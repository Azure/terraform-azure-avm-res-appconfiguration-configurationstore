locals {
  private_endpoint_role_assignments = {
    for item in flatten(
      [
        for parent_key, parent_value in module.avm_interfaces_private_endpoints : [
          for child_key, child_value in parent_value.private_endpoints_azapi : {
            parent_key  = parent_key
            child_key   = child_key
            child_value = child_value
          }
        ]
      ]
    ) : "${item.parent_key}/${item.child_key}" => item.child_value
  }
}
