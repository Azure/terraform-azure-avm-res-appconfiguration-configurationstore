data "azurerm_app_configuration_key" "this" {
  configuration_store_id = var.configuration_store_resource_id
  key                    = var.key
  label                  = var.label
}
