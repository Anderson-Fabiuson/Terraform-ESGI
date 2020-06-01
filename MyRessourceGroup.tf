variable "prefix" {
  default = "tfvmex"
}

provider "azurerm" {
    features  {}
}

resource "azurerm_resource_group" "RGMonoVM1" {
  name     = "RGMonoVM1"
  location = "North Europe"

}

resource "azurerm_virtual_network" "virtualNetwork16" {
  name                = "virtualNetwork16"
  location            = azurerm_resource_group.RGMonoVM1.location
  resource_group_name = azurerm_resource_group.RGMonoVM1.name
  address_space       = ["192.168.0.0/16"]

}

resource "azurerm_subnet" "virtualNetwork24" {
  name                 = "virtualNetwork24"
  resource_group_name  = azurerm_resource_group.RGMonoVM1.name
  virtual_network_name = azurerm_virtual_network.virtualNetwork16.name
  address_prefixes       = ["192.168.1.0/24"]
}


resource "azurerm_network_interface" "main" {
  name                = "Interface-nic"
  location            = azurerm_resource_group.RGMonoVM1.location
  resource_group_name = azurerm_resource_group.RGMonoVM1.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.virtualNetwork24.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_virtual_machine" "main" {
  name                  = "Ubuntu-vm"
  location              = azurerm_resource_group.RGMonoVM1.location
  resource_group_name   = azurerm_resource_group.RGMonoVM1.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "MyUbuntu"
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

resource "azurerm_managed_disk" "ManagedDisk" {
  name                 = "managedDisk"
  location             = "East Europe"
  resource_group_name  = azurerm_resource_group.RGMonoVM1.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    environment = "staging"
  }
}

/*resource "azure_data_disk" "ManagedDisk" {
  name                 =  "ManagedDisk"
  lun                  = 0
  size                 = 10
  storage_service_name = "yourstorage"
  virtual_machine      = "Ubuntu-vm"
}
*/