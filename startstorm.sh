#!/bin/bash

DEPLOY_HOME=$(cd "$(dirname "$0")"; pwd)
echo "starting storm nimbus servers.."
source /etc/profile
nohup storm nimbus > logs/nimbus.log 2>&1 &
echo "starting storm ui servers.."
nohup storm ui > logs/ui.log 2>&1 &
echo "starting storm drpc server..."
nohup storm drpc > logs/drpc.log 2>&1 &

while read line
do
  host=`echo $line | cut -f2 -d " "`
  if [[ "$host" != "${HOSTNAME}" ]];
  then
   echo "starting $line storm supervisor server.."
   ssh $host ". /etc/profile; nohup storm supervisor > supervisor.log 2>&1 &" </dev/null
  fi
done < $DEPLOY_HOME/hosts
