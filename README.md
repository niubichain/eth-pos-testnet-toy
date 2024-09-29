# NBnet-Testnet

> **NOTE: can only run on recent versions of `Ubuntu/Debian/Fedora Linux`.**

### Generate the initial node

```shell
# Only need to execute one time,
# will trigger the `sudo` command.
make prepare

# Create genesis data for the new testnet.
make genesis

# Create a new testnet node.
make create_initial_node

# Start the node.
make start_initial_node

# Stop it.
make stop_initial_node
```
