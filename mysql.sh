#!/bin/bash

echo 'mysql-server-5.5 mysql-server/root_password password kingnet' | sudo debconf-set-selections
echo 'mysql-server-5.5 mysql-server/root_password_again password kingnet' | sudo debconf-set-selections
sudo apt-get install -y mysql-server-5.5
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
echo "update user set host='%' where user='root' and host='127.0.0.1'" | mysql -uroot -pkingnet mysql
service mysql restart
