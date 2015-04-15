#!/bin/bash
###  InterGenOS_build_002 build_sys3.sh - Continues building InterGen packages
###  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
###  4/14/2015

echo \# > /root/.bash_profile

cd /sources

rm -rf bash-4.3.30/


################
## Bc-1.06.95 ##
## ========== ##
################


tar xf bc-1.06.95.tar.bz2 &&
cd bc-1.06.95/

patch -Np1 -i ../bc-1.06.95-memory_leak-1.patch

./configure --prefix=/usr           \
            --with-readline         \
            --mandir=/usr/share/man \
            --infodir=/usr/share/info &&

make &&

echo "quit" | ./bc/bc -l Test/checklib.b >> /bc-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf bc-1.06.95/


###################
## Libtool-2.4.6 ##
## ============= ##
###################


tar xf libtool-2.4.6.tar.xz &&
cd libtool-2.4.6/

./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /libtool-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf libtool-2.4.6/


###############
## GDBM-1.11 ##
## ========= ##
###############


tar xf gdbm-1.11.tar.gz &&
cd gdbm-1.11/

./configure --prefix=/usr --enable-libgdbm-compat &&

make &&

make check 2>&1 | tee /gdbm-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf gdbm-1.11/


#################
## Expat-2.1.0 ##
## =========== ##
#################


tar xf expat-2.1.0.tar.gz &&
cd expat-2.1.0/

./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /expat-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf expat-2.1.0/


#####################
## Inetutils-1.9.2 ##
## =============== ##
#####################


tar xf inetutils-1.9.2.tar.gz &&
cd inetutils-1.9.2/

echo '#define PATH_PROCNET_DEV "/proc/net/dev"' >> ifconfig/system/linux.h

./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-servers &&

make &&

make check 2>&1 | tee /inetutils-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin &&
mv -v /usr/bin/ifconfig /sbin &&

cd .. && rm -rf inetutils-1.9.2/


#################
## Perl-5.20.2 ##
## =========== ##
#################


tar xf perl-5.20.2.tar.bz2 &&
cd perl-5.20.2/

echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des -Dprefix=/usr                 \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib &&

make &&

make -k test 2>&1 | tee /perl-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&
unset BUILD_ZLIB BUILD_BZIP2

cd .. && rm -rf perl-5.20.2/


######################
## XML::Parser-2.44 ##
## ================ ##
######################


tar xf XML-Parser-2.44.tar.gz &&
cd XML-Parser-2.44/

perl Makefile.PL &&

make &&

make test 2>&1 | tee /xml_parser-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf XML-Parser-2.44/


###################
## Autoconf-2.69 ##
## ============= ##
###################


tar xf autoconf-2.69.tar.xz &&
cd autoconf-2.69/

./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /autoconf-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf autoconf-2.69/


###################
## Automake-1.15 ##
## ============= ##
###################


tar xf automake-1.15.tar.xz &&
cd automake-1.15/

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.15 &&

make &&

sed -i "s:./configure:LEXLIB=/usr/lib/libfl.a &:" t/lex-{clean,depend}-cxx.sh
make -j4 check 2>&1 | tee /automake-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf automake-1.15/


###################
## Diffutils-3.3 ##
## ============= ##
###################


tar xf diffutils-3.3.tar.xz &&
cd diffutils-3.3/

sed -i 's:= @mkdir_p@:= /bin/mkdir -p:' po/Makefile.in.in

./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /diffutils-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf diffutils-3.3/


################
## Gawk-4.1.1 ##
## ========== ##
################


tar xf gawk-4.1.1.tar.xz &&
cd gawk-4.1.1/

./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /gawk-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf gawk-4.1.1/


#####################
## Findutils-4.4.2 ##
## =============== ##
#####################


tar xf findutils-4.4.2.tar.gz &&
cd findutils-4.4.2/

./configure --prefix=/usr --localstatedir=/var/lib/locate &&

make &&

make check 2>&1 | tee /findutils-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

cd .. && rm -rf findutils-4.4.2/


####################
## Gettext-0.19.4 ##
## ============== ##
####################


tar xf gettext-0.19.4.tar.xz &&
cd gettext-0.19.4/

./configure --prefix=/usr --docdir=/usr/share/doc/gettext-0.19.4 &&

make &&

make check 2>&1 | tee /gettext-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf gettext-0.19.4/


#####################
## Intltool-0.50.2 ##
## =============== ##
#####################


tar xf intltool-0.50.2.tar.gz &&
cd intltool-0.50.2/

./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /intltool-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.50.2/I18N-HOWTO &&

cd .. && rm -rf intltool-0.50.2/


#################
## Gperf-3.0.4 ##
## =========== ##
#################


tar xf gperf-3.0.4.tar.gz &&
cd gperf-3.0.4/

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.0.4 &&

make &&

make check 2>&1 | tee /gperf-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf gperf-3.0.4/


##################
## Groff-1.22.3 ##
## ============ ##
##################


tar xf groff-1.22.3.tar.gz &&
cd groff-1.22.3/

PAGE=letter ./configure --prefix=/usr &&

make &&

make install &&

cd .. && rm -rf groff-1.22.3/


##############
## Xz-5.2.0 ##
## ======== ##
##############


tar xf xz-5.2.0.tar.xz &&
cd xz-5.2.0/

./configure --prefix=/usr --docdir=/usr/share/doc/xz-5.2.0 &&

make &&

make check 2>&1 | tee /xz-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&
mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v /usr/lib/liblzma.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so

cd .. && rm -rf xz-5.2.0/


#####################
## GRUB-2.02~beta2 ##
## =============== ##
#####################


tar xf grub-2.02~beta2.tar.xz &&
cd grub-2.02~beta2/

./configure --prefix=/usr          \
            --sbindir=/sbin        \
            --sysconfdir=/etc      \
            --disable-grub-emu-usb \
            --disable-efiemu       \
            --disable-werror &&

make &&

make install &&

cd .. && rm -rf grub-2.02~beta2/


##############
## Less-458 ##
## ======== ##
##############


tar xf less-458.tar.gz &&
cd less-458/

./configure --prefix=/usr --sysconfdir=/etc &&

make &&

make install &&

cd .. && rm -rf less-458/


##############
## Gzip-1.6 ##
## ======== ##
##############







echo ok all designated builds completed

### remaining packages to be added as testing finishes
###
### packages in testing as of 4/6/2015:
###
### Gzip-1.6
### IPRoute2-3.19.0
### Kbd-2.0.2
### Kmod-19
### Libpipeline-1.4.0
### Make-4.1
### Patch-2.7.4
### Systemd-219
### D-Bus-1.8.16
### Util-linux-2.26
### Man-DB-2.7.1
### Tar-1.28
### Texinfo-5.2
### Vim-7.4
### Nano-2.26
###
###
