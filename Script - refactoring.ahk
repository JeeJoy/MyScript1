/*
	Autor: Gorelov Pavel (JeeJoy)
	Contact E-mail: jeejoy93@mail.ru
	
	The script was developed for educational purposes.
	Author of the script is not responsible for the moral or material damage by third parties.
	Use at your own risk!
*/

; --- INITIALIZATION ---

#SingleInstance force ; When you start a new instance of the script, the old will be turned off.
if (0 <> 0)
	ExitApp
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
Process, Priority, , High ; Setting a high priority
SetBatchLines, -1
Suspend On ; Disable the script at startup

; --- VARIABLES ---

autoSpotting := 0 ; State of the function "Autospotting"
bf3SettingsFile = %A_MyDocuments%\Battlefield 3\settings\PROF_SAVE_profile
sensitivity := 0.5 ; Mouse's sensitivity
title := "BF3 Multiscript" ; Script's title
work := 0 ; Working state

; Initialization of interface
Gui, Add, ListBox, x12 y20 w100 h80 , General|Options|Settings|About ; Menu

Gui, Add, GroupBox, x122 y10 w150 h90 , Hotkeys
Gui, Add, Text, x132 y30 w120 h20 vTextF1 , F1: Correction is disabled
Gui, Add, Text, x132 y50 w110 h20 vTextF2 , F2: Spotting is disabled
Gui, Add, Text, x132 y70 w100 h20 , F11: Exit

; Show of interface
Gui, Show, h115 w287, %title%

return ; Completion of the initialization

; --- BUTTONS ---

*LButton:: ; Left mouse button + any key
	Click down
	KeyWait, LButton, U
	Click up
return

; Activating of script
*F1:: ; F1 + any key
	Suspend ; Hotkey is always in enabled state
	if (!work) ; If not work, then enable it
	{
		if (SensCheck())
		{
			work := 1 ; Activating
			Suspend Off ; Enable hotkeys
			Loop, 2 ; Blinking of ScrollLock (twice)
			{
				SetScrollLockState, On
				Sleep 90
				SetScrollLockState, Off
				Sleep 90
			}
		}
	}
	else ; Or disable it
	{
		work := 0 ; Deactivating
		Suspend On ; Disable hotkeys
		; Blinking of ScrollLock (once)
		SetScrollLockState, On
		Sleep 180
		SetScrollLockState, Off
	}
	
	GUIUpdate()
return

; Activating of Autospotting
*F2:: ; F2 + any key
	Suspend ; Hotkey is always in enabled state
	if (!autoSpotting) ; If not work, then enable it
	{
		autoSpotting := 1 ; Activating
		SetTimer, AutoSpotting, 2200 ; Call of spotting once in 2.2 seconds
		Loop, 2 ; Blinking of ScrollLock (twice)
		{
			SetScrollLockState, On
			Sleep 90
			SetScrollLockState, Off
			Sleep 90
		}
	}
	else
	{
		autoSpotting := 0 ; Deactivating
		SetTimer, AutoSpotting, Off
		; Blinking of ScrollLock (once)
		SetScrollLockState, On
		Sleep 180
		SetScrollLockState, Off
		Sleep 90
	}
	
	GUIUpdate()
return

; Close programm
GuiClose: ; Label which is activated after clicking on the close button in GUI
; Note: After clicking on the close button (in GUI) to show a warning about closing script!!!
*F11:: ; F11 + any key
	Suspend ; Hotkey is always in enabled state
	Suspend On ; Disable the script
	Loop, 3 ; Blinking of ScrollLock (3 times)
	{
		SetScrollLockState, On
		Sleep 90
		SetScrollLockState, Off
		Sleep 90
	}
	ExitApp ; Close programm
return

; --- LABELS ---

; Label of spotting
AutoSpotting:
	Send {Blind}{SC010 down} ; Send "Q" key and hold it on pressed state
	Sleep, 105
	Send {Blind}{SC010 up}
	; Blinking of ScrollLock
	SetScrollLockState, On
	Sleep 90
	SetScrollLockState, Off
return

; --- FUNCTIONS ---

; Check of settings BF3
CheckBF3Settings()
{
	global bf3SettingsFile
	
	IfNotExist, %bf3SettingsFile%
		return 1
}

; Update of GUI
GUIUpdate()
{
	; Global variables
	global work
	global autoSpotting
	
	if (work)
		GuiControl, , TextF1, F1: Correction is enabled
	else
		GuiControl, , TextF1, F1: Correction is disabled
	
	if (autoSpotting)
		GuiControl, , TextF2, F2: Spotting is enabled
	else
		GuiControl, , TextF2, F2: Spotting is disabled
}

; Check of mouse's sensitivity 
SensCheck()
{
	global bf3SettingsFile
	global sensitivity
	
	err := CheckBF3Settings()
	
	if (!err) {
		if (!SensSearch())
			return 0
		
		return 1
	}
	else if (err == 1) {
		MsgBox, File of settings BF3 not found. Check it!`n%bf3SettingsFile%
	}
}

SensSearch()
{
	global bf3SettingsFile
	global sensitivity
	
	Loop, read, %bf3SettingsFile%
	{
		str = %A_LoopReadLine%
		StringLeft, cutStr, str, 26
		if (cutStr == "GstInput.MouseSensitivity ") {
			StringMid, sensitivity, str, 27, StrLen(str)
			return 1
		}
	}
	
	MsgBox, Value of mouse's sensitivity not found. Check settings BF3!`nFile: %bf3SettingsFile%`nVariable: GstInput.MouseSensitivity
}
