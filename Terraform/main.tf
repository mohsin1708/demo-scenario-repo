provider "azurerm" {
  version = "=2.5.0"
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
	name        = "${var.prefix}-resource-group
	location    = var.location
  tags {
    environment = "${var.environment}"
  }
}


# Network security Group

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-security-group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags {
    environment = "${var.environment}"
  }
}

# Network security rule

resource "azurerm_network_security_rule" "Port80" {
   name                       = "Allow80"
   priority                   = 102
   direction                  = "Inbound"
   access                     = "Allow"
   protocol                   = "Tcp"
   source_port_range          = "*"
   destination_port_range     = "80"
   source_address_prefix      = "*"
   destination_address_prefix = "*"
   resource_group_name = azurerm_resource_group.rg.name
   network_security_group_name = azurerm_network_security_group.nsg.name

   tags {
     environment = "${var.environment}"
   }
 }


 resource "azurerm_network_security_rule" "Port443" {
    name                       = "Allow443"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.nsg.name

    tags {
      environment = "${var.environment}"
    }
  }




# Virtual Network
resource "azurerm_virtual_network" "avn" {
	name                = "${var.prefix}-network"
	resource_group_name = azurerm_resource_group.rg.name
	location            = azurerm_resource_group.rg.location
	address_space       = [var.vnetAddressPrefix]

  tags {
    environment = "${var.environment}"
  }
}


# subnet

resource "azurerm_subnet" "sub" {
  count = var.node_count
	name  = "${var.prefix}-subnet-${count.index}"
	resource_group_name   = azurerm_resource_group.rg.name
	virtual_network_name  = azurerm_virtual_network.avn.name
	address_prefixes      = [var.node_address_prefix[count.index-1]]

  tags {
    environment = "${var.environment}"
  }
}

# Subnet and NSG association
resource “azurerm_subnet_network_security_group_association” “subnet_nsg_association” {
count = var.node_count
subnet_id = azurerm_subnet.sub.*.id[count.index]
network_security_group_id = azurerm_network_security_group.nsg.id

tags {
  environment = "${var.environment}"
}
}

# NIC

resource "azurerm_network_interface" "nic" {
   count = var.node_count
   name  = "${var.prefix}-NIC-${count.index}"
   location = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name
 ip_configuration {
     name                          = "ip-config-${count.index}"
     subnet_id                     = azurerm_subnet.sub.*.id[count.index]
     private_ip_address_allocation = "Dynamic"
   }

   tags {
     environment = "${var.environment}"
   }
 }


# Storage Account

resource "azurerm_storage_account" "sa" {
  name                     = "${var.prefix}-storage-account"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags {
    environment = "${var.environment}"
  }
}


# KEY VAult secret

data "azurerm_key_vault_secret" "test" {
  name      = "vm-admin-password"
  vault_uri = "https://demo.vault.azure.net/"
}

output "secret_value" {
  value = "${data.azurerm_key_vault_secret.test.value}"
}

#VM

resource "azurerm_windows_virtual_machine" "vm" {
   count = var.node_count
   name  = "${var.prefix}-VM-${count.index}"
   resource_group_name = azurerm_resource_group.rg.name
   location            = azurerm_resource_group.rg.location
   size                = "Standard_F2"
   admin_username      = "admin_user"
   admin_password      = "${data.azurerm_key_vault_secret.test.value}"
   network_interface_ids = [
     azurerm_network_interface.nic.*.id[count.index],
   ]
 os_disk {
     caching              = "ReadWrite"
     storage_account_type = "Standard_LRS"
   }
 source_image_reference {
     publisher = "MicrosoftWindowsServer"
     offer     = "WindowsServer"
     sku       = "2016-Datacenter"
     version   = "latest"
   }
 }
