output "jenkins_admin_password" {
  value = module.jenkins_server.jenkins_admin_password
}

output "jenkins_public_ip" {
  value = module.jenkins_server.server_ip
}

output "prometheus_public_ip" {
  value = module.prometheus_server.server_ip
}
