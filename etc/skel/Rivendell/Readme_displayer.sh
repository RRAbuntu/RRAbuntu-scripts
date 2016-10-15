#!/bin/bash
#set -x ## For testing purposes
#
#Readme_displayer.sh 
#
# Setup test tone, promos, sample logs for demoing Rivendell with RRAbuntu.
#
#   (C) Copyright 2002-2003 Frederick Henderson <frederick@henderson-meier.org>
#
#      Readme_displayer.sh,v 1.12 2010.04.24  FJH
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
version 1.12

Initial Release-FJH

#########################################################
CHANGELOG

currentuser=$(whoami)
zenity --text-info --title="Welcome to RRAbuntu" --width=800 --height=900 --filename="/etc/skel/Rivendell/README.txt"
