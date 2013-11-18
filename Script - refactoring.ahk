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

work := 0 ; Working state
autoSpotting := 0 ; State of the function "Autospotting"

; Initialization of interface
Gui, Add, Tab, x2 y0 w490 h320 , Горячие клавиши

Gui, Tab, Горячие клавиши
Gui, Add, Edit, x12 y30 w440 h280 vHotkeys ReadOnly, F1 - Activating / Deactivating`nF2 - Activating / Deactivating of Autospotting`nF11 - Exit

; Show of interface
Gui, Show, h322 w494, %title%

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

AutoSpotting:
	Send {Blind}{SC010 down} ; Send "Q" key and hold it on pressed state
	Sleep, 105
	Send {Blind}{SC010 up}
	; Blinking of ScrollLock
	SetScrollLockState, On
	Sleep 90
	SetScrollLockState, Off
return
