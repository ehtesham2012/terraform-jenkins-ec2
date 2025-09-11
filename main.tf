provider "aws" {
  region = var.aws_region
}

locals {
  jenkins_vpc_id   = "vpc-0a720d6537e05bc03"
  public_subnet_id = "subnet-0a977f57c7180c12b"
  public_rtb_id    = "rtb-0e43a2b517662fc9e"
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow SSH and HTTP"
  vpc_id      = local.jenkins_vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP for Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "JenkinsSG"
  }
}

# Optional: manage the association to ensure subnet stays public
# Comment out if association is owned elsewhere to avoid conflicts
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = local.public_subnet_id
  route_table_id = local.public_rtb_id
}

resource "aws_instance" "jenkins_server" {
  ami                         = "ami-0861f4e788f5069dd"
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = local.public_subnet_id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo su
              set -e
              yum update -y
              dnf install -y java-17-amazon-corretto-headless
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
              yum install -y jenkins
              systemctl enable --now jenkins
              EOF

  tags = {
    Name = "JenkinsServer"
  }
}
