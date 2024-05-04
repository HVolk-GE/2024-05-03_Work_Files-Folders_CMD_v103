#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Blue3.ico
#AutoIt3Wrapper_Outfile=Work_Files-Folders_i386_v001.exe
#AutoIt3Wrapper_Outfile_x64=Work_Files-Folders_64Bit_v001.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_Res_Comment=Works with files and folders, in the background. Copy, Move and Delete Files/Folders
#AutoIt3Wrapper_Res_Fileversion=1.0.1.22
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=work files and folders
#AutoIt3Wrapper_Res_ProductVersion=1.0.3
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs
App short description:
Very simple app, this app checks folders (and possible files) for secifical days old.
When the app find folder (or and files) are older as x Days then is possible to work with this for
copy, move or delete. Setup is edit the config.ini file and read the comments in there.

IMPORTANT:
Files are copiered with the source folder name - like= Targed Path\Source Path\Source File!
The days-function is at the moment not actived!

#########################################################################################################

Version:
1.0.0 - HV - 30.04.2024 - Simple App for reading the dates of Folders and files.
1.0.1 - HV - 30.04.2024 - Simple App for work with the date older than of Folders and files.
1.0.2 - HV - 02.05.2024 - First tests with Alpha Version.
1.0.3 - HV - 03.05.2024 - Small fixes, add user information when App started.
#########################################################################################################
#ce

; Implemented libarys
; No TrayIcon possibility:
; #NoTrayIcon
#include <Array.au3>
#include <File.au3>
#include <Date.au3>
#include <MsgBoxConstants.au3>

; TrayIcon Hidden possibility:
; Opt("TrayIconHide", 1)

FoldersFiles()

Func FoldersFiles()

	Local $PathArray[90]
	Local $TarPathArray[90]
	Local $FilehArray[90]

	; Define ini File for external configuration
	$inifilename = "config.ini"

	$ComputerName = @ComputerName

	; create a information variable
	$aInformation = ""
	$aFolderVar = ""

	; Reading ini Files Sections
	; Information Settings
	$meldnotexits = IniRead($inifilename, "Messages", "MsgNoExistsFiles", "0")

	; Send a Messages when appl. start and folders, with defined proberties are exists !
	; 1 like Send a Messages if Appl. on End and 0 like no Messages send out !
	$StartMessages = IniRead($inifilename, "Messages", "Startmessages", "0")


	; Send a Messages when appl. end !
	; 1 like Send a Messages if Appl. on End and 0 like no Messages send out !
	$EndMessages = IniRead($inifilename, "Messages", "Endmessages", "0")

	; Days after it should be work with the Folders
	$HoldDays = IniRead($inifilename, "Config", "Days", "NOTFOUND")

	; Foldername not effected
	$aCutoutFolderName = IniRead($inifilename, "Config", "CutoutFolderName", "")

	; Folder mode: m = MODIFIED, c = CREAETD, a = ACCESSED
	$FolderMode = StringUpper(IniRead($inifilename, "Config", "FolderSetting", "NOTFOUND"))

	; Target Directory - who should be copy or move to.
	$Target = IniRead($inifilename, "TARGETPATH", "PATH", "NOTFOUND")
	;# DirCreate($Target)

	; Initalisation counter variable $i to 1
	$i = 1
	; Source Directory - who can find the Files or Folders stored.

	; Use Computername in the Path
	$TPCName = Number(IniRead($inifilename, "SOURCEPATH", "UsePCName", 0))

	; use counted character from the lefthandside:
	$TCutPCNameLeft = Number(IniRead($inifilename, "SOURCEPATH", "CutOffLeft", 0))

	; use counted character from the righthandside:
	$TCutPCNameRight = Number(IniRead($inifilename, "SOURCEPATH", "CutOffRight", 0))

	$var = IniRead($inifilename, "SOURCEPATH", "PATH" & $i, "NOTFOUND")
	$FaultSourcePath = $var

	;$TPCName = StringIsInt($TPCName)
	;MsgBox($MB_SYSTEMMODAL, "Inhalt wenn Computername on/off", "Computername soll benutzt werden !" & $TPCName)

	; Reading the ini - Sections for find the subSections
	While $var <> "NOTFOUND"
		$var = IniRead($inifilename, "SOURCEPATH", "PATH" & $i, "NOTFOUND")
			If $TPCName = 1 Then
				;MsgBox($MB_SYSTEMMODAL, "Inhalt wenn Folders gefunden werden", "Computername soll benutzt werden !")
				if $TCutPCNameLeft = 1 Then
					$TPCName = StringLeft($TPCName, $TCutPCNameLeft)
					$var = $var & "\" & $TPCName & "\"
				Elseif $TCutPCNameLeft = 1 Then
					$TPCName = StringRight($TPCName, $TCutPCNameRight)
					$var = $var & "\" & $TPCName & "\"
				EndIf
			EndIf
		; When is defined fill the Array variable:
		If $var <> "NOTFOUND" Then
			$PathArray[$i] = $var
			$len = StringLen($var)
			$var = StringRight($var, $len - 3)

			$TarPathArray[$i] = $var
		EndIf
		$i = $i + 1
	Wend

	; $b counter for Directorys
		$b = $i - 1

	; reset $i is now counter for End used by $i < $b
		$i = 1

	; set $a to counter for Files inside Directory
		$a = 1

	; set $e actived Files/Folder found
		$e = 0

	; X like copy all complete Directory with all subdirectorys
	; otherways copy only files define in ini file !
		$d = 0

	;##########################################################################################################################################
	; Read the first entry in the File Selction for Information - Filename, x = all Files and Folders (incl. subfolders), c - copy, m - move or d - delete Folders
	$var = IniRead($inifilename, $PathArray[$i], "FILE" & $i, "NOTFOUND")

	For $i = 1 to $b Step 1
		; Reread the first entry in the File Selction for Information - Filename, x = all Files and Folders (incl. subfolders), c - copy, m - move or d - delete Folders
		$var = IniRead($inifilename, $PathArray[$i], "FILE" & $a, "NOTFOUND")

		; Set $var to Uppercase String
		$var = StringUpper($var)

		While $var <> "NOTFOUND"
			; Ssavety reread the entry in the File Selction for Information - File-/Foldername, x = all Files and Folders with path, c - copy, m - move
			; or d - delete Folders  (incl. subfolders)
			; When change beween Loops
			$var = IniRead($inifilename, $PathArray[$i], "FILE" & $a, "NOTFOUND")

			; When is somthing else as character inside the $var Variabele - "like Filenames" then
			If $var <> "NOTFOUND" and ($var <> "X" or $var <> "Y" or $var <> "P" or $var <> "O") Then
				; use pointer variable
				$e = 0
				$FilehArray[$a] = $var
				If FileExists($PathArray[$i] & $FilehArray[$a]) Then
					$aInformation = "Copied"
					FileCopy($PathArray[$i] & $FilehArray[$a], $Target & $TarPathArray[$i] & $FilehArray[$a])
				Else
					If $meldnotexits = "1" Then
						MsgBox(8192, $PathArray[$i] & $FilehArray[$a], "Does NOT exists")
					EndIf
				Endif
			; When is only x character inside the $var variable then
			ElseIf  $var = "X" Then
				$aInformation = "Copied"
				DirCopy($PathArray[$i], $Target & $TarPathArray[$i], 1)
			Endif

			; If c, m or d inside the $var Variable then is work with Folders only
			If  $var <> "NOTFOUND" and ($var = "C" or $var = "M" or $var = "D") Then
				; use pointer variable
				$e = 1
				; Fill Foldernames into a array - Longname incl. Drive and complete path
				Local $aFileList = _FileListToArray($PathArray[$i], Default, 2, True)

				; Fill Foldernames into a array - Shortname Foldername only
				Local $aFolderList = _FileListToArray($PathArray[$i], Default, 2, False)

				; Calculate date, time from Now
				$FolderToDayDateLong = _NowCalc()

				For $c = 1 To UBound($aFileList) - 1

				$aFolderVar = $aFileList[$c]

				; Cut-Off Foldername, when Foldername contains $aCutoutFolderName in the Foldername (lengh/chacraters), then Folder is not affected
				$aCutoutFolderName = StringUpper($aCutoutFolderName)

				; for cut-off Folders like "Calibration Folder" etc. when is part of string inside the foldername set $iPosition > 0
				$iPosition = StringInStr($aFolderList[$c], $aCutoutFolderName)

					; When part of the String, is'n inside the hole foldername, then work. Otherwise go next foldername
					If $iPosition = 0 Then
						; Read date from Long Foldernames of Modified
						If $FolderMode = "M" Then
							$FolderActualDateComplete = FileGetTime($aFileList[$c], $FT_MODIFIED, 1)
						ElseIf $FolderMode = "C" Then
							$FolderActualDateComplete = FileGetTime($aFileList[$c], $FT_CREATED, 1)
						ElseIf $FolderMode = "A" Then
							$FolderActualDateComplete = FileGetTime($aFileList[$c], $FT_ACCESSED, 1)
						EndIf

						; Cut Date and Time for new setup the datetime format at the end
						$FolderActualDate = StringLeft($FolderActualDateComplete, 8)
						$FolderActualYear = StringMid($FolderActualDateComplete, 1,4)
						$FolderActualMonth = StringMid($FolderActualDateComplete,5,2)
						$FolderActualDay = StringMid($FolderActualDateComplete,7,2)
						$FolderActualHour = StringMid($FolderActualDateComplete,9,2)
						$FolderActualMinute = StringMid($FolderActualDateComplete,11,2)
						$FolderActualSecond = StringMid($FolderActualDateComplete,13,2)
						$FolderActualDateCompleteNew = $FolderActualYear & "/" &$FolderActualMonth & "/" & $FolderActualDay& " " & $FolderActualHour&":"&$FolderActualMinute&":"&$FolderActualSecond

						; Date different in Days from the Folders Date Time to Today
						$iDateCalc = _DateDiff('D', $FolderActualDateCompleteNew, $FolderToDayDateLong)

						; Use help variable for Message
						$FalutVar = $var

						; When the different bigger than $HoldDays (eg. > 30 days) then
						If $iDateCalc > $HoldDays Then
							If $StartMessages = "1" and $d = 0 Then
								MsgBox($MB_SYSTEMMODAL, "Es wurden Verzeichnisse gefunden !", "Diese Verzeichnisse " & @CRLF & " sind älter als : " & $HoldDays & " und werden nun gelöscht !" & @CRLF & "Bitte erst die Prüfstandsoftware starten, wenn die Meldung kommt, das dieser Vorgang beendet ist !")
								$d = 1
							Endif
							IF $var = "C" Then
								; Copy the Folders
								; Use help variable for Message
								$aInformation = "Copied"
								DirCopy($aFileList[$c], $Target & $aFolderList[$c], 1)
							ElseIf $var = "M" Then
								; Move the Folders
								; Use help variable for Message
								$aInformation = "Moved"
								DirMove($aFileList[$c], $Target & $aFolderList[$c], 1)
							ElseIf $var = "D" Then
								; Delete the Folders
								; Use help variable for Message
								$aInformation = "Deleted"
								DirRemove($aFileList[$c],1)
							EndIf
							; Empty the Recycle-Bin after the Folder are Remove or Delete
							Local $iRecycle = FileRecycleEmpty(@HomeDrive)
						EndIf
					EndIf
				Next
			EndIf
			$a = $a + 1
		Wend
		$a = 1
	Next

	; Send the End Messages, when is actived
	If $e > 0 Then
		If $EndMessages = "1" and ($FalutVar = "C" or $FalutVar = "M" or $FalutVar = "D") Then
			MsgBox($MB_SYSTEMMODAL, "Information", "Folders are older than " & $HoldDays & " Days, from " & @CRLF & $FaultSourcePath & " " & $aInformation & @CRLF & " to " & @CRLF &  $Target & " !")
		ElseIf $EndMessages = "1" and $FalutVar = "X" Then
			MsgBox($MB_SYSTEMMODAL, "Information", "Files are copied, from " & @CRLF & $FaultSourcePath & " "& $aInformation & @CRLF & " to " & @CRLF  & $Target & " !")
		EndIf
	ElseIf $EndMessages = "1" and $e = 3 Then
		; Deactived, for not make confusion to the users $e=3 -> never set automatic!
		MsgBox($MB_SYSTEMMODAL, "Information", "No Folder found, with these search-parameters !")
	EndIf

	; Error Messages
    If @error = 1 Then
		MsgBox($MB_SYSTEMMODAL, "", "Path was invalid.")
        Exit
	EndIf
    If @error = 4 Then
		MsgBox($MB_SYSTEMMODAL, "", "No file(s) were found.")
        Exit
	EndIf

EndFunc   ;==>End Function
