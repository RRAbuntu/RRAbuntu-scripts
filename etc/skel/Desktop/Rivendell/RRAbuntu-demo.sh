#!/bin/bash
#set -x ## For testing purposes
#
# Run_me_to_setup_Rivendell.sh
# File renamed to RRAbuntu-demo.sh by Geoff
#
# Setup test tone, promos, sample logs for demoing Rivendell with RRAbuntu.
#
#   (C) Copyright 2002-2003 Frederick Henderson <frederick@henderson-meier.org>
#
#      Run_me_to_setup_Rivendell.sh,v 1.25 2010/03/06 17:33:12 frederickh 
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

## Add user ubuntu to the rivendell and audio groups
sudo adduser ubuntu rivendell
sudo adduser ubuntu audio

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

## Generate Test tone for the rdlibrary
sudo rdgen -t 10 -l 16 /var/snd/999999_000.wav

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

## Load the test tone in the button at row 1, column 1 of the current pannel.
rmlsend PE\ C\ 1\ 1\ 999999\!
sleep 1

#Play the button at row 1, column 1 of the current panel.
rmlsend PP\ C\ 1\ 1\!
sleep 5

zenity --info --text="If you heard the test tone twice then this script has properly configured Rivendell. Now on with the show!"

sleep 1
#killall rdairplay

## FIX ME
## Fix permissions to /var/snd currently the user is rduser not ubuntu
## Is this something we need to fix or is it something Alban needs to fix
## or does this go back to Fred G.?
sudo chown ubuntu:rivendell /var/snd

## Change to directory with promos and add them to the library

#old line
#cd ~/Desktop/Promos

cd ~/Desktop/Rivendell/Promos
rdimport --to-cart=999998 --metadata-pattern=%a-%t. TRAFFIC  ./*.flac

## Include variables from rd.conf to use
#./etc/rd.conf

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
#
mysql -u $USER -p$PASSWORD -e"USE Rivendell;
      INSERT INTO CART(TYPE,NUMBER,GROUP_NAME,TITLE,CUT_QUANTITY,FORCED_LENGTH,ASYNCRONOUS,MACROS)
      VALUES (2,050001,\"MACROS\",\"Welcome\",0,6000,\"Y\",\"\LC\ blue\ Welcome\ to\ Rivendell\ Radio\ Automation\!SP\ 3000\!LC\ red\ Open\ Source\ Broadcast\ Automation\!SP\ 3000\!LC\ green\ RRAbuntu\ Live\ CD\ Project\!SP\ 3000\!LC\ darkcyan\ The\ Easiest\ Rivendell\ Demo and Install\!SP\ 3000\!\")"

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

## Start up RDAirplay again for the user
#rdairplay &

#sleep 2
rmlsend PN\ 1\!

sleep 100

zenity --info --text="Thank you for testing the RRAbuntu demo cd. If you would like to install RRAbuntu on your system. Click on RRAbuntu-install.sh in the Rivendell folder on the desktop. www.rivendellaudio.org . 
Many Thanks from Geoff Barkman, Frederick Henderson and Alban Peignier"

