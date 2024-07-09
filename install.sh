#!/bin/bash
# Actualiza los paquetes e instala Apache y PHP
sudo yum update -y && sudo yum upgrade -y
sudo yum install httpd -y
sudo service httpd start
sudo chkconfig httpd on

# Navega al directorio del servidor web
cd /var/www/html

# Instala PHP y extensiones necesarias
sudo yum install php php-cli php-json php-mbstring php-fpm -y

# Instala Composer
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php
sudo php -r "unlink('composer-setup.php');"

# Instala AWS SDK para PHP usando Composer
sudo COMPOSER_ALLOW_SUPERUSER=1 php composer.phar require aws/aws-sdk-php

# Reinicia Apache y PHP-FPM
sudo systemctl restart httpd
sudo systemctl enable httpd
sudo systemctl restart php-fpm
sudo systemctl enable php-fpm
