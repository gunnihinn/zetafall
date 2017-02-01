#!/bin/sh

# PROVIDE: zetafall

. /etc/rc.subr

name="zetafall"
rcvar=zetafall_enable

command="/home/freebsd/${name}"
command_args="/home/freebsd"

zetafall_user=freebsd
start_cmd="/usr/sbin/daemon -u ${zetafall_user} ${command} ${command_args}"

load_rc_config $name
run_rc_command "$1"
