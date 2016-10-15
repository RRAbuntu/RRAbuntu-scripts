#!/bin/bash
set -x ## For testing purposes
#
# RRAbuntu-First_run.sh
#
# To assist in installing RRAbuntu.
#
#   Geoff Barkman 2010
#   (based on scripts created by Frederick Henderson)
#  RRAbuntu-First_run.sh,v 1.11 2010.03.18 FJH
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
#
<<CHANGELOG
########################## CHANGE LOG ##################################
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

#### NOTE: the first part of this script used to be RRAbuntu-Reboot-1.sh


# Change first dialog to question and added code to allow aborting. -FJH 2010.03.16
# Fixed typo spelling of RRAbuntu. -GPB 2010.03.22
zenity --question --title="Ready to configure RRAbuntu? " --text="These instructions are for configuring RRAbuntu on first reboot after the installation. Are you ready to do this?"
# Check the exit status $? to see if the user clicked OK(=0) or Cancel(=1).
# Then exit the whole script if they clicked Cancel.-FJH 2010.03.16
if [ ! $? = 0 ]; then
exit
fi

################### FUNCTIONS ##########################
#
# function to run commands as super user. This will keep give the user
# option to re-enter the password till they get it right or allow them
# to exit if something goes wrong instead of continuing on. 
# Usage:
#  run_sudo_command [COMMANDS...] -FJH 2010.03.17

run_sudo_command() {
# grab the commands pass to the function and put theme in a variable for safe keeping
sudocommand=$*
gksudo $sudocommand
# Check the exit status if it is not 0 (good) then assume that the password was not entered correctly and loop them till they get it right or cancel the running of this script.
while [ ! $? = 0 ]; do
zenity --question --title='Attention Needed!' --text="Something is not right here. (Did you correctly enter your password? Is the Caps-Locks on?) Do you want to try to enter the password again(OK) or exit this script(Cancel)?"
	if [ ! $? = 0 ]; then
		exit
		else 
		gksudo $sudocommand
	fi
done
}


# Changed dialog to state that they will be only asked for the
# password after they click OK.-FJH 2010.03.16
zenity --question --title='Password will be needed!' --text="You will be asked for your password after clicking OK. Please enter your Linux user password from the Ubuntu installation. We need this as some parts of the script need to be run as the super user. If the script takes longer than 5 minutes to complete you may be asked again. If you are uncomfortable with this select Cancel to exit."
if [ ! $? = 0 ]; then
	exit
fi

## Add user ubuntu to the rivendell and audio groups
# Add current User

# Make the current linux user name available as a system variable.
export currentuser=$(whoami)

run_sudo_command adduser $currentuser rivendell
run_sudo_command adduser $currentuser audio

# Find the string "AudioOwner=username"and replace the username
# part with the currently running linux username and save it to
# /etc/rd.conf  Also removed zenity, sleep and cp lines.-FJH 2010.03.16
run_sudo_command sed s/AudioOwner=username/AudioOwner=$currentuser/ ~/Desktop/Rivendell/rd.conf >~/Desktop/Rivendell/temp.conf
run_sudo_command cp ~/Desktop/Rivendell/temp.conf /etc/rd.conf
rm temp.conf
#/etc/rd.conf

##### FIXME
## Fix permissions to /var/snd currently the user is rduser not ubuntu
## nor the current user.
## Is this something we need to fix or is it something Alban needs to fix
## or does this go back to Fred G.?
## Moved up in the script to before Rivendell daemons are started and test tone is created. -FJH 2010.03.16
run_sudo_command chown $currentuser:rivendell /var/snd

##### FIXME
## Fix permissions to /var/log/rivendell currently the user is rduser not ubuntu
## nor the current user.
## Is this something we need to fix or is it something Alban needs to fix
## or does this go back to Fred G.?
run_sudo_command chown $currentuser:rivendell /var/log/rivendell

# Replaced dialog to tell the user to reboot with code below
# to start the Rivendell daemons. -FJH 2010.03.16
run_sudo_command /etc/init.d/rivendell start

#### NOTE: the script below here used to be RRAbuntu-Reboot-final.sh

## Start RDAdmin to get mysql database prompt to create
## rivendell database. This only happens the first time
## RDAdmin starts  after new install or after updating
## to a new version. It is very important to run
## RDAdmin after upgrading to a new version of Rivendell
rdadmin &
sleep 2

## Inform the user what the username and password are for
## The mysql database setup
zenity --info --text="A window titled mysql Admin will pop-up behind this one. The username is... root and the password is....  rivendell.  Close this window only after entering the username and password, Click OK and after the Created Database window with the message New Rivendell Database Created! pops up."

zenity --info --text="Now rdadmin will start up. The username is .... admin
with no password"


## Generate Test tone for the RDLibrary
# Removed sudo from rdgen command  to generate test tone as it is no
# longer needed now that the linux user is set as owner of the folder
# before it is run.-FJH 2010.03.17
rdgen -t 10 -l 16 /var/snd/999999_000.wav

## Since we are finished with sudo commands remove the user's
# timestamp entirely from the /etc/sudoer file to prevent them
# from running sudo command without retyping the password as a
# safety precaution. This would time-out in 5 minutes from the
# time the user enter the password to allow sudo command, but
# we want to be on the safe side.-FJH 2010.03.17
sudo -K



## Start up RDAirplay for the user
rdairplay &

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

zenity --info --text="If you heard the test tone twice then this script has properly configured Rivendell. Now on with the show!"

## Change to directory with promos and add them to the library
## Rename Rivendell promos so the look better in the demo. Instead of 
## "Imported from Mixdown?.flac we will get e.g. "Never Pay" -FJH 2010.03.16
cd ~/Desktop/Rivendell/Promos
mv Mixdown1.flac Rivendell_Promo-Never_Pay.flac
mv Mixdown2.flac Rivendell_Promo-15000_Dollars.flac
mv Mixdown3.flac Rivendell_Promo-Rock_Steady.flac
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

zenity --info --text="Thank you for installing RRAbuntu. Visit the Rivendell website and download the Rivendell Operations Guide from the Docs section on page. Print out for more advanced configuration. www.rivendellaudio.org . 
Many Thanks from Geoff Barkman, Frederick Henderson and Alban Peignier"



