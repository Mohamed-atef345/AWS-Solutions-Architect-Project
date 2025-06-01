resource "aws_key_pair" "shared_key" {
  key_name   = "shared_server_key"
  public_key = file("~/.ssh/deployer.pub")
}

module "jenkins_server" {
  source = "./modules/server_module"
  server_name = "jenkins"
  script_path = "./scripts/install_java_jenkins.sh"
  allow_web_port = true
  web_port = 8080
  key_name    = aws_key_pair.shared_key.key_name
  use_file_provisioner = false
}
module "prometheus_server" {
  source = "./modules/server_module"
  server_name = "Prometheus"
  script_path = "./scripts/install_docker_prometheus.sh"
  allow_web_port = true
  web_port = 9090
  key_name    = aws_key_pair.shared_key.key_name
  use_file_provisioner = true
  local_file_path      = "./config_files/prometheus.yml"
  remote_file_path     = "/home/ubuntu/prometheus.yml"
}

module "jenkins_node" {
  count = 2
  source = "./modules/server_module"
  server_name = "jenkins_node_${count.index}"
  script_path = "./scripts/install_java.sh"
  allow_web_port = false
  key_name    = aws_key_pair.shared_key.key_name
  use_file_provisioner = false
}


