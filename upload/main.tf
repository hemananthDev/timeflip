provider "aws" {
  region = "ap-south-1"
}

variable "public_key_path" {
  # 👇 Use your Windows path with double backslashes OR a single forward slash
  default = "D:/DevOps_Learning/docs/SSH Key/text-align-key.pub"
}

resource "aws_key_pair" "timeflip_key" {
  key_name   = "timeflip-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "timeflip_sg" {
  name        = "timeflip-sg"
  description = "Allow SSH, HTTP, and Jenkins"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Flask
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Jenkins
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound
  }
}

resource "aws_instance" "timeflip_ec2" {
  ami                         = "ami-0f5ee92e2d63afc18"  # Ubuntu 22.04 LTS - ap-south-1
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.timeflip_key.key_name
  vpc_security_group_ids      = [aws_security_group.timeflip_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "TimeFlip EC2"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > instance_ip.txt"
  }
}
