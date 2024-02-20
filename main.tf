terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "my-pvc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "prometheus"
  }
}

# Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-pvc.id
}


# Route table
resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.my-pvc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }
}


# Subnet
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.my-pvc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# 為何 subnet 跟 route table 要 associate 呢？
# 關聯 Route Table 是為了定義和控制子網內的網絡流量路由規則，確保數據在 VPC 中按照你的預期流動。
# associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.my-route-table.id
}

# SG
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.my-pvc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # prometheus
  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # grafana
  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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

  tags = {
    Name = "allow_web"
  }
}

# NIC
# 在AWS中，network interface與subnet跟security group有什麼關係？
# 1.Network Interface 必須與一個特定的 Subnet 相關聯，因為它需要在該 Subnet 中獲得一個 IP 地址。
# 2.Network Interface 通過與 Security Group 相關聯，可以定義哪些流量是允許進入或離開 Network Interface 的。
# NIC跟subnet要一個ip、security group包住一個NIC，NIC去attach到EC2上
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}


# eip
# 在 AWS 中，EIP 與 network interface 和 internet gateway 有何關係？
# EIP 是靜態公開 IP，與私有的 NIC 關聯，使 EC2 有公開的 IP。因為希望與 Internet 通訊，所以也需要配置 Internet gateway。
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

# Server
resource "aws_instance" "prometheus-instance" {
  ami               = var.ami_id
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = var.ami_key_pair_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  #user_data = file("userdata.sh")

  tags = {
    Name = var.ami_name
  }
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}
