# === 1. Authentification : obtenir un token ===
POST {{KEYCLOAK_URL}}/realms/master/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

client_id=admin-cli
&username={{USERNAME}}
&password={{PASSWORD}}
&grant_type=password

[Captures]
access_token: jsonpath "$.access_token"

###

# === 2. Vérifier si le realm existe déjà ===
GET {{KEYCLOAK_URL}}/admin/realms/{{REALM_NAME}}
Authorization: Bearer {{access_token}}

[Options]
continue-on-error: true

[Captures]
realm_status: status
existing_realm: body

###

# === 3. Si le realm n’existe pas, on le crée ===
# (status == 404)
PUT {{KEYCLOAK_URL}}/admin/realms/{{REALM_NAME}}
Authorization: Bearer {{access_token}}
Content-Type: application/json

@realm-export.json

[Asserts]
status == 201 or status == 204
[Options]
predicate: realm_status == 404

###

# === 4. Si le realm existe, mais est différent → mise à jour ===
# (status == 200 et JSON différent)
PUT {{KEYCLOAK_URL}}/admin/realms/{{REALM_NAME}}
Authorization: Bearer {{access_token}}
Content-Type: application/json

@realm-export.json

[Options]
predicate: |
  realm_status == 200 &&
  body != readFile("realm-export.json")