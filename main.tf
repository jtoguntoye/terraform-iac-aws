    provider "aws" {
        region = var.region
    }

    #configure terraform s3 backend
    terraform{
        backend "s3" {
            bucket = "joekiff-dev-terraform-bucket"
            key = "global/s3/terraform.tfstate"
            region = "eu-west-3"
            dynamodb_table = "terraform-locks"
          
        }
    }

# create VPC
    resource "aws_vpc" "main" {
        cidr_block = var.vpc_cidr
        enable_dns_support = var.enable_dns_support 
        enable_dns_hostnames = var.enable_dns_hostnames
        enable_classiclink = var.enable_classiclink
        enable_classiclink_dns_support = var.enable_classiclink_dns_support
    
    tags = merge (
        var.tags,
        {
        Name = var.vpc_name    
        }

    )
    }

#Get list of available zones using data sources
    data "aws_availability_zones" "available" {
        state = "available"
    }    

# create public subnet1
    resource "aws_subnet" "public" {
        count = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets
        vpc_id = aws_vpc.main.id
        cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
        map_public_ip_on_launch = true
        availability_zone = data.aws_availability_zones.available.names[count.index]

        tags = merge(
            var.tags,
            {
             Name = format("public-%s", count.index + 1)
            }
        )
    }

# create private subnets for web servers
  resource "aws_subnet" "private-A" {
      count = var.preferred_number_of_private_subnets == null ? length(data.aws_availability_zones.available.names): var.preferred_number_of_private_subnets
      vpc_id = aws_vpc.main.id
      cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
      availability_zone = data.aws_availability_zones.available.names[count.index]    
      tags = merge(
            var.tags,
            {
             Name = format("privateSubnet-%s", count.index + 1)
            }
        )
  
  }    

# create private subnets for data storage layer
  resource "aws_subnet" "private-B" {
      count = var.preferred_number_of_private_subnets == null ? length(data.aws_availability_zones.available.names): var.preferred_number_of_private_subnets
      vpc_id = aws_vpc.main.id
      cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 5)
      availability_zone = data.aws_availability_zones.available.names[count.index]    
      tags = merge(
            var.tags,
            {
             Name = format("PrivateSubnet-%s", count.index + 3)
            }
        )
  
  }  