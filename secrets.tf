module "secrets" {
  source   = "./modules/secret"
  for_each = { for s in var.secrets : s.name => s }

  key_vault_resource_id = azurerm_key_vault.this.id
  name                  = each.value.name
  value                 = each.value.value
  content_type          = lookup(each.value, "content_type", null)
  expiration_date       = lookup(each.value, "expiration_date", null)
  not_before_date       = lookup(each.value, "not_before_date", null)
  role_assignments      = lookup(each.value, "role_assignments", null)
  tags                  = lookup(each.value, "tags", null)

  depends_on = [
    azurerm_private_endpoint.this,
    time_sleep.wait_for_rbac_before_secret_operations
  ]
}


resource "time_sleep" "wait_for_rbac_before_secret_operations" {
  count = length(var.role_assignments) != 0 && length(var.secrets) != 0 ? 1 : 0

  create_duration  = var.wait_for_rbac_before_secret_operations.create
  destroy_duration = var.wait_for_rbac_before_secret_operations.destroy
  triggers = {
    role_assignments = jsonencode(var.role_assignments)
  }

  depends_on = [
    azurerm_role_assignment.this
  ]
}