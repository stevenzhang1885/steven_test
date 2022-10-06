#!/bin/bash
#-----------------------------------------------------PROJECT VARIABLE DEFINITION
if [ "$FABRIC_BASE_DIR" == "" ];then
   echo "[WARNING:] FABRIC_BASE_DIR not defined, use difault "FABRIC_BASE_DIR=/mnt/d/fabric_network_test""
   FABRIC_BASE_DIR=/mnt/d/fabric_network_test
fi

if [ "$TLS_NAME" == "" ];then
   echo "[WARNING:] TLS_NAME not defined, use difault "TLS_NAME=tls.master""
   TLS_NAME=tls.master
fi
#------------------------------------------------------FABRCI CA SERVER VARIABLE DEFINITION------------------------------
export FABRIC_CA_SERVER_HOME=$FABRIC_BASE_DIR/ca/$TLS_NAME
export FABRIC_CA_SERVER_RCA_ENABLED=true
export FABRIC_CA_SERVER_CSR_CN=tls.$TLS_NAME
export FABRIC_CA_SERVER_CSR_HOSTS="0.0.0.0,$HOSTNAME,localhost"
#---------------------------------------------------------LOCAL VARIABLE DEFINITION---------------------------------------------------------------
tls_admin_user=$TLS_NAME.admin
tls_admin_password=$TLS_NAME.adminpw

mkdir -p $FABRIC_CA_SERVER_HOME

if [ "$1" == "clean" ];then
   rm  -rf $FABRIC_CA_SERVER_HOME 
   exit 0
fi

if [ "$2" == "init" ] || [ "$2" == "" ];then
   if test -e $FABRIC_BASE_DIR/fabric-ca-server-config-$TLS_NAME.yaml;then
      cp  $FABRIC_BASE_DIR/fabric-ca-server-config-$TLS_NAME.yaml $FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml
   fi
   if test -e $FABRIC_CA_SERVER_HOME/fabric-ca-server.db;then
      echo "$TLS_NAME has been Inited yet."
   else
      echo "-----------------------------------------------------------------Init $TLS_NAME-------------------------------------------------------------------------------------"
      fabric-ca-server init -d -b $tls_admin_user:$tls_admin_password
      if [ "$?" -ne 0 ];then
         exit 1
      fi
      rm -rf $FABRIC_CA_SERVER_HOME/ca-cert.pem 
      rm -rf $FABRIC_CA_SERVER_HOME/msp
   fi
fi

if [ "$1" == "start" ] || [ "$1" == "" ];then
   echo "-----------------------------------------------------------------Start $TLS_NAME-------------------------------------------------------------------------------------"
   fabric-ca-server start &
fi
