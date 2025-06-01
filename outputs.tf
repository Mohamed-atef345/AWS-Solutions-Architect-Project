output "jenkins_admin_password" {
  value = module.jenkins_server.jenkins_admin_password
}

output "jenkins_public_ip" {
  value = module.jenkins_server.server_ip
}

output "prometheus_public_ip" {
  value = module.prometheus_server.server_ip
}

output "jenkins_node0_public_ip" {
  value = module.jenkins_node[0].server_ip
}

output "jenkins_node1_public_ip" {
  value = module.jenkins_node[1].server_ip
}

