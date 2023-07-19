#!/bin/bash

# Function to display error message and exit
error_exit() {
  echo "$1" >&2
  exit 1
}

# Display help menu
display_help() {
  echo "Usage: $0 [OPTION...]"
  echo "  --interface  Interface name (e.g. eth0)"
  echo "  --mac        MAC address (e.g. 00:11:22:33:44:55)"
  echo "  --ip         IP address (e.g. 192.168.1.100)"
  echo "  --gateway    Gateway IP address (e.g. 192.168.1.1)"
  echo "  --netmask    Netmask (e.g. 24)"
  echo "  --vlan       VLAN tag (e.g. 100) [Optional]"
  echo "  -h, --help   Display this help menu and exit"
}

# Get command line arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --interface) interface="$2"; shift 2;;
    --mac) mac="$2"; shift 2;;
    --ip) ip="$2"; shift 2;;
    --gateway) gateway="$2"; shift 2;;
    --netmask) netmask="$2"; shift 2;;
    --vlan) vlan="$2"; shift 2;;
    -h|--help) display_help; exit 0;;
    *) error_exit "Unknown option: $1";;
  esac
done

# Verify that all required arguments are supplied
if [ -z "$interface" ]; then
  error_exit "Missing required argument: --interface"
elif [ -z "$mac" ]; then
  error_exit "Missing required argument: --mac"
elif [ -z "$ip" ]; then
  error_exit "Missing required argument: --ip"
elif [ -z "$gateway" ]; then
  error_exit "Missing required argument: --gateway"
elif [ -z "$netmask" ]; then
  error_exit "Missing required argument: --netmask"
fi

# Flush
ip addr flush dev "$interface" || error_exit "Failed to flush the interface"

# Set static data
ifconfig "$interface" "$ip" netmask "$netmask" || error_exit "Failed to set data to interface"

# Bring down the interface
ip link set "$interface" down || error_exit "Failed to bring down interface"

# Change MAC address
macchanger -m "$mac" "$interface"
echo "MAC address change complete"

# Bring up interface
ip link set "$interface" up || error_exit "Failed to bring up interface"

# Setup VLAN tag interface
if [ -n "$vlan" ]; then
  flag_vlan=true
  echo "Setting up 802.1q VLAN tagging by loading 8021q Linux kernel driver"
  modprobe 8021q

  echo "Setting VLAN tag: $vlan"
  vlan_interface="$interface.$vlan"
  ip link add link "$interface" name "$vlan_interface" type vlan id "$vlan" || error_exit "Failed to set VLAN tag"
	
	# Bring up vlan interface
  ip link set "$vlan_interface" up
  
  ifconfig "$vlan_interface" "$ip" netmask "$netmask" || error_exit "Failed to to create vlan interface"
else
  vlan_interface="$interface"
fi

echo "Setting up routing: $gateway"
route add default gw "$gateway" "$vlan_interface" || error_exit "Failed to set gateway"

ip_mask="$(echo $ip | cut -d '.' -f-3).0/24"
[ "$flag_vlan" = "true" ] && route del -net "$ip_mask"
exit 0
