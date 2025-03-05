resource "azapi_resource" "this" {
  type = "Microsoft.AppConfiguration/configurationStores@2024-05-01"
  body = {
    sku = {
      name = var.sku
    }
    properties = {
      createMode            = "Default"
      dataPlaneProxy        = local.data_plane_proxy
      disableLocalAuth      = !var.local_auth_enabled
      enablePurgeProtection = var.purge_protection_enabled
      encryption = {
        keyVaultProperties = local.key_vault_properties
      }
      publicNetworkAccess       = var.public_network_access_enabled ? "Enabled" : "Disabled"
      softDeleteRetentionInDays = var.soft_delete_retention_days
    }
  }
  location                  = var.location
  name                      = var.name
  parent_id                 = var.resource_group_resource_id
  schema_validation_enabled = var.azapi_schema_validation_enabled
  tags                      = var.tags

  dynamic "identity" {
    for_each = module.avm_interfaces.managed_identities_azapi != null ? [1] : []

    content {
      type         = module.avm_interfaces.managed_identities_azapi.type
      identity_ids = module.avm_interfaces.managed_identities_azapi.identity_ids
    }
  }
}
