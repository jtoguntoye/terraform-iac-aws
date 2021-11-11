variable "tags" {
  type = map(string)
}

variable "private_subnet1_id" {
  description = "private subnet1 for mount target of EFS"
}

variable "datalayer_sg_id" {
  description = "security group for datalayer"
}

variable "private_subnet2_id" {
  description = "private subnet2 for mount target of EFS"
}

variable "account_no" {
  description = "AWS organization account number "
}