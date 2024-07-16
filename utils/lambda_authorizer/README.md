# API Gateway Lambda Authorizer

Pour compiler le lambda authorizer:

```
./build.sh
```

## Variables d'environnement

* **JWT_ISSUER** : Url du realm Keycloak Ex: https://keycloak.example.com/realms/example
* **JWT_ISSUER_CERTS_PATH** : Chemin vers les certificats publics du realm (relatif à l'url du realm) Ex: /protocol/openid-connect/certs
* **JWT_AUDIENCE** : Audience du client autorisé
