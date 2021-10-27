    # create region variable
    variable "region" {
        default =  "eu-west-3"
    }
    variable "vpc_cidr" {
        default = "172.16.0.0/16"
    }
    variable "enable_dns_support" {
        default = "true"
    }

    variable "enable_dns_hostnames" {
        default ="true" 
    }

    variable "enable_classiclink" {
        default = "false"
    }

    variable "enable_classiclink_dns_support" {
        default = "false"
    }

    variable "preferred_number_of_public_subnets" {
        default = "null"
    }

    variable "preferred_number_of_private_subnets" {
      default = "null"
    }

    variable "tags" {
      description = "A mapping of tags to assign to all resources"
      type = map(string)
      default = {}
      
    }

    variable "vpc_name" {
      default = "vpc_name"
    }

    variable "public_subnet_tag" {
      default = ""
    }

    variable "eip_name" {
    }

    variable "nat_gw" {  
    }

    variable "private-rtb-name" {
    }

    variable "public-rtb-name" {
    }