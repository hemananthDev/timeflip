provider "aws" {
  region = "ap-south-1"
}

# 🗝️ Key Pair Path (Make sure this is valid from your system context)
variable "public_key_path" {
  default = "D:/DevOps_Learning/docs/SSH Key/text-align-key.pub"
}

# 🔐 EC2 Key Pair
resource "aws_key_pair" "timeflip_key" {
  key_name   = "timeflip-key"
  public_key = file(var.public_key_path)
}

# 🔒 Security Group
resource "aws_security_group" "timeflip_sg" {
  name        = "timeflip-sg"
  description = "Allow SSH, Flask, and Jenkins"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask App"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 💻 EC2 Instance
resource "aws_instance" "timeflip_ec2" {
  ami                         = "ami-0f5ee92e2d63afc18"  # Ubuntu 22.04 in ap-south-1
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.timeflip_key.key_name
  vpc_security_group_ids      = [aws_security_group.timeflip_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "TimeFlip EC2"
  }

  # 📝 Output public IP to file
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > instance_ip.txt"
  }

  # Optional: Ensure instance is created only after the key is uploaded
  depends_on = [aws_key_pair.timeflip_key]
}
