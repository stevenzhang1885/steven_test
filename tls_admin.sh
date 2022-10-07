#!/bin/bash
#------------------------------------------------------ VARIABLE DEFINITION------------------------------
tlsAdminInit(){
    tls=$TLS_NAME
    ca_dir=$FABRIC_BASE_DIR/ca/$tls
    client_dir=$FABRIC_BASE_DIR/ca/fabric-ca-client
    tls_ipaddr_port=$TLS_IP_PORT
    tls_admin_dir=$client_dir/$tls-admin
    tls_admin_user=$tls.admin
    tls_admin_password=$tls.adminpw
}

tlsAdminEnroll(){
    echo "-------------------------------------------------tlsAdminEnroll: Enroll $tls Admin Identity-------------------------------------------------------"
    mkdir -p $client_dir/$tls-root-cert
    cp $ca_dir/ca-cert.pem $client_dir/$tls-root-cert/$tls-ca-cert.pem
    #Enroll TLS CA admin identity for fabric ca client
    fabric-ca-client enroll -d -u https://$tls_admin_user:$tls_admin_password@$tls_ipaddr_port --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --enrollment.profile tls  --mspdir $tls_admin_dir/msp
    if [ "$?" -ne 0 ];then
        exit $?
    fi 
}

#clean
tlsAdmin.clean(){
    tlsAdminInit
    echo "-------------------------------------------------tlsAdmin.clean: rm $tls_admin_dir $client_dir/$tls-root-cert  ------------------------------------------------------"
    rm $tls_admin_dir -rf
    rm $client_dir/$tls-root-cert -rf
}   

tlsAdmin.enrolAdmin(){
    tlsAdminInit
    tlsAdminEnroll
}

if [ "$1" == "tlsadmin" ];then
   tlsAdmin.enrolAdmin
fi 

if [ "$1" == "tlsadminclean" ];then
   tlsAdmin.clean
fi 