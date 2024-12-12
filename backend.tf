terraform {
  backend "s3" {
    bucket         = "aft-ollion-poc-terraform-backend"
    key            = "aft-management/ap-southeast-1/aft-api.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "aft-ollion-poc-terraform-backend"
  }
}
