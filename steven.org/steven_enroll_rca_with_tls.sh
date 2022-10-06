#!/bin/bash

export STEVENORG_DIR=/mnt/d/steven_test/steven.org
MASTERVIEW_DIR=/mnt/d/steven_test/masterview
#Set Evnriment variable
export FABRIC_CA_CLIENT_HOME=$STEVENORG_DIR/ca/fabric-ca-client
CSRHOST="0.0.0.0,localhost,$HOSTNAME" 
declare -A tls_ipaddr_list=(["tls.master"]="0.0.0.0:7052")
tls_list="tls.master"
rca_list="rca.steven"

#clean all
if [ "$1" == "clean" ];then
    for tls in $tls_list;do
        if [ "$2" == "all" ] ||  [ "$2" == "" ] ||  [ "$2" == "$tls" ];then
            for rca in $rca_list;do
                if [ "$3" == "all" ] ||  [ "$3" == "" ] ||  [ "$3" == "$rca" ];then
                    echo "-------------------------------------------------Clean: rm $FABRIC_CA_CLIENT_HOME/$rca/$tls ------------------------------------------------------"
                    rm $FABRIC_CA_CLIENT_HOME/$rca/$tls -rf
                fi
            done
        fi
    done
    exit 0
fi 

echo "-------------------------------------------------Fabric CA Client: Register & Enroll TLS Identity for RCA.ORG-------------------------------------------------------"

for tls in $tls_list;do
    #update tls root ca cert if old;
    mkdir -p $FABRIC_CA_CLIENT_HOME/$tls-root-cert
    cp $MASTERVIEW_DIR/ca/$tls/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$tls-root-cert/$tls-ca-cert.pem

    #Enroll TLS CA admin identity for fabric ca client
    echo "fabric-ca-client enroll -d -u https://$tls-admin:$tls-adminpw@${tls_ipaddr_list[$tls]} --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --enrollment.profile tls --csr.hosts $CSRHOST --mspdir $tls.admin/msp"
    fabric-ca-client enroll -u https://$tls-admin:$tls-adminpw@${tls_ipaddr_list[$tls]} --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --enrollment.profile tls --csr.hosts $CSRHOST --mspdir $tls.admin/msp
    if [ "$?" -ne 0 ];then
        exit $?
    fi 

    #Register RCA.ORG  to TCL CA
    for rca in $rca_list;do
        echo "fabric-ca-client register -d --id.name $rca --id.secret $rca-pw -u https://${tls_ipaddr_list[$tls]}  --tls.certfiles $tls-root-cert/$tls-ca-cert.pem  --mspdir $tls.admin/msp"
        fabric-ca-client register -d --id.name $rca --id.secret $rca-pw -u https://${tls_ipaddr_list[$tls]}  --tls.certfiles $tls-root-cert/$tls-ca-cert.pem  --mspdir $tls.admin/msp
        if [ "$?" -ne 0 ];then
            echo "Register $rca to TCL CA FAIL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        fi
    done
    #Enroll TLS CA identity for RCA.ORG
    for rca in $rca_list;do
        echo "fabric-ca-client enroll -d -u https://$rca:$rca-pw@${tls_ipaddr_list[$tls]} --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --enrollment.profile tls --csr.hosts $CSRHOST --mspdir $rca/$tls/msp"
        fabric-ca-client enroll -d -u https://$rca:$rca-pw@${tls_ipaddr_list[$tls]} --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --enrollment.profile tls --csr.hosts $CSRHOST --mspdir $rca/$tls/msp
        if [ "$?" -ne 0 ];then
            exit 1
        fi
        mkdir -p $STEVENORG_DIR/ca/$rca/$tls-certs
        cp $FABRIC_CA_CLIENT_HOME/$rca/$tls/msp/signcerts/cert.pem $STEVENORG_DIR/ca/$rca/$tls-certs/cert.pem
        cp $FABRIC_CA_CLIENT_HOME/$rca/$tls/msp/keystore/* $STEVENORG_DIR/ca/$rca/$tls-certs/key.pem
    done
done