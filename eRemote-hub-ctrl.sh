#!/bin/sh
#

MYNAME=`basename $0`
BINDIR="${HOME}/bin"
HOSTNAME="eremote-mini.ytani.net"
SYSLOG_PARAM="local7.info"

export PATH="${BINDIR}:/usr/local/bin:${PATH}"

HUB_CTRL_CMD="hub-ctrl.sh"

PING_CMD="ping"
PING_OPTS="-c 1 -W 2"

INTERVAL_OK=10
INTERVAL_NG=5
INTERVAL_REBOOTING=3
INTERVAL=${INTERVAL_OK}

REBOOT_INTERVAL=2

STAT="OK"
PREV_STAT="NONE"

FLAG_REBOOT="false"

while true; do
	DATE_STR=`date +'%Y/%m/%d(%a),%H:%M:%S'`

	${PING_CMD} ${PING_OPTS} ${HOSTNAME} > /dev/null 2>&1
	if [ $? = 0 ]; then
		STAT="OK"
		FLAG_REBOOT="false"
		INTERVAL=${INTERVAL_OK}
	else
		STAT="NG"
		INTERVAL=${INTERVAL_NG}

		if [ ${FLAG_REBOOT} = "true" ]; then
			STAT="Rebooting"
			INTERVAL=${INTERVAL_REBOOTING}
		fi

	fi

	if [ "${STAT}" != "${PREV_STAT}" ]; then
		# logger -p ${SYSLOG_PARAM} "${MYNAME}: ${STAT}"
		echo
		echo "${DATE_STR} ${STAT}"
		PREV_STAT=${STAT}
	else
		echo -n "."
	fi
	
	if [ "${STAT}" = "NG" ]; then
		if [ "${FLAG_REBOOT}" != "true" ]; then
			${HUB_CTRL_CMD} off
			sleep ${REBOOT_INTERVAL}
			${HUB_CTRL_CMD} on
			FLAG_REBOOT="true"
		fi
	fi

	sleep ${INTERVAL}
done
