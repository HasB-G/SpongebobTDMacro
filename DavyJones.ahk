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

;;Show menu soon as script selected
GoSub, CreateDavyGUI

;F1 can still be used to reopen menu if closed
F1::Reload  ; Restart script

CreateDavyGUI:
	Gui, SetupGUI:Destroy
	Gui, LevelGUI:Destroy
	Gui, CreateLevelGUI:Destroy
    Gui, DavyGUI:New, +AlwaysOnTop +ToolWindow -SysMenu, Davy Jones Macro
    Gui, DavyGUI:Color, F0F0F0
    Gui, DavyGUI:Font, S10 Bold, Verdana
    Gui, DavyGUI:Add, Text, x20 y15 w160 Center, Davy Jones Options:
    Gui, DavyGUI:Add, Button, gJoinPrivateServer x20 y50 w160 h30, Join Server
	Gui, DavyGUI:Add, Button, gLeavePrivateServer x20 y90 w160 h40, Leave and Join Server
    Gui, DavyGUI:Add, Button, gGoToLevel x20 y140 w160 h30, Go To Challenge
	Gui, DavyGUI:Add, Button, gCreateLevelGUI x20 y180 w160 h30, Choose Level
	Gui, DavyGUI:Add, Button, gCreateSetupGUI x20 y220 w160 h30, Set Up Menu
	Gui, DavyGUI:Add, Button, gCloseMenu x20 y260 w160 h30, Close Menu
	Gui, DavyGUI:Add, Button, gReturnMain x20 y300 w160 h30, Main Menu
    Gui, DavyGUI:Show, w200 h360, Davy Jones Macro by HasB
Return

CreateLevelGUI:
	Gui, DavyGUI:Destroy
    Gui, LevelGUI:New, +AlwaysOnTop +ToolWindow -SysMenu, Setup Level
    Gui, LevelGUI:Color, F0F0F0
    Gui, LevelGUI:Font, S10 Bold, Verdana
    Gui, LevelGUI:Add, Text, x20 y15 w160 Center, Choose Level:
    Gui, LevelGUI:Add, Button, gBoatSchool x20 y60 w160 h30, Boat School
	Gui, LevelGUI:Add, Button, gFlyingDutchman x20 y100 w160 h30, Flying Dutchman
	Gui, LevelGUI:Add, Button, gConchStreet x20 y140 w160 h30, ConchStreet
	Gui, LevelGUI:Add, Button, gPatty x20 y180 w160 h30, Patty Vault
	Gui, LevelGUI:Add, Button, gCreateDavyGUI x20 y220 w160 h30, Back
    Gui, LevelGUI:Show, w200 h280, Choose Level
Return

CreateSetupGUI:
	Gui, DavyGUI:Destroy
    Gui, SetupGUI:New, +AlwaysOnTop +ToolWindow -SysMenu, Setup Level
    Gui, SetupGUI:Color, F0F0F0
    Gui, SetupGUI:Font, S10 Bold, Verdana
    Gui, SetupGUI:Add, Text, x20 y15 w160 Center, Choose Level to setup:
    Gui, SetupGUI:Add, Button, gPreBoat x20 y60 w160 h30, Boat School
	Gui, SetupGUI:Add, Button, gPreDutchman x20 y100 w160 h30, Flying Dutchman
	Gui, SetupGUI:Add, Button, gPreConch x20 y140 w160 h30, Conch Street
	Gui, SetupGUI:Add, Button, gPrePatty x20 y180 w160 h30, Patty Vault
	Gui, SetupGUI:Add, Button, gCreateDavyGUI x20 y220 w160 h30, Back
    Gui, SetupGUI:Show, w200 h280, Setup Level
Return

CloseMenu:
	Gui, DavyGUI:Destroy
Return

ReturnMain:
    Gui, DavyGUI:Destroy
    Run, Main.ahk
    ExitApp
Return

LeavePrivateServer:
    Gui, DavyGUI:Destroy
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	Sleep, 300
	Send, {Escape}
	Sleep, 500
	Send, {l}
	Sleep, 500
	Send, {Enter}
	Sleep, 300
	Send, {Enter}
	Sleep, 3500
	Gosub, JoinPrivateServer
Return


GoToLevel:
    Gui, DavyGUI:Destroy
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	Sleep, 300
	
	Send, {w Down}
	Sleep, 4000
	Send, {w Up}
	Sleep, 300

	Send, {d Down}
	Sleep, 4000
	Send, {d Up}
	
	Send, {w Down}
	Sleep, 1000
	Send, {w Up}
	
	Send, {d Down}
	Sleep, 1600
	Send, {d Up}

	Send, {w Down}
	Send, {Space Down}
	Sleep, 600
	Send, {Space Up}
	Sleep, 1000
	Send, {w Up}
	
	Send, {d Down}
	Sleep, 600
	Send, {d Up}
	Sleep, 300
	
	Send, {w Down}
	Sleep, 700
	Send, {w Up}
	Sleep, 300
	
	Send, {d Down}
	Sleep, 400
	Send, {d Up}{w Down}
	Sleep, 900
	Send, {w Up}{d Down}
	Sleep, 350
	Send, {d Up}{w Down}
	Sleep, 1550
	Send, {w Up}
	Sleep, 7000
	
	Goto, MapHandler
Return


SetupLevelAll:
	Gui, ChumGUI:Destroy
	WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	
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

PreDutchman:
	Gui, SetupGUI:Destroy
	Gosub, SetupLevelAll
	Sleep, 300
	Send, {w Down}
	Sleep, 1000
	Send, {w Up}
	Goto, FlyingDutchman
Return

Gosub, WiggleMouse
Click, Left, 1

FlyingDutchman:
	Gui, LevelGUI:Destroy
	Gosub, StartDefeatCheckTimer  ; Start timer when level begins
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	Sleep, 300
	
	Send, {2} ;Bank Down 1st
	Sleep, 300
	MouseMove, % ScaleX(782), % ScaleY(1204), 0
	Sleep, 300
	Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
	Sleep, 300
	
	Send, {2} ;Bank Down 2nd
	Sleep, 300
	MouseMove, % ScaleX(1028), % ScaleY(1204), 0
	Sleep, 300
	Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
	
	MouseMove, % ScaleX(1302), % ScaleY(1024), 0 ;Start
	Sleep, 300
	Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 4
	
	Send, {4} ;Rhino Down
	Sleep, 10800
	MouseMove, % ScaleX(1250), % ScaleY(581), 0
	Sleep, 300
	Gosub, WiggleMouse
	Sleep, 300
	Click, Left, 1
	Sleep, 4000
	
	Send, {4} ;Rhino Down (2nd)
    Sleep, 1300  ; Wait for gold
    MouseMove, % ScaleX(1120), % ScaleY(221), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 1800
	
	Sleep, 5000  ; Upgrade banks
    Send, {f}
    Sleep, 300
    MouseMove, % ScaleX(1868), % ScaleY(561), 0 ;Upgrade 1st Bank
    Sleep, 300
    Gosub, WiggleMouse
    Sleep, 300
    Loop, 5
	{
        Click, Left, 1
        Sleep, 300
    }
	Sleep, 4000
	
	MouseMove, % ScaleX(2125), % ScaleY(561), 0 ;Upgrade 2nd Bank
    Sleep, 300
    Gosub, WiggleMouse
    Sleep, 300
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
	
	Send, {f} ;Close menu + Sea Bear down
    Sleep, 500
	Send, {5}
	
	MouseMove, % ScaleX(878), % ScaleY(172), 0 ;SeaBear Down
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 4000
	
	Send, {1} ;Slasher Down
    Sleep, 300
    MouseMove, % ScaleX(933), % ScaleY(299), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 300
	
	Send, {f}
	Sleep, 300
	
	Sleep, 10000
	
	MouseMove, % ScaleX(2373), % ScaleY(564), 0 ;Rhino Upgrade (1st)
    Sleep, 300
    Gosub, WiggleMouse
    Sleep, 300
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
	Sleep, 10000
	
	MouseMove, % ScaleX(1867), % ScaleY(945), 0 ;2nd Rhino Upgrade
    Sleep, 300
    Gosub, WiggleMouse
    Sleep, 300
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
	Sleep, 15000
	
	MouseMove, % ScaleX(2122), % ScaleY(945), 0 ;Sea Bear Upgrade
    Sleep, 300
    Gosub, WiggleMouse
    Sleep, 300
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
    Sleep, 14000
	
	MouseMove, % ScaleX(2375), % ScaleY(946), 0 ;Slasher Upgrade
    Sleep, 300
    Gosub, WiggleMouse
    Sleep, 300
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
    Sleep, 14000
	
	Send, {3} ;Richard Down (1st)
    Sleep, 300
    MouseMove, % ScaleX(810), % ScaleY(435), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 1000
	
	Send, {3} ;Richard Down (2nd)
    Sleep, 300
    MouseMove, % ScaleX(533), % ScaleY(99), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
	
    Sleep, 10000
	
	MouseMove, % ScaleX(2210), % ScaleY(780), 0 ;Scroll to Richard upgrades
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 20 
	{
        Click, WheelDown, 10
        Sleep, 10
    }
    Sleep, 5000
	
	MouseMove, % ScaleX(1997), % ScaleY(1108), 0 ;Upgrade Richard (1st)
    Sleep, 300
    Gosub, WiggleMouse
    Sleep, 300
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
	MouseMove, % ScaleX(2250), % ScaleY(1107), 0 ;Upgrade 2nd Richard
    Sleep, 300
    Gosub, WiggleMouse
    Sleep, 300
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
    Sleep, 1000
	
	Sleep, 1000 ;Garry
    Send, {6}
    Sleep, 300
    MouseMove, % ScaleX(1421), % ScaleY(198), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 2000
	
	Send, {6}
    Sleep, 300
    MouseMove, % ScaleX(729), % ScaleY(89), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 5000
	
	MouseMove, % ScaleX(2283), % ScaleY(1187), 0 ;Scroll for Garry
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 20 
	{
        Click, WheelDown, 10
        Sleep, 10
    }
    Sleep, 300
	
	MouseMove, % ScaleX(2374), % ScaleY(725), 0 ;Upgrade Garry (1st)
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
    Sleep, 1000
	
	MouseMove, % ScaleX(2124), % ScaleY(1105), 0 ;Upgrade 2nd Garry
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5
	{
        Click, Left, 1
        Sleep, 300
    }
	
	Loop, 40 
	{
        Click, WheelUp, 10
        Sleep, 10
    }
    Sleep, 300
	
	Gosub, DetectForDefeat
	Gosub, VictoryScreen
	Gosub, StopDefeatCheckTimer
	Goto, FlyingDutchman
Return

PrePatty:
	Gui, SetupGUI:Destroy
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	Gosub, SetupLevelAll
	Send, {d Down}
	Sleep, 1600
	Send, {d}{w Down}{Space Down}
	Sleep, 1200
	Send, {w}
	Sleep, 200
	Send, {Space}
	Sleep, 100
	Click, % ScaleX(1291) ", " ScaleY(844), 0 
	Sleep, 100
	Click, Right, 1
	Sleep, 400
	Click, % ScaleX(1291) ", " ScaleY(843), 0 
	Sleep, 100
	Click, % ScaleX(1500) ", " ScaleY(843), 0
	Sleep, 100
	Click, Right, 1
	Sleep, 100
	Goto, Patty
Return

Patty:
	Gui, LevelGUI:Destroy
	Gosub, StartDefeatCheckTimer
	WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	
	Sleep, 300
	Send, {2} ;Bank Down
	Sleep, 300
	
	MouseMove, % ScaleX(224), % ScaleY(1117), 0
	Sleep, 300
	Gosub, WiggleMouse
	Click, Left, 1
	Sleep, 500
	
	MouseMove, % ScaleX(1302), % ScaleY(1023), 0 ; Start level 
	Sleep, 300
	Gosub, WiggleMouse
	Loop, 5
	{
		Click
		Sleep, 200
	}

	Sleep, 5000
	Send, {3} ;Richard Down
	Sleep, 300
	MouseMove, % ScaleX(1475), % ScaleY(1002), 0
	Sleep, 300
	Gosub, WiggleMouse
	Click, Left, 1
	
	Sleep, 10000
	
	Send, {1} ;Slasher Down
	Sleep, 300
	MouseMove, % ScaleX(1023), % ScaleY(522), 0
	Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 5000
	
	Send, {5} ;Sea Bear Down
	Sleep, 300
	MouseMove, % ScaleX(899), % ScaleY(471), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
	
    Sleep, 1000
	
	Send, {4} ;Rhino Down
	Sleep, 300
	MouseMove, % ScaleX(1986), % ScaleY(304), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
	
    Sleep, 1000
	
	Send, {4} ;2nd Rhino Down
	Sleep, 300
	MouseMove, % ScaleX(660), % ScaleY(220), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
	
    Sleep, 1000
	
	Send, {f} ; Upgrade Menu
	Sleep, 200
	
	MouseMove, % ScaleX(1866), % ScaleY(563), 0 ;Upgrade Bank
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 300
	Loop, 5
	{
		Click
		Sleep, 200
	}
	
	Sleep, 7000
	
	MouseMove, % ScaleX(2121), % ScaleY(564), 0 ;Upgrade Richard
	Sleep, 300
    Gosub, WiggleMouse
    Loop, 5
	{
		Click
		Sleep, 200
	}
	
	Sleep, 18000
	
	MouseMove, % ScaleX(2373), % ScaleY(564), 0 ;Upgrade Slasher
	Sleep, 300
    Gosub, WiggleMouse
	Loop, 5
	{
		Click
		Sleep, 200
	}
   
	Sleep, 18000
	
	MouseMove, % ScaleX(1864), % ScaleY(943), 0 ;Upgrade Sea Bear
	Sleep, 300
    Gosub, WiggleMouse
	Loop, 5
	{
		Click
		Sleep, 200
	}
	
	Sleep, 18000
	
	MouseMove, % ScaleX(2120), % ScaleY(943), 0 ;Upgrade 1st Rhino
	Sleep, 300
    Gosub, WiggleMouse
	Loop, 5
	{
		Click
		Sleep, 200
	}
	
	Sleep, 5000
	
	MouseMove, % ScaleX(2375), % ScaleY(941), 0 ;Upgrade 2nd Rhino
	Sleep, 300
    Gosub, WiggleMouse
	Loop, 5
	{
		Click
		Sleep, 200
	}
	
	Send, {6} ;Garry Down
	Sleep, 300
	MouseMove, % ScaleX(1350), % ScaleY(500), 0
    Sleep, 300
    Gosub, WiggleMouse
	Sleep, 300
    Click, Left, 1
    Sleep, 300
	
	MouseMove, % ScaleX(2210), % ScaleY(780), 0
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 20 
	{
        Click, WheelDown, 10
        Sleep, 10
    }
    Sleep, 300

    MouseMove, % ScaleX(2119), % ScaleY(1105), 0
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 100
    }
	Sleep, 300
    Loop, 20 {
        Click, WheelUp, 10
        Sleep, 10
    }
	
	Gosub, DetectForDefeat
	Gosub, VictoryScreen
	Gosub, StopDefeatCheckTimer
	Goto, Patty
Return

PreConch:
	Gui, SetupGUI:Destroy
	Gosub, SetupLevelAll
	Goto, ConchStreet
Return

ConchStreet:
    Gui, LevelGUI:Destroy
    Gosub, StartDefeatCheckTimer
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	
    Sleep, 300
    Send, {2} ;Bank Down (1st)
    Sleep, 300
    MouseMove, % ScaleX(1921), % ScaleY(301), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 300

    Send, {2} ;Bank Down (2nd)
    Sleep, 300
    MouseMove, % ScaleX(1760), % ScaleY(615), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 300

    MouseMove, % ScaleX(1302), % ScaleY(1024), 0
    Sleep, 300
    Gosub, WiggleMouse
    
    Loop, 5
	{
        Click, Left, 1
        Sleep, 500
    }
    Sleep, 3500

    Send, {4} ;First Rhino
    Sleep, 300
    MouseMove, % ScaleX(1302), % ScaleY(1024), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 1300

    Send, {4} ;Second Rhino
    Sleep, 1300  ; wait for gold
    MouseMove, % ScaleX(1048), % ScaleY(847), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
	
    Sleep, 10000

    Send, {f};Upgrade banks
    Sleep, 300
    MouseMove, % ScaleX(1867), % ScaleY(567), 0 ;Upgrade 1st bank
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 100
    }

    MouseMove, % ScaleX(2122), % ScaleY(564), 0 ;Upgrade 2nd bank
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5
	{
        Click, Left, 1
        Sleep, 300
    }

    Send, {1} ;Slasher Down
    Sleep, 300
    MouseMove, % ScaleX(1024), % ScaleY(1061), 0
    Sleep, 300
    Gosub, WiggleMouse
	Click, Left, 1
	
    Sleep, 7000

    Send, {5} ;Sea Bear Down
    Sleep, 300
    MouseMove, % ScaleX(893), % ScaleY(637), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1

    MouseMove, % ScaleX(2376), % ScaleY(562), 0 ;Upgrade 1st Rhino
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 100
    }
    Sleep, 4000

    MouseMove, % ScaleX(1866), % ScaleY(945), 0 ;Upgrade 2nd Rhino
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 100
    }
	
    Sleep, 18000

    MouseMove, % ScaleX(2121), % ScaleY(940), 0 ;Upgrade Slasher
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 100
    }
	
    Sleep, 9000

    MouseMove, % ScaleX(2374), % ScaleY(944), 0 ;Upgrade Sea Bear
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 100
    }
    Sleep, 1000

    
    Send, {3} ;Richard Down
    Sleep, 300
    MouseMove, % ScaleX(1135), % ScaleY(534), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 2300

	Send, {3} ;Richard Down
    Sleep, 300
    MouseMove, % ScaleX(769), % ScaleY(795), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 600

    MouseMove, % ScaleX(2210), % ScaleY(780), 0 ;Upgrades
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 20 {
        Click, WheelDown, 10
        Sleep, 10
    }
    Sleep, 10000

    ;Upgrade Richard
    MouseMove, % ScaleX(1995), % ScaleY(1106), 0
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 100
    }

    MouseMove, % ScaleX(2248), % ScaleY(1106), 0
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 100
    }
    Sleep, 3000

    
    Send, {6} ;Garry Down & upgrades
    Sleep, 300
    MouseMove, % ScaleX(719), % ScaleY(333), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
	
    Sleep, 2000

    Send, {6}
    Sleep, 300
    MouseMove, % ScaleX(644), % ScaleY(898), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
	
    Sleep, 10000

    MouseMove, % ScaleX(2210), % ScaleY(780), 0
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 20 
	{
        Click, WheelDown, 10
        Sleep, 10
    }
    Sleep, 300

    ;Garry upgrades
    MouseMove, % ScaleX(2376), % ScaleY(724), 0
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 100
    }

    MouseMove, % ScaleX(2119), % ScaleY(1105), 0
    Sleep, 5000
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 100
    }

    Loop, 20 {
        Click, WheelUp, 10
        Sleep, 10
    }

    Gosub, DetectForDefeat
    Gosub, VictoryScreen
    Gosub, StopDefeatCheckTimer
    Goto, ConchStreet
Return


PreBoat:
	Gui, SetupGUI:Destroy
	Gosub, SetupLevelAll
	Goto, BoatSchool
Return

BoatSchool:
	Gui, LevelGUI:Destroy
	Gosub, StartDefeatCheckTimer
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
	
	Sleep, 300
	Send, {2} ;Bank Down
	Sleep, 300
	MouseMove, % ScaleX(976), % ScaleY(1138), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 200
	
	Send, {2} ;2nd Bank Down
	Sleep, 300
	MouseMove, % ScaleX(1284), % ScaleY(1135), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 300
	
	MouseMove, % ScaleX(1302), % ScaleY(1023), 0
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 200
    }
	
    Sleep, 3500
	
	Send, {4}  ; First Rhino 
	Sleep, 300
	MouseMove, % ScaleX(722), % ScaleY(692), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
	
    Sleep, 4000
	
	Send, {4}  ; Second Rhino 
	Sleep, 1300  ; Wait for gold 
	MouseMove, % ScaleX(887), % ScaleY(425), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
	
    Sleep, 6000

	Send, {5} ;Bear Down
	Sleep, 300
	MouseMove, % ScaleX(960), % ScaleY(159), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
	
    Sleep, 3000
	
	Send, {1} ;Slasher Down
	Sleep, 300
	MouseMove, % ScaleX(1044), % ScaleY(227), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
	
    Sleep, 14000
	
	Send, {f}
	Sleep, 500  ;Upgrades
	
	MouseMove, % ScaleX(1867), % ScaleY(564), 0 ;Upgrade 1st Bank
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
    Sleep, 4000
	
	MouseMove, % ScaleX(2121), % ScaleY(564), 0 ;Upgrade 2nd Bank
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
    Sleep, 8000
	
	MouseMove, % ScaleX(2375), % ScaleY(564), 0 ;Upgrade 1st Rhino
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
    Sleep, 14000
	
	MouseMove, % ScaleX(1867), % ScaleY(945), 0 ;Upgrade 2nd Rhino
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
    Sleep, 18000
	
    MouseMove, % ScaleX(2122), % ScaleY(942), 0 ;Upgrade Bear
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
	Sleep, 18000
	
	MouseMove, % ScaleX(2377), % ScaleY(946), 0 ;Upgrade Slasher
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
    Sleep, 8000
	
	Send, {3} ;Richard Down
	Sleep, 300
	MouseMove, % ScaleX(329), % ScaleY(560), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1

	Sleep, 2000
	
	Send, {3} 
	Sleep, 300
	MouseMove, % ScaleX(295), % ScaleY(127), 0 ;Richard Down 2nd
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 2 {
        Click, Left, 1
        Sleep, 300
    }
    Sleep, 1000
	
	MouseMove, % ScaleX(2210), % ScaleY(780), 0 ;Scroll to upgrades
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 20 {
        Click, WheelDown, 10
        Sleep, 10
    }
    Sleep, 18000
	
	MouseMove, % ScaleX(1995), % ScaleY(1105), 0 ;Upgrade 1st Richard
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
	Sleep, 1000
	MouseMove, % ScaleX(2249), % ScaleY(1107), 0 ;Upgrade 2nd Richard
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
    Sleep, 1000
	
	Loop, 20
	{
		Click, WheelUp, 10
		Sleep, 10
	}
	
	Sleep, 4000 
	
	Send, {6} ;Garry
	Sleep, 300
	MouseMove, % ScaleX(1345), % ScaleY(420), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1
    Sleep, 1000
	
	Send, {6} ;Garry 2nd
	Sleep, 300
	MouseMove, % ScaleX(1142), % ScaleY(72), 0
    Sleep, 300
    Gosub, WiggleMouse
    Click, Left, 1

	Sleep, 25000
	
	MouseMove, % ScaleX(2283), % ScaleY(1187), 0 ;Scroll down to upgrades
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 20 
	{
        Click, WheelDown, 10
        Sleep, 10
    }
    Sleep, 300
	
	MouseMove, % ScaleX(2377), % ScaleY(722), 0 ;Upgrade 1st Garry
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
	Sleep, 1000
	
	MouseMove, % ScaleX(2120), % ScaleY(1107), 0 ;Upgrade 2nd Garry
    Sleep, 300
    Gosub, WiggleMouse
    Loop, 5 
	{
        Click, Left, 1
        Sleep, 300
    }
	
	Loop, 40 
	{ 
        Click, WheelUp, 10
        Sleep, 10
    }
    Sleep, 300

    Gosub, DetectForDefeat
    Gosub, VictoryScreen
    Gosub, StopDefeatCheckTimer
    Goto, BoatSchool
Return

MapHandler:
    WinActivate, Roblox ahk_class WINDOWSCLIENT
    WinWaitActive, Roblox ahk_class WINDOWSCLIENT
    Loop, 5
    {
        Loop, 4
        {
            CoordMode, Pixel, Window
            ImageSearch, FoundX, FoundY
            , % ScaleX(0), % ScaleY(717)
            , % ScaleX(1902), % ScaleY(1447)
            , *10 %A_ScriptDir%\Images\%Resolution%\ConchStreet.png
            Sleep, 200
        }
        If (ErrorLevel = 0)
        {
            Sleep, 10000
            StartTime := A_TickCount
            Loop
            {
                CoordMode, Pixel, Window
                ImageSearch, FoundX3, FoundY3
                , % ScaleX(330), % ScaleY(823)
                , % ScaleX(2164), % ScaleY(1432)
                , *10 %A_ScriptDir%\Images\%Resolution%\StartWave.png
                If (ErrorLevel = 0)
                {
                    Goto, PreConch
                }
                Sleep, 500
                If (A_TickCount - StartTime > 15000)
                {
                    Goto, LeavePrivateServer
                }
            }
        }
        
        Loop, 4
        {
            CoordMode, Pixel, Window
            ImageSearch, FoundX, FoundY
            , % ScaleX(0), % ScaleY(717)
            , % ScaleX(1902), % ScaleY(1447)
            , *10 %A_ScriptDir%\Images\%Resolution%\BoatSchool.png
            Sleep, 200
        }
        If (ErrorLevel = 0)
        {
            Sleep, 10000
            StartTime := A_TickCount
            Loop
            {
                CoordMode, Pixel, Window
                ImageSearch, FoundX3, FoundY3
                , % ScaleX(330), % ScaleY(823)
                , % ScaleX(2164), % ScaleY(1432)
                , *10 %A_ScriptDir%\Images\%Resolution%\StartWave.png
                If (ErrorLevel = 0)
                {
                    Goto, PreBoat
                }
                Sleep, 500
                If (A_TickCount - StartTime > 15000)
                {
                    Goto, LeavePrivateServer
                }
            }
        }
        
        Loop, 4
        {
            CoordMode, Pixel, Window
            ImageSearch, FoundX, FoundY
            , % ScaleX(0), % ScaleY(717)
            , % ScaleX(1902), % ScaleY(1447)
            , *10 %A_ScriptDir%\Images\%Resolution%\FlyingDutchman.png
            Sleep, 200
        }
        If (ErrorLevel = 0)
        {
            Sleep, 10000
            StartTime := A_TickCount
            Loop
            {
                CoordMode, Pixel, Window
                ImageSearch, FoundX3, FoundY3
                , % ScaleX(330), % ScaleY(823)
                , % ScaleX(2164), % ScaleY(1432)
                , *10 %A_ScriptDir%\Images\%Resolution%\StartWave.png
                If (ErrorLevel = 0)
                {
                    Goto, PreDutchman
                }
                Sleep, 500
                If (A_TickCount - StartTime > 15000)
                {
                    Goto, LeavePrivateServer
                }
            }
        }
        
        Loop, 4
        {
            CoordMode, Pixel, Window
            ImageSearch, FoundX, FoundY
            , % ScaleX(0), % ScaleY(717)
            , % ScaleX(1902), % ScaleY(1447)
            , *10 %A_ScriptDir%\Images\%Resolution%\PattyVault.png
            Sleep, 200
        }
        If (ErrorLevel = 0)
        {
            Sleep, 10000
            StartTime := A_TickCount
            Loop
            {
                CoordMode, Pixel, Window
                ImageSearch, FoundX3, FoundY3
                , % ScaleX(330), % ScaleY(823)
                , % ScaleX(2164), % ScaleY(1432)
                , *10 %A_ScriptDir%\Images\%Resolution%\StartWave.png
                If (ErrorLevel = 0)
                {
                    Goto, PrePatty
                }
                Sleep, 500
                If (A_TickCount - StartTime > 15000)
                {
                    Goto, LeavePrivateServer
                }
            }
        }
    }
    Goto, LeavePrivateServer
Return

VictoryScreen:
    WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
    WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
    Loop
	{
        Gosub, DetectForDefeat
        WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
        WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
        CoordMode, Pixel, Window
        ImageSearch, FoundX1, FoundY1
        , % ScaleX(393), % ScaleY(9)
        , % ScaleX(2140), % ScaleY(323)
        , *10 %A_ScriptDir%\Images\%Resolution%\SweetVictory.png
    }
	Until ErrorLevel = 0
	If (ErrorLevel = 0)
	{
		Loop, 3
		{
            CoordMode, Pixel, Window
            ImageSearch, FoundX2, FoundY2
            , % ScaleX(414), % ScaleY(990)
            , % ScaleX(2242), % ScaleY(1413)
            , *50 %A_ScriptDir%\Images\%Resolution%\NoReplay.png
            Sleep, 500
        }
		If (ErrorLevel = 0)
		{
			Goto, LeavePrivateServer
		}
		Else
		{
			CoordMode, Pixel, Window
			ImageSearch, FoundX2, FoundY2
			, % ScaleX(443), % ScaleY(846)
			, % ScaleX(2241), % ScaleY(1447)
			, *50 %A_ScriptDir%\Images\%Resolution%\Replay.png
			Sleep, 500
			If (ErrorLevel = 0)
			{
				Click, % ScaleX(1902) ", " ScaleY(1113) ", 0"
				Gosub, WiggleMouse
				Click, Left, 1
				Sleep, 300
				Click, Left, 1
				Sleep, 1500
				
				Loop, 4
				{
					CoordMode, Pixel, Window
					ImageSearch, FoundX3, FoundY3
					, % ScaleX(330), % ScaleY(823)
					, % ScaleX(2164), % ScaleY(1432)
				    , *10 %A_ScriptDir%\Images\%Resolution%\StartWave.png
					Sleep, 250
				}
				If (ErrorLevel = 0)
				{
					Return
				}
				Else
				{
					Goto, LeavePrivateServer
				}
			}
			Else
			{
				Goto, LeavePrivateServer
			}
		}
	}
Return

DetectForDefeat:
    ;Reduce loops for quicker checks
    Loop, 3  ; Check 3 times with shorter delays
    {
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		WinWaitActive, Roblox ahk_exe RobloxPlayerBeta.exe,,2
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
        Gosub, StopDefeatCheckTimer  ;Stop timer on defeat
        Goto, LeavePrivateServer
    }
return

JoinPrivateServer:
    Gui, DavyGUI:Destroy
	
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
        Random, OffsetX, -3, 3
        Random, OffsetY, -3, 3
        
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

StartDefeatCheckTimer:
    SetTimer, DetectForDefeat, 30000  ; Check every 30 seconds
return

StopDefeatCheckTimer:
    SetTimer, DetectForDefeat, Off    ; Stop the timer
return
