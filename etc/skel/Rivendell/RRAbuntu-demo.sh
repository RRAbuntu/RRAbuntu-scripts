#!/bin/bash
#set -x ## For testing purposes
#
#RRAbuntu-demo.sh 
#
# Setup test tone, promos, sample logs for demoing Rivendell with RRAbuntu.
#
#   (C) Copyright 2010 Frederick Henderson <frederick@henderson-meier.org>
#
#      RRAbuntu-demo.sh,v 1.13 2010.05.21  FJH
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
<<CHANGELOG
####################### CHANGE LOG ######################
version 1.13
Removed commands to close and open Nautilus at beginning and 
end as now the scripts are started from icons on the desktop. FJH

Added code to turn off pulseaudio autospawning and killed any 
running pulseaudio instances. FJH

Fixed paths that use to go to ~/Desktop/Rivendell to go to
/etc/skel/Rivendell. FJH

Added loop to hold up the script till RDAirplay starts. FJH

#########################################################
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

Moved Rivendell directory from Desktop into users home directory.
Modified to point to files in the /etc/skel directory - geoff 2010.05.09

################################################################
 version 1.11
 changed version numbers to match CD release numbers. 
 intermediary changes before the next CD get a third number like
 1.11.1 then 1.11.2 then 1.11.3 etc. -FJH

 Added renaming of Rivendell Promos to script -FJH

 Removed extra RML command to start play list as loading the
 play list also started the its as well. This was causing the
 audio to jump at the start of the demo. -FJH

Set the asyncronous field to N as this was causing a runawy condition
in the Aux1 log that was disrupting the audio playout as it was trying
to run all the macros in the cart at once.-FJH

Moved code to set proper permissions for /var/snd up in the script to 
before Rivendell daemons are started and test tone is created. -FJH

Removed sudo from rdgen command  to generate test tone as it is no
longer needed now that the linux user is set as owner of the folder
before it is run.-FJH

#########################################################
 version 1.25 initial release with RRAbuntu Live CD 1.10
#########################################################
CHANGELOG

## Added devilspie code to position windows.-FJH 2010.03.25

# Get the screen sizes, find the line with the asterisks that shows the
# current screen size, get the first column with the screen dimensions,
# then using the "x" as a separator get first the screen width and then the height.
WIDTH=$(xrandr | sed -n '/\*/p' | awk '{ print $1 }' | awk -F "x" '{ print $1 }')
HEIGHT=$(xrandr | sed -n '/\*/p' | awk '{ print $1 }' | awk -F "x" '{ print $2 }')

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

## Add user ubuntu to the rivendell and audio groups
sudo adduser ubuntu rivendell
sudo adduser ubuntu audio

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

# Restart Rivendell daemons just in case the got messed up
# by pulseaudio starting at the same time. FJH
/etc/init.d/rivendell stop
/etc/init.d/rivendell start

## Start RDAdmin to get mysql database prompt to create
## rivendell database. This only happens the first time
## RDAdmin starts  after new install or after updating
## to a new version. It is very important to run
## RDAdmin after upgrading to a new version of Rivendell
rdadmin &
sleep 2

## Inform the user what the username and password are for
## The mysql database setup
zenity --info --title="RRAbuntu Demo Setup - MySQL" --text="A window titled mysql Admin will pop-up. The username is... root and the password is....  rivendell.  Close this window only after entering the username and password, Click OK and after the Created Database window with the message New Rivendell Database Created! pops up."

zenity --info --title="RRAbuntu Demo Setup - RDAdmin" --text="Now rdadmin will start up. The username is .... admin
with no password"

## FIXME
## Fix permissions to /var/snd currently the user is rduser not ubuntu
## Is this something we need to fix or is it something Alban needs to fix
## or does this go back to Fred G.?
## Moved up in the script to before Rivendell daemons are started and test tone is created. -FJH 2010.03.16
sudo chown ubuntu:rivendell /var/snd

## Generate Test tone for the RDLibrary
# Removed sudo from rdgen command  to generate test tone as it is no
# longer needed now that the linux user is set as owner of the folder
# before it is run.-FJH 2010.03.17
rdgen -t 10 -l 16 /var/snd/999999_000.wav

## Start up RDAirplay for the user
# Removed ampersand after rdairplay. This was allowing the script 
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

## Load the test tone in the button at row 1, column 1 of the current pannel.
rmlsend PE\ C\ 1\ 1\ 999999\!
sleep 1

#Play the button at row 1, column 1 of the current panel.
rmlsend PP\ C\ 1\ 1\!
sleep 5

zenity --info --title="RRAbuntu Demo Setup - Congratulations!" --text="If you heard the test tone twice then this script has properly configured Rivendell. Now on with the show!"

sleep 1

## Change to directory with promos and add them to the library -FJH
cd /etc/skel/Rivendell/Promos
rdimport --to-cart=999998 --metadata-pattern=%a-%t. TRAFFIC  ./*.flac


## Set up the variables to use in the script
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
insert into TITLES_LOG(ID,COUNT,CART_NUMBER)VALUES($ID,$COUNT,050001)"

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

zenity --info --title="RRAbuntu Demo Setup - Thanks!" --text="Thank you for testing the RRAbuntu demo CD. If you would like to install RRAbuntu on your system. Click on the Install RRAbuntu icon on the Desktop.  www.rivendellaudio.org . 
Many Thanks from Geoff Barkman, Frederick Henderson and Alban Peignier"

# Cleanup, if devilspie was running before we started this script then leave it running otherwise kill it.
if [ ! $LEAVEDEVILSPIERUNNING = 1 ]; then
	killall devilspie
fi

# END
