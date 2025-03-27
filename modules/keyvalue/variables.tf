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

variable "value" {
  type        = string
  description = "The value of the App Configuration key."
}

variable "content_type" {
  type        = string
  description = "The content type of the App Configuration key's value, e.g. `application/json` or `text/plain`."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to the App Configuration key."
  default     = null
}

variable "label" {
  type        = string
  description = "The label of the App Configuration key."
  default     = null
}
