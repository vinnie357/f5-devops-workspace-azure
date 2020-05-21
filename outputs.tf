## OUTPUTS ###
data "azurerm_public_ip" "workspace" {
  name                = azurerm_public_ip.workspace.name
  resource_group_name = azurerm_resource_group.main.name
  depends_on          = [azurerm_public_ip.workspace]
}

output "sg_id" { value = azurerm_network_security_group.main.id }
output "sg_name" { value = azurerm_network_security_group.main.name }

# workspace
output "workspace_id" { value = azurerm_virtual_machine.workspace.id  }
output "mgmt_private_ip" { value = azurerm_network_interface.workspace-mgmt-nic.private_ip_address }
output "mgmt_public_ip" { value = "https://${data.azurerm_public_ip.workspace.ip_address}" }
output "mgmt_ssh" { value = "ssh ${var.adminAccountName}@${data.azurerm_public_ip.workspace.ip_address}" }
output "workspace_password" { value = random_password.password.result }