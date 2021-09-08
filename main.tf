provider "aws" {
  profile = "default"
  region = "us-east-1"
}

# Moving my state file to s3 bucket
terraform {
   backend "s3" {
   bucket = "austiobioma"
   key    = "devops/state.tfstate"
   region = "us-east-1"
}
}

# Defining variables
variable "my-ami" {
  default ="ami-0c2b8ca1dad447f8a"
}
variable "ec2-size" {
  default = "t2.micro"
}
# this will create a vpc tagged main with the cidr block stated below
resource "aws_vpc" "main" {
  cidr_block     = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}
# This will create an elastic ip for your vpc
resource "aws_eip" "my-eip" {
  
  vpc      = true
}
# this will create an Internet Gateway for our vpc
resource "aws_internet_gateway" "gateway" {
  vpc_id       = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}
# This will create a public subnet in our vpc
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}
#This will create a public route table
resource "aws_route_table" "public" {
  vpc_id                  = aws_vpc.main.id
  
  tags = {
    Name        = "public"
    }
}
# Asssociating public subnet to RT
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
# Associating pub subnet to IGW
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}
# This will create a private subnet
resource "aws_subnet" "private" {
  vpc_id       = aws_vpc.main.id
  cidr_block   = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private"
  }
}
#This will create a private route table
resource "aws_route_table" "private-route" {
  vpc_id                  = aws_vpc.main.id
  tags = {
    Name        = "private-route"
    }
}
# This will create a nat GW in the public subnet
resource "aws_nat_gateway" "my-nat-gw" {
  allocation_id = aws_eip.my-eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gateway]
}
#This will associate ur private routing table to ur private subnet
resource "aws_route_table_association" "private-route" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private-route.id
}
#This will attach ur nat-gateway to the private route
resource "aws_route" "my-nat-gw" {
  route_table_id         = aws_route_table.private-route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my-nat-gw.id
}
# This will create Security Group for our vpc
resource "aws_security_group" "web-sg" {
  name = "web-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# This will create two ec2 in our public subnet
resource "aws_instance" "austin-ec2" {
  ami = var.my-ami
  instance_type = var.ec2-size
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  count = 2
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true

  tags = {
      "Name" = "Terraform-Jenkins"
  }
  # This will create two ec2 in our private subnet
}
  resource "aws_instance" "austin12-ec2" {
  ami = var.my-ami
  instance_type = var.ec2-size
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  count = 2
  subnet_id = aws_subnet.private.id
  associate_public_ip_address = false

  tags = {
      "Name" = "Terraform-Jenkins2" 
  }
  }
