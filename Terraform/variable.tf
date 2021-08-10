variable "location" {
type = string
}

variable "prefix" {
type = string
}
variable vnetAddressPrefix {
default = "1.0.0.0/16"
}
#variable for network range

variable "node_address_prefix" {
type = list
default = ["1.0.0.0/24", "1.0.1.0/24"]
}

#variable for Environment
variable "Environment" {
type = string
}


variable "node_count" {
type = number
}
