resource "azapi_resource" "private_endpoints" {
  for_each = local.private_endpoints

  location               = coalesce(each.value.location, azapi_resource.this.location)
  name                   = module.avm_interfaces_private_endpoints[each.key].private_endpoints_azapi[each.key].name
  parent_id              = local.private_endpoint_parent_ids[each.key]
  type                   = module.avm_interfaces_private_endpoints[each.key].private_endpoints_azapi[each.key].type
  body                   = module.avm_interfaces_private_endpoints[each.key].private_endpoints_azapi[each.key].body
  response_export_values = ["properties.networkInterfaces"]
  tags                   = each.value.tags
}

resource "azapi_resource" "private_dns_zone_groups" {
  for_each = {
    for k, v in local.private_endpoints : k => module.avm_interfaces_private_endpoints[k].private_dns_zone_groups_azapi[k]
    if var.private_endpoints_manage_dns_zone_group && length(v.private_dns_zone_resource_ids) > 0
  }

  name      = each.value.name
  parent_id = azapi_resource.private_endpoints[each.key].id
  type      = each.value.type
  body      = each.value.body
}

module "avm_interfaces_private_endpoints" {
  source   = "Azure/avm-utl-interfaces/azure"
  version  = "0.9.0"
  for_each = local.private_endpoints

  location                                = var.location
  enable_telemetry                        = var.enable_telemetry
  private_endpoints                       = { (each.key) = each.value }
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group
  private_endpoints_scope                 = "${var.resource_group_resource_id}/providers/Microsoft.AppConfiguration/configurationStores/${var.name}"
  role_assignment_definition_scope        = local.private_endpoint_parent_ids[each.key]
}
