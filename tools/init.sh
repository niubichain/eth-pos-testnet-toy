#!/bin/bash

pkill validator
pkill beacon-chain
pkill reth

sleep 2

rm -rf *data

mkdir rethdata beacondata validatordata || exit 1

./prysmctl testnet generate-genesis --fork capella --num-validators 64 --genesis-time-delay 10 --config-name interop --chain-config-file config.yml --geth-genesis-json-in genesis.json --geth-genesis-json-out genesis.json --output-ssz genesis.ssz --output-json genesis.ssz.json || exit 1

./reth init --datadir=rethdata --chain=genesis.json || exit 1

nohup ./reth node --chain=genesis.json --ipcdisable --http --http.addr=0.0.0.0 --http.corsdomain=* --http.api="admin,net,eth,web3,debug,trace,txpool" --ws --ws.addr=0.0.0.0 --ws.origins=* --ws.api="eth,net" --authrpc.jwtsecret=jwt.hex --datadir=rethdata --disable-discovery >rethdata/log.txt 2>&1 &

nohup ./beacon-chain --datadir beacondata --min-sync-peers 0 --genesis-state genesis.ssz --bootstrap-node= --interop-eth1data-votes --chain-config-file config.yml --contract-deployment-block 0 --chain-id 9527000 --accept-terms-of-use --jwt-secret jwt.hex --suggested-fee-recipient 0x123463a4B065722E99115D6c222f267d9cABb524 --minimum-peers-per-subnet 0 --enable-debug-rpc-endpoints --execution-endpoint http://localhost:8551 >beacondata/log.txt 2>&1 &

# nohup ./lh beacon_node --testnet-dir=. --datadir=beacondata --boot-nodes="" --listen-address=0.0.0.0 --http --http-address=0.0.0.0 --http-allow-sync-stalled --execution-endpoints="http://localhost:8551" --jwt-secrets="jwt.hex" --suggested-fee-recipient="0x123463a4B065722E99115D6c222f267d9cABb524" --target-peers=0 >beacondata/log.txt 2>&1 &

nohup ./validator --datadir validatordata --accept-terms-of-use --interop-num-validators 64 --chain-config-file config.yml >validatordata/log.txt 2>&1 &
# nohup ./lh vc --testnet-dir=. --datadir=validatordata --init-slashing-protection --beacon-nodes="http://localhost:9001" --suggested-fee-recipient="0x123463a4B065722E99115D6c222f267d9cABb524" >validatordata/log.txt 2>&1 &

sleep 2

tail -n 3 rethdata/log.txt
echo
tail -n 3 beacondata/log.txt
echo
tail -n 3 validatordata/log.txt
