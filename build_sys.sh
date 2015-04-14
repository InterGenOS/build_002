#!/bin/bash -e
###  InterGenOS_build_002 build_sys.sh - Builds InterGen packages
###  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
###  4/5/2015

## Begin initialize logs

touch /var/log/{btmp,lastlog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

## End initialize logs

## Begin package builds

cd /sources

## Updated kernel to 3.19 ###
#############################
## Linux-3.19 API Headers  ##
## ======================= ##
#############################


tar xf linux-3.19.tar.xz &&
cd linux-3.19/

make mrproper &&

make INSTALL_HDR_PATH=dest headers_install &&

find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* /usr/include

cd .. && rm -rf linux-3.19

COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT

echo "------------------------------------------"
echo "|                                        |"
echo "|  SPACING BEFORE STARTING NEXT PACKAGE  |"
echo "|  ALLOWS FOR EASIER REVIEW OF BUILD     |"
echo "|  OUTPUT                                |"
echo "|                                        |"
echo "------------------------------------------"

COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT


####################
## man-pages-3.79 ##
## ============== ##
####################


tar xf man-pages-3.79.tar.xz &&
cd man-pages-3.79

make install &&

cd .. && rm -rf man-pages-3.79 &&

COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT

echo "------------------------------------------"
echo "|                                        |"
echo "|  SPACING BEFORE STARTING NEXT PACKAGE  |"
echo "|  ALLOWS FOR EASIER REVIEW OF BUILD     |"
echo "|  OUTPUT                                |"
echo "|                                        |"
echo "------------------------------------------"

COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT


################
## glibc-2.21 ##
## ========== ##
################


tar xf glibc-2.21.tar.xz &&
cd glibc-2.21

patch -Np1 -i ../glibc-2.21-fhs-1.patch &&

sed -e '/ia32/s/^/1:/' \
    -e '/SSE2/s/^1://' \
    -i  sysdeps/i386/i686/multiarch/mempcpy_chk.S &&

mkdir -v ../glibc-build
cd ../glibc-build

../glibc-2.21/configure    \
    --prefix=/usr          \
    --disable-profile      \
    --enable-kernel=2.6.32 \
    --enable-obsolete-rpc  \
    --with-pkgversion='InterGenOS GNU/Linux glibc build002'

make &&

make check 2>&1 | tee /glibc-mkck-log_$(date +"%m-%d-%Y_%T") &&

COUNT=15 # Add some blank lines so glibc make check results
#          are easier to see in build output

while [ "$COUNT" -gt "0" ]; do
	echo " "
	let COUNT=COUNT-1
done
unset COUNT

echo " ---------------------------------- "
echo " "
echo " GLIBC MAKE CHECK RESULTS ARE ABOVE "
echo " "
echo " ---------------------------------- "

COUNT=15 # Add some blank lines so glibc make check results
#          are easier to see in build output

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT

touch /etc/ld.so.conf # the install stage of Glibc will complain about 
#                       the absence of /etc/ld.so.conf. Touching the 
#                       file prevents it

make install &&

cp -v ../glibc-2.21/nscd/nscd.conf /etc/nscd.conf

mkdir -pv /var/cache/nscd

install -v -Dm644 ../glibc-2.21/nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
install -v -Dm644 ../glibc-2.21/nscd/nscd.service /lib/systemd/system/nscd.service

mkdir -pv /usr/lib/locale

localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns myhostname
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf ../tzdata2015a.tar.gz

ZONEINFO=/usr/share/zoneinfo

mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO

zic -d $ZONEINFO -p America/New_York

unset ZONEINFO

ln -sfv /usr/share/zoneinfo/America/Chicago /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF

mkdir -pv /etc/ld.so.conf.d

COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT

echo "------------------------------------------"
echo "|                                        |"
echo "|  SPACING BEFORE TOOLCHAIN TESTING      |"
echo "|  ALLOWS FOR EASIER REVIEW OF BUILD     |"
echo "|  OUTPUT                                |"
echo "|                                        |"
echo "------------------------------------------"

COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT


#############################
## Adjusting the Toolchain ##
## ======================= ##
#############################


mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(gcc -dumpmachine)/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld

gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
    `dirname $(gcc --print-libgcc-file-name)`/specs

echo 'main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log

ExpectedA="Requestingprograminterpreter/lib64/ld-linux-x86-64.so.2"
ActualA="$(readelf -l a.out | grep ': /lib' | sed s/://g | cut -d '[' -f 2 | cut -d ']' -f 1 | awk '{print $1$2$3$4}')"

if [ "$ExpectedA" != "$ActualA" ]; then
    echo "!!!!!TOOLCHAIN ADJUSTMENT TEST 1 FAILED!!!!! Halting build, check your work."
    exit 0

else

    COUNT=15 # Add some blank lines so build output
#   	       is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT
    
    echo "TOOLCHAIN ADJUSTMENT TEST 1 PASSED, CONTINUING TESTS"

    COUNT=15 # Add some blank lines so build output
#   	       is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT
fi

cat > tlchn_test2.txt << "EOF"
/usr/lib/../lib64/crt1.o succeeded
/usr/lib/../lib64/crti.o succeeded
/usr/lib/../lib64/crtn.o succeeded
EOF

ExpectedB="$(cat tlchn_test2.txt)"
ActualB="$(grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log)"

        if [ "$ActualB" != "$ExpectedB" ]; then

                echo "!!!!!TOOLCHAIN ADJUSTMENT TEST 2 FAILED!!!!! Halting build, check your work."
                exit 0

        else

		COUNT=15 # Add some blank lines so build output
		#   	   is easier to review

    		while [ "$COUNT" -gt "0" ]; do
    		echo " "
    		let COUNT=COUNT-1
    		done
    		unset COUNT
    		
		echo "TOOLCHAIN ADJUSTMENT TEST 2 PASSED, CONTINUING TESTS"
	
		COUNT=15 # Add some blank lines so build output
		#   	   is easier to review

    		while [ "$COUNT" -gt "0" ]; do
    		echo " "
    		let COUNT=COUNT-1
    		done
    		unset COUNT
	fi

rm tlchn_test2.txt

ExpectedC="/usr/include"
ActualC="$(grep -B1 '^ /usr/include' dummy.log | grep usr | awk '{print $1}')"

if [ "$ExpectedC" != "$ActualC" ]; then
    echo "!!!!!TOOLCHAIN ADJUSTMENT TEST 3 FAILED!!!!! Halting build, check your work."
    exit 0

else

    COUNT=15 # Add some blank lines so build output
#   	       is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT

    echo "TOOLCHAIN ADJUSTMENT TEST 3 PASSED, CONTINUING TESTS"

    COUNT=15 # Add some blank lines so build output
#   	       is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT
fi

cat > tlchn_test4.txt << "EOF"
SEARCH_DIR("=/tools/x86_64-unknown-linux-gnu/lib64")
SEARCH_DIR("/usr/lib")
SEARCH_DIR("/lib")
SEARCH_DIR("=/tools/x86_64-unknown-linux-gnu/lib");
EOF

ExpectedD="$(cat tlchn_test4.txt)"
ActualD="$(grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g')"

if [ "$ExpectedD" != "$ActualD" ]; then
    echo "!!!!!TOOLCHAIN ADJUSTMENT TEST 4 FAILED!!!!! Halting build, check your work."
    exit 0

else

    COUNT=15 # Add some blank lines so build output
#   	       is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT

    echo "TOOLCHAIN ADJUSTMENT TEST 4 PASSED, CONTINUING TESTS"

    COUNT=15 # Add some blank lines so build output
#   	       is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT
fi

rm tlchn_test4.txt

ExpectedE="succeeded"
ActualE="$(grep "/lib.*/libc.so.6 " dummy.log | awk '{print $5}')"

if [ "$ExpectedE" != "$ActualE" ]; then
    echo "!!!!!TOOLCHAIN ADJUSTMENT TEST 5 FAILED!!!!! Halting build, check your work."
    exit 0

else

    COUNT=15 # Add some blank lines so build output
#   	       is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT

    echo "TOOLCHAIN ADJUSTMENT TEST 5 PASSED, CONTINUING TESTS"

    COUNT=15 # Add some blank lines so build output
#   	       is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT
fi

ExpectedF="found ld-linux-x86-64.so.2 at /lib64/ld-linux-x86-64.so.2"
ActualF="$(grep found dummy.log)"

if [ "$ExpectedF" != "$ActualF" ]; then
    echo "!!!!!TOOLCHAIN ADJUSTMENT TEST 6 FAILED!!!!! Halting build, check your work."
    exit 0

else

    COUNT=15 # Add some blank lines so build output
#   	       is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT

    echo "TOOLCHAIN ADJUSTMENT TEST 6 PASSED, CONTINUING BUILD"

    COUNT=15 # Add some blank lines so build output
#   	       is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT
fi

rm -v dummy.c a.out dummy.log

cd .. && rm -rf glibc-2.21 glibc-build/


################
## Zlib-1.2.8 ##
## ========== ##
################


tar xf zlib-1.2.8.tar.xz &&
cd zlib-1.2.8

./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /zlib-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

mv -v /usr/lib/libz.so.* /lib

ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so

cd .. && rm -rf zlib-1.2.8

COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT

echo "------------------------------------------"
echo "|                                        |"
echo "|  SPACING BEFORE STARTING NEXT PACKAGE  |"
echo "|  ALLOWS FOR EASIER REVIEW OF BUILD     |"
echo "|  OUTPUT                                |"
echo "|                                        |"
echo "------------------------------------------"

COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT


###############
## File-5.22 ##
## ========= ##
###############


tar xf file-5.22.tar.gz &&
cd file-5.22

./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /file-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf file-5.22

COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT

echo "------------------------------------------"
echo "|                                        |"
echo "|  SPACING BEFORE STARTING NEXT PACKAGE  |"
echo "|  ALLOWS FOR EASIER REVIEW OF BUILD     |"
echo "|  OUTPUT                                |"
echo "|                                        |"
echo "------------------------------------------"

COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT


###################
## Binutils-2.25 ##
## ============= ##
###################


tar xf binutils-2.25.tar.bz2 &&
cd binutils-2.25

COUNT=5 # Add some blank lines so build output
#         is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT

echo "___________________________________________________________"
echo "|                                                         |"
echo "| Manual PTY Check                                        |"
echo "| ----------------                                        |"
echo "|                                                         |"
echo "| Verify that PTYs are working properly inside the chroot |"
echo "| environment by copy/pasting the following command:      |"
echo "|                                                         |"
echo "| expect -c \"spawn ls\"                                    |"
echo "|                                                         |"
echo "| The command should output the following:                |"
echo "|                                                         |"
echo "| spawn ls                                                |"
echo "|                                                         |"
echo "| If it does not, review the installation logs located at |"
echo "| \$IGos/ as well as the build output to find and correct  |"
echo "| the error. If the command output is correct, copy/paste |"
echo "|                                                         |"
echo "| /bin/bash build_sys2.sh                                 |"
echo "|                                                         |"
echo "| to continue building the system.                        |"
echo "|_________________________________________________________|"

COUNT=5 # Add some blank lines so build output
#         is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT

### 
