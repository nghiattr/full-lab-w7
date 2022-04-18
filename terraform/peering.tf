# resource "azurerm_virtual_network_peering" "aks2ag" {
#   name                      = "aks2ag"
#   resource_group_name       = azurerm_resource_group.rg.name
#   virtual_network_name      = azurerm_virtual_network.myterraformnetwork.name
#   remote_virtual_network_id = azurerm_virtual_network.vnetaks.id
# }

# resource "azurerm_virtual_network_peering" "ag2aks" {
#   name                      = "ag2aks"
#   resource_group_name       = azurerm_resource_group.rg.name
#   virtual_network_name      = azurerm_virtual_network.vnetaks.name
#   remote_virtual_network_id = azurerm_virtual_network.myterraformnetwork.id
# }