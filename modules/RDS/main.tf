# create RDS DB subnet resource
resource "aws_db_subnet_group" "kiff-rds" {
    name = "main-db"
    subnet_ids = [var.private_subnet3_id, var.private_subnet4_id]
  
  tags = merge (
      var.tags,
      {
          Name = "kiff-rds"
      }
  )
}

# create RDS instance with the db subnet groups
resource "aws_db_instance" "kiff-rds" {
    allocated_storage = 20
    storage_type = "gp2"
    engine = "mysql"
    engine_version = "5.7"
    instance_class = "db.t2.micro"
    name = "kiffdb"
    username = var.master_username
    password = var.master_password
    parameter_group_name = "default.mysql5.7"
    db_subnet_group_name = aws_db_subnet_group.kiff-rds.name
    skip_final_snapshot = true
    vpc_security_group_ids = [var.data_layer_sg_id]
    multi_az = true 
}