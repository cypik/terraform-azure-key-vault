# Terraform-azure-key-vault

# Terraform Azure Cloud Key-Vault Module

## Table of Contents
- [Introduction](#introduction)
- [Usage](#usage)
- [Examples](#examples)
- [Author](#author)
- [License](#license)
- [Inputs](#inputs)
- [Outputs](#outputs)

## Introduction

This Terraform module is designed to facilitate the creation of essential Azure resources for your applications, including a Resource Group, Virtual Network (VNet), Subnet, and an Azure Key Vault. It simplifies the infrastructure provisioning process, making it easier to manage your Azure environment

## Usage
To use this module, you should have Terraform installed and configured for AZURE. This module provides the necessary Terraform configuration
for creating AZURE resources, and you can customize the inputs as needed. Below is an example of how to use this module:

# Examples

# Example: key-vault-with-RBAC

```hcl
module "vault" {
  source                      = "cypik/key-vault/azure"
  version                     = "1.0.1"
  name                        = "app"
  environment                 = "test"
  sku_name                    = "standard"
  principal_id                = ["xxxxxxxxxxxxxxxxxxxxxxxxxx"]
  role_definition_name        = ["Key Vault Administrator"]
  resource_group_name         = module.resource_group.resource_group_name
  subnet_id                   = module.subnet.default_subnet_id
  virtual_network_id          = module.vnet.id
  enable_private_endpoint     = true
  enable_rbac_authorization   = true
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true

  depends_on                  = [module.resource_group, module.vnet]
}
```

# Example: key-vault-with-access-policy


```hcl
module "vault" {
  source                      = "cypik/key-vault/azure"
  version                     = "1.0.1"
  name                        = "app"
  environment                 = "test"
  resource_group_name         = module.resource_group.resource_group_name
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true
  sku_name                    = "standard"
  subnet_id                   = module.subnet.default_subnet_id
  virtual_network_id          = module.vnet.id
  enable_private_endpoint     = true

  depends_on                  = [module.resource_group, module.vnet]
  access_policy = [
    {
      object_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      key_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Import",
        "Delete",
        "Recover",
        "Backup",
        "Restore",
        "UnwrapKey",
        "WrapKey",
        "GetRotationPolicy"
      ]
      certificate_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Import",
        "Delete",
        "Recover",
        "Backup",
        "Restore",
        "ManageContacts",
        "ManageIssuers",
        "GetIssuers",
        "ListIssuers",
        "SetIssuers",
        "DeleteIssuers"
      ]
      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Recover",
        "Backup",
        "Restore"
      ]
      storage_permissions = []
    },
  ]
}
```
This example demonstrates how to create various AZURE resources using the provided modules. Adjust the input values to suit your specific requirements.

## Examples
For detailed examples on how to use this module, please refer to the [examples](https://github.com/cypik/terraform-azure-key-vault/blob/master/_example) directory within this repository.

## License
This Terraform module is provided under the **MIT** License. Please see the [LICENSE](https://github.com/cypik/terraform-azure-key-vault/blob/master/LICENSE) file for more details.

## Author
Your Name
Replace **MIT** and **Cypik** with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.87.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.87.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_labels"></a> [labels](#module\_labels) | cypik/labels/azure | 1.0.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_key.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_secret.key_vault_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_private_dns_a_record.arecord](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.dnszone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.addon_vent_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.vent-link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.pep](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.aks_user_assigned](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.rbac_user_assigned](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current_client_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_private_endpoint_connection.private-ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_endpoint_connection) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policy"></a> [access\_policy](#input\_access\_policy) | Map of access policies for an object\_id (user, service principal, security group) to backend. | <pre>list(object({<br>    object_id               = string,<br>    certificate_permissions = list(string),<br>    key_permissions         = list(string),<br>    secret_permissions      = list(string),<br>    storage_permissions     = list(string),<br>  }))</pre> | `[]` | no |
| <a name="input_addon_resource_group_name"></a> [addon\_resource\_group\_name](#input\_addon\_resource\_group\_name) | The name of the addon vnet resource group | `string` | `""` | no |
| <a name="input_addon_vent_link"></a> [addon\_vent\_link](#input\_addon\_vent\_link) | The name of the addon vnet | `bool` | `false` | no |
| <a name="input_addon_virtual_network_id"></a> [addon\_virtual\_network\_id](#input\_addon\_virtual\_network\_id) | The name of the addon vnet link vnet id | `string` | `""` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Manages a Private Endpoint to Azure database for MySQL | `bool` | `true` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | (Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to false | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_existing_private_dns_zone"></a> [existing\_private\_dns\_zone](#input\_existing\_private\_dns\_zone) | Name of the existing private DNS zone | `string` | `null` | no |
| <a name="input_existing_private_dns_zone_resource_group_name"></a> [existing\_private\_dns\_zone\_resource\_group\_name](#input\_existing\_private\_dns\_zone\_resource\_group\_name) | The name of the existing resource group | `string` | `""` | no |
| <a name="input_key_enabled"></a> [key\_enabled](#input\_key\_enabled) | Flag to control creation of key vault key resource. | `bool` | `false` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] . | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"North Europe"` | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'cypik'. | `string` | `"Cypik"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_network_acls_bypass"></a> [network\_acls\_bypass](#input\_network\_acls\_bypass) | Specifies which traffic can bypass the network rules. Possible values are AzureServices and None. | `string` | `null` | no |
| <a name="input_network_acls_default_action"></a> [network\_acls\_default\_action](#input\_network\_acls\_default\_action) | The Default Action to use when no rules match from ip\_rules / virtual\_network\_subnet\_ids. Possible values are Allow and Deny. | `string` | `"Deny"` | no |
| <a name="input_network_acls_ip_rules"></a> [network\_acls\_ip\_rules](#input\_network\_acls\_ip\_rules) | (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault. | `list(string)` | `null` | no |
| <a name="input_network_acls_subnet_ids"></a> [network\_acls\_subnet\_ids](#input\_network\_acls\_subnet\_ids) | (Optional) One or more Subnet ID's which should be able to access this Key Vault. | `list(string)` | `null` | no |
| <a name="input_principal_id"></a> [principal\_id](#input\_principal\_id) | The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created. | `list(string)` | `[]` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Whether public network access is allowed for this Key Vault. Defaults to true | `bool` | `true` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | Is Purge Protection enabled for this Key Vault? Defaults to false | `bool` | `null` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Terraform current module repo | `string` | `"https://github.com/cypik/terraform-azure-key-vault"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | A container that holds related resources for an Azure solution | `string` | `""` | no |
| <a name="input_role_definition_name"></a> [role\_definition\_name](#input\_role\_definition\_name) | The name of a built-in Role. Changing this forces a new resource to be created. Conflicts with role\_definition\_id | `list(string)` | `[]` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets for be created | `any` | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The Name of the SKU used for this Key Vault. Possible values are standard and premium | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | The number of days that items should be retained for once soft-deleted. The valid value can be between 7 and 90 days | `number` | `90` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The resource ID of the subnet | `string` | `""` | no |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | The name of the virtual network | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_vault_uri"></a> [vault\_uri](#output\_vault\_uri) | n/a |
<!-- END_TF_DOCS -->