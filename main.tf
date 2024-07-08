provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/ssh.pem")
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-08a0d1e16fc3f61ea" # Amazon Linux 2 AMI (HVM)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
  user_data              = file("./install.sh")
  tags = {
    Name = "WebServer"
  }

  provisioner "file" {
    source      = "./index.html"  # Ruta local del archivo index.html
    destination = "/tmp/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/ssh.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "sudo /tmp/install.sh",
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo mv /tmp/info.php /var/www/html/info.php",
      "sudo mv /tmp/submit.php /var/www/html/submit.php",
      "sudo systemctl restart httpd",
      "sudo systemctl restart php-fpm"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./ssh.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_sns_topic" "contact_form_topic" {
  name = "contact-form-topic"
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}

output "sns_topic_arn" {
  value = aws_sns_topic.contact_form_topic.arn
}
