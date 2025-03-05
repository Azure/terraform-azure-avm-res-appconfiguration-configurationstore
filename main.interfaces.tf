module "avm_interfaces" {
  source = "/Users/matt/code/terraform-azure-avm-utl-interfaces"
  #version            = "0.1.2"
  managed_identities               = var.managed_identities
  lock                             = var.lock
  customer_managed_key             = var.customer_managed_key
  private_endpoints                = var.private_endpoints
  private_endpoints_scope          = "${var.resource_group_resource_id}/providers/Microsoft.AppConfiguration/configurationStores/${var.name}"
  role_assignments                 = var.role_assignments
  role_assignment_definition_scope = var.resource_group_resource_id
  enable_telemetry                 = var.enable_telemetry
}
