#!/bin/sh
if [ ! -d /var/www/html/magento2/var/log ]; then
  sudo mkdir -p /var/www/html/magento2/var/log
  sudo chown www-data:www-data /var/www/html/magento2/var/log
fi

while true; do
  change=$(inotifywait -e close_write,moved_to,create --format '%f' /var/www/html/magento2/var/log)
  cp /var/www/html/magento2/var/log/$change /vagrant/vagrant/vagrant_logs/
done