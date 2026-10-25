# keyvalue

This submodule allows you to create and manage key-value pairs in an App Configuration Store.
Only native key-value pairs are supported, it is not possible to create key-value pairs that are backed with Azure Key Vault references.

## Direct caller migration

`location` is now required for direct callers, even when `enable_telemetry = false`. Parent-module callers already receive this value through the root module. Telemetry is enabled by default and can be disabled with `enable_telemetry = false`.

```hcl
module "key_value" {
  source = "Azure/avm-res-appconfiguration-configurationstore/azure//modules/keyvalue"

  configuration_store_resource_id = var.configuration_store_resource_id
  key                             = "example"
  location                        = "eastus"
  value                           = "example-value"
}
```
