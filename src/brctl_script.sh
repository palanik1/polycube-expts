# Making use of the `ip` command from the `iproute2` 
# package we're able to create the namespaces.
#
# By convention, network namespace handles created by
# iproute2 live under `/var/run/netns` (although they
# could live somewhere, like `docker` does with its
# namespaces - /var/run/docker/netns`).
ip netns add namespace1
ip netns add namespace2
# Create the two pairs.
ip link add inner-veth1 type veth peer name br-veth1
ip link add inner-veth2 type veth peer name br-veth2

# Associate the non `br-` side
# with the corresponding namespace
ip link set inner-veth1 netns namespace1
ip link set inner-veth2 netns namespace2
# Assign the address 192.168.1.11 with netmask 255.255.255.0
# (see the `/24` mask there) to `inner-veth1`.
ip netns exec namespace1 ip addr add 192.168.1.11/24 dev inner-veth1
# Repeat the process, assigning the address 192.168.1.12 with 
# netmask 255.255.255.0 to `inner-veth2`.
ip netns exec namespace2 ip addr add 192.168.1.12/24 dev inner-veth2
# Create the bridge device naming it `br1`
# and set it up:
ip link add name br1 type bridge
ip link set br1 up

# Set the bridge veths from the default
# namespace up.
ip link set br-veth1 up
ip link set br-veth2 up

# Set the veths from the namespaces up too.
ip netns exec namespace1 ip link set inner-veth1 up
ip netns exec namespace2 ip link set inner-veth2 up

# Add the br-veth* interfaces to the bridge
# by setting the bridge device as their master.
ip link set br-veth1 master br1
ip link set br-veth2 master br1

# Set the address of the `br1` interface (bridge device)
# to 192.168.1.10/24 and also set the broadcast address
# to 192.168.1.255 (the `+` symbol sets  the host bits to
# 255).
ip addr add 192.168.1.10/24 brd + dev br1

# We can also reach the interface of the other namespace
# given that we have a route to it.
#ip netns exec namespace1 ip route 

#192.168.1.0/24 dev inner-veth1 proto kernel scope link src 192.168.1.11
