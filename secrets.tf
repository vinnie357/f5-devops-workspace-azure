# thanks mark https://github.com/mjmenger/terraform-azure-bigip-setup/blob/master/secrets.tf

#
# Create random password
#
resource "random_password" "password" {
    length           = 16
    special          = true
    override_special = "_%@"
}
# # client config
# data "azurerm_client_config" "current" {}

# # create azure key vault
# resource "azurerm_key_vault" "workspace-vault" {
#     name                = format("kv%s", random_id.randomId.hex)
#     location            = azurerm_resource_group.main.location
#     resource_group_name = azurerm_resource_group.main.name
#     tenant_id           = data.azurerm_client_config.current.tenant_id

#     sku_name = "premium"

#     access_policy {
#         tenant_id = data.azurerm_client_config.current.tenant_id
#         object_id = data.azurerm_client_config.current.object_id

#         key_permissions = [
#         "create",
#         "get",
#         ]

#         secret_permissions = [
#         "set",
#         "get",
#         "delete",
#         "list",
#         ]
#     }

#     tags = {
#         environment = var.environment
#     }
# }

# # create password for vault
# resource "azurerm_key_vault_secret" "workspace-password" {
#     name         = format("workspace-password-%s",random_id.randomId.hex)
#     value        = random_password.password.result
#     key_vault_id = azurerm_key_vault.workspace-vault.id

#     tags = {
#         environment = var.environment
#     }
# }