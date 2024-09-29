#!/usr/bin/env bash

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

source ./path.env

cfg_dir=${testnet_dir}
yaml_path="${cfg_dir}/mnemonics.yaml"
txt_path="${cfg_dir}/mnemonics.txt"

validator_cnt=$(grep -Po '(?<=count: )\d+' $yaml_path)
mnemonics=$(grep -Po '(?<=mnemonic: ")[\s\w]+(?=")' $yaml_path)

if [[ "" == $validator_cnt || "" == $mnemonics ]]; then
    exit 1
fi

echo "$mnemonics" > $txt_path | exit 1

time ../testdata/bin/lighthouse account validator recover \
    --testnet-dir=${cfg_dir} \
    --datadir=${cl_vc_data_dir} \
    --mnemonic-path=${txt_path} \
    --count=${validator_cnt} \
    --store-withdrawal-keystore

