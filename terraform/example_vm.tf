provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "myRg" {
  location = "Australia East"
  name = "myRg"
  tags = {
    env = "test"
  }
}

resource "azurerm_virtual_network" "myVnet" {
  name = "myVnet"
  resource_group_name = azurerm.resource_group.myRg.name
  location = azurerm.resource_group.myRg.location
  address_space = ["10.0.0.0/24"]
}

resource "subnet" "mySubnet" {
  name = "mySubnet"
  resource_group_name = azurerm.resource_group.myRg
  virtual_network = azurerm.resource_group.myVnet
  address_prefix = ["10.0.0.1/27"]
}

resource "network_security_group" "myNSG" {
  name = "myNSG"
  location = azurerm.resource_group.myRg.location
  resource_group_name = azurerm.resource_group.myRg.name
}

resource "network_security_group_rule" "myRule" {
  name = "myRule"
  network_security_group = azurerm.network_secuirty_group.myNSG.name
  resource_group_name = azurerm_resource_group.myRg.name
  protocol = "TCP"
  access = "Allow"
  source_port_range = "*"
  destination_port_range = 22
  source_address_prefix = ["0.0.0.0/0"]
  destination_address_prefix = "*"
  priority = 150
  direction = "Inbound"
}

resource "azurerm_subnet_network_secuirty_group_association" "myAssoc" {
  subnet_id = azurerm_subnet.mySubnet.id
  network_secuirty_group_id = azurerm_network_secuirty_group.myNSG.id
}

resource "azurerm_public_ip" "myip" {
  name = "myIP"
  resource_group_name = azurerm_resource_group.myRg.name
  location = azurerm_resource_group.myRg.location
  allocation_method = "Static"
}

resource "azurerm_network_interface" "myNIC" {
  name = "myNIC"
  location = azurerm_resource_group.myRg.location
  name = azurerm_resource_group.myRg.name
  ip_configuration = {
    name = "myConfig"
    subnet_id = azurerm_subnet.mySubnet.id
    public_ip_address_id = azurerm_public_ip.myIP.id
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_network_interface_secuirty_group_association" "Assoc" {
  network_secuirty_group_id = azurerm_network_secuirty_group.myNSG.id
  network_interface_id = azurerm_network_interface.myNIC.id
}

resource "azurerm_managed_disk" "myDisk" {
  name = "myDisk"
  location = azurerm_resource_group.myRg.location
  create_option = "Empty"
  disk_size_gb = 128
  resource_group_name = azurerm_resource_group.myRg.name
  storage_account_type = "Premium_LRS"
}
resource "azurerm_virtual_machine" "myVM" {
  name = "myVM"
  location = azurerm_resource_group.myRg.location
  resource_group_name = azurerm_resource_group.myRg.name
  size = "Standard_DS1_V2"
  admin_username = "admin"
  network_interface_id = azurerm_network_interface.myNIC.id
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard LRS"
  }
  data_disk {
    caching = "ReadWrite"
    managed_disk_id = azurerm_managed_disk.myDisk.id
    lun = 0
    create_option = "Attach"
  }
  admin_ssh_key {
    username = "admin"
    public_key = "<path-to-public-key>"
  }
  source_image_reference {
    publisher = "Canonical"
    version = "latest"
    sku = "18.0-LTS"
    offer = "UbuntuServer"
  }
}

resource "azurerm_virtual_machine" "winVM" {
  name = "winVM"
  location = azurerm_resource_group.myRg.location
  resource_group_name = azurerm_resource_group.myRg.name
  network_interface_ids = azurerm_network_interface.myNIC.id
  size = "Standard_DSI_V2"
  os_disk {
    caching = ReadWrite
    storage_account_type = "Standard_LRS"
  }
  data_disk {
    managed_disk_id = azurerm_amanaged_disk.myDisk.id
    lun = 0
    caching = "ReadOnly"
  }
  zone = "1"
  admin_username = "admin"
  admin_password = var.password
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    version = "latest"
    offer = "windowsserver"
    sku = "2025-datacenter"
  }
  depends_on = [
    azurerm_network_secuirty_group.myNSG
    azurerm_virtual_network.myVnet
    azurerm_public_ip.myip
  ]
}