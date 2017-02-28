#! /bin/bash
########################################################################
# Share files or directories on the lan with a grahical interface
# Copyright (C) 2017  Carl J Smith
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
########################################################################
cleanup(){ # cleanup the generated temp files
	# grab input arguments
	tempPath="$1"
	serverId="$2"
	guiId="$3"
	# kill the GUI component when the server quits;
	kill $guiId >> $tempPath.log || echo "GUI was already shutdown..."
	kill -9 $guiId >> $tempPath.log || echo "GUI was verified shutdown..."
	# kill the server if it was somehow not killed prevously
	kill $serverId >> $tempPath.log || echo "Server was already shutdown..."
	kill -9 $serverId >> $tempPath.log || echo "Server was verified shutdown..."
	# remove the qr code files generated
	rm -v $tempPath.png >> $tempPath.log || echo "PNG Qr Code was already cleaned up..."
	rm -v $tempPath.txt >> $tempPath.log || echo "TEXT Qr Code was already cleaned up..."
	rm -v $tempPath.log || echo "LOG was already cleaned up..."
}
########################################################################
# Kill woof if it is running since it will block woof from running again
pkill "woof" || echo 'Webserver is cleared to launch...';
#"#NOTES: %f is in single quotes, you cant store bash variables this way;
fileName=$(echo $@);
echo "Preparing to share $fileName..."
#launch the gui in its own process;
hostnames=$(hostname -I);
# grab the first given hostname
for ip in $hostnames;do
	hostname="$ip"
	break
done
link="http://$hostname:9119";
# generate a temporary qr code for the window
tempPath="/tmp/ShareOnLan_$RANDOM"
echo "Generating Qr Code Image at $tempPath..."
# Available qr code formats below
# PNG,EPS,SVG,ANSI,ANSI256,ASCII,ASCIIi,UTF8,ANSIUTF8
qrencode -o "$tempPath.png" -s 10 -t png "$link"
# generate qr code to display in the terminal
echo "Generating Qr Code text at $tempPath..."
qrencode -o "$tempPath.txt" -t ANSI "$link"
# store the title of the dialog
title="Sharing $fileName over LAN"
# store the message
message="Sharing $fileName\nOrdered from most to least reliable below are links to download the shared file"
message="$message\nhttp://$(hostname):9119"
message="$message\nhttp://$(hostname).local:9119"
for ip in $hostnames;do
	# print out all the possible ip addresses available
	message="$message\nhttp://$ip:9119"
done
message="$message\nServer will close automatically after one download"
# display the GUI using the created qr code, or the curses qr code generated
echo "Launching graphical interface..."
#zenity --info --window-icon="$tempPath.png" --icon-name="$tempPath.png" --text="$message" --ok-label="Stop Share" --title="Sharing $fileName over LAN" &
#nohup yad --picture --text-align="center" --center --title="$title" --window-icon="$tempPath.png" --filename="$tempPath.png" --text="$message" --dialog-sep --size="fit" >> $tempPath.log &
nohup yad --picture --text-align="center" --center --hscroll-policy=never --yscroll-policy=never --title="$title" --window-icon="$tempPath.png" --filename="$tempPath.png" --text="$message" --dialog-sep --size=fit >> $tempPath.log &
#store the gui process id
guiId=$!
# create a trap to catch ctrl-c and cleanup correctly
trap "cleanup $tempPath $serverId $guiId"  SIGINT SIGTERM
# Launch the webserver in its own process
echo 'Starting webserver...'
if [ -d "$fileName" ];then
	echo 'Sharing directory...'
	nohup woof -p 9119 -z "$fileName" >> $tempPath.log &
else
	echo 'Sharing file...'
	nohup woof -p 9119 "$fileName" >> $tempPath.log &
fi
# store the woof process id
serverId=$!;
# YAD needs time to fail if the user is running on a console. When done here
# the user should not notice the sleep command since all interface elements
# have already been printed to the screen.
sleep 0.5
# if the gui launched successfully, check to make sure it keeps running
if [ -d "/proc/$guiId" ];then
	guiCheck=true
else
	guiCheck=false
fi
# show the code on the cli and the message below it, pipe message through cat for newlines
clear
echo -e "$message"
cat "$tempPath.txt"
# wait for the woof process to die then kill the gui;
echo "Waiting on webserver to finish share..."
while [ -d "/proc/$serverId" ];do
	# if the user kills the gui kill the webserver;
	if $guiCheck;then
		if ! [ -d "/proc/$guiId" ];then
			echo "Interface has been closed, shutting down the server..."
			# cleanup everything by closing the server and removing all the temp files
			cleanup $tempPath $serverId $guiId
		fi
	fi
	# sleep 3 seconds between checks on subprocesses
	sleep 3;
done;
# cleanup everything by closing the server and removing all the temp files
cleanup $tempPath $serverId $guiId
