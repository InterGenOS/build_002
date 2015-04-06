#!/bin/bash -e
###  InterGenOS_build_002 build_temp_sys.sh - Build the Temporary System used to create the working system separately from the host 
###  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
###  3/10/2015

################################
###  Build Temporary System  ###
################################

cd /mnt/igos

sed -i '/.\/build_temp_sys.sh/d' /home/igos/.bashrc # Removes bashrc entry that executes the temp-system build

cd /mnt/igos/sources

###################
## Binutils-2.25 ##
## ============= ##
##    PASS -1-   ##
#########################################################################################################
## To determine SBUs, use the following command:                                                       ##
## =============================================                                                       ##
## time { ../binutils-2.25/configure --prefix=/tools --with-sysroot=$IGos --with-lib-path=/tools/lib \ ##
## --target=$IGos_TGT --disable-nls --disable-werror && make && case $(uname -m) in \                  ##
## x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;; esac && make install; }                   ##
## =================================================================================                   ##
## Example results for SBU with the following hardware:                                                ##
## ====================================================                                                ##
## 8GB Memory, Intel Core i3, SSD:                                                                     ##
## real - 2m 1.212s                                                                                    ##
## user - 1m 32.530s                                                                                   ##
## sys  - 0m 5.540s                                                                                    ##
## ================                                                                                    ##
#########################################################################################################

tar xf binutils-2.25.tar.bz2 &&
cd binutils-2.25/
mkdir -v ../binutils-build
cd ../binutils-build
../binutils-2.25/configure     \
    --prefix=/tools            \
    --with-sysroot=$IGos       \
    --with-lib-path=/tools/lib \
    --target=$IGos_TGT         \
    --disable-nls              \
    --disable-werror &&
make &&
case $(uname -m) in
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac &&
make install &&
cd .. && rm -rf binutils-2.25 binutils-build/


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
## Gcc-4.9.2 ##
## ========= ##
##  PASS -1- ##
###############

tar xf gcc-4.9.2.tar.bz2 
cd gcc-4.9.2/
tar -xf ../mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar -xf ../gmp-6.0.0a.tar.xz
mv -v gmp-6.0.0 gmp
tar -xf ../mpc-1.0.2.tar.gz
mv -v mpc-1.0.2 mpc
for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done
sed -i '/k prot/agcc_cv_libc_provides_ssp=yes' gcc/configure
mkdir -v ../gcc-build
cd ../gcc-build
../gcc-4.9.2/configure                               \
    --target=$IGos_TGT                               \
    --prefix=/tools                                  \
    --with-sysroot=$IGos                             \
    --with-newlib                                    \
    --without-headers                                \
    --with-local-prefix=/tools                       \
    --with-native-system-header-dir=/tools/include   \
    --disable-nls                                    \
    --disable-shared                                 \
    --disable-multilib                               \
    --disable-decimal-float                          \
    --disable-threads                                \
    --disable-libatomic                              \
    --disable-libgomp                                \
    --disable-libitm                                 \
    --disable-libquadmath                            \
    --disable-libsanitizer                           \
    --disable-libssp                                 \
    --disable-libvtv                                 \
    --disable-libcilkrts                             \
    --disable-libstdc++-v3                           \
    --enable-languages=c,c++ &&
make &&
make install &&
cd .. && rm -rf gcc-4.9.2 gcc-build/


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



## Updated kernel to 3.19 ###
#############################
## Linux-3.19 API Headers  ##
## ======================= ##
#############################

tar xf linux-3.19.tar.xz &&
cd linux-3.19/
make mrproper &&
make INSTALL_HDR_PATH=dest headers_install &&
cp -rv dest/include/* /tools/include &&
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



################
## Glibc-2.21 ##
## ========== ##
################

tar xf glibc-2.21.tar.xz &&
cd glibc-2.21/
if [ ! -r /usr/include/rpc/types.h ]; then
  su -c 'mkdir -pv /usr/include/rpc'
  su -c 'cp -v sunrpc/rpc/*.h /usr/include/rpc'
fi
sed -e '/ia32/s/^/1:/' \
    -e '/SSE2/s/^1://' \
    -i  sysdeps/i386/i686/multiarch/mempcpy_chk.S
mkdir -v ../glibc-build
cd ../glibc-build
../glibc-2.21/configure                             \
      --prefix=/tools                               \
      --host=$IGos_TGT                              \
      --build=$(../glibc-2.21/scripts/config.guess) \
      --disable-profile                             \
      --enable-kernel=2.6.32                        \
      --with-headers=/tools/include                 \
      libc_cv_forced_unwind=yes                     \
      libc_cv_ctors_header=yes                      \
      libc_cv_c_cleanup=yes &&
make &&
make install &&


COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT

echo "------------------------------------------"
echo "|                                        |"
echo "|  SPACING BEFORE GLIBC SANITY TESTING   |"
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



##########################
## glibc sanity testing ##
## ==================== ##
##############################################################################
## The actual Sanity Check will look like the following in terminal:        ##
## =================================================================        ##
## [igos@Arch glibc-build]$ echo 'main(){}' > dummy.c                       ##
## [igos@Arch glibc-build]$ $IGos_TGT-gcc dummy.c                           ##
## [igos@Arch glibc-build]$ readelf -l a.out | grep ': /tools'              ##
##      [Requesting program interpreter: /tools/lib64/ld-linux-x86-64.so.2] ##
## ======================================================================== ##
## The following script will kill the build if the Sanity Check fails:      ##
## ===================================================================      ##
##############################################################################

echo 'main(){}' > dummy.c
$IGos_TGT-gcc dummy.c

Expected="Requestingprograminterpreter/tools/lib64/ld-linux-x86-64.so.2"
Actual="$(readelf -l a.out | grep ': /tools' | sed s/://g | cut -d '[' -f 2 | cut -d ']' -f 1 | awk '{print $1$2$3$4}')"

if [ $Expected != $Actual ]; then
    echo "!!!!!GLIBC 1st PASS SANITY CHECK FAILED!!!!! Halting build, check your work."
    exit 0
else
    COUNT=50 # Add some blank lines so build output
    #          is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT
    
    echo "Compiler and Linker are functioning as expected, continuing build."

    COUNT=50 # Add some blank lines so build output
    #          is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT
fi
rm -v dummy.c a.out
cd .. && rm -rf glibc-2.21 glibc-build/



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




#################################
##       Libstdc++-4.9.2       ##
## (Part of Gcc-4.9.2 package) ##
## =========================== ##
#################################

tar xf gcc-4.9.2.tar.bz2 &&
cd gcc-4.9.2/
mkdir -pv ../gcc-build
cd ../gcc-build
../gcc-4.9.2/libstdc++-v3/configure \
    --host=$IGos_TGT                \
    --prefix=/tools                 \
    --disable-multilib              \
    --disable-shared                \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$IGos_TGT/include/c++/4.9.2 &&
make &&
make install
cd .. && rm -rf gcc-4.9.2 gcc-build/



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
## Binutils-2.25  ##
## =============  ##
##   PASS  -2-    ##
####################

tar xf binutils-2.25.tar.bz2 &&
cd binutils-2.25/
mkdir -v ../binutils-build
cd ../binutils-build
CC=$IGos_TGT-gcc               \
AR=$IGos_TGT-ar                \
RANLIB=$IGos_TGT-ranlib        \
../binutils-2.25/configure     \
    --prefix=/tools            \
    --disable-nls              \
    --disable-werror           \
    --with-lib-path=/tools/lib \
    --with-sysroot &&
make &&
make install &&
make -C ld clean &&
make -C ld LIB_PATH=/usr/lib:/lib &&
cp -v ld/ld-new /tools/bin
cd .. && rm -rf binutils-2.25 binutils-build/



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
## Gcc-4.9.2 ##
## ========= ##
##  PASS -2- ##
###############

tar xf gcc-4.9.2.tar.bz2 
cd gcc-4.9.2/
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($IGos_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h
for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done
tar -xf ../mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar -xf ../gmp-6.0.0a.tar.xz
mv -v gmp-6.0.0 gmp
tar -xf ../mpc-1.0.2.tar.gz
mv -v mpc-1.0.2 mpc
mkdir -v ../gcc-build
cd ../gcc-build
CC=$IGos_TGT-gcc                                     \
CXX=$IGos_TGT-g++                                    \
AR=$IGos_TGT-ar                                      \
RANLIB=$IGos_TGT-ranlib                              \
../gcc-4.9.2/configure                               \
    --prefix=/tools                                  \
    --with-local-prefix=/tools                       \
    --with-native-system-header-dir=/tools/include   \
    --enable-languages=c,c++                         \
    --disable-libstdcxx-pch                          \
    --disable-multilib                               \
    --disable-bootstrap                              \
    --disable-libgomp &&
make &&
make install &&
ln -sv gcc /tools/bin/cc &&



COUNT=15 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT

echo "------------------------------------------"
echo "|                                        |"
echo "|  SPACING BEFORE GLIBC SANITY TESTING   |"
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




##########################
## glibc sanity testing ##
## ==================== ##
##############################################################################
## The actual Sanity Check will look like the following in terminal:        ##
## =================================================================        ##
## [igos@Arch gcc-build]$ echo 'main(){}' > dummy.c                         ##
## [igos@Arch gcc-build]$ cc dummy.c                                        ##
## [igos@Arch gcc-build]$ readelf -l a.out | grep ': /tools'                ##
##      [Requesting program interpreter: /tools/lib64/ld-linux-x86-64.so.2] ##
## ======================================================================== ##
## The following script will kill the build if the Sanity Check fails:      ##
## ===================================================================      ##
##############################################################################

echo 'main(){}' > dummy.c
cc dummy.c

Expected2="Requestingprograminterpreter/tools/lib64/ld-linux-x86-64.so.2"
Actual2="$(readelf -l a.out | grep ': /tools' | sed s/://g | cut -d '[' -f 2 | cut -d ']' -f 1 | awk '{print $1$2$3$4}')"

if [ $Expected2 != $Actual2 ]; then
    echo "!!!!!GCC 2nd PASS SANITY CHECK FAILED!!!!! Halting build, check your work."
    exit 0
else
    COUNT=50 # Add some blank lines so build output
    #          is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT
    
    echo "Compiler and Linker are functioning as expected, continuing build."

    COUNT=50 # Add some blank lines so build output
    #          is easier to review

    while [ "$COUNT" -gt "0" ]; do
    echo " "
    let COUNT=COUNT-1
    done
    unset COUNT
fi
rm -v dummy.c a.out
cd .. && rm -rf gcc-4.9.2 gcc-build/



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
## Tcl-8.6.3 ##
## ========= ##
###############

tar xf tcl8.6.3-src.tar.gz &&
cd tcl8.6.3/
cd unix
./configure --prefix=/tools &&
make &&
make install &&
chmod -v u+w /tools/lib/libtcl8.6.so &&
make install-private-headers &&
ln -sv tclsh8.6 /tools/bin/tclsh
cd .. && cd .. && rm -rf tcl8.6.3



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



#################
## Expect-5.45 ##
## =========== ##
#################

tar xf expect5.45.tar.gz &&
cd expect5.45/ 
cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure
./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include &&
make &&
make SCRIPTS="" install
cd .. && rm -rf expect5.45



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
## DejaGNU-1.5.2 ##
## ============= ##
###################

tar xf dejagnu-1.5.2.tar.gz &&
cd dejagnu-1.5.2/
./configure --prefix=/tools && make install
cd .. && rm -rf dejagnu-1.5.2



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



##################
## Check-0.9.14 ##
## ============ ##
##################

tar xf check-0.9.14.tar.gz &&
cd check-0.9.14/
PKG_CONFIG= ./configure --prefix=/tools &&
make &&
make install
cd .. && rm -rf check-0.9.14



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



#################
## Ncurses-5.9 ##
## =========== ##
#################

tar xf ncurses-5.9.tar.gz &&
cd ncurses-5.9/
./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite &&
make &&
make install
cd .. && rm -rf ncurses-5.9



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




#################
## Bash-4.3.30 ##
## =========== ##
#################

tar xf bash-4.3.30.tar.gz &&
cd bash-4.3.30/
./configure --prefix=/tools --without-bash-malloc &&
make &&
make install &&
ln -sv bash /tools/bin/sh
cd .. && rm -rf bash-4.3.30



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



#################
## Bzip2-1.0.6 ##
## =========== ##
#################

tar xf bzip2-1.0.6.tar.gz &&
cd bzip2-1.0.6/
make && make PREFIX=/tools install &&
cd .. && rm -rf bzip2-1.0.6



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
## Coreutils-8.23 ##
## ============== ##
####################

tar xf coreutils-8.23.tar.xz &&
cd coreutils-8.23/
./configure --prefix=/tools --enable-install-program=hostname &&
make &&
make install &&
cd .. && rm -rf coreutils-8.23



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
## Diffutils-3.3 ##
## ============= ##
###################

tar xf diffutils-3.3.tar.xz &&
cd diffutils-3.3/
./configure --prefix=/tools && make && make install
cd .. && rm -rf diffutils-3.3




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
cd file-5.22/
./configure --prefix=/tools && make && make install &&
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




#####################
## Findutils-4.4.2 ##
## =============== ##
#####################

tar xf findutils-4.4.2.tar.gz &&
cd findutils-4.4.2/
./configure --prefix=/tools && make && make install &&
cd .. && rm -rf findutils-4.4.2



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
## Gawk-4.1.1 ##
## ========== ##
################

tar xf gawk-4.1.1.tar.xz &&
cd gawk-4.1.1/
./configure --prefix=/tools && make && make install &&
cd .. && rm -rf gawk-4.1.1



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
## Gettext-0.19.4 ##
## ============== ##
####################

tar xf gettext-0.19.4.tar.xz &&
cd gettext-0.19.4/
cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared &&
make -C gnulib-lib &&
make -C intl pluralx.c &&
make -C src msgfmt &&
make -C src msgmerge &&
make -C src xgettext &&
cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin
cd .. && cd .. && rm -rf gettext-0.19.4



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
## Grep-2.21 ##
## ========= ##
###############

tar xf grep-2.21.tar.xz &&
cd grep-2.21/
./configure --prefix=/tools && make && make install &&
cd .. && rm -rf grep-2.21



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



##############
## Gzip-1.6 ##
## ======== ##
##############

tar xf gzip-1.6.tar.xz &&
cd gzip-1.6/
./configure --prefix=/tools && make && make install &&
cd .. && rm -rf gzip-1.6



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
## M4-1.4.17 ##
## ========= ##
###############

tar xf m4-1.4.17.tar.xz &&
cd m4-1.4.17/
./configure --prefix=/tools && make && make install &&
cd .. && rm -rf 4-1.4.17



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



##############
## Make-4.1 ##
## ======== ##
##############

tar xf make-4.1.tar.bz2 &&
cd make-4.1/
./configure --prefix=/tools --without-guile && make && make install
cd .. && rm -rf make-4.1



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



#################
## Patch-2.7.4 ##
## =========== ##
#################

tar xf patch-2.7.4.tar.xz &&
cd patch-2.7.4/
./configure --prefix=/tools && make && make install &&
cd .. && rm -rf patch-2.7.4



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



#################
## Perl-5.20.2 ##
## =========== ##
#################

tar xf perl-5.20.2.tar.bz2 &&
cd perl-5.20.2/
sh Configure -des -Dprefix=/tools -Dlibs=-lm &&
make &&
cp -v perl cpan/podlators/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.20.2
cp -Rv lib/* /tools/lib/perl5/5.20.2
cd .. && rm -rf perl-5.20.2



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
## Sed-4.2.2 ##
## ========= ##
###############

tar xf sed-4.2.2.tar.bz2 &&
cd sed-4.2.2/
./configure --prefix=/tools && make && make install &&
cd .. && rm -rf sed-4.2.2



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



##############
## Tar-1.28 ##
## ======== ##
##############

tar xf tar-1.28.tar.xz &&
cd tar-1.28/
./configure --prefix=/tools && make && make install &&
cd .. && rm -rf tar-1.28



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



#################
## Texinfo-5.2 ##
## =========== ##
#################

tar xf texinfo-5.2.tar.xz &&
cd texinfo-5.2/
./configure --prefix=/tools && make && make install &&
cd .. && rm -rf texinfo-5.2



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



#####################
## Util-linux-2.26 ##
## =============== ##
#####################

tar xf util-linux-2.26.tar.xz &&
cd util-linux-2.26/
./configure --prefix=/tools                \
            --without-python               \
            --disable-makeinstall-chown    \
            --without-systemdsystemunitdir \
            PKG_CONFIG="" && 
make && 
make install
cd .. && rm -rf util-linux-2.26



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



##############
## Xz-5.2.0 ##
## ======== ##
##############

tar xf xz-5.2.0.tar.xz &&
cd xz-5.2.0/
./configure --prefix=/tools && 
make && 
make install
cd .. && rm -rf xz-5.2.0



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



#####################
####             ####
####  STRIPPING  ####
####             ####
#####################

strip --strip-debug /tools/lib/* &&
/usr/bin/strip --strip-unneeded /tools/{,s}bin/* &&
rm -rf /tools/{,share}/{info,man,doc} &&

COUNT=10 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT

echo "==================================================================================="
echo "|                                                                                 |"
echo "|                        Temporary System Build Completed                         |"
echo "|                                                                                 |"
echo "|                      It is now recommended that you open a                      |"
echo "|                      separate terminal to back up the /tools                    |"
echo "|                     directory for future use, as the directory                  |"
echo "|                   will be altered and eventually removed during                 |"
echo "|                       the remainder of the build process.                       |"
echo "|                                                                                 |"
echo "|                        Please 'exit' back into root shell                       |"
echo "|                            and then copy/paste and run                          |"
echo "|                        the following command to continue:                       |"
echo "|                                                                                 |"
echo "|                             \$IGos/./setup_chroot.sh                             |"
echo "|                                                                                 |"
echo "|                                  InterGen OSsD                                  |"
echo "|                                       2015                                      |"
echo "|                                                                                 |"
echo "==================================================================================="

COUNT=5 # Add some blank lines so build output
#          is easier to review

while [ "$COUNT" -gt "0" ]; do
        echo " "
        let COUNT=COUNT-1
done
unset COUNT
