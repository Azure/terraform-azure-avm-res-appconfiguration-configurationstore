resource "azapi_resource" "diag_settings" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = each.value.type
  body      = each.value.body
}
