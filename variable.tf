variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16" # users can override this cidr
}

variable "enable_dns_hostnames" {
  type = bool
  default = true
}

# we are keeping tags as optional here in main.tf n variable.tf . 
# later in lab2 we will give our own tags codes in varibles.tf in vpc-test folder)
variable "common_tags" {
  type = map
  default = {} # it is optional
}

variable "vpc_tags" {
  type = map
  default = {} # empty {} means it is optional & If you comment it (ex, # default = {}), means user must provide values. 
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "igw_tags" {
  type = map
  default = {}
}

variable "public_subnets_cidr" {
  type = list
   # writing length function to get list size  == 2 & error message using validation
  validation {   
    condition = length(var.public_subnets_cidr) == 2
    error_message = "Please give 2 public valid subnet CIDR"
  }
}

variable "public_subnets_tags" {
  default = {}
}

variable "private_subnets_cidr" {
  type = list
  validation {
    condition = length(var.private_subnets_cidr) == 2
    error_message = "Please give 2 private valid subnet CIDR"
  }
}

variable "private_subnets_tags" {
  default = {}
}

variable "database_subnets_cidr" {
  type = list
  validation {
    condition = length(var.database_subnets_cidr) == 2
    error_message = "Please give 2 database valid subnet CIDR"
  }
}

variable "database_subnets_tags" {
  default = {}
}

variable "nat_gateway_tags" {
  default = {}
}

variable "public_route_table_tags" {
  default = {}
}

variable "private_route_table_tags" {
  default = {}
}

variable "database_route_table_tags" {
  default = {}
}

variable "is_peering_required" {
  type = bool
  default = false
}

variable "acceptor_vpc_id" {
  type = string
  default = ""
}

variable "vpc_peering_tags" {
  default = {}
}