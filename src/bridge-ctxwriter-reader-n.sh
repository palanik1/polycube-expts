#!/bin/bash -x 


function add_simplebridges {
	for i in `seq 1 $1`;
	do
		polycubectl simplebridge add br$i type=XDP_SKB loglevel=info
	done
}

function del_simplebridges {
	for i in `seq 1 $1`;
	do
		polycubectl simplebridge del br$i
	done
}

function add_helloworld {
	for i in `seq 1 $1`;
	do
		polycubectl helloworld add hw$i
		polycubectl hw$i set action=forward
	done
}

function del_helloworld {
	for i in `seq 1 $1`;
	do
		polycubectl helloworld del hw$i
	done
}

function add_ctxwriters {
	for i in `seq 1 $1`;
	do
		polycubectl ctxwriter add cw$i type=XDP_SKB loglevel=info
	done
}

function del_ctxwriter {
	for i in `seq 1 $1`;
	do
		polycubectl ctxwriter del cw$i
	done
}

function add_ctxwriter {
	for i in `seq 1 $1`;
	do
		polycubectl ctxwriter add cw$i type=XDP_SKB loglevel=info
	done
}

function del_ctxwriter {
	for i in `seq 1 $1`;
	do
		polycubectl ctxwriter del cw$i
	done
}


function helloworld_add_port {
	polycubectl helloworld $1 ports add $2
	polycubectl helloworld $1 ports $2 set peer=$2
}

function simplebridge_add_port {
	polycubectl simplebridge $1 ports add $2
	polycubectl simplebridge $1 ports $2 set peer=$2
}

function ctxwriter_add_port {
	polycubectl ctxwriter $1 ports add $2
	polycubectl ctxwriter $1 ports $2 set peer=$2
}


function connect_ctxwriter_with_next {
    i=${1}
    j=$((${i}+1))
	polycubectl cw${i} ports add to_cw${j}
	polycubectl cw${j} ports add to_cw${i}
	polycubectl connect cw${i}:to_cw${j} cw${j}:to_cw${i}
}

function connect_ctxwriters {

    for i in `seq 1 $1`;
    do
	connect_ctxwriter_with_next $i
    done
}

function connect_helloworld_with_bridge {
    i=$1
    polycubectl hw${i} ports add to_br1
    polycubectl br1 ports add to_hw${i}
    polycubectl connect hw${i}:to_br1 br1:to_hw${i}
}


function connect_ctxwriter_with_bridge {
    i=$1
    polycubectl cw${i} ports add to_br1
    polycubectl br1 ports add to_cw${i}
    polycubectl connect cw${i}:to_br1 br1:to_cw${i}
}

function set_action_ctxwriter {
    i=$1
    act=$2
    polycubectl cw${i} set action=${act}
}

function create_veth {
	for i in `seq 1 $1`;
	do
		sudo ip netns del ns${i} || true
		sudo ip netns add ns${i}
		sudo ip link add veth${i}_ type veth peer name veth${i}
		sudo ip link set veth${i}_ netns ns${i}
		sudo ip netns exec ns${i} ip link set dev veth${i}_ up
		sudo ip link set dev veth${i} up
		sudo ip netns exec ns${i} ifconfig veth${i}_ 10.0.0.${i}/24
	done
}

function create_veth_no_ipv6 {
	for i in `seq 1 $1`;
	do
		sudo ip netns del ns${i} || true
		sudo ip netns add ns${i}
		sudo ip link add veth${i}_ type veth peer name veth${i}
		sudo ip link set veth${i}_ netns ns${i}
		sudo sysctl -w net.ipv6.conf.veth${i}.disable_ipv6=1
		sudo ip netns exec ns${i} sysctl -w net.ipv6.conf.veth${i}_.disable_ipv6=1
		sudo ip netns exec ns${i} ip link set dev veth${i}_ up
		sudo ip link set dev veth${i} up
		sudo ip netns exec ns${i} ifconfig veth${i}_ 10.0.0.${i}/24
	done
}

function create_link {
	for i in `seq 1 $1`;
	do
		sudo ip link add link${i}1 type veth peer name link${i}2
		sudo ip link set dev link${i}1 up
		sudo ip link set dev link${i}2 up
	done
}

function delete_veth {
	for i in `seq 1 $1`;
	do
		sudo ip link del veth${i}
		sudo ip netns del ns${i}
	done
}

function delete_link {
	for i in `seq 1 $1`;
	do
		sudo ip link del link${i}1
	done
}

#Set up following topology
# veth1 <-> cw1 <-> cw2... <-> cwn+2 <-> br1  <-> veth2
function setup_expt {
    echo "Arg" $1
    j=$((${1}+2))
    echo "j=" ${j}

    add_simplebridges 1

    add_ctxwriters ${j}

    polycubectl cw1 ports add to_veth1 peer=veth1
    polycubectl cw1 set action=WRITE

    polycubectl cw${j} ports add to_br1

    polycubectl br1 ports add to_cw${j}

    polycubectl connect br1:to_cw${j} cw${j}:to_br1
    
    polycubectl br1 ports add to_veth2 peer=veth2

    connect_ctxwriters $((${1}+1))
    k=$((${1}+1))
    for i in $(seq 2 ${k});
        do
	    set_action_ctxwriter ${i} READ
	done

    polycubectl cw${j} set action=WRITE
    #connect_ctxwriter_with_bridge ${j}

    polycubectl cubes show

    #read -n 1 -s

    sudo ip netns exec ns1 ping 10.0.0.2 -c 5
    sudo ip netns exec ns2 ping 10.0.0.1 -c 5

    #run iperf server in ns2
    sudo ip netns exec ns2 iperf3 -s &

    sleep 2

    #run iper client in ns1
    sudo ip netns exec ns1 iperf3 -c 10.0.0.2 -t 60 

    cleanup $1

}

function cleanup {
    #delete
    polycubectl del br1
    del_helloworld $1
}


setup_expt $1

#trap cleanup EXIT

