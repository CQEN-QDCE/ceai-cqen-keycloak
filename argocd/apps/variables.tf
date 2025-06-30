# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Nom du cluster"
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0 && length(var.cluster_name) <= 19
    error_message = "Le nom du cluster doit comporter entre 1 et 19 caractères"
  }
  default = "cluster-eks"
}

variable "cluster_region" {
  description = "Région où créer le cluster"
  type        = string
  default     = "ca-central-1"
}

variable "aws_profile" {
  type        = string
  description = "Optionnel : Si une connexion SSO est utilisée, spécifiez le nom du profil SSO dans le fichier .aws/config sur la machine exécutant le déploiement."
  default     = null
}

variable "assume_role_arn" {
  type        = string
  description = "L'ARN du rôle à assumer"
  default     = null
}

variable "workload_account_type" {
  type        = string
  description = "Nom de l'environnement système déployé sur AWS LZA"
  default     = "Sandbox"

  validation {
    condition     = contains(["Sandbox", "Dev", "Prod"], var.workload_account_type)
    error_message = "workload_account_type doit être l'une des valeurs suivantes : Sandbox, Development, Production"
  }
}

variable "project_name" {
  description = "Projet pour Keycloak"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN du certificat ACM pour le load balancer"
  type        = string
}

variable "server_image_keycloak" {
  description = "Valeur du dépôt d'image pour le serveur Keycloak"
  type        = string
  default     = "quay.io/keycloak/keycloak"
}

variable "image_tag_keycloak" {
  description = "Valeur du tag d'image pour le serveur Keycloak"
  type        = string
  default     = "26.2.4"
}

variable "chart_path_keycloak" {
  description = "Chemin du chart dans le dépôt pour le serveur Keycloak"
  type        = string
  default     = "charts"
}

variable "repo_github_url" {
  description = "URL du dépôt GitHub pour Keycloak"
  type        = string
  default     = "https://github.com/CQEN-QDCE/ceai-cqen-keycloak"
}

variable "target_revision" {
  description = "Révision cible du dépôt pour Keycloak"
  type        = string
  default     = "feature/helmcharts"
}

variable "host_path_keycloak" {
  description = "Chemin d'hôte pour Keycloak"
  type        = string
  default     = "keycloak-preprod.asea.cqen.ca"
}

variable "replica_count_keycloak" {
  description = "Nombre de réplicas pour Keycloak"
  type        = number
  default     = 1
}

variable "endpoint_bd_keycloak" {
  description = "Endpoint pour la base de données Keycloak"
  type        = string
}

variable "keycloak_db_name" {
  description = "Nom de la base de données Keycloak"
  type        = string
  default     = "keycloak-xroad-default"
}

variable "keycloak_db_admin_user" {
  description = "Utilisateur administrateur de la base de données Keycloak"
  type        = string
}

variable "keycloak_db_admin_password" {
  description = "Mot de passe administrateur de la base de données Keycloak"
  type        = string
}
