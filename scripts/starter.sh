#!/usr/bin/env bash
##
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##
set -e


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KERBEROS_SERVER=${KERBEROS_SERVER:-krb5}
ISSUER_SERVER=${ISSUER_SERVER:-$KERBEROS_SERVER\:8081}

while true
do
  STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://$ISSUER_SERVER/keytab/test/test)
  if [ $STATUS -eq 200 ]; then
    echo "Got 200, KDC service ready!!"
    break
  else
    echo "Got $STATUS :( Not done yet..."
  fi
  sleep 5
done

export HOST_NAME=`hostname -f`
for NAME in ${KERBEROS_KEYTABS}; do
   echo "Download $NAME/$HOSTNAME@EXAMPLE.COM keytab file to $CONF_DIR/$NAME.keytab"
   wget http://$ISSUER_SERVER/keytab/$HOST_NAME/$NAME -O $CONF_DIR/$NAME.keytab
   KERBEROS_ENABLED=true
done

#for NAME in ${KERBEROS_KEYSTORES}; do
#   echo "Download keystore files for $NAME"
#   wget http://$ISSUER_SERVER/keystore/$NAME -O $CONF_DIR/$NAME.keystore
#   KERBEROS_ENABLED=true
#   KEYSTORE_DOWNLOADED=true
#done

#if [ -n "$KEYSTORE_DOWNLOADED" ]; then
#  wget http://$ISSUER_SERVER/keystore/$HOST_NAME -O $CONF_DIR/$HOST_NAME.keystore
#  wget http://$ISSUER_SERVER/truststore -O $CONF_DIR/truststore
#fi

if [ -n "$KERBEROS_ENABLED" ]; then
   cat $DIR/krb5.conf |  sed "s/SERVER/$KERBEROS_SERVER/g" | sudo tee /etc/krb5.conf
fi


#To avoid docker volume permission problems
sudo chmod o+rwx /data

$DIR/envtoconf.py --destination /opt/hadoop/etc/hadoop

if [ -n "$SLEEP_SECONDS" ]; then
   #echo "Sleeping for $SLEEP_SECONDS seconds"
   sleep $SLEEP_SECONDS
fi


if [ -n "$ENSURE_NAMENODE_DIR" ]; then
   CLUSTERID_OPTS=""
   if [ -n "$ENSURE_NAMENODE_CLUSTERID" ]; then
      CLUSTERID_OPTS="-clusterid $ENSURE_NAMENODE_CLUSTERID"
   fi
   if [ ! -d "$ENSURE_NAMENODE_DIR" ]; then
      /opt/hadoop/bin/hdfs namenode -format -force $CLUSTERID_OPTS
        fi
fi


if [ -n "$ENSURE_STANDBY_NAMENODE_DIR" ]; then
   if [ ! -d "$ENSURE_STANDBY_NAMENODE_DIR" ]; then
      /opt/hadoop/bin/hdfs namenode -bootstrapStandby
    fi
fi


if [ -n "$ENSURE_SCM_INITIALIZED" ]; then
   if [ ! -f "$ENSURE_SCM_INITIALIZED" ]; then
      /opt/hadoop/bin/ozone scm -init
   fi
fi

if [ -n "$ENSURE_KSM_INITIALIZED" ]; then
   if [ ! -f "$ENSURE_KSM_INITIALIZED" ]; then
      #To make sure SCM is running in dockerized environment we will sleep
		# Could be removed after HDFS-13203
		echo "Waiting 15 seconds for SCM startup"
		sleep 15
      /opt/hadoop/bin/ozone ksm -createObjectStore
   fi
fi

#while :
#do
#	echo ".."
#	sleep 100
#done
$@
