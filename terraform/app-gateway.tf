
# Create subnet
resource "azurerm_subnet" "frontend" {
  name                 = "sub-frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  #virtual_network_name = azurerm_virtual_network.vnetaks.name dif vnet
  # address_prefixes     = ["172.17.0.0/24"] dif vnet
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  #address_prefixes     = ["10.0.3.0/24"]
  address_prefixes     = ["172.17.3.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "ippub-appgateway" {
  name                = "ippub-appgateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}



#&nbsp;since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.myterraformnetwork.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.myterraformnetwork.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.myterraformnetwork.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.myterraformnetwork.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.myterraformnetwork.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.myterraformnetwork.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.myterraformnetwork.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "network-appgateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ippub-appgateway.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    ip_addresses = [azurerm_linux_virtual_machine.jenkins-gitlab-sv.private_ip_address]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "probe_heath"
  }

  backend_http_settings {
    name                  = "gitlab-backend_http_settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 8012
    protocol              = "Http"
    request_timeout       = 60
    probe_name =  "probe_heath_2"
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = "jenkins.nghiattr777.tk"
  }

  http_listener {
    name                           = "lis-2"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name = "gitlab.nghiattr777.tk"
  }



  probe {
    host                = "jenkins.nghiattr777.tk"
    interval            = 30
    minimum_servers     = 0
    name                = "probe_heath"
    path                = "/"
    protocol            = "Http"
    timeout             = 30
    unhealthy_threshold = 3

    match {
      body = ""
      status_code = [
        "403",
        "200-399",
      ]
    }
  }
  probe {
    host = "gitlab.nghiattr777.tk"
    interval = 30
    minimum_servers = 0
    name  = "probe_heath_2"
    path = "/"
    pick_host_name_from_backend_http_settings = false
    protocol = "Http"
    timeout = 30
    unhealthy_threshold = 3

    match {
      body = ""
      status_code = [
        "403",
        "200-399",
      ]
    }
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
  request_routing_rule {
    name                       = "rules-2"
    rule_type                  = "Basic"
    http_listener_name         = "lis-2"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = "gitlab-backend_http_settings"
  }
}