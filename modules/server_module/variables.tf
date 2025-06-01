variable "server_name" {
  
}

variable "script_path" {
  
}

variable "web_port" {
  default = ""
  
}

variable "key_name" {
  type = string

}

variable "use_file_provisioner" {
  type = bool
  default = false
}

variable "local_file_path" {
  type = string
  default = ""
}

variable "remote_file_path" {
  type = string
  default = ""
}

variable "allow_web_port" {
  default = false
}



