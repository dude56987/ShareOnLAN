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
# Kill woof if it is running since it will block woof from running again
pkill "woof" || echo 'Webserver is cleared to launch...';
#"#NOTES: %f is in single quotes, you cant store bash variables this way;
fileName=$(echo $@ | sed 's/ /\\ /g');
# Launch the webserver in its own process
echo 'Starting webserver...'
if [ -d $fileName ];then
	echo 'Sharing directory...'
	woof -p 9119 -z $fileName &
else
	echo 'Sharing file...'
	woof -p 9119 $fileName &
fi
# store the woof process id
serverId=$!;
#launch the gui in its own process;
hostname=$(hostname);
zenity --progress --pulsate --no-cancel --text="Sharing $fileName\nConnect to http://$hostname.local:9119 to download\nServer will close automatically after one download" --ok-label="Stop Share" --title="Sharing $fileName over LAN" &
#store the gui process id;
guiId=$!;
# wait for the woof process to die then kill the gui;
while ps -e | grep $serverId;do
	# if the user kills the gui kill the webserver;
	if ! ps -e | grep $guiId;then
		kill $serverId;
		# force kill the program if regular kill signals do not work
		kill -9 $serverId;
	fi;
	# sleep 3 seconds between checks on subprocesses
	sleep 3;
done;
# kill the GUI component when the server quits;
kill $guiId;
kill -9 $guiId;
# kill the server if it was somehow not killed prevously
kill $serverId;
kill -9 $serverId;
