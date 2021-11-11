variable "private_subnet3_id" {
  description = "private subnet3 for data layer"
}

variable "private_subnet4_id" {
  description = "private subnet4 for data layer"
}

variable "master_username" {
  description  = "Root username for the RDS instance"
}

variable "master_password" {
  description = "Root password for the RDS instance"
}

variable "data_layer_sg_id" {
  description = "Security group ID for the datalayer"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
