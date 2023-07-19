# NAC_Bypass
Bypass NAC script to set permanent ip address, change MAC address and add VLAN tag (optional!)

## Usage:
```
./NAC_Bypass.sh --interface eth0 --mac e6:26:a9:9a:03:07 --ip 10.140.251.204 --gateway 10.140.251.1 --netmask 255.255.255.0 --vlan 1001

Help Menu:
./NAC_Bypass.sh -h
Usage: ./NAC_Bypass.sh [OPTIONS...]
  --interface  Interface name (e.g. eth0)
  --mac        MAC address (e.g. 00:11:22:33:44:55)
  --ip         IP address (e.g. 192.168.1.100)
  --gateway    Gateway IP address (e.g. 192.168.1.1)
  --netmask    Netmask (e.g. 24)
  --vlan       VLAN tag (e.g. 100) [Optional]
  -h, --help   Display this help menu and exit
```
