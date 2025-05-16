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

## Example: create-key

```hcl
module "key_vault" {
  source              = "cypik/key-vault/azure"
  version             = "1.0.3"
  location            = module.resource_group.resource_group_location
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  keys = {
    cmk_for_storage_account = {
      key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
      key_type = "RSA"
      name     = "cmk-for-storage-account"
      key_size = 2048
    }
  }
  network_acls = {
    bypass   = "AzureServices"
    ip_rules = ["${data.http.ip.response_body}/32"]
  }
  public_network_access_enabled = true
  role_assignments = {
    deployment_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }
  wait_for_rbac_before_key_operations = {
    create = "60s"
  }
}
```

## Example: create-secrets

```hcl
module "key_vault" {
  source              = "cypik/key-vault/azure"
  version             = "1.0.3"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  network_acls = {
    bypass   = "AzureServices"
    ip_rules = ["${data.http.ip.response_body}/32"]
  }
  public_network_access_enabled = true
  role_assignments = {
    deployment_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }

  }
  secrets = [
    {
      name  = "db-password"
      value = "super-secret-password"
    }
  ]
  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
}
```

## Example: access-policies

```hcl
module "keyvault" {
  source              = "cypik/key-vault/azure"
  version             = "1.0.3"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tenant_id           = data.azurerm_client_config.this.tenant_id
  legacy_access_policies = {
    test = {
      object_id               = data.azurerm_client_config.this.object_id
      certificate_permissions = ["Get", "List"]
    }
  }
  legacy_access_policies_enabled = true
}
```

## Example: default

```hcl
module "keyvault" {
  source              = "cypik/key-vault/azure"
  version             = "1.0.3"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tenant_id           = data.azurerm_client_config.this.tenant_id
}
```

## Example: diagnostic-settings

```hcl
module "keyvault" {
  source              = "cypik/key-vault/azure"
  version             = "1.0.3"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tenant_id           = data.azurerm_client_config.this.tenant_id
  diagnostic_settings = {
    to_la = {
      name                  = "to-la"
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
    }
  }
}
```

## Example: private-endpoint

```hcl
module "keyvault" {
  source              = "cypik/key-vault/azure"
  version             = "1.0.3"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tenant_id           = data.azurerm_client_config.this.tenant_id
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this.id]
      subnet_resource_id            = module.subnet.default_subnet_id
    }
  }
  public_network_access_enabled = false
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.28.0 |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) | ~> 0.3.5 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.7 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.28.0 |
| <a name="provider_modtm"></a> [modtm](#provider\_modtm) | ~> 0.3.5 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.7 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.13.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_keys"></a> [keys](#module\_keys) | ./modules/key | n/a |
| <a name="module_labels"></a> [labels](#module\_labels) | cypik/labels/azure | 1.0.2 |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | ./modules/secret | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_certificate_contacts.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate_contacts) | resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.this_unmanaged_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) | resource |
| [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [time_sleep.wait_for_rbac_before_contact_operations](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_rbac_before_key_operations](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_rbac_before_secret_operations](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.<br><br>- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.<br>- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.<br>- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.<br>- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.<br>- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.<br>- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.<br>- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.<br>- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.<br>- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.<br>- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs. | <pre>map(object({<br>    name                                     = optional(string, null)<br>    log_categories                           = optional(set(string), [])<br>    log_groups                               = optional(set(string), ["allLogs"])<br>    metric_categories                        = optional(set(string), ["AllMetrics"])<br>    log_analytics_destination_type           = optional(string, "Dedicated")<br>    workspace_resource_id                    = optional(string, null)<br>    storage_account_resource_id              = optional(string, null)<br>    event_hub_authorization_rule_resource_id = optional(string, null)<br>    event_hub_name                           = optional(string, null)<br>    marketplace_partner_resource_id          = optional(string, null)<br>  }))</pre> | `{}` | no |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | This variable controls whether or not telemetry is enabled for the module.<br>For more information see https://aka.ms/avm/telemetryinfo.<br>If it is set to false, then no telemetry will be collected. | `bool` | `true` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the vault. | `bool` | `false` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | Specifies whether Azure Resource Manager is permitted to retrieve secrets from the vault. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map(string)` | `{}` | no |
| <a name="input_keys"></a> [keys](#input\_keys) | A map of keys to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.<br><br>- `name` - The name of the key.<br>- `key_type` - The type of the key. Possible values are `EC` and `RSA`.<br>- `key_opts` - A list of key options. Possible values are `decrypt`, `encrypt`, `sign`, `unwrapKey`, `verify`, and `wrapKey`.<br>- `key_size` - The size of the key. Required for `RSA` keys.<br>- `curve` - The curve of the key. Required for `EC` keys.  Possible values are `P-256`, `P-256K`, `P-384`, and `P-521`. The API will default to `P-256` if nothing is specified.<br>- `not_before_date` - The not before date of the key.<br>- `expiration_date` - The expiration date of the key.<br>- `tags` - A mapping of tags to assign to the key.<br>- `rotation_policy` - The rotation policy of the key.<br>  - `automatic` - The automatic rotation policy of the key.<br>    - `time_after_creation` - The time after creation of the key before it is automatically rotated.<br>    - `time_before_expiry` - The time before expiry of the key before it is automatically rotated.<br>  - `expire_after` - The time after which the key expires.<br>  - `notify_before_expiry` - The time before expiry of the key when notification emails will be sent.<br><br>Supply role assignments in the same way as for `var.role_assignments`. | <pre>map(object({<br>    name     = string<br>    key_type = string<br>    key_opts = optional(list(string), ["sign", "verify"])<br><br>    key_size        = optional(number, null)<br>    curve           = optional(string, null)<br>    not_before_date = optional(string, null)<br>    expiration_date = optional(string, null)<br>    tags            = optional(map(any), null)<br><br>    role_assignments = optional(map(object({<br>      role_definition_id_or_name             = string<br>      principal_id                           = string<br>      description                            = optional(string, null)<br>      skip_service_principal_aad_check       = optional(bool, false)<br>      condition                              = optional(string, null)<br>      condition_version                      = optional(string, null)<br>      delegated_managed_identity_resource_id = optional(string, null)<br>      principal_type                         = optional(string, null)<br>    })), {})<br><br>    rotation_policy = optional(object({<br>      automatic = optional(object({<br>        time_after_creation = optional(string, null)<br>        time_before_expiry  = optional(string, null)<br>      }), null)<br>      expire_after         = optional(string, null)<br>      notify_before_expiry = optional(string, null)<br>    }), null)<br>  }))</pre> | `{}` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] . | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| <a name="input_legacy_access_policies"></a> [legacy\_access\_policies](#input\_legacy\_access\_policies) | A map of legacy access policies to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.<br><br>Requires `var.legacy_access_policies_enabled` to be `true`.<br><br>- `object_id` - (Required) The object ID of the principal to assign the access policy to.<br>- `application_id` - (Optional) The object ID of an Application in Azure Active Directory. Changing this forces a new resource to be created.<br>- `certifiate_permissions` - (Optional) A list of certificate permissions. Possible values are: `Backup`, `Create`, `Delete`, `DeleteIssuers`, `Get`, `GetIssuers`, `Import`, `List`, `ListIssuers`, `ManageContacts`, `ManageIssuers`, `Purge`, `Recover`, `Restore`, `SetIssuers`, and `Update`.<br>- `key_permissions` - (Optional) A list of key permissions. Possible value are: `Backup`, `Create`, `Decrypt`, `Delete`, `Encrypt`, `Get`, `Import`, `List`, `Purge`, `Recover`, `Restore`, `Sign`, `UnwrapKey`, `Update`, `Verify`, `WrapKey`, `Release`, `Rotate`, `GetRotationPolicy`, and `SetRotationPolicy`.<br>- `secret_permissions` - (Optional) A list of secret permissions. Possible values are: `Backup`, `Delete`, `Get`, `List`, `Purge`, `Recover`, `Restore`, and `Set`.<br>- `storage_permissions` - (Optional) A list of storage permissions. Possible values are: `Backup`, `Delete`, `DeleteSAS`, `Get`, `GetSAS`, `List`, `ListSAS`, `Purge`, `Recover`, `RegenerateKey`, `Restore`, `Set`, `SetSAS`, and `Update`. | <pre>map(object({<br>    object_id               = string<br>    application_id          = optional(string, null)<br>    certificate_permissions = optional(set(string), [])<br>    key_permissions         = optional(set(string), [])<br>    secret_permissions      = optional(set(string), [])<br>    storage_permissions     = optional(set(string), [])<br>  }))</pre> | `{}` | no |
| <a name="input_legacy_access_policies_enabled"></a> [legacy\_access\_policies\_enabled](#input\_legacy\_access\_policies\_enabled) | Specifies whether legacy access policies are enabled for this Key Vault. Prevents use of Azure RBAC for data plane. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_lock"></a> [lock](#input\_lock) | The lock level to apply to the Key Vault. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`. | <pre>object({<br>    kind = string<br>    name = optional(string, null)<br>  })</pre> | `null` | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'info@cypik.com' | `string` | `"info@cypik.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Key Vault. | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | The network ACL configuration for the Key Vault.<br>If not specified then the Key Vault will be created with a firewall that blocks access.<br>Specify `null` to create the Key Vault with no firewall.<br><br>- `bypass` - (Optional) Should Azure Services bypass the ACL. Possible values are `AzureServices` and `None`. Defaults to `None`.<br>- `default_action` - (Optional) The default action when no rule matches. Possible values are `Allow` and `Deny`. Defaults to `Deny`.<br>- `ip_rules` - (Optional) A list of IP rules in CIDR format. Defaults to `[]`.<br>- `virtual_network_subnet_ids` - (Optional) When using with Service Endpoints, a list of subnet IDs to associate with the Key Vault. Defaults to `[]`. | <pre>object({<br>    bypass                     = optional(string, "None")<br>    default_action             = optional(string, "Deny")<br>    ip_rules                   = optional(list(string), [])<br>    virtual_network_subnet_ids = optional(list(string), [])<br>  })</pre> | `{}` | no |
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | A map of private endpoints to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.<br><br>- `name` - (Optional) The name of the private endpoint. One will be generated if not set.<br>- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.<br>- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.<br>- `tags` - (Optional) A mapping of tags to assign to the private endpoint.<br>- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.<br>- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.<br>- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.<br>- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.<br>- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.<br>- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.<br>- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.<br>- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the Key Vault.<br>- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.<br>  - `name` - The name of the IP configuration.<br>  - `private_ip_address` - The private IP address of the IP configuration. | <pre>map(object({<br>    name = optional(string, null)<br>    role_assignments = optional(map(object({<br>      role_definition_id_or_name             = string<br>      principal_id                           = string<br>      description                            = optional(string, null)<br>      skip_service_principal_aad_check       = optional(bool, false)<br>      condition                              = optional(string, null)<br>      condition_version                      = optional(string, null)<br>      delegated_managed_identity_resource_id = optional(string, null)<br>      principal_type                         = optional(string, null)<br>    })), {})<br>    lock = optional(object({<br>      kind = string<br>      name = optional(string, null)<br>    }), null)<br>    tags                                    = optional(map(string), null)<br>    subnet_resource_id                      = string<br>    private_dns_zone_group_name             = optional(string, "default")<br>    private_dns_zone_resource_ids           = optional(set(string), [])<br>    application_security_group_associations = optional(map(string), {})<br>    private_service_connection_name         = optional(string, null)<br>    network_interface_name                  = optional(string, null)<br>    location                                = optional(string, null)<br>    resource_group_name                     = optional(string, null)<br>    ip_configurations = optional(map(object({<br>      name               = string<br>      private_ip_address = string<br>    })), {})<br>  }))</pre> | `{}` | no |
| <a name="input_private_endpoints_manage_dns_zone_group"></a> [private\_endpoints\_manage\_dns\_zone\_group](#input\_private\_endpoints\_manage\_dns\_zone\_group) | Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy. | `bool` | `true` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Whether public network access is allowed for this Key Vault. Defaults to true | `bool` | `true` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | Specifies whether protection against purge is enabled for this Key Vault. Note once enabled this cannot be disabled. | `bool` | `true` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Terraform current module repo | `string` | `"https://github.com/cypik/terraform-azure-key-vault"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | A map of role assignments to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.<br><br>- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.<br>- `principal_id` - The ID of the principal to assign the role to.<br>- `description` - The description of the role assignment.<br>- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.<br>- `condition` - The condition which will be used to scope the role assignment.<br>- `condition_version` - The version of the condition syntax. If you are using a condition, valid values are '2.0'.<br><br>> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal. | <pre>map(object({<br>    role_definition_id_or_name             = string<br>    principal_id                           = string<br>    description                            = optional(string, null)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>    condition                              = optional(string, null)<br>    condition_version                      = optional(string, null)<br>    delegated_managed_identity_resource_id = optional(string, null)<br>    principal_type                         = optional(string, null)<br>  }))</pre> | `{}` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets to create | <pre>list(object({<br>    name             = string<br>    value            = string<br>    content_type     = optional(string)<br>    expiration_date  = optional(string)<br>    not_before_date  = optional(string)<br>    tags             = optional(map(string))<br>    role_assignments = optional(any)<br>  }))</pre> | `[]` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name of the Key Vault. Default is `premium`. Possible values are `standard` and `premium`. | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the Key Vault resource. | `map(string)` | `null` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Azure tenant ID used for authenticating requests to Key Vault. You can use the `azurerm_client_config` data source to retrieve it. | `string` | n/a | yes |
| <a name="input_wait_for_rbac_before_contact_operations"></a> [wait\_for\_rbac\_before\_contact\_operations](#input\_wait\_for\_rbac\_before\_contact\_operations) | This variable controls the amount of time to wait before performing contact operations.<br>It only applies when `var.role_assignments` and `var.contacts` are both set.<br>This is useful when you are creating role assignments on the key vault and immediately creating keys in it.<br>The default is 30 seconds for create and 0 seconds for destroy. | <pre>object({<br>    create  = optional(string, "30s")<br>    destroy = optional(string, "0s")<br>  })</pre> | `{}` | no |
| <a name="input_wait_for_rbac_before_key_operations"></a> [wait\_for\_rbac\_before\_key\_operations](#input\_wait\_for\_rbac\_before\_key\_operations) | This variable controls the amount of time to wait before performing key operations.<br>It only applies when `var.role_assignments` and `var.keys` are both set.<br>This is useful when you are creating role assignments on the key vault and immediately creating keys in it.<br>The default is 30 seconds for create and 0 seconds for destroy. | <pre>object({<br>    create  = optional(string, "30s")<br>    destroy = optional(string, "0s")<br>  })</pre> | `{}` | no |
| <a name="input_wait_for_rbac_before_secret_operations"></a> [wait\_for\_rbac\_before\_secret\_operations](#input\_wait\_for\_rbac\_before\_secret\_operations) | This variable controls the amount of time to wait before performing secret operations.<br>It only applies when `var.role_assignments` and `var.secrets` are both set.<br>This is useful when you are creating role assignments on the key vault and immediately creating secrets in it.<br>The default is 30 seconds for create and 0 seconds for destroy. | <pre>object({<br>    create  = optional(string, "30s")<br>    destroy = optional(string, "0s")<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_keys"></a> [keys](#output\_keys) | A map of key names with full key details. |
| <a name="output_keys_resource_ids"></a> [keys\_resource\_ids](#output\_keys\_resource\_ids) | Key names mapped to their IDs and versionless IDs. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Key Vault. |
| <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints) | Private endpoints linked to the Key Vault. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The resource ID of the Key Vault. |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | A map of secret names with full secret details. |
| <a name="output_secrets_resource_ids"></a> [secrets\_resource\_ids](#output\_secrets\_resource\_ids) | Secret names mapped to their resource IDs. |
| <a name="output_uri"></a> [uri](#output\_uri) | The URI of the Key Vault. |
<!-- END_TF_DOCS -->