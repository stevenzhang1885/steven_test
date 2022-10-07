#!/bin/bash
#-----------------------------------------------------PROJECT VARIABLE DEFINITION----------------------------------------------
nodeIdentityWithtlsInit(){
    if [ "$1" == "" ];then
        echo "[WARNING:]  Arg1(node_type) is empty, use difault "node_type=client""
        node_type=client
        node_name=client$RANDOM.$ORG_NAME
    else
        node_type=$1
        if [ "$node_type" == "org" ];then
            $node_type=rca
        fi
        node_name=$2.$ORG_NAME
    fi

    tls=$TLS_NAME
    rca=$RCA_NAME.$ORG_NAME
    tls_ipaddr_port=$TLS_IP_PORT
    ca_dir=$FABRIC_BASE_DIR/ca/$rca
    client_dir=$FABRIC_BASE_DIR/ca/fabric-ca-client
    tls_admin_dir=$client_dir/$tls-admin
    csr_host=$CSR_HOST
}
    
nodeIdentifyWithTls(){
    echo "-------------------------------------------------nodeIdentifyWithTls: Register $node_name to $tls  -------------------------------------------------------"
    fabric-ca-client register -d --id.name $node_name --id.secret $node_name.pw -u https://$tls_ipaddr_port  --tls.certfiles $tls-root-cert/$tls-ca-cert.pem  --mspdir $tls_admin_dir/msp
    if [ "$?" -ne 0 ];then
        echo "Register $node_name to $tls FAIL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    fi
    echo "-------------------------------------------------nodeIdentifyWithTls: Enroll $node_name to $tls  -------------------------------------------------------"
    fabric-ca-client enroll -d -u https://$node_name:$node_name.pw@$tls_ipaddr_port --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --enrollment.profile tls --csr.hosts $csr_host --mspdir $tls-signed/$node_name/msp
    if [ "$?" -ne 0 ];then
        exit 1
    fi

    if [ "$node_type" == "rca" ];then
        mkdir -p $ca_dir/$TLS_NAME-certs
        rm $client_dir/$tls-signed/$node_name/msp/signcerts/cert-signed-by-$tls.pem
        mv $client_dir/$tls-signed/$node_name/msp/signcerts/cert.pem $client_dir/$tls-signed/$node_name/msp/signcerts/cert-signed-by-$tls.pem
        cp $client_dir/$tls-signed/$node_name/msp/signcerts/cert-signed-by-$tls.pem $ca_dir/$tls-certs/
        rm $client_dir/$tls-signed/$node_name/msp/keystore/key-signed-by-$tls.pem
        mv $client_dir/$tls-signed/$node_name/msp/keystore/* $client_dir/$tls-signed/$node_name/msp/keystore/key-signed-by-$tls.pem
        cp $client_dir/$tls-signed/$node_name/msp/keystore/key-signed-by-$tls.pem $ca_dir/$tls-certs/
    fi
}

nodeIdentityWithTls.clean(){
    nodeIdentityWithtlsInit $1 $2
    echo "-------------------------------------------------nodeIdentityWithTls.clean: rm $client_dir/$tls-signed/$node_name ------------------------------------------------------"
    rm $client_dir/$tls-signed/$node_name -rf
    if [ "$node_type" == "rca" ];then
        rm $ca_dir/$tls-certs -rf
    fi
}

nodeIdentifyWithTls.registerAndEnroll(){
    nodeIdentityWithtlsInit $1 $2
    nodeIdentifyWithTls $1 $2
}

if [ "$1" == "nodetls" ];then
    nodeIdentifyWithTls.registerAndEnroll $2 $3
fi 

if [ "$1" == "nodetlsclean" ];then
   nodeIdentifyWithTls.clean $2 $3
fi