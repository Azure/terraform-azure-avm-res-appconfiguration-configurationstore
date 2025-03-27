resource "azurerm_app_configuration_key" "this" {
  configuration_store_id = var.configuration_store_resource_id
  key                    = var.key
  value                  = var.value
  content_type           = var.content_type
  tags                   = var.tags
  label                  = var.label
  type                   = "kv"
}
