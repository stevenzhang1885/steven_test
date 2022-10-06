#!/bin/bash

#Set Evnriment variable
export MASTERVIEW_DIR=/mnt/d/myproject/masterview
export FABRIC_CA_CLIENT_HOME=$MASTERVIEW_DIR/ca/fabric-ca-client
CSRHOST="0.0.0.0,localhost,$HOSTNAME" 

declare -A tls_ipaddr_list=(["tls.master"]="0.0.0.0:7052")
tls_list="tls.master"

#clean all
if [ "$1" == "clean" ];then
    for tls in $tls_list;do
        if [ "$2" == "all" ] ||  [ "$2" == "" ] ||  [ "$2" == "$tls" ];then
            echo "-------------------------------------------------Clean: rm $FABRIC_CA_CLIENT_HOME/$tls*------------------------------------------------------"
            rm $FABRIC_CA_CLIENT_HOME/$tls.admin -rf
        fi
    done
    exit 0
fi 

echo "-------------------------------------------------Fabric CA Client: REnroll TLS CA Admin Identity-------------------------------------------------------"

for tls in $tls_list;do
    mkdir -p $FABRIC_CA_CLIENT_HOME/$tls-root-cert
    cp $MASTERVIEW_DIR/ca/$tls/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$tls-root-cert/$tls-ca-cert.pem

    #Enroll TLS CA admin identity for fabric ca client
    echo "fabric-ca-client enroll -d -u https://$tls-admin:$tls-adminpw@${tls_ipaddr_list[$tls]} --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --enrollment.profile tls --csr.hosts $CSRHOST --mspdir $tls.admin/msp"
    fabric-ca-client enroll -u https://$tls-admin:$tls-adminpw@${tls_ipaddr_list[$tls]} --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --enrollment.profile tls --csr.hosts $CSRHOST --mspdir $tls.admin/msp
    if [ "$?" -ne 0 ];then
        exit $?
    fi 
done