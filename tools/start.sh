#!/bin/bash

pkill geth
sleep 1

pkill beacon-chain
sleep 1

pkill validator
sleep 1

nohup ./geth --http --http.addr=0.0.0.0 --http.api eth,web3,net,txpool,shh,debug --ws --ws.addr=0.0.0.0 --ws.api eth,web3,net,txpool,shh,debug --authrpc.jwtsecret jwt.hex --datadir gethdata --nodiscover --syncmode full --allow-insecure-unlock --unlock 0x123463a4b065722e99115d6c222f267d9cabb524 --password secret.txt.password >gethdata/log.txt 2>&1 &

nohup ./beacon-chain --datadir beacondata --min-sync-peers 0 --genesis-state genesis.ssz --bootstrap-node= --interop-eth1data-votes --chain-config-file config.yml --contract-deployment-block 0 --chain-id 9527000 --accept-terms-of-use --jwt-secret jwt.hex --suggested-fee-recipient 0x123463a4B065722E99115D6c222f267d9cABb524 --minimum-peers-per-subnet 0 --enable-debug-rpc-endpoints --execution-endpoint gethdata/geth.ipc >beacondata/log.txt 2>&1 &

nohup ./validator --datadir validatordata --accept-terms-of-use --interop-num-validators 64 --chain-config-file config.yml >validatordata/log.txt 2>&1 &

sleep 2

tail -n 3 gethdata/log.txt
echo
tail -n 3 beacondata/log.txt
echo
tail -n 3 validatordata/log.txt
