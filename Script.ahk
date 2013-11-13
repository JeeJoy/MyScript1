/*
1) Нужно отремонтировать кнопку ОК при редактировании параметров оружия

----------

Функции:
- ChangeCorrection(tmp1, tmp2, tmp3) 	; Изменяет параметры оружия в конфиге
- ChangeModifications() 				; Изменяет параметры модификаций оружия в конфиге
- Correction() 							; Корректирует прицел
- GUILoadProfiles() 					; Перерисовывает в интерфейсе имена оружия
- GUIResetChoice() 						; Сбрасывает в ListBox'е выбраные пункты на дефолтные
- GUIUpdate() 							; Общая функция обновления интерфейса.
- GUIUpdateInfo() 						; Перерисовывает в интерфейсе параметры корректировки
- GUIUpdateProfile() 					; Перерисовывает в интерфейсе значение выбранного профиля
- IsIniExists() 						; Проверяет существование конфига. Если файл не найден или параметр Exists в файле равен нулю, то файл перезаписывается с дефолтными параметрами
- LoadCorrection(i) 					; Считывает из конфига параметры корректировок по активному оружию
- mouseXY(x, y) 						; Передвигает прицел
- PreCorrection() 						; Корректирует прицел при первом выстреле
- RememberWeapon(i, iid) 				; Запоминает ID активного оружия для дальнейшей обработки
- SaveWeapon() 							; Записывает в конфиг ID оружия по каждому профилю
- SearchWeapon(i, s) 					; Ищет ID оружия по названию
- Song(s) 								; Воспроизводит звуки
- SoundCheck() 							; Проверяет настройку отвечающую за активность звуковых эффектов
*/

; Initialization
#SingleInstance force
if 0 <> 0
{
	ExitApp
}
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
Process, Priority, , High
SetBatchLines, -1
Suspend On
title = BF3 NoRecoil (v1.9) by JeeJoy
work := 0
autoSpotting := 0
profile := 1
slot := 1
sound := 1
enableFirstCorr := 1
enableLastCorr := 1
tmpAssaultPrimary := 1
tmpAssaultSecondary := 52
tmpEngineerPrimary := 1
tmpEngineerSecondary := 52
tmpSupportPrimary := 1
tmpSupportSecondary := 52
firstCorr := 0
corrY := 0
corrX := 0
corrXRemember := 0
tmpCorrY := 0
tmpCorrX := 0
delay := 0
recDelay := 0
iResetCorr := 0
factor := 1
fire := 0
fireDelay := 105
firePause = fireDelay - 45
Weapons := ["870MCS", "AS VAL", "DAO-12", "M1014", "MK3A1", "MP7", "P90", "PDW-R", "PP-19", "PP-2000", "SAIGA 12K", "UMP-45", "USAS-12", "AEK-971", "AK-74M", "AN-94", "F2000", "FAMAS", "G3A3", "KH2002", "L85A2", "M16A3", "M16A4", "M416", "A-91", "AKS-74u", "G36C", "G53", "M4", "M4A1", "QBZ-95B", "SCAR-H", "SG553", "M240B", "M249", "M27 IAR", "M60E4", "MG36", "PKP", "QBB-95", "RPK-74M", "Type 88", "SVD", "MK11", "M39 EMR", "SV98", "M98B", "M40A5", "SKS", "QBU-88", "L96", ".44", "93R", "G17C", "G18", "M1911", "M9", "MP412", "MP443"]

; Check of resources
IsIniExists()
SoundCheck()

; Initialization of interface
Gui, Add, Tab, x2 y0 w490 h320 , Основное|Модификации|Настройки|Доп. настройки|Горячие клавиши|О программе
Gui, Add, Text, x12 y30 w200 h20 vTextStatus, Статус: выкл
Gui, Add, Text, x12 y50 w200 h20 vTextActiveProfile, Выбран профиль: Assault
Gui, Add, GroupBox, x12 y70 w120 h70 , Assault
Gui, Add, GroupBox, x142 y70 w120 h70 , Engineer
Gui, Add, GroupBox, x12 y150 w120 h70 , Support
Gui, Add, GroupBox, x142 y150 w120 h70 , Recon
Gui, Add, GroupBox, x272 y70 w180 h150 , Инфо
Gui, Add, Text, x22 y90 w100 h20 vTextAssaultPrimary, ---
Gui, Add, Text, x22 y110 w100 h20 vTextAssaultSecondary, ---
Gui, Add, Text, x152 y90 w100 h20 vTextEngineerPrimary, ---
Gui, Add, Text, x152 y110 w100 h20 vTextEngineerSecondary, ---
Gui, Add, Text, x22 y170 w100 h20 vTextSupportPrimary, ---
Gui, Add, Text, x22 y190 w100 h20 vTextSupportSecondary, ---
Gui, Add, Text, x152 y170 w100 h20 vTextReconPrimary, ---
Gui, Add, Text, x152 y190 w100 h20 vTextReconSecondary, ---
Gui, Add, Text, x282 y90 w160 h20 vText1stVCorr, 1st vert. correction: ---
Gui, Add, Text, x282 y110 w160 h20 vTextVCorr, Vert. correction: ---
Gui, Add, Text, x282 y130 w160 h20 vTextDelay, Delay: ---
Gui, Add, Text, x282 y150 w160 h20 vTextRecDelay, Rec. delay: ---
Gui, Add, Button, x272 y230 w90 h30 , Assault
Gui, Add, Button, x362 y230 w90 h30 , Engineer
Gui, Add, Button, x272 y260 w90 h30 , Support
Gui, Add, Button, x362 y260 w90 h30 , Recon
Gui, Add, Button, x282 y170 w160 h30 , Изменить
Gui, Tab, 2
Gui, Add, Text, x12 y30 w130 h20 , Оружие:
Gui, Add, CheckBox, x12 y50 w130 h20 , Глушитель
Gui, Add, CheckBox, x12 y70 w130 h20 , Пламегаситель
Gui, Add, CheckBox, x12 y90 w130 h20 , Рукоятка
Gui, Add, CheckBox, x12 y110 w130 h20 , Утолщенный ствол
Gui, Add, CheckBox, x12 y130 w140 h20 , Коллиматорный прицел
Gui, Add, CheckBox, x12 y150 w160 h20 , Голограф. прицел / ПКА-С
Gui, Add, CheckBox, x12 y170 w130 h20 , ИК/НВ (ИК 1-крат.)
Gui, Add, CheckBox, x12 y190 w140 h20 , М145 / ПК-А (3`,4-крат.)
Gui, Add, CheckBox, x12 y210 w140 h20 , ACOG / ПСО-1 (4-крат.)
Gui, Add, CheckBox, x12 y230 w140 h20 , Винтов. прицел (6-крат.)
Gui, Add, CheckBox, x12 y250 w130 h20 , ПКС-07 (7-крат.)
Gui, Add, Button, x12 y280 w100 h30 gButtonSaveMods , Сохранить
Gui, Tab, 3
Gui, Add, GroupBox, x12 y30 w140 h230 , Assault
Gui, Add, GroupBox, x162 y30 w140 h230 , Engineer
Gui, Add, GroupBox, x312 y30 w140 h230 , Support
Gui, Add, Text, x22 y50 w100 h30 , Основное
Gui, Add, Text, x22 y150 w100 h30 , Альтернативное
Gui, Add, Text, x172 y50 w100 h30 , Основное
Gui, Add, Text, x172 y150 w100 h30 , Альтернативное
Gui, Add, Text, x322 y50 w100 h30 , Основное
Gui, Add, Text, x322 y150 w100 h30 , Альтернативное
Gui, Add, Button, x12 y270 w440 h30 , Сохранить
Gui, Add, ListBox, x22 y70 w120 h80 vChoice1 gMySubroutine1 Choose1, No change|870MCS|AEK-971|AK-74M|AN-94|AS VAL|DAO-12|F2000|FAMAS|G3A3|KH2002|L85A2|M1014|M16A3|M16A4|M416|MK3A1|MP7|P90|PDW-R|PP-19|PP-2000|SAIGA 12K|UMP-45|USAS-12
Gui, Add, ListBox, x22 y170 w120 h80 vChoice2 gMySubroutine2 Choose1, No change|.44|93R|G17C|G18|M1911|M9|MP412|MP443
Gui, Add, ListBox, x172 y70 w120 h80 vChoice3 gMySubroutine3 Choose1, No change|870MCS|A-91|AKS-74u|AS VAL|DAO-12|G36C|G53|M1014|M4|M4A1|MK3A1|MP7|P90|PDW-R|PP-19|PP-2000|QBZ-95B|SAIGA 12K|SCAR-H|SG553|UMP-45|USAS-12
Gui, Add, ListBox, x172 y170 w120 h80 vChoice4 gMySubroutine4 Choose1, No change|.44|93R|G17C|G18|M1911|M9|MP412|MP443
Gui, Add, ListBox, x322 y70 w120 h80 vChoice5 gMySubroutine5 Choose1, No change|870MCS|AS VAL|DAO-12|M1014|M240B|M249|M27 IAR|M60E4|MG36|MK3A1|MP7|P90|PDW-R|PKP|PP-19|PP-2000|QBB-95|RPK-74M|SAIGA 12K|Type 88|UMP-45|USAS-12
Gui, Add, ListBox, x322 y170 w120 h80 vChoice6 gMySubroutine6 Choose1, No change|.44|93R|G17C|G18|M1911|M9|MP412|MP443
Gui, Tab, 4
Gui, Add, GroupBox, x12 y30 w170 h150 , Основные
Gui, Add, GroupBox, x192 y30 w260 h150 , Боевые
tmp := 0
IniRead, tmp, bf3-settings2.ini, General, Sound, 1
Gui, Add, CheckBox, x22 y50 w90 h20 vCheckBoxSound gCheckBoxSound Checked%tmp%, Звук
Gui, Add, CheckBox, x202 y50 w170 h20 vCheckBoxFFire gCheckBoxFFire Checked, Компенсация 1-го выстрела
Gui, Add, CheckBox, x202 y70 w210 h20 vCheckBoxLFire gCheckBoxLFire Disabled, Компенсация последнего выстрела
Gui, Tab, 5
Gui, Add, Edit, x12 y30 w440 h280 vHotkeys ReadOnly, F10 - вкл/выкл`nF11 - выход`nAlt+1 - 1 режим`nAlt+2 - 2 режим`nAlt+3 - 3 режим`nAlt+4 - 4 режим
Gui, 2:Add, Text, x12 y10 w120 h20 +Center, Первый выстрел
Gui, 2:Add, Text, x142 y10 w120 h20 +Center, Следующие выстрелы
Gui, 2:Add, Text, x272 y10 w120 h20 +Center, Задержка (мс)
Gui, 2:Add, Edit, x12 y30 w120 h20 vEdit1, Edit
Gui, 2:Add, Edit, x142 y30 w120 h20 vEdit2, Edit
Gui, 2:Add, Edit, x272 y30 w120 h20 vEdit3, Edit
Gui, 2:Add, Button, x12 y60 w190 h30 disabled , Ок
Gui, 2:Add, Button, x202 y60 w190 h30 , Отмена

; Loading of settings
GUILoadProfiles()
LoadCorrection(1)

; Update of interface
GUIUpdateInfo()

; Show of interface
Gui, Show, h322 w494, %title%
return

; --- BUTTONS ---

; Left mouse button + any key
*LButton::
	if (!fire)
	{
		if (!delay)
			delay := 20
		corrY = %corrXRemember%
		;SetTimer, Correction, %delay%
		SetTimer, Correction, 105
		;SetTimer, ResetCorr, 2100
		if (iResetCorr)
			SetTimer, ResetCorr, %iResetCorr%
		Click down
		PreCorrection()
		KeyWait, LButton, U
		Click up
	}
	else
	{
		;SetTimer, Fire, 105
		SetTimer, Fire, %fireDelay%
		gosub, Fire
	}
return

; F8 + any key
*F8::
	Suspend
	if (!autoSpotting)
	{
		autoSpotting := 1
		SetTimer, AutoSpot, 2200
		Loop, 2
		{
			SetScrollLockState, On
			Sleep 90
			SetScrollLockState, Off
			Sleep 90
		}
	}
	else
	{
		autoSpotting := 0
		SetTimer, AutoSpot, Off
		SetScrollLockState, On
		Sleep 180
		SetScrollLockState, Off
		Sleep 90
	}
return

; F9 + any key
*F9::
	if (!fire)
	{
		fire := 1
		Loop, 2
		{
			SetScrollLockState, On
			Sleep 90
			SetScrollLockState, Off
			Sleep 90
		}
	}
	else
	{
		fire := 0
		SetScrollLockState, On
		Sleep 180
		SetScrollLockState, Off
	}
return

; F10 + any key
*F10::
	Suspend
	if (!work)
	{
		LoadCorrection(1)
		work := 1
		Suspend Off
		Loop, 2
		{
			SetScrollLockState, On
			Sleep 90
			SetScrollLockState, Off
			Sleep 90
		}
		GuiControl, , TextStatus, Статус: вкл
		GUIUpdate()
	}
	else
	{
		work := 0
		Suspend On
		SetScrollLockState, On
		Sleep 180
		SetScrollLockState, Off
		GuiControl, , TextStatus, Статус: выкл
	}
return

; Up arrow + Ctrl
^Up::
	if ((fireDelay <= 270) || (fireDelay > 300))
	{
		if (fireDelay <= 270)
		{
			fireDelay += 30
			firePause := fireDelay - 45
		}
		if (fireDelay > 300)
		{
			fireDelay := 300
			firePause := fireDelay - 45
		}
		SetScrollLockState, Off
		Sleep 90
		SetScrollLockState, On
		Sleep 90
	}
return

; Down arrow + Ctrl
^Down::
	if ((fireDelay >= 135) || (fireDelay < 105))
	{
		if (fireDelay >= 135)
		{
			fireDelay -= 30
			firePause := fireDelay - 45
		}
		if (fireDelay < 105)
		{
			fireDelay := 105
			firePause := fireDelay - 45
		}
		SetScrollLockState, Off
		Sleep 90
		SetScrollLockState, On
		Sleep 90
	}
return

; 1 + Alt
!SC002::
	Song("mode")
	Send, !{SC002}
ButtonAssault:
	profile := 1
	LoadCorrection(1)
	GUIUpdateProfile()
return

; 2 + Alt
!SC003::
	Song("mode")
	Send, !{SC003}
ButtonEngineer:
	profile := 2
	LoadCorrection(1)
	GUIUpdateProfile()
return

; 3 + Alt
!SC004::
	Song("mode")
	Send, !{SC004}
ButtonSupport:
	profile := 3
	LoadCorrection(1)
	GUIUpdateProfile()
return

; 1
~*SC002::
	Send, {SC002}
	slot := 1
	LoadCorrection(1)
	GUIUpdateInfo()
return
; 2
~*SC003::
	Send, {SC003}
	slot := 2
	firstCorr := 0
	corrY := 0
	corrX := 0
	delay := 20
	recDelay := 20
	GUIUpdateInfo()
return

; --- LABELS ---

AutoSpot:
	Send {Blind}{SC010 down}
	Sleep, 90
	Send {Blind}{SC010 up}
	;Send {Blind}{SC010}
	if (work)
	{
		SetScrollLockState, Off
		Sleep 90
		SetScrollLockState, On
		Sleep 90
	}
	else
	{
		SetScrollLockState, On
		Sleep 90
		SetScrollLockState, Off
		Sleep 90
	}
return

ButtonSaveMods:
	MsgBox 12345
return

ButtonСохранить:
	SaveWeapon()
return

ButtonИзменить:
	GuiControl, 2:Text, Edit1, %firstCorr%
	GuiControl, 2:Text, Edit2, %corrY%
	GuiControl, 2:Text, Edit3, %delay%
	Gui, 2:Show, h106 w408, Настройка
return

/*
2ButtonОк:
	tmp1 := 0
	tmp2 := 0
	tmp3 := 0
	GuiControlGet, tmp1, , Edit1
	GuiControlGet, tmp2, , Edit2
	GuiControlGet, tmp3, , Edit3
	MsgBox %tmp1%
	MsgBox Слот #%slot%
	ChangeCorrection(%tmp1%, %tmp2%, %tmp3%)
	Gui, 2:Hide
return
*/

2ButtonОтмена:
	Gui, 2:Hide
return

Correction:
	if (!GetKeyState("LButton", "P"))
	{
		SetTimer, Correction, Off
		SetTimer, ResetCorr, Off
	}
	else
	{
		SetTimer, Correction, %delay%
		Correction()
	}
return

Fire:
	if (!GetKeyState("LButton", "P"))
		SetTimer, Fire, Off
	else
	{
		mouseLD()
		;Sleep 60
		Sleep, %firePause%
		mouseLU()
	}
return

ResetCorr:
	if (profile == 3)
		corrY := 0
return

MySubroutine1:
	Gui, Submit, NoHide
	Loop, parse, Choice1 , |
	{
		SearchWeapon(1, A_LoopField)
	}
return

MySubroutine2:
	Gui, Submit, NoHide
	Loop, parse, Choice2 , |
	{
		SearchWeapon(2, A_LoopField)
	}
return

MySubroutine3:
	Gui, Submit, NoHide
	Loop, parse, Choice3 , |
	{
		SearchWeapon(3, A_LoopField)
	}
return

MySubroutine4:
	Gui, Submit, NoHide
	Loop, parse, Choice4 , |
	{
		SearchWeapon(4, A_LoopField)
	}
return

MySubroutine5:
	Gui, Submit, NoHide
	Loop, parse, Choice5 , |
	{
		SearchWeapon(5, A_LoopField)
	}
return

MySubroutine6:
	Gui, Submit, NoHide
	Loop, parse, Choice6 , |
	{
		SearchWeapon(6, A_LoopField)
	}
return

CheckBoxSound:
	tmp := 0
	GuiControlGet, State,, CheckBoxSound
	if (state)
		tmp := 1
	IniWrite, %tmp%, bf3-settings2.ini, General, Sound
return

CheckBoxFFire:
	GuiControlGet, State,, CheckBoxFFire
	if (state)
	{
		enableFirstCorr := 1
		enableLastCorr := 1
	}
	else
	{
		enableFirstCorr := 0
		enableLastCorr := 0
	}
return

CheckBoxLFire:
	GuiControlGet, State,, CheckBoxLFire
	if (state)
		enableLastCorr := 1
	else
		enableLastCorr := 0
return

; Close programm
GuiClose:
*F11::
	Suspend
	Song("exit")
	Suspend On
	Loop, 3
	{
		SetScrollLockState, On
		Sleep 90
		SetScrollLockState, Off
		Sleep 90
	}
	ExitApp
return

; --- FUNCTIONS ---

ChangeCorrection(tmp1, tmp2, tmp3)
{
	global profile
	global slot
	iid := 0
	tmpid := 0
	MsgBox В коррекции слот #%slot%
	MsgBox Сохраняю!
	if (profile == 1)
	{
		if (slot == 1)
		{
			MsgBox Сохраняю 1-ый слот
			IniRead, iid, bf3-settings2.ini, Profiles, AssaultPrimary
			if (iid > 13)
			{
				MsgBox Сохраняю в 1-ый слот штурмовика
				tmpid = %iid%-V-1st
				IniWrite, %tmp1%, bf3-correction.ini, Assault, %tmpid%
				MsgBox 111
				tmpid = %iid%-V-sub
				IniWrite, %tmp2%, bf3-correction.ini, Assault, %tmpid%
				tmpid = %iid%-delay
				IniWrite, %tmp3%, bf3-correction.ini, Assault, %tmpid%
			}
			else
			{
				tmpid = %iid%-V-1st
				IniWrite, %tmp1%, bf3-correction.ini, Other, %tmpid%
				tmpid = %iid%-V-sub
				IniWrite, %tmp2%, bf3-correction.ini, Other, %tmpid%
				tmpid = %iid%-delay
				IniWrite, %tmp3%, bf3-correction.ini, Other, %tmpid%
			}
		}
		else if (slot == 2)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, AssaultSecondary
			tmpid = %iid%-V-1st
			IniWrite, %tmp1%, bf3-correction.ini, Pistols, %tmpid%
			tmpid = %iid%-V-sub
			IniWrite, %tmp2%, bf3-correction.ini, Pistols, %tmpid%
			tmpid = %iid%-delay
			IniWrite, %tmp3%, bf3-correction.ini, Pistols, %tmpid%
		}
	}
	else if (profile == 2)
	{
		if (slot == 1)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, EngineerPrimary
			if (iid > 13)
			{
				tmpid = %iid%-V-1st
				IniWrite, %tmp1%, bf3-correction.ini, Engineer, %tmpid%
				tmpid = %iid%-V-sub
				IniWrite, %tmp2%, bf3-correction.ini, Engineer, %tmpid%
				tmpid = %iid%-delay
				IniWrite, %tmp3%, bf3-correction.ini, Engineer, %tmpid%
			}
			else
			{
				tmpid = %iid%-V-1st
				IniWrite, %tmp1%, bf3-correction.ini, Other, %tmpid%
				tmpid = %iid%-V-sub
				IniWrite, %tmp2%, bf3-correction.ini, Other, %tmpid%
				tmpid = %iid%-delay
				IniWrite, %tmp3%, bf3-correction.ini, Other, %tmpid%
			}
		}
		else if (slot == 2)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, EngineerSecondary
			tmpid = %iid%-V-1st
			IniWrite, %tmp1%, bf3-correction.ini, Pistols, %tmpid%
			tmpid = %iid%-V-sub
			IniWrite, %tmp2%, bf3-correction.ini, Pistols, %tmpid%
			tmpid = %iid%-delay
			IniWrite, %tmp3%, bf3-correction.ini, Pistols, %tmpid%
		}
	}
	else if (profile == 3)
	{
		if (slot == 1)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, SupportPrimary
			if (iid > 13)
			{
				tmpid = %iid%-V-1st
				IniWrite, %tmp1%, bf3-correction.ini, Support, %tmpid%
				tmpid = %iid%-V-sub
				IniWrite, %tmp2%, bf3-correction.ini, Support, %tmpid%
				tmpid = %iid%-delay
				IniWrite, %tmp3%, bf3-correction.ini, Support, %tmpid%
			}
			else
			{
				tmpid = %iid%-V-1st
				IniWrite, %tmp1%, bf3-correction.ini, Other, %tmpid%
				tmpid = %iid%-V-sub
				IniWrite, %tmp2%, bf3-correction.ini, Other, %tmpid%
				tmpid = %iid%-delay
				IniWrite, %tmp3%, bf3-correction.ini, Other, %tmpid%
			}
		}
		else if (slot == 2)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, SupportSecondary
			tmpid = %iid%-V-1st
			IniWrite, %tmp1%, bf3-correction.ini, Pistols, %tmpid%
			tmpid = %iid%-V-sub
			IniWrite, %tmp2%, bf3-correction.ini, Pistols, %tmpid%
			tmpid = %iid%-delay
			IniWrite, %tmp3%, bf3-correction.ini, Pistols, %tmpid%
		}
	}
	else if (profile == 4)
	{
		if (slot == 1)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, ReconPrimary
			if (iid > 13)
			{
				tmpid = %iid%-V-1st
				IniWrite, %tmp1%, bf3-correction.ini, Recon, %tmpid%
				tmpid = %iid%-V-sub
				IniWrite, %tmp2%, bf3-correction.ini, Recon, %tmpid%
				tmpid = %iid%-delay
				IniWrite, %tmp3%, bf3-correction.ini, Recon, %tmpid%
			}
			else
			{
				tmpid = %iid%-V-1st
				IniWrite, %tmp1%, bf3-correction.ini, Other, %tmpid%
				tmpid = %iid%-V-sub
				IniWrite, %tmp2%, bf3-correction.ini, Other, %tmpid%
				tmpid = %iid%-delay
				IniWrite, %tmp3%, bf3-correction.ini, Other, %tmpid%
			}
		}
		else if (slot == 2)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, ReconSecondary
			tmpid = %iid%-V-1st
			IniWrite, %tmp1%, bf3-correction.ini, Pistols, %tmpid%
			tmpid = %iid%-V-sub
			IniWrite, %tmp2%, bf3-correction.ini, Pistols, %tmpid%
			tmpid = %iid%-delay
			IniWrite, %tmp3%, bf3-correction.ini, Pistols, %tmpid%
		}
	}
	LoadCorrection(slot)
}

ChangeModifications()
{
	;
}

Correction()
{
	global corrY
	global corrX
	global tmpCorrY
	global tmpCorrX
	tmpCorrY := tmpCorrY + corrY
	tmpCorrX := tmpCorrX + corrX
	mouseXY(Floor(tmpCorrX), Floor(tmpCorrY))
	tmpCorrY := tmpCorrY - Floor(tmpCorrY)
	tmpCorrX := tmpCorrX - Floor(tmpCorrX)
}

GUILoadProfiles()
{
	global Weapons
	global tmpAssaultPrimary
	global tmpAssaultSecondary
	global tmpEngineerPrimary
	global tmpEngineerSecondary
	global tmpSupportPrimary
	global tmpSupportSecondary
	tmp := 0
	Loop, 8
	{
		B_Index = %A_Index%
		if (B_Index == 1)
			IniRead, tmp, bf3-settings2.ini, Profiles, AssaultPrimary
		else if (B_Index == 2)
			IniRead, tmp, bf3-settings2.ini, Profiles, AssaultSecondary
		else if (B_Index == 3)
			IniRead, tmp, bf3-settings2.ini, Profiles, EngineerPrimary
		else if (B_Index == 4)
			IniRead, tmp, bf3-settings2.ini, Profiles, EngineerSecondary
		else if (B_Index == 5)
			IniRead, tmp, bf3-settings2.ini, Profiles, SupportPrimary
		else if (B_Index == 6)
			IniRead, tmp, bf3-settings2.ini, Profiles, SupportSecondary
		else if (B_Index == 7)
			IniRead, tmp, bf3-settings2.ini, Profiles, ReconPrimary
		else if (B_Index == 8)
			IniRead, tmp, bf3-settings2.ini, Profiles, ReconSecondary
		Loop % Weapons.MaxIndex()
		{
			if (A_Index == tmp)
			{
				tmp := Weapons[A_Index]
				if (B_Index == 1)
				{
					tmpAssaultPrimary = %A_Index%
					GuiControl, , TextAssaultPrimary, %tmp% (%A_Index%)
				}
				else if (B_Index == 2)
				{
					tmpAssaultSecondary = %A_Index%
					GuiControl, , TextAssaultSecondary, %tmp% (%A_Index%)
				}
				else if (B_Index == 3)
				{
					tmpEngineerPrimary = %A_Index%
					GuiControl, , TextEngineerPrimary, %tmp% (%A_Index%)
				}
				else if (B_Index == 4)
				{
					tmpEngineerSecondary = %A_Index%
					GuiControl, , TextEngineerSecondary, %tmp% (%A_Index%)
				}
				else if (B_Index == 5)
				{
					tmpSupportPrimary = %A_Index%
					GuiControl, , TextSupportPrimary, %tmp% (%A_Index%)
				}
				else if (B_Index == 6)
				{
					tmpSupportSecondary = %A_Index%
					GuiControl, , TextSupportSecondary, %tmp% (%A_Index%)
				}
				else if (B_Index == 7)
				{
					GuiControl, , TextReconPrimary, %tmp% (%A_Index%)
				}
				else if (B_Index == 8)
				{
					GuiControl, , TextReconSecondary, %tmp% (%A_Index%)
				}
				break
			}
		}
	}
}

GUIResetChoice()
{
	Control, Choose, 1, ListBox1, %title%
	Control, Choose, 1, ListBox2, %title%
	Control, Choose, 1, ListBox3, %title%
	Control, Choose, 1, ListBox4, %title%
	Control, Choose, 1, ListBox5, %title%
	Control, Choose, 1, ListBox6, %title%
}

GUIUpdate()
{
	GUILoadProfiles()
	GUIUpdateInfo()
}

GUIUpdateInfo()
{
	global firstCorr
	global corrY
	global delay
	global recDelay
	firstCorr := Round(firstCorr, 2)
	corrY := Round(corrY, 2)
	GuiControl, , Text1stVCorr, 1st vert. correction: %firstCorr%
	GuiControl, , TextVCorr, Vert. correction: %corrY%
	GuiControl, , TextDelay, Delay: %delay% ms
	GuiControl, , TextRecDelay, Rec. delay: %recDelay% ms
}

GUIUpdateProfile()
{
	global profile
	GUIUpdateInfo()
	if (profile == 1)
	{
		GuiControl, , TextActiveProfile, Выбран профиль: Assault
	}
	else if (profile == 2)
	{
		GuiControl, , TextActiveProfile, Выбран профиль: Engineer
	}
	else if (profile == 3)
	{
		GuiControl, , TextActiveProfile, Выбран профиль: Support
	}
	else if (profile == 4)
	{
		GuiControl, , TextActiveProfile, Выбран профиль: Recon
	}
}

IsIniExists()
{
	arrV1st        := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arrVsub        := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arrDelay       := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arrRate        := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	
	arrSuppressor  := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arrFlashSupp   := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arrForegrip    := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arrHeavyBarrel := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arrRDS         := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arrHOLO        := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arrIR          := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arr3_4x        := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arr4x          := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arr6x          := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	arr7x          := [3,5,7,4,5,6,6,6,9,7,7,4,9,8,4,5,5,1,1,7,9,4,8,5,5,5,9,1,8,8,6,6,6,5,6,3,8,2,1,6,6,4,6,2,2,8,5,3,6,6,8,7,2,7,4,1,5,7,8]
	/*
	arrV1st        := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arrVsub        := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arrDelay       := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arrRate        := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	
	arrSuppressor  := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arrFlashSupp   := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arrForegrip    := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arrHeavyBarrel := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arrRDS         := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arrHOLO        := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arrIR          := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arr3_4x        := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arr4x          := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arr6x          := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	arr7x          := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	*/
	
	arrKeys        := ["V-1st","V-sub","delay","rate","Suppressor","Flash-Supp","Foregrip","Heavy-Barrel","RDS","HOLO","IR","3-4x","4x","6x","7x"]
	
	;tmpSection     := 0
	tmpKey         := 0
	tmpValue       := 0
	
	Loop, 59
	{
		tmp := 0
		IniRead, tmp, ./settings/%A_Index%.ini, General, Exists, 0
		if (!tmp)
		{
			IniWrite, 1, ./settings/%A_Index%.ini, General, Exists
			
			B_Index = %A_Index%
			Loop, 15
			{
				if (A_Index == 1)
					tmpValue := arrV1st[A_Index]
				else if (A_Index == 2)
					tmpValue := arrVsub[A_Index]
				else if (A_Index == 3)
					tmpValue := arrDelay[A_Index]
				else if (A_Index == 4)
					tmpValue := arrRate[A_Index]
				else if (A_Index == 5)
					tmpValue := arrSuppressor[A_Index]
				else if (A_Index == 6)
					tmpValue := arrFlashSupp[A_Index]
				else if (A_Index == 7)
					tmpValue := arrForegrip[A_Index]
				else if (A_Index == 8)
					tmpValue := arrHeavyBarrel[A_Index]
				else if (A_Index == 9)
					tmpValue := arrRDS[A_Index]
				else if (A_Index == 10)
					tmpValue := arrHOLO[A_Index]
				else if (A_Index == 11)
					tmpValue := arrIR[A_Index]
				else if (A_Index == 12)
					tmpValue := arr3_4x[A_Index]
				else if (A_Index == 13)
					tmpValue := arr4x[A_Index]
				else if (A_Index == 14)
					tmpValue := arr6x[A_Index]
				else if (A_Index == 15)
					tmpValue := arr7x[A_Index]
				
				tmpKey := arrKeys[A_Index]
				if (A_Index <= 4)
					IniWrite, %tmpValue%, ./settings/%B_Index%.ini, General, %tmpKey%
				else
					IniWrite, %tmpValue%, ./settings/%B_Index%.ini, MOD-VALUES, %tmpKey%
			}
		}
	}
}

/*
IsIniExists()
{
	tmp := 0
	IniRead, tmp, bf3-settings2.ini, General, Exists, 0
	if (!tmp)
	{
		IniWrite, 1, bf3-settings2.ini, General, Exists
		IniWrite, 1, bf3-settings2.ini, General, Sound
		IniWrite, 1, bf3-settings2.ini, Profiles, AssaultPrimary
		IniWrite, 52, bf3-settings2.ini, Profiles, AssaultSecondary
		IniWrite, 1, bf3-settings2.ini, Profiles, EngineerPrimary
		IniWrite, 52, bf3-settings2.ini, Profiles, EngineerSecondary
		IniWrite, 1, bf3-settings2.ini, Profiles, SupportPrimary
		IniWrite, 52, bf3-settings2.ini, Profiles, SupportSecondary
		MsgBox, Файл с настройками профилей не был найден или параметр Exists был равен нулю. Файл обновлён.
	}
	tmp := 0
	IniRead, tmp, bf3-correction.ini, General, Exists, 0
	if (!tmp)
	{
		IniWrite, 1, bf3-correction.ini, General, Exists
		IniWrite, 1, bf3-correction.ini, General, Factor
		IniWrite, 1, bf3-correction.ini, Other, 1-V-1st
		IniWrite, 1, bf3-correction.ini, Other, 1-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 1-delay
		IniWrite, 125, bf3-correction.ini, Other, 1-rate
		IniWrite, 0.5, bf3-correction.ini, Other, 2-V-1st
		IniWrite, 0.4, bf3-correction.ini, Other, 2-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 2-delay
		IniWrite, 900, bf3-correction.ini, Other, 2-rate
		IniWrite, 1, bf3-correction.ini, Other, 3-V-1st
		IniWrite, 1.2, bf3-correction.ini, Other, 3-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 3-delay
		IniWrite, 220, bf3-correction.ini, Other, 3-rate
		IniWrite, 1, bf3-correction.ini, Other, 4-V-1st
		IniWrite, 1.2, bf3-correction.ini, Other, 4-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 4-delay
		IniWrite, 220, bf3-correction.ini, Other, 4-rate
		IniWrite, 1.5, bf3-correction.ini, Other, 5-V-1st
		IniWrite, 1.5, bf3-correction.ini, Other, 5-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 5-delay
		IniWrite, 255, bf3-correction.ini, Other, 5-rate
		IniWrite, 2.2, bf3-correction.ini, Other, 6-V-1st
		IniWrite, 0.12, bf3-correction.ini, Other, 6-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 6-delay
		IniWrite, 950, bf3-correction.ini, Other, 6-rate
		IniWrite, 2, bf3-correction.ini, Other, 7-V-1st
		IniWrite, 0.18, bf3-correction.ini, Other, 7-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 7-delay
		IniWrite, 900, bf3-correction.ini, Other, 7-rate
		IniWrite, 2, bf3-correction.ini, Other, 8-V-1st
		IniWrite, 0.2, bf3-correction.ini, Other, 8-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 8-delay
		IniWrite, 750, bf3-correction.ini, Other, 8-rate
		IniWrite, 1.5, bf3-correction.ini, Other, 9-V-1st
		IniWrite, 0.2, bf3-correction.ini, Other, 9-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 9-delay
		IniWrite, 900, bf3-correction.ini, Other, 9-rate
		IniWrite, 2.5, bf3-correction.ini, Other, 10-V-1st
		IniWrite, 0.18, bf3-correction.ini, Other, 10-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 10-delay
		IniWrite, 650, bf3-correction.ini, Other, 10-rate
		IniWrite, 1, bf3-correction.ini, Other, 11-V-1st
		IniWrite, 0.8, bf3-correction.ini, Other, 11-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 11-delay
		IniWrite, 220, bf3-correction.ini, Other, 11-rate
		IniWrite, 2.75, bf3-correction.ini, Other, 12-V-1st
		IniWrite, 0.25, bf3-correction.ini, Other, 12-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 12-delay
		IniWrite, 600, bf3-correction.ini, Other, 12-rate
		IniWrite, 2, bf3-correction.ini, Other, 13-V-1st
		IniWrite, 1.2, bf3-correction.ini, Other, 13-V-sub
		IniWrite, 20, bf3-correction.ini, Other, 13-delay
		IniWrite, 275, bf3-correction.ini, Other, 13-rate
		IniWrite, 3, bf3-correction.ini, Assault, 14-V-1st
		IniWrite, 0.2, bf3-correction.ini, Assault, 14-V-sub
		IniWrite, 20, bf3-correction.ini, Assault, 14-delay
		IniWrite, 900, bf3-correction.ini, Assault, 14-rate
		IniWrite, 1.5, bf3-correction.ini, Assault, 15-V-1st
		IniWrite, 0.28, bf3-correction.ini, Assault, 15-V-sub
		IniWrite, 20, bf3-correction.ini, Assault, 15-delay
		IniWrite, 650, bf3-correction.ini, Assault, 15-rate
		IniWrite, 1.5, bf3-correction.ini, Assault, 16-V-1st
		IniWrite, 0.3, bf3-correction.ini, Assault, 16-V-sub
		IniWrite, 20, bf3-correction.ini, Assault, 16-delay
		IniWrite, 600, bf3-correction.ini, Assault, 16-rate
		IniWrite, 3, bf3-correction.ini, Assault, 17-V-1st
		IniWrite, 0.26, bf3-correction.ini, Assault, 17-V-sub
		IniWrite, 20, bf3-correction.ini, Assault, 17-delay
		IniWrite, 850, bf3-correction.ini, Assault, 17-rate
		IniWrite, 2.6, bf3-correction.ini, Assault, 18-V-1st
		IniWrite, 0.35, bf3-correction.ini, Assault, 18-V-sub
		IniWrite, 20, bf3-correction.ini, Assault, 18-delay
		IniWrite, 1000, bf3-correction.ini, Assault, 18-rate
		IniWrite, 1.4, bf3-correction.ini, Assault, 19-V-1st
		IniWrite, 0.45, bf3-correction.ini, Assault, 19-V-sub
		IniWrite, 20, bf3-correction.ini, Assault, 19-delay
		IniWrite, 550, bf3-correction.ini, Assault, 19-rate
		IniWrite, 1.5, bf3-correction.ini, Assault, 20-V-1st
		IniWrite, 0.2, bf3-correction.ini, Assault, 20-V-sub
		IniWrite, 20, bf3-correction.ini, Assault, 20-delay
		IniWrite, 800, bf3-correction.ini, Assault, 20-rate
		IniWrite, 2.5, bf3-correction.ini, Assault, 21-V-1st
		IniWrite, 0.2, bf3-correction.ini, Assault, 21-V-sub
		IniWrite, 20, bf3-correction.ini, Assault, 21-delay
		IniWrite, 650, bf3-correction.ini, Assault, 21-rate
		IniWrite, 2.5, bf3-correction.ini, Assault, 22-V-1st
		IniWrite, 0.26, bf3-correction.ini, Assault, 22-V-sub
		IniWrite, 20, bf3-correction.ini, Assault, 22-delay
		IniWrite, 800, bf3-correction.ini, Assault, 22-rate
		IniWrite, 2.5, bf3-correction.ini, Assault, 23-V-1st
		IniWrite, 0.26, bf3-correction.ini, Assault, 23-V-sub
		IniWrite, 20, bf3-correction.ini, Assault, 23-delay
		IniWrite, 800, bf3-correction.ini, Assault, 23-rate
		IniWrite, 1.8, bf3-correction.ini, Assault, 24-V-1st
		IniWrite, 0.26, bf3-correction.ini, Assault, 24-V-sub
		IniWrite, 20, bf3-correction.ini, Assault, 24-delay
		IniWrite, 750, bf3-correction.ini, Assault, 24-rate
		IniWrite, 3, bf3-correction.ini, Engineer, 25-V-1st
		IniWrite, 0.2, bf3-correction.ini, Engineer, 25-V-sub
		IniWrite, 20, bf3-correction.ini, Engineer, 25-delay
		IniWrite, 800, bf3-correction.ini, Engineer, 25-rate
		IniWrite, 1.5, bf3-correction.ini, Engineer, 26-V-1st
		IniWrite, 0.28, bf3-correction.ini, Engineer, 26-V-sub
		IniWrite, 20, bf3-correction.ini, Engineer, 26-delay
		IniWrite, 650, bf3-correction.ini, Engineer, 26-rate
		IniWrite, 1.8, bf3-correction.ini, Engineer, 27-V-1st
		IniWrite, 0.28, bf3-correction.ini, Engineer, 27-V-sub
		IniWrite, 20, bf3-correction.ini, Engineer, 27-delay
		IniWrite, 750, bf3-correction.ini, Engineer, 27-rate
		IniWrite, 2.5, bf3-correction.ini, Engineer, 28-V-1st
		IniWrite, 0.28, bf3-correction.ini, Engineer, 28-V-sub
		IniWrite, 20, bf3-correction.ini, Engineer, 28-delay
		IniWrite, 750, bf3-correction.ini, Engineer, 28-rate
		IniWrite, 2.8, bf3-correction.ini, Engineer, 29-V-1st
		IniWrite, 0.26, bf3-correction.ini, Engineer, 29-V-sub
		IniWrite, 20, bf3-correction.ini, Engineer, 29-delay
		IniWrite, 800, bf3-correction.ini, Engineer, 29-rate
		IniWrite, 2.8, bf3-correction.ini, Engineer, 30-V-1st
		IniWrite, 0.26, bf3-correction.ini, Engineer, 30-V-sub
		IniWrite, 20, bf3-correction.ini, Engineer, 30-delay
		IniWrite, 800, bf3-correction.ini, Engineer, 30-rate
		IniWrite, 2.5, bf3-correction.ini, Engineer, 31-V-1st
		IniWrite, 0.2, bf3-correction.ini, Engineer, 31-V-sub
		IniWrite, 20, bf3-correction.ini, Engineer, 31-delay
		IniWrite, 650, bf3-correction.ini, Engineer, 31-rate
		IniWrite, 1.35, bf3-correction.ini, Engineer, 32-V-1st
		IniWrite, 0.5, bf3-correction.ini, Engineer, 32-V-sub
		IniWrite, 20, bf3-correction.ini, Engineer, 32-delay
		IniWrite, 600, bf3-correction.ini, Engineer, 32-rate
		IniWrite, 2.2, bf3-correction.ini, Engineer, 33-V-1st
		IniWrite, 0.25, bf3-correction.ini, Engineer, 33-V-sub
		IniWrite, 20, bf3-correction.ini, Engineer, 33-delay
		IniWrite, 700, bf3-correction.ini, Engineer, 33-rate
		IniWrite, 1.7, bf3-correction.ini, Support, 34-V-1st
		IniWrite, 0.7, bf3-correction.ini, Support, 34-V-sub
		IniWrite, 20, bf3-correction.ini, Support, 34-delay
		IniWrite, 650, bf3-correction.ini, Support, 34-rate
		IniWrite, 2.2, bf3-correction.ini, Support, 35-V-1st
		IniWrite, 0.4, bf3-correction.ini, Support, 35-V-sub
		IniWrite, 20, bf3-correction.ini, Support, 35-delay
		IniWrite, 800, bf3-correction.ini, Support, 35-rate
		IniWrite, 2.2, bf3-correction.ini, Support, 36-V-1st
		IniWrite, 0.35, bf3-correction.ini, Support, 36-V-sub
		IniWrite, 20, bf3-correction.ini, Support, 36-delay
		IniWrite, 750, bf3-correction.ini, Support, 36-rate
		IniWrite, 1.5, bf3-correction.ini, Support, 37-V-1st
		IniWrite, 0.6, bf3-correction.ini, Support, 37-V-sub
		IniWrite, 20, bf3-correction.ini, Support, 37-delay
		IniWrite, 580, bf3-correction.ini, Support, 37-rate
		IniWrite, 1.8, bf3-correction.ini, Support, 38-V-1st
		IniWrite, 0.4, bf3-correction.ini, Support, 38-V-sub
		IniWrite, 20, bf3-correction.ini, Support, 38-delay
		IniWrite, 750, bf3-correction.ini, Support, 38-rate
		IniWrite, 1.5, bf3-correction.ini, Support, 39-V-1st
		IniWrite, 0.65, bf3-correction.ini, Support, 39-V-sub
		IniWrite, 20, bf3-correction.ini, Support, 39-delay
		IniWrite, 600, bf3-correction.ini, Support, 39-rate
		IniWrite, 2, bf3-correction.ini, Support, 40-V-1st
		IniWrite, 0.37, bf3-correction.ini, Support, 40-V-sub
		IniWrite, 20, bf3-correction.ini, Support, 40-delay
		IniWrite, 650, bf3-correction.ini, Support, 40-rate
		IniWrite, 1.8, bf3-correction.ini, Support, 41-V-1st
		IniWrite, 0.3, bf3-correction.ini, Support, 41-V-sub
		IniWrite, 20, bf3-correction.ini, Support, 41-delay
		IniWrite, 700, bf3-correction.ini, Support, 41-rate
		IniWrite, 1.5, bf3-correction.ini, Support, 42-V-1st
		IniWrite, 0.5, bf3-correction.ini, Support, 42-V-sub
		IniWrite, 20, bf3-correction.ini, Support, 42-delay
		IniWrite, 650, bf3-correction.ini, Support, 42-rate
		IniWrite, 1, bf3-correction.ini, Recon, 43-V-1st
		IniWrite, 1.5, bf3-correction.ini, Recon, 43-V-sub
		IniWrite, 20, bf3-correction.ini, Recon, 43-delay
		IniWrite, 260, bf3-correction.ini, Recon, 43-rate
		IniWrite, 1, bf3-correction.ini, Recon, 44-V-1st
		IniWrite, 1.5, bf3-correction.ini, Recon, 44-V-sub
		IniWrite, 20, bf3-correction.ini, Recon, 44-delay
		IniWrite, 260, bf3-correction.ini, Recon, 44-rate
		IniWrite, 1, bf3-correction.ini, Recon, 45-V-1st
		IniWrite, 1.2, bf3-correction.ini, Recon, 45-V-sub
		IniWrite, 20, bf3-correction.ini, Recon, 45-delay
		IniWrite, 300, bf3-correction.ini, Recon, 45-rate
		IniWrite, 1, bf3-correction.ini, Recon, 46-V-1st
		IniWrite, 2, bf3-correction.ini, Recon, 46-V-sub
		IniWrite, 20, bf3-correction.ini, Recon, 46-delay
		IniWrite, 48, bf3-correction.ini, Recon, 46-rate
		IniWrite, 1, bf3-correction.ini, Recon, 47-V-1st
		IniWrite, 2, bf3-correction.ini, Recon, 47-V-sub
		IniWrite, 20, bf3-correction.ini, Recon, 47-delay
		IniWrite, 46.2, bf3-correction.ini, Recon, 47-rate
		IniWrite, 1, bf3-correction.ini, Recon, 48-V-1st
		IniWrite, 2, bf3-correction.ini, Recon, 48-V-sub
		IniWrite, 20, bf3-correction.ini, Recon, 48-delay
		IniWrite, 54.5, bf3-correction.ini, Recon, 48-rate
		IniWrite, 1, bf3-correction.ini, Recon, 49-V-1st
		IniWrite, 0.55, bf3-correction.ini, Recon, 49-V-sub
		IniWrite, 20, bf3-correction.ini, Recon, 49-delay
		IniWrite, 333, bf3-correction.ini, Recon, 49-rate
		IniWrite, 1, bf3-correction.ini, Recon, 50-V-1st
		IniWrite, 1.5, bf3-correction.ini, Recon, 50-V-sub
		IniWrite, 20, bf3-correction.ini, Recon, 50-delay
		IniWrite, 260, bf3-correction.ini, Recon, 50-rate
		IniWrite, 1, bf3-correction.ini, Recon, 51-V-1st
		IniWrite, 2, bf3-correction.ini, Recon, 51-V-sub
		IniWrite, 20, bf3-correction.ini, Recon, 51-delay
		IniWrite, 43.5, bf3-correction.ini, Recon, 51-rate
		IniWrite, 1, bf3-correction.ini, Pistols, 52-V-1st
		IniWrite, 2, bf3-correction.ini, Pistols, 52-V-sub
		IniWrite, 20, bf3-correction.ini, Pistols, 52-delay
		IniWrite, 160, bf3-correction.ini, Pistols, 52-rate
		IniWrite, 1.5, bf3-correction.ini, Pistols, 53-V-1st
		IniWrite, 0.5, bf3-correction.ini, Pistols, 53-V-sub
		IniWrite, 20, bf3-correction.ini, Pistols, 53-delay
		IniWrite, 900, bf3-correction.ini, Pistols, 53-rate
		IniWrite, 1, bf3-correction.ini, Pistols, 54-V-1st
		IniWrite, 0.7, bf3-correction.ini, Pistols, 54-V-sub
		IniWrite, 20, bf3-correction.ini, Pistols, 54-delay
		IniWrite, 400, bf3-correction.ini, Pistols, 54-rate
		IniWrite, 2.4, bf3-correction.ini, Pistols, 55-V-1st
		IniWrite, 0.7, bf3-correction.ini, Pistols, 55-V-sub
		IniWrite, 20, bf3-correction.ini, Pistols, 55-delay
		IniWrite, 900, bf3-correction.ini, Pistols, 55-rate
		IniWrite, 1, bf3-correction.ini, Pistols, 56-V-1st
		IniWrite, 0.7, bf3-correction.ini, Pistols, 56-V-sub
		IniWrite, 20, bf3-correction.ini, Pistols, 56-delay
		IniWrite, 333, bf3-correction.ini, Pistols, 56-rate
		IniWrite, 1, bf3-correction.ini, Pistols, 57-V-1st
		IniWrite, 0.7, bf3-correction.ini, Pistols, 57-V-sub
		IniWrite, 20, bf3-correction.ini, Pistols, 57-delay
		IniWrite, 400, bf3-correction.ini, Pistols, 57-rate
		IniWrite, 1, bf3-correction.ini, Pistols, 58-V-1st
		IniWrite, 1.2, bf3-correction.ini, Pistols, 58-V-sub
		IniWrite, 20, bf3-correction.ini, Pistols, 58-delay
		IniWrite, 255, bf3-correction.ini, Pistols, 58-rate
		IniWrite, 1, bf3-correction.ini, Pistols, 59-V-1st
		IniWrite, 0.7, bf3-correction.ini, Pistols, 59-V-sub
		IniWrite, 20, bf3-correction.ini, Pistols, 59-delay
		IniWrite, 400, bf3-correction.ini, Pistols, 59-rate
		MsgBox, Файл с настройками коррекции стрельбы не был найден или параметр Exists был равен нулю. Файл обновлён.
	}
}
*/

ModCorrection()
{
}

/*
LoadCorrection(i)
{
	global profile
	global firstCorr
	global corrY
	global corrX
	global tmpCorrY
	global tmpCorrX
	global delay
	global recDelay
	global factor
}
*/

LoadCorrection(i)
{
	global profile
	global firstCorr
	global corrY
	global corrX
	global corrXRemember
	global tmpCorrY
	global tmpCorrX
	global delay
	global recDelay
	global iResetCorr
	global factor
	iid := 0
	tmpid := 0
	tmp := 0
	IniRead, factor, bf3-correction.ini, General, Factor
	if (profile == 1)
	{
		if (i == 1)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, AssaultPrimary
			if (iid > 13)
			{
				tmpid = %iid%-V-1st
				IniRead, tmp, bf3-correction.ini, Assault, %tmpid%
				firstCorr = %tmp%
				tmpid = %iid%-V-sub
				IniRead, tmp, bf3-correction.ini, Assault, %tmpid%
				corrY := Round(tmp * factor, 2)
				corrXRemember = %corrY%
				tmpid = %iid%-H
				IniRead, tmp, bf3-correction.ini, Assault, %tmpid%
				corrX := Round(tmp * factor, 2)
				tmpid = %iid%-delay
				IniRead, tmp, bf3-correction.ini, Assault, %tmpid%
				delay = %tmp%
				tmpid = %iid%-rate
				IniRead, tmp, bf3-correction.ini, Assault, %tmpid%
				recDelay := Round(1000 / (tmp/60), 0)
				tmpid = %iid%-resetDelay
				IniRead, iResetCorr, bf3-correction.ini, Assault, %tmpid%, 0
			}
			else
			{
				tmpid = %iid%-V-1st
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				firstCorr = %tmp%
				tmpid = %iid%-V-sub
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				corrY := Round(tmp * factor, 2)
				corrXRemember = %corrY%
				tmpid = %iid%-H
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				corrX := Round(tmp * factor, 2)
				tmpid = %iid%-delay
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				delay = %tmp%
				tmpid = %iid%-rate
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				recDelay := Round(1000 / (tmp/60), 0)
				tmpid = %iid%-resetDelay
				IniRead, iResetCorr, bf3-correction.ini, Other, %tmpid%, 0
			}
		}
		else if (i == 2)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, AssaultSecondary
			tmpid = %iid%-V-1st
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			firstCorr = %tmp%
			tmpid = %iid%-V-sub
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			corrY := Round(tmp * factor, 2)
			corrXRemember = %corrY%
			tmpid = %iid%-H
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			corrX := Round(tmp * factor, 2)
			tmpid = %iid%-delay
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			delay = %tmp%
			tmpid = %iid%-rate
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			recDelay := Round(1000 / (tmp/60), 0)
			tmpid = %iid%-resetDelay
			IniRead, iResetCorr, bf3-correction.ini, Pistols, %tmpid%, 0
		}
	}
	else if (profile == 2)
	{
		if (i == 1)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, EngineerPrimary
			if (iid > 13)
			{
				tmpid = %iid%-V-1st
				IniRead, tmp, bf3-correction.ini, Engineer, %tmpid%
				firstCorr = %tmp%
				tmpid = %iid%-V-sub
				IniRead, tmp, bf3-correction.ini, Engineer, %tmpid%
				corrY := Round(tmp * factor, 2)
				corrXRemember = %corrY%
				tmpid = %iid%-H
				IniRead, tmp, bf3-correction.ini, Engineer, %tmpid%
				corrX := Round(tmp * factor, 2)
				tmpid = %iid%-delay
				IniRead, tmp, bf3-correction.ini, Engineer, %tmpid%
				delay = %tmp%
				tmpid = %iid%-rate
				IniRead, tmp, bf3-correction.ini, Engineer, %tmpid%
				recDelay := Round(1000 / (tmp/60), 0)
				tmpid = %iid%-resetDelay
				IniRead, iResetCorr, bf3-correction.ini, Engineer, %tmpid%, 0
			}
			else
			{
				tmpid = %iid%-V-1st
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				firstCorr = %tmp%
				tmpid = %iid%-V-sub
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				corrY := Round(tmp * factor, 2)
				corrXRemember = %corrY%
				tmpid = %iid%-H
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				corrX := Round(tmp * factor, 2)
				tmpid = %iid%-delay
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				delay = %tmp%
				tmpid = %iid%-rate
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				recDelay := Round(1000 / (tmp/60), 0)
				tmpid = %iid%-resetDelay
				IniRead, iResetCorr, bf3-correction.ini, Other, %tmpid%, 0
			}
		}
		else if (i == 2)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, EngineerSecondary
			tmpid = %iid%-V-1st
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			firstCorr = %tmp%
			tmpid = %iid%-V-sub
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			corrY := Round(tmp * factor, 2)
			corrXRemember = %corrY%
			tmpid = %iid%-H
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			corrX := Round(tmp * factor, 2)
			tmpid = %iid%-delay
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			delay = %tmp%
			tmpid = %iid%-rate
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			recDelay := Round(1000 / (tmp/60), 0)
			tmpid = %iid%-resetDelay
			IniRead, iResetCorr, bf3-correction.ini, Pistols, %tmpid%, 0
		}
	}
	else if (profile == 3)
	{
		if (i == 1)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, SupportPrimary
			if (iid > 13)
			{
				tmpid = %iid%-V-1st
				IniRead, tmp, bf3-correction.ini, Support, %tmpid%
				firstCorr = %tmp%
				tmpid = %iid%-V-sub
				IniRead, tmp, bf3-correction.ini, Support, %tmpid%
				corrY := Round(tmp * factor, 2)
				corrXRemember = %corrY%
				tmpid = %iid%-H
				IniRead, tmp, bf3-correction.ini, Support, %tmpid%
				corrX := Round(tmp * factor, 2)
				tmpid = %iid%-delay
				IniRead, tmp, bf3-correction.ini, Support, %tmpid%
				delay = %tmp%
				tmpid = %iid%-rate
				IniRead, tmp, bf3-correction.ini, Support, %tmpid%
				recDelay := Round(1000 / (tmp/60), 0)
				tmpid = %iid%-resetDelay
				IniRead, iResetCorr, bf3-correction.ini, Support, %tmpid%, 0
			}
			else
			{
				tmpid = %iid%-V-1st
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				firstCorr = %tmp%
				tmpid = %iid%-V-sub
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				corrY := Round(tmp * factor, 2)
				corrXRemember = %corrY%
				tmpid = %iid%-H
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				corrX := Round(tmp * factor, 2)
				tmpid = %iid%-delay
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				delay = %tmp%
				tmpid = %iid%-rate
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				recDelay := Round(1000 / (tmp/60), 0)
				tmpid = %iid%-resetDelay
				IniRead, iResetCorr, bf3-correction.ini, Other, %tmpid%, 0
			}
		}
		else if (i == 2)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, SupportSecondary
			tmpid = %iid%-V-1st
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			firstCorr = %tmp%
			tmpid = %iid%-V-sub
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			corrY := Round(tmp * factor, 2)
			corrXRemember = %corrY%
			tmpid = %iid%-H
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			corrX := Round(tmp * factor, 2)
			tmpid = %iid%-delay
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			delay = %tmp%
			tmpid = %iid%-rate
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			recDelay := Round(1000 / (tmp/60), 0)
			tmpid = %iid%-resetDelay
			IniRead, iResetCorr, bf3-correction.ini, Pistols, %tmpid%, 0
		}
	}
	else if (profile == 4)
	{
		if (i == 1)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, ReconPrimary
			if (iid > 13)
			{
				tmpid = %iid%-V-1st
				IniRead, tmp, bf3-correction.ini, Recon, %tmpid%
				firstCorr = %tmp%
				tmpid = %iid%-V-sub
				IniRead, tmp, bf3-correction.ini, Recon, %tmpid%
				corrY := Round(tmp * factor, 2)
				corrXRemember = %corrY%
				tmpid = %iid%-H
				IniRead, tmp, bf3-correction.ini, Recon, %tmpid%
				corrX := Round(tmp * factor, 2)
				tmpid = %iid%-delay
				IniRead, tmp, bf3-correction.ini, Recon, %tmpid%
				delay = %tmp%
				tmpid = %iid%-rate
				IniRead, tmp, bf3-correction.ini, Recon, %tmpid%
				recDelay := Round(1000 / (tmp/60), 0)
				tmpid = %iid%-resetDelay
				IniRead, iResetCorr, bf3-correction.ini, Recon, %tmpid%, 0
			}
			else
			{
				tmpid = %iid%-V-1st
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				firstCorr = %tmp%
				tmpid = %iid%-V-sub
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				corrY := Round(tmp * factor, 2)
				corrXRemember = %corrY%
				tmpid = %iid%-H
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				corrX := Round(tmp * factor, 2)
				tmpid = %iid%-delay
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				delay = %tmp%
				tmpid = %iid%-rate
				IniRead, tmp, bf3-correction.ini, Other, %tmpid%
				recDelay := Round(1000 / (tmp/60), 0)
				tmpid = %iid%-resetDelay
				IniRead, iResetCorr, bf3-correction.ini, Other, %tmpid%, 0
			}
		}
		else if (i == 2)
		{
			IniRead, iid, bf3-settings2.ini, Profiles, ReconSecondary
			tmpid = %iid%-V-1st
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			firstCorr = %tmp%
			tmpid = %iid%-V-sub
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			corrY := Round(tmp * factor, 2)
			corrXRemember = %corrY%
			tmpid = %iid%-H
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			corrX := Round(tmp * factor, 2)
			tmpid = %iid%-delay
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			delay = %tmp%
			tmpid = %iid%-rate
			IniRead, tmp, bf3-correction.ini, Pistols, %tmpid%
			recDelay := Round(1000 / (tmp/60), 0)
			tmpid = %iid%-resetDelay
			IniRead, iResetCorr, bf3-correction.ini, Pistols, %tmpid%, 0
		}
	}
	tmpCorrY := 0
	tmpCorrX := 0
}

mouseXY(x, y)
{
	DllCall("mouse_event",uint,1,int,x,int,y,uint,0,int,0)
}

mouseLD()
{
	;DllCall("mouse_event",uint,1,int,0,int,0,uint,0,int,0)
	MouseClick, left,,,1,0, D
}

mouseLU()
{
	;DllCall("mouse_event",uint,1,int,0,int,0,uint,0,int,0)
	MouseClick, left,,,1,0, U
}

PreCorrection()
{
	global enableFirstCorr
	global firstCorr
	global corrY
	if (enableFirstCorr)
		mouseXY(0, firstCorr)
}

RememberWeapon(i, iid)
{
	global tmpAssaultPrimary
	global tmpAssaultSecondary
	global tmpEngineerPrimary
	global tmpEngineerSecondary
	global tmpSupportPrimary
	global tmpSupportSecondary
	if (iid)
	{
		if (i == 1)
			tmpAssaultPrimary = %iid%
		else if (i == 2)
			tmpAssaultSecondary = %iid%
		else if (i == 3)
			tmpEngineerPrimary = %iid%
		else if (i == 4)
			tmpEngineerSecondary = %iid%
		else if (i == 5)
			tmpSupportPrimary = %iid%
		else if (i == 6)
			tmpSupportSecondary = %iid%
	}
}

SaveWeapon()
{
	global tmpAssaultPrimary
	global tmpAssaultSecondary
	global tmpEngineerPrimary
	global tmpEngineerSecondary
	global tmpSupportPrimary
	global tmpSupportSecondary
	IniWrite, %tmpAssaultPrimary%, bf3-settings2.ini, Profiles, AssaultPrimary
	IniWrite, %tmpAssaultSecondary%, bf3-settings2.ini, Profiles, AssaultSecondary
	IniWrite, %tmpEngineerPrimary%, bf3-settings2.ini, Profiles, EngineerPrimary
	IniWrite, %tmpEngineerSecondary%, bf3-settings2.ini, Profiles, EngineerSecondary
	IniWrite, %tmpSupportPrimary%, bf3-settings2.ini, Profiles, SupportPrimary
	IniWrite, %tmpSupportSecondary%, bf3-settings2.ini, Profiles, SupportSecondary
	GUILoadProfiles()
	GUIResetChoice()
	MsgBox, Сохранено!
}

SearchWeapon(i, s)
{
	global Weapons
	iid := 0
	Loop % Weapons.MaxIndex()
	{
		if (Weapons[A_Index] == s)
		{
			iid = %A_Index%
			break
		}
	}
	RememberWeapon(i, iid)
}

Song(s)
{
	global sound
	if (sound)
	{
		if (s == "on")
			SoundPlay, ./sounds/on.wav
		else if (s == "off")
			SoundPlay, ./sounds/off.wav
		else if (s == "mode")
			SoundPlay, ./sounds/mode.wav
		else if (s == "exit")
			SoundPlay, ./sounds/exit.wav
	}
}

SoundCheck()
{
	global sound
	tmp := 0
	IniRead, tmp, bf3-settings2.ini, General, Sound, 1
	if (!tmp)
		sound := 0
	else
		sound := 1
}