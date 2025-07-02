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
  version = "~> 0.4.2"
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

# vnet
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "=0.8.1"

  address_space       = ["10.0.0.0/16"]
  location            = azapi_resource.rg.location
  resource_group_name = azapi_resource.rg.name
  name                = module.naming.virtual_network.name_unique
  subnets = {
    pe_subnet = {
      name             = "${module.naming.subnet.name_unique}-1"
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

module "private_dns_zones" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.4"

  domain_name         = "privatelink.azconfig.io"
  resource_group_name = azapi_resource.rg.name
  enable_telemetry    = var.enable_telemetry
  virtual_network_links = {
    vnet_link = {
      vnetlinkname     = "${module.vnet.name}-link"
      vnetid           = module.vnet.resource_id
      autoregistration = false
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
  enable_telemetry                = var.enable_telemetry
  private_endpoints = {
    app_configuration = {
      private_dns_zone_resource_ids = [module.private_dns_zones.resource_id]
      subnet_resource_id            = module.vnet.subnets["pe_subnet"].resource_id
    }
  }
  public_network_access_enabled = true
}


