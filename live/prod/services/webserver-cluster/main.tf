provider "aws" {
  region = "us-west-2"
}

module "webserver_cluster" {
  source = "../../modules/services/webserver-cluster"
  
  cluster_name = "webservers-prod"
  db_remote_state_bucket = "tf-up-and-running-state-example"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"
  instance_type = "t2.micro"
  min_size = 2
  max_size = 10
}
#increase the number of servers to 10 at 9 a.m. every day
resource "aws_autoscaling_schedule" "scale_out_in_morning" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}
#decrease the number of servers at night at 5 p.m everyday 
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}
