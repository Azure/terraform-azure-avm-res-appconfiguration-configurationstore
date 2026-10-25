module "key_values" {
  source   = "./modules/keyvalue"
  for_each = var.key_values

  configuration_store_resource_id = azapi_resource.this.id
  key                             = each.value.key
  location                        = var.location
  value                           = each.value.value
  content_type                    = each.value.content_type
  enable_telemetry                = var.enable_telemetry
  label                           = each.value.label
  tags                            = each.value.tags

  depends_on = [azapi_resource.role_assignments]
}
