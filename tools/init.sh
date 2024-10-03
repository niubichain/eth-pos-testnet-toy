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
pkill reth
pkill geth

sleep 2

mkdir -p $el_data_dir $cl_bn_data_dir $cl_vc_data_dir || exit 1
cp ../static_files/jwt.hex ${jwt_path} || exit 1

geth init \
    --datadir=${el_data_dir} \
    ${genesis_json_path} \
    >> ${el_data_dir}/reth.log 2>&1 || exit 1

echo "**=============================================================**" \
    >> ${el_data_dir}/reth.log || exit 1

nohup geth \
      --networkid=${chain_id} \
      --datadir=${el_data_dir} \
      --http \
      --http.addr=0.0.0.0 \
      --http.port=8545 \
      --http.vhosts=* \
      --http.corsdomain=* \
      --http.api=admin,engine,net,eth,web3,debug,txpool \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.port=8546 \
      --ws.api=net,eth \
      --ws.origins=* \
      --allow-insecure-unlock \
      --authrpc.port=8551 \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.jwtsecret=${jwt_path} \
      --syncmode=archive \
    >>${el_data_dir}/reth.log 2>&1 &

nohup ${bin_dir}/lighthouse beacon_node \
    --testnet-dir=${testnet_dir} \
    --datadir=${cl_bn_data_dir} \
    --staking \
    --slots-per-restore-point=32 \
    --boot-nodes= \
    --enr-address=${cl_enr_address} \
    --disable-enr-auto-update \
    --listen-address=0.0.0.0 \
    --http --http-address=0.0.0.0 \
    --execution-endpoints="http://localhost:8551" \
    --jwt-secrets=${jwt_path} \
    --suggested-fee-recipient=${fee_recipient} \
    >>${cl_bn_data_dir}/lighthouse.bn.log 2>&1 &

nohup ${bin_dir}/lighthouse validator_client \
    --testnet-dir=${testnet_dir} \
    --datadir=${cl_vc_data_dir}\
    --init-slashing-protection \
    --suggested-fee-recipient=${fee_recipient} \
    >>${cl_vc_data_dir}/lighthouse.vc.log 2>&1 &

sleep 2

tail -n 3 ${el_data_dir}/reth.log
echo
tail -n 3 ${cl_bn_data_dir}/lighthouse.bn.log
echo
tail -n 3 ${cl_vc_data_dir}/lighthouse.vc.log

