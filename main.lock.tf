resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(module.avm_interfaces.lock_azapi.name, "lock-${azapi_resource.this.name}")
  parent_id = azapi_resource.this.id
  type      = module.avm_interfaces.lock_azapi.type
  body      = module.avm_interfaces.lock_azapi.body

  depends_on = [
    module.replica,
    azapi_resource.role_assignments,
    azapi_resource.diag_settings,
  ]
}

resource "azapi_resource" "lock_pe" {
  for_each = local.private_endpoint_locks

  name      = coalesce(each.value.name, "lock-${each.value.body.properties.level}")
  parent_id = azapi_resource.private_endpoints[each.key].id
  type      = each.value.type
  body = merge(each.value.body, {
    properties = {
      for k, v in each.value.body.properties : k => v
      if k != "notes" || v != null
    }
  })

  depends_on = [
    azapi_resource.private_dns_zone_groups,
    azapi_resource.role_assignments_pe,
  ]
}
