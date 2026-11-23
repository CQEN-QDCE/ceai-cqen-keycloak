import os

import pytest
import requests

BASE_URL = os.getenv('KEYCLOAK_TEST_URL', 'http://localhost:8080').rstrip('/')
REALM_NAME = 'master'
REALM_NAME_IMPORT = 'ceai'
REALM_NAME_PASSWORD = 'ceai'
USERNAME = 'admin'
PASSWORD = 'cqen'
EXPECTED_LOGIN_THEME = 'cqen'
EXPECTED_EMAIL_THEME = 'cqen'
EXPECTED_ACCOUNT_THEME = 'cqen'
ADMIN_CLIENT_ID = 'admin-cli'


def get_admin_token(base_url, realm_name, client_id, username, password):
    url = f'{base_url}/realms/{realm_name}/protocol/openid-connect/token'
    payload = {
        'client_id': client_id,
        'username': username,
        'password': password,
        'grant_type': 'password'
    }
    response = requests.post(url, data=payload)
    response.raise_for_status()
    return response.json()['access_token']


def test_realm_import():
    admin_token = get_admin_token(BASE_URL, REALM_NAME, ADMIN_CLIENT_ID, USERNAME, PASSWORD)
    url = f"{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}"
    headers = {
        'Authorization': f'Bearer {admin_token}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    assert realm_data['realm'] == REALM_NAME_IMPORT, f"Expected realm name '{REALM_NAME_IMPORT}', got '{realm_data['realm']}'"
    assert realm_data['enabled'] is True, "Expected realm to be enabled"


def test_password_policy():
    admin_token = get_admin_token(BASE_URL, REALM_NAME, ADMIN_CLIENT_ID, USERNAME, PASSWORD)
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_PASSWORD}/users'
    headers = {
        'Authorization': f'Bearer {admin_token}',
        'Content-Type': 'application/json'
    }
    forbidden_password = 'password123'
    payload = {
        'username': 'testuser',
        'enabled': True,
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'testuser@example.com',
        'credentials': [{'type': 'password', 'value': forbidden_password, 'temporary': False}]
    }
    response = requests.post(url, json=payload, headers=headers)
    assert response.status_code == 400, response.text
    assert "blacklist" in response.text.lower()


def test_login_theme_import():
    admin_token = get_admin_token(BASE_URL, REALM_NAME, ADMIN_CLIENT_ID, USERNAME, PASSWORD)
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}'
    headers = {
        'Authorization': f'Bearer {admin_token}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    login_theme = realm_data.get('loginTheme')
    assert login_theme is not None, "Expected 'loginTheme' key in realm data, but it does not exist"
    assert login_theme == EXPECTED_LOGIN_THEME, f"Expected login theme '{EXPECTED_LOGIN_THEME}', got '{login_theme}'"


def test_account_theme_import():
    admin_token = get_admin_token(BASE_URL, REALM_NAME, ADMIN_CLIENT_ID, USERNAME, PASSWORD)
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}'
    headers = {
        'Authorization': f'Bearer {admin_token}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    account_theme = realm_data.get('accountTheme')
    assert account_theme is not None, "Expected 'accountTheme' key in realm data, but it does not exist"
    assert account_theme == EXPECTED_ACCOUNT_THEME, f"Expected account theme '{EXPECTED_ACCOUNT_THEME}', got '{account_theme}'"


def test_email_theme_import():
    admin_token = get_admin_token(BASE_URL, REALM_NAME, ADMIN_CLIENT_ID, USERNAME, PASSWORD)
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}'
    headers = {
        'Authorization': f'Bearer {admin_token}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    email_theme = realm_data.get('emailTheme')
    assert email_theme is not None, "Expected 'emailTheme' key in realm data, but it does not exist"
    assert email_theme == EXPECTED_EMAIL_THEME, f"Expected email theme '{EXPECTED_EMAIL_THEME}', got '{email_theme}'"

def test_check_otp_email_provider_imported():
    admin_token = get_admin_token(BASE_URL, REALM_NAME, ADMIN_CLIENT_ID, USERNAME, PASSWORD)
    response = requests.get(
        f"{BASE_URL}/admin/serverinfo",
        headers={"Authorization": f"Bearer {admin_token}"},
        timeout=10,
    )
    response.raise_for_status()
    assert "cqen-otp-email-code" in response.json()["providers"]["authenticator"]["providers"]


if __name__ == "__main__":
    raise SystemExit(pytest.main([__file__]))
