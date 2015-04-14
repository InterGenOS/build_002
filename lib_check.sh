#!/bin/bash
###  InterGenOS_build_002 lib_check.sh - used to assist in verifying build requirements

for lib in lib{gmp,mpfr,mpc}.la; do
  echo $lib: $(if find /usr/lib* -name $lib|
               grep -q $lib;then :;else echo not;fi) found
done
unset lib

#End lib_check.sh
