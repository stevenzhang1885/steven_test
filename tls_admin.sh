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
#------------------------------------------------------FABRCI CA CLIENT VARIABLE DEFINITION------------------------------
export FABRIC_CA_CLIENT_HOME=$FABRIC_BASE_DIR/ca/fabric-ca-client
export FABRIC_CA_SERVER_HOME=$FABRIC_BASE_DIR/ca/$TLS_NAME
#---------------------------------------------------------LOCAL VARIABLE DEFINITION---------------------------------------------------------------
tls_ipaddr_port=0.0.0.0:7052
tls_admin_dir=$FABRIC_CA_CLIENT_HOME/$TLS_NAME.admin
tls_admin_user=$TLS_NAME.admin
tls_admin_password=$TLS_NAME.adminpw
#clean all
if [ "$1" == "clean" ];then
    rm $tls_admin_dir -rf
    rm $FABRIC_CA_CLIENT_HOME/$TLS_NAME-root-cert -rf
    exit 0
fi 

echo "-------------------------------------------------fabric ca client: Enroll $TLS_NAME Admin Identity-------------------------------------------------------"
mkdir -p $FABRIC_CA_CLIENT_HOME/$TLS_NAME-root-cert
cp $FABRIC_CA_SERVER_HOME/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$TLS_NAME-root-cert/$TLS_NAME-ca-cert.pem
#Enroll TLS CA admin identity for fabric ca client
fabric-ca-client enroll -d -u https://$tls_admin_user:$tls_admin_password@$tls_ipaddr_port --tls.certfiles $TLS_NAME-root-cert/$TLS_NAME-ca-cert.pem --enrollment.profile tls  --mspdir $tls_admin_dir/msp
if [ "$?" -ne 0 ];then
    exit $?
fi 