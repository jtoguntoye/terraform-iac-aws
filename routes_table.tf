#create private routes table 
resource "aws_route_table" "private-rtb" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.tags,
        {
            Name = format("%s-private-route-table", var.private-rtb-name)
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
          Name = format("%s-public-route-table", var.public-rtb-name)
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

