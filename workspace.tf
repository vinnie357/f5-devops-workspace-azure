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
  name                = "${var.prefix}workspace-mgmt-pip${var.buildSuffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"

  tags = {
    Name = "${var.prefix}-workspace-public-ip"
  }
}

# linuxbox
resource "azurerm_network_interface" "workspace-mgmt-nic" {
  name                = "${var.projectPrefix}-workspace-mgmt-nic"
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
    name                  = "workstation"
    location                     = azurerm_resource_group.main.location
    resource_group_name          = azurerm_resource_group.main.name
    
    network_interface_ids = [azurerm_network_interface.workspace-mgmt-nic.id]
    vm_size               = var.instanceType

    admin_ssh_key {
        username   = var.adminAccountName
        public_key = var.sshPublicKey
    }

    storage_os_disk {
        name              = "workspaceOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = var.diskType
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04.0-LTS"
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