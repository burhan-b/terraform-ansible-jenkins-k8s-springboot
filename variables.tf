variable "ami" {
  type    = list(string)
  default = ["ami-00c90dbdc12232b58", "ami-0ec23856b3bad62d3"]
}

variable "sg" {
  default = "Terraform Security Group"
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "cidr_subnet1" {
  description = "CIDR block for the subnet"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "availability zone to create subnet"
  default     = "eu-west-1"
}

variable "az" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

}

variable "subnet_names" {
  type    = list(string)
  default = ["subnet-1", "subnet-2", "subnet-3"]

}

variable "os_names" {
  type    = list(string)
  default = ["Ansible_control_node", "Jenkins", "K8S_Master", "K8S_Slave1", "K8S_Slave2"]

}

variable "environment_tag" {
  description = "Environment tag"
  default     = "Production"

}

variable "instance_type" {
  default = "t2.micro"
}

variable "keypair" {
  default = "ipseckeypair"
}

variable "keypair_public" {
  default = "ipseckeypair.pub"
}

variable "keypair_plain" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXHO4pfqjybB5aEtd0/ln3tek5IZKBEiB4U5bov4Fua2Rkytxlc1ZWgFxhUBFj6du2FOncgIGMFTzRHWpfDru+8mpQTjMOf6zkrqKdPLY/OtHkOjAZ2iZPCozK2gEjztSW0rClD9Wn0gDo0ul3+xIdZ5mWCx0ZdJWkR/YKFoVkCWibHl239OW14gm96Vj9TG1gceKbQxFVsneZw01AxYMLJkXVHomvpgUO2AUJZcqiQYgE3EcCndO2+u01+CyaVcR72hpbbCHqY1Oc8iDSaMX7KUhKW/GeIq5O7k5febgB2gxBdTEfC6adPH0AoilYrWnCXS3xvVGoL7+LdW0PlfIb"
}

variable "private_key" {
  default = "ipseckeypair.pem"
}