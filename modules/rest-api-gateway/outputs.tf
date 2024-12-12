output "apigateway_api_id" {
  description = "API Identifier"
  value       = aws_api_gateway_rest_api.this.id
}

output "apigateway_api_root_resource_id" {
  description = "Root Resource ID"
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "apigateway_api_arn" {
  description = "The ARN of the API"
  value       = aws_api_gateway_rest_api.this.arn
}

output "apigateway_execution_arn" {
  description = "The execution ARN of the API"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "apigateway_stage_invoke_url" {
  description = "Invocation URL of the API"
  value       = aws_api_gateway_stage.prod.invoke_url
}
