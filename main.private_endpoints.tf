resource "azapi_resource" "private_endpoints" {
  for_each = module.avm_interfaces.private_endpoints_azapi

  location  = azapi_resource.this.location
  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = each.value.type
  body      = each.value.body
  tags      = each.value.tags
}

resource "azapi_resource" "private_dns_zone_groups" {
  for_each = module.avm_interfaces.private_dns_zone_groups_azapi

  name      = each.value.name
  parent_id = azapi_resource.private_endpoints[each.key].id
  type      = each.value.type
  body      = each.value.body
}

module "avm_interfaces_private_endpoints" {
  source   = "Azure/avm-utl-interfaces/azure"
  version  = "0.3.0"
  for_each = var.private_endpoints

  lock             = each.value.lock
  role_assignments = each.value.role_assignments
}

resource "azapi_resource" "private_endpoint_lock" {
  for_each = { for k, v in module.avm_interfaces_private_endpoints : k => v.lock if v.lock != null }

  name      = each.value.name
  parent_id = azapi_resource.private_endpoints[each.key].id
  type      = each.value.type
  body      = each.value.body
}

resource "azapi_resource" "private_endpoint_role_assignments" {
  for_each = local.private_endpoint_role_assignments

  name      = each.value.child_value.name
  parent_id = azapi_resource.private_endpoints[each.value.parent_key].id
  type      = each.value.child_value.type
  body      = each.value.child_value.body
}
