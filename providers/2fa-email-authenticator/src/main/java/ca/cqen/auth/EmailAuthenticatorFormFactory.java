package ca.cqen.auth;

import com.google.auto.service.AutoService;
import java.util.Collections;
import org.keycloak.Config;
import org.keycloak.authentication.Authenticator;
import org.keycloak.authentication.AuthenticatorFactory;
import org.keycloak.models.AuthenticationExecutionModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;
import org.keycloak.provider.ProviderConfigProperty;

import java.util.List;

@AutoService(AuthenticatorFactory.class)
public class EmailAuthenticatorFormFactory implements AuthenticatorFactory {

  @Override
  public String getDisplayType() {
    return "Courriel OTP";
  }

  @Override
  public String getReferenceCategory() {
    return null;
  }

  @Override
  public boolean isConfigurable() {
    return false;
  }

  protected static final AuthenticationExecutionModel.Requirement[] REQUIREMENT_CHOICES = {
      AuthenticationExecutionModel.Requirement.REQUIRED, AuthenticationExecutionModel.Requirement.ALTERNATIVE,
      AuthenticationExecutionModel.Requirement.DISABLED
  };

  @Override
  public AuthenticationExecutionModel.Requirement[] getRequirementChoices() {
    return REQUIREMENT_CHOICES;
  }

  @Override
  public boolean isUserSetupAllowed() {
    return false;
  }

  @Override
  public String getHelpText() {
    return "Authentification via couriel otp.";
  }

  @Override
  public List<ProviderConfigProperty> getConfigProperties() {
    return Collections.emptyList();
  }

  @Override
  public void close() {
    // ne rien faire
  }

  @Override
  public Authenticator create(KeycloakSession session) {
    return new EmailAuthenticatorForm(session);
  }

  @Override
  public void init(Config.Scope config) {
    // ne rien faire
  }

  @Override
  public void postInit(KeycloakSessionFactory factory) {
    // ne rien faire
  }

  @Override
  public String getId() {
    return EmailAuthenticatorForm.ID;
  }
}
