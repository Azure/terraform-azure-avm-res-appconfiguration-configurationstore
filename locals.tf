locals {
  data_plane_proxy = var.data_plane_proxy != null ? {
    authenticationMode    = var.data_plane_proxy.authentication_mode
    privateLinkDelegation = var.data_plane_proxy.private_link_delegation
    } : {
    authenticationMode    = "Local"
    privateLinkDelegation = "Disabled"
  }
  key_vault_properties = var.customer_managed_key == null ? null : {
    identityClientId = module.avm_interfaces.customer_managed_key_azapi.identity_client_id
    keyIdentifier    = module.avm_interfaces.customer_managed_key_azapi.versionless_key_uri
  }
}
