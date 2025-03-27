<!-- BEGIN_TF_DOCS -->
# keyvalue-data

This submodule allows you to query an existing App Configuration Store and retrieve key-value pairs.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_app_configuration_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/app_configuration_key) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_configuration_store_resource_id"></a> [configuration\_store\_resource\_id](#input\_configuration\_store\_resource\_id)

Description: The resource ID of the App Configuration store.

Type: `string`

### <a name="input_key"></a> [key](#input\_key)

Description: The key name for the App Configuration key.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_label"></a> [label](#input\_label)

Description: The label of the App Configuration key.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource ID of the App Configuration key.

### <a name="output_value"></a> [value](#output\_value)

Description: The value of the App Configuration key. The value is returned as a map with the following keys:

- content\_type - the content type of the key
- value - the value of the key
- locked - a boolean indicating if the key is locked
- type - the type of the key, either `"kv"` or `"vault"`
- vault\_reference - the vault reference if the key is of type `"vault"`
- tags - the tags associated with the key
- etag - the entity tag for the key, this is used to determine if the key has changed since it was last retrieved

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->