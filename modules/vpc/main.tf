
#Get list of available zones using data sources
    data "aws_availability_zones" "available" {
        state = "available"
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
        Name = var.name  
        }

    )
    }

  
# create public subnet
    resource "aws_subnet" "public" {
        count = var.public-sn-count
        vpc_id = aws_vpc.main.id
        cidr_block = var.public-cidr[count.index]
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
      count = var.private-sn-count
      vpc_id = aws_vpc.main.id
      cidr_block = var.private-a-cidr[count.index]
      availability_zone = data.aws_availability_zones.available.names[count.index]    
      tags = merge(
            var.tags,
            {
             Name = format("privateSubnet-%s", count.index +1)
            }
        )
  
  }    

# create private subnets for data storage layer
  resource "aws_subnet" "private-B" {
      count = var.private-sn-count
      vpc_id = aws_vpc.main.id
      cidr_block = var.private-b-cidr[count.index]
      availability_zone = data.aws_availability_zones.available.names[count.index]    
      tags = merge(
            var.tags,
            {
             Name = format("PrivateSubnet-%s", count.index + 3)
            }
        )
  
  }  

  #create internet gateway 
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.tags,
        {
            Name = format("%s-%s", aws_vpc.main.id, "IG")
        }
    )
  
}

#create eip for nat gateway
resource "aws_eip" "nat_eip" {
    vpc = true
    depends_on = [aws_internet_gateway.ig]
    tags = merge (
        var.tags,
        {
            Name = format("%s-EIP", var.name)
        }
    )
}

#create nat gateway
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = element(aws_subnet.public[*].id, 0)
    depends_on = [aws_internet_gateway.ig]
    
    tags = merge (
        var.tags,
        {
            Name = format("EIP-%s", var.name)
        }
    )
  
}


#create private routes table 
resource "aws_route_table" "private-rtb" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.tags,
        {
            Name = format("%s-private-route-table", var.name)
        }
    )
}

# create a route in the private route table
resource "aws_route" "private-rtb-route" {
    route_table_id = aws_route_table.private-rtb.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id

}

#associate all private-A subnets to the private route table
resource "aws_route_table_association" "private-subnets-assoc-A" {
  count = length(aws_subnet.private-A[*].id)
  subnet_id = element(aws_subnet.private-A[*].id, count.index)
  route_table_id = aws_route_table.private-rtb.id
}

#associate all private-B subnets to the private route table
resource "aws_route_table_association" "private-subnets-assoc-B" {
  count = length(aws_subnet.private-B[*].id)
  subnet_id = element(aws_subnet.private-B[*].id, count.index)
  route_table_id = aws_route_table.private-rtb.id
}

#create route table for the public subnets
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.main.id

  tags = merge (
      var.tags,
      {
          Name = format("%s-public-route-table", var.name)
      }
  )
}

#create route in the public route table
resource "aws_route" "public-rtb-route" {
  route_table_id = aws_route_table.public-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig.id
}

# associate all the public subnets with the public route table
resource "aws_route_table_association" "public-subnets-assoc" {
    count = length(aws_subnet.public[*].id)
    subnet_id = element(aws_subnet.public[*].id, count.index)
    route_table_id = aws_route_table.public-rtb.id
}
