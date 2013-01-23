#!/bin/bash
DEPLOY_HOME=$(cd "$(dirname "$0")"; pwd)

while read line
do
  host=`echo $line | cut -f2 -d " "`
  echo "starting $line zookeeper server.."
  ssh $host '. /etc/profile; $ZOOKEEPER_HOME/bin/zkServer.sh start' </dev/null
done < $DEPLOY_HOME/hosts
