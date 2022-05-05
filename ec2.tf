resource "aws_vpc" "vpc" {
  count                = terraform.workspace == "aws_prod" ? 1 : 0
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = {
    Environment = "${var.environment_tag}"
    Name        = "TerraformVpc"
  }
}

resource "aws_subnet" "subnet_public1" {
  count                   = terraform.workspace == "aws_prod" ? 1 : 0
  vpc_id                  = aws_vpc.vpc[count.index].id
  cidr_block              = var.cidr_subnet1
  map_public_ip_on_launch = "true"
  availability_zone       = element(var.az, count.index)
  tags = {
    Environment = "${var.environment_tag}"
    Name        = element(var.subnet_names, count.index)
  }

}

resource "aws_security_group" "TerraformSG" {
  count  = terraform.workspace == "aws_prod" ? 1 : 0
  name   = "TerraformSG"
  vpc_id = aws_vpc.vpc[count.index].id

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "${var.environment_tag}"
    Name        = "TerraformSG"
  }
}

resource "aws_internet_gateway" "gw" {
  count  = terraform.workspace == "aws_prod" ? 1 : 0
  vpc_id = aws_vpc.vpc[count.index].id

  tags = {
    Name = "Terraform_IG"
  }
}

resource "aws_route_table" "r" {
  count  = terraform.workspace == "aws_prod" ? 1 : 0
  vpc_id = aws_vpc.vpc[count.index].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[count.index].id
  }
  tags = {
    Name = "TerraformRouteTable"
  }
}

resource "aws_route_table_association" "public" {
  count          = terraform.workspace == "aws_prod" ? 1 : 0
  subnet_id      = aws_subnet.subnet_public1[count.index].id
  route_table_id = aws_route_table.r[count.index].id
}

resource "aws_instance" "ansiblecn" {
  count = terraform.workspace == "aws_prod" ? 1 : 0

  ami           = var.ami[0]
  instance_type = var.instance_type

  availability_zone      = element(var.az, count.index)
  subnet_id              = aws_subnet.subnet_public1[count.index].id
  vpc_security_group_ids = [aws_security_group.TerraformSG[count.index].id]
  key_name               = var.keypair
  tags = {
    Environment = var.environment_tag
    Name        = var.os_names[0]

  }
}

resource "aws_instance" "jenkins" {
  count = terraform.workspace == "aws_prod" ? 1 : 0

  ami           = var.ami[0]
  instance_type = var.instance_type

  availability_zone      = element(var.az, count.index)
  subnet_id              = aws_subnet.subnet_public1[count.index].id
  vpc_security_group_ids = [aws_security_group.TerraformSG[count.index].id]
  key_name               = var.keypair
  tags = {
    Environment = var.environment_tag
    Name        = var.os_names[1]

  }
}

resource "aws_instance" "master" {
  count = terraform.workspace == "aws_prod" ? 1 : 0

  ami           = var.ami[0]
  instance_type = var.instance_type

  availability_zone      = element(var.az, count.index)
  subnet_id              = aws_subnet.subnet_public1[count.index].id
  vpc_security_group_ids = [aws_security_group.TerraformSG[count.index].id]
  key_name               = var.keypair
  tags = {
    Environment = var.environment_tag
    Name        = var.os_names[2]

  }
}

resource "aws_instance" "slave1" {
  count = terraform.workspace == "aws_prod" ? 1 : 0

  ami           = var.ami[0]
  instance_type = var.instance_type

  availability_zone      = element(var.az, count.index)
  subnet_id              = aws_subnet.subnet_public1[count.index].id
  vpc_security_group_ids = [aws_security_group.TerraformSG[count.index].id]
  key_name               = var.keypair
  tags = {
    Environment = var.environment_tag
    Name        = var.os_names[3]

  }
}

resource "aws_instance" "slave2" {
  count = terraform.workspace == "aws_prod" ? 1 : 0

  ami           = var.ami[0]
  instance_type = var.instance_type

  availability_zone      = element(var.az, count.index)
  subnet_id              = aws_subnet.subnet_public1[count.index].id
  vpc_security_group_ids = [aws_security_group.TerraformSG[count.index].id]
  key_name               = var.keypair
  tags = {
    Environment = var.environment_tag
    Name        = var.os_names[4]
  }
}

resource "local_file" "inventory" {
    content  = <<EOF
[ec2]
ansiblecn ansible_host=${aws_instance.ansiblecn[0].public_ip} #ansible_user=ec2-user
jenkins ansible_host=${aws_instance.jenkins[0].public_ip}
master ansible_host=${aws_instance.master[0].public_ip}
slave1 ansible_host=${aws_instance.slave1[0].public_ip}
slave2 ansible_host=${aws_instance.slave2[0].public_ip}
    EOF
    filename = "inventory"

    depends_on = [
      aws_instance.ansiblecn,
      aws_instance.jenkins,
      aws_instance.master,
      aws_instance.slave1,
      aws_instance.slave2
    ]
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [local_file.inventory]

  create_duration = "60s"
}

resource "null_resource" "run_playbook" {

  #provisioner "remote-exec" {
  #  inline = ["echo Done!"]
#
  #  connection {
  #    host        = aws_instance.ansiblecn[0].public_ip
  #    type        = "ssh"
  #    user        = "ubuntu"
  #    #password    = "passwd"
  #    #host_key    = "${var.private_key}"
  #    #host_key    = "${file(var.keypair_public)}"
  #    agent       = false
  #    private_key = "${file(var.private_key)}"
  #    timeout     = "2m"
  #  }
  #}
#
  #provisioner "remote-exec" {
  #  inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]
#
  #  connection {
  #    host        = aws_instance.jenkins[0].private_ip
  #    type        = "ssh"
  #    user        = "ubuntu"
  #    private_key = "${file(var.private_key)}"
  #  }
  #}
#
  #provisioner "remote-exec" {
  #  inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]
#
  #  connection {
  #    host        = aws_instance.master[0].private_ip
  #    type        = "ssh"
  #    user        = "ubuntu"
  #    private_key = file(var.private_key)
  #  }
  #}
#
  #provisioner "remote-exec" {
  #  inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]
#
  #  connection {
  #    host        = aws_instance.slave1[0].private_ip
  #    type        = "ssh"
  #    user        = "ubuntu"
  #    private_key = file(var.private_key)
  #  }
  #}
#
  #provisioner "remote-exec" {
  #  inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]
#
  #  connection {
  #    host        = aws_instance.slave2[0].private_ip
  #    type        = "ssh"
  #    user        = "ubuntu"
  #    private_key = file(var.private_key)
  #  }
  #}
  
  provisioner "local-exec" {
	    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory configure.yml"
	}
  
  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

output "ansiblecn" {
  value = aws_instance.ansiblecn[*].public_ip
}

output "jenkins" {
  value = aws_instance.jenkins[*].public_ip
}

output "master" {
  value = aws_instance.master[*].public_ip
}

output "slave1" {
  value = aws_instance.slave1[*].public_ip
}

output "slave2" {
  value = aws_instance.slave2[*].public_ip
}