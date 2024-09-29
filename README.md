# NBnet-Testnet

> **NOTE: can only run on recent versions of `Ubuntu/Debian/Fedora Linux`.**

### Generate the initial node

```shell
# Only need to execute one time,
# will trigger the `sudo` command.
make prepare

# Create genesis data for the new testnet,
# and create an initial node instance for it.
make create_initial_node

# Start the node.
make start_initial_node

# Stop it.
make stop_initial_node
```
