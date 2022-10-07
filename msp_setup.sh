#!/bin/bash
#-----------------------------------------------------------------------------PROJECT BRIC VARIABALE INIT----------------------------------------------------

FABRIC_BASE_DIR=/mnt/d/fabric_network_test
TLS_NAME=tls.master
RCA_NAME=rca
ORG_NAME=stevenOrg
TLS_IP_PORT="0.0.0.0:7052"
RCA_IP_PORT="0.0.0.0:7053"
CSR_HOST="0.0.0.0,localhost,$HOSTNAME" 

#-----------------------------------------------------------------------------FABRIC VARIABALE INIT----------------------------------------------------
export FABRIC_CA_SERVER_HOME=$FABRIC_BASE_DIR/ca/$RCA_NAME.$ORG_NAME
export FABRIC_CA_SERVER_RCA_ENABLED=true
export FABRIC_CA_SERVER_CSR_CN=$TLS_NAME
export FABRIC_CA_SERVER_CSR_HOSTS=$CSR_HOST
export FABRIC_CA_CLIENT_HOME=$FABRIC_BASE_DIR/ca/fabric-ca-client

. env_init.sh
. tls_init.sh
. tls_admin.sh
. node_identity_with_tls.sh
. rca_init.sh
. rca_admin.sh
. msp_identity_with_rca.sh

mspSetup(){
   tls.setup            #1. setup tls
   tlsAdmin.enrolAdmin #2. enroll  tls admin
   node_type=rca
   node_name=rca
   nodeIdentifyWithTls.registerAndEnroll $node_type $node_name  #3 rca get identity from tls
   rca.setup  #4 setup rca
   rcaAdmin.enrollAdmin  #5 enroll rca admin 
   node_type=$1
   node_name=$2
   nodeIdentifyWithTls.registerAndEnroll $node_type $node_name #5   node get identity from tls
   mspIdentityWithRca.registerAndEnroll $node_type $node_name #6    msp get identity from rca
}

mspSetup.setup(){
   envInit
   mspSetup $2 $3
}

mspSetup.clean(){
   envInit
   #to do
}

if [ "$1" == "mspsetup" ];then
   envInit
   mspSetup.setup $2 $3
fi  

if [ "$1" == "mspsetupclean" ];then
   mspSetup.clean $2 $3
fi 





