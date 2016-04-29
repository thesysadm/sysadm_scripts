#!/bin/bash
if ! `grep -q -i zHWADDR /etc/sysconfig/network-scripts/ifcfg-eth0`; then
echo -e "HWADDR=`cat /sys/class/net/eth0/address`\n$(cat /etc/sysconfig/network-scripts/ifcfg-eth0)" > /etc/sysconfig/network-scripts/ifcfg-eth0
fi

if ! `grep -q -i zHWADDR /etc/sysconfig/network-scripts/ifcfg-eth1`; then
echo -e "HWADDR=`cat /sys/class/net/eth1/address`\n$(cat /etc/sysconfig/network-scripts/ifcfg-eth1)" > /etc/sysconfig/network-scripts/ifcfg-eth1
fi

