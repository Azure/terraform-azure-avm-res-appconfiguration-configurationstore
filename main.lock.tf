resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name           = coalesce(module.avm_interfaces.lock_azapi.name, "lock-${azapi_resource.this.name}")
  parent_id      = azapi_resource.this.id
  type           = module.avm_interfaces.lock_azapi.type
  body           = module.avm_interfaces.lock_azapi.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  depends_on = [
    module.replica,
    azapi_resource.role_assignments,
    azapi_resource.diag_settings,
  ]
}

resource "azapi_resource" "lock_pe" {
  for_each = module.avm_interfaces.lock_private_endpoint_azapi

  name           = each.value.name
  parent_id      = azapi_resource.private_endpoints[each.key].id
  type           = each.value.type
  body           = each.value.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  depends_on = [
    azapi_resource.private_dns_zone_groups,
    azapi_resource.private_endpoint_role_assignments,
  ]
}
