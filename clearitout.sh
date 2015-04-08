#!/bin/bash
###  InterGenOS_build_002 clearitout.sh - Completely removes InterGenOS build components from the system
###  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
###  4/8/2015

umount -vl $IGos/dev/pts
umount -vl $IGos/dev
umount -vl $IGos/proc
umount -vl $IGos/sys
umount -vl $IGos/run
rm -rf $IGos/*
umount -vl $IGos
rm -rf $IGos
userdel igos
rm -rf /home/igos
unlink /tools
