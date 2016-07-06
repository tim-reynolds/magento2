#!/usr/bin/env bash

# This script can be used to perform any sort of command line actions to setup your box.
# This includes installing software, importing databases, enabling new sites, pulling from
# remote servers, etc.
echo "#############################"
echo "#### CREATING SWAP SPACE ####"
echo "#############################"
dd if=/dev/zero of=/swapfile bs=128M count=4
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "" >> /etc/fstab
echo "/swapfile   none    swap    sw    0   0" > /etc/fstab

echo "##############################"
echo "#### RSYNC OF SOURCE CODE ####"
echo "##############################"
mkdir -p /var/www/html
rsync -r /vagrant/ /var/www/html
# update
echo "########################"
echo "##### UPDATING APT #####"
echo "########################"
apt-get update

# Install Apache
echo "#############################"
echo "##### INSTALLING APACHE #####"
echo "#############################"
apt-get -y install apache2

# Creating folder
echo "#######################################"
echo "##### MAGENTO2 FOLDER PERMISSIONS #####"
echo "#######################################"
chmod 0777 -R /var/www/html/magento2

# enable modrewrite
echo "#######################################"
echo "##### ENABLING APACHE MOD-REWRITE #####"
echo "#######################################"
a2enmod rewrite

# append AllowOverride to Apache Config File
echo "#######################################"
echo "##### CREATING APACHE CONFIG FILE #####"
echo "#######################################"
echo "
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/magento2
		ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

		<Directory '/var/www/html/magento2'>
			Options Indexes FollowSymLinks MultiViews
			AllowOverride All
			Order allow,deny
			allow from all
		</Directory>
</VirtualHost>
" > /etc/apache2/sites-available/magento2.conf

echo "ServerName localhost" >> /etc/apache2/apache2.conf
echo "" >> /etc/hosts
echo "" >> /etc/hosts
echo "127.0.0.1 dev.magento2.com" >> /etc/hosts


# Enabling Site
echo "##################################"
echo "##### Enabling Magento2 Site #####"
echo "##################################"
a2ensite magento2.conf
a2dissite 000-default.conf
service apache2 restart

# Setting Locales
echo "###########################"
echo "##### Setting Locales #####"
echo "###########################"
locale-gen en_US en_US.UTF-8 pl_PL pl_PL.UTF-8
dpkg-reconfigure locales

# Install MySQL 5.6
echo "############################"
echo "##### INSTALLING MYSQL #####"
echo "############################"
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server-5.6 mysql-client-5.6

# Create Database instance
echo "#############################"
echo "##### CREATING DATABASE #####"
echo "#############################"
mysql -u root -e "create database magento;"
mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root');"
# Install PHP 5.5
echo "##########################"
echo "##### INSTALLING PHP #####"
echo "##########################"
#apt-get -y update
#add-apt-repository ppa:ondrej/php
#apt-get -y update
#apt-get -y install php5

#apt-get -y install php5-mhash php5-mcrypt php5-curl php5-cli php5-mysql php5-gd php5-intl php5-common php-pear php5-dev php5-xsl

echo "##############################"
echo "##### INSTALLING PHP 5.6 #####"
echo "##############################"
LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
apt-get -y update
apt-get -y install php5.6

# Install Required PHP extensions
echo "#####################################"
echo "##### INSTALLING PHP EXTENSIONS #####"
echo "#####################################"
apt-get -y install php5.6-mcrypt php5.6-curl php5-cli php5.6-mysql php5.6-gd php5.6-intl php5.6-common php-pear php5.6-dev php5.6-xsl php5.6-xml php5.6-mbstring php5.6-zip


# Mcrypt issue
echo "#############################"
echo "##### PHP MYCRYPT PATCH #####"
echo "#############################"
php5enmod mcrypt
service apache2 restart

# Set PHP Timezone
echo "########################"
echo "##### PHP TIMEZONE #####"
echo "########################"
echo "date.timezone = America/New_York" >> /etc/php5/cli/php.ini

# Set Pecl php_ini location
echo "##########################"
echo "##### CONFIGURE PECL #####"
echo "##########################"
pear config-set php_ini /etc/php5/apache2/php.ini

# Install Xdebug
echo "##########################"
echo "##### INSTALL XDEBUG #####"
echo "##########################"
pecl install xdebug

# Install Pecl Config variables
echo "############################"
echo "##### CONFIGURE XDEBUG #####"
echo "############################"
echo "xdebug.remote_enable = 1" >> /etc/php5/apache2/php.ini
echo "xdebug.remote_connect_back = 1" >> /etc/php5/apache2/php.ini

# Install Git
echo "##########################"
echo "##### INSTALLING GIT #####"
echo "##########################"
apt-get -y install git
echo "##################################"
echo "##### INSTALLING LOG SYNCING #####"
echo "##################################"
apt-get install -y inotify-tools
# Composer Installation
sudo apt-get  install -y curl dos2unix lsyncd
cp /vagrant/vagrant/logsync.sh /root/logsync.sh
chmod +x /root/logsync.sh
dos2unix /root/logsync.sh
cp /vagrant/vagrant/logsync /etc/init.d/logsync
chmod +x /etc/init.d/logsync
dos2unix /etc/init.d/logsync
update-rc.d logsync defaults
/etc/init.d/logsync start

cp /vagrant/vagrant/staticsync.lua /root/staticsync.lua
chmod +x /root/staticsync.lua
dos2unix /root/staticsync.lua

cp /vagrant/vagrant/staticsync.sh /root/staticsync.sh
chmod +x /root/staticsync.sh
dos2unix /root/staticsync.sh


echo "#####################################"
echo "##### INSTALLING STATIC SYNCING #####"
echo "#####################################"
cp /vagrant/vagrant/staticsync /etc/init.d/staticsync
chmod +x /etc/init.d/staticsync
dos2unix /etc/init.d/staticsync
update-rc.d staticsync defaults
# NOTE: NOT STARTING IT NOW. WILL START AT THE END

echo "###############################"
echo "##### INSTALLING COMPOSER #####"
echo "###############################"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Set Ownership and Permissions
echo "#############################################"
echo "##### SETTING OWNERSHIP AND PERMISSIONS #####"
echo "#############################################"
chown -R www-data:www-data /var/www/html/magento2/
find /var/www/html/magento2/ -type d -exec chmod 770 {} \;
find /var/www/html/magento2/ -type f -exec chmod 660 {} \;
# Add vagrant user to www-data group
usermod -a -G www-data vagrant

# Install n98-magerun
# --------------------
echo "##################################"
echo "##### Installing n98-magerun #####"
echo "##################################"
cd /tmp
wget https://raw.github.com/netz98/n98-magerun/master/n98-magerun.phar
chmod +x ./n98-magerun.phar
sudo mv ./n98-magerun.phar /usr/local/bin/magerun
cd /var/www/html
#magerun admin:user:create admin test@envalo.com passw0rd Admin User

echo "#################################"
echo "##### Installing PHPMyAdmin #####"
echo "#################################"
# PHPMyAdmin
export DEBIAN_FRONTEND=noninteractive
echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
apt-get install -y  php-gettext phpmyadmin

# Magento 2 Installation from composer
echo "############################################"
echo "##### INSTALLING COMPOSER DEPENDENDIES #####"
echo "############################################"
 if [ -z "$1" ]
 	then
 		echo "################################################################"
 		echo "##### NO GITHUB API TOKEN.  SKIPPING COMPOSER INSTALLATION #####"
		echo "################################################################"
	else
		composer config -g github-oauth.github.com $1

		echo "################################################################"
        echo "##### Ran Composer config #####"
        echo "################################################################"

		cd /var/www/html/magento2/

		echo "################################################################"
        echo "##### Changed into magenot2 directory #####"
        echo "################################################################"

        echo "################################################################"
        echo "##### Attempting to run composer install #####"
        echo "################################################################"

        composer install

		#composer config repositories.magento composer http://packages.magento.com

		echo "################################################################"
        echo "##### Ran config repositories.magento command #####"
        echo "################################################################"

		#composer require magento/sample-bundle-all:1.0.0

        echo "################################################################"
        echo "##### Ran composer require magento #####"
        echo "################################################################"

fi

echo "############################################"
echo "#### FIXING PHP 5.6 DEPRECATED FEATURES ####"
echo "############################################"
echo "" >> /etc/php/5.6/apache2/php.ini
echo "" >> /etc/php/5.6/apache2/php.ini
echo "always_populate_raw_post_data = -1"  >> /etc/php/5.6/apache2/php.ini
cat /vagrant/vagrant/php.vagrant.ini >> /etc/php/5.6/apache2/php.ini
cat /etc/php/5.6/apache2/php.ini | sed -s "s/128M/1024M/" > /tmp/php.ini
rm /etc/php/5.6/apache2/php.ini
mv /tmp/php.ini /etc/php/5.6/apache2/

echo "#################################################"
echo "#### DONE FIXING PHP 5.6 DEPRECATED FEATURES ####"
echo "#################################################"


echo "#############################################"
echo "#### FIXING PHP MODULE DUPLICATION ISSUE ####"
echo "#############################################"
a2dismod php5

# Restart apache
echo "#############################"
echo "##### RESTARTING APACHE #####"
echo "#############################"
service apache2 restart
echo "##################################"
echo "##### INSTALLING MAILCATCHER #####"
echo "##################################"
apt-get install -y libsqlite3-dev ruby1.9.1-dev
gem install mime-types --version "< 3"
gem install mailcatcher --conservative

cp /vagrant/vagrant/mailcatcher /etc/init.d/mailcatcher
chmod +x /etc/init.d/mailcatcher
dos2unix /etc/init.d/mailcatcher
update-rc.d mailcatcher defaults
/etc/init.d/mailcatcher start

echo "###########################"
echo "##### SETTING UP CRON #####"
echo "###########################"
cd /tmp
crontab -u www-data -l > cronfile
echo "
*/5 * * * * /usr/bin/php -c /etc/php/5.6/apache2/php.ini /var/www/html/magento2/bin/magento cron:run | grep -v "Ran jobs by schedule" >> /var/www/html/magento2/var/log/magento.cron.log
*/5 * * * * /usr/bin/php -c /etc/php/5.6/apache2/php.ini /var/www/html/magento2/update/cron.php >> /var/www/html/magento2/var/log/update.cron.log
*/5 * * * * /usr/bin/php -c /etc/php/5.6/apache2/php.ini /var/www/html/magento2/bin/magento setup:cron:run >> /var/www/html/magento2/var/log/setup.cron.log
" >> cronfile
crontab -u www-data cronfile
rm ./cronfile
echo "#######################################"
echo "#### INSTALLING MAGENTO 2 FROM CLI ####"
echo "#######################################"
cd /var/www/html/magento2/bin
php ./magento setup:install --admin-firstname="AdminUser" --admin-lastname="Person" --admin-email="test@test.com" \
--admin-user="admin" --admin-password="passw0rd" --base-url="http://dev.magento2.com/" --backend-frontname="admin" \
--db-host="localhost" --db-name="magento" --db-user="root" --db-password="root" --language="en_US" \
--timezone="America/New_York" --currency="USD" --use-rewrites="1" --use-secure="0" \
--use-secure-admin="0" --session-save="files"
echo "###########################################"
echo "#### INSTALLING STATIC CONTENT FROM CLI ###"
echo "###########################################"
php ./magento setup:static-content:deploy en_US

echo "#################################"
echo "#### RSYNC OF STATIC CONTENT ####"
echo "#################################"
rsync -r /var/www/html/magento2/pub/static /vagrant/pub_static
/etc/init.d/staticsync start

echo "###########################################"
echo "#### FIXING VAR PERMISSIONS IN MAGENTO ####"
echo "###########################################"
mkdir -p /var/www/html/magento2/var
chmod -R 777 /var/www/html/magento2/var
cd /var/www/html
sudo chown -R www-data:www-data ./magento2
# Post Up Message
echo "Magento2 Vagrant Box ready!"
if [ -z "$1" ]
	then
		echo "Final installation instructions:"
		echo "run 'vagrant ssh'"
		echo "run 'cd /var/www/html/magento2/'"
		echo "run 'composer install'"
		echo "When prompted, enter your github API credentials"
		echo "Afterward finish installation."
fi

