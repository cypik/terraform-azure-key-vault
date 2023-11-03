# terraform-azure-key-vault
# Terraform-Azure-Key-Vault

## Table of Contents

- [Introduction](#introduction)
- [Usage](#usage)
- [Module Inputs](#module-inputs)
- [Module Outputs](#module-outputs)
- [Examples](#examples)
- [License](#license)

## Introduction

This Terraform module is designed to facilitate the creation of essential Azure resources for your applications, including a Resource Group, Virtual Network (VNet), Subnet, and an Azure Key Vault. It simplifies the infrastructure provisioning process, making it easier to manage your Azure environment

## Usage

- # key-vault-with-RBAC
You can use this module in your Terraform configuration like this:

```hcl
#Key Vault
module "vault" {
  depends_on = [module.resource_group, module.vnet]
  source     = "./../.."  # Replace with the actual source path

  name        = "annkkdsovvttdcc"
  environment = "test"
  label_order = ["name", "environment"]

  resource_group_name = module.resource_group.resource_group_name

  purge_protection_enabled    = false
  enabled_for_disk_encryption = true

  sku_name = "standard"

  subnet_id          = module.subnet.default_subnet_id
  virtual_network_id = module.vnet.vnet_id[0]
  #private endpoint
  enable_private_endpoint = true
  ##RBAC
  enable_rbac_authorization = true
  principal_id              = ["c0xxxxxxxxxxxxxxx210aedf"]
  role_definition_name      = ["Key Vault Administrator"]
}
```

- # key-vault-with-access-policy
You can use this module in your Terraform configuration like this:


```hcl
# Key Vault
module "vault" {
  depends_on = [module.resource_group, module.vnet]
  source     = "./../.."  # Update this with the correct path to the module

  name        = "annkkdsovvddcc"
  environment = "test"
  label_order = ["name", "environment"]

  resource_group_name = module.resource_group.resource_group_name

  purge_protection_enabled    = false
  enabled_for_disk_encryption = true

  sku_name = "standard"

  subnet_id          = module.subnet.default_subnet_id
  virtual_network_id = module.vnet.vnet_id[0]

  # Private Endpoint
  enable_private_endpoint = true

  # Access Policy
  access_policy = [
    {
      object_id = "c0fdxxxxxxxxxxxxxxxx10aedf"
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
    }
  ]
}
```

## Module Inputs

- 'name': A unique name for the resources.
- 'environment': The environment in which these resources are deployed.
- 'location': The Azure region in which the resources are located.
- 'address_space': The address space for the VNet.
- 'subnet_names': Names for the subnets.
- 'subnet_prefixes': Subnet IP address prefixes.
- 'enable_route_table': Set to `true` to enable a route table.
- 'route_table_name': Name of the route table.
- 'routes': Route definitions for the route table.
- 'purge_protection_enabled': Enable or disable purge protection for the Key Vault.
- 'enabled_for_disk_encryption': Enable or disable disk encryption for the Key Vault.
- 'sku_name': The pricing tier of the Key Vault.
- 'subnet_id': The ID of the subnet in which the Key Vault is deployed.
- 'virtual_network_id': The ID of the virtual network to which the Key Vault is connected.
- 'enable_private_endpoint': Enable or disable the private endpoint for the Key Vault.
- 'enable_rbac_authorization': Enable or disable RBAC for the Key Vault.
- 'principal_id': Azure AD principal IDs for RBAC.
- 'role_definition_name': Names of the role definitions for RBAC.
- 'access_policy': Access policy definitions for the Key Vault.

## Module Outputs
- 'resource_group_name': Name of the created Azure Resource Group.
- 'resource_group_location': Location of the Azure Resource Group.
- 'vnet_name': Name of the created Azure Virtual Network.
- 'default_subnet_id': ID of the default subnet created.
The module provides output variables that you can use in your Terraform configurations. You can access them using `module.<module_name>.<output_variable_name>`.

## Examples
For detailed examples on how to use this module, please refer to the 'examples' directory within this repository.

## License
This Terraform module is provided under the '[License Name]' License. Please see the [LICENSE](https://github.com/opz0/terraform-azure-key-vault/blob/readme/LICENSE) file for more details.

## Author
Your Name
Replace '[License Name]' and '[Your Name]' with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.
