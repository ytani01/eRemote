#!/bin/sh

MYNAME=`basename $0`

HOSTNAME="eremote-mini.ytani.net"

SYSLOG_PARAM="local7.info"

INTERVAL_OK=10
INTERVAL_NG=5
INTERVAL=${INTERVAL_OK}

STAT="OK"
PREV_STAT="OK"

while true; do
	echo -n "===== "
	date
	ping -c 1 ${HOSTNAME}
	if [ $? = 0 ]; then
		STAT="OK"
		INTERVAL=${INTERVAL_OK}
	else
		STAT="NG"
		INTERVAL=${INTERVAL_NG}
	fi
	echo "> ${STAT}"

	if [ "${STAT}" != "${PREV_STAT}" ]; then
		logger -p ${SYSLOG_PARAM} "${MYNAME}: ${STAT}"
	fi
	PREV_STAT=${STAT}

	sleep ${INTERVAL}
done
