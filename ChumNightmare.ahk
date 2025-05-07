;Made by HasB aka Nuntoohydrological aka TheeSkengdo
;This script is free
#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1

;Read config for resolution 
IniRead, Resolution, settings.ini, Display, Resolution, 1440p

ScaleX(x) {
    global Resolution
    return (Resolution = "1080p") ? Round(x * 0.75) : x
}

ScaleY(y) {
    global Resolution
    return (Resolution = "1080p") ? Round(y * 0.75) : y
}

global CoordMap ;for JoinPrivate Server

;Join Private coordmaps
CoordMap := {} 
CoordMap["JoinBtn"]        := { "1080p": [560, 238],  "1440p": [561, 241] }
CoordMap["JoinFriends"]    := { "1080p": [428, 410],  "1440p": [397, 415] }
CoordMap["Refresh"] 	   := { "1080p": [1394, 125], "1440p": [1714, 130] }
CoordMap["PrivateSrvSlot"] := { "1080p": [590, 490],  "1440p": [910, 490] }

ClickStep(stepName) {
    global Resolution, CoordMap

    ;lookup
    if !(stepName in CoordMap)
        throw Exception("Step """ stepName """ not defined in CoordMap.")
    pair := CoordMap[stepName][Resolution]
    if !IsObject(pair)
        throw Exception("No coords for step """ stepName """ at resolution " Resolution)
    x := pair[1], y := pair[2]

    ;wiggle around (±5px) then return to center
    MouseGetPos, origX, origY
    Loop 3 {
        Random, dx, -5, 5
        Random, dy, -5, 5
        MouseMove, x + dx, y + dy, 0
        Sleep, 30
    }
    MouseMove, x, y, 0

    ;click
    Click, %x% ", " %y%
    Sleep, 300
}

;Show menu soon as script selected
GoSub, CreateChumGUI

;F1 to reopen menu if closed
F1::Reload  ; Restart script

CreateChumGUI:
    Gui, ChumGUI:New, +AlwaysOnTop +ToolWindow -SysMenu, Chum Macro
    Gui, ChumGUI:Color, F0F0F0
    Gui, ChumGUI:Font, S10 Bold, Verdana
    Gui, ChumGUI:Add, Text, x20 y15 w160 Center, Chum Options:
    Gui, ChumGUI:Add, Button, gJoinPrivateServer x20 y50 w160 h30, Join Server
	Gui, ChumGUI:Add, Button, gLeavePrivateServer x20 y90 w160 h40, Leave and Join Server
    Gui, ChumGUI:Add, Button, gGoToLevel x20 y140 w160 h30, Go To Level
	Gui, ChumGUI:Add, Button, gPreChum x20 y180 w160 h30, Setup Level
	Gui, ChumGUI:Add, Button, gChumMacro x20 y220 w160 h30, Carry On
    Gui, ChumGUI:Add, Button, gCloseMenu x20 y260 w160 h30, Close Menu
	Gui, ChumGUI:Add, Button, gReturnMain x20 y300 w160 h30, Main Menu
    Gui, ChumGUI:Show, w200 h360, Chum Macro by HasB
Return

ReturnMain:
    Gui, ChumGUI:Destroy
    Run, Main.ahk
    ExitApp
Return

CloseMenu:
	Gui, ChumGUI:Destroy
Return

GoToLevel:
	Gui, ChumGUI:Destroy
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	Sleep, 300

	Loop
	{
		CoordMode, Pixel, Window
		ImageSearch, PlayX, PlayY
		, % ScaleX(196), % ScaleY(493) ;Top Left
		, % ScaleX(515), % ScaleY(799) ;Bottom Right
		, *10 %A_ScriptDir%\Images\%Resolution%\PlayButton.png
		Sleep, 300
	}
	
	Until ErrorLevel = 0
	if (ErrorLevel = 0)
    {
		Sleep, 300
		Click, % ScaleX(287) ", " ScaleY(590) ", 0"
		Sleep, 300
		Click, % ScaleX(280) ", " ScaleY(595) ", 0, 2"
		Sleep, 1000
    }

	Click, % ScaleX(517) ", " ScaleY(950) ", 0"
	Gosub, WiggleMouse
	Sleep, 500
	Click, Left, 1
	
	Click, % ScaleX(1769) ", " ScaleY(686) ", 0"
	Gosub, WiggleMouse
	Sleep, 500
	Click, Left, 1
	
	Click, % ScaleX(1459) ", " ScaleY(1099) ", 0"
	Gosub, WiggleMouse
	Sleep, 500
	Click, Left, 1
	
	Click, % ScaleX(2005) ", " ScaleY(930) ", 0"
	Gosub, WiggleMouse
	Sleep, 500
	Click, Left, 1
	
	Gosub, CheckMap
	Goto, PreChum
Return

CheckMap:
	Loop, 5
	{
		CoordMode, Pixel, Window
		ImageSearch, OutX, OutY  ; Placeholder variables
		, % ScaleX(32), % ScaleY(1024)
		, % ScaleX(1654), % ScaleY(1447)
		, *10 %A_ScriptDir%\Images\%Resolution%\ChumBucket.png
		Sleep, 200
	}
	If (ErrorLevel = 0)
	{
		StartTime := A_TickCount
		Loop
		{
			CoordMode, Pixel, Window
			ImageSearch, FoundX3, FoundY3
			, % ScaleX(330), % ScaleY(823)
			, % ScaleX(2240), % ScaleY(1440)
			, *10 %A_ScriptDir%\Images\%Resolution%\StartWave.png
			;SoundBeep, 300, 300 Debug
			Sleep, 200
			
			if (ErrorLevel = 0)
			{
				Goto, PreChum
			}
			Sleep, 500
			if (A_TickCount - StartTime > 15000)
			{
				Goto, LeavePrivateServer
			}
		}
	}
Return
		
LeavePrivateServer:
    Gui, ChumGUI:Destroy
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	Sleep, 300
	Send, {Escape}
	Sleep, 500
	Send, {l}
	Sleep, 500
	Send, {Enter}
	Sleep, 3500
	Gosub, JoinPrivateServer
Return


JoinPrivateServer:
    Gui, ChumGUI:Destroy
	
	; --- Quick Check for image 2 or 3 scroll fix ---
	bIconFound := false
	
	; Check for GameIcon2.png
    Loop 5 {
        CoordMode, Pixel, Window
        ImageSearch, FoundX1, FoundY1
            , % ScaleX(0), % ScaleY(0)
            , % ScaleX(A_ScreenWidth), % ScaleY(A_ScreenHeight)
            , *10 %A_ScriptDir%\Images\%Resolution%\GameIcon2.png
        if (ErrorLevel = 0) {
            bIconFound := true
            break
        }
        Sleep, 500
    }
	
	; If GameIcon2 not found, check for GameIcon3.png
    if (!bIconFound) {
        Loop 5 {
            CoordMode, Pixel, Window
            ImageSearch, FoundX1, FoundY1
                , % ScaleX(0), % ScaleY(0)
                , % ScaleX(A_ScreenWidth), % ScaleY(A_ScreenHeight)
                , *10 %A_ScriptDir%\Images\%Resolution%\GameIcon3.png
            if (ErrorLevel = 0) {
                bIconFound := true
                break
            }
            Sleep, 500
        }
    }
	
    if (!bIconFound) {
        Gosub, DetectGame
    }
	
    Sleep, 1450
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	
	ClickStep("JoinBtn")
	Sleep, 300
	ClickStep("JoinFriends")
	Sleep, 1000
	ClickStep("Refresh")
	Sleep, 1000
    ClickStep("PrivateSrvSlot")
	Sleep, 300
	
    Loop
	{
		CoordMode, Pixel, Window
		ImageSearch, PlayX, PlayY
		, % ScaleX(196), % ScaleY(493) ;Top Left
		, % ScaleX(515), % ScaleY(799) ;Bottom Right
		, *10 %A_ScriptDir%\Images\%Resolution%\PlayButton.png
		Sleep, 300
	}
	Until ErrorLevel = 0
    Goto, GoToLevel
Return

DetectGame:

    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	Sleep, 300
	GoSub WiggleMouse
	Sleep, 300
	
    Loop 10 {
        CoordMode, Pixel, Window
        ImageSearch, FoundX1, FoundY1
            , % ScaleX(0),    % ScaleY(0)
            , % ScaleX(A_ScreenWidth), % ScaleY(A_ScreenHeight)
            , *10 %A_ScriptDir%\Images\%Resolution%\GameIcon.png
        if (ErrorLevel = 0)
            break
        Send, {WheelDown 2}
        Sleep, 500
    }

	
    if (ErrorLevel = 0) {
        Gosub, CenterImgSrchCoords1  ;centers on FoundX1/FoundY1
        
        ;Move to center coordinates
        MouseMove, %FoundX1%, %FoundY1%, 5
        ;Add wiggle movement
        Gosub, WiggleMouse
        Sleep, 500
        Click, Left, 1
        Sleep, 400
        
        ;now search for Image2
        Loop 10 {
            CoordMode, Pixel, Window
            ImageSearch, FoundX2, FoundY2
                , % ScaleX(0),    % ScaleY(0)
                , % ScaleX(A_ScreenWidth), % ScaleY(A_ScreenHeight)
                , *10 %A_ScriptDir%\Images\%Resolution%\GameIcon2.png
            if (ErrorLevel = 0)
                break
            Sleep, 200
        }
        
        if (ErrorLevel = 0) {
            Return
        }
        ;go to Image3
        Loop 10 {
            CoordMode, Pixel, Window
            ImageSearch, FoundX3, FoundY3
                , % ScaleX(0),    % ScaleY(0)
                , % ScaleX(A_ScreenWidth), % ScaleY(A_ScreenHeight)
                , *10 %A_ScriptDir%\Images\%Resolution%\GameIcon3.png
            if (ErrorLevel = 0)
                break
            Sleep, 200
        }
        if (ErrorLevel = 0)
            Return

    } else {
        ;didnt find Image1 try Image2
        Loop 5 {
            CoordMode, Pixel, Window
            ImageSearch, FoundX2, FoundY2
                , % ScaleX(0),    % ScaleY(0)
                , % ScaleX(A_ScreenWidth), % ScaleY(A_ScreenHeight)
                , *10 %A_ScriptDir%\Images\%Resolution%\GameIcon2.png
            if (ErrorLevel = 0)
                break
            Sleep, 200
        }
        if (ErrorLevel = 0)
            Return

        ;try Image3
        Loop 5 {
            CoordMode, Pixel, Window
            ImageSearch, FoundX3, FoundY3
                , % ScaleX(0),    % ScaleY(0)
                , % ScaleX(A_ScreenWidth), % ScaleY(A_ScreenHeight)
                , *10 %A_ScriptDir%\Images\%Resolution%\GameIcon3.png
            if (ErrorLevel = 0)
                break
            Sleep, 200
        }
        if (ErrorLevel = 0)
            Return
    }

    ;none found then restart Roblox
    Process, Close, RobloxPlayerBeta.exe
    Sleep, 3000
    shell := ComObjCreate("Shell.Application")
    apps  := shell.NameSpace("shell:AppsFolder")
    for item in apps.Items {
        if (item.Name = "Roblox Player") {
            item.InvokeVerb()
            break
        }
    }
    WinWait, ahk_exe RobloxPlayerBeta.exe, , 10
    Goto, JoinPrivateServer
Return

WiggleMouse:
    ;get current mousepos
    MouseGetPos, CurrentX, CurrentY
    
    ;small random movements to make the mouse more detectable
    Loop, 3
    {
        ;Random small offsets between -5 and 5 pixels
        Random, OffsetX, -5, 5
        Random, OffsetY, -5, 5
        
        ;Move slightly from current position
        MouseMove, CurrentX + OffsetX, CurrentY + OffsetY, 2
        Sleep, 50
    }
    
    ;Return to original position
    MouseMove, CurrentX, CurrentY, 2
    Sleep, 50
Return

CenterImgSrchCoords1:
    ; Calculate center coordinates based on the GameIcon.png dimensions
    ImageFile := A_ScriptDir . "\Images\" . Resolution . "\GameIcon.png"
    
    ; Create a temporary GUI to get image dimensions
    Gui, TempGui:New, +AlwaysOnTop -Caption
    Gui, TempGui:Add, Picture, vPicControl, %ImageFile%
    GuiControlGet, PicSize, TempGui:Pos, PicControl
    Gui, TempGui:Destroy
    
    ; Calculate center of the found image
    FoundX1 += PicSizeW/2
    FoundY1 += PicSizeH/2
Return

PreChum:
	WinActivate, Roblox
	WinWaitActive, Roblox
	Gosub, SetupLevelAll
	Goto, ChumMacro
Return

SetupLevelAll:
	Gui, ChumGUI:Destroy
	WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	Gosub, CheckForAutoSkip
	
	Click, % ScaleX(1472) ", " ScaleY(95) ", 0" ;5x
    Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
	
	Send, {o Down} ;Zoom out
	Sleep, 1000
	Send, {o}
	Sleep, 100
	
	Click, % ScaleX(1291) ", " ScaleY(559) ", 0" ;Camera Positioning
	Sleep, 300
	Click, % ScaleX(1300) ", " ScaleY(627) " Right, 1"
	Sleep, 400
	Click, % ScaleX(1300) ", " ScaleY(189) ", 0"
	Sleep, 400
	Click, % ScaleX(1300) ", " ScaleY(831) ", 0"
	Sleep, 400
	Click, Right, 1
	Sleep, 100
Return

CheckForAutoSkip:
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2

    Click, % ScaleX(2520) ", " ScaleY(79) ", 0"
    Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1

    Loop, 5
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, % ScaleX(768), % ScaleY(130), % ScaleX(1734), % ScaleY(513), *10 %A_ScriptDir%\Images\%Resolution%\AutoSkip.png
    }
	
    If (ErrorLevel = 0)
    {
        Sleep, 300

        Click, % ScaleX(1546) ", " ScaleY(460) ", 0"
        Gosub, WiggleMouse
		Sleep, 300
		Click, Left, 1

        Click, % ScaleX(2520) ", " ScaleY(80) ", 0"
        Gosub, WiggleMouse
		Sleep, 300
		Click, Left, 1
    }

    Sleep, 300
    Click, % ScaleX(2522) ", " ScaleY(80) ", 0"
    Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
Return

ChumMacro:
	Gui, ChumGUI:Destroy
	WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	
	Send, {2} ;Banks Down
	Sleep, 300
	Click, % ScaleX(1900) ", " ScaleY(130) ", 0"
	Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
	
	Sleep, 300
	Click, % ScaleX(1296) ", " ScaleY(1024) ", 0"
	Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
	
	Sleep, 1000
	Click, Left, 5
	Sleep, 300
	
	Send, {2} ;2nd Bank
	Sleep, 300
	Sleep, 300
	Click, % ScaleX(2022) ", " ScaleY(476) ", 0"
	Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
	
	Sleep, 4500
	Send, {1} ;Slasher Down
	Sleep, 300
	Click, % ScaleX(1350) ", " ScaleY(729) ", 0"
	Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
	
	Sleep, 3500
	Send, {5} ;Bear
	Sleep, 300
	Click, % ScaleX(999) ", " ScaleY(547) ", 0"
	Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
	
	Sleep, 2000
	Send, {4} ;Rhino
	Sleep, 300
	Click, % ScaleX(1584) ", " ScaleY(408) ", 0"
	Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
	
	Sleep, 1000
	Send, {4} ;Rhino
	Sleep, 300
	Click, % ScaleX(631) ", " ScaleY(450) ", 0"
	Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
	
Gosub, VictoryScreen
Goto, ChumMacro

VictoryScreen:
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2

    Loop
    {
        Gosub, DetectForDefeat
        CoordMode, Pixel, Window
        ImageSearch, FoundX1, FoundY1
			, % ScaleX(393), % ScaleY(9)
			, % ScaleX(2140), % ScaleY(323)
			, *10 %A_ScriptDir%\Images\%Resolution%\SweetVictory.png
        Sleep, 300
    }
	
    Until ErrorLevel = 0
	 If (ErrorLevel = 0)
    {
        Click, % ScaleX(1495) ", " ScaleY(1125) ", 0"
        Gosub, WiggleMouse
		Click, Left, 1
		Sleep, 300
    }
Return

DetectForDefeat:
    Loop, 3
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY
		, % ScaleX(278), % ScaleY(8)
        , % ScaleX(2093), % ScaleY(328)
        , *10 %A_ScriptDir%\Images\%Resolution%\Defeat.png
		Sleep, 100
		
        if (ErrorLevel = 0)
            break
    }
    If (ErrorLevel = 0)
    {
        Goto, LeavePrivateServer
    }
Return