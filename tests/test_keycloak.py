import requests
import pytest
import subprocess
import re

BASE_URL = 'http://localhost:8080'
REALM_NAME = 'master'
REALM_NAME_IMPORT = 'ceai'
# ggignore
REALM_NAME_PASSWORD = 'ceai'
USERNAME = 'admin'
# ggignore
PASSWORD = 'cqen'
EXPECTED_LOGIN_THEME = 'cqen'
EXPECTED_EMAIL_THEME = 'cqen'
EXPECTED_ACCOUNT_THEME = 'cqen'
ADMIN_CLIENT_ID = 'admin-cli'
NEW_CLIENT_ID1 = 'test-client1'
NEW_CLIENT_ID2 = 'test-client2'
NEW_CLIENT_ID3 = 'test-client3'
NEW_CLIENT_ID4 = 'test-client4'
NEW_CLIENT_ID5 = 'test-client5'
NEW_CLIENT_ID6 = 'test-client6'
NEW_CLIENT_ID7 = 'test-client7'


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


def get_access_token_with_refresh(base_url, realm_name, client_id, client_secret, username, password):
    token_url = f"{base_url}/realms/{realm_name}/protocol/openid-connect/token"
    payload = {
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret,
        'username': username,
        'password': password,
        'grant_type': 'password'
    }
    response = requests.post(token_url, data=payload)
    print(f"Requête vers {token_url} avec payload {payload}")
    print(f"Réponse : {response.status_code}, {response.text}")
    response.raise_for_status()
    return response.json()['access_token'], response.json().get('refresh_token')


def refresh_access_token(base_url, realm_name, client_id, client_secret, refresh_token):
    token_url = f"{base_url}/realms/{realm_name}/protocol/openid-connect/token"
    payload = {
        'grant_type': 'refresh_token',
        'refresh_token': refresh_token,
        'client_id': client_id,
        'client_secret': client_secret
    }
    response = requests.post(token_url, data=payload)
    response.raise_for_status()
    return response.json()['access_token']

def create_client(base_url, realm_name, client_id):
    admin_token = get_admin_token(base_url, realm_name, ADMIN_CLIENT_ID, USERNAME, PASSWORD)
    url = f'{base_url}/admin/realms/{realm_name}/clients'
    headers = {
        'Authorization': f'Bearer {admin_token}',
        'Content-Type': 'application/json'
    }
    payload = {
        'clientId': client_id,
        'directAccessGrantsEnabled': True,
        'publicClient': False
    }
    response = requests.post(url, json=payload, headers=headers)
    response.raise_for_status()

    client_uuid = None
    clients_url = f'{base_url}/admin/realms/{realm_name}/clients'
    response = requests.get(clients_url, headers=headers)
    response.raise_for_status()
    for client in response.json():
        if client['clientId'] == client_id:
            client_uuid = client['id']
            break

    client_secret_url = f'{base_url}/admin/realms/{realm_name}/clients/{client_uuid}/client-secret'
    response = requests.get(client_secret_url, headers=headers)
    response.raise_for_status()
    client_secret = response.json()['value']

    return client_id, client_secret


def test_realm_import():
    client_id, client_secret = create_client(BASE_URL, REALM_NAME, NEW_CLIENT_ID1)
    CLIENT_TOKEN, REFRESH_TOKEN = get_access_token_with_refresh(BASE_URL, REALM_NAME, client_id, client_secret, USERNAME, PASSWORD)
    url = f"{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}"
    headers = {
        'Authorization': f'Bearer {CLIENT_TOKEN}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    assert realm_data['realm'] == REALM_NAME_IMPORT, f"Expected realm name '{REALM_NAME_IMPORT}', got '{realm_data['realm']}'"
    assert realm_data['enabled'] is True, "Expected realm to be enabled"


def test_password_policy():
    client_id2, client_secret2 = create_client(BASE_URL, REALM_NAME, NEW_CLIENT_ID2)
    CLIENT_TOKEN, REFRESH_TOKEK = get_access_token_with_refresh(BASE_URL, REALM_NAME, client_id2, client_secret2, USERNAME, PASSWORD)
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_PASSWORD}/users'
    headers = {
        'Authorization': f'Bearer {CLIENT_TOKEN}',
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
    assert response.status_code != 201, f"Expected failure, but got {response.status_code}: {response.text}"
    # assert 'password is blacklisted' in response.text, "Password policy violation message not found"


def test_login_theme_import():
    client_id, client_secret = create_client(BASE_URL, REALM_NAME, NEW_CLIENT_ID3)
    CLIENT_TOKEN, REFRESH_TOKEN = get_access_token_with_refresh(BASE_URL, REALM_NAME, client_id, client_secret, USERNAME, PASSWORD)
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}'
    headers = {
        'Authorization': f'Bearer {CLIENT_TOKEN}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    login_theme = realm_data.get('loginTheme')
    assert login_theme is not None, "Expected 'loginTheme' key in realm data, but it does not exist"
    assert login_theme == EXPECTED_LOGIN_THEME, f"Expected login theme '{EXPECTED_LOGIN_THEME}', got '{login_theme}'"


def test_account_theme_import():
    client_id, client_secret = create_client(BASE_URL, REALM_NAME, NEW_CLIENT_ID4)
    CLIENT_TOKEN, REFREH_TOKEN = get_access_token_with_refresh(BASE_URL, REALM_NAME, client_id, client_secret, USERNAME, PASSWORD)
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}'
    headers = {
        'Authorization': f'Bearer {CLIENT_TOKEN}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    account_theme = realm_data.get('accountTheme')
    assert account_theme is not None, "Expected 'accountTheme' key in realm data, but it does not exist"
    assert account_theme == EXPECTED_ACCOUNT_THEME, f"Expected account theme '{EXPECTED_ACCOUNT_THEME}', got '{account_theme}'"


def test_email_theme_import():
    client_id, client_secret = create_client(BASE_URL, REALM_NAME, NEW_CLIENT_ID5)
    CLIENT_TOKEN, REFREH_TOKEN = get_access_token_with_refresh(BASE_URL, REALM_NAME, client_id, client_secret, USERNAME, PASSWORD)
    url = f'{BASE_URL}/admin/realms/{REALM_NAME_IMPORT}'
    headers = {
        'Authorization': f'Bearer {CLIENT_TOKEN}'
    }
    response = requests.get(url, headers=headers)
    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"
    realm_data = response.json()
    email_theme = realm_data.get('emailTheme')
    assert email_theme is not None, "Expected 'emailTheme' key in realm data, but it does not exist"
    assert email_theme == EXPECTED_EMAIL_THEME, f"Expected email theme '{EXPECTED_EMAIL_THEME}', got '{email_theme}'"

def test_check_otp_email_provider_imported():
    # Commande pour exécuter docker-compose et récupérer les logs
    result = subprocess.run(['docker-compose', '-f', 'docker-compose-dev.yml', 'logs', 'keycloak'], capture_output=True, text=True)
    logs = result.stdout

    # Vérifier si les logs contiennent le message indiquant que le provider OTP email a été importé
    otp_email_pattern = r'KC-SERVICES0047: cqen-otp-email-code \(ca\.cqen\.auth\.EmailAuthenticatorFormFactory\) is implementing the internal SPI authenticator'
    assert re.search(otp_email_pattern, logs), "The two-factor authentication module via email has not been imported"


if __name__ == "__main__":
    pytest.main([__file__])