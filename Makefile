all: create_initial_node

prepare:
	git submodule update --init --recursive
	cd submodules/egg && make prepare
	rm -rf testdata/bin
	mkdir -p testdata/bin
	cd submodules/lighthouse && make && cp ./target/release/lighthouse ../../testdata/bin/
	cd submodules/reth && make build && cp ./target/release/reth ../../testdata/bin/

genesis:
	cd submodules/egg && make build
	mkdir -p testdata/node
	cp -r submodules/egg/data testdata/node/genesis_data
	bash -x tools/restore_validator_keys.sh

create_initial_node: stop_initial_node genesis
	bash -x tools/init.sh

start_initial_node:
	bash -x tools/start.sh

stop_initial_node:
	bash -x tools/stop.sh

archive_node: stop_initial_node
	sleep 3
	tar -zcpf initial_node.tar.gz testdata

fmt:
	find tools -type f | xargs sed -i 's/\t/    /g'
