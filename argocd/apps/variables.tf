# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster"
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0 && length(var.cluster_name) <= 19
    error_message = "The cluster name must be between [1, 19] characters"
  }
  default = "cluster-eks"

}

variable "cluster_region" {
  description = "Region to create the cluster"
  type        = string
  default     = "ca-central-1"
}

variable "aws_profile" {
  type        = string
  description = "Optional: If an SSO connection is being used, specify the SSO profile name in the .aws/config file on the machine executing the deployment."
  default     = null
}

variable "assume_role_arn" {
  type        = string
  description = "The ARN of the role to assume"
  default     = null
}

variable "workload_account_type" {
  type        = string
  description = "Name of system environment deployed on LZA AWS"
  default     = "Sandbox"

  validation {
    condition     = contains(["Sandbox", "Dev", "Prod"], var.workload_account_type)
    error_message = "workload_account_type must be one of: Sandbox, Development, Production"
  }
}

variable "project_name" {
  description = "project for Keycloak"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the load balancer"
  type        = string
}

variable "server_image_keycloak" {
  description = "value of the image repo for the Keycloak server"
  type        = string
  default     = "quay.io/keycloak/keycloak"
}

variable "image_tag_keycloak" {
  description = "value of the image tag for the Keycloak server"
  type        = string
  default     = "26.2.4"
}

variable "chart_path_keycloak" {
  description = "The path to the chart in the repository for the Keycloak server"
  type        = string
  default     = "charts"
}

variable "repo_github_url" {
  description = "The URL of the repository for Keycloak"
  type        = string
  default     = "https://github.com/CQEN-QDCE/ceai-cqen-keycloak"
}

variable "target_revision" {
  description = "The target revision of the repository for Keycloak"
  type        = string
  default     = "feature/helmcharts"
}


variable "host_path_keycloak" {
  description = "Host path for Keycloak"
  type        = string
  default     = "keyclaok-preprod.asea.cqen.ca"
}

variable "replica_count_keycloak" {
  description = "Number of replicas for Keycloak"
  type        = number
  default     = 1
}

variable "endpoint_bd_keycloak" {
  description = "Endpoint for the Keycloak database"
  type        = string
}

variable "keycloak_db_name" {
  description = "Keycloak database name"
  type        = string
  default     = "keycloak-xroad-default"
}

variable "keycloak_db_admin_user" {
  description = "Keycloak database admin user"
  type        = string
}

variable "keycloak_db_admin_password" {
  description = "Keycloak database admin password"
  type        = string
}