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

title := "BF3 Multiscript"
work := 0 ; Working state
autoSpotting := 0 ; State of the function "Autospotting"

; Initialization of interface
Gui, Add, ListBox, x12 y20 w100 h80 , General|Options|Settings|About

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

; Function GUI update
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
