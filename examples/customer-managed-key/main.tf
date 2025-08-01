terraform {
  required_version = "~> 1.9"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azapi_client_config" "current" {}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.3.0"

  enable_telemetry = var.enable_telemetry
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

# This is required for resource modules
resource "azapi_resource" "rg" {
  location                  = module.regions.regions[random_integer.region_index.result].name
  name                      = module.naming.resource_group.name_unique
  type                      = "Microsoft.Resources/resourceGroups@2021-04-01"
  schema_validation_enabled = false
}

# user-assigned managed identity
resource "azapi_resource" "umi" {
  location  = azapi_resource.rg.location
  name      = module.naming.user_assigned_identity.name_unique
  parent_id = azapi_resource.rg.id
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30"
  response_export_values = [
    "properties.principalId",
    "properties.clientId",
  ]
  schema_validation_enabled = false
}

# key vault & key
module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.0"

  location            = azapi_resource.rg.location
  name                = module.naming.key_vault.name_unique
  resource_group_name = azapi_resource.rg.name
  tenant_id           = data.azapi_client_config.current.tenant_id
  keys = {
    cmk = {
      name     = "cmk"
      key_type = "RSA"
      key_size = 4096
      key_opts = ["wrapKey", "unwrapKey", "sign", "verify", "encrypt", "decrypt"]
      enabled  = true
    }
  }
  network_acls = {
    default_action = "Allow"
  }
  role_assignments = {
    admin = {
      principal_id               = data.azapi_client_config.current.object_id
      role_definition_id_or_name = "Key Vault Administrator"
    }
    umi = {
      principal_id               = azapi_resource.umi.output.properties.principalId
      role_definition_id_or_name = "Key Vault Crypto User"
      principal_type             = "ServicePrincipal"
    }
  }
}

# This is the module call
module "test" {
  source = "../../"

  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...
  location                        = azapi_resource.rg.location
  name                            = module.naming.app_configuration.name_unique
  resource_group_resource_id      = azapi_resource.rg.id
  azapi_schema_validation_enabled = false
  customer_managed_key = {
    key_name              = split("/", module.key_vault.keys.cmk.id)[4]
    key_vault_resource_id = module.key_vault.resource_id
    user_assigned_identity = {
      resource_id = azapi_resource.umi.id
    }
  }
  enable_telemetry = var.enable_telemetry
  managed_identities = {
    user_assigned_resource_ids = [
      azapi_resource.umi.id
    ]
  }
}
