#!/bin/bash

export STEVENORG_DIR=/mnt/d/myproject/steven.org
export FABRIC_CA_SERVER_HOME=$STEVENORG_DIR/ca/rcaxxx

rca_list="rca.steven"
clean_files="Issuer* ca-cert.pem fabric-ca-server.db msp"
#clean rca x

for rca in $rca_list;do
export FABRIC_CA_SERVER_HOME=$STEVENORG_DIR/ca/$rca
   if [ "$1" == "all" ] || [ "$1" == "" ] || [ "$1" == "$rca" ];then
      for file in $clean_files;do
         echo "clean: rm $file "
         rm  -rf $FABRIC_CA_SERVER_HOME/$file 
      done
   fi 
done

 