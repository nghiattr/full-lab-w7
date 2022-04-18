
/*-----------------------CentOS AWX--------------------------------------------*/

resource "azurerm_virtual_network" "myterraformnetwork-awx" {
  name                = "myVnet-awx"
  address_space       = ["10.0.0.0/16"]
  location            = "Japan East"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet-awx" {
  name                 = "mySubnet-awx"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork-awx.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip-awx" {
  name                = "myPublicIP-awx"
  location            = "Japan East"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

#network interface
resource "azurerm_network_interface" "myterraformnic-awx" {
  name                = "myNIC-awx"
  location            = "Japan East"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration-awx"
    subnet_id                     = azurerm_subnet.myterraformsubnet-awx.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip-awx.id
  }
}

# Create (and display) an SSH key
resource "azurerm_ssh_public_key" "ssh-awx" {
  name                = "sshkey-awx"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "Japan East"
  public_key          = file("./id_rsa.pub")
}

#Create virtual machine centos awx
resource "azurerm_linux_virtual_machine" "centos-vm" {
  name                  = "centos-vm"
  location              = "Japan East"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnic-awx.id]
  size                  = "Standard_B4ms"

  os_disk {
    name                 = "myOsDisk-awx"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8_5-gen2"
    version   = "latest"
  }


  computer_name                   = "centos-vm"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  admin_ssh_key {
    username   = var.admin_username
    public_key = azurerm_ssh_public_key.ssh-awx.public_key
  }
  depends_on = [
    azurerm_network_interface.myterraformnic-awx
  ]

}