#!/bin/bash
#set -x ## For testing purposes
#
# RRAbuntu-install.sh
#
# To assist in installing RRAbuntu. This script walks the user through installing Ubuntu.
#
#   Geoff Barkman 2010
#   (based on scripts created by Frederick Henderson)
#
#  RRAbuntu-install.sh,v 2.0 beta 2011.05.30  Geoff
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
# geoff= Geoff Barkman
#
<<CHANGELOG
######################### CHANGE LOG ###########################
version 2.0 - beta

Added 5 second pause while Ubuntu installer detects your region - Geoff 2011.06.01

################################################################
version 1.12

Added code for positioning the zenity dialog windows. Windows with 
RRAbuntu in the title will be sent down to the bottom center of the 
screen, while windows with titles with Tip in them will be sent to 
the bottom left-hand corner. Only include one of the keywords 
(RRAbuntu, Tip) in the title or things may not work the way you want. 
The .ds files setup the parameters on where which windows should go.
We use a program called devilspie to move the windows around. So we 
will start and stop it after we are finished. Add more .ds files to 
add new positioning setups. -FJH

Added code to position the Installer windows. This is done with a 
program called wmctrl.-FJH

Moved Rivendell folder from Desktop into users home directory.
Changed closing message on installer because everything ran from 
icons on desktop.-geoff 2010.05.09 

################################################################
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


## Added devilspie code to position windows.-FJH 2010.03.25


# Get the screen sizes, find the line with the asterisks that shows the
# current screen size, get the first column with the screen dimensions,
# then using the "x" as a separator get first the screen width and then the height.
WIDTH=$(xrandr | sed -n '/.0\*/p' | awk '{ print $1 }' | awk -F "x" '{ print $1 }')
HEIGHT=$(xrandr | sed -n '/.0\*/p' | awk '{ print $1 }' | awk -F "x" '{ print $2 }')

# Figure out where to position the top left corner of of our window based on the width
# of the screen. The zenity dialogs are normally 443 pixel wide. So we subtract this
# from the width and divide by 2.
HORIZONTALPOS=$(echo "($WIDTH-443)/ 2" | bc )

# Figure out where to position the top left corner of of our Installer window based on the width
# of the screen. The installer dialogs are 816 pixel wide. So we subtract this
# from the width and divide by 2.
HORIZONTALPOSINSTALLER=$(echo "($WIDTH-816)/ 2" | bc )


# Put the horizontal position in our RRAbuntu.ds file to position the windows with
# RRAbuntu. Make .devilspie dirctory in the users home folder. Then copy RRAbuntu.ds
# and the Tips.ds file to their proper home.
sed s/REPLACEME/$HORIZONTALPOS/ /etc/skel/devilspie/RRAbuntu.ds >~/temp.ds
cp ~/temp.ds ~/.devilspie/RRAbuntu.ds
rm ~/temp.ds

# Figure out if devilspie is running. If so remember this, kill it and restart it so
# it re-reads the configuration files and we will also redirect error messages to the trash.
# Way down at the end of this script we will decided whether or not we should kill devilspie or let it run.
DEVILSPIEPS=$(ps -C devilspie -o comm=)
LEAVEDEVILSPIERUNNING=0
if [ ! -z $DEVILSPIEPS ]; then
	LEAVEDEVILSPIERUNNING=1
fi
echo $LEAVEDEVILSPIERUNNING
killall devilspie
devilspie 2> /dev/null &


## Changed OK to YES and Cancel to NO - geoff
## Changed opening dialog to a question offering to start the Ubuntu installer for them and allow them to abort as well.-FJH 2010.03.17
zenity --question --title "Install RRAbuntu?" --text="This script will install Ubuntu with Rivendell click on YES to start the installer or NO to abort.  Installing takes about 30 minutes depending on your hardware. Don't worry we will walk you through it. Just click the OK buttons in these windows after you complete each step and an new window will pop up to help you with the next step."
if [ ! $? = 0 ]; then
exit
else
# Let the user know we are doing something the installer takes a while to load on my test machine.-FJH 2010.03.27
zenity --info --title="Starting the installer." --text="Please wait, we are starting the installer." --timeout=30 &
# Start Ubuntu installer
ubiquity --desktop %k gtk_ui &
fi

# Hang around waiting for our Install window to appear then reposition it using wmctrl. -FJH 2010.03.26
ISITOPENYET=$(wmctrl -l | sed -n '/.Install/p' | awk '{ print $4 }')
while [ -z $ISITOPENYET  ]; do
sleep 1
ISITOPENYET=$(wmctrl -l | sed -n '/.Install/p' | awk '{ print $4 }')
done
sleep 10
wmctrl -F -r Install -e 0,$HORIZONTALPOSINSTALLER,0,-1,-1
wmctrl -F -r Install -e 0,$HORIZONTALPOSINSTALLER,0,-1,-1

zenity --info --title="RRAbuntu Installation - Step 1 of 7" --text="1 of 7  Welcome - Select your language. - Click forward"
wmctrl -F -r Install -e 0,$HORIZONTALPOSINSTALLER,0,-1,-1

# Added 5 sec delay so that there is a small pause while Ubuntu detects your region. - Geoff
sleep 5

zenity --info --title="RRAbuntu Installation - Step 2 of 7" --text="2 of 7 Where are you? - Select your location on the map. - Click forward" --width=443
wmctrl -F -r Install -e 0,$HORIZONTALPOSINSTALLER,0,-1,-1

zenity --info --title="RRAbuntu Installation - Step 3 of 7" --text="3 of 7 Keyboard layout - Choose your keyboard layout, or keep suggested keyboard layout. - Click forward"
wmctrl -F -r Install -e 0,$HORIZONTALPOSINSTALLER,0,-1,-1

zenity --warning --title="RRAbuntu Installation - Step 4 of 7" --text="4 of 7 Prepare disk space - Select use entire disk. (WARNING: Selecting this option will delete your entire existing hard drive contents) - Or you can choose partitions manually (advanced users) Beginners DON'T choose this. - Click forward" &

sleep 7

zenity --info --title="Tip" --text="Note there are other options at this step, but I recommend, just erasing whole disk, rather than keeping windows, i.e. dual boot (for simplicity)" --width=310
wmctrl -F -r Install -e 0,$HORIZONTALPOSINSTALLER,0,-1,-1

zenity --info --title="RRAbuntu Installation - Step 5 of 7" --text="5 of 7 Who are you? - Type your name. - Type the user name you wish to use (NOTE:This should be all lower case letters.) - Enter your password x2 and the name for the computer on the network(could be your station name with no gaps) - Optionally select Log in automatically (Otherwise the password will be required on every boot.) - Click forward"
wmctrl -F -r Install -e 0,$HORIZONTALPOSINSTALLER,0,-1,-1

zenity --info --title="RRAbuntu Installation - Step 7 of 7" --text="7 of 7 - Ready to install - Check that the installation settings are all correct then, click Install" --width=443


zenity --info --title="Tip - While you wait . . ." --text="While installing you can surf the net if you wish, just click Firefox icon. This will take 30 mins approximately (depends on hardware specifications)" --width=310 
sleep 10

zenity --info --title="RRAbuntu Installation - When the Installation is Finished . . ." --text="Once installation is complete, you will be prompted to Restart Now.... Stand clear of the CD drawer....Remove CD after it pops out.... and hit Enter " 
sleep 30 

##reworded because installer now run from desktop shortcut
zenity --info --title="Tip - After the Reboot . ." --text="After the reboot you will want to click on the Post Install RRAbuntu icon on the desktop to setup Rivendell." --width=310 
sleep 


# Cleanup, if devilspie was running before we started this script then leave it running otherwise kill it.
if [ ! $LEAVEDEVILSPIERUNNING = 1 ]; then
	killall devilspie
fi

# END
