output "ext-alb-sg-id" {
    value = aws_security_group.ext-alb-sg.id
    description = "Security group for external load balancer"
}

output "int-lb-sg-id" {
    value = aws_security_group.int-alb-sg.id
}

output "data_layer_sg_id" {
    value = aws_security_group.datalayer-sg.id
}

output "bastion_sg_id" {
    value = aws_security_group.bastion-sg.id
}
 
output "nginx_sg_id" {
     value = aws_security_group.nginx-sg.id
 }

output "webserver_sg_id" {
    value = aws_security_group.webserver-sg.id
}

