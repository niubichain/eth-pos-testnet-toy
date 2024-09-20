#!/bin/bash

pkill geth
sleep 1

pkill beacon-chain
sleep 1

pkill validator
sleep 1

sleep 2

tail -n 3 gethdata/log.txt
tail -n 3 beacondata/log.txt
tail -n 3 validatordata/log.txt
