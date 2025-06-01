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


resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_${var.server_name}"
  description = "Allow ssh inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_ssh_${var.server_name}"
  }
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
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
  from_port         = "${var.web_port}"
  ip_protocol       = "tcp"
  to_port           = "${var.web_port}"
}


resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "${var.server_name}_server"
  }

}

resource "null_resource" "copy_file" {
  
  count = var.use_file_provisioner ? 1 : 0

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("~/.ssh/deployer")
    host     = aws_instance.server.public_ip
  }
  provisioner "file" {
    source      = var.local_file_path
    destination = var.remote_file_path
  }

  depends_on = [ aws_instance.server ]

}

resource "null_resource" "exexute_scripts" {
  
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("~/.ssh/deployer")
    host     = aws_instance.server.public_ip
  }

  provisioner "remote-exec" {
    script = "${var.script_path}"
  }

  depends_on = [ null_resource.copy_file ]

}

resource "null_resource" "fetch_jenkins_admin_password" {
  count = var.server_name == "jenkins" ? 1 : 0

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ~/.ssh/deployer ubuntu@${aws_instance.server.public_ip}:/home/ubuntu/initialAdminPassword ."
  }
  depends_on = [null_resource.exexute_scripts]
}

data "local_file" "jenkins_password" {
  count = var.server_name == "jenkins" ? 1 : 0
  filename = "./initialAdminPassword"
  depends_on = [null_resource.fetch_jenkins_admin_password]
}

