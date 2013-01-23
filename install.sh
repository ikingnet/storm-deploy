#!/bin/bash

DEPLOY_HOME=$(cd "$(dirname "$0")"; pwd)
mkdir -p logs

while read line
do   
  host=`echo $line | cut -f2 -d " "`
  nohup ssh $host "$DEPLOY_HOME/setup.sh" > logs/install.$host.log 2>&1 &
done < $DEPLOY_HOME/hosts
