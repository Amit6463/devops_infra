terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "5.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "example" {
  name = "amit5_rg"
  location = "eastus"
}
resource "azurerm_resource_group" "example" {
  name = "amit6_rg"
  location = "centralindia"
}


resource "azurerm_storage_account" "stg" {
  name = "insiderstoarge45678"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "con" {
  name = "amitcontainer"
  storage_account_id = azurerm_storage_account.stg.id
  container_access_type = "private"
}

resource "azurerm_virtual_network" "vn" {
  name = "amit_vnet"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name = "amit_subnet"
  virtual_network_name = azurerm_virtual_network.vn.name
  resource_group_name = azurerm_resource_group.example.name
  address_prefixes = ["10.0.2.0/26"]
}

resource "azurerm_network_interface" "nic" {
  name = "amit_nic"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
  ip_configuration {
    name = "prvate_internet"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet.id
  }
}

resource "azurerm_virtual_machine" "main" {
   name                  = "amitvm1"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"
   storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
