import requests
import pytest

BASE_URL = 'http://localhost:8080'
REALM_NAME = 'master'
REALM_NAME_IMPORT = 'ceai'
REALM_NAME_PASSWORD = 'ceai'
CLIENT_ID = 'test'
CLIENT_SECRET = 'KGXDTjxWfdrEczIIHiwqhtGranJuyDEU'
USERNAME = 'test'
PASSWORD = 'test'
EXPECTED_LOGIN_THEME = 'cqen'
EXPECTED_EMAIL_THEME = 'cqen'
EXPECTED_ACCOUNT_THEME = 'cqen'


def get_access_token():
    url = f'{BASE_URL}/realms/{REALM_NAME}/protocol/openid-connect/token'
    payload = {
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
        'username': USERNAME,
        'password': PASSWORD,
        'grant_type': 'password'
    }
    response = requests.post(url, data=payload)
    response.raise_for_status()
    return response.json()['access_token']


def test_realm_import():
    token = get_access_token()
    url = f"{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}"
    headers = {
        'Authorization': f'Bearer {token}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    assert realm_data['realm'] == REALM_NAME_IMPORT, f"Expected realm name '{REALM_NAME_IMPORT}', got '{realm_data['realm']}'"
    assert realm_data['enabled'] is True, "Expected realm to be enabled"


def test_password_policy():
    token = get_access_token()
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_PASSWORD}/users'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    # Exemple de mot de passe interdit
    forbidden_password = 'password123'
    payload = {
        'username': 'testuser7',
        'enabled': True,
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'testuser7@example.com',
        'credentials': [{'type': 'password', 'value': forbidden_password, 'temporary': False}]
    }
    response = requests.post(url, json=payload, headers=headers)
    # On s'attend à ce que la création de l'utilisateur échoue à cause de la politique de mot de passe
    assert response.status_code != 201, f"Expected failure, but got {response.status_code}: {response.text}"
    # Vérifier le message d'erreur pour la politique de mot de passe
    assert 'Password policy not met' in response.text, "Password policy violation message not found"


def test_login_theme_import():
    token = get_access_token()
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}'
    headers = {
        'Authorization': f'Bearer {token}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    # Vérifier si la clé 'loginTheme' existe dans le dictionnaire realm_data
    login_theme = realm_data.get('loginTheme')
    assert login_theme is not None, "Expected 'loginTheme' key in realm data, but it does not exist"
    # Maintenant, vous pouvez effectuer votre assertion
    assert login_theme == EXPECTED_LOGIN_THEME, f"Expected login theme '{EXPECTED_LOGIN_THEME}', got '{login_theme}'"


def test_account_theme_import():
    token = get_access_token()
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}'
    headers = {
        'Authorization': f'Bearer {token}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    # Vérifier si la clé 'accountTheme' existe dans le dictionnaire realm_data
    account_theme = realm_data.get('accountTheme')
    assert account_theme is not None, "Expected 'accountTheme' key in realm data, but it does not exist"
    # Maintenant, vous pouvez effectuer votre assertion
    assert account_theme == EXPECTED_ACCOUNT_THEME, f"Expected account theme '{EXPECTED_ACCOUNT_THEME}', got '{account_theme}'"


def test_email_theme_import():
    token = get_access_token()
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}'
    headers = {
        'Authorization': f'Bearer {token}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    # Vérifier si la clé 'emailTheme' existe dans le dictionnaire realm_data
    email_theme = realm_data.get('emailTheme')
    assert email_theme is not None, "Expected 'emailTheme' key in realm data, but it does not exist"
    # Maintenant, vous pouvez effectuer votre assertion
    assert email_theme == EXPECTED_EMAIL_THEME, f"Expected email theme '{EXPECTED_EMAIL_THEME}', got '{email_theme}'"


if __name__ == "__main__":
    pytest.main([__file__])