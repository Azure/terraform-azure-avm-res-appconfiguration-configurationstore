variable "configuration_store_resource_id" {
  type        = string
  description = "The resource ID of the App Configuration store."

  validation {
    error_message = "Value must be a valid App Configuration store resource ID."
    condition     = can(provider::azapi::parse_resource_id("Microsoft.AppConfiguration/configurationStores", var.configuration_store_resource_id))
  }
}

variable "key" {
  type        = string
  description = "The key name for the App Configuration key."
}

variable "location" {
  type        = string
  description = "The Azure region for this module's resources or telemetry deployment."
  nullable    = false
}

variable "value" {
  type        = string
  description = "The value of the App Configuration key."
}

variable "content_type" {
  type        = string
  default     = null
  description = "The content type of the App Configuration key's value, e.g. `application/json` or `text/plain`."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "label" {
  type        = string
  default     = null
  description = "The label of the App Configuration key."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Tags to be applied to the App Configuration key."
}
