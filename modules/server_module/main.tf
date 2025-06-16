provider "aws" {
  region = "us-east-1"
}

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "jenkins-prometheus"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "jenkins-prometheus-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins-prometheus-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "jenkins-prometheus-rt"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_${var.server_name}"
  description = "Allow SSH and web traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_ssh_${var.server_name}"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_port" {
  count = var.allow_web_port ? 1 : 0
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.web_port
  ip_protocol       = "tcp"
  to_port           = var.web_port
}

resource "aws_instance" "server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.server_name}_server"
  }
}

resource "null_resource" "copy_file" {
  count = var.use_file_provisioner ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/deployer")
    host        = aws_instance.server.public_ip
  }

  provisioner "file" {
    source      = var.local_file_path
    destination = var.remote_file_path
  }

  depends_on = [aws_instance.server]
}

resource "null_resource" "exexute_scripts" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/deployer")
    host        = aws_instance.server.public_ip
  }

  provisioner "remote-exec" {
    script = var.script_path
  }

  depends_on = [null_resource.copy_file]
}

resource "null_resource" "fetch_jenkins_admin_password" {
  count = var.server_name == "jenkins" ? 1 : 0

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ~/.ssh/deployer ubuntu@${aws_instance.server.public_ip}:/home/ubuntu/initialAdminPassword ."
  }

  depends_on = [null_resource.exexute_scripts]
}

data "local_file" "jenkins_password" {
  count    = var.server_name == "jenkins" ? 1 : 0
  filename = "./initialAdminPassword"

  depends_on = [null_resource.fetch_jenkins_admin_password]
}
