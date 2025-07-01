resource "azapi_resource" "role_assignments" {
  for_each = module.avm_interfaces.role_assignments_azapi

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = each.value.type
  body      = each.value.body
}
