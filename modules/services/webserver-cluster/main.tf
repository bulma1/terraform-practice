provider "aws" {
  region = "us-west-2"
}
resource "aws_launch_template" "example" {
  image_id                = "ami-0b8c6b923777519db" #Amazon Linux 2023
  instance_type           = var.instance_type
  vpc_security_group_ids  =  [aws_security_group.instance.id]
  user_data               = base64encode(templatefile("${path.module}/user-data.sh",{
    server_port           = var.server_port
    db_address            = data.terraform_remote_state.db.outputs.address
    db_port               = data.terraform_remote_state.db.outputs.port
  }))

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}
# Reference a specific VPC by its ID
data "aws_vpc" "specific_vpc" {
  id = "vpc-02047e08709c4f64a"  # Your specific VPC ID
}
# Reference subnets within the specific VPC
data "aws_subnets" "specific_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.specific_vpc.id]  # Reference the specific VPC ID
  }
}
resource "aws_autoscaling_group" "example" {
  launch_template {
    id = aws_launch_template.example.id
    version = "$Latest"
  } 
  # vpc_zone_identifier = data.aws_subnets.default.ids
  vpc_zone_identifier = data.aws_subnets.specific_subnets.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size
  tag {
    key = "Name"
    value = var.cluster_name
    propagate_at_launch = true
  }
}
resource "aws_lb" "example" {
  name = var.alb_name
  load_balancer_type = "application"
  subnets = data.aws_subnets.specific_subnets.ids
  security_groups = [aws_security_group.alb.id]
}
resource "aws_lb_listener" "http" {

  load_balancer_arn   = aws_lb.example.arn
  port                = local.http_port
  protocol            = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
      }
    }

  }
resource "aws_security_group" "instance" {
  name = "$(var.cluster_name)-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   
}
resource "aws_lb_target_group" "asg" {
  name = var.alb_name

  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.specific_vpc.id 
  
  health_check {
    path                    = "/"
    protocol                = "HTTP"
    matcher                 = "200"
    interval                = 15
    timeout                 = 3
    healthy_threshold       = 2
    unhealthy_threshold     = 2
  }
}
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
resource "aws_security_group" "alb" {
  name = "$(var.cluster_name)-alb"
}
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    # bucket = "tf-up-and-running-state-example"
    # key = "stage/data-stores/mysql/terraform.tfstate"
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-west-2"
  }
  
}
locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}