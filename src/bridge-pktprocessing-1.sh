source ./utils.sh
echo "Module Name" $1
echo "IP Subnet " $2
setup_bridge_with_module $1 $2
