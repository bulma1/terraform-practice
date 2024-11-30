provider "aws" {
  region = "us-west-2"
}
resource "aws_db_instance" "example" {
  identifier_prefix = "tf-up-and-running"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t3.micro"
  skip_final_snapshot = true
  db_name = "example_database"

  username = var.db_username
  password = var.db_password
}

terraform {
  backend "s3" {
    bucket = "tf-up-and-running-state-example"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-west-2"

    dynamodb_table = "tf-up-and-running-locks"
    encrypt = true
  }
}