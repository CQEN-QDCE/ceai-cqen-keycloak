################################################################################
# ARGOCD apps for SS Management
################################################################################

resource "random_password" "keycloak_admin_user" {
  length  = 4
  special = false
}

resource "random_password" "keycloak_admin_password" {
  length           = 18
  special          = true
  override_special = "!@#%&*"
}

resource "random_string" "keycloak_secret_name" {
  length  = 16
  special = false
  upper   = false
}

resource "aws_secretsmanager_secret" "keycloak_secret" {
  name = "${local.cluster_name}-keycloak-${terraform.workspace}-admin-credentials-${random_string.keycloak_secret_name.result}"
  #kms_key_id = "aws/secretsmanager"
}

resource "aws_secretsmanager_secret_version" "keycloak_secret_version" {
  secret_id = aws_secretsmanager_secret.keycloak_secret.id
  secret_string = jsonencode({
    adminUser     = "admin${random_password.keycloak_admin_user.result}"
    adminPassword = random_password.keycloak_admin_password.result
  })
}

resource "kubernetes_manifest" "keycloak_app_of_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "keycloak-app-of-apps-${terraform.workspace}"
      namespace = "argocd"
      labels = {
        "app.kubernetes.io/name"    = "keycloak-app-of-apps-${terraform.workspace}"
        "app.kubernetes.io/part-of" = var.project_name
      }
    }
    spec = {
      project = var.project_name
      source = {
        repoURL        = var.repo_github_url
        targetRevision = var.target_revision
        path           = var.chart_path_keycloak

        helm = {
          values = yamlencode({
            keycloak = {
              host         = var.host_path_keycloak
              image        = var.server_image_keycloak
              imageTag     = var.image_tag_keycloak
              replicaCount = var.replica_count_keycloak
              admin = {
                username = jsondecode(aws_secretsmanager_secret_version.keycloak_secret_version.secret_string)["adminUser"]
                password = jsondecode(aws_secretsmanager_secret_version.keycloak_secret_version.secret_string)["adminPassword"]
              }
              db = {
                username = var.keycloak_db_admin_user
                password = var.keycloak_db_admin_password
                host     = var.endpoint_bd_keycloak
                name     = var.keycloak_db_name
              }
            }
            ingress = {
              annotations = {
                subnetAllowList   = "${module.sea_network.web_subnet_a.id}, ${module.sea_network.web_subnet_b.id}"
                acmCertificateArn = var.acm_certificate_arn
              }
            }
          })
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.project_name
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
  depends_on = [aws_secretsmanager_secret_version.keycloak_secret_version]
}


resource "kubernetes_manifest" "keycloak_github_app_secret" {
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "keycloak-repo-github-app-${terraform.workspace}"
      namespace = "argocd"
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
      }
    }
    type = "Opaque"
    data = {
      url                     = base64encode(var.repo_github_image_url)
      type                    = base64encode("git")
      githubAppID             = base64encode(var.github_app_id)
      githubAppInstallationID = base64encode(var.github_app_installation_id)
      githubAppPrivateKey     = base64encode(var.github_app_private_key)
      project                 = base64encode(var.project_name)
    }
  }
}


resource "kubernetes_secret" "ghcr_dockerconfig" {
  metadata {
    name      = "github-registry-credentials"
    namespace = var.project_name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = base64encode(
      jsonencode({
        auths = {
          "ghcr.io" = {
            username = var.ghcr_username
            password = var.ghcr_pat
            auth     = base64encode("${var.ghcr_username}:${var.ghcr_pat}")
          }
        }
      })
    )
  }
}