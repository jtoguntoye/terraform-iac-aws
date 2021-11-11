variable "ext-alb" {
    type = string
    description = "Name of external load balancer" 
    default = "ext-alb"
}

variable "ext-alb-sg-id" {
    description = "Security group for the external load balancer"
}

variable "int-lb-sg-id" {
  description = "Security group for the internal load balancer"
}

variable "vpc_id" {}


variable "public-subnet1-id" {
}

variable "public-subnet2-id" {}

variable "private-subnet1-id"{}

variable "private-subnet2-id" {}


variable "tags" {
     description = "A mapping of tags to assign to all resources."
     type        = map(string)
}

variable "certificate-arn"{
    description = "TLS certificate to be used by the external and internal load balancers "
}

