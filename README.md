ShareOnLan
==========

* Share file on the lan with a graphical interface.
* Designed to be intergrated with thunar or other file managers.
* Can be used from the command line
* Provides a simple way to intergrate sharing files with woof into file managers

## Command Line Usage

To share a file from the command line you just give the file path

	shareonlan path/to/file.txt

To share a directory you would use

	shareonlan path/to/directory

## Open With

ShareOnLan includes a "ShareOnLan.desktop" launcher to allow you to use your file managers "open with" functionality to intergrate with ShareOnLan in order to share files this way.

## How to intergrate into Thunar

1. Open thunar
2. Click "edit" at the top and go to the "configure custom actions" option
3. Add a new custom action with plus sign button on right side of the "Custom Actions" dialogue.
4. In the "Name:" text box type "Share on LAN"
5. In the "Command:" text box type "shareonlan %f"
6. Change the tab at the top of the "Create Action" dialog to "Apearance Conditions"
7. Check all of the boxes and set the "File Pattern:" to "*" if it is not already set to that
8. Click "OK" on the "Create Action" dialog
9. Click "Close" on the "Custom Actions" dialog
