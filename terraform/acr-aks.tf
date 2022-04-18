/*-----------------------Create ACR--------------------------------------------*/



resource "azurerm_container_registry" "acrk8s" {



  name                = "nghiattracrk8s"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  //Each container registry contains an admin user account that is disabled by default
  admin_enabled = false

}

/*-----------------------Create AKS--------------------------------------------*/

# resource "azurerm_virtual_network" "vnetaks" {
#     name                        = "vnetaks"
#     location                    = azurerm_resource_group.rg.location
#     resource_group_name         = azurerm_resource_group.rg.name
#     address_space               = ["172.16.0.0/12"]
# }

resource "azurerm_subnet" "akspodssubnet" {
    name                        = "akspodssubnet"
    resource_group_name         = azurerm_resource_group.rg.name
    #virtual_network_name        = azurerm_virtual_network.vnetaks.name   dif vnet
    #address_prefixes              = ["172.16.0.0/24"]
    virtual_network_name        = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes              = ["172.16.2.0/24"]
    
}

resource "azurerm_kubernetes_cluster" "k8s-cluster" {

  name                = "azure-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "k8s-cluster"
  node_resource_group = "K8S${azurerm_resource_group.rg.name}"



  default_node_pool {

    name                = "default"
    node_count          = 1
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
    vm_size             = "Standard_F2s_v2"
    vnet_subnet_id        = azurerm_subnet.akspodssubnet.id

  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key { key_data = azurerm_ssh_public_key.ssh-awx.public_key }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }

}

# add the role to the identity the kubernetes cluster was assigned

resource "azurerm_role_assignment" "role-aks" {

  principal_id                     = azurerm_kubernetes_cluster.k8s-cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acrk8s.id
  skip_service_principal_aad_check = true

}