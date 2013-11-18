; Initialization
#SingleInstance force
if 0 <> 0
{
	ExitApp
}
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
Process, Priority, , High ; Setting a high priority
SetBatchLines, -1
Suspend On ; Disable the script at startup

; --- VARIABLES ---
work := 0 ; Working state

return ; Completion of the initialization

; --- BUTTONS ---

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

; Close programm
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