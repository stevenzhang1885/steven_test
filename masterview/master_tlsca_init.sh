#!/bin/bash


export MASTERVIEW_DIR=/mnt/d/steven_test/masterview
#Set Evnriment variable
export FABRIC_CA_SERVER_HOME=$MASTERVIEW_DIR/ca/tlsxxx
export FABRIC_CA_SERVER_TLS_ENABLED=true
export FABRIC_CA_SERVER_CSR_CN=tlsxxx
export FABRIC_CA_SERVER_CSR_HOSTS="0.0.0.0,localhost,$HOSTNAME"

tls_ca_list="tls.master"

if [ "$1" == "init" ] || [ "$1" == "start" ];then
   for tls in $tls_ca_list;do
      export FABRIC_CA_SERVER_HOME=$MASTERVIEW_DIR/ca/$tls
      export FABRIC_CA_SERVER_CSR_CN=$tls
      if [ "$2" == "all" ] || [ "$2" == "" ] || [ "$2" == "$tls" ];then
         if test -e $FABRIC_CA_SERVER_HOME/fabric-ca-server.db;then
            echo "TLS CA SERVER has been Inited yet."
         else
            echo "-----------------------------------------------------------------Init TLS CA SERVER-------------------------------------------------------------------------------------"
            fabric-ca-server init -d -b $tls-admin:$tls-adminpw
            if [ "$?" -ne 0 ];then
               exit 1
            fi
            rm -rf $FABRIC_CA_SERVER_HOME/ca-cert.pem 
            rm -rf $FABRIC_CA_SERVER_HOME/msp
         fi

         if [ "$1" == "start" ];then
            echo "-----------------------------------------------------------------Start TLS CA SERVER-------------------------------------------------------------------------------------"
            fabric-ca-server start &
         fi
      fi
   done
else
   echo "please iput subcommand: start, init.  
         for example: tlsca_init_master.sh init"
fi                         