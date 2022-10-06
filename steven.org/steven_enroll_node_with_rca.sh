#!/bin/bash

export STEVENORG_DIR=/mnt/d/myproject/steven.org
#Set Evnriment variable
export FABRIC_CA_CLIENT_HOME=$STEVENORG_DIR/ca/fabric-ca-client
CSRHOST="0.0.0.0,localhost,$HOSTNAME" 
rca_ipaddr=0.0.0.0:7053
rca_org="rca.steven"
org="steven"
orderer_list="orderer1.steven"
peer_list="peer1.steven"
user_list=""
declare -A node_tls_map=(["steven"]="tls.master" ["peer1.steven"]="tls.master" ["orderer1.steven"]="tls.master")

#clean all
if [ "$1" == "clean" ];then
    if [ "$2" == "all" ] ||  [ "$2" == "" ] ||  [ "$2" == "$org" ];then
        echo "-------------------------------------------------Clean: rm $STEVENORG_DIR/$node ------------------------------------------------------"
        rm $STEVENORG_DIR/$org -rf
        exit 0
    fi
    for node in $orderer_list  $peer_list  $user_list ;do
    if [ "$2" == "$node" ];then
        echo "-------------------------------------------------Clean: rm $STEVENORG_DIR/$org/$node ------------------------------------------------------"
        rm $STEVENORG_DIR/$org/$node -rf
    fi
    done
    exit 0
fi 

echo "-------------------------------------------------Fabric CA Client: Register & Enroll Steven Node Identity With rca.steven-------------------------------------------------------"
echo "-------------------------------------------------STEVEN: Register & Enroll ORG ADMIN Identity With rca.steven-------------------------------------------------------"
tls=${node_tls_map[$org]}
echo "fabric-ca-client register -d --id.name $org --id.secret $org-pw -u https://$rca_ipaddr  --tls.certfiles $tls-root-cert/$tls-ca-cert.pem  --mspdir $rca_org.admin/msp"
fabric-ca-client register -d --id.name $org --id.secret $org-pw -u https://$rca_ipaddr  --tls.certfiles $tls-root-cert/$tls-ca-cert.pem  --mspdir $rca_org.admin/msp
if [ "$?" -ne 0 ];then
    echo "Register $org  FAIL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi

echo "fabric-ca-client enroll -d -u https://$org:$org-pw@$rca_ipaddr --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --csr.hosts $CSRHOST --mspdir $STEVENORG_DIR/$org /msp"
fabric-ca-client enroll -d -u https://$org:$org-pw@$rca_ipaddr --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --csr.hosts $CSRHOST --mspdir $STEVENORG_DIR/$org/msp
if [ "$?" -ne 0 ];then
    exit 1
fi
cp -r $FABRIC_CA_CLIENT_HOME/$rca_org/$tls/msp/tlscacerts $STEVENORG_DIR/$org/msp
echo "-------------------------------------------------STEVEN: Register & Enroll peer Identity With rca.steven-------------------------------------------------------"
#Enroll steven node identity with RCA.STEVEN
for peer in $peer_list;do
    tls=${node_tls_map[$peer]}
    echo "fabric-ca-client register -d --id.name $peer --id.secret $peer-pw -u https://$rca_ipaddr  --tls.certfiles $tls-root-cert/$tls-ca-cert.pem  --mspdir $rca_org.admin/msp"
    fabric-ca-client register -d --id.name $peer --id.secret $peer-pw -u https://$rca_ipaddr  --tls.certfiles $tls-root-cert/$tls-ca-cert.pem  --mspdir $rca_org.admin/msp
    if [ "$?" -ne 0 ];then
        echo "Register $peer FAIL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    fi

    echo "fabric-ca-client enroll -d -u https://$peer:$peer-pw@$rca_ipaddr --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --csr.hosts $CSRHOST --mspdir $STEVENORG_DIR/$org/$peer/msp"
    fabric-ca-client enroll -d -u https://$peer:$peer-pw@$rca_ipaddr --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --csr.hosts $CSRHOST --mspdir $STEVENORG_DIR/$org/$peer/msp
    if [ "$?" -ne 0 ];then
        exit 1
    fi
    cp -r $FABRIC_CA_CLIENT_HOME/$rca_org/$tls/msp/tlscacerts $STEVENORG_DIR//$org/$peer/msp
done
echo "-------------------------------------------------STEVEN: Register & Enroll orderer Identity With rca.steven-------------------------------------------------------"
#Register steven node  to RCA.STEVEN
for orderer in $orderer_list;do
    tls=${node_tls_map[$orderer]}
    echo "fabric-ca-client register -d --id.name $orderer --id.secret $orderer-pw -u https://$rca_ipaddr  --tls.certfiles $tls-root-cert/$tls-ca-cert.pem  --mspdir $rca.admin/msp"
    fabric-ca-client register -d --id.name $orderer --id.secret $orderer-pw -u https://$rca_ipaddr  --tls.certfiles $tls-root-cert/$tls-ca-cert.pem  --mspdir $rca.admin/msp
    if [ "$?" -ne 0 ];then
        echo "Register $orderer FAIL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    fi

    echo "fabric-ca-client enroll -d -u https://$orderer:$orderer-pw@$rca_ipaddr --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --csr.hosts $CSRHOST --mspdir $STEVENORG_DIR/$org/$orderer/msp"
    fabric-ca-client enroll -d -u https://$orderer:$orderer-pw@$rca_ipaddr --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --csr.hosts $CSRHOST --mspdir $STEVENORG_DIR/$org/$orderer/msp
    if [ "$?" -ne 0 ];then
        exit 1
    fi
    cp -r $FABRIC_CA_CLIENT_HOME/$rca_org/$tls/msp/tlscacerts $STEVENORG_DIR/$org/$orderer/msp
done
