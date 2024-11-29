resource "aws_instance" "example" {
    ami           = "ami-055e3d4f0bbeb5878"
    instance_type = "t2.micro"
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "tf-up-and-running-state-example"
    key            = "workspaces-example/terraform.tfstate"
    region         = "us-west-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "tf-up-and-running-locks"
    encrypt        = true
  }
}