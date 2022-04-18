


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "myVnet-assign2"
  #address_space       = ["10.0.0.0/16"]
  address_space       = ["172.16.0.0/12"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "mySubnet-assign2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  #address_prefixes     = ["10.0.1.0/24"]
  address_prefixes     = ["172.17.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "myPublicIP-assign2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNSG-assign2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Jenkins"
    priority                   = 121
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Gitlab-2"
    priority                   = 123
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8011"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Gitlab-3"
    priority                   = 124
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8012"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Gitlab-4"
    priority                   = 125
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8013"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                = "myNIC-assign2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration-assign2"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}


# Create (and display) an SSH key
resource "azurerm_ssh_public_key" "example_ssh" {
  name                = "sshkey-linux"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  public_key          = file("./id_rsa.pub")
}

# Create virtual machine Linux for Jenkins-GitLab Server
resource "azurerm_linux_virtual_machine" "jenkins-gitlab-sv" {
  name                  = "jenkins-gitlab-sv"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnic.id]
  size                  = "Standard_B4ms"

  os_disk {
    name                 = "myOsDisk-assign2"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "jenkins-gitlab-sv"
  admin_username                  = var.admin_username
  admin_password = var.admin_password 
  disable_password_authentication = false

  admin_ssh_key {
    username   = var.admin_username
    public_key = azurerm_ssh_public_key.example_ssh.public_key
  }
}

resource "null_resource" "install_and_run_ansible2" {
  depends_on = [azurerm_linux_virtual_machine.centos-vm]
  connection {
    type        = "ssh"
    user        = var.admin_username
    #password = var.admin_password
    private_key = file("./id_rsa")
    host        = azurerm_linux_virtual_machine.centos-vm.public_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /home/ac",
      "sudo chmod 777 /home/ac"
    ]
  }
  provisioner "file" {
    source      = "./install-awx.sh"
    destination = "/home/ac/install-awx.sh"
  }
  provisioner "file" {
    source      = "./ansible-jen-git/"
    destination = "/home/ac/"
  }

  # provisioner "local-exec" {
  #   command = "sed -i '2 i\${azurerm_linux_virtual_machine.jenkins-gitlab-sv.public_ip_address}' /ansible-jen-git/inventory"
  #   interpreter = ["bash", "-c"]
  # }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ac/install-awx.sh",
      "sudo /home/ac/install-awx.sh",
      # "git clone https://github.com/nghiattr/ansible-jen-git.git",
      # "cd /ansible-jen-git/",
      "cp /home/ac/id_rsa ~/.ssh/id_rsa",
      "sudo chmod 777 /etc/ansible/ansible.cfg",
      "echo $'[defaults] \nhost_key_checking = false' > /etc/ansible/ansible.cfg",
      "echo 'server1 ansible_host=${azurerm_linux_virtual_machine.jenkins-gitlab-sv.public_ip_address} ansible_user=labadmin ansible_password=Password1234! ansible_python_interpreter=/usr/bin/python3' > /home/ac/inventory ",
      #"sed -i '2 i \asd' /home/ac/inventory",
      "ansible-playbook /home/ac/playbook.yaml -i /home/ac/inventory -u labadmin ",
    ]
  }
}

