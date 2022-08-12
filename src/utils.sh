#!/bin/bash -x 

function start_polycube {
    kill_polycube
    polycubed --loglevel=debug &
}

function kill_polycube {
    killall polycubed
}

function run_iperf3_server {
    ns_id=${1}
    port=${2}
    ip netns exec ${ns_id} iperf3 -s -D -p ${port} &

}

function run_iperf3_client {
    ns_id=${1}
    server_ip=${2}
    port=${3}
    mode=${4}
    if [ -z "${mode}" ]
    then
	ip netns exec ${ns_id} iperf3 -c ${server_ip}  -p ${port} -t 60  -l 64B -b 0
    else
	ip netns exec ${ns_id} iperf3 -c ${server_ip}  -p ${port} -t 60 -u -l 64B -b 0 
    fi
    
}

function setup_bridge_with_module {
   polycubectl ${1} add hw1 type=XDP_SKB loglevel=off
   #polycubectl hw1 set action=forward

   polycubectl simplebridge add br1 type=XDP_SKB loglevel=off

   # add ports (only two are supported)
   polycubectl hw1 ports add port1 peer=veth1
   polycubectl hw1 ports add to_br1

   polycubectl br1 ports add to_hw1
   polycubectl connect hw1:to_br1 br1:to_hw1


   polycubectl br1 ports add to_veth2 peer=veth2

   sudo ip netns exec ns1 ping ${2}.0.0.2 -c 5
   sudo ip netns exec ns2 ping ${2}.0.0.1 -c 5

   #run iperf server in ns2
   sudo ip netns exec ns2 iperf3 -s &

   sleep 2

   #run iper client in ns1
   sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2 -t 60 


   #delete
   polycubectl del br1

   polycubectl del hw1

}

function setup_bridge {

   polycubectl simplebridge add br1 type=TC loglevel=off

   polycubectl br1 ports add to_veth1 peer=veth1
   polycubectl br1 ports add to_veth2 peer=veth2

   sudo ip netns exec ns1 ping ${1}.0.0.2 -c 5
   sudo ip netns exec ns2 ping ${1}.0.0.1 -c 5

   #run iperf server in ns2
   sudo ip netns exec ns2 iperf3 -s &

   sleep 2

   #run iper client in ns1
   sudo ip netns exec ns1 iperf3 -c ${1}.0.0.2 -t 60 


   #delete
   polycubectl del br1
 
}


function setup_helloworld {
   #polycubectl helloworld add hw1 type=TC loglevel=off
    #polycubectl helloworld add hw1 type=TC loglevel=off
    polycubectl helloworld add hw1 type=TC loglevel=off

   polycubectl hw1 set action=forward
   
   polycubectl hw1 ports add to_veth1 peer=veth1
   polycubectl hw1 ports add to_veth2 peer=veth2

   sudo ip netns exec ns1 ping ${1}.0.0.2 -c 5
   sudo ip netns exec ns2 ping ${1}.0.0.1 -c 5

   #run iperf server in ns2
   sudo ip netns exec ns2 iperf3 -s &

   sleep 2

   #run iper client in ns1
   sudo ip netns exec ns1 iperf3 -c ${1}.0.0.2 -t 60 
   #udp
   #sudo ip netns exec ns1 iperf3 -c ${1}.0.0.2 -t 60 -u -b 0 

   #delete
   polycubectl del hw1
}

function add_modules {
    echo "ADD MODULES MODULE_TYPE ${1} MODULE_PREFIX ${2} COUNT ${3} MODE ${4}"
    prefix=${2}
    MODE=${4}
    for i in `seq 1 $3`;
    do
	if [[ ${MODE} = "TC" ]]
	then
	    polycubectl ${1} add ${prefix}$i type=TC loglevel=off
	    #polycubectl ${1} add ${prefix}$i type=TC loglevel=debug
	else
	    polycubectl ${1} add ${prefix}$i type=XDP_SKB loglevel=off
	    #polycubectl ${1} add ${prefix}$i type=XDP_SKB loglevel=debug
	fi
	
    done
}


function del_modules {
    echo "DELETE MODULES MODULE_TYPE ${1} MODULE_PREFIX ${2} COUNT ${3}"
    prefix=${2}
    for i in `seq 1 $3`;
	do
		polycubectl ${1} del ${prefix}$i 
	done
}


function add_simplebridges {
    mode=${2}
    if [ -z "${mode}" ]
    then mode=TC
    fi
    
    for i in `seq 1 $1`;
	do
		polycubectl simplebridge add br$i type=${mode} loglevel=off
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
		polycubectl ctxwriter add cw$i type=XDP_SKB loglevel=off
	done
}

# Add one instance of ctxwriter1..ctxwritern 
function add_ctxwriters_independant {
	for i in `seq 1 $1`;
	do
		polycubectl ctxwriter${i} add cw${i}_1 type=TC loglevel=off
	done
}

function add_mapwriters {
	for i in `seq 1 $1`;
	do
	    polycubectl mapwriter add mw$i type=TC loglevel=off
	    #polycubectl mapwriter add mw$i type=TC loglevel=debug
	done
}


# Add one instance of mapwriter1..mapwritern 
function add_mapwriters_independant {
	for i in `seq 1 $1`;
	do
		polycubectl mapwriter${i} add mw${i}_1 type=TC loglevel=off
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

function connect_module_with_next {
    i=${1}
    j=$((${i}+1))
    prefix=${2}
    polycubectl ${prefix}${i} ports add to_${prefix}${j}
    polycubectl ${prefix}${j} ports add to_${prefix}${i}
    polycubectl connect ${prefix}${i}:to_${prefix}${j} ${prefix}${j}:to_${prefix}${i}
 }

function connect_modules {

    prefix=${2}
    for i in `seq 1 $1`;
    do
	connect_module_with_next $i ${prefix}
    done
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

function connect_module_with_bridge {
    i=$1
    prefix=${2}
    polycubectl ${prefix}${i} ports add to_br1
    polycubectl br1 ports add to_${prefix}${i}
    echo " Conencting to Bridge: polycubectl connect ${prefix}${i}:to_br1 br1:to_${prefix}${i} "
    polycubectl connect ${prefix}${i}:to_br1 br1:to_${prefix}${i}
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

