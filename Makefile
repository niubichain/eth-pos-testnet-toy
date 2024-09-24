all: init

prepare:
	git submodule update --init --recursive

build: prepare
	cd prysm && go build -o=../prysmctl ./cmd/prysmctl
	cd prysm && go build -o=../beacon-chain ./cmd/beacon-chain
	cd prysm && go build -o=../validator ./cmd/validator
	cd rust-ethereum && make build && cp ./target/release/reth ../
	cd lighthouse && make && cp ./target/release/lighthouse ../lh

init:
	bash -x tools/init.sh

start:
	bash -x tools/start.sh

stop:
	bash -x tools/stop.sh
