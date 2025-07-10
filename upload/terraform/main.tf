provider "aws" {
  region = "ap-south-1"
}

# 🗝️ Key Pair Path
variable "public_key_path" {
  default = "D:/DevOps_Learning/docs/SSH Key/text-align-key.pub"
}

# 🔐 RDS Credentials
variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "Admin12345!"
}

# 🔐 EC2 Key Pair
resource "aws_key_pair" "timeflip_key" {
  key_name   = "timeflip-key"
  public_key = file(var.public_key_path)
}

# 🔒 Security Group for EC2
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

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > instance_ip.txt"
  }

  depends_on = [aws_key_pair.timeflip_key]
}

# 🔒 RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "timeflip-rds-sg"
  description = "Allow MySQL from EC2 only"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.timeflip_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ IAM Role for Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring_role" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# 🛢️ RDS MySQL Instance with Logging & Monitoring
resource "aws_db_instance" "timeflip_db" {
  identifier             = "timeflip-db"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "timeflip"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  deletion_protection    = false

  # 🪵 CloudWatch Logs
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  # 📊 Enhanced Monitoring
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
  monitoring_interval = 60
}

# 📤 Output: EC2 IP
output "ec2_public_ip" {
  value = aws_instance.timeflip_ec2.public_ip
}

# 📤 Output: RDS Endpoint
output "rds_endpoint" {
  value = aws_db_instance.timeflip_db.endpoint
}

# (Optional) Output: Monitoring Role ARN
output "rds_monitoring_role_arn" {
  value = aws_iam_role.rds_monitoring_role.arn
}
