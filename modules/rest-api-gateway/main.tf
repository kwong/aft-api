# API Gateway
resource "aws_api_gateway_rest_api" "this" {
  name        = var.app_name
  description = var.app_name

  body = var.openapi_config
  #tags = module.this.tags

  endpoint_configuration {
    types = ["REGIONAL"]

  }
}



# API Gateway Stages
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.aft_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.environment
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "aft_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(aws_api_gateway_rest_api.this.body)
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_rest_api.this]
}
