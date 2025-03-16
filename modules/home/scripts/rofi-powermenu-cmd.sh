#! /usr/bin/env bash

printf Suspend"\n"Reboot | rofi -dmenu | xargs rofi-powermenu
