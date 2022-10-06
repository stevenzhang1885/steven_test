#!/bin/bash

export MASTERVIEW_DIR=/mnt/d/steven_test/masterview
export FABRIC_CA_SERVER_HOME=$MASTERVIEW_DIR/ca/tlsxxx

tls_ca_list="tls.master"
clean_files="Issuer* ca-cert.pem fabric-ca-server.db msp tls-cert.pem"
#clean tls x

for tls in $tls_ca_list;do
   export FABRIC_CA_SERVER_HOME=$MASTERVIEW_DIR/ca/$tls
   if [ "$1" == "all" ] || [ "$1" == "" ] || [ "$1" == "$tls" ];then
      for file in $clean_files;do
         echo "clean: rm $file "   
         rm  -rf $FABRIC_CA_SERVER_HOME/$file 
      done
   fi 
done


   