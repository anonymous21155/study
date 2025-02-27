resource "azurerm_resource_group" "myRg" {
  name = "RG"
  location = "Canada Central"
  tags = {
    env = "prod"
  }
}


resource "azurerm_virtual_network" "myVnet" {
  name = "vnet"
  location = azurerm_resource_group.myRg.location
  resource_group = azurerm_resource_group.myRg.name
  address_space = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "mySubnet" {
  name = "mySubnet"
  virtual_network = azurerm_virtual_network.myVnet.name
  address_prefix = ["192.168.0.0/24]
  resource_group_name = azurerm_resource_group.myRg.name
}

resource "azurerm_network_security_group" "myNSG" {
  name = "myNSG"
  location = azurerm_resource_group.myRg.location
  resource_group_name = azurerm_resource_group.myRg.name
}

resource "azurerm_network_security_rule" "myRule" {
  name = "myRule"
  access = "Allow"
  priority = 500
  source_port_range = "*"
  destination_port_range = 22
  direction = "Inbound"
  protocol = "TCP"
  source_address_prefix = "0.0.0.0./0"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.myRg.name
  network_security_group = azurerm_network_security_group.name
}

resource "azurerm_subnet_network_secuirty_group_association" "myAssoc" {
  subnet_id = azurerm_subnet_mySubnet.id
  network_secuirty_group_id = azurerm_network_security_group.myNSG.id
}
