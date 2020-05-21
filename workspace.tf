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
    application    = "workspace"
  }
}
resource "azurerm_virtual_machine" "workspace" {
    name                         = "${var.projectPrefix}-workspace-${random_pet.buildSuffix.id}"
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
        computer_name  = "workspace"
        admin_username = var.adminAccountName
        admin_password = var.adminPassword == "" ? random_password.password.result : var.adminPassword
        custom_data = data.template_file.onboard.rendered
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
    Name           = "${var.environment}-workspace"
    environment    = var.environment
    owner          = var.owner
    group          = var.group
    costcenter     = var.costcenter
    application    = var.application
  }
}

# Run Startup Script
resource "azurerm_virtual_machine_extension" "workspace-run-startup-cmd" {
  name                 = "${var.projectPrefix}-workspace-run-startup-cmd${random_pet.buildSuffix.id}"
  depends_on           = [azurerm_virtual_machine.workspace]
  location             = var.region
  resource_group_name  = azurerm_resource_group.main.name
  virtual_machine_name = azurerm_virtual_machine.workspace.name
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "echo ${data.template_file.onboard.rendered} > ./startup.sh && chmod +x ./startup.sh && bash ./startup.sh"
    }
  SETTINGS

  tags = {
    Name           = "${var.environment}-workspace-startup-cmd"
    environment    = var.environment
    owner          = var.owner
    group          = var.group
    costcenter     = var.costcenter
    application    = var.application
  }
}