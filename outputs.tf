## OUTPUTS ###

output "sg_id" { value = azurerm_network_security_group.main.id }
output "sg_name" { value = azurerm_network_security_group.main.name }

# workstation
output "workspace_id" { value = azurerm_virtual_machine.id  }
output "mgmt_private_ip" { value = azurerm_network_interface.workspace-mgmt-nic.private_ip_address }
output "mgmt_public_ip" { value = "https://${azurerm_network_interface.workspace-mgmt-nic.ip_address}" }
output "mgmt_ssh" { value = "ssh ${var.adminAccountName}@${azurerm_network_interface.workspace-mgmt-nic.ip_address}" }
output "workspace_password" { value = random_password.password.result }