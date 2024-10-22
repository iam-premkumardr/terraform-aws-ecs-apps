output "vpc_endpoint_ids" {
  value = { for name, ep in aws_vpc_endpoint.vpc_endpoint : name => ep.id }
}