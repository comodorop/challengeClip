provider "aws" {
  region     = "us-east-1"
  access_key = "AKIATG7SIEFISFMGARWN"
  secret_key = "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"
}

resource "aws_vpc" "clip-vpc" {
  cidr_block           = "172.22.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "clip-vpc"
  }
}

resource "aws_subnet" "clip-prd-subnet-privada-1a" {
  vpc_id            = aws_vpc.clip-vpc.id
  cidr_block        = "172.22.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "clip-prd-subnet-privada-1a"
  }
}

resource "aws_db_subnet_group" "clip_subnet_group" {
  name       = "clip_subnet_group"
  subnet_ids = [aws_subnet.clip-prd-subnet-privada-1a.id, aws_subnet.clip-prd-subnet-privada-1b.id]
  tags = {
    Name = "clip_subnet_group"
  }
}




resource "aws_subnet" "clip-prd-subnet-privada-1b" {
  vpc_id            = aws_vpc.clip-vpc.id
  cidr_block        = "172.22.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "clip-prd-subnet-privada-1b"
  }
}


resource "aws_security_group" "clip-apps" {
  name   = "aplazo-sg-apps"
  vpc_id = aws_vpc.clip-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["172.22.2.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "clip-apps"
  }
}

resource "aws_instance" "clip-ws-prd" {
  ami                         = "ami-09d56f8956ab235b3"
  instance_type               = "t2.micro"
  key_name                    = "clipapp"
  subnet_id                   = aws_subnet.clip-prd-subnet-privada-1b.id
  vpc_security_group_ids      = [aws_security_group.clip-apps.id]
  associate_public_ip_address = false

  root_block_device {
    volume_size = 16
  }

  tags = {
    Name = "clip-ws-prd"
  }

}



resource "aws_security_group" "clip-mysql" {
  name = "clip-mysql"
  description = "RDS  servers (terraform-managed)"
  vpc_id      = aws_vpc.clip-vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "clip-rds" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  name                   = "clipmysql"
  username               = "foo"
  password               = "foobarbaz"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.clip-mysql.id]
  db_subnet_group_name = aws_db_subnet_group.clip_subnet_group.name
}
