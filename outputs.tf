output "endpoint" {
  description = "The default hostname of the resource."
  value       = azapi_resource.this.output.properties.endpoint
}

output "name" {
  description = "The name of the resource."
  value       = azapi_resource.this.name
}

output "private_endpoint_network_interface_ids" {
  description = "A map of the private endpoints created to their network interface ids."
  value       = { for k, v in azapi_resource.private_endpoints : k => v.output.properties.networkInterfaces[*].id }
}

output "private_endpoint_resource_ids" {
  description = <<DESCRIPTION
A map of the private endpoints created to their resource ids.
DESCRIPTION
  value       = { for k, v in azapi_resource.private_endpoints : k => v.id }
}

output "replica_names" {
  description = "A map of the replicas created to their names."
  value       = { for k, v in module.replica : k => v.name }
}

output "replica_resource_ids" {
  description = "A map of the replicas created to their resource ids."
  value       = { for k, v in module.replica : k => v.resource_id }
}

output "resource_id" {
  description = "The resource id of the resource."
  value       = azapi_resource.this.id
}
