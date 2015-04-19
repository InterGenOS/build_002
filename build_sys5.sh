#!/bin/bash
###  InterGenOS_build_002 build_sys5.sh - Continues building InterGen packages
###  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
###  4/16/2015

rm -rf /tools &&

##------------------------------------------------------

cat > /etc/systemd/network/10-dhcp-eth0.network << "EOF"
[Match]
Name=eth0

[Network]
DHCP=yes

EOF

##------------------------------------------------------

GetMac="$(ip link | grep ether | awk '{print $2}')"

# Set UDEV rule to rename ethlink to eth0 :)
cat > /etc/udev/rules.d/10-network.rules << "EOF"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="Mac", NAME="eth0"

EOF

sed -i "s/Mac/$GetMac/" /etc/udev/rules.d/10-network.rules &&

unset GetMac

##------------------------------------------------------

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

nameserver 8.8.8.8
nameserver 8.8.4.4

# End /etc/resolv.conf

EOF

ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf

##------------------------------------------------------

echo InterGenOS > /etc/hostname

##------------------------------------------------------

cat > /etc/hosts << "EOF"
#
# Begin /etc/hosts: static lookup table for host names
#

#<ip-address>   <hostname.domain.org>   <hostname>
127.0.0.1       localhost.localdomain   localhost
::1             localhost.localdomain   localhost

# End /etc/hosts

EOF

##------------------------------------------------------

cat > /etc/adjtime << "EOF"
0.0 0 0.0
0
LOCAL

EOF

##------------------------------------------------------

cat > /etc/vconsole.conf << "EOF"
KEYMAP=us
FONT=Lat2-Terminus16

EOF

##------------------------------------------------------

cat > /etc/locale.conf << "EOF"
LANG=en_US.UTF-8 LC_CTYPE=en_US

EOF

##------------------------------------------------------

cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Christopher 'InterGen' Cork <chris@intergenstudios.com>
# 4-19-2015

# do not bell on tab-completion
set bell-style none

set meta-flag on
set input-meta on
set convert-meta off
set output-meta on

$if mode=emacs

# for linux console and RH/Debian xterm
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[7~": beginning-of-line
"\e[3~": delete-char
"\e[2~": quoted-insert
"\e[5C": forward-word
"\e[5D": backward-word
"\e\e[C": forward-word
"\e\e[D": backward-word
"\e[1;5C": forward-word
"\e[1;5D": backward-word
"\eOc": forward-word
"\eOd": backward-word

# for rxvt
"\e[8~": end-of-line

# for non RH/Debian xterm, can't hurt for RH/DEbian xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for freebsd console, konsole
"\e[H": beginning-of-line
"\e[F": end-of-line
$endif

# End of /etc/inputrc

EOF

##------------------------------------------------------

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells

EOF

##------------------------------------------------------

# Disable Screen Clearing at Boot Time

mkdir -pv /etc/systemd/system/getty@tty1.service.d

cat > /etc/systemd/system/getty@tty1.service.d/noclear.conf << EOF
[Service]
TTYVTDisallocate=no

EOF

##------------------------------------------------------

# Create /etc/skel and shell files

mkdir /etc/skel

cat > /etc/profile << "EOF"
##############################################################################
####                                                                      ####
####  Begin /etc/profile                                                  ####
####  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>  ####
####  2/25/15                                                             ####
####                                                                      ####
##############################################################################


#############################################
####                                     ####
####  System wide environment variables  ####
####                                     ####
#############################################


# Setup some environment variables.
export HISTSIZE=9999
export HISTIGNORE="&:[bf]g:exit"

# Set some defaults for graphical systems
export XDG_DATA_DIRS=/usr/share



########################################
####                                ####
####  System wide startup programs  ####
####                                ####
########################################



################################################################################
####                                                                        ####
####  System wide environment variables and startup programs should go in   ####
####  ~/.bash_profile.  System wide environment variables and startup       ####
####  programs are in /etc/profile.  System wide aliases and functions are  ####
####  in /etc/bashrc.                                                       ####
####                                                                        ####
################################################################################



#################################
####                         ####
####  System Wide Functions  ####
####                         ####
##################################################################################
####                                                                          ####
####  Functions to help us manage paths.  Second argument is the name of the  ####
####  path variable to be modified (default: PATH)                            ####
####                                                                          ####
##################################################################################


pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
}

pathprepend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

pathappend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}

export -f pathremove pathprepend pathappend


################################
####                        ####
####  Set the initial path  ####
####                        ####
################################


export PATH=/bin:/usr/bin

if [ $EUID -eq 0 ] ; then
        pathappend /sbin:/usr/sbin
        unset HISTFILE
fi


######################################################################
####                                                              ####
####  Initializations- red prompt for root, green one for users,  ####
####  and run any scripts in /etc/profile.d/                      ####
####                                                              ####
######################################################################

RED='\[\e[1;34m\][\[\e[m\] \[\e[1;31m\]\u\[\e[m\]\[\e[1;34m\]@\[\e[m\]\[\e[1;37m\]\h\[\e[m\] \[\e[1;34m\]]\[\e[m\]\[\e[1;34m\][\[\e[m\] \[\e[1;37m\]<\[\e[m\]\[\e[1;32m\]\w\[\e[m\]\[\e[1;37m\]>\[\e[m\] \[\e[1;34m\]]\[\e[m\]\[\e[1;37m\]:\[\e[m\]\[\e[1;37m\]\\$\[\e[m\] '
GREEN='\[\e[1;34m\][\[\e[m\] \[\e[1;32m\]\u\[\e[m\]\[\e[1;34m\]@\[\e[m\]\[\e[1;37m\]\h\[\e[m\] \[\e[1;34m\]]\[\e[m\]\[\e[1;34m\][\[\e[m\] \[\e[1;37m\]<\[\e[m\]\[\e[1;32m\]\w\[\e[m\]\[\e[1;37m\]>\[\e[m\] \[\e[1;34m\]]\[\e[m\]\[\e[1;37m\]:\[\e[m\]\[\e[1;37m\]\\$\[\e[m\] '

if [[ $EUID == 0 ]] ; then
export PS1=$RED
else
export PS1=$GREEN
fi

for script in /etc/profile.d/*.sh ; do
        if [ -r $script ] ; then
                . $script
        fi
done

unset script RED GREEN


############################
####                    ####
####  END /etc/profile  ####
####                    ####
############################

EOF

##------------------------------------------------------

install --directory --mode=0755 --owner=root --group=root /etc/profile.d

cat > /etc/profile.d/dircolors.sh << "EOF"
# Setup for /bin/ls and /bin/grep to support color, the alias is in /etc/bashrc.
if [ -f "/etc/dircolors" ] ; then
        eval $(dircolors -b /etc/dircolors)

        if [ -f "$HOME/.dircolors" ] ; then
                eval $(dircolors -b $HOME/.dircolors)
        fi
fi
alias ls='ls -a --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias grep='grep --color=auto'

EOF

##------------------------------------------------------

cat > /etc/profile.d/extrapaths.sh << "EOF"
if [ -d /usr/local/lib/pkgconfig ] ; then
        pathappend /usr/local/lib/pkgconfig PKG_CONFIG_PATH
fi
if [ -d /usr/local/bin ]; then
        pathprepend /usr/local/bin
fi
if [ -d /usr/local/sbin -a $EUID -eq 0 ]; then
        pathprepend /usr/local/sbin
fi

EOF

##------------------------------------------------------

cat > /etc/profile.d/readline.sh << "EOF"
# Setup the INPUTRC environment variable.
if [ -z "$INPUTRC" -a ! -f "$HOME/.inputrc" ] ; then
        INPUTRC=/etc/inputrc
fi
export INPUTRC

EOF

##------------------------------------------------------

cat > /etc/profile.d/umask.sh << "EOF"
# By default, the umask should be set.
if [ "$(id -gn)" = "$(id -un)" -a $EUID -gt 99 ] ; then
  umask 002
else
  umask 022
fi

EOF

##------------------------------------------------------

cat > /etc/profile.d/i18n.sh << "EOF"
# Begin /etc/profile.d/i18n.sh

unset LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES \
      LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION

if [ -n "$XDG_CONFIG_HOME" ] && [ -r "$XDG_CONFIG_HOME/locale.conf" ]; then
  . "$XDG_CONFIG_HOME/locale.conf"
elif [ -r /etc/locale.conf ]; then
  . /etc/locale.conf
fi

export LANG="${LANG:-C}"
[ -n "$LC_CTYPE" ]          && export LC_CTYPE
[ -n "$LC_NUMERIC" ]        && export LC_NUMERIC
[ -n "$LC_TIME" ]           && export LC_TIME
[ -n "$LC_COLLATE" ]        && export LC_COLLATE
[ -n "$LC_MONETARY" ]       && export LC_MONETARY
[ -n "$LC_MESSAGES" ]       && export LC_MESSAGES
[ -n "$LC_PAPER" ]          && export LC_PAPER
[ -n "$LC_NAME" ]           && export LC_NAME
[ -n "$LC_ADDRESS" ]        && export LC_ADDRESS
[ -n "$LC_TELEPHONE" ]      && export LC_TELEPHONE
[ -n "$LC_MEASUREMENT" ]    && export LC_MEASUREMENT
[ -n "$LC_IDENTIFICATION" ] && export LC_IDENTIFICATION

# End /etc/profile.d/i18n.sh

EOF

##------------------------------------------------------

cat > /etc/bashrc << "EOF"
##############################################################################
####                                                                      ####
####  Begin /etc/bashrc                                                   ####
####  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>  ####
####  2/25/15                                                             ####
####                                                                      ####
##############################################################################


###############################
####                       ####
####  System wide aliases  ####
####                       ####
###############################


alias ls='ls -a --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias grep='grep --color=auto'


#################################
####                         ####
####  System wide functions  ####
####                         ####
#################################



################################################################################
####                                                                        ####
####  System wide environment variables and startup programs should go in   ####
####  ~/.bash_profile.  System wide environment variables and startup       ####
####  programs are in /etc/profile.  System wide aliases and functions are  ####
####  in /etc/bashrc.                                                       ####
####                                                                        ####
################################################################################


#############################################################################
####                                                                     ####
####  Provides prompt for non-login shells, specifically shells started  ####
####  in the X environment.                                              ####
####                                                                     ####
#############################################################################

RED='\[\e[1;34m\][\[\e[m\] \[\e[1;31m\]\u\[\e[m\]\[\e[1;34m\]@\[\e[m\]\[\e[1;37m\]\h\[\e[m\] \[\e[1;34m\]]\[\e[m\]\[\e[1;34m\][\[\e[m\] \[\e[1;37m\]<\[\e[m\]\[\e[1;32m\]\w\[\e[m\]\[\e[1;37m\]>\[\e[m\] \[\e[1;34m\]]\[\e[m\]\[\e[1;37m\]:\[\e[m\]\[\e[1;37m\]\\$\[\e[m\] '
GREEN='\[\e[1;34m\][\[\e[m\] \[\e[1;32m\]\u\[\e[m\]\[\e[1;34m\]@\[\e[m\]\[\e[1;37m\]\h\[\e[m\] \[\e[1;34m\]]\[\e[m\]\[\e[1;34m\][\[\e[m\] \[\e[1;37m\]<\[\e[m\]\[\e[1;32m\]\w\[\e[m\]\[\e[1;37m\]>\[\e[m\] \[\e[1;34m\]]\[\e[m\]\[\e[1;37m\]:\[\e[m\]\[\e[1;37m\]\\$\[\e[m\] '

if [[ $EUID == 0 ]] ; then
export PS1=$RED
else
export PS1=$GREEN
fi

unset RED GREEN


###########################
####                   ####
####  End /etc/bashrc  ####
####                   ####
###########################

EOF

##------------------------------------------------------

cat > ~/.bash_profile << "EOF"
##############################################################################
####                                                                      ####
####  Begin ~/.bash_profile for Root user                                 ####
####  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>  ####
####  2/25/15                                                             ####
####                                                                      ####
##############################################################################


###########################################
####                                   ####
####  Root user environment variables  ####
####                                   ####
###########################################



######################################
####                              ####
####  Root user startup programs  ####
####                              ####
######################################



#######################################################################
####                                                               ####
####  User aliases should go in their respective ~/.bashrc files.  ####
####  System wide environment variables and startup programs are   ####
####  in /etc/profile.  System wide aliases and functions are in   ####
####  /etc/bashrc.                                                 ####
####                                                               ####
#######################################################################


[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -d ~/bin ]] && pathprepend ~/bin

# Having . in the PATH is dangerous
#if [ $EUID -gt 99 ]; then
#  pathappend .
#fi

#############################################
####                                     ####
####  END ~/.bash_profile for root user  ####
####                                     ####
#############################################

EOF

##------------------------------------------------------

cat > ~/.bashrc << "EOF"
##############################################################################
####                                                                      ####
####  Begin ~/.bashrc for Root User                                       ####
####  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>  ####
####  2/25/15                                                             ####
####                                                                      ####
##############################################################################


#####################################
####                             ####
####  Bash prompt for Root User  ####
####                             ####
##################################################################
####                                                          ####
####  You can set an alternative bash prompt by placing your  ####
####  prompt code in-between the '' below and removing the #  ####
####  before 'export'                                         ####
####                                                          ####
##################################################################

#export PS1=''


###############################
####                       ####
####  Root User Variables  ####
####                       ####
###############################

export EDITOR=nano


#############################
####                     ####
####  Root User Aliases  ####
####                     ####
#############################

alias ping='ping -c 3'
alias ls='ls -a --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias grep='grep --color=auto'
alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'


###############################
####                       ####
####  Root User Functions  ####
####                       ####
###############################



################################################################################
####                                                                        ####
####  Root User environment variables and startup programs should go in     ####
####  ~/.bash_profile.  System wide environment variables and startup       ####
####  programs are in /etc/profile.  System wide aliases and functions are  ####
####  in /etc/bashrc.                                                       ####
####                                                                        ####
################################################################################

if [ -f "/etc/bashrc" ] ; then
  source /etc/bashrc
fi



#######################################
####                               ####
####  END ~/.bashrc for Root user  ####
####                               ####
#######################################

EOF

##------------------------------------------------------

cat > ~/.bash_logout << "EOF"
# Begin ~/.bash_logout
Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
2/25/15

# Personal items to perform on logout.

# End ~/.bash_logout

EOF

##------------------------------------------------------

cat > /etc/skel/.bash_profile << "EOF"
##############################################################################
####                                                                      ####
####  Begin ~/.bash_profile for System user                               ####
####  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>  ####
####  2/25/15                                                             ####
####                                                                      ####
##############################################################################


#############################################
####                                     ####
####  System user environment variables  ####
####                                     ####
#############################################



########################################
####                                ####
####  System user startup programs  ####
####                                ####
########################################



#######################################################################
####                                                               ####
####  User aliases should go in their respective ~/.bashrc files.  ####
####  System wide environment variables and startup programs are   ####
####  in /etc/profile.  System wide aliases and functions are in   ####
####  /etc/bashrc.                                                 ####
####                                                               ####
#######################################################################



[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -d ~/bin ]] && pathprepend ~/bin

# Having . in the PATH is dangerous
#if [ $EUID -gt 99 ]; then
#  pathappend .
#fi

###############################################
####                                       ####
####  END ~/.bash_profile for System user  ####
####                                       ####
###############################################

##------------------------------------------------------

cat > /etc/skel/.bashrc << "EOF"
##############################################################################
####                                                                      ####
####  ~/.bashrc for System User                                           ####
####  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>  ####
####  2/25/15                                                             ####
####                                                                      ####
##############################################################################

###################################
####                           ####
####  Interactive shell check  ####
####                           ####
###################################

[[ $- != *i* ]] && return


#######################################
####                               ####
####  Bash prompt for System User  ####
####                               ####
##################################################################
####                                                          ####
####  You can set an alternative bash prompt by placing your  ####
####  prompt code in-between the '' below and removing the #  ####
####  before 'export'                                         ####
####                                                          ####
##################################################################

#export PS1=''


#################################
####                         ####
####  System User Variables  ####
####                         ####
#################################

export EDITOR=nano


###############################
####                       ####
####  System User Aliases  ####
####                       ####
###############################

alias ping='ping -c 3'
alias ls='ls -a --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias grep='grep --color=auto'
alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'


#################################
####                         ####
####  System User Functions  ####
####                         ####
#################################



################################################################################
####                                                                        ####
####  System User environment variables and startup programs should go in   ####
####  ~/.bash_profile.  System wide environment variables and startup       ####
####  programs are in /etc/profile.  System wide aliases and functions are  ####
####  in /etc/bashrc.                                                       ####
####                                                                        ####
################################################################################

if [ -f "/etc/bashrc" ] ; then
  source /etc/bashrc
fi


#########################################
####                                 ####
####  END ~/.bashrc for system user  ####
####                                 ####
#########################################

EOF

##------------------------------------------------------

dircolors -p > /etc/dircolors

##------------------------------------------------------

ln -sfv /dev/null /etc/systemd/system/tmp.mount

##------------------------------------------------------

echo " "
echo " "
echo " "
echo "Main system configurations have been completed"
echo " "
echo "If your build has completed to this point, feel free to continue on at:"
echo " "
echo "http://linuxfromscratch.org/lfs/view/stable-systemd/chapter08/fstab.html"
echo " "
echo "making sure to substitute \$IGos for any \$LFS that you see listed,"
echo "or you can wait for script updates at https://github.com/InterGenOS/build_002"
echo " "
echo "Again, we appreciate your participation in the InterGenOS Project"
echo " "
echo "Thank you, and remember- The cake is a lie"
echo " "
echo " "

# Updates to follow -4-16-15
# --------------------------
#
# To do:
# ==========================
#
# /etc/fstab
# Compile Kernel ****KEEP BUILD DIRECTORY!****
# (It's needed for Realtek driver compilation)
# GRUB (can re-use template from build_001)
# /etc/os-release
# /etc/lsb-release
# Begin Linpack Pkg Generation
# Script core FS layout
