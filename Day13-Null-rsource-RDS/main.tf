# ─────────────────────────────────────
# DATA SOURCES
# ─────────────────────────────────────

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# ─────────────────────────────────────
# VPC
# ─────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform-rds-vpc"
  }
}

# ─────────────────────────────────────
# SUBNETS
# ─────────────────────────────────────

# Public Subnet (for EC2)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.18.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet"
  }
}

# Private Subnet 1 (for RDS)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.19.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "terraform-private-subnet-1"
  }
}

# Private Subnet 2 (for RDS - needs 2 AZs)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "terraform-private-subnet-2"
  }
}

# ─────────────────────────────────────
# INTERNET GATEWAY + ROUTE TABLE
# ─────────────────────────────────────

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraform-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "terraform-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ─────────────────────────────────────
# SECURITY GROUPS
# ─────────────────────────────────────

# EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Security group for EC2"
  vpc_id      = aws_vpc.main.id

  # SSH from your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "SSH access"
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-ec2-sg"
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  # MySQL from EC2 only
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
    description     = "MySQL from EC2"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-rds-sg"
  }
}

# ─────────────────────────────────────
# RDS SUBNET GROUP
# ─────────────────────────────────────

resource "aws_db_subnet_group" "main" {
  name       = "terraform-rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "terraform-rds-subnet-group"
  }
}

# ─────────────────────────────────────
# RDS MYSQL INSTANCE
# ─────────────────────────────────────

resource "aws_db_instance" "mysql" {
  identifier        = "terraform-mysql-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Free tier settings
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  multi_az               = false
  backup_retention_period = 1

  tags = {
    Name = "terraform-mysql"
  }
}

# ─────────────────────────────────────
# EC2 INSTANCE
# ─────────────────────────────────────

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.ec2_instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "terraform-bastion"
  }
}

# ─────────────────────────────────────
# NULL RESOURCE WITH PROVISIONERS
# ─────────────────────────────────────

resource "null_resource" "setup_rds" {

  # Trigger when EC2 or RDS changes
  triggers = {
    ec2_id     = aws_instance.bastion.id
    rds_endpoint = aws_db_instance.mysql.endpoint
  }

  # ─────────────────────────────
  # 1. LOCAL-EXEC PROVISIONER
  # Runs on YOUR local machine
  # ─────────────────────────────
  provisioner "local-exec" {
    command = <<-EOT
      echo "============================================"
      echo "Terraform deployment started!"
      echo "EC2 IP: ${aws_instance.bastion.public_ip}"
      echo "RDS Endpoint: ${aws_db_instance.mysql.endpoint}"
      echo "Time: $(date)"
      echo "============================================"

      # Save connection details to local file
      echo "EC2_IP=${aws_instance.bastion.public_ip}" > connection_details.txt
      echo "RDS_ENDPOINT=${aws_db_instance.mysql.address}" >> connection_details.txt
      echo "DB_NAME=${var.db_name}" >> connection_details.txt
      echo "DB_USER=${var.db_username}" >> connection_details.txt

      echo "Connection details saved to connection_details.txt"
    EOT
    interpreter = ["bash", "-c"]
  }

  # ─────────────────────────────
  # 2. FILE PROVISIONER
  # Copies files from local to EC2
  # ─────────────────────────────
  provisioner "file" {
    source      = "scripts/setup.sql"
    destination = "/home/ec2-user/setup.sql"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.bastion.public_ip
    }
  }

  # Copy a shell script too
  provisioner "file" {
    content = <<-EOT
      #!/bin/bash
      echo "Setting up RDS connection..."
      export MYSQL_PWD=${var.db_password}

      # Test connection
      mysql -h ${aws_db_instance.mysql.address} \
            -u ${var.db_username} \
            -e "SELECT VERSION();"

      echo "Connection successful!"
    EOT
    destination = "/home/ec2-user/connect_rds.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.bastion.public_ip
    }
  }

  # ─────────────────────────────
  # 3. REMOTE-EXEC PROVISIONER
  # Runs commands ON EC2
  # ─────────────────────────────
  provisioner "remote-exec" {
    inline = [
      # Install MySQL client
      "sudo yum update -y",
      "sudo yum install -y mysql",

      # Make script executable
      "chmod +x /home/ec2-user/connect_rds.sh",

      # Test RDS connection
      "echo 'Testing RDS connection...'",
      "mysql -h ${aws_db_instance.mysql.address} -u ${var.db_username} -p${var.db_password} -e 'SELECT VERSION();'",

      # Run SQL setup file
      "echo 'Running setup SQL...'",
      "mysql -h ${aws_db_instance.mysql.address} -u ${var.db_username} -p${var.db_password} ${var.db_name} < /home/ec2-user/setup.sql",

      # Verify tables created
      "echo 'Verifying tables...'",
      "mysql -h ${aws_db_instance.mysql.address} -u ${var.db_username} -p${var.db_password} ${var.db_name} -e 'SHOW TABLES;'",

      "echo 'RDS setup complete!'"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.bastion.public_ip
    }
  }

  # Depends on both EC2 and RDS being ready
  depends_on = [
    aws_instance.bastion,
    aws_db_instance.mysql
  ]
}