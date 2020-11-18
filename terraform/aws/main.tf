provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "demo" {
  ami           = "ami-0502e817a62226e03"
  instance_type = "t2.micro"

  tags = {
    Name = "ubuntu-demo"
  }
}

resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demo"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "demo-subnet"
  }
}
