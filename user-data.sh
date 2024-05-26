#!/bin/bash

HOSTS=("repo.internal" "192.168.1.23:9000" "raw.githubusercontent.com/vinnyw/user-data/master")


##############################
#
#   HOSTTYPE
#

# ubuntu type
if cat "/etc/issue" | grep -qF 'Ubuntu'; then

    export NEEDRESTART_MODE=a
    export DEBIAN_FRONTEND=noninteractive
    export DEBIAN_PRIORITY=critical

    # install tools
    sudo -E apt-get -qy install lsb-release coreutils dpkg curl

    # capture valutes
    export DISTRO=$( lsb_release -s -i 2>/dev/null)
    export SUITE=$( lsb_release -s -c 2>/dev/null)
    export ARCH=$(dpkg --print-architecture 2>/dev/null)

# debian type
elif cat "/etc/issue" | grep -qF 'Debian'; then

    # display message
    echo "Debian is not currently supported..."
    exit 1

# amzon type
elif cat "/etc/issue" | grep -qF 'Amazon Linux'; then

    # display message
    echo "Amazon Linux is not currently supported..."
    exit 1

# unsupported
else

    # display message
    echo "Unsupported system type..."
    exit 1

fi


##############################
#
#   FIND HOSTS
#

##
#
#    for each host in array 
#       do loop
#       check https (wget --timeout=seconds URL)
        # try host/distro/suite_arch host/distro/suite  
        #    if 404 recieved then try next less specific   
#       if unable to connect try http
#       if unable to connect then try next in loop
#   
