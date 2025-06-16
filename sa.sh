#!/usr/bin/bash

# 
DIR=`dirname $0`
NAME=`basename $0`
DATE=`date +%Y-%m-%d`

# Arguments
HOST=$1
COMMAND="$2"

# Use POSIX standart of regular expression
PATTERN_IPv4='^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$'





connect()
{
    if [ ! -d $DIR/logs/$DATE ]; then
	mkdir -p $DIR/logs/$DATE
    fi

    LOGFILE=$(date +%H-%M)_$1
    sshpass -p $TACACS_USER_PASS ssh $TACACS_USER_NAME@$1 -o ConnectTimeout=5 -o StrictHostKeyChecking=no $2 2> /dev/null | tee -a $DIR/logs/$DATE/$LOGFILE 
}

get_ip_from_file()
{
    # Use text file as a source
    # For this function you need text file "ip.txt". Format is "Name	IP".
    local IP=`grep -i $1 $DIR/ip.txt | awk '{print $2}'`
    echo $IP
}

get_ip_from_nb()
{
    # Use NetBox as a source
    # For this function you need set varible "NB_URL" and "NB_TOKEN" in env.
    local IP=$($DIR/netbox.py $1)
    echo $IP
}


case "$#" in
  0)
    printf "How to run script:\n"
    printf " - Connect to device:\n"
    printf "     sa 10.26.255.1\n"
    printf "     sa swr-dl-core-1\n"
    printf " - Connect to device and run command:\n"
    printf "     sa 10.26.255.1 'sa 10.5.18.53 \"sh ip int br vrf dev\" | grep protocol-up | awk '{print \$2}' | sort -n\n"
    printf "     sa 10.26.255.1 'sh ip route next-hop 10.19.255.1 vrf prod | i ubest' | awk '{print \$1}' | cut -d '=' -f 2 | sed 's/,$//'\n"
    printf "\n"
    printf "Options:\n"
    printf " 1. Show 2 column:      | awk '{print \$2}'\n"
    printf " 2. Sort by Number:     | sort -n\n"
    printf " 3. Delete last symbol: | cut -d '=' -f 2 | sed 's/.$//'\n"
    printf "\n"
    exit 0
    ;;
  1|2)
    if [[ $HOST =~ $PATTERN_IPv4 ]]
    then
	connect "$HOST" "$COMMAND"
    else
	IP=`get_ip_from_file $HOST`
	#IP=get_ip_from_nb $HOST
	if [[ $IP =~ $PATTERN_IPv4 ]]
	then
	    connect "$IP" "$COMMAND"
	else
	    printf 'Sorry \"%s\" out of data\n' "$HOST"
	fi
    fi
    ;;
  *)
    printf 'Sorry, unknown error' "$HOST"
    ;;
esac
