resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(module.avm_interfaces.lock_azapi.name, "lock-${azapi_resource.this.name}")
  parent_id = azapi_resource.this.id
  type      = module.avm_interfaces.lock_azapi.type
  body      = module.avm_interfaces.lock_azapi.body
}
