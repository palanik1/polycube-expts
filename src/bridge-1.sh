source ./utils.sh

#Set up following topology
# veth1 <-> cf1 <-> veth2
function setup_expt {
    echo "Arg" $1
    j=${1}
     #Make j = 1
    j=1
    echo "j=" ${1}

    #start_polycube

    #sleep 5
    
    #Add cflare modules

    prefix="br"
    add_modules "simplebridge" ${prefix} ${j} XDP_SKB
    polycubectl ${prefix}1 ports add to_veth1 peer=veth1
    polycubectl ${prefix}1 ports add to_veth2 peer=veth2

    polycubectl show topology
    
    sudo ip netns exec ns1 ping ${2}.0.0.2 -c 5
    sudo ip netns exec ns2 ping ${2}.0.0.1 -c 5

    #run iperf server in ns2 
    sudo ip netns exec ns2 iperf3 -s -D -p 5101 &
    #sudo ip netns exec ns2 iperf3 -s -D -p 5102 &

    sleep 2

    #run iper client in ns1
    #sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2 -t 60 -A4,4 -P 64 -i 0
    #sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2 -t 60 -A4,5 -P 64

    #TCP
    #sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2 -t 60

    #UDP
    #sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2 -t 60 -u -b 0

    #set pkt size to 200B
    sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2  -p 5101 -t 60 -u -b 0 
    #sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2 -T s2 -p 5102 -t 60 -u -l 64B -b 0 -A2,3 
    
    cleanup "packetprocessing" ${prefix} ${j}

}

function cleanup {
    #delete
    polycubectl del br1
    del_modules ${1} ${2} ${3}
    #kill_polycube
}

function usage {

    echo "Usage: sudo bash <script> count ip_cidr"
    }
setup_expt $1 $2


