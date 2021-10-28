# security group for alb, to allow access from anywhere for  http and https traffic
resource "aws_security_group" "ext-alb-sg" {
  name = var.ext-alb-sg-name
  vpc_id = aws_vpc.main.id
  description = "Allow TLS inbound traffic"

  ingress =  [
      {
    description = "http"
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = [ "0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    },

    {
    description = "https"
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = [ "0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    } 
  ]

   
  
  egress = [
      {
      description = "outgoing"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
  }
  ]

  tags = merge (
      var.tags,
      {
        Name = "ext-alb-sg"  
      },
  )
}

# security group for Bastion, to allow access from your IP to the bastion host
resource "aws_security_group" "bastion-sg" {
    name = "bastion-sg"
    vpc_id = aws_vpc.main.id
    description = "Allow incoming ssh connection"

    ingress = [
        {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        cidr_blocks = [ "0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
        }
    ]    
    
    egress = [
     {
        description = "outgoing"
        from_port = 22
        to_port = 22
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
     }
   ]

    tags = merge (
        var.tags,
        {
            Name = "Bastion-sg"
        }
    )
  
}

# create security group for nginx reverse proxy, to allow access only from the external load balancer
# and Bastion instance
resource "aws_security_group" "nginx-sg" {
    name = "nginx-sg"
    vpc_id = aws_vpc.main.id

    egress = [
        {
        description = "outgoing"    
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = [ "0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    } 
    ]

    tags = merge (
        var.tags,
        {
            Name = "nginx-SG"
        }
    )    
}

# ingress rule to attach to the nginx sg
resource "aws_security_group_rule" "inbound-nginx-https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    source_security_group_id = aws_security_group.ext-alb-sg.id
    security_group_id = aws_security_group.nginx-sg.id
}

#ingress rule to attach to the nginx sg to allow access from bastion
resource "aws_security_group_rule" "inbound-bastion-ssh" {
   type = "ingress"
   from_port = 22
   to_port = 22
   protocol = "tcp"
   source_security_group_id = aws_security_group.bastion-sg.id
   security_group_id = aws_security_group.nginx-sg.id
}

# security group for ialb, to have acces only from nginx reverser proxy server
resource "aws_security_group" "int-alb-sg" {
  name   = "my-alb-sg"
  vpc_id = aws_vpc.main.id

  egress =  [
    {
    description = "outgoing"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false

    }
  ]

  

  tags = merge(
    var.tags,
    {
      Name = "int-alb-sg"
    },
  )

}

resource "aws_security_group_rule" "inbound-ialb-https" {
     type = "ingress"
     from_port = 443
     to_port  = 443
     protocol = "tcp"
     source_security_group_id = aws_security_group.nginx-sg.id
     security_group_id = aws_security_group.int-alb-sg.id
}

# security group for webservers, to have access only from the internal load balancer and bastion instance
resource "aws_security_group" "webserver-sg" {
  name   = "my-asg-sg"
  vpc_id = aws_vpc.main.id

  egress = [
    {
    description = "outgoing"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    }
  ]

  tags = merge(
    var.tags,
    {
      Name = "webserver-sg"
    },
  )

}

resource "aws_security_group_rule" "inbound-web-https" {
  type  = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  source_security_group_id = aws_security_group.int-alb-sg.id
  security_group_id = aws_security_group.webserver-sg.id
}

resource "aws_security_group_rule" "inbound-web-ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = aws_security_group.bastion-sg.id
  security_group_id = aws_security_group.webserver-sg.id
}

# security group for datalayer to allow traffic from webserver to nfs and mysql port 
#and bastion host to mysql port
resource "aws_security_group" "datalayer-sg" {
    name = "datalayer-sg"
    vpc_id = aws_vpc.main.id
    egress = [
        {
        description = "outgoing"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    }
    ]
    tags = merge (
        var.tags,
        {
            Name = "datalayer-sg"
        }
    )
}

resource "aws_security_group_rule" "inbound-nfs-webserver" {
  type = "ingress"
  from_port = 2049
  to_port = 2049
  protocol = "tcp"
  security_group_id = aws_security_group.datalayer-sg.id
  source_security_group_id = aws_security_group.webserver-sg.id
}

resource "aws_security_group_rule" "inbound-nfs-nginx" {
  type = "ingress"
  from_port = 2049
  to_port = 2049
  protocol = "tcp"
  security_group_id = aws_security_group.datalayer-sg.id
  source_security_group_id = aws_security_group.nginx-sg.id
}

resource "aws_security_group_rule" "inbound-mysql-webserver" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = aws_security_group.webserver-sg.id
  security_group_id = aws_security_group.datalayer-sg.id
}

resource "aws_security_group_rule" "inbound-mysql-bastion" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = aws_security_group.bastion-sg.id
  security_group_id = aws_security_group.datalayer-sg.id
}