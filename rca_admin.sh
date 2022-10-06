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

#------------------------------------------------------FABRCI CA CLIENT VARIABLE DEFINITION------------------------------
export FABRIC_CA_CLIENT_HOME=$FABRIC_BASE_DIR/ca/fabric-ca-client
#---------------------------------------------------------LOCAL VARIABLE DEFINITION---------------------------------------------------------------
CSRHOST="0.0.0.0,localhost,$HOSTNAME" 
rca_ipaddr_port=0.0.0.0:7053
rca_admin_dir=$FABRIC_CA_CLIENT_HOME/$RCA_NAME-admin
rca_admin_user=$RCA_NAME.admin
rca_admin_password=$RCA_NAME.adminpw

#clean all
if [ "$1" == "clean" ];then
    rm $rca_admin_dir -rf
    exit 0
fi 

echo "-------------------------------------------------Fabric CA Client: REnroll RCA.STEVEN Admin Identity-------------------------------------------------------"
fabric-ca-client enroll -u https://$rca_admin_user:$rca_admin_password@$rca_ipaddr_port --tls.certfiles $TLS_NAME-root-cert/$TLS_NAME-ca-cert.pem --csr.hosts $CSRHOST --mspdir $rca_admin_dir/msp
if [ "$?" -ne 0 ];then
    exit $?
fi 
