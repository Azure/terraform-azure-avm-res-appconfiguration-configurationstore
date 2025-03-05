output "name" {
  value = azapi_resource.this.name
}

output "private_endpoint_resource_ids" {
  description = <<DESCRIPTION
A map of the private endpoints created to their resource ids.
DESCRIPTION
  value       = { for k, v in azapi_resource.private_endpoints : k => v.id }
}

output "resource_id" {
  value = azapi_resource.this.id
}
