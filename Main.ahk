;Made by HasB aka Nuntoohydrological aka TheeSkengdo
;This script is free
#NoEnv
SetWorkingDir, %A_ScriptDir%
SendMode, Input
#SingleInstance, Force

;Show GUI Soon as script starts 
GoSub, CreateMainGUI

;F1 to open menu if closed
F1:: GoSub, CreateMainGUI

CreateMainGUI:
    Gui, MainGUI:New, +AlwaysOnTop +ToolWindow -SysMenu, Macro Loader
    Gui, MainGUI:Color, F0F0F0
    Gui, MainGUI:Font, S10 Bold, Verdana
    Gui, MainGUI:Add, Text, x20 y15 w160 Center, Choose a Macro:
    Gui, MainGUI:Add, Button, gRunChum x20 y50 w160 h30, Chum Macro
    Gui, MainGUI:Add, Button, gRunDavy x20 y90 w160 h30, Davy Jones Macro
	Gui, MainGUI:Add, Button, gCloseMenu x20 y130 w160 h30, Close Menu
	Gui, MainGUI:Add, Button, gSettingsGUI x20 y170 w160 h30, Settings
    Gui, MainGUI:Add, Button, gExitApp x20 y210 w160 h30, Exit
    Gui, MainGUI:Show, w200 h280, Macro Loader by HasB
Return

SettingsGUI:
    Gui, SettingsGUI:New, +AlwaysOnTop +ToolWindow -SysMenu, Settings
    Gui, SettingsGUI:Add, Text,, Resolution:
    Gui, SettingsGUI:Add, DropDownList, vSelectedResolution Choose1, 1440p|1080p
    Gui, SettingsGUI:Add, Button, gSaveSettings, Save
    Gui, SettingsGUI:Show, w200 h100
return

SaveSettings:
    Gui, Submit
    IniWrite, %SelectedResolution%, settings.ini, Display, Resolution
    MsgBox, 4096, Settings, Saved settings, updated Config
return

RunChum:
    Gui, MainGUI:Destroy
    Run, ChumNightmare.ahk
    ExitApp
Return

RunDavy:
    Gui, MainGUI:Destroy
    Run, DavyJones.ahk
    ExitApp
Return

CloseMenu:
	Gui, MainGUI:Destroy
Return

ExitApp:
    ExitApp
Return

GuiClose:
    Gui, MainGUI:Destroy
ExitApp