ShareOnLAN
==========

- Share file on the LAN with a graphical interface
- Generates a QR code of the link in graphical and console environments
- Designed to be integrated with Thunar or other file managers
- Uses [YAD](https://sourceforge.net/projects/yad-dialog/) to provide a graphical interface to [Woof](http://www.home.unix-ag.org/simon/woof.html)

## Firewall Rules

For Share On LAN to work you must open TCP port 9119 on your computer.

If you are using UFW you can use the below to let traffic though.

	ufw allow proto tcp from any to any port 9119

## Command Line Usage

To share a file from the command line you just give the file path

	shareonlan path/to/file.txt

To share a directory you would use

	shareonlan path/to/directory

## Open With

ShareOnLAN includes a "ShareOnLAN.desktop" launcher to allow you to use your file managers "open with" functionality to integrate with ShareOnLAN in order to share files this way.

## How to integrate into Thunar

1. Open Thunar
2. Click "edit" at the top and go to the "configure custom actions" option
3. Add a new custom action with plus sign button on right side of the "Custom Actions" dialogue.
4. In the "Name:" text box type "Share on LAN"
5. In the "Command:" text box type "shareonlan %f"
6. Change the tab at the top of the "Create Action" dialog to "Appearance Conditions"
7. Check all of the boxes and set the "File Pattern:" to "*" if it is not already set to that
8. Click "OK" on the "Create Action" dialog
9. Click "Close" on the "Custom Actions" dialog
