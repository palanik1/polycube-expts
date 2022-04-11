
polycubectl helloworld add hw1
polycubectl hw1 set action=forward

polycubectl simplebridge add br1

# add ports (only two are supported)
polycubectl hw1 ports add port1 peer=veth1
polycubectl hw1 ports add to_br1

polycubectl br1 ports add to_hw1
polycubectl connect hw1:to_br1 br1:to_hw1


polycubectl br1 ports add to_veth2 peer=veth2

sudo ip netns exec ns1 ping 10.0.0.2 -c 5
sudo ip netns exec ns2 ping 10.0.0.1 -c 5

#run iperf server in ns2
sudo ip netns exec ns2 iperf3 -s &

sleep 2

#run iper client in ns1
sudo ip netns exec ns1 iperf3 -c 10.0.0.2 -t 60 


#delete
polycubectl del br1

polycubectl del hw1
