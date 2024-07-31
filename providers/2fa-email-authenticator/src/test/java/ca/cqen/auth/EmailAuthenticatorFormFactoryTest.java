package ca.cqen.auth;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;

import org.junit.jupiter.api.Test;
import org.keycloak.authentication.Authenticator;
import org.keycloak.models.AuthenticationExecutionModel;
import org.keycloak.models.KeycloakSession;

public class EmailAuthenticatorFormFactoryTest {
  EmailAuthenticatorFormFactory factory = new EmailAuthenticatorFormFactory();

  @Test
  public void getDisplayType_shouldReturnsCourrielOTP() {
    String expected = "Courriel OTP";

    String actual = factory.getDisplayType();

    assertEquals(expected, actual);
  }

  @Test
  public void getReferenceCategory_shouldReturnsNull() {
    String expected = null;

    String actual = factory.getReferenceCategory();

    assertEquals(expected, actual);
  }

  @Test
  public void getRequirementChoices_shouldReturnsListOfChoicesAlternativeRequiredDisabled() {
    AuthenticationExecutionModel.Requirement[] expected = {
        AuthenticationExecutionModel.Requirement.REQUIRED, AuthenticationExecutionModel.Requirement.ALTERNATIVE,
        AuthenticationExecutionModel.Requirement.DISABLED
    };

    AuthenticationExecutionModel.Requirement[] actual = factory.getRequirementChoices();

    assertArrayEquals(expected, actual);
  }

  @Test
  public void isUserSetupAllowed_shouldReturnsFalse() {
    boolean expected = false;

    boolean actual = factory.isUserSetupAllowed();

    assertEquals(expected, actual);
  }

  @Test
  public void getHelpText_shouldReturnsAuthentificationViaCourieOtpLikeHelpText() {
    String expected = "Authentification via couriel otp.";

    String actual = factory.getHelpText();

    assertEquals(expected, actual);
  }

  @Test
  public void getId_shouldReturnsCqenOtpEmailCodeLikeId() {
    String expected = "cqen-otp-email-code";

    String actual = factory.getId();

    assertEquals(expected, actual);
  }

  @Test
  public void create_whenAnySession_shouldReturnsEmailAuthenticatorForm() {
    KeycloakSession session = mock(KeycloakSession.class);

    Authenticator actual = factory.create(session);

    assertEquals(EmailAuthenticatorForm.class, actual.getClass());
  }
}
