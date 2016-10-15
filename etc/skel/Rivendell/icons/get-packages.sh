#!/bin/bash

##################################################################################################
#Supplimentary script added by Geoff because Rivendell packages are faulty when added to cd image.
#But are ok when downloaded manually
##################################################################################################


#Add Tryphon sources to the sources.list
sudo -s

echo "deb http://debian.tryphon.org lucid main" >>  /etc/apt/sources.list

echo "deb-src http://debian.tryphon.org lucid main" >> /etc/apt/sources.list

sleep 2

#Update source packages
apt-get update


#Remove sudo priviledges from user, so can't be used by mistake
sudo -K


