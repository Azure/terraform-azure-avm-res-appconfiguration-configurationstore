mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/store-rg/providers/Microsoft.Network/privateEndpoints/mock-pe"
      output = {
        properties = {
          endpoint = "https://mock-store.azconfig.io"
          networkInterfaces = [
            {
              id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/store-rg/providers/Microsoft.Network/networkInterfaces/mock-nic"
            }
          ]
        }
      }
    }
  }

  mock_data "azapi_resource_list" {
    defaults = {
      output = {
        results = [
          {
            id        = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
            role_name = "Reader"
          },
          {
            id        = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
            role_name = "Contributor"
          }
        ]
      }
    }
  }
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "azurerm" {}

mock_provider "random" {
  mock_resource "random_uuid" {
    defaults = {
      result = "11111111-1111-1111-1111-111111111111"
    }
  }
}

override_resource {
  target = azapi_resource.this
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/store-rg/providers/Microsoft.AppConfiguration/configurationStores/test-store"
    output = {
      properties = {
        endpoint = "https://mock-store.azconfig.io"
      }
    }
  }
}

variables {
  enable_telemetry           = false
  location                   = "eastus"
  name                       = "test-store"
  resource_group_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/store-rg"
}

run "empty_endpoints_create_no_satellites" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  assert {
    condition = (
      length(azapi_resource.private_endpoints) == 0 &&
      length(azapi_resource.private_dns_zone_groups) == 0 &&
      length(azapi_resource.lock_pe) == 0 &&
      length(azapi_resource.role_assignments_pe) == 0
    )
    error_message = "Omitted endpoints must not create endpoints, DNS groups, locks or endpoint roles."
  }
}

run "default_endpoint_preserves_names_scope_and_body" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      arbitrary_key = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
      }
    }
  }

  assert {
    condition = (
      azapi_resource.private_endpoints["arbitrary_key"].name ==
      "pep-configurationStores-${uuidv5("url", "${var.resource_group_resource_id}/providers/Microsoft.AppConfiguration/configurationStores/${var.name}")}"
    )
    error_message = "The existing default endpoint name must remain stable."
  }

  assert {
    condition = (
      azapi_resource.private_endpoints["arbitrary_key"].location == var.location &&
      azapi_resource.private_endpoints["arbitrary_key"].parent_id == var.resource_group_resource_id
    )
    error_message = "Omitted location and group overrides must retain the store's location and resource group."
  }

  assert {
    condition = (
      azapi_resource.private_endpoints["arbitrary_key"].body.properties.privateLinkServiceConnections[0].properties.groupIds == ["configurationStores"] &&
      azapi_resource.private_endpoints["arbitrary_key"].body.properties.privateLinkServiceConnections[0].properties.privateLinkServiceId == azapi_resource.this.id
    )
    error_message = "The default endpoint must still connect to the configurationStores service on the store."
  }

  assert {
    condition = (
      azapi_resource.private_endpoints["arbitrary_key"].body.properties.customNetworkInterfaceName ==
      "nic-${azapi_resource.private_endpoints["arbitrary_key"].name}" &&
      azapi_resource.private_endpoints["arbitrary_key"].body.properties.privateLinkServiceConnections[0].name ==
      "pcon-${azapi_resource.private_endpoints["arbitrary_key"].name}" &&
      length(azapi_resource.private_endpoints["arbitrary_key"].body.properties.ipConfigurations) == 0 &&
      length(azapi_resource.private_endpoints["arbitrary_key"].body.properties.applicationSecurityGroups) == 0
    )
    error_message = "Existing NIC/connection names and empty optional body collections must be preserved."
  }

  assert {
    condition     = length(azapi_resource.private_dns_zone_groups) == 0
    error_message = "An endpoint without DNS zones must not create an invalid empty DNS zone group."
  }

  assert {
    condition = (
      keys(output.private_endpoint_resource_ids) == ["arbitrary_key"] &&
      output.private_endpoint_resource_ids["arbitrary_key"] == azapi_resource.private_endpoints["arbitrary_key"].id &&
      output.private_endpoint_network_interface_ids["arbitrary_key"] ==
      ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/store-rg/providers/Microsoft.Network/networkInterfaces/mock-nic"]
    )
    error_message = "Endpoint outputs must retain the arbitrary caller key and network interface IDs."
  }
}

run "null_overrides_use_legacy_defaults" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      nulls = {
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        location            = null
        resource_group_name = null
        subresource_name    = null
        ip_configurations = {
          not_the_name = {
            name               = "static"
            private_ip_address = "10.0.0.4"
            member_name        = null
          }
        }
      }
    }
  }

  assert {
    condition = (
      azapi_resource.private_endpoints["nulls"].location == var.location &&
      azapi_resource.private_endpoints["nulls"].parent_id == var.resource_group_resource_id &&
      azapi_resource.private_endpoints["nulls"].body.properties.ipConfigurations[0].properties.groupId == "configurationStores" &&
      azapi_resource.private_endpoints["nulls"].body.properties.ipConfigurations[0].properties.memberName == "default"
    )
    error_message = "Explicit nulls must preserve the existing defaults, including the legacy IP member name."
  }
}

run "independent_location_and_group_overrides" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      default_group = {
        name               = "pe-default"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
      }
      group_id = {
        name                = "pe-other-subscription"
        subnet_resource_id  = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        location            = "westus2"
        resource_group_name = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/endpoint-rg"
      }
      group_name = {
        name                = "pe-legacy-name"
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        location            = "northeurope"
        resource_group_name = "legacy-endpoint-rg"
      }
    }
  }

  assert {
    condition = (
      azapi_resource.private_endpoints["default_group"].parent_id == var.resource_group_resource_id &&
      azapi_resource.private_endpoints["default_group"].location == var.location &&
      azapi_resource.private_endpoints["group_id"].parent_id == "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/endpoint-rg" &&
      azapi_resource.private_endpoints["group_id"].location == "westus2" &&
      azapi_resource.private_endpoints["group_name"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/legacy-endpoint-rg" &&
      azapi_resource.private_endpoints["group_name"].location == "northeurope"
    )
    error_message = "Each endpoint must honor its own location and resource-group override without affecting other endpoints."
  }

  assert {
    condition = alltrue([
      for endpoint in azapi_resource.private_endpoints :
      endpoint.body.properties.privateLinkServiceConnections[0].properties.privateLinkServiceId == azapi_resource.this.id
    ])
    error_message = "Moving an endpoint must not change the App Configuration store to which it connects."
  }
}

run "subresource_and_ip_members_are_forwarded" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      custom = {
        name               = "pe-custom"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        subresource_name   = "customService"
        ip_configurations = {
          first_key = {
            name               = "first-ip"
            private_ip_address = "10.0.0.4"
            member_name        = "customMember"
          }
          second_key = {
            name               = "second-ip"
            private_ip_address = "10.0.0.5"
          }
        }
      }
    }
  }

  assert {
    condition = (
      azapi_resource.private_endpoints["custom"].body.properties.privateLinkServiceConnections[0].properties.groupIds == ["customService"] &&
      azapi_resource.private_endpoints["custom"].body.properties.ipConfigurations[0].name == "first-ip" &&
      azapi_resource.private_endpoints["custom"].body.properties.ipConfigurations[0].properties.privateIPAddress == "10.0.0.4" &&
      azapi_resource.private_endpoints["custom"].body.properties.ipConfigurations[0].properties.groupId == "customService" &&
      azapi_resource.private_endpoints["custom"].body.properties.ipConfigurations[0].properties.memberName == "customMember" &&
      azapi_resource.private_endpoints["custom"].body.properties.ipConfigurations[1].properties.memberName == "default"
    )
    error_message = "The caller's service and member names must reach the endpoint body, while omitted members retain the default."
  }
}

run "existing_named_settings_and_dns_are_preserved" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      named = {
        name                            = "pe-explicit"
        subnet_resource_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        private_service_connection_name = "connection-explicit"
        network_interface_name          = "nic-explicit"
        private_dns_zone_group_name     = "zones-explicit"
        private_dns_zone_resource_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azconfig.io"
        ]
        application_security_group_associations = {
          arbitrary_asg_key = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/applicationSecurityGroups/asg"
        }
        tags = {
          purpose = "private"
        }
      }
    }
  }

  assert {
    condition = (
      azapi_resource.private_endpoints["named"].name == "pe-explicit" &&
      azapi_resource.private_endpoints["named"].body.properties.customNetworkInterfaceName == "nic-explicit" &&
      azapi_resource.private_endpoints["named"].body.properties.privateLinkServiceConnections[0].name == "connection-explicit" &&
      azapi_resource.private_endpoints["named"].tags == tomap({ purpose = "private" }) &&
      azapi_resource.private_endpoints["named"].body.properties.applicationSecurityGroups[0].id ==
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/applicationSecurityGroups/asg"
    )
    error_message = "Existing explicit names, tags and application security group associations must remain unchanged."
  }

  assert {
    condition = (
      keys(azapi_resource.private_dns_zone_groups) == ["named"] &&
      azapi_resource.private_dns_zone_groups["named"].name == "zones-explicit" &&
      azapi_resource.private_dns_zone_groups["named"].parent_id == azapi_resource.private_endpoints["named"].id &&
      azapi_resource.private_dns_zone_groups["named"].body.properties.privateDnsZoneConfigs[0].properties.privateDnsZoneId ==
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azconfig.io"
    )
    error_message = "DNS zone group addresses, names, scope and zone IDs must remain stable."
  }
}

run "external_dns_management_creates_no_groups" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints_manage_dns_zone_group = false
    private_endpoints = {
      external_dns = {
        name               = "pe-external-dns"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        private_dns_zone_resource_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azconfig.io"
        ]
      }
    }
  }

  assert {
    condition     = length(azapi_resource.private_endpoints) == 1 && length(azapi_resource.private_dns_zone_groups) == 0
    error_message = "Disabling DNS management must retain the endpoint without creating a zone group."
  }
}

run "endpoint_locks_honor_names_notes_and_defaults" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      explicit_lock = {
        name               = "pe-explicit-lock"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        lock = {
          kind  = "ReadOnly"
          name  = "lock-explicit"
          notes = "Keep endpoint settings unchanged."
        }
      }
      generated_lock = {
        name               = "pe-generated-lock"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        lock = {
          kind = "CanNotDelete"
        }
      }
      unlocked = {
        name               = "pe-unlocked"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
      }
    }
  }

  assert {
    condition = (
      keys(azapi_resource.lock_pe) == ["explicit_lock", "generated_lock"] &&
      azapi_resource.lock_pe["explicit_lock"].name == "lock-explicit" &&
      azapi_resource.lock_pe["explicit_lock"].parent_id == azapi_resource.private_endpoints["explicit_lock"].id &&
      azapi_resource.lock_pe["explicit_lock"].body.properties.level == "ReadOnly" &&
      azapi_resource.lock_pe["explicit_lock"].body.properties.notes == "Keep endpoint settings unchanged." &&
      azapi_resource.lock_pe["generated_lock"].name == "lock-CanNotDelete" &&
      keys(azapi_resource.lock_pe["generated_lock"].body.properties) == ["level"]
    )
    error_message = "Create exactly one lock per requested endpoint, honoring explicit values and preserving the body when notes are omitted."
  }
}

run "endpoint_roles_keep_keys_and_use_the_correct_parent" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  override_resource {
    target = azapi_resource.private_endpoints["first"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/store-rg/providers/Microsoft.Network/privateEndpoints/pe-first"
      output = {
        properties = {
          networkInterfaces = []
        }
      }
    }
  }

  override_resource {
    target = azapi_resource.private_endpoints["second"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/store-rg/providers/Microsoft.Network/privateEndpoints/pe-second"
      output = {
        properties = {
          networkInterfaces = []
        }
      }
    }
  }

  variables {
    private_endpoints = {
      first = {
        name               = "pe-first"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        role_assignments = {
          reader = {
            name                                   = "22222222-2222-2222-2222-222222222222"
            role_definition_id_or_name             = "Reader"
            principal_id                           = "00000000-0000-0000-0000-000000000010"
            principal_type                         = "ServicePrincipal"
            description                            = "Endpoint reader"
            condition                              = "custom condition"
            condition_version                      = "2.0"
            delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/delegated"
            skip_service_principal_aad_check       = true
          }
        }
      }
      second = {
        name               = "pe-second"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        role_assignments = {
          reader = {
            role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
            principal_id               = "00000000-0000-0000-0000-000000000020"
          }
        }
      }
    }
  }

  assert {
    condition = (
      keys(azapi_resource.role_assignments_pe) == ["first-reader", "second-reader"] &&
      azapi_resource.role_assignments_pe["first-reader"].parent_id == azapi_resource.private_endpoints["first"].id &&
      azapi_resource.role_assignments_pe["second-reader"].parent_id == azapi_resource.private_endpoints["second"].id &&
      azapi_resource.role_assignments_pe["first-reader"].name == "22222222-2222-2222-2222-222222222222" &&
      azapi_resource.role_assignments_pe["second-reader"].name == "11111111-1111-1111-1111-111111111111"
    )
    error_message = "Endpoint roles must retain composite keys, use their own endpoint parents, and honor explicit or generated names."
  }

  assert {
    condition = (
      azapi_resource.role_assignments_pe["first-reader"].body.properties.principalId == "00000000-0000-0000-0000-000000000010" &&
      azapi_resource.role_assignments_pe["first-reader"].body.properties.principalType == "ServicePrincipal" &&
      azapi_resource.role_assignments_pe["first-reader"].body.properties.roleDefinitionId == "${provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.resource_group_resource_id).parent_id}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7" &&
      azapi_resource.role_assignments_pe["first-reader"].body.properties.description == "Endpoint reader" &&
      azapi_resource.role_assignments_pe["first-reader"].body.properties.condition == "custom condition" &&
      azapi_resource.role_assignments_pe["first-reader"].body.properties.conditionVersion == "2.0" &&
      azapi_resource.role_assignments_pe["first-reader"].body.properties.delegatedManagedIdentityResourceId == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/delegated"
    )
    error_message = "All supported role properties and name-based definition lookup must reach the endpoint role body: ${jsonencode(azapi_resource.role_assignments_pe["first-reader"].body.properties)}"
  }
}

run "store_roles_retain_the_existing_deterministic_name" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    role_assignments = {
      store_reader = {
        role_definition_id_or_name = "Reader"
        principal_id               = "00000000-0000-0000-0000-000000000010"
      }
    }
    private_endpoints = {
      endpoint = {
        name               = "pe-separate"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
      }
    }
  }

  assert {
    condition = (
      azapi_resource.role_assignments["store_reader"].name ==
      uuidv5("url", "00000000-0000-0000-0000-000000000010/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7") &&
      azapi_resource.role_assignments["store_reader"].parent_id == azapi_resource.this.id &&
      length(azapi_resource.role_assignments_pe) == 0
    )
    error_message = "The endpoint utility update must not rename or move an already-working store-level role assignment."
  }
}

run "telemetry_enabled_uses_the_mocked_client_configuration" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    enable_telemetry = true
  }

  assert {
    condition = (
      length(azapi_resource.telemetry) == 1 &&
      azapi_resource.telemetry[0].type == "Microsoft.Resources/deployments@2025-04-01" &&
      azapi_resource.telemetry[0].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000"
    )
    error_message = "Enabled telemetry must use the mocked subscription client configuration."
  }
}

run "existing_key_value_child_uses_the_mocked_v4_provider" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    key_values = {
      existing = {
        key   = "existing-key"
        value = "existing-value"
      }
    }
  }

  assert {
    condition = (
      keys(module.key_values) == ["existing"] &&
      module.key_values["existing"].resource_id != null &&
      module.key_values["existing"].etag != null
    )
    error_message = "The existing key-value child must remain creatable through the declared and inherited mocked AzureRM v4 provider."
  }
}

run "invalid_subnet_is_rejected" {
  command   = plan
  state_key = "invalid_subnet"
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet"
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_dns_zone_is_rejected" {
  command   = plan
  state_key = "invalid_dns_zone"
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        private_dns_zone_resource_ids = ["not-a-zone-id"]
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_security_group_is_rejected" {
  command   = plan
  state_key = "invalid_security_group"
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        application_security_group_associations = {
          invalid = "not-an-asg-id"
        }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_delegated_identity_is_rejected" {
  command   = plan
  state_key = "invalid_delegated_identity"
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        role_assignments = {
          invalid = {
            role_definition_id_or_name             = "Reader"
            principal_id                           = "00000000-0000-0000-0000-000000000010"
            delegated_managed_identity_resource_id = "not-an-identity-id"
          }
        }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_resource_group_override_is_rejected" {
  command   = plan
  state_key = "invalid_resource_group"
  providers = {
    azapi   = azapi
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/private"
        resource_group_name = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet"
      }
    }
  }

  expect_failures = [var.private_endpoints]
}
