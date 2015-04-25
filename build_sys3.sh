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


tar xf gzip-1.6.tar.xz &&
cd gzip-1.6/

./configure --prefix=/usr --bindir=/bin &&

make &&

make check 2>&1 | tee /gzip-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

mv -v /bin/{gzexe,uncompress,zcmp,zdiff,zegrep} /usr/bin
mv -v /bin/{zfgrep,zforce,zgrep,zless,zmore,znew} /usr/bin

cd .. && rm -rf gzip-1.6/


#####################
## IPRoute2-3.19.0 ##
## =============== ##
#####################


tar xf iproute2-3.19.0.tar.xz &&
cd iproute2-3.19.0/

sed -i '/^TARGETS/s@arpd@@g' misc/Makefile
sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile

make &&

make DOCDIR=/usr/share/doc/iproute2-3.19.0 install &&

cd .. && rm -rf iproute2-3.19.0/


###############
## Kbd-2.0.2 ##
## ========= ##
###############


tar xf kbd-2.0.2.tar.gz &&
cd kbd-2.0.2/

patch -Np1 -i ../kbd-2.0.2-backspace-1.patch &&

sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock &&

make &&

make check 2>&1 | tee /kbd-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf kbd-2.0.2/


#############
## Kmod-19 ##
## ======= ##
#############


tar xf kmod-19.tar.xz &&
cd kmod-19/

./configure --prefix=/usr          \
            --bindir=/bin          \
            --sysconfdir=/etc      \
            --with-rootlibdir=/lib \
            --with-xz              \
            --with-zlib &&

make &&

make check 2>&1 | tee /kmod-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sv ../bin/kmod /sbin/$target
done

ln -sv kmod /bin/lsmod

cd .. && rm -rf kmod-19/


#######################
## Libpipeline-1.4.0 ##
## ================= ##
#######################


tar xf libpipeline-1.4.0.tar.gz &&
cd libpipeline-1.4.0/

PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /libpipeline-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf libpipeline-1.4.0/


##############
## Make-4.1 ##
## ======== ##
##############


tar xf make-4.1.tar.bz2 &&
cd make-4.1/

./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /make-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf make-4.1/


#################
## Patch-2.7.4 ##
## =========== ##
#################


tar xf patch-2.7.4.tar.xz &&
cd patch-2.7.4/

./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /patch-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf patch-2.7.4/


#################
## Systemd-219 ##
## =========== ##
#################


tar xf systemd-219.tar.xz &&
cd systemd-219/

cat > config.cache << "EOF"
KILL=/bin/kill
HAVE_BLKID=1
BLKID_LIBS="-lblkid"
BLKID_CFLAGS="-I/tools/include/blkid"
HAVE_LIBMOUNT=1
MOUNT_LIBS="-lmount"
MOUNT_CFLAGS="-I/tools/include/libmount"
cc_cv_CFLAGS__flto=no
EOF

sed -i "s:blkid/::" $(grep -rl "blkid/blkid.h")

patch -Np1 -i ../systemd-219-compat-1.patch

sed -i "s:test/udev-test.pl ::g" Makefile.in

./configure --prefix=/usr                                           \
            --sysconfdir=/etc                                       \
            --localstatedir=/var                                    \
            --config-cache                                          \
            --with-rootprefix=                                      \
            --with-rootlibdir=/lib                                  \
            --enable-split-usr                                      \
            --disable-gudev                                         \
            --disable-firstboot                                     \
            --disable-ldconfig                                      \
            --disable-sysusers                                      \
            --without-python                                        \
            --docdir=/usr/share/doc/systemd-219                     \
            --with-dbuspolicydir=/etc/dbus-1/system.d               \
            --with-dbussessionservicedir=/usr/share/dbus-1/services \
            --with-dbussystemservicedir=/usr/share/dbus-1/system-services &&

make LIBRARY_PATH=/tools/lib &&

mv -v /usr/lib/libnss_{myhostname,mymachines,resolve}.so.2 /lib &&

rm -rfv /usr/lib/rpm &&

for tool in runlevel reboot shutdown poweroff halt telinit; do
     ln -sfv ../bin/systemctl /sbin/${tool}
done
ln -sfv ../lib/systemd/systemd /sbin/init

sed -i "s:0775 root lock:0755 root root:g" /usr/lib/tmpfiles.d/legacy.conf
sed -i "/pam.d/d" /usr/lib/tmpfiles.d/etc.conf

systemd-machine-id-setup &&

sed -i "s:minix:ext4:g" src/test/test-path-util.c
make LD_LIBRARY_PATH=/tools/lib -k check 2>&1 | tee /systemd-mkck-log_$(date +"%m-%d-%Y_%T") &&

cd .. && rm -rf systemd-219/


##################
## D-Bus-1.8.16 ##
## ============ ##
##################


tar xf dbus-1.8.16.tar.gz &&
cd dbus-1.8.16/

./configure --prefix=/usr                       \
            --sysconfdir=/etc                   \
            --localstatedir=/var                \
            --docdir=/usr/share/doc/dbus-1.8.16 \
            --with-console-auth-dir=/run/console &&

make &&

make install &&

mv -v /usr/lib/libdbus-1.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so

ln -sfv /etc/machine-id /var/lib/dbus

cd .. && rm -rf dbus-1.8.16/


#####################
## Util-linux-2.26 ##
## =============== ##
#####################


tar xf util-linux-2.26.tar.xz &&
cd util-linux-2.26/

mkdir -pv /var/lib/hwclock

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --docdir=/usr/share/doc/util-linux-2.26 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --without-python &&

make &&

chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=$PATH make -k check" 2>&1 | tee /util_linux-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

cd .. && rm -rf util-linux-2.26/


##################
## Man-DB-2.7.1 ##
## ============ ##
##################


tar xf man-db-2.7.1.tar.xz &&
cd man-db-2.7.1/

./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.7.1 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap &&

make &&

make check 2>&1 | tee /man_db-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

sed -i "s:man root:root root:g" /usr/lib/tmpfiles.d/man-db.conf

cd .. && rm -rf man-db-2.7.1/


##############
## Tar-1.28 ##
## ======== ##
##############


tar xf tar-1.28.tar.xz &&
cd tar-1.28/

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin &&

make &&

make check 2>&1 | tee /tar-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&
make -C doc install-html docdir=/usr/share/doc/tar-1.28 &&

cd .. && rm -rf tar-1.28/


#################
## Texinfo-5.2 ##
## =========== ##
#################


tar xf texinfo-5.2.tar.xz &&
cd texinfo-5.2/

./configure --prefix=/usr &&

make &&

make check 2>&1 | tee /texinfo-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

make TEXMF=/usr/share/texmf install-tex &&

cd .. && rm -rf texinfo-5.2/


#############
## Vim-7.4 ##
## ======= ##
#############


tar xf vim-7.4.tar.bz2 &&
cd vim74/

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr &&

make &&

make -j1 test > /vim-mkck-log_$(date +"%m-%d-%Y_%T") &&

make install &&

ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim74/doc /usr/share/doc/vim-7.4


cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

set nocompatible
set backspace=2
syntax on
if (&term == "iterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

cd .. && rm -rf vim74/


################
## Nano-2.3.6 ##
## ========== ##
################


tar xf nano-2.3.6.tar.gz &&
cd nano-2.3.6/

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-utf8     \
            --enable-nanorc   \
            --docdir=/usr/share/doc/nano-2.3.6 &&
make &&

make install &&
install -v -m644 doc/nanorc.sample /etc &&
install -v -m644 doc/texinfo/nano.html /usr/share/doc/nano-2.3.6 &&
cp intergen_nanorc /etc/nanorc

cd .. && rm -rf nano-2.3.6/

echo " "
echo " "
echo " "
echo " "
echo "____________________________________________________________"
echo "                                                          "
echo "  Core package builds completed!                          "
echo "                                                          "
echo "  Now pass the 'exit' command twice to leave the chroot   "
echo "  environment and return to the host system's root        "
echo "  terminal, and then re-enter the chroot environment      "
echo "  by copy/pasting the following command:                  "
echo " "
echo "  chroot \$IGos /tools/bin/env -i            \\"
echo "      HOME=/root TERM=\$TERM PS1='\\u:\\w\\\$ ' \\"
echo "      PATH=/bin:/usr/bin:/sbin:/usr/sbin   \\"
echo "      /tools/bin/bash --login"
echo " "
echo "  Once you've re-entered the chroot environment, copy/paste"
echo "  the following command to strip unnecessary symbols from "
echo "  binaries and libraries and continue the build:"
echo " "
echo "  /tools/bin/find /{,usr/}{bin,lib,sbin} -type f \\"
echo "      -exec /tools/bin/strip --strip-debug '{}' ';' &&"
echo "  /bin/bash build_sys4.sh "
echo " "
echo " "
echo "__________________________________________________________"
echo " "
echo " "
echo " "
###
###
