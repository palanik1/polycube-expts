#!/bin/bash -x 
source ./utils.sh


# Sets up experiment with map1writer1..mapwritern
#Set up following topology
# veth1 <-> mw1_1 <-> mw2_1... <-> mwn+1_1 <-> br1  <-> veth2
function setup_expt_independant {
    echo "Arg" $1
    j=$((${1}+1))
    echo "j=" ${j}

    add_simplebridges 1
    add_mapwriters_independant ${j}

    polycubectl mw1_1 ports add to_veth1 peer=veth1
    polycubectl mw1_1 set action=WRITE

    # polycubectl mw${j} ports add to_br1
    # polycubectl br1 ports add to_mw${j}
    # polycubectl connect br1:to_mw${j} mw${j}:to_br1
    
    polycubectl br1 ports add to_veth2 peer=veth2

    connect_mapwriters_independant $((${1}))
    k=$((${1}+1))
    for i in $(seq 2 ${k});
        do
	    set_action_mapwriter_independant ${i} READ
	done

    #polycubegctl mw${j} set action=WRITE
    connect_mapwriter_independant_with_bridge ${j}

    polycubectl cubes show

    #read -n 1 -s

    sudo ip netns exec ns1 ping ${2}.0.0.2 -c 5
    sudo ip netns exec ns2 ping ${2}.0.0.1 -c 5

    #run iperf server in ns2
    sudo ip netns exec ns2 iperf3 -s -D &

    sleep 2

    #run iper client in ns1
    sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2 -t 60 -A4,4 -P 64 -i 0
    #sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2 -t 60 -A4,5 -P 64

    cleanup $1

}



#Set up following topology
# veth1 <-> mw1 <-> mw2... <-> mwn+1 <-> br1  <-> veth2
function setup_expt {
    echo "Arg" $1
    j=$((${1}+1))
    echo "j=" ${j}

    add_simplebridges 1

    add_mapwriters ${j}

    polycubectl mw1 ports add to_veth1 peer=veth1
    polycubectl mw1 set action=WRITE

    # polycubectl mw${j} ports add to_br1
    # polycubectl br1 ports add to_mw${j}
    # polycubectl connect br1:to_mw${j} mw${j}:to_br1
    
    polycubectl br1 ports add to_veth2 peer=veth2

    connect_mapwriters $((${1}))
    k=$((${1}+1))
    for i in $(seq 2 ${k});
        do
	    set_action_mapwriter ${i} READ
	done

    #polycubectl mw${j} set action=WRITE
    connect_mapwriter_with_bridge ${j}

    polycubectl cubes show

    #read -n 1 -s

    sudo ip netns exec ns1 ping ${2}.0.0.2 -c 5
    sudo ip netns exec ns2 ping ${2}.0.0.1 -c 5

    #run iperf server in ns2
    #sudo ip netns exec ns2 iperf3 -s &
    sudo ip netns exec ns2 iperf3 -s -D &
    
    sleep 2

    #run iper client in ns1
    #sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2 -t 60 
    sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2 -t 60 -A4,4 -P 64 -i 0
    #sudo ip netns exec ns1 iperf3 -c ${2}.0.0.2 -t 60 -A4,5 -P 64
    cleanup $1

}

function cleanup {
    #delete
    polycubectl del br1
    del_helloworld $1
}


#setup_expt $1 $2

setup_expt_independant $1 $2
#trap cleanup EXIT

