resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.resource_group_resource_id
  type      = "Microsoft.AppConfiguration/configurationStores@2024-05-01"
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
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values    = ["properties.endpoint"]
  schema_validation_enabled = var.azapi_schema_validation_enabled
  tags                      = var.tags
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "identity" {
    for_each = module.avm_interfaces.managed_identities_azapi != null ? [1] : []

    content {
      type         = module.avm_interfaces.managed_identities_azapi.type
      identity_ids = module.avm_interfaces.managed_identities_azapi.identity_ids
    }
  }
}
