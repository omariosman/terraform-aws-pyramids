

data "aws_vpc" "main" {
  id = "vpc-06f6608585199b584"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.my_pub_key
}



resource "aws_instance" "web" {
  
  ami           = var.ami_value
  instance_type = "t2.small"
  key_name = "${aws_key_pair.deployer.key_name}"
  user_data = data.template_file.user_data.rendered
  vpc_security_group_ids = [aws_security_group.sg_web.id]


  tags = {
    Name = "MyServer"
  }

 
}

data "template_file" "user_data" {
  template = "${file("${path.module}/cloud-config.yaml")}"
}



resource "aws_security_group" "sg_web" {
  name        = "sg_web"
  description = "Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  },
    {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }

]
  egress = [
    { 
    description      = "outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false
  }

]

}



# resource "aws_s3_bucket" "terraform_state" {
#    bucket = "terraform-state-juno"

#    lifecycle {
#      prevent_destroy = true
#    }

#    versioning {
#      enabled = true
#    }

#    server_side_encryption_configuration {
#      rule {
#        apply_server_side_encryption_by_default {
#          sse_algorithm = "AES256"
#        }
#      }
#    }
#  }



#  resource "aws_dynamodb_table" "terraform_locks" {
#    name         = "terraform-state-locking"
#    billing_mode = "PAY_PER_REQUEST" 
#    hash_key     = "LockID"

#    attribute {
#      name = "LockID"
#      type = "S"
#    }
#  }





