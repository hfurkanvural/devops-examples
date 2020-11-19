provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Prod"
  }

}
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress = [{
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    "security_groups" : null
    "self" : null
    "ipv6_cidr_blocks" : null
    "prefix_list_ids" : null
    },
    {
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      "security_groups" : null
      "self" : null
      "ipv6_cidr_blocks" : null
      "prefix_list_ids" : null
    },
    {
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      "security_groups" : null
      "self" : null
      "ipv6_cidr_blocks" : null
      "prefix_list_ids" : null
  }]

  egress = [{
    cidr_blocks = ["0.0.0.0/0"]
    description = "egress"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    "security_groups" : null
    "self" : null
    "ipv6_cidr_blocks" : null
    "prefix_list_ids" : null
  }]
  tags = {
    Name = "allow_web"
  }

}
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

resource "aws_eip" "name" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

resource "aws_instance" "web-server-instance" {
  ami               = "ami-0502e817a62226e03"
  instance_type     = "t2.micro"
  availability_zone = "eu-central-1a"
  key_name          = "main-key-pair"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very first web server! > /var/www/html/index.html'
              EOF

  tags = {
    Name = "web-server"
  }
}

output "server_private_ip" {
  value = aws_instance.web-server-instance.private_ip
}
output "server_id" {
  value = aws_instance.web-server-instance.id
}
