#!/bin/bash
#------------------------------------------------------FABRCI CA CLIENT VARIABLE DEFINITION------------------------------
export FABRIC_CA_CLIENT_HOME=$FABRIC_BASE_DIR/ca/fabric-ca-client

rcaAdminInit(){
    tls=$TLS_NAME
    rca=$RCA_NAME.$ORG_NAME
    csr_host=$CSR_HOST
    rca_ipaddr_port=$RCA_IP_PORT
    rca_admin_dir=$FABRIC_BASE_DIR/ca/fabric-ca-client/$rca-admin
    rca_admin_user=$rca.admin
    rca_admin_password=$rca.adminpw
}

rcaAdminEnroll(){
    rcaAdminInit
    echo "-------------------------------------------------rcaAdminEnroll: Enroll $rca Admin Identity-------------------------------------------------------"
    fabric-ca-client enroll -u https://$rca_admin_user:$rca_admin_password@$rca_ipaddr_port --tls.certfiles $tls-root-cert/$tls-ca-cert.pem --csr.hosts $csr_host --mspdir $rca_admin_dir/msp
    if [ "$?" -ne 0 ];then
        exit $?
    fi 
}

rcaAdmin.clean(){
    rcaAdminInit
    echo "-------------------------------------------------rcaAdmin.clean: rm $rca_admin_dir ------------------------------------------------------"
    rm $rca_admin_dir -rf
}

rcaAdmin.enrollAdmin(){
    rcaAdminInit
    rcaAdminEnrroll
}

if [ "$1" == "rcaadmin" ];then
    rcaAdmin.enrollAdmin
fi 

if [ "$1" == "rcaadminclean" ];then
   rcaAdmin.clean
fi