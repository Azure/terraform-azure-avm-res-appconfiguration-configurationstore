# terraform-azure-avm-res-appconfiguration-configurationstore

Deploys an Azure App Configuration Store.
Has submodules for:

- Key Value - the capability to store key-value pairs.
- Key Value (data) - the ability to retrieve key-value pairs.

## Private endpoints

`private_endpoints[*].resource_group_name` accepts an existing resource group ID, or a resource group name in the store's subscription. Location defaults to the store's location, and `subresource_name` defaults to `configurationStores`. Specify distinct names when creating multiple endpoints. DNS zone groups are created only when DNS zone IDs are supplied and management is enabled.

Previously ignored endpoint location, resource group, subresource, role-assignment names, lock notes and IP member names now take effect. Review existing overrides before upgrading: changing an endpoint's location or resource group can replace it. Existing working endpoint resource addresses and generated names are retained when these overrides are omitted.

## Direct key-value submodule migration

The root module forwards its `location` and `enable_telemetry` values to the local key-value submodule. Direct consumers of the published `//modules/keyvalue` submodule must now set `location`, including when `enable_telemetry = false`. Telemetry is enabled by default and can be disabled with `enable_telemetry = false`.

```hcl
module "key_value" {
  source = "Azure/avm-res-appconfiguration-configurationstore/azure//modules/keyvalue"

  configuration_store_resource_id = var.configuration_store_resource_id
  key                             = "example"
  location                        = "eastus"
  value                           = "example-value"
}
```
