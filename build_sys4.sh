#!/bin/bash
###  InterGenOS_build_002 build_sys4.sh - Continues building InterGen packages
###  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
###  4/16/2015

rm -rf /tmp/* &&

echo " "
echo " "
echo "______________________________________________________________________"
echo " "
echo " Now run 'exit' to drop back into the host system's root terminal,"
echo " and then drop back into the chroot environment with the following"
echo " command:"
echo " "
echo " chroot \"\$IGos\" /usr/bin/env -i              \\"
echo "     HOME=/root TERM=\"\$TERM\" PS1='\\u:\\w\\\$ ' \\"
echo "     PATH=/bin:/usr/bin:/sbin:/usr/sbin     \\"
echo "     /bin/bash --login"
echo " "
echo " Once you're back into the chroot environment, run the following"
echo " command to continue the build:"
echo " "
echo " /bin/bash build_sys5.sh"
echo " "
echo "______________________________________________________________________"
echo " "
echo " "
