module "avm_interfaces" {
  source                                  = "Azure/avm-utl-interfaces/azure"
  version                                 = "0.2.0"
  managed_identities                      = var.managed_identities
  lock                                    = var.lock
  diagnostic_settings                     = var.diagnostic_settings
  customer_managed_key                    = var.customer_managed_key
  private_endpoints                       = var.private_endpoints
  private_endpoints_scope                 = "${var.resource_group_resource_id}/providers/Microsoft.AppConfiguration/configurationStores/${var.name}"
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group
  role_assignments                        = var.role_assignments
  role_assignment_definition_scope        = var.resource_group_resource_id
  enable_telemetry                        = var.enable_telemetry
}
