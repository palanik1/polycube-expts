polycubectl simplebridge add br1
polycubectl br1 ports add toveth2 peer=veth2
polycubectl br1 ports add toveth1 peer=veth1
sudo ip netns exec ns1 ping 10.0.0.2 -c 5
sudo ip netns exec ns2 ping 10.0.0.1 -c 5

#run iperf server in ns2
sudo ip netns exec ns2 iperf3 -s &
sleep 2
#run iper client in ns1
sudo ip netns exec ns1 iperf3 -c 10.0.0.2 -t 60


#cleanup
polycubectl del br1
