#!/bin/bash
envInit(){
    if [ "$FABRIC_BASE_DIR" == "" ];then
        echo "[WARNING:] FABRIC_BASE_DIR not defined, use difault "FABRIC_BASE_DIR=/mnt/d/fabric_network_test""
        FABRIC_BASE_DIR=/mnt/d/fabric_network_test
    fi
    if [ "$TLS_NAME" == "" ];then
        echo "[WARNING:] TLS_NAME not defined, use difault "TLS_NAME=tls.master""
        TLS_NAME=tls.master
    fi

    if [ "$RCA_NAME" == "" ];then
        echo "[WARNING:] RCA_NAME not defined, use difault "RCA_NAME=rca""
        RCA_NAME=rca
    fi

    if [ "$TLS_IP_PORT" == ""];then
        echo "[WARNING:] TLS_IP_PORT not defined, use difault "TLS_IP_PORT=0.0.0.0:7052""
        TLS_IP_PORT="0.0.0.0:7052"
    fi

    if [ "$RCA_IP_PORT" == "" ]; then
        echo "[WARNING:] RCA_IP_PORT not defined, use difault "RCA_IP_PORT=0.0.0.0:7052""
        RCA_IP_PORT="0.0.0.0:7053"
    fi

   if [ "$ORG_NAME" == "" ];then
      echo "[WARNING:] ORG_NAME not defined, use difault "ORG_NAME=steven""
      ORG_NAME=steven
   fi

   if [ "$CSR_HOST" == "" ];then
      echo "[WARNING:] CSR_HOST not defined, use difault "CSR_HOST=steven""
      CSR_HOST="0.0.0.0,localhost,$HOSTNAME" 
   fi
}
