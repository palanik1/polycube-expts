# namespace ns1 -> veth1 40.0.1.2/24
# namespace ns2 -> veth2 40.0.2.2/24


function clean {
    sudo ip netns del ns1
    sudo ip netns del ns2
    sudo ip link del veth1
    sudo ip link del veth2

}


for i in `seq 1 2`;
do
    sudo ip netns del ns${i} > /dev/null 2>&1 # remove ns if already existed
    sudo ip link del veth${i} > /dev/null 2>&1

    sudo ip netns add ns${i}
    sudo ip link add veth${i}_ type veth peer name veth${i}
    sudo ip link set veth${i}_ netns ns${i}
    sudo ip netns exec ns${i} ip link set dev veth${i}_ up
    sudo ip netns exec ns${i} ip link set dev lo up
    sudo ip link set dev veth${i} up
    sudo ip netns exec ns${i} ifconfig veth${i}_ 40.0.${i}.2/24
    sudo ifconfig veth${i} 40.0.${i}.1/24
    sudo ip netns exec ns${i} route add  default gw 40.0.${i}.1 veth${i}_
done


# run iperf server in ns2 and client in ns1

sudo ip netns exec ns2 iperf3 -s &

sleep 2

sudo ip netns exec ns1 iperf3 -c 40.0.2.2 -t 30

clean


