    provider "aws" {
        region = var.region
    }

# create VPC
    resource "aws_vpc" "main" {
        cidr_block = var.vpc_cidr
        enable_dns_support = var.enable_dns_support 
        enable_dns_hostnames = var.enable_dns_hostnames
        enable_classiclink = var.enable_classiclink
        enable_classiclink_dns_support = var.enable_classiclink_dns_support
    }

#Get list of available zones using data sources
    data "aws_availability_zones" "available" {
        state = "available"
    }    

# create public subnet1
    resource "aws_subnet" "public" {
        count = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) :var.preferred_number_of_public_subnets
        vpc_id = aws_vpc.main.id
        cidr_block = cidrsubnet(var.vpc_cidr, 4, count.index)
        map_public_ip_on_launch = true
        availability_zone = data.aws_availability_zones.available.names[count.index]
    }
