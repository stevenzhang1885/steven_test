#!/bin/bash
#-----------------------------------------------------PROJECT VARIABLE DEFINITION----------------------------------------------
export FABRIC_CA_CLIENT_HOME=$FABRIC_BASE_DIR/ca/fabric-ca-client

mspIdentityWithRcaInit(){
    if [ "$1" == ""];then
        echo "[WARNING:]  Arg1(node_type) is empty, use difault "node_type=client""
        node_type=client
        node_name=client$RANDOM.$ORG_NAME
    else
        node_type=$1
        node_name=$2.$ORG_NAME
    fi
    tls=$TLS_NAME
    rca=$RCA_NAME.$ORG_NAM
    ca_dir=$FABRIC_BASE_DIR/ca/$rca
    rca_ipaddr_port=$RCA_IP_PORT
    client_dir=$FABRIC_BASE_DIR/ca/fabric-ca-client
    rca_admin_dir=$client_dir/$rca-admin
    msp_dir=$FABRIC_BASE_DIR/{$node_type}MSP/$node_name
}
#input: $1-node_type $2-node_name
mspIdentityWithRca(){
    echo "-------------------------------------------------mspIdentityWithRca: Register $node_name to $rca  -------------------------------------------------------"
    fabric-ca-client register -d --id.name $node_name --id.secret $node_name.pw -u https://$rca_ipaddr_port  --tls.certfiles $tls-root-cert/$tls-ca-cert.pem  --mspdir $rca_admin_dir/msp
    if [ "$?" -ne 0 ];then
        echo "Register $node_name to $node_name FAIL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    fi
    echo "-------------------------------------------------mspIdentityWithRca: Enroll $node_name to $rca  -------------------------------------------------------"
    fabric-ca-client enroll -d -u https://$node_name:$node_name.pw@$rca_ipaddr_port --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --csr.hosts $ca_dir --mspdir $msp_dir/msp
    if [ "$?" -ne 0 ];then
        exit 1
    fi
}

mspIdentityWithRca.clean(){
    mspIdentityWithRcaInit $1 $2
    echo "-------------------------------------------------mspIdentityWithRca.clean: rm $msp_dir ------------------------------------------------------"
    rm $msp_dir -rf
}

mspIdentityWithRca.registerAndEnroll(){
    mspIdentityWithRcaInit $1 $2
    mspIdentityWithRca $1 $2
}

mspIdentityWithRca.clean(){
    mspIdentityWithRcaInit $1 $2
    # to do
}

if [ "$1" == "msprca" ];then
    mspIdentityWithRca.registerAndEnroll $2 $3
fi 

if [ "$1" == "msprcaclean" ];then
   mspIdentityWithRca.clean $2 $3
fi