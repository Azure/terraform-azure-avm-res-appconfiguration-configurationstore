variable "key_values" {
  type = map(object({
    key          = string
    value        = string
    content_type = optional(string, null)
    label        = optional(string, null)
    tags         = optional(map(string), null)
  }))
  default     = {}
  description = "Map of objects containing App Configuration key-value attributes to create. The map key is deliberately arbitrary to ensure keys can always be known at plan time."
  nullable    = false
}
