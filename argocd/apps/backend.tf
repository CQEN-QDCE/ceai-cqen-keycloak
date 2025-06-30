terraform {
  backend "s3" {
    workspace_key_prefix = "environments"
    key                  = "apps/keycloak/terraform.tfstate"
    region               = "ca-central-1"
  }
}