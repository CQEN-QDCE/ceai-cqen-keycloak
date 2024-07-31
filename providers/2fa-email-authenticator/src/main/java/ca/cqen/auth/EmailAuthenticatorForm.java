package ca.cqen.auth;

import lombok.extern.jbosslog.JBossLog;
import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.AuthenticationFlowError;
import org.keycloak.authentication.AuthenticationFlowException;
import org.keycloak.authentication.Authenticator;
import org.keycloak.email.EmailException;
import org.keycloak.email.EmailTemplateProvider;
import org.keycloak.events.Errors;
import org.keycloak.forms.login.LoginFormsProvider;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.models.utils.FormMessage;
import org.keycloak.services.messages.Messages;

import jakarta.ws.rs.core.MultivaluedMap;
import jakarta.ws.rs.core.Response;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;

@JBossLog
public class EmailAuthenticatorForm implements Authenticator {

  static final String ID = "cqen-otp-email-code";
  public static final String EMAIL_CODE = "emailCode";
  private final KeycloakSession session;

  public EmailAuthenticatorForm(KeycloakSession session) {
    this.session = session;
  }

  @Override
  public void authenticate(AuthenticationFlowContext context) {
    challenge(context, null);
  }

  @Override
  public void action(AuthenticationFlowContext context) {
    MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
    if (formData.containsKey("resend")) {
      resetEmailCode(context);
      challenge(context, null);
      return;
    }

    if (formData.containsKey("cancel")) {
      resetEmailCode(context);
      context.resetFlow();
      return;
    }

    boolean valid;
    try {
      int givenEmailCode = Integer.parseInt(formData.getFirst(EMAIL_CODE));
      valid = validateCode(context, givenEmailCode);
    } catch (NumberFormatException e) {
      valid = false;
    }

    if (!valid) {
      context.getEvent().error(Errors.INVALID_USER_CREDENTIALS);
      challenge(context, new FormMessage(Messages.INVALID_ACCESS_CODE));
      return;
    }

    resetEmailCode(context);
    context.success();
  }

  private void challenge(AuthenticationFlowContext context, FormMessage errorMessage) {

    generateAndSendEmailCode(context);

    LoginFormsProvider form = context.form().setExecution(context.getExecution().getId());
    if (errorMessage != null) {
      form.setErrors(List.of(errorMessage));
    }

    Response response = form.createForm("email-code-form.ftl");
    context.challenge(response);
  }

  private void generateAndSendEmailCode(AuthenticationFlowContext context) {

    if (context.getAuthenticationSession().getAuthNote(EMAIL_CODE) != null) {
      return;
    }

    int emailCode = ThreadLocalRandom.current().nextInt(100000, 1000000);
    sendEmailWithCode(context.getRealm(), context.getUser(), String.valueOf(emailCode));
    context.getAuthenticationSession().setAuthNote(EMAIL_CODE, Integer.toString(emailCode));
  }

  private void resetEmailCode(AuthenticationFlowContext context) {
    context.getAuthenticationSession().removeAuthNote(EMAIL_CODE);
  }

  private boolean validateCode(AuthenticationFlowContext context, int givenCode) {
    int emailCode = Integer.parseInt(context.getAuthenticationSession().getAuthNote(EMAIL_CODE));
    return givenCode == emailCode;
  }

  @Override
  public boolean requiresUser() {
    return true;
  }

  @Override
  public boolean configuredFor(KeycloakSession session, RealmModel realm, UserModel user) {
    return true;
  }

  @Override
  public void setRequiredActions(KeycloakSession session, RealmModel realm, UserModel user) {
    // ne fait rien.
  }

  @Override
  public void close() {
    // ne rien faire
  }

  private void sendEmailWithCode(RealmModel realm, UserModel user, String code) {
    if (user.getEmail() == null) {
      log.warnf(
          "Impossible d'envoyer le code d'accès par courriel en raison d'une adresse courriel manquant. royaume=%s utilisateur=%s",
          realm.getId(),
          user.getUsername());
      throw new AuthenticationFlowException(AuthenticationFlowError.INVALID_USER);
    }

    Map<String, Object> mailBodyAttributes = new HashMap<>();
    mailBodyAttributes.put("username", user.getUsername());
    mailBodyAttributes.put("code", code);

    String realmName = realm.getDisplayName() != null ? realm.getDisplayName() : realm.getName();
    List<Object> subjectParams = List.of(realmName);
    try {
      EmailTemplateProvider emailProvider = session.getProvider(EmailTemplateProvider.class);
      emailProvider.setRealm(realm);
      emailProvider.setUser(user);
      emailProvider.send("emailCodeSubject", subjectParams, "code-email.ftl", mailBodyAttributes);
    } catch (EmailException eex) {
      log.errorf(eex, "Échec de l'envoi du courriel du code d'accès. royaume=%s utilisateur=%s", realm.getId(),
          user.getUsername());
    }
  }
}