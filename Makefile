all: create_initial_node

prepare:
	git submodule update --init --recursive
	cd submodules/egg && make prepare

utils:
	rm -rf testdata
	mkdir -p testdata/bin
	cd submodules/lighthouse && make && cp ./target/release/lighthouse ../../testdata/bin/
	cd submodules/reth && make build && cp ./target/release/reth ../../testdata/bin/
	cd submodules/go-ethereum && make geth && cp build/bin/geth ../../testdata/bin/

genesis: utils
	cd submodules/egg && make build
	mkdir -p testdata/node
	cp -r submodules/egg/data testdata/node/genesis_data

restore_validator_keys: genesis
	bash -x tools/restore_validator_keys.sh

create_initial_node: genesis
	bash -x tools/init.sh

start_initial_node:
	bash -x tools/start.sh

stop_initial_node:
	bash -x tools/stop.sh
