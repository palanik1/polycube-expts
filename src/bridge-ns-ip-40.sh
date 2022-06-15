# namespace ns1 -> veth1 40.0.1.11/24
# namespace ns2 -> veth2 40.0.1.12/24
#tbr1 -> 40.0.1.10
#https://ops.tips/blog/using-network-namespaces-and-bridge-to-isolate-servers/

function clean {
    clean_br

    sudo ip netns del ns1
    sudo ip netns del ns2
    sudo ip link del veth1
    sudo ip link del veth2
}

function clean_br {
    sudo ifconfig tbr1 down	
    sudo brctl delif tbr1 veth1
    sudo brctl delif tbr1 veth2
    sudo brctl delbr tbr1
}

#set up bridge and connect veths
function add_br {
    clean_br 
    sudo brctl addbr tbr1
    sudo ip addr add 40.0.1.10/24 brd + dev tbr1

    sudo brctl show
    sudo ip link set veth1 master tbr1 
    sudo ip link set veth2 master tbr1
    sudo brctl showmacs tbr1
    #sudo ifconfig veth1 0.0.0.0
    #sudo ifconfig veth2 0.0.0.0
    sudo ifconfig tbr1 up
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
    sudo ip netns exec ns${i} ifconfig veth${i}_ 40.0.1.1${i}/24
    #sudo ifconfig veth${i} 40.0.${i}.1/24
    #sudo ip netns exec ns${i} route add  default gw 40.0.1.${i} veth${i}_
done


# add bridges
add_br

# run iperf server in ns2 and client in ns1
sudo ip netns exec ns2 iperf3 -s &

sleep 2

sudo ip netns exec ns1 iperf3 -c 40.0.1.12 -t 30

read

clean



