#!/bin/bash
#set -x ## For testing purposes
#
# RRAbuntu_autostart.sh
#
# Automatically displays either the readme.txt if booted from the CD or
# if booted from the hard drive a dialogue prompting the user to run the
# first run script.
#
#   C) Copyright 2010 Frederick Henderson <frederick@henderson-meier.org>
#   
#  RRAbuntu_autostart.sh,v 1.13 2010.05.25  FJH
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
#
## KEY TO CHANGE LOG AND CHANGES Initials
# FJH= Frederick Henderson frederickjh@henderson-meier.org
# geoff= Geoff Barkman
<<CHANGELOG
########################## CHANGE LOG ##################################
Version 2.0 - Beta
Reworded messages to they tell how to compile rivendell instead of running first-run script - geoff
########################################################
version 1.13
initial release -FJH
#######################################################
CHANGELOG

################### FUNCTIONS ##########################
#
# function to run commands as super user. This will keep give the user
# option to re-enter the password till they get it right or allow them
# to exit if something goes wrong instead of continuing on. 
# Usage:
#  run_sudo_command [COMMANDS...] -FJH 2010.03.17

run_sudo_command() {
# grab the commands passed to the function and put theme in a variable for safe keeping
sudocommand=$*
gksudo $sudocommand
# Check the exit status if it is not 0 (good) then assume that the password was not entered correctly and loop them till they get it right or cancel the running of this script.
while [ ! $? = 0 ]; do
zenity --question --title='RRAbuntu Rivendell Setup - Attention Needed!' --text="Something is not right here. (Did you correctly enter your password? Is the Caps-Locks on?) Do you want to try to enter the password again(OK) or exit this script(Cancel)?"
	if [ ! $? = 0 ]; then
		exit
		else 
		gksudo $sudocommand
	fi
done
}


readme_displayer(){
# Get the screen sizes, find the line with the asterisks that shows the
# current screen size, get the first column with the screen dimensions,
# then using the "x" as a separator get first the screen width and then the height.
WIDTH=$(xrandr | sed -n '/\*/p' | awk '{ print $1 }' | awk -F "x" '{ print $1 }')
HEIGHT=$(xrandr | sed -n '/\*/p' | awk '{ print $1 }' | awk -F "x" '{ print $2 }')

# Now that we have the screen size figure out what size to make the dialog
PERCENTWIDTH=$(echo "scale=0; $WIDTH*87.9/100" | bc )
PERCENTHEIGHT=$(echo "scale=0; $HEIGHT*62.5/100" | bc )

if [ $PERCENTWIDTH -gt 800 ]; then
SCREENWIDTH=800
else
SCREENWIDTH=$PERCENTWIDTH
fi

if [ $PERCENTHEIGHT -gt 800 ]; then
SCREENHEIGHT=800
else
SCREENHEIGHT=$PERCENTHEIGHT
fi


currentuser=$(whoami)
zenity --text-info --title="Welcome to RRAbuntu" --width=$SCREENWIDTH --height=$SCREENHEIGHT --filename="/etc/skel/Rivendell/README.txt"
}

first_run_prompter(){
# Inform the user that we still need to setup Rivendell then offer to start the script.
# Reworded message because we don't have the demo available now on the demo :( - geoff
zenity --question --text="Now that you have installed Ubuntu we need to compile Rivendell. Do you wish to do this?"
if [ ! $? = 0 ]; then
exit
else
# Start the RRAbuntu_first_run.sh script
#/etc/skel/Rivendell/RRAbuntu-First_run.sh &

# Replaced  RRAbuntu_first run with a pop up of instructions telling how to compile it. - geoff
zenity --info --title="RRAbuntu Setup" --text="To set up RRAbuntu. Double click on Rivendell_Compile.sh on the desktop and choose RUN IN TERMINAL"

fi
}

################## HERE STARTS THE MAIN PROGRAM ####################

# Check for /rofs directory and for the file /etc/casper.conf that only exists when booted from the CD.
if [ -d /rofs -a -f /etc/casper.conf ] ; then
        readme_displayer
else
        first_run_prompter
fi

# END
