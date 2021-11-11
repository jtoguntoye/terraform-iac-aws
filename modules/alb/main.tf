#create external load balancer
resource "aws_lb" "ext-alb" {
    name = var.ext-alb
    internal = false
    security_groups = [
        var.ext-alb-sg-id,
    ]

    subnets = [
        var.public-subnet1-id,
        var.public-subnet2-id
    ]

    tags = merge (
        var.tags,
        {
            Name = "kiff-ext-alb"
        },
    )

    ip_address_type = "ipv4"
    load_balancer_type = "application"
}

# create target group for the external alb
resource "aws_lb_target_group" "nginx-tgt" {
  health_check {
    interval  = 10
    path = "/healthstatus"
    protocol = "HTTPS"
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }

  name = "nginx-tgt"
  port = 443
  protocol = "HTTPS"
 target_type = "instance"
 vpc_id = var.vpc_id
}

# create a listener for the target group
resource "aws_lb_listener" "nginx-listener" {
  load_balancer_arn = aws_lb.ext-alb.arn
  port = 443
  protocol = "HTTPS"
  certificate_arn = var.certificate-arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nginx-tgt.arn
  }
}



# create an internal Application Load Balancer for the webservers

resource "aws_lb" "ialb" {
    name = "ialb"
    internal = true
    security_groups = [
        var.int-lb-sg-id
        
    ]

    subnets = [
        var.private-subnet1-id,
        var.private-subnet2-id
    ]

    tags = merge (
        var.tags,
        {
            Name = "kiff-int-LB"
        },
    )
    
    ip_address_type = "ipv4"
    load_balancer_type = "application"
}

#--- create target group for internal LB ---

resource "aws_lb_target_group" "wordpress-tgt" {
    health_check {
      interval  = 10
      path = "/healthstatus"
      protocol = "HTTPS"
      timeout = 5
      healthy_threshold = 5
      unhealthy_threshold = 2
    }

    name = "wordpress-tgt"
    port = 443
    protocol = "HTTPS"
    target_type = "instance"
    vpc_id = var.vpc_id
}

# target group for tooling
resource "aws_lb_target_group" "tooling-tgt" {
    health_check {
      interval = 10
      path = "/healthstatus"
      protocol = "HTTPS"
      timeout = 5
      healthy_threshold = 5
      unhealthy_threshold = 2
    }

    name = "tooling-tgt"
    port = 443
    protocol = "HTTPS"
    target_type = "instance"
    vpc_id = var.vpc_id
}

# ---create a listener for the wordpress target group which will be the default --- 
resource "aws_lb_listener" "web_listener" {
 load_balancer_arn = aws_lb.ialb.arn
 port = 443
 protocol = "HTTPS"
 certificate_arn = var.certificate-arn

 default_action {
   type = "forward"
   target_group_arn = aws_lb_target_group.wordpress-tgt.arn
 }  
}

#configure listener rule for tooling target

resource "aws_lb_listener_rule" "tooling-listener" {
    listener_arn = aws_lb_listener.web_listener.arn
    priority = 99

    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.tooling-tgt.arn
    }

    condition {
      host_header {
          values = ["tooling.kiff-web.space"]
      }
    }
}