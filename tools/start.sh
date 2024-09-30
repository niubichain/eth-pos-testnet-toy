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

pkill lighthouse
sleep 2

pkill reth
pkill geth
sleep 2

nohup ${bin_dir}/reth node \
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
    --disable-discovery \
    >>${el_data_dir}/reth.log 2>&1 &

nohup ${bin_dir}/lighthouse beacon_node \
    --testnet-dir=${testnet_dir} \
    --datadir=${cl_bn_data_dir} \
    --slots-per-restore-point=32 \
    --boot-nodes= \
    --enable-private-discovery \
    --disable-enr-auto-update \
    --enr-udp-port=9000 --enr-tcp-port=9000 \
    --listen-address=0.0.0.0 --port=9000 \
    --http --http-address=0.0.0.0 --http-port=4000 \
    --execution-endpoints="http://localhost:8551" \
    --jwt-secrets=${jwt_path} \
    --subscribe-all-subnets \
    --suggested-fee-recipient=${fee_recipient} \
    --allow-insecure-genesis-sync \
    >>${cl_bn_data_dir}/lighthouse.bn.log 2>&1 &

nohup ${bin_dir}/lighthouse validator_client \
    --testnet-dir=${testnet_dir} \
    --datadir=${cl_vc_data_dir}\
    --init-slashing-protection \
    --beacon-nodes="http://localhost:9001" \
    --suggested-fee-recipient=${fee_recipient} \
    >>${cl_vc_data_dir}/lighthouse.vc.log 2>&1 &

sleep 2

tail -n 3 ${el_data_dir}/reth.log
echo
tail -n 3 ${cl_bn_data_dir}/lighthouse.bn.log
echo
tail -n 3 ${cl_vc_data_dir}/lighthouse.vc.log

