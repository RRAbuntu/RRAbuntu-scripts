#!/bin/bash

#set -x ## For testing purposes
#
# RRAbuntu-install.sh
#
# To assist in installing RRAbuntu.
#
#   Geoff Barkman 2010
#   (based on scripts created by Frederick Henderson)
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

zenity --info --text="To Install Ubuntu with Rivendell click on Install Icon ... on the Desktop. This takes about 30 minutes"
sleep 5

zenity --info --text="1 of 7  Welcome Select Language - click forward"
sleep 5

zenity --info --text="2 of 7 Where are you - click location on map - click forward"
sleep 5

zenity --info --text="3 of 7 Keyboard Layout - choose your keyboard layout, or keep suggested US - click forward"
sleep 5

zenity --warning --text="4 of 7 Prepare disk space - click use entire disk (WARNING: will delete entire existing Hard  drive contents) - or choose partitions manually (advanced) Beginners DON'T choose this. - click forward"
sleep 5

zenity --info --text="Note there are other options at this step, but I recommend, just erasing whole disk, rather than keeping windows ie dual boot (for simpicity)"
sleep 5

zenity --info --text="5 of 7 Type your name - type your username (note it will be lowercase) - password x2 - name of computer (your station name with no gaps) - optional log in auto (otherwise leave requiring password) - forward"
sleep 5

zenity --info --text="6 of 7 No such page on installer (ops)"
sleep 5

zenity --info --text="7 of 7 Click install"
sleep 10

zenity --info --text="While installing you can surf the net if you wish, just click firefox icon. This will take
30 mins approx.... (depends on hardware specs)"
sleep 10

zenity --info --text="Once installation complete, you will be prompted to Restart Now.... Remove CD....Stand clear of the CD drawer.... and hit Enter once it pops out"


