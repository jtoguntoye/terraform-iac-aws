# create sns topic for all the autoscaling groups
resource "aws_sns_topic" "kiff-sns" {
  name = "Default_CloudWatch_Alarms_Topic"
}

# create notification for all the autoscaling groups
resource "aws_autoscaling_notification" "kiff-notification" {
  group_names = [
      aws_autoscaling_group.bastion-asg.name,
      aws_autoscaling_group.nginx-asg.name,
      aws_autoscaling_group.wordpress-asg.name,
      aws_autoscaling_group.tooling-asg.name,
  ]
  notifications = [
      "autoscaling:EC2_INSTANCE_LAUNCH",
      "autoscaling:EC2_INSTANCE_TERMINATE",
      "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
      "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.kiff-sns.arn
}



resource "random_shuffle" "az_list" {
  input = var.available_zone_names
}

#--- Autoscaling for bastion hosts
resource "aws_autoscaling_group" "bastion-asg" {
   name = "bastion-asg"
   max_size = 2
   min_size = 1
   health_check_grace_period = 300
   health_check_type = "ELB"
   desired_capacity = 1

   vpc_zone_identifier = [
      var.public_subnet1_id,
       var.public_subnet2_id
   ]

   launch_template {
     id = var.bastion_launch_template_id
     version = "$Latest"
   }
   tag {
       key = "Name"
       value = "bastion-launch-template"
       propagate_at_launch = true
   }
}




# create autoscaling group for nginx
resource "aws_autoscaling_group" "nginx-asg" {
    name = "nginx-asg"
    max_size = 2
    min_size = 1
    health_check_type = "ELB"
    health_check_grace_period = 300
    desired_capacity = 1

    vpc_zone_identifier = [
        var.public_subnet1_id,
        var.public_subnet2_id
    ]

    launch_template {
      id = var.nginx_launch_template_id
      version = "$Latest"
    }

    tag {
      key = "Name"
      value = "nginx-launch-template"
      propagate_at_launch = true
    } 

}


# attach the autoscaling group of nginx to external load balancer
resource "aws_autoscaling_attachment" "asg_attachment_nginx" {
    autoscaling_group_name = aws_autoscaling_group.nginx-asg.id
    alb_target_group_arn = var.nginx_tgt_arn
}




# --- Autoscaling for wordpress application
resource "aws_autoscaling_group" "wordpress-asg" {
    name = "Wordpress-asg"
    max_size = 2
    min_size = 1
    health_check_grace_period = 300
    health_check_type = "ELB"
    desired_capacity = 1
    vpc_zone_identifier = [
       var.private_subnet1_id,
        var.private_subnet2_id
    ]

    launch_template {
      id = var.wordpress_launch_template_id
      version = "$Latest"
    }

    tag{
        key = "Name"
        value = "wordpress-asg"
        propagate_at_launch = true
    }
  
}

# attach wordpress autoscaling group to the internal load balancer
resource "aws_autoscaling_attachment" "asg-attachment-wordpress" {
   autoscaling_group_name = aws_autoscaling_group.wordpress-asg.id
   alb_target_group_arn = var.wordpress_tgt_arn
  
}


# create autoscaling group for tooling webserver
resource "aws_autoscaling_group" "tooling-asg" {
   name = "tooling-asg"
   max_size = 2
   min_size = 1
   health_check_grace_period = 300
   health_check_type = "ELB"
   desired_capacity = 1

   vpc_zone_identifier = [
       var.private_subnet1_id,
       var.private_subnet2_id
   ]

   launch_template {
     id = var.tooling_launch_template_id
     version = "$Latest"
   }

   tag { 
       key = "Name"
       value = "tooling-launch-template"
       propagate_at_launch = true
   }  
}

# attaching tooling autoscaling group to the internal load balancer
resource "aws_autoscaling_attachment" "asg-attachment-tooling" {
    autoscaling_group_name = aws_autoscaling_group.tooling-asg.id
    alb_target_group_arn = var.tooling_tgt_arn  
}

