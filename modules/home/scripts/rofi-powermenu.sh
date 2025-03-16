#! /usr/bin/env bash

case "$@" in
Suspend)
	sudo systemctl suspend
	;;

Reboot)
	sudo reboot now
	;;
esac
