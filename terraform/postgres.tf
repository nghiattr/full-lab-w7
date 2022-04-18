
#Postgre Service
#Manages a PostgreSQL Database within a PostgreSQL Server
resource "azurerm_postgresql_flexible_server" "postgresqlSV" {
  name                = "postgresql-server-nghiattr"
  location            = "Australia East"
  resource_group_name = azurerm_resource_group.rg.name


  sku_name = "GP_Standard_D2s_v3"

  storage_mb                   = 32768
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  administrator_login    = "labadmin"
  administrator_password = "H@Sh1CoR3!"
  zone                   = "1"
  version                = "11"
}

resource "azurerm_postgresql_flexible_server_database" "postgresqlDB" {
  depends_on = [azurerm_postgresql_flexible_server.postgresqlSV]
  name       = "users"
  server_id  = azurerm_postgresql_flexible_server.postgresqlSV.id
  collation  = "en_US.utf8"
  charset    = "utf8"
}



resource "azurerm_postgresql_flexible_server_firewall_rule" "ruleall" {
  name             = "all-allow-fw"
  server_id        = azurerm_postgresql_flexible_server.postgresqlSV.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}