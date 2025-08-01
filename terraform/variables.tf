# here are all the variables that I needed for this project

variable "location" {
  type        = string
  default     = "francecentral"
  description = "Azure region for resources"
}
variable "admin_username" {
  type        = string
  default     = "paul"
  description = "Admin username for the VM"
}
variable "admin_password" {
  type        = string
  default     = "Justice2024!"
  description = "Admin passowrd for the VM"
  sensitive   = true
}
variable "vm_size" {
  type        = string
  default     = "Standard_B1s"
  description = "Size of the virtual machine"
}
variable "resource_group_name" {
  type        = string
  default     = "testing-terraform-rg"
  description = "Name of thess RG"
}
variable "vnet_name" {
  type        = string
  default     = "terraform-vnet"
  description = "Name of the Vnet"
}
variable "subnet_name" {
  default = "terraform-subnet"
}
variable "nsg_name" {
  type        = string
  default     = "terraform-nsg"
  description = "Nsg name"
}
variable "public_ip_name" {
  type        = string
  default     = "terraform-public-ip"
  description = "Name of the Public IP"
}
variable "nic_name" {
  type        = string
  default     = "terraform-nic"
  description = "Name of the NIC"
}
variable "vm_name" {
  type        = string
  default     = "terraform-vm"
  description = "Name of the virtual machine "
}
variable "ubuntu_image" {
  description = "Ubuntu image reference"
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"

  }
}







