output "resource_id" {
  description = "The resource ID of the App Configuration key."
  value       = data.azurerm_app_configuration_key.this.id
}

output "value" {
  description = <<DESCRIPTION
The value of the App Configuration key. The value is returned as a map with the following keys:

- content_type - the content type of the key
- value - the value of the key
- locked - a boolean indicating if the key is locked
- type - the type of the key, either `"kv"` or `"vault"`
- vault_reference - the vault reference if the key is of type `"vault"`
- tags - the tags associated with the key
- etag - the entity tag for the key, this is used to determine if the key has changed since it was last retrieved
DESCRIPTION
  value = {
    content_type    = data.azurerm_app_configuration_key.this.content_type
    value           = data.azurerm_app_configuration_key.this.value
    locked          = data.azurerm_app_configuration_key.this.locked
    type            = data.azurerm_app_configuration_key.this.type
    vault_reference = data.azurerm_app_configuration_key.this.vault_reference
    tags            = data.azurerm_app_configuration_key.this.tags
    etag            = data.azurerm_app_configuration_key.this.etag
  }
}
