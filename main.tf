
# call compute module resource
module "compute"{
    source = "./modules/compute"
    ami                 = var.ami
    bastion-sg          = module.security.bastion_sg_id
    nginx-sg             = module.security.nginx_sg_id
    webserver-sg        = module.security.webserver_sg_id
    keypair             = var.keypair
    bastion_user_data   = filebase64("${path.module}/user-data/bastion.sh")
    nginx_user_data     = filebase64("${path.module}/user-data/nginx.sh")
    wordpress_user_data = filebase64("${path.module}/user-data/wordpress.sh")
    tooling_user_data   = filebase64("${path.module}/user-data/tooling.sh")  
}

module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    enable_classiclink = true
    enable_classiclink_dns_support = false
    public-sn-count = 2
    private-sn-count = 2
    public-cidr =  [for i in range(2) : cidrsubnet(var.vpc_cidr, 8, i+1)]
    private-a-cidr = [for i in range(2) : cidrsubnet(var.vpc_cidr, 8, i+3)]
    private-b-cidr = [for i in range(2) : cidrsubnet(var.vpc_cidr, 8, i+5) ]
    tags = var.tags   
}

# call module for load balancer
module "alb" {
    source = "./modules/alb"
    vpc_id = module.vpc.vpc_id
    ext-alb-sg-id = module.security.ext-alb-sg-id
    int-lb-sg-id = module.security.int-lb-sg-id
    public-subnet1-id = module.vpc.public_subnet1-id
    public-subnet2-id = module.vpc.public_subnet2-id
    private-subnet1-id = module.vpc.private_subnet1-id
    private-subnet2-id = module.vpc.private_subnet2-id
    certificate-arn = module.certificate.certificate-arn
    tags = var.tags    
}

# call module for EFS 
module "efs" {
    source = "./modules/efs"
    tags = var.tags
    private_subnet1_id = module.vpc.private_subnet1-id
    private_subnet2_id = module.vpc.private_subnet2-id
    datalayer_sg_id = module.security.data_layer_sg_id
    account_no = var.account_no    
}

# call Certificate module
module "certificate" {
    source = "./modules/certificate"
    ext_alb_dns_name = module.alb.alb_dns_name
    ext_alb_zone_id = module.alb.ext-alb-zone-id
}

# call RDS module 
module "rds" {
    source = "./modules/RDS" 
    private_subnet3_id = module.vpc.private_subnet3-id
    private_subnet4_id = module.vpc.private_subnet4-id
    master_username = var.master_username
    master_password = var.master_username
    data_layer_sg_id = module.security.data_layer_sg_id
    tags = var.tags
}

# call autoscaling module
module "autoscaling" {
    source = "./modules/autoscaling"
    available_zone_names = module.vpc.availability_zones
    bastion_launch_template_id = module.compute.bastion_launch_template
    nginx_launch_template_id = module.compute.nginx_launch_template
    wordpress_launch_template_id = module.compute.wordpress_launch_template
    tooling_launch_template_id = module.compute.tooling_launch_template
    public_subnet1_id = module.vpc.public_subnet1-id
    public_subnet2_id = module.vpc.public_subnet2-id
    private_subnet1_id = module.vpc.private_subnet1-id  
    private_subnet2_id = module.vpc.private_subnet2-id
    nginx_tgt_arn = module.alb.nginx_tgt_arn
    tooling_tgt_arn = module.alb.tooling_tgt_arn
    wordpress_tgt_arn = module.alb.wordpress_tgt_arn
}

# call security module
 module "security" {
     source = "./modules/security"
     vpc_id = module.vpc.vpc_id    
     tags = var.tags
 }