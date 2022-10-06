#!/bin/bash

export STEVENORG_DIR=/mnt/d/steven_test/steven.org
#Set Evnriment variable
export FABRIC_CA_SERVER_HOME=$STEVENORG_DIR/ca/rcaxxx
export FABRIC_CA_SERVER_rca_ENABLED=true
export FABRIC_CA_SERVER_CSR_HOSTS="0.0.0.0,$HOSTNAME,localhost"
export FABRIC_CA_SERVER_CSR_CN=rcaxxx

declare -A rca_tls_map=(["rca.steven"]="tls.master")
#declare -A RCA_ORG_ADDRESS=(["rca.org1"]="0.0.0.0:7053" ["rca.org2"]="0.0.0.0:7054" ["rca.org3"]="0.0.0.0:7055" ["rca.org4"]="0.0.0.0:7056")
rca_list="rca.steven"

if [ "$1" == "init" ] || [ "$1" == "start" ];then
   for rca in $rca_list;do
      export FABRIC_CA_SERVER_HOME=$STEVENORG_DIR/ca/$rca
      export FABRIC_CA_SERVER_CSR_CN=$rca
      if [ "$2" == "all" ] || [ "$2" == "" ] || [ "$2" == "$rca" ];then
         if test -e $FABRIC_CA_SERVER_HOME/fabric-ca-server.db;then
            echo "rca CA SERVER has been Inited yet."
         else
            echo "-----------------------------------------------------------------Init rca CA SERVER-------------------------------------------------------------------------------------"
            fabric-ca-server init -d -b $rca-admin:$rca-adminpw
            if [ "$?" -ne 0 ];then
               exit 1
            fi
            rm -rf $FABRIC_CA_SERVER_HOME/ca-cert.pem 
            rm -rf $FABRIC_CA_SERVER_HOME/msp
         fi

         if [ "$1" == "start" ];then
            echo "-----------------------------------------------------------------Start rca CA SERVER-------------------------------------------------------------------------------------"
            tls=${rca_tls_map[$rca]}
            fabric-ca-server start --tls.certfile $STEVENORG_DIR/ca/$rca/$tls-certs/cert.pem --tls.keyfile $STEVENORG_DIR/ca/$rca/$tls-certs/key.pem &
         fi
      fi
   done
else
   echo "please iput subcommand: start, init.  
         for example: rcaca_init_master.sh start"
fi   