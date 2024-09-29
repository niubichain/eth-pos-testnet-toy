#!/bin/bash

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

pkill lighthouse
pkill reth
pkill geth

sleep 2

node_dir="../testdata/node"
testnet_dir="${node_dir}/genesis_data/network_configs"
genesis_json_path="${testnet_dir}/genesis.json"

el_data_dir="${node_dir}/el"
cl_bn_data_dir="${node_dir}/cl/beacon"
cl_vc_data_dir="${node_dir}/cl/validator"

jwt_path="${node_dir}/jwt.hex"

mkdir -p $el_data_dir $cl_bn_data_dir $cl_vc_data_dir || exit 1
cp ../static_files/jwt.hex ${jwt_path} || exit 1

./reth init --datadir=${el_data_dir} --chain=${genesis_json_path} || exit 1

nohup ./reth node \
    --datadir=${el_data_dir} \
    --chain=${genesis_json_path} \
    --ipcdisable \
    --http --http.addr=0.0.0.0 \
    --http.corsdomain=* --http.api="admin,net,eth,web3,debug,trace,txpool" \
    --ws --ws.addr=0.0.0.0 \
    --ws.origins=* --ws.api="eth,net" \
    --authrpc.jwtsecret=${jwt_path} \
    --disable-discovery \
    >${el_data_dir}/reth.log 2>&1 &

nohup ./lighthouse beacon_node \
    --testnet-dir=${testnet_dir} \
    --datadir=${cl_bn_data_dir} \
    --boot-nodes="" \
    --listen-address=0.0.0.0 \
    --http --http-address=0.0.0.0 --http-allow-sync-stalled \
    --execution-endpoints="http://localhost:8551" \
    --jwt-secrets=${jwt_path} \
    >${cl_bn_data_dir}/bn.log 2>&1 &

nohup ./lighthouse validator_client \
    --testnet-dir=. \
    --datadir=validatordata \
    --init-slashing-protection \
    --beacon-nodes="http://localhost:9001" \
    --suggested-fee-recipient="0x123463a4B065722E99115D6c222f267d9cABb524" \
    >${cl_vc_data_dir}/vc.log 2>&1 &

sleep 2

tail -n 3 ${el_data_dir}/reth.log
echo
tail -n 3 ${cl_bn_data_dir}/bn.log
echo
tail -n 3 ${cl_vc_data_dir}/vc.log
