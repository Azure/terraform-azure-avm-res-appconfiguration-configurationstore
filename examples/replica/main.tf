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

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.7.0"

  enable_telemetry = var.enable_telemetry
  has_pair         = true
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

locals {
  region = module.regions.regions[random_integer.region_index.result]
}

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

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...
  location                        = azapi_resource.rg.location
  name                            = module.naming.app_configuration.name_unique
  resource_group_resource_id      = azapi_resource.rg.id
  azapi_schema_validation_enabled = false
  enable_telemetry                = var.enable_telemetry
  replicas = {
    paired_region = {
      name     = "PairedRegion"
      location = local.region.paired_region_name
    }
  }
}
