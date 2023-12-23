terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "ssh_key_path" {
    type = string
}

data "tls_public_key" "from_pem" {
  private_key_openssh = file("${var.ssh_key_path}")
}

resource "aws_key_pair" "dev" {
  key_name   = "vicuna"
  public_key = data.tls_public_key.from_pem.public_key_openssh
}

locals {
  region = "sa-east-1"

  # instance_type = "t3.xlarge"
  instance_type = "m5.8xlarge"
  
  # gnd famyly are powered by NVIDIA T4 GPU
  # instance_type = "g4dn.12xlarge"
  # instance_type = "g4dn.8xlarge"

  models_path = "/dev/sdh"
  
  # us-east-1
  # linux_ami_for_region =  "ami-053b0d53c279acc90"
  
  # sa-east-1
  linux_ami_for_region = "ami-0af6e9042ea5a4e3e"


}

resource "aws_ebs_volume" "vicuna_model" {
  availability_zone = "${local.region}a"
  size              = 40

  tags = {
    Name = "vicuna_model"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = local.models_path
  volume_id   = aws_ebs_volume.vicuna_model.id
  instance_id = aws_instance.web.id
}


resource "aws_instance" "web" {
  ami = local.linux_ami_for_region
  instance_type = local.instance_type

  availability_zone = "${local.region}a"
  key_name = resource.aws_key_pair.dev.key_name

  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
  }

  user_data_base64 = base64encode(
    templatefile(
      "${path.module}/user_data.tpl.sh", {
        models_path = local.models_path
    })
  )
  tags = {
    Name = "vicuna"
  }
}

output "public_id" {
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  value       = aws_instance.web.public_dns
}


output "chat_url" {
  value       = "${aws_instance.web.public_dns}:{12000}"
}




