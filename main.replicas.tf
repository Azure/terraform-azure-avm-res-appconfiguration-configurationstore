module "replica" {
  source   = "./modules/replicas"
  for_each = var.replicas

  location  = each.value.location
  name      = each.value.name
  parent_id = azapi_resource.this.id
}
