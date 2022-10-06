#!/bin/bash
#--------------------------------------------------------------------------------------------
if [ "$1" != "rca" ] && [ "$1" != "orderer" ] && [ "$1" != "peer" ];then
    echo "Error: missing node type(peer/oreder/rca)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
fi

if [ "$2" == "" ];then
    echo "Error: missing node name(peer name/oreder name/rca name)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
fi
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

NODE_NAME=$2.$ORG_NAME
#------------------------------------------------------FABRCI CA CLIENT VARIABLE DEFINITION------------------------------
export FABRIC_CA_CLIENT_HOME=$FABRIC_BASE_DIR/ca/fabric-ca-client
export FABRIC_CA_SERVER_HOME=$FABRIC_BASE_DIR/ca/$NODE_NAME
#---------------------------------------------------------LOCAL VARIABLE DEFINITION---------------------------------------------------------------
CSRHOST="0.0.0.0,localhost,$HOSTNAME" 
tls_ipaddr_port=0.0.0.0:7052
tls_admin_dir=$FABRIC_CA_CLIENT_HOME/$TLS_NAME-admin

if [ "$3" == "clean" ];then
    echo "-------------------------------------------------Clean: rm $FABRIC_CA_CLIENT_HOME/$TLS_NAME-signed/$NODE_NAME ------------------------------------------------------"
    rm $FABRIC_CA_CLIENT_HOME/$TLS_NAME-signed/$NODE_NAME -rf
    if [ "$1" == "rca" ];then
        rm $FABRIC_CA_SERVER_HOME/$TLS_NAME-certs -rf
    fi
    exit 0
fi 

echo "-------------------------------------------------Fabric CA Client: Register $NODE_NAME to $TLS_NAME  -------------------------------------------------------"
fabric-ca-client register -d --id.name $NODE_NAME --id.secret $NODE_NAME.pw -u https://$tls_ipaddr_port  --tls.certfiles $TLS_NAME-root-cert/$TLS_NAME-ca-cert.pem  --mspdir $tls_admin_dir/msp
if [ "$?" -ne 0 ];then
    echo "Register $NODE_NAME to $TLS_NAME FAIL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
echo "-------------------------------------------------Fabric CA Client: Register $NODE_NAME to $TLS_NAME  -------------------------------------------------------"
fabric-ca-client enroll -d -u https://$NODE_NAME:$NODE_NAME.pw@$tls_ipaddr_port --tls.certfiles $TLS_NAME-root-cert/$TLS_NAME-ca-cert.pem --enrollment.profile tls --csr.hosts $CSRHOST --mspdir $TLS_NAME-signed/$NODE_NAME/msp
if [ "$?" -ne 0 ];then
    exit 1
fi

if [ "$1" == "rca" ];then
    mkdir -p $FABRIC_CA_SERVER_HOME/$TLS_NAME-certs
    rm $FABRIC_CA_CLIENT_HOME/$TLS_NAME-signed/$NODE_NAME/msp/signcerts/cert-signed-by-$TLS_NAME.pem
    mv $FABRIC_CA_CLIENT_HOME/$TLS_NAME-signed/$NODE_NAME/msp/signcerts/cert.pem $FABRIC_CA_CLIENT_HOME/$TLS_NAME-signed/$NODE_NAME/msp/signcerts/cert-signed-by-$TLS_NAME.pem
    cp $FABRIC_CA_CLIENT_HOME/$TLS_NAME-signed/$NODE_NAME/msp/signcerts/cert-signed-by-$TLS_NAME.pem $FABRIC_CA_SERVER_HOME/$TLS_NAME-certs/
    rm $FABRIC_CA_CLIENT_HOME/$TLS_NAME-signed/$NODE_NAME/msp/keystore/key-signed-by-$TLS_NAME.pem
    mv $FABRIC_CA_CLIENT_HOME/$TLS_NAME-signed/$NODE_NAME/msp/keystore/* $FABRIC_CA_CLIENT_HOME/$TLS_NAME-signed/$NODE_NAME/msp/keystore/key-signed-by-$TLS_NAME.pem
    cp $FABRIC_CA_CLIENT_HOME/$TLS_NAME-signed/$NODE_NAME/msp/keystore/key-signed-by-$TLS_NAME.pem $FABRIC_CA_SERVER_HOME/$TLS_NAME-certs/
fi