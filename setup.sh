#!/bin/bash

DEPLOY_HOME=$(cd "$(dirname "$0")"; pwd)

#前提条件已经下载所有相关的软件包

# apt-get install
sudo apt-get install libtool autoconf automake uuid-dev e2fsprogs build-essential g++ unzip python git pkg-config -y

# set hosts
while read line
do   
  host=`echo $line | cut -f2 -d " "`
  sed -i "/\<$host\>/d" /etc/hosts
done < $DEPLOY_HOME/hosts

sudo sh -c "cat $DEPLOY_HOME/hosts >> /etc/hosts"

# install JDK and config path
yes|$DEPLOY_HOME/resource/jdk-6u38-linux-x64.bin
sed -i "/export JAVA_HOME=/d" /etc/profile
echo "export JAVA_HOME=${PWD}/jdk1.6.0_38" | sudo tee -a /etc/profile
sed -i "/export PATH=\$JAVA_HOME\/bin:\$PATH/d" /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH'  | sudo tee -a /etc/profile
source /etc/profile

# install zookeeper
tar zxvf $DEPLOY_HOME/resource/zookeeper-3.4.5.tar.gz
mkdir -p zkdata
mkdir -p /var/log/zookeeper
cp zookeeper-3.4.5/conf/zoo_sample.cfg zookeeper-3.4.5/conf/zoo.cfg
sed -i "/dataDir=/d" zookeeper-3.4.5/conf/zoo.cfg
sed -i "/dataLogDir=/d" zookeeper-3.4.5/conf/zoo.cfg
sed -i "/server\./d" zookeeper-3.4.5/conf/zoo.cfg
echo "dataDir=${PWD}/zkdata" >> zookeeper-3.4.5/conf/zoo.cfg
echo "dataLogDir=/var/log/zookeeper" >>  zookeeper-3.4.5/conf/zoo.cfg

while read line
do   
  echo "server.${line:${#line}-1}:${line}:2888:3888" >> zookeeper-3.4.5/conf/zoo.cfg
done < $DEPLOY_HOME/zkserver.list
echo "${HOSTNAME:${#HOSTNAME}-1}" > ${PWD}/zkdata/myid

sed -i "/export ZOOKEEPER_HOME=/d" /etc/profile
sed -i "/export PATH=\$ZOOKEEPER_HOME\/bin:\$PATH/d" /etc/profile
echo "export ZOOKEEPER_HOME=${PWD}/zookeeper-3.4.5" | sudo tee -a /etc/profile
echo 'export PATH=$ZOOKEEPER_HOME/bin:$PATH'  | sudo tee -a /etc/profile

# install zeormq
tar zxvf $DEPLOY_HOME/resource/zeromq-2.1.7.tar.gz 
cd zeromq-2.1.7
./configure
make
sudo make install
sudo ldconfig
cd ..

# install jzmq
tar zxvf $DEPLOY_HOME/resource/jzmq.tar.gz
cd jzmq
./autogen.sh 
./configure
make
sudo make install
sudo ldconfig
cd ..

# install storm 
yes|unzip $DEPLOY_HOME/resource/storm-0.8.1.zip 
mkdir -p stormdata
echo "storm.zookeeper.servers:" >> storm-0.8.1/conf/storm.yaml
while read line
do
  echo '  - "'$line'"' >> storm-0.8.1/conf/storm.yaml
done < $DEPLOY_HOME/zkserver.list

echo "storm.zookeeper.port: 2181" >> storm-0.8.1/conf/storm.yaml
echo 'storm.local.dir: '${PWD}'/stormdata' >> storm-0.8.1/conf/storm.yaml
echo 'nimbus.host: "'`head -n1 $DEPLOY_HOME/nimbus.host`'"' >> storm-0.8.1/conf/storm.yaml
echo 'drpc.servers: ' >> storm-0.8.1/conf/storm.yaml
echo ' - "'`head -n1 $DEPLOY_HOME/nimbus.host`'"' >> storm-0.8.1/conf/storm.yaml
echo 'supervisor.scheduler.meta:' >> storm-0.8.1/conf/storm.yaml
echo ' name: "'${HOSTNAME}'"' >> storm-0.8.1/conf/storm.yaml

sed -i "/export STORM_HOME=/d" /etc/profile
sed -i "/export PATH=\$STORM_HOME\/bin:\$PATH/d" /etc/profile
echo "export STORM_HOME=${PWD}/storm-0.8.1" | sudo tee -a /etc/profile
echo 'export PATH=$STORM_HOME/bin:$PATH'  | sudo tee -a /etc/profile
