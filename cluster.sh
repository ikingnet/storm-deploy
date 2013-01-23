#!/bin/bash

DEPLOY_HOME=$(cd "$(dirname "$0")"; pwd)
# set hosts
while read line
do
  host=`echo $line | cut -f2 -d " "`
  sudo sed -i "/\<$host\>$/d" /etc/hosts
done < $DEPLOY_HOME/hosts

cat $DEPLOY_HOME/hosts | sudo tee -a /etc/hosts
echo "install expect and dsh"
sudo apt-get install expect dsh -y
# copy ssh key
$DEPLOY_HOME/ssh.exp

# sync DEPLOY_HOME and config dsh
cat /dev/null > /etc/dsh/machines.list
while read line
do   
  host=`echo $line | cut -f2 -d " "`
  sudo sh -c "echo $host >> /etc/dsh/machines.list"
  if [[ "$host" != "${HOSTNAME}" ]]; then
    scp -r $DEPLOY_HOME $host:$DEPLOY_HOME/
  fi
done < $DEPLOY_HOME/hosts

# set a simple dsh command 
echo '#!/bin/bash' | sudo tee /usr/bin/c
echo 'dsh -a -- "echo =================\${HOSTNAME}=================;. /etc/profile;$*"' | sudo tee -a /usr/bin/c
sudo chmod +x /usr/bin/c

