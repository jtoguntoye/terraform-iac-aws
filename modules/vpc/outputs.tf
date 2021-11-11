output "vpc_id" {
    value = aws_vpc.main.id
}

output "availability_zones" {
    value = data.aws_availability_zones.available.names
}

output "public_subnet1-id" {
    value = aws_subnet.public[0].id
}

output "public_subnet2-id" {
    value = aws_subnet.public[1].id
}

output "private_subnet1-id" {
    value = aws_subnet.private-A[0].id
}

output "private_subnet2-id" {
    value = aws_subnet.private-A[1].id
}

output "private_subnet3-id" {
    value = aws_subnet.private-B[0].id
}

output "private_subnet4-id" {
    value = aws_subnet.private-B[1].id
}