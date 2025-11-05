#VPC+SUBNET

resource "aws_vpc" "main" {
 cidr_block = var.vpc_cidr
}
resource "aws_subnet" "private_subnet" {
 vpc_id = aws_vpc.main.id
 cidr_block = var.private_subnet_cidr
 availability_zone = "ap-south-1a"
 map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet" {
 vpc_id = aws_vpc.main.id
 cidr_block = var.public_subnet_cidr
 availability_zone = "ap-south-1b"
 map_public_ip_on_launch = true
}

resource "aws_route_table" "rt"{
 vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private_association" {
 route_table_id = aws_route_table.rt.id
 subnet_id = aws_subnet.private_subnet.id
}

resource "aws_route_table_association" "public_association" {
 route_table_id = aws_route_table.rt.id
 subnet_id = aws_subnet.public_subnet.id
}
resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.main.id
}
resource "aws_eip" "nat" {
 domain = "vpc" 
}
resource "aws_nat_gateway" "nat" {
 allocation_id = aws_eip.nat.id
 subnet_id = aws_subnet.public_subnet.id
 depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "public_internet_access" {
 route_table_id = aws_route_table.rt.id
 destination_cidr_block = "0.0.0.0/0"
 gateway_id = aws_internet_gateway.igw.id
}

#SECURITY GROUPS
#WEB TIER

resource "aws_security_group" "web_sg" {
 name = "web-sg"
 vpc_id = aws_vpc.main.id
 description = "allow SSH and HTTP from internet"
 ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
 ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}

#DB TIER

resource "aws_security_group" "db_tier" {
 name = "db-tier"
 vpc_id = aws_vpc.main.id
 description = "Allow mySQL from web SG"

ingress {
 from_port = 3306
 to_port = 3306
 protocol = "tcp"
 security_groups = [aws_security_group.web_sg.id]
}
egress {
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
}
}

#LAUNCH TEMPLATE FOR ASG:

resource "aws_launch_template" "web_lt" {
  name_prefix = "web-lt"
  image_id = "ami-052cef05d01020f1d"
  instance_type = var.instance_type
  key_name = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [ aws_security_group.web_sg.id]
}
user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "<h1>Welcome to auto scaling web tier</h1>"> /var/www/html/index.html
EOF
)
}
#Auto scaling group:

resource "aws_autoscaling_group" "web_asg" {
 desired_capacity = 2
 max_size = 3
 min_size = 1
 vpc_zone_identifier = [aws_subnet.public_subnet.id]
 health_check_type ="EC2"
 health_check_grace_period = 120

 launch_template {
  id = aws_launch_template.web_lt.id
  version = "$Latest"
}
 depends_on = [aws_lb_target_group.web_tg]

}

#Application load balancer

resource "aws_lb" "alb" {
 name = "two-tier-alb"
 internal = false 
 load_balancer_type = "application"
 security_groups = [aws_security_group.web_sg.id]
 subnets = [aws_subnet.public_subnet.id ,aws_subnet.private_subnet.id]
}

resource "aws_lb_target_group" "web_tg" {
 name = "web-tg"
 port = 80
 protocol = "HTTP"
 vpc_id = aws_vpc.main.id
 health_check {
  path = "/"
}
}
resource "aws_lb_listener" "web_listener" {
 load_balancer_arn = aws_lb.alb.arn
 port = 80
 protocol = "HTTP"

 default_action {
  type = "forward" 
  target_group_arn = aws_lb_target_group.web_tg.arn
  }
}  

resource "aws_autoscaling_attachment" "asg_lb_attachment" {
 autoscaling_group_name = aws_autoscaling_group.web_asg.name
 lb_target_group_arn = aws_lb_target_group.web_tg.arn
}

#RDS database

resource "aws_db_subnet_group" "db_subnet_group" {
 name = "db-subnet-group"
 subnet_ids = [aws_subnet.private_subnet.id,aws_subnet.public_subnet.id]
}

resource "aws_db_instance" "db" {
 identifier = "mydb"
 engine = "mysql"
 instance_class = "db.t3.micro"
 allocated_storage = 20
 username = var.db_username
 password = var.db_password
 db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
 vpc_security_group_ids = [aws_security_group.db_tier.id]
 skip_final_snapshot = true
 publicly_accessible = false
}

#Route 53 record

data "aws_route53_zone" "selected" {
 name = var.domain_name
 count = var.domain_name == "" ? 0:1
 private_zone = false
}

resource "aws_route53_record" "alb_record" {
 count = var.domain_name == "" ? 0:1
 zone_id = data.aws_route53_zone.selected[0].zone_id
 name = "app.${var.domain_name}"
 type = "A"

 alias {
  name = aws_lb.alb.dns_name
  zone_id = aws_lb.alb.zone_id
  evaluate_target_health = true
}
}
