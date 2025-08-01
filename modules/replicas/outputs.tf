output "name" {
  description = "The name of the resource."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource id of the resource."
  value       = azapi_resource.this.id
}
