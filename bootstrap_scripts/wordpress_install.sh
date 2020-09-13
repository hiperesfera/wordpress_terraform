#!/bin/bash
sudo apt update
sudo apt install -y nginx
sudo apt install -y mariadb-server mariadb-client
sudo apt install -y php php-mysql php-fpm
sudo apt install -y sendmail mailutils

#removing apache2
sudo systemctl stop apache2
sudo apt purge apache2* -y
sudo apt-get autoremove -y

#get php-fpm version
php_fpm_version=$(systemctl list-units --type service | grep php | awk '{print $1}')
php_fpm_socket="/var/run/php/$${php_fpm_version%.*}.sock"

sudo cat > /etc/nginx/sites-enabled/default <<-_EOF
server {
    listen 80 default_server;
    root /var/www/html/wordpress;
    server_name localhost;
    index index.php;
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
    location / {
        try_files \$uri \$uri/ /index.php?$args;
    }
    location ~* ^/xmlrpc.php$ {
  	    deny all;
  	}
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$${php_fpm_socket};
    }
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }
}
_EOF

#install wordpress app and cli
#wget -c http://wordpress.org/latest.tar.gz -P /tmp/
#sudo tar -xzvf /tmp/latest.tar.gz -C /var/www/html/
wget -c https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp/
sudo chmod +x /tmp/wp-cli.phar
sudo mv /tmp/wp-cli.phar /usr/local/bin/wp
#sudo mkdir /var/www/html/wordpress
sudo WP_CLI_CACHE_DIR=/tmp/ wp core download --allow-root --path=/var/www/html/wordpress
#permissions
chown -R www-data.www-data /var/www/html

# enabling and restarting services
sudo systemctl is-enabled nginx
sudo systemctl is-enabled mariadb
sudo systemctl is-enabled $php_fpm_version
sudo systemctl restart nginx
sudo systemctl restart mariadb
sudo systemctl restart $php_fpm_version

#create database
db_password=$(openssl rand -base64 12)
mysql -uroot -e "CREATE DATABASE db_worpress"
mysql -uroot -e "GRANT ALL PRIVILEGES ON db_worpress.* TO 'db_user'@'localhost' IDENTIFIED BY '$${db_password}'"
mysql -uroot -e "FLUSH PRIVILEGES"

#conf database connection
public_ip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
wp_password=$(openssl rand -base64 12)
sudo WP_CLI_CACHE_DIR=/tmp/ wp config create --allow-root --path=/var/www/html/wordpress --dbname=db_worpress --dbuser=db_user --dbpass=$${db_password}
sudo WP_CLI_CACHE_DIR=/tmp/ wp core install --allow-root --path=/var/www/html/wordpress --url=http://${site_url_name} --title=baleiaventure --admin_user=admin --admin_password=$${wp_password} --admin_email=hiperesfera@gmail.com

#printing admin password in systemlog
echo "Wordpress password - $${wp_password}"
#sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
#sed -re "s/password_here/$${db_password}/g" -i /var/www/html/wordpress/wp-config.php
#sed -re "s/username_here/db_user/g" -i /var/www/html/wordpress/wp-config.php
#sed -re "s/database_name_here/db_worpress/g" -i /var/www/html/wordpress/wp-config.php
#permissions
chown -R www-data.www-data /var/www/html
#mail admin details and password
echo -e "http://${site_url_name}\n$${wp_password}" | mail -s "Wordpress installations details" hiperesfera@gmail.com
