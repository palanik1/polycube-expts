# Add qdisc to interface
function add_qdisc {
    iface=$1
    echo "IFACE: ${iface} \n"
    tc qdisc add dev ${iface} clsact
}


function del_qdisc {
    iface=$1
    echo "IFACE: ${iface} \n"
    tc qdisc del dev ${iface} clsact
}


# Attach TC to interface
function attach_to_filter {
iface=${1}
prog=${2}
sec=${3}
count=${4}
for i in `seq 1 ${count}`;

    do
	sudo tc filter add dev ${iface} ingress bpf da obj ${prog} sec ${sec}
    done

}

function clean {
    del_qdisc $1
}

function setup_expt {
    add_qdisc $1
    attach_to_filter $1 $2 $3 $4
}

# script <iface> <prog> <sec> <ct>
setup_expt $1 $2 $3 $4
