provider "aws" {
    region = "us-west-2"  
}
resource "aws_instance" "example" {
  ami = "ami-0b8c6b923777519db"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-example"
  }
}