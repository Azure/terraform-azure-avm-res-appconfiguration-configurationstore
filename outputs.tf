output "name" {
  description = "The name of the resource."
  value       = azapi_resource.this.name
}

output "private_endpoint_resource_ids" {
  description = <<DESCRIPTION
A map of the private endpoints created to their resource ids.
DESCRIPTION
  value       = { for k, v in azapi_resource.private_endpoints : k => v.id }
}

output "private_endpoints" {
  description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints. The map value is the entire azapi_resource.private_endpoints resource."
  value       = azapi_resource.private_endpoints
}

output "resource" {
  description = "The full resource object."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource id of the resource."
  value       = azapi_resource.this.id
}
