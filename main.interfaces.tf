module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.7.0"

  customer_managed_key             = var.customer_managed_key
  diagnostic_settings              = var.diagnostic_settings
  enable_telemetry                 = var.enable_telemetry
  lock                             = var.lock
  managed_identities               = var.managed_identities
  role_assignment_definition_scope = var.resource_group_resource_id
  role_assignments                 = var.role_assignments
}
