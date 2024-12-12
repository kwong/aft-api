
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



# variable "openapi_config" {
#   description = "The OpenAPI Configuration"

# }
