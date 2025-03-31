#! /usr/bin/env bash

choice=$(find /home/gabriel/drive/Books/ -name '*.pdf' | rofi -dmenu -p "Select an option")

zathura "$choice" &
