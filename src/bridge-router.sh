# namespace ns1
#  veth1 10.0.1.1/24
#  default gateway 10.0.1.254
# namespace ns2
#  veth2 10.0.2.1/24
#  default gateway 10.0.2.254
# namespace ns3
#  veth3 10.0.3.1/24
#  default gateway 10.0.3.254

for i in `seq 1 3`;
do
	sudo ip netns del ns${i} > /dev/null 2>&1 # remove ns if already existed
	sudo ip link del veth${i} > /dev/null 2>&1

	sudo ip netns add ns${i}
	sudo ip link add veth${i}_ type veth peer name veth${i}
	sudo ip link set veth${i}_ netns ns${i}
	sudo ip netns exec ns${i} ip link set dev veth${i}_ up
	sudo ip link set dev veth${i} up
	sudo ip netns exec ns${i} ifconfig veth${i}_ 10.0.${i}.1/24
	sudo ip netns exec ns${i} route add default gw 10.0.${i}.254 veth${i}_
done
