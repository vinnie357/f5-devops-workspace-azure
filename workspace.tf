data "http" "template_workspace" {
    url = var.onboardScript
}
data "template_file" "onboard" {
    
    template = data.http.template_workspace.body
    vars = {
        repositories       	  = var.repositories
        user            	  = var.adminAccountName
    }
}
# Create a Public IP for the Virtual Machines
resource "azurerm_public_ip" "workspace" {
  name                = "${var.projectPrefix}workspace-mgmt-pip-${random_pet.buildSuffix.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"

  tags = {
    Name = "${var.projectPrefix}-workspace-public-ip"
  }
}
data "azurerm_public_ip" "workspace" {
  name                = azurerm_public_ip.workspace.name
  resource_group_name = azurerm_resource_group.main.name
}

# linuxbox
resource "azurerm_network_interface" "workspace-mgmt-nic" {
  name                = "${var.projectPrefix}-workspace-mgmt-nic-${random_pet.buildSuffix.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  network_security_group_id = azurerm_network_security_group.main.id

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.mgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.workspaceIp
    primary			  = true
    public_ip_address_id          = azurerm_public_ip.workspace.id
  }

  tags = {
    Name           = "${var.environment}-workspace-ext-int"
    environment    = var.environment
    owner          = var.owner
    group          = var.group
    costcenter     = var.costcenter
    application    = "workstation"
  }
}
resource "azurerm_virtual_machine" "workstation" {
    name                         = "${var.projectPrefix}workstation-${random_pet.buildSuffix.id}"
    location                     = azurerm_resource_group.main.location
    resource_group_name          = azurerm_resource_group.main.name
    
    network_interface_ids = [azurerm_network_interface.workspace-mgmt-nic.id]
    vm_size               = var.instanceType

    storage_os_disk {
        name              = "workspaceOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = var.diskType
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "workstation"
        admin_username = var.adminAccountName
        admin_password = var.adminPassword == "" ? random_password.password.result : var.adminPassword
        custom_data = <<-EOF
                data.templatefile.onboard.rendered
              EOF
    }

    os_profile_linux_config {
        disable_password_authentication = false
        ssh_keys {
            #NOTE: Due to a limitation in the Azure VM Agent the only allowed path is /home/{username}/.ssh/authorized_keys.
            path  = "/home/${var.adminAccountName}/.ssh/authorized_keys"
            key_data = var.sshPublicKey
       }
    }

  tags = {
    Name           = "${var.environment}-workstation"
    environment    = var.environment
    owner          = var.owner
    group          = var.group
    costcenter     = var.costcenter
    application    = var.application
  }
}