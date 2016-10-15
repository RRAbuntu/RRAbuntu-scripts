#!/bin/bash
#set -x ## For testing purposes
#
# RRAbuntu-Reboot-1.sh
#
# To assist in installing RRAbuntu.
#
#   Geoff Barkman 2010
#   (based on scripts created by Frederick Henderson)
#   
#   Sections below created by Frederick Henderson
# 
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License version 2 as
#   published by the Free Software Foundation.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#


zenity --info --text="These instructions are for configuring RRAbuntu on first reboot"
sleep 5

zenity --info --text="You will get asked for your password in a few seconds... Note super user commands will ask for your password. If your not familiar with a terminal, your typing will be invisible as you type your password"

sleep 5

## Add user ubuntu to the rivendell and audio groups
# Add current User

export currentuser=$(whoami)

sudo adduser $currentuser rivendell
sudo adduser $currentuser audio

sleep 2
zenity --info --text="Now we have edit the rd.conf file... Replace username with the name you used when you installed RRAbuntu. Close this once you have saved the file"

sleep 2

sudo cp ~/Desktop/Rivendell/rd.conf /etc/rd.conf

sleep 2

zenity --info --text="Now we have to restart the system"
