#!/bin/bash
#set -x ## For testing purposes
#
# RRAbuntu-First_run.sh
#
# To assist in installing RRAbuntu. To be run after installing Ubuntu and rebooting.
#
#   Geoff Barkman 2010
#   (based on scripts created by Frederick Henderson)
#  RRAbuntu-First_run.sh,v 1.13 2010.05.21  FJH
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
#
## KEY TO CHANGE LOG AND CHANGES Initials
# FJH= Frederick Henderson frederickjh@henderson-meier.org
# geoff= Geoff Barkman
<<CHANGELOG
########################## CHANGE LOG ##################################
version 1,14

Major rewrite to get everything that I could into functions. My hope is
that this will make the code more portable and we can eventually merge
everything into one script.
########################################################################
version 1.13

Clean up, Added code to get rid of the desktop file that starts the First_run_prompter.sh script that 
displays a prompt to run this script, down at the end. FJH

Fixed paths that use to go to ~/Desktop/Rivendell to go to
/etc/skel/Rivendell. FJH

Added loop to hold up the script till RDAirplay starts. FJH

########################################################################
version1.12
Removed unneeded sudo on sed command.-FJH

Added code for positioning the zenity dialog windows. Windows with 
RRAbuntu in the title will be sent down to the bottom center of the 
screen, while windows with titles with Tip in them will be sent to 
the bottom left-hand corner. Only include one of the keywords 
(RRAbuntu, Tip) in the title or things may not work the way you want. 
The .ds files set-up the parameters on where which windows should go.
We use a program called devilspie to move the windows around. So we 
will start and stop it after we are finished. Add more .ds files to 
add new positioning set-ups. -FJH

Moved demo install to a function. Also change dialog after test tones play 
to a question that allows the user to decide if they want to install the demo or not. -FJH

Made section at end of code to delete Desktop icons and 
add new icons on Desktop section. -geoff

########################################################################
version 1.11
changed version numbers to match CD release numbers. 
intermediary changes before the next CD get a third number like
1.11.1 then 1.11.2 then 1.11.3 etc.-FJH

Changed sudo statements to be done via a function that also make 
sure that the script does not continue on its merry way if something 
does not happen correctly.-FJH

Change initial prompt to a question and added code so the user can abort
the script if it is not what they wanted to do.-FJH

Removed some unneeded sleep statements that were just slowing down the
pop-up of dialogues.-FJH

Added code to change the owner of /var/log/rivendell to the current linux
user. Needs fixing upstream. -FJH

Added code to automate changing the linux user name in rd.conf to the
current linux user and then save it in /etc/rd.conf -FJH

Moved code to fix permissions for /var/snd up in script to before
Rivendell daemons start and test tone is created.-FJH

Removed sudo from rdgen command  to generate test tone as it is no
longer needed now that the linux user is set as owner of the folder
before it is run.-FJH

Replace dialogue to reboot computer with code to start the Rivendell
daemons. -FJH

Added renaming of Rivendell Promos to script -FJH

Set the asyncronous field to N as this was causing a runawy condition
in the Aux1 log that was disrupting the audio playout as it was trying
to run all the macros in the cart at once. Also added new text to the 
cart to let folks know their messages cand appear in "The Label Area" -FJH


#######################################################
 version less initial release with RRAbuntu Live CD 1.10 was two
 scripts RRAbuntu-Reboot-1.sh and RRAbuntu-Reboot-final.sh
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



function restartdaemons(){
# Restart Rivendell daemons
run_sudo_command /etc/init.d/rivendell stop
run_sudo_command /etc/init.d/rivendell start
}

function devilspiestartup(){
## Devilspie code to position windows.
# Get the screen sizes, find the line with the asterisks that shows the
# current screen size, get the first column with the screen dimensions,
# then using the "x" as a separator get first the screen width and then the height.
WIDTH=$(xrandr | sed -n '/.0\*/p' | awk '{ print $1 }' | awk -F "x" '{ print $1 }')
HEIGHT=$(xrandr | sed -n '/.0\*/p' | awk '{ print $1 }' | awk -F "x" '{ print $2 }')

# Figure out where to position the top left corner of of our window based on the width
# of the screen. The zenity dialogs are normally 443 pixel wide. So we subtract this
# from the width and divide by 2.
HORIZONTALPOS=$(echo "($WIDTH-443)/ 2" | bc )

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
}

function readytoconfigure(){
# Question the user if the really want to run the script.
zenity --question --title="RRAbuntu Rivendell Setup - Ready to configure? " --text="These instructions are for configuring RRAbuntu on first reboot after the installation. Are you ready to do this?"
# Check the exit status $? to see if the user clicked OK(=0) or Cancel(=1).
# Then exit the whole script if they clicked Cancel.-FJH 2010.03.16
if [ ! $? = 0 ]; then
exit
fi
}

function disablepaautospawning(){
## Turn off pulseaudio autospawning and then kill all instances of it.
# Copy pulseaudo client configuration file to home folder
cp /etc/pulse/client.conf ~/.pulse/client.conf

# Find the string "; autospawn = yes"and replace it with
# autospawn = no. This disables pulseaudio autospawning. FJH 
sed s/\;\ autospawn\ =\ yes/autospawn\ =\ no/ ~/.pulse/client.conf >~/temp.conf
cp ~/temp.conf ~/.pulse/client.conf
rm ~/temp.conf

# Kill pulseaudio 
killall pulseaudio
}

function entersudopassword(){
# Ask user to under the SUDO password to run commands as the super user.
zenity --question --title='RRAbuntu Rivendell Setup - Password will be needed!' --text="You will be asked for your password after clicking YES. Please enter your Linux user password from the Ubuntu installation. We need this as some parts of the script need to be run as the super user. If the script takes longer than 5 minutes to complete you may be asked again. If you are uncomfortable with this select NO to exit."
if [ ! $? = 0 ]; then
	exit
fi
}

function addcurrentlinuxusertorivendellandaudiogroups(){
## Add current linux user to the rivendell and audio groups
# Make the current linux user name available as a system variable.
export currentuser=$(whoami)
run_sudo_command adduser $currentuser rivendell
run_sudo_command adduser $currentuser audio
}

function copycurrenlinuxusertoaudioowner(){
# Find the string "AudioOwner=username"and replace the username
# part with the currently running linux username and save it to
# /etc/rd.conf  Also removed zenity, sleep and cp lines.-FJH 2010.03.16
# Removed sudo on the sed command below for security reasons as it is not need.-FJH 2010-03-24
sed s/AudioOwner=username/AudioOwner=$currentuser/ /etc/skel/Rivendell/rd.conf >~/temp.conf
run_sudo_command cp ~/temp.conf /etc/rd.conf
rm ~/temp.conf
}

function setpermissionsforvarsnd(){
##### FIXME
## Fix permissions to /var/snd currently the user is rduser not ubuntu
## nor the current user.
## Is this something we need to fix or is it something Alban needs to fix
## or does this go back to Fred G.?
## Moved up in the script to before Rivendell daemons are started and test tone is created. -FJH 2010.03.16
run_sudo_command chown $currentuser:rivendell /var/snd
}

function setpermissionsforvarlogrivendell(){
##### FIXME
## Fix permissions to /var/log/rivendell currently the user is rduser not ubuntu
## nor the current user.
## Is this something we need to fix or is it something Alban needs to fix
## or does this go back to Fred G.?
run_sudo_command chown $currentuser:rivendell /var/log/rivendell
}

function startrivendelldaemons(){
# Start the Rivendell daemons. -FJH 2010.03.16
run_sudo_command /etc/init.d/rivendell start
}

function startrdadminfirsttime(){
## Start RDAdmin to get mysql database prompt to create
## rivendell database. This only happens the first time
## RDAdmin starts  after new install or after updating
## to a new version. It is very important to run
## RDAdmin after upgrading to a new version of Rivendell
rdadmin &
sleep 2

## Inform the user what the username and password are for
## The mysql database setup
zenity --info --title="RRAbuntu Rivendell Setup - MySQL" --text="A window titled mysql Admin will pop-up behind this one. The username is... root and the password is....  rivendell.  Close this window only after entering the username and password, Click OK and after the Created Database window with the message New Rivendell Database Created! pops up."

zenity --info --title="RRAbuntu Rivendell Setup - RDAdmin" --text="Now rdadmin will start up. The username is .... admin
with no password"
}

function generatetesttone(){
## Generate Test tone for the RDLibrary
# Removed sudo from rdgen command  to generate test tone as it is no
# longer needed now that the linux user is set as owner of the folder
# before it is run.-FJH 2010.03.17
rdgen -t 10 -l 16 /var/snd/999999_000.wav
}

function removesudotimestamp(){
## Since we are finished with sudo commands remove the user's
# timestamp entirely from the /etc/sudoer file to prevent them
# from running sudo command without retyping the password as a
# safety precaution. This would time-out in 5 minutes from the
# time the user enter the password to allow sudo command, but
# we want to be on the safe side.-FJH 2010.03.17
sudo -K
}

function rdairplaydemo(){
## Start up RDAirplay for the user
rdairplay &

# Hang around waiting for RDAirplay to appear. -FJH 2010.05.21
ISITOPENYET=$(wmctrl -l | sed -n '/.RDAirPlay/p' | awk '{ print $4 }')
while [ -z $ISITOPENYET  ]; do
sleep 1
ISITOPENYET=$(wmctrl -l | sed -n '/.RDAirPlay/p' | awk '{ print $4 }')
done
sleep 1

## Welcome the user with a label in Rivendell
rmlsend LC\ blue\ Welcome\ to\ Rivendell\ Radio\ Automation\!
sleep 1

## Load test tone into Main log=1 (Aux 1 log=2, Aux 2 log=3)
rmlsend PX\ 1\ 999999\!
sleep 1

## Start the log playing
rmlsend PN\ 1\!
sleep 10

## Load the test tone in the button at row 1, column 1 of the current panel.
rmlsend PE\ C\ 1\ 1\ 999999\!
sleep 1

#Play the button at row 1, column 1 of the current panel.
rmlsend PP\ C\ 1\ 1\!

sleep 6
## Changed OK and CANCEL to YES and NO geoff 2010.05.08
zenity --question --title="RRAbuntu Rivendell Setup - Did you hear it?" --text="If you heard the test tone twice then this script has properly configured Rivendell. If you would like, we can now install the demo the same as with the live CD.  Press YES to install the demo audio and logs. NO to not install the demo."
# Check the exit status $? to see if the user clicked OK(=0) or Cancel(=1).
# Then exit the whole script if they clicked Cancel.-FJH 2010.03.16
if [ $? = 0 ]; then
install_demo
fi
}

install_demo() {
## Change to directory with promos and add them to the library
cd /etc/skel/Rivendell/Promos
rdimport --to-cart=999998 --metadata-pattern=%a-%t. TRAFFIC  ./*.flac

## Set up the variables to use in the script
##### FIXME The variables below are hard coded in. This is ok
# for the demo run but if anyone wants to change their usernames
# or passwords this means this script will fail. We should also
# allow the user the option to set passwords and usernames as well.
# -FJH 2010.03.16
USER=root
PASSWORD=rivendell
RD_USER=rduser@localhost
RD_PASSWORD=letmein
CARTSTOADD=10
COUNTER=0
ID=1
COUNT=1

## Loop through and add the carts to create the Sample log
while [ $COUNTER -le $CARTSTOADD ]; do

mysql -u $USER -p$PASSWORD -e"USE Rivendell;
insert into SAMPLE_LOG(ID,COUNT,CART_NUMBER) VALUES($ID,$COUNT,999998)"

let COUNTER=COUNTER+1
let ID=ID+1
let COUNT=COUNT+1
done

## Add macro at the end of the audio log to load the same
## audio log to keep it running forever or till the user hits stop.
mysql -u $USER -p$PASSWORD -e"USE Rivendell;
insert into SAMPLE_LOG(ID,COUNT,TYPE,COMMENT,LABEL) VALUES($ID,$COUNT,5,\"Sample\ Log\",\"SAMPLE\")"

## Change the Title and Artist of our Rivendell Promo cart
mysql -u $USER -p$PASSWORD -e"USE Rivendell;
update CART set TITLE=\"Rivendell\ Promo\", ARTIST=\"The\ Rivendell\ Announcer\ Guy\" where NUMBER=999998"

#
# Create Titles Log
#
mysql -u $USER -p$PASSWORD -e"USE Rivendell;
      CREATE TABLE IF NOT EXISTS TITLES_LOG (
      ID INT NOT NULL PRIMARY KEY,
      COUNT INT NOT NULL,
      TYPE INT DEFAULT 0,
      SOURCE INT(11) SIGNED DEFAULT 0,
      START_TIME TIME NOT NULL,
      GRACE_TIME INT(11) SIGNED DEFAULT 0,
      CART_NUMBER INT UNSIGNED NOT NULL,
      TIME_TYPE INT NOT NULL,
      POST_POINT ENUM('N','Y') DEFAULT 'N',
      TRANS_TYPE INT NOT NULL,
      START_POINT INT NOT NULL DEFAULT -1,
      END_POINT INT NOT NULL DEFAULT -1,
      FADEUP_POINT INT(11) SIGNED DEFAULT -1,
      FADEUP_GAIN  INT(11) SIGNED DEFAULT -3000,
      FADEDOWN_POINT INT(11) SIGNED DEFAULT -1,
      FADEDOWN_GAIN INT(11) SIGNED DEFAULT -3000,
      SEGUE_START_POINT INT NOT NULL DEFAULT -1,
      SEGUE_END_POINT INT NOT NULL DEFAULT -1,
      SEGUE_GAIN INT(11) SIGNED DEFAULT -3000,
      DUCK_UP_GAIN INT(11) DEFAULT 0,
      DUCK_DOWN_GAIN INT(11) DEFAULT 0,
      COMMENT CHAR(255),
      LABEL CHAR(64),
      ORIGIN_USER CHAR(255),
      ORIGIN_DATETIME DATETIME,
      LINK_EVENT_NAME CHAR(64),
      LINK_START_TIME INT(11) SIGNED,
      LINK_LENGTH INT(11) SIGNED DEFAULT 0,
      LINK_START_SLOP INT(11) SIGNED DEFAULT 0,
      LINK_END_SLOP INT(11) SIGNED DEFAULT 0,
      LINK_ID INT(11) SIGNED DEFAULT -1,
      LINK_EMBEDDED ENUM('N','Y') DEFAULT 'N',
      EXT_START_TIME TIME,
      EXT_LENGTH INT(11) SIGNED,
      EXT_CART_NAME CHAR(32),
      EXT_DATA CHAR(32),
      EXT_EVENT_ID CHAR(8),
      EXT_ANNC_TYPE CHAR(8),
      INDEX COUNT_IDX (COUNT),
      INDEX CART_NUMBER_IDX (CART_NUMBER),
      INDEX START_TIME_IDX (START_TIME),
      INDEX LABEL_IDX (LABEL)
)"

mysql -u $USER -p$PASSWORD -e"USE Rivendell;
      GRANT ALL ON TITLES_LOG TO $RD_USER IDENTIFIED BY \"$RD_PASSWORD\""
mysql -u $USER -p$PASSWORD -e"USE Rivendell;
      INSERT INTO LOGS (NAME,SERVICE,DESCRIPTION,ORIGIN_USER,ORIGIN_DATETIME)
      VALUES (\"TITLES\",\"Production\",\"Titles Log\",\"user\",NOW())"


#
# Create Welcome Macro Cart
# Set the asyncronous field to N as this was causing a runawy condition
# in the Aux1 log that was disrupting the audio playout as it was trying
# to run all the macros in the cart at once.-FJH 2010.03.18
mysql -u $USER -p$PASSWORD -e"USE Rivendell;      INSERT INTO CART(TYPE,NUMBER,GROUP_NAME,TITLE,CUT_QUANTITY,FORCED_LENGTH,ASYNCRONOUS,MACROS)
      VALUES (2,050001,\"MACROS\",\"Welcome\",0,6000,\"N\",\"\LC\ blue\ Welcome\ to\ Rivendell\ Radio\ Automation\!SP\ 3000\!LC\ red\ Open\ Source\ Broadcast\ Automation\!SP\ 3000\!LC\ green\ RRAbuntu\ Live\ CD\ Project\!SP\ 3000\!LC\ darkcyan\ The\ Easiest\ Rivendell\ Demo\ and\ Install\!SP\ 3000\!LC\ darkBlue\ Your\ Messages\ and\ Alerts\ for\ Your\ DJs\ Can\ Display\ Here\ Too.\!SP\ 3000\!\")"

## Reset the variables for the lines in the log
ID=1
COUNT=1
## Add Welcome Macro Cart to Titles log
mysql -u $USER -p$PASSWORD -e"USE Rivendell;
insert into TITLES_LOG(ID,COUNT,CART_NUMBER) VALUES($ID,$COUNT,050001)"

let ID=ID+1
let COUNT=COUNT+1

## Add macro at the end of the titles log to load the same
## audio log to keep it running forever or till the user hits stop.
mysql -u $USER -p$PASSWORD -e"USE Rivendell;
insert into TITLES_LOG(ID,COUNT,TYPE,COMMENT,LABEL) VALUES($ID,$COUNT,5,\"Titles\ Log\",\"TITLES\")"


## Load the Sample Log in the Main log
rmlsend LL\ 1\ Sample\ Log!

## Load the Titles Log in the Aux 1 log
rmlsend LL\ 2\ Titles\ Log!

sleep 100
}

function thanksforinstallingrrabuntu(){
zenity --info --title="RRAbuntu Rivendell Setup" --text="Thank you for installing RRAbuntu. Visit the Rivendell website and download the Rivendell Operations Guide from the Docs section on page. Print out for more advanced configuration. www.rivendellaudio.org . 
Many Thanks from Geoff Barkman, Frederick Henderson and Alban Peignier"
}

function cleanupicons(){
sleep 5

zenity --question --title="PS. Clean up and Add Icons?" --text="P.S. Did you want to delete the no longer required Installer icons and add some New Icons on the desktop for Rdairplay, Rdlibrary, Rdedit and Rdlogmanager?  If you do need them again there is some back up copies sitting in your home directory in the Rivendell icons folder"
# Check the exit status $? to see if the user clicked Yes(=0) or No(=1).
# Delete icons and add new ones if they answer yes
# Then continue with the rest of the script if they clicked No.-geoff 2010.05.10
if [ ! $? = 1 ]; then

# Delete the unneeded Desktop icons.
#rm ~/Desktop/Read_Me_First.desktop
rm /home/$currentuser/Desktop/RRAbuntu_Install.desktop
rm /home/$currentuser/Desktop/RRAbuntu_Demo.desktop
rm /home/$currentuser/Desktop/RRAbuntu_Post_Install.desktop

# Copy Icons to the desktop
cp /home/$currentuser/Rivendell/icons/rdairplay.desktop /home/$currentuser/Desktop/rdairplay.desktop
cp /home/$currentuser/Rivendell/icons/rdlibrary.desktop /home/$currentuser/Desktop/rdlibrary.desktop
cp /home/$currentuser/Rivendell/icons/rdlogedit.desktop /home/$currentuser/Desktop/rdlogedit.desktop
cp /home/$currentuser/Rivendell/icons/rdlogmanager.desktop /home/$currentuser/Desktop/rdlogmanager.desktop

fi
}

function devilspiecleanup(){
# Clean up, if devilspie was running before we started this script then leave it running otherwise kill it.
if [ ! $LEAVEDEVILSPIERUNNING = 1 ]; then
	killall devilspie
fi
}

function cleanuprrabuntu_autostart_sh_desktop(){
# Clean up, Get rid of desktop file that displays the prompt to run this script. FJH
rm ~/.config/autostart/RRAbuntu_autostart.sh.desktop
}

################## HERE STARTS THE MAIN PROGRAM ####################
devilspiestartup
readytoconfigure
disablepaautospawning
entersudopassword
addcurrentlinuxusertorivendellandaudiogroups
copycurrenlinuxusertoaudioowner
setpermissionsforvarsnd
setpermissionsforvarlogrivendell
startrivendelldaemons
startrdadminfirsttime
generatetesttone
removesudotimestamp
rdairplaydemo
thanksforinstallingrrabuntu
cleanupicons
devilspiecleanup
cleanuprrabuntu_autostart_sh_desktop
# END
