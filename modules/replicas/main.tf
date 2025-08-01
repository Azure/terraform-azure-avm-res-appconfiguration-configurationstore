resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.AppConfiguration/configurationStores/replicas@2024-05-01"
}
