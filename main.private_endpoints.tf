resource "azapi_resource" "private_endpoints" {
  for_each = module.avm_interfaces.private_endpoints_azapi

  location       = azapi_resource.this.location
  name           = each.value.name
  parent_id      = var.resource_group_resource_id
  type           = each.value.type
  body           = each.value.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  tags           = each.value.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "private_dns_zone_groups" {
  for_each = module.avm_interfaces.private_dns_zone_groups_azapi

  name           = each.value.name
  parent_id      = azapi_resource.private_endpoints[each.key].id
  type           = each.value.type
  body           = each.value.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

module "avm_interfaces_private_endpoints" {
  source   = "Azure/avm-utl-interfaces/azure"
  version  = "0.4.0"
  for_each = local.private_endpoints

  lock             = each.value.lock
  role_assignments = each.value.role_assignments
}

resource "azapi_resource" "private_endpoint_lock" {
  for_each = { for k, v in module.avm_interfaces_private_endpoints : k => v.lock if try(v.lock, null) != null }

  name           = each.value.name
  parent_id      = azapi_resource.private_endpoints[each.key].id
  type           = each.value.type
  body           = each.value.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "private_endpoint_role_assignments" {
  for_each = local.private_endpoint_role_assignments

  name           = each.value.child_value.name
  parent_id      = azapi_resource.private_endpoints[each.value.parent_key].id
  type           = each.value.child_value.type
  body           = each.value.child_value.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
