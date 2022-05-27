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

# Add one instance of ctxwriter1..ctxwritern 
function add_ctxwriters_independant {
	for i in `seq 1 $1`;
	do
		polycubectl ctxwriter${i} add cw${i}_1 type=XDP_SKB loglevel=info
	done
}

function add_mapwriters {
	for i in `seq 1 $1`;
	do
		polycubectl mapwriter add mw$i type=XDP_SKB loglevel=info
	done
}


# Add one instance of mapwriter1..mapwritern 
function add_mapwriters_independant {
	for i in `seq 1 $1`;
	do
		polycubectl mapwriter${i} add mw${i}_1 type=XDP_SKB loglevel=info
	done
}

function del_ctxwriter {
	for i in `seq 1 $1`;
	do
		polycubectl ctxwriter del cw$i
	done
}

#Delete instance of type ctxwriter1...ctxwritern
function del_ctxwriter_independant {
	for i in `seq 1 $1`;
	do
		polycubectl ctxwriter${i} del cw${i}_1
	done
}

function del_mapwriter {
	for i in `seq 1 $1`;
	do
		polycubectl mapwriter del mw$i
	done
}


#Delete instance of type mapwriter1...mapwritern
function del_mapwriter_independant {
	for i in `seq 1 $1`;
	do
		polycubectl mapwriter${i} del mw${i}_1
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
    polycubectl cw${i} port
    s add to_cw${j}
	polycubectl cw${j} ports add to_cw${i}
	polycubectl connect cw${i}:to_cw${j} cw${j}:to_cw${i}
}

function connect_ctxwriters {

    for i in `seq 1 $1`;
    do
	connect_ctxwriter_with_next $i
    done
}


function connect_ctxwriter_independant_with_next {
    i=${1}
    j=$((${i}+1))
	polycubectl cw${i}_1 ports add to_cw${j}
	polycubectl cw${j}_1 ports add to_cw${i}
	polycubectl connect cw${i}_1:to_cw${j} cw${j}_1:to_cw${i}
}

function connect_ctxwriters_independant {

    for i in `seq 1 $1`;
    do
	connect_ctxwriter_independant_with_next $i
    done
}

function connect_mapwriter_with_next {
    i=${1}
    j=$((${i}+1))
	polycubectl mw${i} ports add to_mw${j}
	polycubectl mw${j} ports add to_mw${i}
	polycubectl connect mw${i}:to_mw${j} mw${j}:to_mw${i}
}

function connect_mapwriters {

    for i in `seq 1 $1`;
    do
	connect_mapwriter_with_next $i
    done
}

function connect_mapwriter_independant_with_next {
    i=${1}
    j=$((${i}+1))
	polycubectl mw${i}_1 ports add to_mw${j}
	polycubectl mw${j}_1 ports add to_mw${i}
	polycubectl connect mw${i}_1:to_mw${j} mw${j}_1:to_mw${i}
}

function connect_mapwriters_independant {

    for i in `seq 1 $1`;
    do
	connect_mapwriter_independant_with_next $i
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

function connect_ctxwriter_independant_with_bridge {
    i=$1
    polycubectl cw${i}_1 ports add to_br1
    polycubectl br1 ports add to_cw${i}
    polycubectl connect cw${i}_1:to_br1 br1:to_cw${i}
}

function connect_mapwriter_with_bridge {
    i=$1
    polycubectl mw${i} ports add to_br1
    polycubectl br1 ports add to_mw${i}
    polycubectl connect mw${i}:to_br1 br1:to_mw${i}
}



function connect_mapwriter_independant_with_bridge {
    i=$1
    polycubectl mw${i}_1 ports add to_br1
    polycubectl br1 ports add to_mw${i}
    polycubectl connect mw${i}_1:to_br1 br1:to_mw${i}
}



function set_action_ctxwriter {
    i=$1
    act=$2
    polycubectl cw${i} set action=${act}
}

function set_action_ctxwriter_independant {
    i=$1
    act=$2
    polycubectl cw${i}_1 set action=${act}
}

function set_action_mapwriter {
    i=$1
    act=$2
    polycubectl mw${i} set action=${act}
}


function set_action_mapwriter_independant {
    i=$1
    act=$2
    polycubectl mw${i}_1 set action=${act}
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
		sudo ip netns exec ns${i} ifconfig veth${i}_ ${2}.0.0.${i}/24
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
		sudo ip netns exec ns${i} ifconfig veth${i}_ ${2}.0.0.${i}/24
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
