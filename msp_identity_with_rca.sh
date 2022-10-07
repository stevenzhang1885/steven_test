#!/bin/bash
#--------------------------------------------------------------------------------------------
#FABRIC_BASE_DIR=
#TLS_NAME=
##MSP_TYPE=
#ORG_NAME=
#ORDERER_NAME=
#ORDERER_NAME=
#PEER_NAME=
#CLIENT_NAME=
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

if [ "$MSP_TYPE" == "" ];then
   echo "[WARNING:] MSP_TYPE not defined, use difault "MSP_TYPE=client""
   MSP_TYPE=client
fi

if [ "$RCA_NAME" == "" ];then
   echo "[WARNING:] RCA_NAME not defined, use difault "RCA_NAME=rca""
   RCA_NAME=rca
fi
RCA_FULL_NAME=$RCA_NAME.$ORG_NAME

if [ "$ORDERER_NAME" == "" ];then
   echo "[WARNING:] ORDERER_NAME not defined, use difault "ORDERER_NAME=orderer""
   ORDERER_NAME=orderer
fi
ORDERER_FULL_NAME=$ORDERER_NAME.$ORG_NAME

if [ "$PEER_NAME" == "" ];then
   echo "[WARNING:] PEER_NAME not defined, use difault "PEER_NAME=peer""
   PEER_NAME=peer
fi
PEER_FULL_NAME=$PEER_NAME.$ORG_NAME

if [ "$CLIENT_NAME" == "" ];then
   echo "[WARNING:] CLIENT_NAME not defined, use difault "CLIENT_NAME='client$RANDOM'""
   CLIENT_NAME=client$RANDOM
fi
CLIENT_FULL_NAME=$CLIENT_NAME.$ORG_NAME

#------------------------------------------------------PATH VARIABLE DEFINITION------------------------------
ORG_MSP_DIR=$FABRIC_BASE_DIR/orgMSP/$ORG_NAME
ORDERER_MSP_DIR=$ORG_MSP_DIR/ordererMSP/$ORDERER_FULL_NAME
PEER_MSP_DIR=$ORG_MSP_DIR/peerMSP/$PEER_FULL_NAME
CLIENT_MSP_DIR=$ORG_MSP_DIR/clientMSP/$CLIENT_FULL_NAME
FABRIC_CA_SERVER_HOME=$FABRIC_BASE_DIR/ca/$ORG_NAME
export FABRIC_CA_CLIENT_HOME=$FABRIC_BASE_DIR/ca/fabric-ca-client
#---------------------------------------------------------LOCAL VARIABLE DEFINITION---------------------------------------------------------------
CSRHOST="0.0.0.0,localhost,$HOSTNAME" 
rca_ipaddr_port=0.0.0.0:7053
rca_admin_dir=$FABRIC_CA_CLIENT_HOME/$RCA_FULL_NAME-admin

if [ "$MSP_TYPE" == "org" ];then
    node_name=$ORG_NAME
    msp_dir=$ORG_MSP_DIR
elif [ "$MSP_TYPE" == "orderer" ];then
    node_name=$ORDERER_FULL_NAME
    msp_dir=$ORDERER_MSP_DIR
elif [ "$MSP_TYPE" == "peer" ];then
    node_name=$PEER_FULL_NAME
    msp_dir=$PEER_MSP_DIR
else  #client
    node_name=$CLIENT_FULL_NAME
    msp_dir=$CLIENT_MSP_DIR
fi 

if [ "$1" == "clean" ];then
    echo "-------------------------------------------------Clean: rm $msp_dir ------------------------------------------------------"
    rm $msp_dir -rf
    exit 0
fi
echo "-------------------------------------------------Fabric CA Client: Register $node_name to $RCA_FULL_NAME  -------------------------------------------------------"
fabric-ca-client register -d --id.name $node_name --id.secret $node_name.pw -u https://$rca_ipaddr_port  --tls.certfiles $TLS_NAME-root-cert/$TLS_NAME-ca-cert.pem  --mspdir $rca_admin_dir/msp
if [ "$?" -ne 0 ];then
    echo "Register $node_name to $node_name FAIL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
echo "-------------------------------------------------Fabric CA Client: Enroll $node_name to $RCA_FULL_NAME  -------------------------------------------------------"
fabric-ca-client enroll -d -u https://$node_name:$node_name.pw@$rca_ipaddr_port --tls.certfiles $TLS_NAME-root-cert/$TLS_NAME-ca-cert.pem --csr.hosts $CSRHOST --mspdir $msp_dir/msp
if [ "$?" -ne 0 ];then
    exit 1
fi