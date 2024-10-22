output "api_gateway_rest_api_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.api_gateway_rest_api.id
}

output "api_gateway_invoke_url" {
  description = "Invoke URL for the API Gateway"
  value       = aws_api_gateway_rest_api.api_gateway_rest_api.execution_arn
}

