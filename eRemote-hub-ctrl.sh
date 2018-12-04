#!/bin/sh
#

MYNAME=`basename $0`
BINDIR="${HOME}/bin"
HOSTNAME="eremote-mini.ytani.net"

SYSLOG_HOST="rpi05"
SYSLOG_PARAM="local7.warn"

export PATH="${BINDIR}:/usr/local/bin:${PATH}"

HUB_CTRL_CMD="hub-ctrl.sh"

PING_CMD="ping"
PING_OPTS="-c 1 -W 2"

INTERVAL_OK=10
INTERVAL_NG=5
INTERVAL_REBOOTING=2
INTERVAL=${INTERVAL_OK}

REBOOT_INTERVAL=2
REBOOT_COUNT=0

STAT="OK"
PREV_STAT="NONE"

### functions
get_datestr() {
	DATE_STR=`date +'%Y/%m/%d(%a) %H:%M:%S'`
}

echo_log() {
	get_datestr
	msg="${DATE_STR} ${MYNAME}: $*"
	echo $msg
	logger -n ${SYSLOG_HOST} -p ${SYSLOG_PARAM} $msg
}

usage() {
	echo "${MYNAME}"
}

usb_power() {
	echo_log "USB power: $1"
	${HUB_CTRL_CMD} $1 > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo_log "usb_power: Error"
	fi
}

reboot_eremote() {
	usb_power off
	sleep $1
	usb_power on
}

### main
while true; do
	${PING_CMD} ${PING_OPTS} ${HOSTNAME} > /dev/null 2>&1
	if [ $? = 0 ]; then
		STAT="OK"
		REBOOT_COUNT=0
		INTERVAL=${INTERVAL_OK}
	else
		STAT="NG"
		INTERVAL=${INTERVAL_NG}

		if [ ${REBOOT_COUNT} -gt 0 ]; then
			STAT="Rebooting:${REBOOT_COUNT}"
			INTERVAL=${INTERVAL_REBOOTING}
			REBOOT_COUNT=$((REBOOT_COUNT+1))
			if [ ${REBOOT_COUNT} -gt 10 ]; then
				# Reboot again
				STAT="NG"
				REBOOT_COUNT=0
			fi
		fi

	fi

	if [ "${STAT}" != "${PREV_STAT}" ]; then
		# logger -p ${SYSLOG_PARAM} "${MYNAME}: ${STAT}"
		echo
		echo_log ${STAT}
		PREV_STAT=${STAT}
	else
		echo -n "."
	fi
	
	if [ "${STAT}" = "NG" ]; then
		if [ ${REBOOT_COUNT} -eq 0 ]; then
			reboot_eremote ${REBOOT_INTERVAL}
			REBOOT_COUNT=1
			INTERVAL=0
		fi
	fi

	sleep ${INTERVAL}
done
