#!/bin/bash
###  InterGenOS_build_002 setup_chroot.sh - Setup chroot for basic system build
###  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
###  4/5/2015

chown -R root:root $IGos/tools # close security hole by moving tools dir ownership from user igos to root

## Begin chroot setup

mkdir -pv $IGos/{dev,proc,sys,run} 

mknod -m 600 $IGos/dev/console c 5 1

mknod -m 666 $IGos/dev/null c 1 3

mount -v --bind /dev $IGos/dev

mount -vt devpts devpts $IGos/dev/pts -o gid=5,mode=620

mount -vt proc proc $IGos/proc

mount -vt sysfs sysfs $IGos/sys

mount -vt tmpfs tmpfs $IGos/run

if [ -h $IGos/dev/shm ]; then
  mkdir -pv $IGos/$(readlink $IGos/dev/shm)
fi

## End chroot setup

wget https://raw.githubusercontent.com/InterGenOS/build_002/master/setup_structure.sh -P $IGos
wget https://raw.githubusercontent.com/InterGenOS/build_002/master/build.sh -P $IGos

echo " "
echo " "
echo " "
echo " "
echo "----------------------------------------------------------"
echo "                                                        "
echo "  Copy and paste the following command to enter chroot  "
echo "  and continue build                                    "
echo "                                                        "
echo -e "  chroot \"\$IGos\" /tools/bin/env -i \\"
echo -e "      HOME=/root                  \\"
echo -e "      TERM=\"\$TERM\"                \\"
echo -e "      PS1='\u:\w\\\$ '              \\"
echo -e "      PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \\"
echo -e "      /tools/bin/bash --login +h"
echo "                                                        "
echo "  The prompt will say  'I have no name'  but will       "
echo "  change to  'root'  as soon as you run                 "
echo "                                                        "
echo "  /tools/bin/bash setup_structure.sh                    "
echo "                                                        "
echo "  in the chroot environment                             "
echo "----------------------------------------------------------"
echo " "
echo " "
echo " "
echo " "
