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

if [ "$ORG_NAME" == "" ];then
   echo "[WARNING:] ORG_NAME not defined, use difault "ORG_NAME=steven""
   ORG_NAME=steven
fi

if [ "$RCA_NAME" == "" ];then
   echo "[WARNING:] RCA_NAME not defined, use difault "RCA_NAME=rca.$ORG_NAME""
   RCA_NAME=rca.$ORG_NAME
fi
#------------------------------------------------------FABRCI CA SERVER VARIABLE DEFINITION------------------------------
#Set Evnriment variable
export FABRIC_CA_SERVER_HOME=$FABRIC_BASE_DIR/ca/$RCA_NAME
export FABRIC_CA_SERVER_RCA_ENABLED=true
export FABRIC_CA_SERVER_CSR_HOSTS="0.0.0.0,$HOSTNAME,localhost"
export FABRIC_CA_SERVER_CSR_CN=$RCA_NAME
#---------------------------------------------------------LOCAL VARIABLE DEFINITION---------------------------------------------------------------
rca_admin_user=$RCA_NAME.admin
rca_admin_password=$RCA_NAME.adminpw
#---------------------------------------------------------------------------------------------------------------------------
mkdir -p $FABRIC_CA_SERVER_HOME

if [ "$1" == "clean" ];then
   rm $FABRIC_CA_SERVER_HOME/IssuerPublicKey -f
   rm $FABRIC_CA_SERVER_HOME/IssuerRevocationPublicKey -f  
   rm $FABRIC_CA_SERVER_HOME/ca-cert.pem -f
   rm $FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml -f
   rm $FABRIC_CA_SERVER_HOME/fabric-ca-server.db -f
   rm $FABRIC_CA_SERVER_HOME/msp -rf 
   exit 0
fi

if [ "$1" == "init" ] || [ "$1" == "" ];then
      if test -e $FABRIC_BASE_DIR/fabric-ca-server-config-$RCA_NAME.yaml;then
         cp  $FABRIC_BASE_DIR/fabric-ca-server-config-$RCA_NAME.yaml $FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml
      fi

      if test -e $FABRIC_CA_SERVER_HOME/fabric-ca-server.db;then
         echo "RCA_NAME has been Inited yet."
      else
         echo "-----------------------------------------------------------------Init $RCA_NAME -------------------------------------------------------------------------------------"
         fabric-ca-server init -d -b $rca_admin_user:$rca_admin_user
         if [ "$?" -ne 0 ];then
            exit 1
         fi
         rm -rf $FABRIC_CA_SERVER_HOME/ca-cert.pem 
         rm -rf $FABRIC_CA_SERVER_HOME/msp
      fi
fi 

if [ "$1" == "start" ] || [ "$1" == "" ];then
   echo "-----------------------------------------------------------------Start $RCA_NAME-------------------------------------------------------------------------------------"
   fabric-ca-server start &
fi  