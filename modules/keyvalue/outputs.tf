output "etag" {
  description = "The ETag of the App Configuration key. This is used to determine if the key has changed since it was last retrieved."
  value       = azurerm_app_configuration_key.this.etag
}

output "resource_id" {
  description = "The resource ID of the App Configuration key."
  value       = azurerm_app_configuration_key.this.id
}
