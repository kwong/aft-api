locals {
  max_session_duration  = 3600
  force_detach_policies = true
  apigw_security_policy = "TLS_1_2"
  apigw_endpoint_types  = ["REGIONAL"]
  xray_tracing_enabled  = false

}
