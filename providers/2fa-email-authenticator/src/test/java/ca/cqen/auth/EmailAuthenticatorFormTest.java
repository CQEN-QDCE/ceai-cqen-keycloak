package ca.cqen.auth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;

import jakarta.ws.rs.core.MultivaluedMap;
import jakarta.ws.rs.core.MultivaluedHashMap;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.AuthenticationFlowException;
import org.keycloak.email.EmailTemplateProvider;
import org.keycloak.events.EventBuilder;
import org.keycloak.forms.login.LoginFormsProvider;
import org.keycloak.models.AuthenticationExecutionModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.sessions.AuthenticationSessionModel;
import org.mockito.InjectMocks;
import org.mockito.Mockito;

public class EmailAuthenticatorFormTest {

    KeycloakSession session = mock(KeycloakSession.class);

    MultivaluedMap<String, String> formParameters;

    AuthenticationFlowContext context;
    AuthenticationSessionModel sessionModel;
    org.keycloak.http.HttpRequest request;
    EmailTemplateProvider emailTemplateProvider;
    LoginFormsProvider loginFormsProvider;
    AuthenticationExecutionModel authenticationExecutionModel;
    EventBuilder eventBuilder;
    UserModel user;
    RealmModel realm;

    static final String ID = "cqen-otp-email-code";
    public static final String EMAIL_CODE = "emailCode";

    @InjectMocks
    private EmailAuthenticatorForm authenticator;

    @BeforeEach
    public void setUp() {
        user = mock(UserModel.class);
        realm = mock(RealmModel.class);
        authenticator = new EmailAuthenticatorForm(session);
        formParameters = new MultivaluedHashMap<>();
        sessionModel = mock(AuthenticationSessionModel.class);
        context = mock(AuthenticationFlowContext.class);
        request = mock(org.keycloak.http.HttpRequest.class);
        emailTemplateProvider = mock(EmailTemplateProvider.class);
        loginFormsProvider = mock(LoginFormsProvider.class);
        authenticationExecutionModel = mock(AuthenticationExecutionModel.class);
        eventBuilder = mock(EventBuilder.class);

        Mockito.when(context.getHttpRequest()).thenReturn(request);
        Mockito.when(request.getDecodedFormParameters()).thenReturn(formParameters);
        Mockito.when(context.getAuthenticationSession()).thenReturn(sessionModel);
        Mockito.when(context.getUser()).thenReturn(user);
        Mockito.when(context.getRealm()).thenReturn(realm);
    }

    @Test
    public void requiresUser_shouldReturnsTrue() {
        boolean expected = true;

        boolean actual = authenticator.requiresUser();

        assertEquals(expected, actual);
    }

    @Test
    public void configuredFor_shouldReturnsTrue() {
        boolean expected = true;

        boolean actual = authenticator.configuredFor(session, realm, user);

        assertEquals(expected, actual);
    }

    @Test
    public void action_whenCancel_shouldRemoveAuthNote() {
        formParameters.add("cancel", "");

        authenticator.action(context);

        Mockito.verify(sessionModel).removeAuthNote(EMAIL_CODE);
    }

    @Test
    public void action_whenCancel_shouldResetFlow() {
        formParameters.add("cancel", "");

        authenticator.action(context);

        Mockito.verify(context).resetFlow();
    }

    @Test
    public void action_whenResend_shouldRemoveAuthNote() {

        formParameters.add("resend", "");

        Mockito.when(sessionModel.getAuthNote(EMAIL_CODE)).thenReturn("any");
        Mockito.when(context.getExecution()).thenReturn(authenticationExecutionModel);
        Mockito.when(authenticationExecutionModel.getId()).thenReturn("any");

        Mockito.when(context.form()).thenReturn(loginFormsProvider);
        Mockito.when(loginFormsProvider.setExecution("any")).thenReturn(loginFormsProvider);

        authenticator.action(context);

        Mockito.verify(sessionModel).removeAuthNote(EMAIL_CODE);
    }

    @Test
    public void action_whenResend_shouldNotSetErrors() {

        formParameters.add("resend", "");
        Mockito.when(sessionModel.getAuthNote(EMAIL_CODE)).thenReturn("any");
        Mockito.when(context.getExecution()).thenReturn(authenticationExecutionModel);
        Mockito.when(authenticationExecutionModel.getId()).thenReturn("any");
        Mockito.when(context.form()).thenReturn(loginFormsProvider);
        Mockito.when(loginFormsProvider.setExecution("any")).thenReturn(loginFormsProvider);

        authenticator.action(context);

        Mockito.verify(loginFormsProvider, times(0)).setErrors(anyList());
    }

    @Test
    public void action_whenValidCode_userMustAuthenticateSuuefully() {

        formParameters.add(EMAIL_CODE, "123456");
        Mockito.when(sessionModel.getAuthNote(EMAIL_CODE)).thenReturn("123456");
        Mockito.when(context.getExecution()).thenReturn(authenticationExecutionModel);
        Mockito.when(authenticationExecutionModel.getId()).thenReturn("any");
        Mockito.when(context.form()).thenReturn(loginFormsProvider);
        Mockito.when(loginFormsProvider.setExecution("any")).thenReturn(loginFormsProvider);
        Mockito.when(user.getEmail()).thenReturn(null);

        authenticator.action(context);

        Mockito.verify(context).success();
    }

    @Test
    public void action_whenCodeNotInteger_shouldThrowNumberFormatException() {

        formParameters.add(EMAIL_CODE, "abcdef");
        Mockito.when(sessionModel.getAuthNote(EMAIL_CODE)).thenReturn("123456");
        Mockito.when(context.getExecution()).thenReturn(authenticationExecutionModel);
        Mockito.when(authenticationExecutionModel.getId()).thenReturn("any");
        Mockito.when(context.form()).thenReturn(loginFormsProvider);
        Mockito.when(loginFormsProvider.setExecution("any")).thenReturn(loginFormsProvider);
        Mockito.when(user.getEmail()).thenReturn(null);
        Mockito.when(context.getEvent()).thenReturn(eventBuilder);

        authenticator.action(context);

        Mockito.verify(loginFormsProvider, times(1)).setErrors(anyList());
    }

    @Test
    public void action_whenCodeNotInteger_shouldSetError() {

        formParameters.add(EMAIL_CODE, "abcdef");
        Mockito.when(sessionModel.getAuthNote(EMAIL_CODE)).thenReturn("123456");
        Mockito.when(context.getExecution()).thenReturn(authenticationExecutionModel);
        Mockito.when(authenticationExecutionModel.getId()).thenReturn("any");
        Mockito.when(context.form()).thenReturn(loginFormsProvider);
        Mockito.when(loginFormsProvider.setExecution("any")).thenReturn(loginFormsProvider);
        Mockito.when(user.getEmail()).thenReturn(null);
        Mockito.when(context.getEvent()).thenReturn(eventBuilder);

        authenticator.action(context);

        Mockito.verify(loginFormsProvider, times(1)).setErrors(anyList());
    }

    @Test
    public void action_whenCodeNotInteger_shouldCreateEmailCodeForm() {

        formParameters.add(EMAIL_CODE, "abcdef");
        Mockito.when(sessionModel.getAuthNote(EMAIL_CODE)).thenReturn("123456");
        Mockito.when(context.getExecution()).thenReturn(authenticationExecutionModel);
        Mockito.when(authenticationExecutionModel.getId()).thenReturn("any");
        Mockito.when(context.form()).thenReturn(loginFormsProvider);
        Mockito.when(loginFormsProvider.setExecution("any")).thenReturn(loginFormsProvider);
        Mockito.when(user.getEmail()).thenReturn(null);
        Mockito.when(context.getEvent()).thenReturn(eventBuilder);

        authenticator.action(context);

        Mockito.verify(loginFormsProvider, times(1)).createForm("email-code-form.ftl");
    }

    @Test
    public void action_whenCodeIsNotSet_shouldGenerateCode() {

        formParameters.add(EMAIL_CODE, "abcdef");
        Mockito.when(realm.getDisplayName()).thenReturn("realm-display-name");
        Mockito.when(realm.getId()).thenReturn("87a20cdd-25da-4dc2-b787-68054ec2c5ca");
        Mockito.when(context.getExecution()).thenReturn(authenticationExecutionModel);
        Mockito.when(context.form()).thenReturn(loginFormsProvider);
        Mockito.when(authenticationExecutionModel.getId()).thenReturn("any");
        Mockito.when(sessionModel.getAuthNote(EMAIL_CODE)).thenReturn(null);
        Mockito.when(loginFormsProvider.setExecution("any")).thenReturn(loginFormsProvider);
        Mockito.when(user.getEmail()).thenReturn("any@any.com");
        Mockito.when(context.getEvent()).thenReturn(eventBuilder);
        Mockito.when(session.getProvider(EmailTemplateProvider.class)).thenReturn(emailTemplateProvider);

        authenticator.action(context);

        Mockito.verify(sessionModel, times(1)).setAuthNote(anyString(), anyString());
    }

    @Test
    public void action_whenCodeIsNotSet_shouldThrowAuthenticationFlowException() {

        formParameters.add(EMAIL_CODE, "abcdef");
        Mockito.when(realm.getDisplayName()).thenReturn("realm-display-name");
        Mockito.when(realm.getId()).thenReturn("87a20cdd-25da-4dc2-b787-68054ec2c5ca");
        Mockito.when(context.getExecution()).thenReturn(authenticationExecutionModel);
        Mockito.when(context.form()).thenReturn(loginFormsProvider);
        Mockito.when(user.getUsername()).thenReturn("any");
        Mockito.when(sessionModel.getAuthNote(EMAIL_CODE)).thenReturn(null);
        Mockito.when(context.getExecution()).thenReturn(authenticationExecutionModel);
        Mockito.when(authenticationExecutionModel.getId()).thenReturn("any");
        Mockito.when(context.form()).thenReturn(loginFormsProvider);
        Mockito.when(loginFormsProvider.setExecution("any")).thenReturn(loginFormsProvider);
        Mockito.when(user.getEmail()).thenReturn(null);

        Mockito.when(context.getEvent()).thenReturn(eventBuilder);

        assertThrows(AuthenticationFlowException.class, () -> {
            authenticator.action(context);
        });
    }
}