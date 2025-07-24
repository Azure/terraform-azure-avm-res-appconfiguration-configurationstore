output "endpoint" {
  description = "The default hostname of the resource."
  value       = azapi_resource.this.output.endpoint
}

output "name" {
  description = "The name of the resource."
  value       = azapi_resource.this.name
}

output "private_endpoint_network_interface_ids" {
  description = "A map of the private endpoints created to their network interface ids."
  value       = { for k, v in azapi_resource.private_endpoints : k => v.output.networkInterfaces[*].id }
}

output "private_endpoint_resource_ids" {
  description = <<DESCRIPTION
A map of the private endpoints created to their resource ids.
DESCRIPTION
  value       = { for k, v in azapi_resource.private_endpoints : k => v.id }
}

output "resource_id" {
  description = "The resource id of the resource."
  value       = azapi_resource.this.id
}
