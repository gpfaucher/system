#! /usr/bin/env bash

options="Suspend\nLogout\nReboot\nShutdown"
choice=$(echo -e "$options" | wofi --dmenu -p "Select an option")

case "$choice" in
"Suspend")
	sudo systemctl suspend
	;;
"Logout")
	sudo loginctl terminate-user "$USER"
	;;
"Reboot")
	sudo reboot now
	;;
"Shutdown")
	sudo poweroff
	exit 0
	;;
*)
	echo "Invalid selection or canceled."
	;;
esac
