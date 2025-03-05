resource "azapi_resource" "private_endpoints" {
  for_each = module.avm_interfaces.private_endpoints_azapi

  type      = each.value.type
  body      = each.value.body
  location  = azapi_resource.this.location
  name      = each.value.name
  parent_id = azapi_resource.this.id
  tags      = each.value.tags
}

resource "azapi_resource" "private_dns_zone_groups" {
  for_each = module.avm_interfaces.private_dns_zone_groups_azapi

  type      = each.value.type
  body      = each.value.body
  name      = each.value.name
  parent_id = azapi_resource.private_endpoints[each.key].id
}

module "avm_interfaces_private_endpoints" {
  source           = "/Users/matt/code/terraform-azure-avm-utl-interfaces"
  for_each         = var.private_endpoints
  lock             = each.value.lock
  role_assignments = each.value.role_assignments
}

resource "azapi_resource" "private_endpoint_lock" {
  for_each = { for k, v in module.avm_interfaces_private_endpoints : k => v.lock if v.lock != null }

  type      = each.value.type
  body      = each.value.body
  name      = each.value.name
  parent_id = azapi_resource.private_endpoints[each.key].id
}

resource "azapi_resource" "private_endpoint_role_assignments" {
  for_each = local.private_endpoint_role_assignments

  type      = each.value.child_value.type
  body      = each.value.child_value.body
  name      = each.value.child_value.name
  parent_id = azapi_resource.private_endpoints[each.value.parent_key].id
}
