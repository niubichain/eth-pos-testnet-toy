all: init

prepare:
	git submodule update --init --recursive

build: prepare
	mkdir -p testdata/bin
	cd submodules/lighthouse && make && cp ./target/release/lighthouse ../../testdata/bin/
	cd submodules/reth && make build && cp ./target/release/reth ../../testdata/bin/
	cd submodules/go-ethereum && make geth && cp build/bin/geth ../../testdata/bin/

init:
	bash -x tools/init.sh

start:
	bash -x tools/start.sh

stop:
	bash -x tools/stop.sh
