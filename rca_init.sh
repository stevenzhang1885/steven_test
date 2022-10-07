#!/bin/bash
#---------------------------------------------------------LOCAL VARIABLE DEFINITION---------------------------------------------------------------
rcaInit(){
   rca=$RCA_NAME.$ORG_NAME
   ca_dir=$FABRIC_BASE_DIR/ca/$rca
   rca_admin_user=$rca.admin
   rca_admin_password=$rca.adminpw
   mkdir -p $ca_dir
}

rcaStart(){
   if test -e $FABRIC_BASE_DIR/fabric-ca-server-config-$rca.yaml;then
      cp  $FABRIC_BASE_DIR/fabric-ca-server-config-$rca.yaml $ca_dir/fabric-ca-server-config.yaml
   fi

   if test -e $ca_dir/fabric-ca-server.db;then
      echo "RCA_NAME has been Inited yet."
   else
      echo "---------------------------------------------------------------rcaStart: Init $rca -------------------------------------------------------------------------------------"
      fabric-ca-server init -d -b $rca_admin_user:$rca_admin_password
      if [ "$?" -ne 0 ];then
         exit 1
      fi
      rm -rf $ca_dir/ca-cert.pem 
      rm -rf $ca_dir/msp
   fi

   echo "-------------------------------------------------------------------rcaStart: Start $rca-------------------------------------------------------------------------------------"
   fabric-ca-server start &
   sleep 3
} 

rca.clean(){
   rcaInit
   echo "-------------------------------------------------rcaInit.clean: rm $ca_dir ------------------------------------------------------"
   rm $ca_dir/IssuerPublicKey -f
   rm $ca_dir/IssuerRevocationPublicKey -f  
   rm $ca_dir/ca-cert.pem -f
   rm $ca_dir/fabric-ca-server-config.yaml -f
   rm $ca_dir/fabric-ca-server.db -f
   rm $ca_dir/msp -rf 
}

rca.setup(){
   rcaInit
   rcaStart
}

if [ "$1" == "rca" ];then
   rca.setup
fi 

if [ "$1" == "rcaclean" ];then
   rca.clean
fi 