#!/bin/bash
#set -x ## For testing purposes
#
# Rivendell_Compile.sh
#
# To assist in installing RRAbuntu. To be run after installing Ubuntu and rebooting.
#
#   Geoff Barkman 2010
#   (based on scripts created by Frederick Henderson)
#  Rivendell_Compile.sh,v 2.0 Beta - Geoff
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
version 2.0 - beta

This script has been re-written because we have no debian packages available for v 2.0 of rivendell -geoff 2011.06.01
Sections from RRAbuntu-First_run.sh

#######################################################
CHANGELOG



cd ~/Rivendell/Downloads/

tar -vxzf ~/Rivendell/Downloads/rivendell-2.0.2.tar.gz 

cd ~/Rivendell/Downloads/rivendell-2.0.2/

zenity --info --title="RRAbuntu Setup" --text="We are going to set up RRAbuntu. This may take 30 minutes or so"

# Run the configure file
~/Rivendell/Downloads/rivendell-2.0.2/configure --disable-hpi --libexecdir=/var/www/rd-bin

zenity --info --title="RRAbuntu Setup" --text="Our configure was successful and now we are going to Make the program. Lots of text will scroll past in the terminal. You might want to turn off the screensaver to stop the screen locking"
cd ~/Rivendell/Downloads/rivendell-2.0.2/

# Run the Makeinstall
make -C ~/Rivendell/Downloads/rivendell-2.0.2/

zenity --info --title="RRAbuntu Setup" --text="We are nearly there. The set up will ask for your password very soon"

cd ~/Rivendell/Downloads/rivendell-2.0.2/

sudo make install -C ~/Rivendell/Downloads/rivendell-2.0.2/

sudo ldconfig

sudo cp ~/Rivendell/Downloads/rivendell-2.0.2/debian/rivendell.init /etc/init.d/rivendell

# Setting up symbolic links so rivendell start and stops properly
sudo ln -s /etc/init.d/rivendell /etc/rc5.d/S99rivendell
sudo ln -s /etc/init.d/rivendell /etc/rc2.d/S99rivendell
sudo ln -s /etc/init.d/rivendell /etc/rc0.d/K99rivendell

# Copying the apache config file
sudo cp ~/Rivendell/Downloads/rivendell-2.0.2/conf/rd-bin.conf /etc/apache2/conf.d/

# Making the /var/snd directory and changing ownership and permissions
sudo mkdir /var/snd

sudo chown -R www-data:www-data /var/snd
sudo chmod -R 777 /var/snd

# Adding www-data user to the audio group
sudo addgroup www-data audio

# making var run directory for rivendell
mkdir /var/run/rivendell

# Stopping and then starting rivendell if its already running
sudo /etc/init.d/rivendell stop
sudo /etc/init.d/rivendell start



# Find out who am I and use name in the next few lines
export currentuser=$(whoami)

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
zenity --info --title="RRAbuntu Rivendell Setup - MySQL" --text="A window titled mysql Admin will pop-up behind this one. The username is... root and the password is....  rivendell.  Close this window only after entering the username and password, Click OK and after the Created Database window with the message New Rivendell Database Created! pops up."

zenity --info --title="RRAbuntu Rivendell Setup - RDAdmin" --text="Now rdadmin will start up. The username is .... admin
with no password"

sleep 5

# Change permissions ownership of /var/snd again
sudo chown -R www-data:www-data /var/snd
sudo chmod -R 777 /var/snd

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


#Make Rivendell icons folder and copy icons to it
sudo mkdir /usr/share/rivendell/

sudo cp /home/$currentuser/Rivendell/icons/*.xpm /usr/share/rivendell/



# Copy Icons to the desktop
cp /home/$currentuser/Rivendell/icons/rdairplay.desktop /home/$currentuser/Desktop/rdairplay.desktop
cp /home/$currentuser/Rivendell/icons/rdlibrary.desktop /home/$currentuser/Desktop/rdlibrary.desktop
cp /home/$currentuser/Rivendell/icons/rdlogedit.desktop /home/$currentuser/Desktop/rdlogedit.desktop
cp /home/$currentuser/Rivendell/icons/rdlogmanager.desktop /home/$currentuser/Desktop/rdlogmanager.desktop

fi

# Clean up, if devilspie was running before we started this script then leave it running otherwise kill it.
if [ ! $LEAVEDEVILSPIERUNNING = 1 ]; then
	killall devilspie
fi

# Clean up, Get rid of desktop file that displays the prompt to run this script. FJH
rm ~/.config/autostart/RRAbuntu_autostart.sh.desktop

# leave the sudo environment
sudo -k

zenity --info --title="RRAbuntu - Adding music to the Rd Library" --text="If you wish to add music to the rdlibrary, I recommend restarting your computer.  Once restarted you can manually delete the Rivendell_Compile.sh icon from your desktop, if you wish.
Many Thanks Geoff and Frederick"

# END

