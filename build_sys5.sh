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

# Updates to follow -4-16-15
# --------------------------
#
# To do:
# ==========================
#
# /etc/resolv.conf
# /etc/hostname
# /etc/hosts
# blacklist forte in /etc/modprobe.d/blacklist.conf
# /etc/adjtime
# systemd-timesyncd
# /etc/vconsole.conf (notes in InterGen's ownCloud)
# Configure system locale
# /etc/inputrc
# /etc/shells
# /etc/skel
# Take a vote for screen clearing at boot
# Disable tmpfs for /tmp
# /etc/fstab
# Compile Kernel ****KEEP BUILD DIRECTORY!****
# (It's needed for Realtek driver compilation)
# GRUB (can re-use template from build_001)
# /etc/os-release
# /etc/lsb-release
# Begin Linpack Pkg Generation
# Script core FS layout
