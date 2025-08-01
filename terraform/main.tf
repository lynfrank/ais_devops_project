# basic information to include when we are using for azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.1.0 "
}
provider "azurerm" {
  features {}
}

# here all the config for simple ubuntu vm spot

resource "azurerm_resource_group" "devops_rg" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_virtual_network" "devops_vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  depends_on          = [azurerm_resource_group.devops_rg]
}
resource "azurerm_subnet" "devops_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.devops_rg.name
  virtual_network_name = azurerm_virtual_network.devops_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on           = [azurerm_virtual_network.devops_vnet]
}
resource "azurerm_public_ip" "devops_pip" {
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.devops_rg.name
  location            = azurerm_resource_group.devops_rg.location
  allocation_method   = "Static"
  sku = "Standard"
  depends_on          = [azurerm_resource_group.devops_rg]
}
# resource "azurerm_public_ip" "devops_pip" {
#   name                = var.public_ip_name
#   resource_group_name = azurerm_resource_group.devops_rg.name
#   location            = azurerm_resource_group.devops_rg.location
#   allocation_method   = "Dynamic"
#   sku                 = "Standard"

#   tags = {
#     environment = "devops"
#   }
# }

resource "azurerm_network_security_group" "devops_nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  security_rule {
    name                       = "Allow-All-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-All-Outbound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [azurerm_resource_group.devops_rg]
}
resource "azurerm_network_interface" "devops_nic" {
  name                = var.nic_name
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devops_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devops_pip.id
  }
  depends_on = [azurerm_public_ip.devops_pip, azurerm_subnet.devops_subnet, azurerm_public_ip.devops_pip]
}
# I am going to associate the NSG to the subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.devops_subnet.id
  network_security_group_id = azurerm_network_security_group.devops_nsg.id
  depends_on                = [azurerm_subnet.devops_subnet, azurerm_network_security_group.devops_nsg]
}





# our spot ubuntu
resource "azurerm_linux_virtual_machine" "devops_vm" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.devops_rg.name
  location                        = azurerm_resource_group.devops_rg.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.devops_nic.id,
  ]

  priority        = "Spot"
  eviction_policy = "Deallocate"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.ubuntu_image.publisher
    offer     = var.ubuntu_image.offer
    sku       = var.ubuntu_image.sku
    version   = var.ubuntu_image.version
  }
  custom_data = filebase64("${path.module}/cloud-init.yaml")
  #custom_data                = data.template_cloudinit_config.config.rendered
  provision_vm_agent         = true
  allow_extension_operations = true
  # depends_on                 = [azurerm_public_ip.devops_pip, azurerm_subnet.devops_subnet, azurerm_subnet_network_security_group_association.nsg_association, data.template_cloudinit_config.config]

}


####

/*
resource "azurerm_virtual_machine_extension" "install_jenkins" {
  name                 = "install-jenkins"
  virtual_machine_id   = azurerm_linux_virtual_machine.devops_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = jsonencode({
    fileUris         = ["https://raw.githubusercontent.com/stanilpaul/docker-getting-started-devops-enhanced/main/install_jenkins.sh"]
    commandToExecute = "bash install_jenkins.sh"
  })

  depends_on = [azurerm_linux_virtual_machine.devops_vm]
}
*/
####


#output : this part is what we will see later terraform apply 
output "public_ip" {
  value      = azurerm_public_ip.devops_pip.ip_address
  depends_on = [azurerm_linux_virtual_machine.devops_vm, azurerm_public_ip.devops_pip]
}
output "ssh_command" {
  value      = "ssh ${var.admin_username}@${azurerm_public_ip.devops_pip.ip_address}"
  depends_on = [azurerm_linux_virtual_machine.devops_vm, azurerm_public_ip.devops_pip]
}


