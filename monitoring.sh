#!/bin/sh

#echo "Broadcast message from root@$(hostname) (tty1) ($(date +"%a %d %b %Y %T %Z")):"
#echo
#echo "  #OS: $(lsb_release -d | awk '{print $2, $3}')"
echo "  #Architecture: $(uname -a | tr '\n' ' ')"
echo
echo "  #Physical processors: $(grep -c ^processor /proc/cpuinfo)"
echo "  #Virtual processors: $(grep -c ^processor /proc/cpuinfo)"
MEMINFO=$(free -m | grep Mem)
echo "  #Available RAM: $(echo $MEMINFO | awk '{print $7}')MB / $(echo $MEMINFO | awk '{print $2}')MB ($(echo $MEMINFO | awk '{print $3/$2 * 100.0}')%)"
DISKINFO=$(df -H / | grep /)
echo "  #Available storage: $(echo $DISKINFO | awk '{print $4}') / $(echo $DISKINFO | awk '{print $2}') ($(echo $DISKINFO | awk '{print $5}'))"
echo "  #Processors utilization rate: $(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}')"
echo
echo "  #Last reboot: $(who -b | awk '{print $3}') $(who -b | awk '{print $4}')"
LVMINFO=$(lsblk | grep lvm | wc -l)
LVMUSING="no"
if [ $LVMINFO -gt 0 ]; then
	LVMUSING="yes"
fi
echo "  #LVM active: $LVMINFO ($LVMUSING)"
echo "  #Active TCP connections: $(ss -s | grep -c TCP)"
echo "  #Users: $(who | wc -l)"
echo "  #IPv4: $(hostname -I)"
echo "  #MAC: $(ip link show | awk '/ether/ {print $2}' | tr '\n' ' ')"
echo "  #Sudo: $(cat /var/log/sudo/sudo.log | grep -c COMMAND) commands"
#echo
