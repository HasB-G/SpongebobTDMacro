;made by HasB aka NunTooHydrological aka TheeSkengdo
#SingleInstance Force
SendMode("Input")
SetKeyDelay(50, 30)
SetMouseDelay(50)
SetControlDelay(50)
SetWinDelay(50)
SetWorkingDir A_InitialWorkingDir

;Load saved selection and stats from file
try {
    statsFile := FileRead("info.txt")
    stats := StrSplit(statsFile, "`n")
    savedSelection := stats[1]
    
    ; Parse stats for each mode
    raidStats := StrSplit(stats[2], "/")
    davyStats := StrSplit(stats[3], "/")
    chumStats := StrSplit(stats[4], "/")
    
    raidWins := Integer(raidStats[1])
    raidLosses := Integer(raidStats[2])
    davyWins := Integer(davyStats[1])
    davyLosses := Integer(davyStats[2])
    chumWins := Integer(chumStats[1])
    chumLosses := Integer(chumStats[2])
} catch {
    ;If file does not exist create it with default values
    savedSelection := "Raid"
    raidWins := 0
    raidLosses := 0
    davyWins := 0
    davyLosses := 0
    chumWins := 0
    chumLosses := 0
    FileAppend("Raid`n0/0`n0/0`n0/0", "info.txt")
}

if (savedSelection = "DavyJones")
    defaultSelection := 2
else if (savedSelection = "ChumBucket")
    defaultSelection := 3
else
    defaultSelection := 1

;Global variables for HUDs
global raidStartTime := 0
global chumStartTime := 0
global prizeTimerDuration := 3 * 60 * 60 * 1000  ;3 hour in ms
global timerActive := false
global waitingForRun := false
global infoHUD := 0
global watermarkText := 0
global statusText := 0
global timerText := 0
global currentStatus := "Idle"

;Core/Utility Functions
WiggleMouse() {
    MouseGetPos(&currentX, &currentY)
    MouseMove currentX + 2, currentY -2
    Sleep 50
    MouseMove currentX, currentY
    Sleep 50
}

MoveAndClick(x, y) {
    MouseMove x, y
    WiggleMouse()
    Click
    Sleep 300
}

StartRoblox() {
    try {
        shell := ComObject("Shell.Application")
        apps := shell.NameSpace("shell:AppsFolder")
        for item in apps.Items {
            if (item.Name = "Roblox Player") {
                item.InvokeVerb()
                break
            }
        }
        WinWait("ahk_exe RobloxPlayerBeta.exe")
        Sleep 300
        WinMaximize("ahk_exe RobloxPlayerBeta.exe")
        Sleep 300
        return true
    } catch as err {
        MsgBox("Error starting Roblox: " err.Message)
        return false
    }
}

ActivateRoblox() {
    if WinExist("ahk_exe RobloxPlayerBeta.exe") {
        WinActivate
        WinWaitActive
        return true
    } else {
        ToolTip "Roblox is not open"
        SetTimer () => ToolTip(), -5000
        return false
    }
}

;Create GUI
MyGui := Gui("+AlwaysOnTop +Border +Theme", "Roblox Macro Menu")
MyGui.BackColor := "101010"

MyGui.SetFont("s12", "Segoe UI Semibold")
MyGui.Add("Text", "w230 Center cd6c044", "SPONGEBOB TD MACRO")
MyGui.SetFont("s8", "Consolas")
MyGui.Add("Text",  "w230 Center cffffff", "──────────────────────────")

MyGui.SetFont("s10", "Segoe UI")
MyGui.Add("Text", "w230 Center cd6c044", "Select Mode:")
MyGui.Add("Radio", "w200 vRaidSelection Group cFFA500 x20", "Raid (Nightmare)")
MyGui.Add("Radio", "w200 vDavyJonesSelection cFF1493 x20", "Challenges (Davy Jones)")
MyGui.Add("Radio", "w200 vChumBucketSelection c800080 x20", "Chum Bucket (Nightmare)")

;Set saved selection
if (savedSelection = "DavyJones")
    MyGui["DavyJonesSelection"].Value := 1
else if (savedSelection = "ChumBucket")
    MyGui["ChumBucketSelection"].Value := 1
else
    MyGui["RaidSelection"].Value := 1

MyGui["RaidSelection"].OnEvent("Click", SaveSelection)
MyGui["DavyJonesSelection"].OnEvent("Click", SaveSelection)
MyGui["ChumBucketSelection"].OnEvent("Click", SaveSelection)


MyGui.SetFont("s8", "Consolas")
MyGui.Add("Text",  "w220 Center cffffff", "──────────────────────────")

;Main Buttons with enhanced styling
MyGui.SetFont("s10", "Segoe UI")
MyGui.Add("Button", "w220 h30 vJoinServerBtn x20 y+10 cFFFFFF Background2A2A2A", "Launch Game/Join Server").OnEvent("Click", (*) => (MyGui.Hide(), JoinServer()))
MyGui.Add("Button", "w220 h30 vLeaveServerBtn x20 y+5 cFFFFFF Background2A2A2A", "Leave Server").OnEvent("Click", (*) => (MyGui.Hide(), LeaveServer()))
MyGui.Add("Button", "w220 h30 vGoToLevelBtn x20 y+5 cFFFFFF Background2A2A2A", "Go To Level").OnEvent("Click", (*) => (MyGui.Hide(), GoToLevel()))
MyGui.Add("Button", "w220 h30 vSetupBtn x20 y+5 cFFFFFF Background2A2A2A", "Setup a Level").OnEvent("Click", (*) => SetupMenu.Show())
MyGui.Add("Button", "w220 h30 vStartBtn x20 y+5 cFFFFFF Background2A2A2A", "Start a Level").OnEvent("Click", (*) => StartMenu.Show())
MyGui.Add("Button", "w220 h30 vCloseMenuBtn x20 y+5 cFFFFFF Background2A2A2A", "Close Menu").OnEvent("Click", (*) => (MyGui.Hide()))
MyGui.Add("Button", "w220 h30 vExitBtn x20 y+5 cFFFFFF Background2A2A2A", "Exit").OnEvent("Click", ExitScript)

;Add a footer
MyGui.SetFont("s8", "Consolas")
MyGui.Add("Text",  "w220 Center cffffff", "──────────────────────────")
MyGui.SetFont("s10", "Consolas")
MyGui.Add("Text", "w220 Center vCreditText", "Made by HasB")

;Setup a level Submenu
SetupMenu := Menu()
SetupMenu.Add("Setup Raid", (*) => (MyGui.Hide(), MyGui["RaidSelection"].Value := 1, PreRaid()))
SetupMenu.Add("Setup Conch Street", (*) => (MyGui.Hide(), MyGui["DavyJonesSelection"].Value := 1, PreConch()))
SetupMenu.Add("Setup Boat School", (*) => (MyGui.Hide(), MyGui["DavyJonesSelection"].Value := 1, PreBoat()))
SetupMenu.Add("Setup Flying Dutchman", (*) => (MyGui.Hide(), MyGui["DavyJonesSelection"].Value := 1, PreDutchman()))
SetupMenu.Add("Setup Patty Vault", (*) => (MyGui.Hide(), MyGui["DavyJonesSelection"].Value := 1, PrePatty()))
SetupMenu.Add("Setup Chum Bucket", (*) => (MyGui.Hide(), MyGui["ChumBucketSelection"].Value := 1, PreChum()))

;Start a level Submenu
StartMenu := Menu()
StartMenu.Add("Start Raid", (*) => (MyGui.Hide(), MyGui["RaidSelection"].Value := 1, Raid()))
StartMenu.Add("Start Conch Street", (*) => (MyGui.Hide(), MyGui["DavyJonesSelection"].Value := 1, ConchStreet()))
StartMenu.Add("Start Boat School", (*) => (MyGui.Hide(), MyGui["DavyJonesSelection"].Value := 1, BoatSchool()))
StartMenu.Add("Start Flying Dutchman", (*) => (MyGui.Hide(), MyGui["DavyJonesSelection"].Value := 1, FlyingDutchman()))
StartMenu.Add("Start Patty Vault", (*) => (MyGui.Hide(), MyGui["DavyJonesSelection"].Value := 1, PattyVault()))
StartMenu.Add("Start Chum Bucket", (*) => (MyGui.Hide(), MyGui["ChumBucketSelection"].Value := 1, ChumBucket()))

;Hotkeys
F1::ShowMenu()
F2::ExitScript()

HSVtoRGB(h, s, v) {
    h := h / 60
    i := Floor(h)
    f := h - i
    p := v * (1 - s)
    q := v * (1 - s * f)
    t := v * (1 - s * (1 - f))
    
    if (i = 0) {
        r := v, g := t, b := p
    } else if (i = 1) {
        r := q, g := v, b := p
    } else if (i = 2) {
        r := p, g := v, b := t
    } else if (i = 3) {
        r := p, g := q, b := v
    } else if (i = 4) {
        r := t, g := p, b := v
    } else {
        r := v, g := p, b := q
    }
    
    return Format("{:02X}{:02X}{:02d}", r * 255, g * 255, b * 255)
}

CreateInfoHUD() {
    global infoHUD, watermarkText, statusText, timerText, currentStatus, raidWins, raidLosses, davyWins, davyLosses, chumWins, chumLosses
    
    if !WinExist("ahk_exe RobloxPlayerBeta.exe")
        return
        
    WinGetPos(&robloxX, &robloxY, &robloxWidth, &robloxHeight, "ahk_exe RobloxPlayerBeta.exe")
    
    infoHUD := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
    infoHUD.BackColor := "000000"
    infoHUD.SetFont("s10", "Consolas")
    
    infoHUD.Add("Text", "x10 y10 c00FF00", "Controls:")
    infoHUD.Add("Text", "x85 y10 cFFFFFF", "F1: Menu")
    infoHUD.Add("Text", "x155 y10 cFFFFFF", "F2: Exit")
    
    ;Stats
    raidStats := infoHUD.Add("Text", "vRaidStats x300 y10 cFFA500", "Raids: ")
    raidStatsWins := infoHUD.Add("Text", "vRaidStatsWins x+0 y10 c00FF00", raidWins)
    raidStatsSep := infoHUD.Add("Text", "vRaidStatsSep x+0 y10 cFFFFFF", " / ")
    raidStatsLoss := infoHUD.Add("Text", "vRaidStatsLoss x+0 y10 cFF0000", raidLosses)
    
    davyStats := infoHUD.Add("Text", "vDavyStats x405 y10 cFF1493", "Davy Jones: ")
    davyStatsWins := infoHUD.Add("Text", "vDavyStatsWins x+0 y10 c00FF00", davyWins)
    davyStatsSep := infoHUD.Add("Text", "vDavyStatsSep x+0 y10 cFFFFFF", " / ")
    davyStatsLoss := infoHUD.Add("Text", "vDavyStatsLoss x+0 y10 cFF0000", davyLosses)
    
    chumStats := infoHUD.Add("Text", "vChumStats x545 y10 c800080", "Chum Bucket: ")
    chumStatsWins := infoHUD.Add("Text", "vChumStatsWins x+0 y10 c00FF00", chumWins)
    chumStatsSep := infoHUD.Add("Text", "vChumStatsSep x+0 y10 cFFFFFF", " / ")
    chumStatsLoss := infoHUD.Add("Text", "vChumStatsLoss x+0 y10 cFF0000", chumLosses)
    
    statusText := infoHUD.Add("Text", "x" (robloxWidth/2 - 150) " y10 w300 Center c00FFFF", "Status: " currentStatus)
    timerText := infoHUD.Add("Text", "x" (robloxWidth - 600) " y10 w300 Right c00FF00 Hidden", "Time until collecting prizes: ⏱ 00:00:00")
    watermarkText := infoHUD.Add("Text", "x" (robloxWidth - 200) " y10 c00FFFF", "----  HasB  ----")

    infoHUD.Show("x" robloxX " y" robloxY " w" robloxWidth " h30 NoActivate")

    SetTimer () => AnimateInfoHUD(), 50
}

AnimateTextColor(textControl, increment := 1) {
    static hue := 0
    hue := Mod(hue + increment, 360)
    color := HSVtoRGB(hue, 1, 1)
    textControl.Opt("c" color)
}

AnimateInfoHUD() {
    global infoHUD, watermarkText
    
    if !WinExist("ahk_exe RobloxPlayerBeta.exe")
        return
        
    WinGetPos(&robloxX, &robloxY, &robloxWidth, &robloxHeight, "ahk_exe RobloxPlayerBeta.exe")
    
    infoHUD.Move(robloxX, robloxY, robloxWidth)
    AnimateTextColor(watermarkText)
}

UpdateStatus(newStatus) {
    global currentStatus, statusText, infoHUD
    
    if (!infoHUD) {
        CreateInfoHUD()
        return
    }
    
    currentStatus := newStatus
    try {
        statusText.Value := "Status: " newStatus
    } catch as err {
        CreateInfoHUD()
        statusText.Value := "Status: " newStatus
    }
}

UpdatePrizeCountdown() {
    global raidStartTime, chumStartTime, prizeTimerDuration, timerActive, timerText, waitingForRun, infoHUD
    
    if (!timerActive || (raidStartTime = 0 && chumStartTime = 0)) {
        timerText.Opt("+Hidden")
        return
    }
    
    timerText.Opt("-Hidden")
 
    startTime := raidStartTime != 0 ? raidStartTime : chumStartTime
    elapsed := A_TickCount - startTime
    remaining := prizeTimerDuration - elapsed
    
    if (remaining <= 0) {
        if (!waitingForRun) {
            waitingForRun := true
            timerText.Value := "Waiting for run to end..."
            timerText.Opt("cFF0000")
        }
        return
    }
    
    hours := Floor(remaining / (60 * 60 * 1000))
    minutes := Floor(Mod(remaining, (60 * 60 * 1000)) / (60 * 1000))
    seconds := Floor(Mod(remaining, (60 * 1000)) / 1000)
    
    if (waitingForRun) {
        timerText.Value := "Waiting for run to end..."
    } else {
        timerText.Value := Format("Time until collecting prizes: ⏱ {1:02d}:{2:02d}:{3:02d}", hours, minutes, seconds)
    }
}

ShowMenu() {
    Reload
}

HideMenu() {
    MyGui.Hide()
}

;Server/Level Navigation
JoinServer() {
    if !WinExist("ahk_exe RobloxPlayerBeta.exe") {
        ToolTip "Launching Roblox..."
        SetTimer () => ToolTip(), -5000
        StartRoblox()
        Sleep 1000
    }
    
    if !ActivateRoblox()
        return

    ;Create info HUD if it does not exist
    if (!infoHUD)
        CreateInfoHUD()
    
    UpdateStatus("Joining Server")
    
    Sleep 300

    loop 20 {
        Send "{Escape}"
        Sleep 300
    }

    Sleep 200
    Send "/"
    Sleep 600
    Send "Spongebob Tower Defense"
    Sleep 600
    Send "{Enter}"
    Sleep 1600

    ;Click on the game
    MoveAndClick(330, 430)
    Sleep 2500
    
    ; Search for friends.png for 20 seconds
    startTime := A_TickCount
    while (A_TickCount - startTime < 20000) {
        result := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*30 " A_ScriptDir "\Images\friends.png")
        if (result) {
            MoveAndClick(FoundX + 18, FoundY + 18)
            Sleep 1000
            break
        }
        Sleep 100
    }
    
    if (!result) {
        JoinServer()
        return
    }

    ;Search for joinfriends.png
    startTime := A_TickCount
    while (A_TickCount - startTime < 20000) {
        result := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*30 " A_ScriptDir "\Images\joinfriends.png")
        if (result) {
            MoveAndClick(FoundX + 75, FoundY + 18)
            Sleep 1000
            break
        }
        Sleep 100
    }

    if (!result) {
        JoinServer()
        return
    }

    Sleep 1000

    ;Refresh servers
    MoveAndClick(1385, 100)
    Sleep 1400

    ;Join server
    MoveAndClick(581, 455)

    found := false
    attempts := 0
    maxAttempts := 30

    loop {
        result := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*10 " A_ScriptDir "\Images\playbutton.png")

        if (result) {
            found := true
            break
        }

        attempts++
        if (attempts >= maxAttempts) {
            break
        }

        Sleep 1000
    }

    if (found) {
        ;Collect prizes before continuing
        CollectPrizes()
        
        if (MyGui["RaidSelection"].Value) {  ;Raid selected
            GoToRaid()
        } else if (MyGui["ChumBucketSelection"].Value) {  ;Chum Bucket selected
            GoToChum()
        } else {  ;Davy Jones selected
            GoToDavyJones()
        }
    } else {
        LeaveServer()
        return
    }
}

LeaveServer() {
    UpdateStatus("Leaving Server")
    if !ActivateRoblox()
        return

    Sleep 300
    Send "{Escape}"
    Sleep 500
    Send "{l}"
    Sleep 500
    Send "{Enter}"
    Sleep 1000
    JoinServer()
}

GoToLevel() {
    if !ActivateRoblox()
        return

    if (!MyGui["RaidSelection"].Value && !MyGui["DavyJonesSelection"].Value && !MyGui["ChumBucketSelection"].Value) {
        MsgBox("Please select a mode first!")
        ShowMenu()
        return
    }

    if (MyGui["RaidSelection"].Value) {
        GoToRaid()
    } else if (MyGui["ChumBucketSelection"].Value) {
        GoToChum()
    } else {
        GoToDavyJones()
    }
}

GoToRaid() {
    UpdateStatus("Going to Raid")
    if !ActivateRoblox()
        return

    ;Teleport to summoning
    MoveAndClick(198, 535)
    Sleep 500

    Send "{s down}"
    Sleep 4800
    Send "{s up}"
    Sleep 300

    Send "{left down}"
    Sleep 950
    Send "{left up}"

    Send "{w down}"
    Sleep 6150
    Send "{w up}"
    Sleep 300

    Send "{Right down}"
    Sleep 555
    Send "{Right up}"

    Send "{w down}"
    Sleep 1100
    Send "{w up}"
    Sleep 300

    MapHandler()
}

GoToDavyJones() {
    UpdateStatus("Going to Davy Jones")
    if !ActivateRoblox()
        return

    ;Teleport to summoning
    MoveAndClick(198, 535)
    Sleep 500

    Send "{s down}"
    Sleep 5100
    Send "{s up}"
    Sleep 300

    Send "{right down}"
    Sleep 500
    Send "{right up}"

    Send "{w down}"
    Sleep 4250
    Send "{w up}"
    Sleep 300

    Send "{a down}"
    Sleep 1000
    Send "{a up}"
    Sleep 300

    Send "{w down}"
    Sleep 2000
    Send "{w up}"
    Sleep 300

    Send "{left down}"
    Sleep 545
    Send "{left up}"
    Sleep 300

    Send "{w down}"
    Send "{Space down}"
    Sleep 500
    Send "{Space up}"
    Sleep 4000
    Send "{w up}"
    Sleep 300

    MapHandler()
}

GoToChum() {
    UpdateStatus("Going to Chum Bucket")
    if !ActivateRoblox()
        return

    ;Teleport to play area
    MoveAndClick(202, 408)
    Sleep 1000

    ;Click chum bucket
    MoveAndClick(316, 674)
    
    ;Click on nightmare
    MoveAndClick(1310, 484)

    ;Click on ready
    MoveAndClick(1086, 802)

    ;Click on start
    MoveAndClick(1506, 652)

    MapHandler()
}

;Raid Functions
PreRaid() {
    UpdateStatus("Setting up Raid")
    if !ActivateRoblox()
        return

    SetupLevelAll()

    Send "{w down}"
    Sleep 1100
    Send "{w up}"

    Send "{a down}"
    Sleep 500
    Send "{a up}"
    Sleep 300

    Raid()
}

Raid() {
    UpdateStatus("Running Raid")
    global raidStartTime, prizeTimerDuration, timerActive, timerText, waitingForRun
    
    if !ActivateRoblox()
        return

    ;Initialize timer only if it hasnt been started
    if (raidStartTime = 0) {
        raidStartTime := A_TickCount
        timerActive := 1
        waitingForRun := 0
        timerText.Opt("+Hidden")  ;Show the timer by removing Hidden option
        SetTimer(UpdatePrizeCountdown, 1000)  ;Update every second
        UpdatePrizeCountdown()  ;Initial display
    }

    ;Bank 1 down
    Send "{2}" 
    Sleep 300
    MoveAndClick(1335, 712)
    Sleep 300

    ;Bank 2 down    
    Send "{2}"
    Sleep 300
    MoveAndClick(1192, 823)
    Sleep 300

    StartWave() 

    loop 5 {
        Click
        Sleep 300
    }

    Sleep 8000

    ;Rhino 1 down
    Send "{4}"
    Sleep 300
    MoveAndClick(830, 35)

    Sleep 5000

    ;Rhino 2 down
    Send "{4}"
    Sleep 300
    MoveAndClick(1506, 509)
    
    Sleep 32000

    ;Slasher down
    Send "{1}"
    Sleep 300
    MoveAndClick(456, 132)
    Sleep 300

    Send "{f}"
    Sleep 18000
    
    ;Upgrade Bank 1
    MouseMove 1405, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 17000

    ;Upgrade Bank 2
    MouseMove 1590, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 15000

    ;Upgrade Rhino 1
    MouseMove 1775, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 5000

    ;Upgrade Rhino 2
    MouseMove 1495, 670
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Send "{f}"
    Sleep 14000

    ;Dennis down
    Send "{3}"
    Sleep 300
    MoveAndClick(946, 587)
    
    Sleep 300
    ;Worm down
    Send "{5}"
    Sleep 300
    MoveAndClick(1348, 441)
    
    Sleep 300

    ;Gary 1 down
    Send "{6}"
    Sleep 300
    MoveAndClick(813, 280)

    Sleep 300

    ;Gary 2 down
    Send "{6}"
    Sleep 300
    MoveAndClick(372, 169)

    Sleep 10000

    Send "{f}"
    Sleep 15000

    ;Upgrade Slasher
    MouseMove 1590, 670
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 65000

    ;Upgrade Dennis
    MouseMove 1775, 670
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    MouseMove 1650, 460
    WiggleMouse()
    loop 10 {   
        Send "{WheelDown}"
        Sleep 100
    }

    Sleep 35000 

    ;Upgrade Worm
    MouseMove 1405, 785
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 60000

    ;Upgrade Gary 1
    MouseMove 1590, 785
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 25000

    ;Upgrade Gary 2
    MouseMove 1775, 785
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    CheckResult()
    Sleep 300

    ;If timer finished leave server after victory
    if (waitingForRun) {
        raidStartTime := 0  ;Reset the timer
        timerActive := false
        SetTimer UpdatePrizeCountdown, 0  ;Stop the timer
        timerText.Opt("+Hidden")  ;Hide the timer text
        waitingForRun := false  ;Reset the waiting flag
        LeaveServer()
        return
    }

    Raid()
}

;Davy Jones Functions
PreConch() {
    UpdateStatus("Setting up Conch Street")
    if !ActivateRoblox()
        return

    SetupLevelAll()
    ConchStreet()
}

ConchStreet() {
    UpdateStatus("Running Conch Street")
    if !ActivateRoblox()
        return

    ;Bank 1 down
    Send "{2}" 
    Sleep 300
    MoveAndClick(1507, 179)
    Sleep 300

    ;Bank 2 down    
    Send "{2}"
    Sleep 300
    MoveAndClick(1306, 418)
    Sleep 300

    StartWave()

    loop 5 {
        Click
        Sleep 300
    }

    Sleep 4000

    ;Rhino 1 down
    Send "{4}"
    Sleep 300
    MoveAndClick(988, 746)

    Sleep 5000
    
    ;Rhino 2 down
    Send "{4}"
    Sleep 300
    MoveAndClick(807, 592)

    Sleep 10000

    ;Slasher down
    Send "{1}"
    Sleep 300
    MoveAndClick(596, 571)

    Sleep 1000

    ;Worm down
    Send "{5}"
    Sleep 300
    MoveAndClick(645, 416)
    Sleep 300

    Sleep 5000

    Send "{f}"
    Sleep 300

    ;Upgrade Bank 1
    MouseMove 1405, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 3000

    ;Upgrade Bank 2
    MouseMove 1590, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    ;Upgrade Rhino 1
    MouseMove 1775, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    ;Upgrade Rhino 2
    MouseMove 1404, 668
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 20000

    ;Upgrade Slasher
    MouseMove 1590, 668
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 20000

    ;Upgrade Worm
    MouseMove 1777, 668
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    CollectPrizes()
    CheckResult()
    Sleep 300
    ConchStreet()
}

PreBoat() {
    UpdateStatus("Setting up Boat School")
    if !ActivateRoblox()
        return

    SetupLevelAll()
    BoatSchool()
}

BoatSchool() {
    UpdateStatus("Running Boat School")
    if !ActivateRoblox()
        return

    ;Bank 1 down
    Send "{2}" 
    Sleep 300
    MoveAndClick(966, 632)
    Sleep 300

    ;Bank 2 down
    Send "{2}"
    Sleep 300
    MoveAndClick(700, 632)
    Sleep 300

    StartWave()

    loop 5 {
        Click
        Sleep 300
    }

    Sleep 4000

    ;Rhino 1 down
    Send "{4}"
    Sleep 300
    MoveAndClick(683, 310)

    Sleep 5000

    ;Rhino 2 down
    Send "{4}"
    Sleep 300
    MoveAndClick(507, 474)

    Sleep 10000

    ;Slasher down
    Send "{1}"
    Sleep 300
    MoveAndClick(790, 47)

    Sleep 14000

    Send "{f}"
    Sleep 300

    ;Upgrade Bank 1
    MouseMove 1405, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    ;Upgrade Bank 2
    MouseMove 1590, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    ;Upgrade Rhino 1
    MouseMove 1775, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    ;Upgrade Rhino 2
    MouseMove 1495, 670
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 34000

    ;Upgrade Slasher
    MouseMove 1683, 669
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    ;Worm down
    Send "{5}"
    Sleep 300
    MoveAndClick(694, 39)

    Sleep 31000

    ;Upgrade Worm
    MouseMove 1777, 668
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    CollectPrizes()
    CheckResult()
    Sleep 300
    BoatSchool()
}

PreDutchman() {
    UpdateStatus("Setting up Flying Dutchman")
    if !ActivateRoblox()
        return

    SetupLevelAll()

    Send "{w down}"
    Sleep 1000  
    Send "{w up}"

    FlyingDutchman()
}

FlyingDutchman() {
    UpdateStatus("Running Flying Dutchman")
    if !ActivateRoblox()
        return

    ;Bank 1 down
    Send "{2}" 
    Sleep 300
    MoveAndClick(1279, 386)
    Sleep 300

    ;Bank 2 down
    Send "{2}"
    Sleep 300
    MoveAndClick(1094, 386)
    Sleep 300

    StartWave()

    loop 5 {
        Click
        Sleep 300
    }

    Sleep 9000

    ;Rhino 1 down
    Send "{4}"
    Sleep 300
    MoveAndClick(886, 386)

    Sleep 5000

    ;Rhino 2 down
    Send "{4}"
    Sleep 300
    MoveAndClick(886, 182)

    Sleep 10000

    ;Slasher down
    Send "{1}"
    Sleep 300
    MoveAndClick(650, 24)

    Sleep 14000

    Send "{f}"
    Sleep 300

    ;Upgrade Bank 1
    MouseMove 1405, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    ;Upgrade Bank 2
    MouseMove 1590, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    ;Upgrade Rhino 1
    MouseMove 1775, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    ;Upgrade Rhino 2
    MouseMove 1495, 670
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 34000

    ;Upgrade Slasher
    MouseMove 1683, 669
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    ;Worm down
    Send "{5}"
    Sleep 300
    MoveAndClick(654, 109)

    Sleep 28000

    ;Upgrade Worm
    MouseMove 1777, 668
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    CollectPrizes()
    CheckResult()
    Sleep 300
    FlyingDutchman()
}

PrePatty() {
    UpdateStatus("Setting up Patty Vault")
    if !ActivateRoblox()
        return

    SetupLevelAll()
    PattyVault()
}

PattyVault() {
    UpdateStatus("Running Patty Vault")
    if !ActivateRoblox()
        return

    ;Bank 1 down
    Send "{2}"
    Sleep 300
    MoveAndClick(870, 1000)
    Sleep 300

    StartWave()

    loop 5 {
        Click
        Sleep 300
    }

    Sleep 8300

    ;Rhino 1 down
    Send "{4}"
    Sleep 300
    MoveAndClick(356, 299)

    Sleep 7000

    ;Slasher down
    Send "{1}"
    Sleep 300
    MoveAndClick(923, 296)

    Sleep 6000
    
    ;Worm down
    Send "{5}"
    Sleep 300
    MoveAndClick(835, 74)

    Sleep 10000

    Send "{f}"
    Sleep 300

    ;Upgrade Bank 1
    MouseMove 1405, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 10000

    ;Upgrade Rhino
    MouseMove 1590, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 28000

    ;Upgrade Slasher
    MouseMove 1776, 387
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 20000

    ;Upgrade Worm
    MouseMove 1590, 668
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    CollectPrizes()
    CheckResult()
    Sleep 300
    PattyVault()
}

;Chum Bucket Functions
PreChum() {
    UpdateStatus("Setting up Chum Bucket")
    if !ActivateRoblox()
        return

    SetupLevelAll()
    ChumBucket()
}

ChumBucket() {
    UpdateStatus("Running Chum Bucket")
    global chumStartTime, prizeTimerDuration, timerActive, timerText, waitingForRun
    
    if !ActivateRoblox()
        return


    if (chumStartTime = 0) {
        chumStartTime := A_TickCount
        timerActive := 1
        waitingForRun := 0
        timerText.Opt("+Hidden") 
        SetTimer(UpdatePrizeCountdown, 1000)
        UpdatePrizeCountdown()
    }

    ;Bank 1 down
    Send "{2}"
    Sleep 300
    MoveAndClick(403, 154)
    Sleep 300

    StartWave()

    loop 5 {
        Click
        Sleep 300
    }

    Sleep 1000

    ;Bank 2 down
    Send "{2}"
    Sleep 300
    MoveAndClick(577, 326)

    Sleep 4000

    ;Rhino 1 down
    Send "{4}"
    Sleep 300
    MoveAndClick(1158, 528)

    Sleep 6000

    ;Slasher down
    Send "{1}"
    Sleep 300
    MoveAndClick(789, 387)

    Sleep 5000

    ;Worm down
    Send "{5}"
    Sleep 300
    MoveAndClick(983, 180)

    Send "{f}"
    Sleep 300

    ;Upgrade Bank 1
    MouseMove 1405, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 5000

    ;Upgrade Bank 2
    MouseMove 1590, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 8000

    ;Upgrade Rhino 1
    MouseMove 1775, 390
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 13000

    ;Upgrade Slasher
    MouseMove 1495, 665
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    Sleep 20000

    ;Upgrade Worm
    MouseMove 1682, 665
    WiggleMouse()
    loop 5 {
        Click
        Sleep 200
    }

    CheckResult()
    Sleep 300

    if (waitingForRun) {
        chumStartTime := 0 
        timerActive := false
        SetTimer UpdatePrizeCountdown, 0
        timerText.Opt("+Hidden")
        waitingForRun := false
        LeaveServer()
        return
    }

    ChumBucket()
}

;Core Game Functions
CollectPrizes() {
    UpdateStatus("Collecting Prizes")
    if !ActivateRoblox()
        return

    ;Click on prizes area
    MoveAndClick(72, 532)
    Sleep 2500

    loop {
        ;Try each open image 5 times
        foundPrize := false
        loop 5 {
            result := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_ScriptDir "\Images\open.png")
            if (!result)
                result := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_ScriptDir "\Images\open2.png")
            if (!result)
                result := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_ScriptDir "\Images\open3.png")

            if (result) {
                foundPrize := true
                break
            }
            Sleep 200
        }

        if (foundPrize) {
            ;Click above the found image
            MoveAndClick(FoundX, FoundY - 10)
            Sleep 300

            loop 5 {
                Click
                Sleep 200
            }

            ;Wait for animation
            Sleep 3000  

            ;Click to close prize
            Click
            Sleep 2000

            ;Check for more prizes
            loop 5 {
                result := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_ScriptDir "\Images\open.png")
                if (!result)
                    result := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_ScriptDir "\Images\open2.png")
                if (!result)
                    result := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_ScriptDir "\Images\open3.png")

                if (result)
                    break
                Sleep 200
            }

            if (!result) {
                ;No more prizes click out
                MoveAndClick(72, 532)
                return
            }
        } else {
            ;Image not found click out and finish
            MoveAndClick(72, 532)
            return
        }
        Sleep 1000
    }
}

StartWave() {
    if !ActivateRoblox()
        return

    MoveAndClick(960, 730)
    Sleep 300

    ;Wait for start wave button to disappear
    loop {
        result := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*10 " A_ScriptDir "\Images\startwave.png")
        if (!result)
            break
        Sleep 1000
    }
}

CheckResult() {
    UpdateStatus("Checking Result")
    if !ActivateRoblox()
        return

    loop {
        ;Check for defeat
        defeatResult := ImageSearch(&defX, &defY, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir "\Images\defeat.png")
        if (defeatResult) {
            UpdateStats(false)  ;Record loss
            LeaveServer()
            return
        }

        ;Check for victory
        victoryResult := ImageSearch(&vicX, &vicY, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir "\Images\victory.png")
        if (victoryResult) {
            UpdateStats(true)  ;Record win
            if (MyGui["ChumBucketSelection"].Value) {
                MoveAndClick(1113, 793)  ;Chum Bucket victory click
            } else {
                MoveAndClick(1415, 790)  ;Normal victory click
            }
            
            ;Check if victory for 5 seconds
            loop 5 {
                Sleep 1000
                stillVictory := ImageSearch(&vicX, &vicY, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir "\Images\victory.png")
                if (!stillVictory)
                    return
            }
            LeaveServer()
            return
        }

        Sleep 1000
    }
}

MapHandler() {
    UpdateStatus("Checking Map")
    if !ActivateRoblox()
        return

    if (MyGui["RaidSelection"].Value) {
        found := false
        startTime := A_TickCount
        while (A_TickCount - startTime < 20000) {
            result := ImageSearch(&FoundMapX, &FoundMapY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*10 " A_ScriptDir "\Images\middleAges.png")
            if (result) {
                found := true
                break
            }
            Sleep 1000
        }

        if (found) {
            PreRaid()
        } else {
            GoToLevel()
            return
        }
    } else if (MyGui["ChumBucketSelection"].Value) {
        found := false
        startTime := A_TickCount
        while (A_TickCount - startTime < 20000) {
            result := ImageSearch(&FoundMapX, &FoundMapY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*10 " A_ScriptDir "\Images\chumBucket.png")
            if (result) {
                PreChum()
                return
            }
            Sleep 1000
        }
        GoToLevel()
        return
    } else if (MyGui["DavyJonesSelection"].Value) {
        found := false
        startTime := A_TickCount
        while (A_TickCount - startTime < 20000) {
            ;Check for Conch Street
            result := ImageSearch(&FoundMapX, &FoundMapY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*10 " A_ScriptDir "\Images\conchStreet.png")
            if (result) {
                PreConch()
                return
            }

            ;Check for Patty Vault
            result := ImageSearch(&FoundMapX, &FoundMapY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*10 " A_ScriptDir "\Images\pattyVault.png")
            if (result) {
                PrePatty()
                return
            }

            ;Check for Flying Dutchman
            result := ImageSearch(&FoundMapX, &FoundMapY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*10 " A_ScriptDir "\Images\flyingDutchman.png")
            if (result) {
                PreDutchman()
                return
            }

            ;Check for Boat School
            result := ImageSearch(&FoundMapX, &FoundMapY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*10 " A_ScriptDir "\Images\boatSchool.png")
            if (result) {
                PreBoat()
                return
            }

            Sleep 1000
        }

        ToolTip "No map found after 20 seconds! Going back to level selection..."
        SetTimer () => ToolTip(), -3000
        GoToLevel()
        return
    } else {
        ;Should never happen
        MsgBox("Invalid mode selection!")
        ShowMenu()
    }
}

SetupLevelAll() {
    if !ActivateRoblox()
        return

    Sleep 300

    found := false
    attempts := 0
    maxAttempts := 30

    loop {
        result := ImageSearch(&FoundMapX, &FoundMapY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*10 " A_ScriptDir "\Images\startwave.png")

        if (result) {
            found := true
            break
        }

        attempts++
        if (attempts >= maxAttempts) {
            break
        }

        Sleep 1000
    }

    if (found) {
        MoveAndClick(1095, 40)
        Sleep 300

        Send "{o down}"
        Sleep 1000
        Send "{o up}"
        Sleep 300

        MouseMove 960, 540
        WiggleMouse()
        Click "Right"
        Sleep 300
        MouseMove 960, 800
        Sleep 300
        Click "Right"
    } else {
        LeaveServer()
        return
    }
}

UpdateStats(isWin) {
    global raidWins, raidLosses, davyWins, davyLosses, chumWins, chumLosses, infoHUD
    
    if (MyGui["RaidSelection"].Value) {
        if (isWin)
            raidWins++
        else
            raidLosses++
    } else if (MyGui["DavyJonesSelection"].Value) {
        if (isWin)
            davyWins++
        else
            davyLosses++
    } else if (MyGui["ChumBucketSelection"].Value) {
        if (isWin)
            chumWins++
        else
            chumLosses++
    }
    
    ; Save updated stats
    if (MyGui["DavyJonesSelection"].Value)
        selection := "DavyJones"
    else if (MyGui["ChumBucketSelection"].Value)
        selection := "ChumBucket"
    else
        selection := "Raid"
        
    FileDelete("info.txt")
    FileAppend(selection "`n" raidWins "/" raidLosses "`n" davyWins "/" davyLosses "`n" chumWins "/" chumLosses, "info.txt")
    
    ; Update HUD stats with colors
    if (infoHUD) {
        infoHUD["RaidStatsWins"].Value := raidWins
        infoHUD["RaidStatsLoss"].Value := raidLosses
        infoHUD["DavyStatsWins"].Value := davyWins
        infoHUD["DavyStatsLoss"].Value := davyLosses
        infoHUD["ChumStatsWins"].Value := chumWins
        infoHUD["ChumStatsLoss"].Value := chumLosses
    }
}

ExitScript(*) {
    if (infoHUD)
        infoHUD.Destroy()
    ExitApp
}

if WinExist("ahk_exe RobloxPlayerBeta.exe")
    CreateInfoHUD()

;Show menu on script start
if WinExist("ahk_exe RobloxPlayerBeta.exe") {
    WinGetPos(&robloxX, &robloxY, &robloxWidth, &robloxHeight, "ahk_exe RobloxPlayerBeta.exe")
    MyGui.Show("x" (robloxX + robloxWidth/2 - 120) " y" (robloxY + robloxHeight/2 - 200) " w260 h520")
} else {
    MyGui.Show("w260 h520 Center")
}

SaveSelection(*) {
    if (MyGui["DavyJonesSelection"].Value)
        selection := "DavyJones"
    else if (MyGui["ChumBucketSelection"].Value)
        selection := "ChumBucket"
    else
        selection := "Raid"
        
    FileDelete("info.txt")
    FileAppend(selection "`n" raidWins "/" raidLosses "`n" davyWins "/" davyLosses "`n" chumWins "/" chumLosses, "info.txt")
}

UpdateCreditColor() {
    AnimateTextColor(MyGui["CreditText"])
}

SetTimer(UpdateCreditColor, 50)

return