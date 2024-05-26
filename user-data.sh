#!/bin/bash

URLS=("http://repo.internal" "http://192.168.1.23:9000" "https://raw.githubusercontent.com/vinnyw/user-data/master")


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
    export SUITE="jammy"
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
COMBINED='#!/bin/bash\n\n'

##############################
#
#   FIND HOSTS
#

# Loop through each URL and concatenate the content
for URL in "${URLS[@]}"; do

    unset HTTP_STATUS
    unset RESPONSE
    unset CONTENT

    # Fetch the content and HTTP status code using curl
    RESPONSE=$(curl -s -o - -w "%{http_code}" "${URL}/distro/${DISTRO,,}")
    HTTP_STATUS="${RESPONSE: -3}"
    CONTENT="${RESPONSE:0: -3}"

  # Check if the HTTP status is 200
  if [ "$HTTP_STATUS" -eq 200 ]; then
    # Append the content to the combined content variable
    COMBINED_CONTENT+="${CONTENT}"
    COMBINED_CONTENT+=$'\n\n'
  else
    echo "Failed to download content from ${URL}/${DISTRO,,}."
    echo "HTTP status code: ${HTTP_STATUS}"
    continue
  fi


    unset HTTP_STATUS
    unset RESPONSE
    unset CONTENT

    # Fetch the content and HTTP status code using curl
    RESPONSE=$(curl -s -o - -w "%{http_code}" "${URL}/${DISTRO,,}_${SUITE,,}")
    HTTP_STATUS="${RESPONSE: -3}"
    CONTENT="${RESPONSE:0: -3}"

  # Check if the HTTP status is 200
  if [ "$HTTP_STATUS" -eq 200 ]; then
    # Append the content to the combined content variable
    COMBINED_CONTENT+="${CONTENT}"
    COMBINED_CONTENT+=$'\n'
  else
    echo "Failed to download content from ${URL}/${DISTRO,,}_${SUITE,,}."
    echo "HTTP status code: ${HTTP_STATUS}"
  fi



    unset HTTP_STATUS
    unset RESPONSE
    unset CONTENT

    # Fetch the content and HTTP status code using curl
    RESPONSE=$(curl -s -o - -w "%{http_code}" "${URL}/distro/${DISTRO,,}_${SUITE,,}_${ARCH,,}")
    HTTP_STATUS="${RESPONSE: -3}"
    CONTENT="${RESPONSE:0: -3}"

  # Check if the HTTP status is 200
  if [ "$HTTP_STATUS" -eq 200 ]; then
    # Append the content to the combined content variable
    COMBINED_CONTENT+="${CONTENT}"
    COMBINED_CONTENT+=$'\n'
  else
    echo "Failed to download content from ${URL}/distro/${DISTRO,,}_${SUITE,,}_${ARCH,,}. HTTP status code: $HTTP_STATUS" >&2
    continue
  fi


done



echo $COMBINED_CONTENT


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
