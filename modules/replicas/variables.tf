variable "location" {
  type        = string
  description = "The location of the replica."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the replica."
  nullable    = false

  validation {
    error_message = "Configuration store replica names must contain only alpha-numeric ASCII characters & must be no greater than 50 characters."
    condition     = can(regex("^[a-zA-Z0-9]{1,50}$", var.name))
  }
  validation {
    error_message = "The sum of a replica name's length and the configuration store name's length must be no greater than 60 characters."
    condition     = length(var.name) + length(basename(var.parent_id)) <= 60
  }
}

variable "parent_id" {
  type        = string
  description = "The resource ID of the parent configuration store."
  nullable    = false

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.AppConfiguration/configurationStores/[^/]+$", var.parent_id))
    error_message = "The parent_id must be a valid resource ID of an App Configuration store."
  }
}
