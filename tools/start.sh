#!/bin/bash

pkill validator
sleep 2

pkill beacon-chain
sleep 2

pkill geth
pkill reth
sleep 2

nohup ./reth node --chain=genesis.json --http --http.addr=0.0.0.0 --http.corsdomain=* --http.api="admin,net,eth,web3,debug,trace,txpool" --ws --ws.addr=0.0.0.0 --ws.origins=* --ws.api="eth,net" --authrpc.jwtsecret=jwt.hex --datadir=rethdata --disable-discovery >rethdata/log.txt 2>&1 &

nohup ./beacon-chain --datadir beacondata --min-sync-peers 0 --genesis-state genesis.ssz --bootstrap-node= --interop-eth1data-votes --chain-config-file config.yml --contract-deployment-block 0 --chain-id 9527000 --accept-terms-of-use --jwt-secret jwt.hex --suggested-fee-recipient 0x123463a4B065722E99115D6c222f267d9cABb524 --minimum-peers-per-subnet 0 --enable-debug-rpc-endpoints --execution-endpoint http://localhost:8551 >beacondata/log.txt 2>&1 &

nohup ./validator --datadir validatordata --accept-terms-of-use --interop-num-validators 64 --chain-config-file config.yml >validatordata/log.txt 2>&1 &

sleep 2

tail -n 2 gethdata/log.txt
echo
tail -n 2 beacondata/log.txt
echo
tail -n 2 validatordata/log.txt
echo
