# API Gateway Lambda Authorizer

Pour compiler le lambda authorizer:

```
./build.sh
```

## Variables d'environnement

* **JWT_ISSUER** : Url du realm Keycloak Ex: https://keycloak.example.com/realms/example
* **JWT_ISSUER_CERTS_PATH** : Chemin vers les certificats publics du realm (relatif à l'url du realm) Ex: /protocol/openid-connect/certs
* **JWT_AUDIENCE** : Audience du client autorisé


## Exemple de ressource Terraform pour déployer la fonction

```
resource "aws_lambda_function" "api_auth_lambda" {
  function_name = "${local.name}-authorizer"
  s3_bucket     = data.aws_s3_bucket.lambda_bucket_s3.bucket
  s3_key        = data.aws_s3_object.lambda_bucket_object.key
  role          = aws_iam_role.role.arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  environment {
    variables = {
      "JWT_AUDIENCE"          = var.jwt_audience
      "JWT_ISSUER"            = var.jwt_issuer
      "JWT_ISSUER_CERTS_PATH" = var.jwt_certs_path
    }
  }
  vpc_config {
    subnet_ids         = var.aws_lambda_app_subnets_id
    security_group_ids = [var.authorizer_security_group_id]
  }
}
```