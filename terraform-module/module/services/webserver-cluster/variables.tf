variable "server_port" {
    description = "The port the server will use for HTTP request"
    type        = number
    default     = 8080
}
variable "alb_name" {
  description = "The name of the ALB"
  type        = string
  default     = "terraform-asg-example"
}

variable "instance_security_group_name" {
  description = "The name of the security group for the EC2 Instances"
  type        = string
  default     = "terraform-example-instance"
}

variable "alb_security_group_name" {
  description = "The name of the security group for the ALB"
  type        = string
  default     = "terraform-example-alb"
}
variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}
# variable "db_remote_state_bucket" {
#   description = "The name of the S3 bucket for the database's remote state"
#   type = string
# }
# variable "db_remote_state_key" {
#   description = "The path for the database's remote state in S3"
#   type = string
# }