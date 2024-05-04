# 2024-05-03_Work_Files-Folders_CMD_v103
 CMD Shell Script for work (copy,move and delete) with files and folders by dates.

This script will work with (focus on) folder and secondary files.
Configuration with flexibe ini-config File, inside these file you can configurate following:
Souces and Target Paths
Source Path: The Path who saved the "Subfolders" eg. C:\test\xyz\, when you here define C:\test\, the app will copy, move or delete all folders inside.
Target Path: These Path presents the target path eg. C:\temp\, who you can find the folders/files after copy and move.
IMPORTANT: These entrys for PATH most be end with "\" !

The Source Path, make this as "Keys" (PATHx) and as "Sectionname", because:
The ini - Key used as targetpoint inside the ini File as Section, inside the Section you can define:
1.) What you need, as "Keys" (FILEx) Value "C" - copy, "M" - move, "D" - delete and "X" copy all files from there.
2.) Or you can insert different filenames to "Keys" (FILEx), than the script will copy (only copy) files from there.

It possible, to search Folders by Date > 1 Day old and define the date by (m) modified, (c) created or (a) accessed.
Configure should by send messages, at start, at end (and/or).
Also you can use a cut-out of Folder the include a defined string.

Updates plan:
When PC-Name is included inside the Source-Folder, these can cut-out from the PC-Name="MyPC" - Source-Foldername eg. "MYPC"Number(String)/Number(String)"MyPC".


#######################################################################################################################################################
# This is my first AutoIT respositorie, for my histrory with these script language: I work with AutoIT since more as 10 Years,
# but most of the time for business, therefore the most scripts could not make to public respositorie and/or these scripts are to special.
#
# I will work on make the idears behind these scripts to make public version, in the future.
#######################################################################################################################################################
