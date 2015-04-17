#!/bin/bash
###  InterGenOS_build_002 build_sys5.sh - Continues building InterGen packages
###  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
###  4/16/2015

rm -rf /tools &&

cat > /etc/systemd/network/10-dhcp-eth0.network << "EOF"
[Match]
Name=eth0

[Network]
DHCP=yes
EOF
