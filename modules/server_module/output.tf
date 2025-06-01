output "server_ip" {
  value = aws_instance.server.public_ip 
}

output "jenkins_admin_password" {
  value = length(data.local_file.jenkins_password) > 0 ? data.local_file.jenkins_password[0].content : null
  sensitive = true
}

