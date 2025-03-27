resource "azurerm_app_configuration_key" "this" {
  configuration_store_id = var.configuration_store_resource_id
  key                    = var.key
  content_type           = var.content_type
  label                  = var.label
  tags                   = var.tags
  type                   = "kv"
  value                  = var.value
}
