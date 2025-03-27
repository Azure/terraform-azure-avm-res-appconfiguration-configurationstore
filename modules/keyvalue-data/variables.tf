variable "configuration_store_resource_id" {
  type        = string
  description = "The resource ID of the App Configuration store."

  validation {
    error_message = "Value must be a valid App Configuration store resource ID."
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.AppConfiguration/configurationStores/[^/]+$", var.configuration_store_resource_id))
  }
}

variable "key" {
  type        = string
  description = "The key name for the App Configuration key."
}

variable "label" {
  type        = string
  description = "The label of the App Configuration key."
  default     = null
}
