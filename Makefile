all: create_initial_node

prepare:
	git submodule update --init --recursive

utils: prepare
	mkdir -p testdata/bin
	cd submodules/lighthouse && make && cp ./target/release/lighthouse ../../testdata/bin/
	cd submodules/reth && make build && cp ./target/release/reth ../../testdata/bin/
	cd submodules/go-ethereum && make geth && cp build/bin/geth ../../testdata/bin/

genesis: utils
	cd submodules/egg && make

create_initial_node: genesis
	bash -x tools/init.sh

start_initial_node:
	bash -x tools/start.sh

stop_initial_node:
	bash -x tools/stop.sh
