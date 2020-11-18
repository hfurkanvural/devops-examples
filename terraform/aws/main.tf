provider "aws" {
    region = "eu-central-1"
}

resource "aws_instance" "demo"{
    ami             = "ami-0502e817a62226e03"
    instance_type   =  "t2.micro"

    tags = {
        Name = "ubuntu-demo"
    }
}