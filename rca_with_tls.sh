#!/bin/bash
#-----------------------------------------------------PROJECT VARIABLE DEFINITION----------------------------------------------
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
#------------------------------------------------------FABRCI CA CLIENT VARIABLE DEFINITION------------------------------
export FABRIC_CA_CLIENT_HOME=$FABRIC_BASE_DIR/ca/fabric-ca-client
export FABRIC_CA_SERVER_HOME=$FABRIC_BASE_DIR/ca/$RCA_NAME
#---------------------------------------------------------LOCAL VARIABLE DEFINITION---------------------------------------------------------------
CSRHOST="0.0.0.0,localhost,$HOSTNAME" 
tls_ipaddr_port=0.0.0.0:7052
tls_admin_dir=$FABRIC_CA_CLIENT_HOME/$TLS_NAME.admin

#clean all
if [ "$1" == "clean" ];then

    echo "-------------------------------------------------Clean: rm $FABRIC_CA_CLIENT_HOME/$rca ------------------------------------------------------"
    rm $FABRIC_CA_CLIENT_HOME/$RCA_NAME -rf
    rm $FABRIC_CA_SERVER_HOME/$TLS_NAME-certs -rf
    exit 0
fi 

echo "-------------------------------------------------Fabric CA Client: Register & Enroll RCA Identity With TLS CA -------------------------------------------------------"
#Register
fabric-ca-client register -d --id.name $RCA_NAME --id.secret $RCA_NAME.pw -u https://$tls_ipaddr_port  --tls.certfiles $TLS_NAME-root-cert/$TLS_NAME-ca-cert.pem  --mspdir $tls_admin_dir/msp
if [ "$?" -ne 0 ];then
    echo "Register $RCA_NAME to $TLS_NAME FAIL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi

#Enroll
fabric-ca-client enroll -d -u https://$RCA_NAME:$RCA_NAME.pw@$tls_ipaddr_port --tls.certfiles $TLS_NAME-root-cert/$TLS_NAME-ca-cert.pem --enrollment.profile tls --csr.hosts $CSRHOST --mspdir $RCA_NAME/msp
if [ "$?" -ne 0 ];then
    exit 1
fi
mkdir -p $FABRIC_CA_SERVER_HOME/$TLS_NAME-certs
cp $FABRIC_CA_CLIENT_HOME/$RCA_NAME/msp/signcerts/cert.pem $FABRIC_CA_SERVER_HOME/$TLS_NAME-certs/cert.pem
cp $FABRIC_CA_CLIENT_HOME/$RCA_NAME/msp/keystore/* $FABRIC_CA_SERVER_HOME/$TLS_NAME-certs/key
