# Variables

variable "app_name" {
  description = "Name of the REST API"
  type        = string
  default     = "aft-api"
}
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "openapi_config" {
  description = "The OpenAPI Configuration"
  default     = ""

}
# variable "github_repo" {
#   description = "GitHub Repository for AFT Account Requests"
#   type        = string
# }

# variable "github_owner" {
#   description = "GitHub Repository Owner"
#   type        = string
# }

# variable "github_token" {
#   description = "GitHub OAuth Token"
#   type        = string
#   sensitive   = true
# }
