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
  private_endpoints = {
    for k, v in var.private_endpoints : k => {
      name                                    = v.name
      role_assignments                        = v.role_assignments
      lock                                    = v.lock
      tags                                    = v.tags
      subnet_resource_id                      = v.subnet_resource_id
      private_dns_zone_group_name             = v.private_dns_zone_group_name
      private_dns_zone_resource_ids           = v.private_dns_zone_resource_ids
      application_security_group_associations = v.application_security_group_associations
      private_service_connection_name         = v.private_service_connection_name
      network_interface_name                  = v.network_interface_name
      location                                = v.location
      resource_group_name                     = v.resource_group_name
      ip_configurations                       = v.ip_configurations
      subresource_name                        = "configurationStores"
    }
  }
}
