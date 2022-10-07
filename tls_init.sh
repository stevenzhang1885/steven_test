#!/bin/bash
#------------------------------------------------------FABRCI CA SERVER VARIABLE DEFINITION------------------------------
export FABRIC_CA_SERVER_HOME=$FABRIC_BASE_DIR/ca/$TLS_NAME
export FABRIC_CA_SERVER_RCA_ENABLED=true
export FABRIC_CA_SERVER_CSR_CN=$TLS_NAME
export FABRIC_CA_SERVER_CSR_HOSTS="0.0.0.0,$HOSTNAME,localhost"
#---------------------------------------------------------LOCAL VARIABLE DEFINITION---------------------------------------------------------------
tlsInit(){
   tls=$TLS_NAME
   ca_dir=$FABRIC_BASE_DIR/ca/$tls
   tls_admin_user=$tls.admin
   tls_admin_password=$tls.adminpw
   mkdir -p $ca_dir
}

tlsStart(){
   if test -e $FABRIC_BASE_DIR/fabric-ca-server-config-$tls.yaml;then
      cp  $FABRIC_BASE_DIR/fabric-ca-server-config-$tls.yaml $ca_dir/fabric-ca-server-config.yaml
   fi
   if test -e $ca_dir/fabric-ca-server.db;then
      echo "$tls has been Inited yet."
   else
      echo "--------------------------------------------------------------tlsStart: Init $tls-------------------------------------------------------------------------------------"
      fabric-ca-server init -d -b $tls_admin_user:$tls_admin_password
      if [ "$?" -ne 0 ];then
         exit 1
      fi
      rm -rf $ca_dir/ca-cert.pem 
      rm -rf $ca_dir/msp
   fi
   echo "-----------------------------------------------------------------tlsStart: Start $tls-------------------------------------------------------------------------------------"
   fabric-ca-server start &
   sleep 3
}

tls.clean(){
   tlsInit
   echo "-------------------------------------------------tls.clean: rm $ca_dir ------------------------------------------------------"
   rm  -rf $ca_dir 
}

tls.setup()
{
   tlsInit
   tlsStart
}

if [ "$1" == "tls" ];then
   tls.setup
fi   

if [ "$1" == "tlsclean" ];then
   tls.clean
fi 