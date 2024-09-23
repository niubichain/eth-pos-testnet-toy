#!/bin/bash

pkill validator
sleep 2

pkill beacon-chain
sleep 2

pkill geth
pkill reth
sleep 2

tail -n 2 rethdata/log.txt
echo
tail -n 2 beacondata/log.txt
echo
tail -n 2 validatordata/log.txt
echo
