#!/bin/bash
#set -v on

. msp_setup.sh
#------------------------------------------------------------------------------
declare -A node_list=(["orderer"]="order1" ["peer"]="peer1" ["client"]="client1")

for node_type in ${!node_list[*]};do
   node_name=${node_list[$node_type]}
   mspSetup.setup $node_type $node_name
   if [ "$?" -ne 0 ];then
      echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!$node_type: setup $node_name  fail!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      exit 1
   fi
done

