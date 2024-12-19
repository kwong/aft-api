output "apigateway_stage_invoke_url" {
  description = "Invocation URL of the API"
  value       = module.aft_api.apigateway_stage_invoke_url
}
