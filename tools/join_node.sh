#!/bin/bin/env bash

#################################################
#### Ensure we are in the right path. ###########
#################################################
if [[ 0 -eq $(echo $0 | grep -c '^/') ]]; then
    # relative path
    EXEC_PATH=$(dirname "`pwd`/$0")
else
    # absolute path
    EXEC_PATH=$(dirname "$0")
fi

EXEC_PATH=$(echo ${EXEC_PATH} | sed 's@/\./@/@g' | sed 's@/\.*$@@')
cd $EXEC_PATH || exit 1
#################################################
source ./common.env

pkill reth
pkill geth
sleep 2

pkill lighthouse
sleep 2

peer_ip="60.212.189.153"
if [[ "" != $NBNET_TESTNET_PEER_IP ]]; then
    peer_ip=$NBNET_TESTNET_PEER_IP
fi

el_enode=$(curl -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' "http://${peer_ip}:8545" | jq '.result.enode' | sed 's/"//g' || exit 1)
cl_enr=$(curl "http://${peer_ip}:5052/eth/v1/node/identity" | jq '.data.enr' | sed 's/"//g' || exit 1)
cl_peer_id=$(curl "http://${peer_ip}:5052/eth/v1/node/identity" | jq '.data.peer_id' | sed 's/"//g' || exit 1)

mkdir -p $el_data_dir $cl_bn_data_dir $cl_vc_data_dir || exit 1
cp ../static_files/jwt.hex ${jwt_path} || exit 1

nohup reth node \
    --datadir=${el_data_dir} \
    --chain=${genesis_json_path} \
    --log.file.directory=${el_data_dir}/logs \
    --ipcdisable \
    --http --http.addr=0.0.0.0 \
    --http.corsdomain=* --http.api="admin,net,eth,web3,debug,trace,txpool" \
    --ws --ws.addr=0.0.0.0 \
    --ws.origins=* --ws.api="eth,net" \
    --authrpc.addr=0.0.0.0 --authrpc.port=8551 \
    --authrpc.jwtsecret=${jwt_path} \
    --trusted-peers=${el_enode} \
    --bootnodes=${el_enode} \
    >>${el_data_dir}/reth.log 2>&1 &

nohup lighthouse beacon_node \
    --testnet-dir=${testnet_dir} \
    --datadir=${cl_bn_data_dir} \
    --staking \
    --slots-per-restore-point=32 \
    --listen-address=0.0.0.0 \
    --http --http-address=0.0.0.0 \
    --execution-endpoints="http://localhost:8551" \
    --jwt-secrets=${jwt_path} \
    --subscribe-all-subnets \
    --suggested-fee-recipient=${fee_recipient} \
    --enr-address=${cl_enr_address} \
    --target-peers=1 \
    --trusted-peers=${cl_peer_id} \
    --boot-nodes=${cl_enr} \
    --checkpoint-sync-url="http://${peer_ip}:5052" \
    --disable-deposit-contract-sync \
    >>${cl_bn_data_dir}/lighthouse.bn.log 2>&1 &

sleep 2

tail -n 3 ${el_data_dir}/reth.log
echo
tail -n 3 ${cl_bn_data_dir}/lighthouse.bn.log

exit 0
