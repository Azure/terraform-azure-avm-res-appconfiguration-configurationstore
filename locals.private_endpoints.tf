locals {
  private_endpoint_locks = {
    for k, v in module.avm_interfaces_private_endpoints : k => v.lock_private_endpoint_azapi[k]
    if local.private_endpoints[k].lock != null
  }
  private_endpoint_parent_ids = {
    for k, v in var.private_endpoints : k => (
      v.resource_group_name == null ? var.resource_group_resource_id : (
        can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", v.resource_group_name)) ?
        v.resource_group_name :
        "${provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.resource_group_resource_id).parent_id}/resourceGroups/${v.resource_group_name}"
      )
    )
  }
  private_endpoint_role_assignments = {
    for item in flatten(
      [
        for parent_value in module.avm_interfaces_private_endpoints : [
          for child_key, child_value in parent_value.role_assignments_private_endpoint_azapi : {
            child_key   = child_key
            child_value = child_value
          }
        ]
      ]
    ) : item.child_key => item.child_value
  }
  private_endpoints = {
    for k, v in var.private_endpoints : k => merge(v, {
      subresource_name = coalesce(v.subresource_name, "configurationStores")
    })
  }
}
