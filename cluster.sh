#!/bin/bash

DEPLOY_HOME=$(cd "$(dirname "$0")"; pwd)

# set hosts
while read line
do
  host=`echo $line | cut -f2 -d " "`
  sed -i "/\<$host\>/d" /etc/hosts
done < $DEPLOY_HOME/hosts

sudo sh -c "cat $DEPLOY_HOME/hosts >> /etc/hosts"

sudo apt-get install expect dsh -y
# copy ssh key
$(cd "$(dirname "$0")"; pwd)/ssh.exp

# sync DEPLOY_HOME
while read line
do   
  host=`echo $line | cut -f2 -d " "`
  sudo sh -c "echo $host > /etc/dsh/machines.list"
  scp -r $DEPLOY_HOME $host:${PWD}/
done < $DEPLOY_HOME/hosts

# set a simple dsh command 
sudo sh -c "echo #!/bin/bash >> /usr/bin/c" 
sudo sh -c "echo dsh -a -- \"echo =================\${HOSTNAME}=================;. /etc/profile;$*\" > /usr/bin/c"
sudo chmod +x /usr/bin/c

