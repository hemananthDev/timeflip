provider "aws" {
  region = "ap-south-1"
}

# ✅ Step 1: Create Key Pair from Local .pub File
resource "aws_key_pair" "timeflip_key" {
  key_name   = "timeflip-key"
  public_key = file("D:/DevOps_Learning/docs/SSH Key/text-align-key.pub")  # ⚠️ Replace with actual path
}

# ✅ Step 2: Launch EC2 Instance
resource "aws_instance" "timeflip_app" {
  ami           = "ami-0f5ee92e2d63afc18"  # Amazon Linux 2023
  instance_type = "t2.micro"
  key_name      = aws_key_pair.timeflip_key.key_name

  tags = {
    Name = "TimeFlip App EC2"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ../../instance_ip.txt"
  }
}
