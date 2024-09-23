all: init

prepare:
	git submodule update --init --recursive

build: prepare
	cd prysm && go build -o=../beacon-chain ./cmd/beacon-chain
	cd prysm && go build -o=../validator ./cmd/validator
	cd prysm && go build -o=../prysmctl ./cmd/prysmctl
	cd go-ethereum && make geth && cp ./build/bin/geth ../geth
	cd rust-ethereum && make build && cp ./target/release/reth ../reth

init:
	bash -x tools/init.sh

start:
	bash -x tools/start.sh

stop:
	bash -x tools/stop.sh
