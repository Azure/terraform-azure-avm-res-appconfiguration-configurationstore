resource "azapi_resource" "role_assignments" {
  for_each = module.avm_interfaces.role_assignments_azapi

  type      = each.value.type
  body      = each.value.body
  name      = each.value.name
  parent_id = azapi_resource.this.id
}
