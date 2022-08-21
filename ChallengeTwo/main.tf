provider "aws" {
  region     = "us-east-1"
  access_key = "AKIATG7SIEFISFMGARWN"
  secret_key = "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"
}

# ----------------------------------SECTION NETWORK------------------------------------------


resource "aws_vpc" "clipV2-vpc" {
  cidr_block           = "172.23.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "clipV2-vpc"
  }
}

resource "aws_subnet" "clipV2-prd-subnet-privada-1a" {
  vpc_id            = aws_vpc.clipV2-vpc.id
  cidr_block        = "172.23.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "clipV2-prd-subnet-privada-1a"
  }
}

# Subnets
resource "aws_subnet" "clipV2-prd-subnet-public-1b" {
  vpc_id                  = aws_vpc.clipV2-vpc.id
  cidr_block              = "172.23.0.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "clipV2-prd-subnet-public-1b"
  }
}
# Internet gateway
resource "aws_internet_gateway" "clipV2-prd-igw" {
  vpc_id = aws_vpc.clipV2-vpc.id
  tags = {
    Name = "clipV2-prd-igw"
  }
}
# Elastic Ip
resource "aws_eip" "clipV2-nat-gateway" {
  vpc = true
  tags = {
    Name = "clipV2-nat-gateway"
  }
}
# Nat Gateway
resource "aws_nat_gateway" "cliV2-nat-gateway" {
  allocation_id = aws_eip.clipV2-nat-gateway.id
  subnet_id     = aws_subnet.clipV2-prd-subnet-public-1b.id
  tags = {
    Name = "cliV2-nat-gateway"
  }
  depends_on = [aws_internet_gateway.clipV2-prd-igw]
}

# RouteTable
resource "aws_route_table" "clipV2-prd-rt-publica" {
  vpc_id = aws_vpc.clipV2-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.clipV2-prd-igw.id
  }
  tags = {
    Name = "clipV2-prd-rt-publica"
  }
}

resource "aws_route_table" "clipV2-prd-rt-privada" {
  vpc_id = aws_vpc.clipV2-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.cliV2-nat-gateway.id
  }
  tags = {
    Name = "clipV2-prd-rt-privada"
  }
}

resource "aws_route_table_association" "clipV2-prd-rta-publica-1a" {
  subnet_id      = aws_subnet.clipV2-prd-subnet-public-1b.id
  route_table_id = aws_route_table.clipV2-prd-rt-publica.id
}

resource "aws_route_table_association" "clipV2-prd-rta-private-1a" {
  subnet_id      = aws_subnet.clipV2-prd-subnet-privada-1a.id
  route_table_id = aws_route_table.clipV2-prd-rt-privada.id
}

# -----------------------------------------------------------------------------------------------------------

# Security Groups
resource "aws_security_group" "clip-apps" {
  name   = "aplazo-sg-apps"
  vpc_id = aws_vpc.clipV2-vpc.id
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

resource "aws_instance" "clip-ws-private" {
  ami                         = "ami-09d56f8956ab235b3"
  instance_type               = "t2.micro"
  key_name                    = "clipapp"
  subnet_id                   = aws_subnet.clipV2-prd-subnet-privada-1a.id
  vpc_security_group_ids      = [aws_security_group.clip-apps.id]
  associate_public_ip_address = false

  root_block_device {
    volume_size = 16
  }

  tags = {
    Name = "clip-ws-prd"
  }
}

resource "aws_instance" "clip-web-public" {
  ami                         = "ami-09d56f8956ab235b3"
  instance_type               = "t2.micro"
  key_name                    = "clipapp"
  subnet_id                   = aws_subnet.clipV2-prd-subnet-public-1b.id
  vpc_security_group_ids      = [aws_security_group.clip-apps.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 16
  }

  tags = {
    Name = "clip-web-public"
  }

}

# ---------------------RSDS SECTION----------------------

resource "aws_security_group" "clip-mysql" {
  name        = "clip-mysql"
  description = "Mysql servers (terraform-managed)"
  vpc_id      = aws_vpc.clipV2-vpc.id

  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
  db_name                = "clipmysql"
  username               = "foo"
  password               = "foobarbaz"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.clip-mysql.id]
  db_subnet_group_name   = aws_db_subnet_group.clip_subnet_group.name
}


resource "aws_db_subnet_group" "clip_subnet_group" {
  name       = "clip_subnet_group"
  subnet_ids = [aws_subnet.clipV2-prd-subnet-privada-1a.id, aws_subnet.clipV2-prd-subnet-public-1b.id]
  tags = {
    Name = "clip_subnet_group"
  }
}
