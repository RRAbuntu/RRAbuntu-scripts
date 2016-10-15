#!/bin/bash

set -x ## For testing purposes
#
# RRAbuntu-install.sh
#
# To assist in installing RRAbuntu.
#
#   Geoff Barkman 2010
#   (based on scripts created by Frederick Henderson)
#
#  RRAbuntu-install.sh,v 1.11 2010.03.18  FJH
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
## KEY TO CHANGE LOG AND CHANGES Initials
# FJH= Frederick Henderson frederickjh@henderson-meier.org
#
<<CHANGELOG
######################### CHANGE LOG ###########################
version 1.11
changed version numbers to match CD release numbers. 
intermediary changes before the next CD get a third number like
1.11.1 then 1.11.2 then 1.11.3 etc. -FJH

Changed starting dialogue to let the user know to click OK on the
windows and that we will be holding their hand. -FJH

Changed the starting dialogue into a question that offers to start 
the installer or allows them to abort the script.-FJH


################################################################
 version-less initial release with RRAbuntu Live CD 1.10
################################################################
CHANGELOG

## Changed opening dialog to a question offering to start the Ubuntu installer for them and allow them to abort as well.-FJH 2010.03.17
zenity --question --title "Install RRAbuntu?" --text="This script will install Ubuntu with Rivendell click on OK to start the installer or Cancel to abort.  Installing takes about 30 minutes depending on your hardware. Don't worry we will walk you through it. Just click the OK buttons in these windows after you complete each step and an new window will pop up to help you with the next step."
if [ ! $? = 0 ]; then
exit
else
# Start Ubuntu installer
ubiquity --desktop %k gtk_ui &
fi


sleep 5

zenity --info --title="RRAbuntu Installation - Step 1 of 7" --text="1 of 7  Welcome - Select your language. - Click forward"
sleep 5

zenity --info --title="RRAbuntu Installation - Step 2 of 7" --text="2 of 7 Where are you? - Select your location on the map. - Click forward"
sleep 5

zenity --info --title="RRAbuntu Installation - Step 3 of 7" --text="3 of 7 Keyboard layout - Choose your keyboard layout, or keep suggested keyboard layout. - Click forward"
sleep 5

zenity --warning --title="RRAbuntu Installation - Step 4 of 7" --text="4 of 7 Prepare disk space - Select use entire disk. (WARNING: Selecting this option will delete your entire existing hard drive contents) - Or you can choose partitions manually (advanced users) Beginners DON'T choose this. - Click forward" &
sleep 7

zenity --info --title="RRAbuntu Installation - Other Options Tip" --text="Note there are other options at this step, but I recommend, just erasing whole disk, rather than keeping windows, i.e. dual boot (for simplicity)"
sleep 5

zenity --info --title="RRAbuntu Installation - Step 5 of 7" --text="5 of 7 Who are you? - Type your name. - Type the user name you wish to use (NOTE:This will be all lower case letters.) - Enter your password x2 and the name of computer (could be your station name with no gaps) - Optionally select Log in automatically (Otherwise the password will be required on every boot.) - Click forward"
sleep 5
# Commented out by FJH. I think it is too confusing to the user.
#zenity --info --title="RRAbuntu Installation - Step 6 of 7" --text="6 of 7 No such page on installer (ops)"
#sleep 5

zenity --info --title="RRAbuntu Installation - Step 7 of 7" --text="7 of 7 - Ready to install - Check that the installation settings are all correct then, click Install"
sleep 10

zenity --info --title="RRAbuntu Installation - While you wait . . ." --text="While installing you can surf the net if you wish, just click Firefox icon. This will take 30 mins approximately (depends on hardware specifications)" &
sleep 10

zenity --info --title="RRAbuntu Installation - When the Installation is Finished . . ." --text="Once installation is complete, you will be prompted to Restart Now.... Stand clear of the CD drawer....Remove CD after it pops out.... and hit Enter "


