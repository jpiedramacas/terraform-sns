# Definición del proveedor AWS y región
provider "aws" {
  region = "us-east-1"
}

# Definición del grupo de seguridad para permitir tráfico HTTP y SSH
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

# Definición de la instancia EC2
resource "aws_instance" "web" {
  ami                    = "ami-08a0d1e16fc3f61ea"  # Amazon Linux 2 AMI (HVM)
  instance_type          = "t2.micro"
  key_name               = "vockey"
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
  user_data              = file("install.sh")  # Asegúrate de que este archivo esté presente
  tags = {
    Name = "WebServer"
  }

  # Copiar archivos locales a la instancia EC2
  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("ssh.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "install.sh"
    destination = "/tmp/install.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("ssh.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "info.php"
    destination = "/tmp/info.php"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("ssh.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "submit.php"
    destination = "/tmp/submit.php"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("ssh.pem")
      host        = self.public_ip
    }
  }

  # Ejecutar comandos remotos en la instancia EC2
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/install.sh",    # Dar permisos de ejecución al script
      "sudo /tmp/install.sh",             # Ejecutar el script de instalación
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo mv /tmp/info.php /var/www/html/info.php",
      "sudo mv /tmp/submit.php /var/www/html/submit.php"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("ssh.pem")
      host        = self.public_ip
    }
  }
}

# Definición de la función Lambda
resource "aws_lambda_function" "slack_notification" {
  filename         = "lambda_function.zip"
  function_name    = "slackNotification"
  role             = "arn:aws:iam::533266991023:role/LabRole"  # Reemplaza por el ARN de tu rol local adecuado
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("lambda_function.zip")
}

# Crear la suscripción del SNS al Lambda
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.contact_form_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notification.arn
}

# Crear la suscripción del SNS para el email
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.contact_form_topic.arn
  protocol  = "email"
  endpoint  = "geovanny.piedra@tajamar365.com"
}

# Permisos para que SNS invoque Lambda
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.contact_form_topic.arn
}

# Definir el tema SNS
resource "aws_sns_topic" "contact_form_topic" {
  name = "contact-form-topic"
}

# Output para mostrar la IP de la instancia
output "instance_ip" {
  value = aws_instance.web.public_ip
}

# Output para mostrar el ARN del tema SNS
output "sns_topic_arn" {
  value = aws_sns_topic.contact_form_topic.arn
}
