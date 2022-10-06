#!/bin/bash

#Set Evnriment variable
export STEVENORG_DIR=/mnt/d/steven_test/steven.org
export FABRIC_CA_CLIENT_HOME=$STEVENORG_DIR/ca/fabric-ca-client
CSRHOST="0.0.0.0,localhost,$HOSTNAME" 

declare -A rca_ipaddr_list=(["rca.steven"]="0.0.0.0:7053")
rca_list="rca.steven"
declare -A rca_tls_map=(["rca.steven"]="tls.master")

#clean all
if [ "$1" == "clean" ];then
    for rca in $rca_list;do
        if [ "$2" == "all" ] ||  [ "$2" == "" ] ||  [ "$2" == "$rca" ];then
            echo "-------------------------------------------------Clean: rm $FABRIC_CA_CLIENT_HOME/$rca*------------------------------------------------------"
            rm $FABRIC_CA_CLIENT_HOME/$rca.admin -rf
        fi
    done
    exit 0
fi 

echo "-------------------------------------------------Fabric CA Client: REnroll RCA.STEVEN Admin Identity-------------------------------------------------------"

for rca in $rca_list;do
    tls=${rca_tls_map[$rca]}
    #Enroll TLS CA admin identity for fabric ca client
    echo "fabric-ca-client enroll -d -u https://$rca-admin:$rca-adminpw@${rca_ipaddr_list[$rca]} --tls.certfiles $tls-root-cert/$tls-ca-cert.pem  --csr.hosts $CSRHOST --mspdir $rca.admin/msp"
    fabric-ca-client enroll -u https://$rca-admin:$rca-adminpw@${rca_ipaddr_list[$rca]} --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --csr.hosts $CSRHOST --mspdir $rca.admin/msp
    if [ "$?" -ne 0 ];then
        exit $?
    fi 
done