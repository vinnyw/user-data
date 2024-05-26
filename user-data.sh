#!/bin/bash

URLS=("repo.internal" "192.168.1.23:9000" "raw.githubusercontent.com/vinnyw/user-data/master")
PROTOS=("https" "http")

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
    export SUITE="focal"
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

# set 

##############################
#
#   FIND HOSTS
#

# Loop through each URL and concatenate the content


for URL in "${URLS[@]}"; do

    for PROTO in "${PROTOS[@]}"; do

        for FETCH in ${DISTRO,,} ${DISTRO,,}_${SUITE,,} ${DISTRO,,}_${SUITE,,}_${ARCH,,}; do

            unset HTTP_STATUS
            unset RESPONSE
            unset CONTENT

            # Fetch the content and HTTP status code using curl
            RESPONSE=$(curl --silent --connect-timeout 2 -o - -w "%{http_code}" "${PROTO}://${URL}/${FETCH,,}")
            HTTP_STATUS="${RESPONSE: -3}"
            CONTENT="${RESPONSE:0: -3}"

            # Check if the HTTP status is 200
            if [ "$HTTP_STATUS" -eq 000 ]; then
                echo "Unable to connect to ${PROTO}://${URL}"
                break
            elif [ "$HTTP_STATUS" -eq 200 ]; then
                echo "Fetched content from ${PROTO}://${URL}/${FETCH,,} (${HTTP_STATUS})"
                COMBINED+="${CONTENT}"
                COMBINED+=$'\n\n'
                export HASOK=1
            else
                echo "Skipped content from ${PROTO}://${URL}/${FETCH,,} (${HTTP_STATUS})"
                continue
            fi

        done
        if [[ $HASOK -eq 1 ]]; then
        break
        fi

    done

done


##############################
#
#   BUILD COMBINED SCRIPT
#

cat <<EOF
#!/bin/bash

##############################
#
#   LOCK
#

sudo -E apt-get -qy install lsb-release coreutils
sudo touch /run/nologin
lsb_release -d -s | sudo -E tee --append /run/nologin
echo "System is booting up for the first time. Unprivileged users are not permitted to log in at this time." | sudo -E tee --append /run/nologin


${COMBINED}


##############################
#
#   UNLOCK
#

[ -e /run/nologin ] && sudo rm -f /run/nologin 2>/dev/null
[ -e /var/run/reboot-required ] && sudo reboot

EOF


##############################
#
#   EXIT
#
exit 0
