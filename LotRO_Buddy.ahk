#NoEnv
SetWorkingDir %A_ScriptDir%
SetWinDelay, 0
SetBatchLines, -1
Coordmode, Mouse, Client
#SingleInstance Force
#Include classMemory.ahk        ; https://github.com/Kalamity/classMemory
OnExit("Cleanup")
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x202, "WM_LBUTTONUP")

if !A_IsAdmin {
    Run *RunAs "%A_ScriptFullPath%"
    exitapp
}
if (_ClassMemory.__Class != "_ClassMemory") {
    MsgBox, 4096,, class memory not correctly installed. 
    ExitApp
}

if !(FileExist("settings.ini"))
    FileAppend,, settings.ini
if !(FileExist("settings.ini"))
    FileAppend,, settings.ini

process, wait, lotroclient64.exe
SetTimer, CheckGameProcess, 1000

mem := new _ClassMemory("ahk_exe lotroclient64.exe",, hProcessCopy)
if !isObject(mem) 
    {
    if (hProcessCopy = 0)
        MsgBox, 4096,, The program isn't running (not found) or you passed an incorrect program identifier parameter. 
    else if (hProcessCopy = "")
        MsgBox, 4096, OpenProcess failed, If the target process has admin rights, then the script also needs to be ran as admin. _ClassMemory.setSeDebugPrivilege() may also be required. Consult A_LastError for more information.
    ExitApp
    }
moduleBase := mem.getModuleBaseAddress("lotroclient64.exe")

Progress, b w200 FS8,`n, LotRO Buddy,
Progress, 10
Progress,, Game Client found.
Loop
    {
    If (A_Index > 1)
        Sleep 2000
    aPattern := [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, "?", "?", 0x00, 0x00, 0x00, 0x00, "?", "?", "?", "?", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70, 0xC1, 0x00, 0x00, 0xC0, 0x40]
    FoV_address := mem.processPatternScan(,, aPattern*)
    Progress, % 5 + A_Index
    Progress,,FoV %A_Index%/10
    If (A_Index >= 10) {
        Progress, Off
        Gui, +OwnDialogs -Caption +LastFound +ToolWindow +AlwaysOnTop
        Gui, Add, Text, , Pattern not found or error: %address% `nPlease open a new issue on GitHub.com
        Gui Add, Button, w90 gOpenGitHub, Open GitHub
        Gui Add, Button, w90 x+10 gCloseGui, Close
        Gui, Show
        Pause
    }
    }until (FoV_address>0)
FoV_AddressBase := FoV_address + 16

Progress, 20
GetBaseAddress()

Progress, 30
Progress,,Waiting for character to join world.

Loop {
    ox:=mem.read(FoV_AddressBase + 0xC8, "UFloat")
    oy:=mem.read(FoV_AddressBase + 0xCC, "UFloat")
    oz:=mem.read(FoV_AddressBase + 0xD0, "UFloat")
    ClientRunTime1:=mem.read(FoV_AddressBase + 0x70, "Double")
    ClientRunTime2:=mem.read(FoV_AddressBase + 0x140, "Double")
    RegionNumber1 := mem.read(AddressBase + moduleBase + 0x40EC, "UChar")
    Sleep 1000
}until ((ox!="" && oy!="" && oz!="") && (ox!=0 || oy!=0 || oz!=0) && RegionNumber1!=0 && ClientRunTime1=ClientRunTime2)



Loop{
    Progress,,Coordinates %A_Index%/10`nDo not move Character or Camera.
    Progress, % 40 + A_Index
    Address_WriteableCoords:=Get_Address_WriteableCoords(mem,FoV_AddressBase)
}until (Address_WriteableCoords>0 || A_Index>=10)

Loop{
    Progress,,Server %A_Index%/10`nDo not move Character or Camera.
    Progress, % 55 + A_Index
    CurrentServer_AddressBase:=Get_CurrentServer_address(mem)
}until (CurrentServer_AddressBase>0 || A_Index>=10)

Loop{
    Progress,,Instance %A_Index%/10`nDo not move Character or Camera.
    Progress, % 70 + A_Index
    InstanceID_addressBase:=Get_InstanceID_address(mem,AddressBase,moduleBase)
}until (InstanceID_addressBase>0 || A_Index>=10)



Progress, 100
Sleep 500
Progress, Off
gosub, Initialize
CreateGui()
ScriptStatus:=1
Return


$Pause::
if (WinExist("ahk_id " LotRO_Buddy_Hwnd))
    Gui, Hide
else
    Gui, Show
Return

#IfWinActive ahk_exe lotroclient64.exe

ButtonSave:
    Gui, Submit
    If (SettingsName="")
        Return
    CheckValuesInMemory(1)
    ReformatINI("settings.ini")
    If (notFoundCount > 0) {
        MsgBox, 4160, Error, % notFoundCount " out of " totalValues " values could not be found / are incorrect and will not be saved.`n`nThe following values could not be found:`n" RegExReplace(LTrim(valuesNotFound, "`n"), "_", " ")"`n`nYou can either close and continue without the missing values or open GitHub to report the issue."
    }
    UpdatePresetList()
    GuiControl,, SettingsName,
    Gui, Show
return

ButtonLoad:
    Gui, Submit, NoHide
    If (MyDropdown="")
        Return
    CheckValuesInMemory(0)
    WriteValuesToMemory()
    Gui, Show
return

ButtonDelete:
    Gui, Submit, NoHide
    MSGBox, 4100,, Do you want to delete the preset %MyDropdown%?
    IfMsgBox, No 
      Return
    IniDelete, settings.ini, %MyDropdown%
    UpdatePresetList()
Return

ButtonResetFoV:
    mem.write(FoV_AddressBase, 45, "UFloat")
    WinGetPos, OutX, OutY, OutWidth, OutHeight, ahk_pid %lotro_window%
    FoVRead := (OutWidth / OutHeight) * 45
    GuiControl,, VarFoVEdit, % Round(FoVRead)
    GuiControl,, VarFoVSlider, % Round(FoVRead)
Return

ButtonResetMaxZoom:
    mem.write(FoV_AddressBase + 0x170, 20, "UFloat")
    GuiControl,, VarMaxZoomEdit, 20
    GuiControl,, VarMaxZoomSlider, 20
Return

OpenGitHub:
    Run, https://github.com/strauss7702/LotRO-Graphic-Preset/issues/new
    Gui, Destroy
    ExitApp
return

CloseGui:
    Gui, Destroy
    ExitApp
return

CheckValuesInMemory(writetoINI) {
    global
    valuesNotFound := 
    totalValues := 0
    notFoundCount := 0

    for index, item in AddressData {
        totalValues++
        ValueInMem := mem.read(moduleBase + AddressBase + item[2], item[3])

        If (item[4] = "IN") {
            CompareValues := item[5]
            If ValueInMem not in %CompareValues%
                {
                notFoundCount++
                valuesNotFound := valuesNotFound . "`n" . item[1]
                If (writetoINI=1) {
                    Key:=item[1]
                    IniWrite, Value not found, settings.ini, %SettingsName%, %Key%
                }
                }
            Else
                If (writetoINI=1) {
                    Key:=item[1]
                    IniWrite, %ValueInMem%, settings.ini, %SettingsName%, %Key%
                }
        }        
        Else If (item[4] = "BETWEEN") {
            CompareValueMin := item[6]
            CompareValueMax := item[7]
            If ValueInMem not between %CompareValueMin% and %CompareValueMax%
                {
                notFoundCount++
                valuesNotFound := valuesNotFound . "`n" . item[1]
                If (writetoINI=1) {
                    Key:=item[1]
                    IniWrite, Value not found, settings.ini, %SettingsName%, %Key%
                }
                }
            Else
                If (writetoINI=1) {
                    Key:=item[1]
                    IniWrite, %ValueInMem%, settings.ini, %SettingsName%, %Key%
                }
        }
    }
}

WriteValuesToMemory(){
    global
    for index, item in AddressData {
        Key := item[1]
        IniRead, Value_INI, settings.ini, %MyDropdown%, %Key%
        If (Value_INI!="Value not found" && Value_INI!="" && Value_INI!="ERROR")
            mem.write(moduleBase + AddressBase + item[2], Value_INI, item[3])
    }
}

ReformatINI(filename){
    FileRead, FileContent, %filename%
    FileContentLines := StrSplit(FileContent, "`n")
    for index, line in FileContentLines {
        if (RegExMatch(line, "^\[|\t|^$"))
            continue
        line := "`t" . line
        FileContentLines[index] := line
    }
    FormattedContent := ""
    for index, line in FileContentLines
        if (line != "")
            FormattedContent := FormattedContent . line . "`n"
    FileDelete, %filename%
    FileAppend, %FormattedContent%, %filename%
}

GetCouponCode(lotro_window){
    global VarCouponText
    WebObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WebObj.Open("GET", "https://forums.lotro.com/index.php?forums/sales-and-promotions.8/&order=post_date&direction=desc")
    WebObj.Send()
    HtmlText := WebObj.ResponseText

    regex := "data-preview-url=""([^""]+)"".*>(Store Sales|LOTRO Sales|LOTRO Store Sales)"
    if (RegExMatch(HtmlText, regex, match)){
        newUrl := "https://forums.lotro.com" . match1
        WebObj.Open("GET", newUrl)
        WebObj.Send()
        HtmlText := WebObj.ResponseText
        couponCodeRegex := "Coupon Code:\s*(\w+)"
        descriptionRegex := "<b>Weekly Coupon<\/b><br \/>[\r\n]*([\w\s()+%]+)"
        couponCode := ""
        description := ""

        if (RegExMatch(HtmlText, couponCodeRegex, couponCodeMatch)){
            couponCode := couponCodeMatch1
        }
        if (RegExMatch(HtmlText, descriptionRegex, descriptionMatch)){
            description := descriptionMatch1
        }
        GetTimeLeftAndDate(EndingTime, DateUTCTargetLocal)
        Clipboard:=couponCode
        GuiControl,, VarCouponText, Coupon Code: %couponCode%`n%description%`n`nExpires in about %EndingTime%`nat %DateUTCTargetLocal%.
    }
    else {
        GuiControl,, VarCouponText, Newest Coupon Code could not be found.
    }
}

;Convert 2 Byte Decimal to 1 byte Decimal
2BD_1BD(number){
byte1 := (number >> 8) & 0xFF
byte2 := number & 0xFF
formattedByte1 := Format("{:02d}", byte1)
formattedByte2 := Format("{:02d}", byte2)
return formattedByte2 " " formattedByte1
}

; Convert 1 Byte Decimal to 1 Byte Hex
1BD_1BH(number) {
    tokens := StrSplit(number, " ")
    formattedHex := ""
    for index, token in tokens {
        hex := Format("{:02X}", token)
        formattedHex := formattedHex . hex . " "
    }
    return RTrim(formattedHex)
}

ConvertStringToHex(originalString) {
    convertedString := ""
    tokens := StrSplit(originalString, " ")
    for index, token in tokens
        convertedString := convertedString . token . " "
    convertedString := RTrim(convertedString, " ")
    return convertedString
}

ToPattern(number){
    return ConvertStringToHex(1BD_1BH(2BD_1BD(number)))
}

GetTimeLeftAndDate(ByRef EndingTime, ByRef DateUTCTargetLocal){
    ; Get the current day of the week (1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday)
    DateUTCTarget:=A_NowUTC
    FormatTime, OutputVarDay , %A_NowUTC%, WDay
    FormatTime, OutputVarHour , %A_NowUTC%, HH

    If (OutputVarDay=5 && OutputVarHour<18)
        FormatTime, DateUTCTarget , %DateUTCTarget%, yyyyMMdd180000

    Else If ((OutputVarDay!=5) || (OutputVarDay=5 && OutputVarHour>=18)) {
        DateUTCTarget += 1, Days
        FormatTime, OutputVarDay , %DateUTCTarget%, WDay
        While (OutputVarDay!=5) {
            DateUTCTarget += 1, Days
            FormatTime, OutputVarDay , %DateUTCTarget%, WDay
        }
        FormatTime, DateUTCTarget , %DateUTCTarget%, yyyyMMdd180000
    }

    EnvSub, DateUTCTarget, A_NowUTC, S

    DateUTCTargetLocal:=A_Now
    DateUTCTargetLocal += DateUTCTarget, S
    FormatTime, DateUTCTargetLocal, %DateUTCTargetLocal%,
    ; FormatTime, DateUTCTargetLocal, %DateUTCTargetLocal%, hh:mm 'pm, August' dd, yyyy

    EndingTime:=GetFormattedTime(DateUTCTarget)
}

GetFormattedTime(_seconds){
    local x, t, ft
    static units
 
    If (_seconds = 0)
       Return "Now"
    units = day.hour.minute
    Loop Parse, units, .
    {
       x := A_Index = 1 ? 24 * 3600 : 60**(4 - A_Index)
       t := _seconds // x
       _seconds -= t * x
       If (t != 0)
          ft .= t . " " . A_LoopField . (t = 1 ? "" : "s") . (A_Index = 1 ? ", " : "") . (A_Index = 2 ? " and " : "")
    }
    Return ft
 }

GetBaseAddress(){
global moduleBase
global AddressBase:=""
global mem
global lotro_window:=""

    WinGet, lotro_window, PID, ahk_exe lotroclient64.exe
    WinGetPos, OutX, OutY, OutWidth, OutHeight, ahk_pid %lotro_window%
    WinGet, WindowStyle, Style, ahk_pid %lotro_window%
    if ((WindowStyle & 0xC00000) && (WindowStyle & 0x00800000)) {
        OutWidth := OutWidth - 8
        OutHeight := OutHeight - 31
    }

    SysGet, MonitorCount, MonitorCount
    MonitorResolution := ""
    Loop, %MonitorCount% {
        SysGet, Monitor, Monitor, %A_Index%
        if (OutX >= MonitorLeft && OutX <= MonitorRight && OutY >= MonitorTop && OutY <= MonitorBottom) {
            MonitorResolution := MonitorRight - MonitorLeft "x" MonitorBottom - MonitorTop
            break
        }
    }

    tokens := StrSplit(ToPattern(OutHeight), " ")
    OutHeight1 := "0x" . tokens[1]
    OutHeight2 := "0x" . tokens[2]
    tokens := StrSplit(ToPattern(OutWidth), " ")
    OutWidth1 := "0x" . tokens[1]
    OutWidth2 := "0x" . tokens[2]
    address:=""
    ; Check if the window resolution matches the monitor resolution
    if (OutWidth = MonitorRight - MonitorLeft && OutHeight = MonitorBottom - MonitorTop) {
            aPattern := [0x00, 0x00, 0x80, 0x3F, OutHeight1, OutHeight2, OutWidth1, OutWidth2, "?", "?", "?", "?", 0x02, 0x00]
            address := mem.modulePatternScan(, aPattern*)
            if !address > 0
                {
                aPattern := [0x00, 0x00, 0x80, 0x3F, OutHeight1, OutHeight2, OutWidth1, OutWidth2, "?", "?", "?", "?", 0x01, 0x00]
                address := mem.modulePatternScan(, aPattern*)
                }
    }
    else {
            aPattern := [0x00, 0x00, 0x80, 0x3F, "?", "?", "?", "?", OutHeight1, OutHeight2, OutWidth1, OutWidth2, 0x00, 0x00]
            address := mem.modulePatternScan(, aPattern*)
    }

    if address > 0
        {
        AddressBase := address - moduleBase
        IniRead, AddressBaseINI, settings.ini, MemoryAddresses, BaseAddress
        If (AddressBaseINI != AddressBase) {
            IniWrite, %AddressBase%, settings.ini, MemoryAddresses, BaseAddress
            IniWrite, %moduleBase%, settings.ini, MemoryAddresses, ModuleBase
            WebObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            WebObj.Open("GET", "https://www.lotro.com/home/update-notes")
            WebObj.Send()
            HtmlText := WebObj.ResponseText
            if (RegExMatch(HtmlText, "Update (\d+(?:\.\d+)*), released on (.*?),[^.</p>]*", LatestUpdate)){
                LatestUpdateNumber := ""
                LatestUpdateReleaseDate := ""
                if (RegExMatch(LatestUpdate, "Update (\d+(?:\.\d+)*)", versionMatch))
                    LatestUpdateNumber := versionMatch1
                if (RegExMatch(LatestUpdate, "released on (.+)", dateMatch))
                    LatestUpdateReleaseDate := dateMatch1
                IniWrite, %LatestUpdateNumber%, settings.ini, MemoryAddresses, LatestUpdateNumber
                IniWrite, %LatestUpdateReleaseDate%, settings.ini, MemoryAddresses, LatestUpdateReleaseDate
            }
            else {
                LatestUpdate:="the latest Game Update"
                IniWrite, "unknown", settings.ini, MemoryAddresses, LatestUpdateNumber
                IniWrite, "unknown", settings.ini, MemoryAddresses, LatestUpdateReleaseDate
            }
            ReformatINI("settings.ini")
        }
        }
    else
        {
        Progress, Off
        Gui, Destroy
        Gui, +OwnDialogs -Caption +LastFound +ToolWindow
        Gui, Add, Text, , Pattern not found or error: %address% `nPlease open a new issue on GitHub.com
        Gui Add, Button, w90 gOpenGitHub, Open GitHub
        Gui Add, Button, w90 x+10 gCloseGui, Close
        WinGet, The_Hwnd , ID, ahk_pid %lotro_window%
        Gui, +Owner%The_Hwnd%
        Gui, Show
        Pause
        }
}

CheckGameProcess:
Process, Exist, lotroclient64.exe
    If (Errorlevel=0){
        Reload
        ExitApp
    }
Return

UpdatePresetList(){
    Global
    DropDownSelectionINI:=""
    IniRead, OutputVarSectionNames, settings.ini
    SectionNames := StrSplit(OutputVarSectionNames, "`n")
    For Key, Value in SectionNames
        {
            If (Value="MemoryAddresses")
                Continue
            Else If (DropDownSelectionINI="")
                DropDownSelectionINI:=Value "||"
            Else If (DropDownSelectionINI!="")
                DropDownSelectionINI:=DropDownSelectionINI Value "|"
        }
    GuiControl,, MyDropdown, |%DropDownSelectionINI%
}

CreateGui(){
    global
    Gui, +OwnDialogs +LastFound -Caption +ToolWindow +HwndLotRO_Buddy_Hwnd
    Gui, Margin,0,0

    Gui Add, Progress, x1 y1 w298 h11 Background1A3461
    Gui Add, Progress, x1 y12 w298 h11 Background000A26
    Gui Add, Progress, x0 y0 w1 h12 Background4A5C7F
    Gui Add, Progress, x0 y12 w1 h12 Background363E54
    Gui Add, Progress, x299 y0 w1 h12 Background1A2843
    Gui Add, Progress, x299 y12 w1 h12 Background000618
    Gui Add, Progress, x0 y0 w300 h1 Background7B8DA9
    Gui Add, Progress, x0 y23 w300 h1 Background00030C

    Gui, Font, s10 cF5DF92
    Gui Add, Text, x263 y4 w15 h15 BackgroundTrans +0x200, __
    Gui, Font, s14 cF5DF92
    Gui Add, Text, x281 y4 w15 h15 BackgroundTrans +0x200, X
    Gui, Font

    Gui, Font, s14 cF5DF92
    Gui, Add, Text, x0 y0 w300 h24 Center BackgroundTrans, LotRO Buddy
    Gui, Font
    Gui, Add, Tab3, x0 y25 w300 h200 Buttons Border vVarMyTabs gMyTabs,Graphic|FoV|Coupon|Misc|Fishing

    Gui, Tab, 1
    Gui, Add, GroupBox, x3 y55 w183 h70 Center, Save Preset
    Gui, Add, Edit, Limit w175 x7 y75 vSettingsName,
    Gui, Add, Button, x45 y+0 gButtonSave w85, Save
    If (DropDownSelectionINI="")
        UpdatePresetList()
    Gui, Add, GroupBox, x3 ym+130 w183 h70 Center, Load Preset
    Gui, Add, DropDownList, x7 ym+150 vMyDropdown w175, %DropDownSelectionINI%
    Gui, Add, Button, x6 y+0 gButtonLoad w85, Load
    Gui, Add, Button, x98 yp+0 gButtonDelete w85, Delete

    Gui, Tab, 2
    Gui, Add, GroupBox, x3 y55 w225 h50 Center, Field of view
    FoV_Factor_ValueInMem := mem.read(FoV_AddressBase, "UFloat")
    WinGetPos, OutX, OutY, OutWidth, OutHeight, ahk_pid %lotro_window%
    FoVRead := (OutWidth / OutHeight) * FoV_Factor_ValueInMem
    Gui, Add, Slider, x5 y70 vVarFoVSlider gFoVSlider AltSubmit TickInterval20 Range40-200, % Round(FoVRead)
    Gui, Add, Edit, vVarFoVEdit w50 x+5 Center ReadOnly, % Round(FoVRead)
    Gui, Add, UpDown, Range40-200 vVarFoVUpDown gFoVUpDown, % Round(FoVRead)
    Gui, Add, Button, x+0 yp-1 w44 vVarButtonResetFoV gButtonResetFoV, Reset

    Gui, Add, GroupBox, x3 y110 w225 h50 Center, Maximum Zoom Level
    MaximumZoomLevel_ValueInMem := mem.read(FoV_AddressBase + 0x170, "UFloat")
    Gui, Add, Slider, x5 y125 vVarMaxZoomSlider gMaxZoomSlider AltSubmit TickInterval20 Range10-200, % Round(MaximumZoomLevel_ValueInMem)
    Gui, Add, Edit, vVarMaxZoomEdit w50 x+5 Center ReadOnly, % Round(MaximumZoomLevel_ValueInMem)
    Gui, Add, UpDown, Range5-200 vVarMaxZoomUpDown gMaxZoomUpDown, % Round(MaximumZoomLevel_ValueInMem)
    Gui, Add, Button, x+0 yp-1 w44 vVarButtonResetMaxZoom gButtonResetMaxZoom, Reset

    Gui, Tab, 3
    Gui, Add, Text, x7 y57 w300 h80 vVarCouponText,
    Gui, Add, Button, x7 y150 w85 vVarGetCode gGetCode, Get Code

    Gui, Tab, 4
    Gui, Add, ListView, vVarListViewTab4_2 -0x8 LV0x10000 Grid -Hdr 0x2000 R1 x0 y50 w300, 1|2
	Gui, ListView, VarListViewTab4_2
    LV_ModifyCol(1, "111 Center"),LV_ModifyCol(2, "185 Center")
    LV_Add(, "","")

    Gui, Add, ListView, vVarListViewTab4_1 -0x8 LV0x10000 Grid -Hdr 0x2000 R7 x0 y+-3 w300 h121, 1|2|3|4
	Gui, ListView, VarListViewTab4_1
    LV_ModifyCol(1, "74 Left"),LV_ModifyCol(2, "74 Right"),LV_ModifyCol(3, "74 Right"),LV_ModifyCol(4, "74 Right")
    LV_Add(, "Region:",""),LV_Add(, "Server:",""),LV_Add(, "XYZ:",""),LV_Add(, "Heading:",""),LV_Add(, "Velocity:",""),LV_Add(, "Acc.:","")

    Gui, Tab, 5
    Gui, Add, Text, x7 y57 0x800000 Center, Equip your fishing rod.`nFishing Skill on 1 is required.`nCast Your Rod atleast once before activating!
    Gui, Add, Text, x7 y+10 w200  vVarFishingText, Status: Off
    Gui, Add, Text, x7 y+5 w200  vVarBaitText, Bait:
    Gui, Add, Progress,  x7 y+20 w85 h25 Disabled BackgroundGray cGreen vVarProgressButton
    Gui, Add, Text, xp yp wp hp BackgroundTrans 0x201 gFishingOnOff

    WinGet, lotro_window_Hwnd , ID, ahk_pid %lotro_window%
    Gui, +AlwaysOnTop
    Gui, Show, w300 h200
    WinActivate, ahk_exe lotroclient64.exe
}
FishingOnOff(){
    global
    FishingFlag := !FishingFlag
	If (!FishingFlag) {
        GuiControl,, VarProgressButton, 0
        SetTimer, LetMeFish, Off
        GuiControl,, VarFishingText, Status: Off
    }
    Else {
        GuiControl,, VarFishingText, Status: Searching for memory address ...
        GuiControl,, VarProgressButton, 50
        aPattern := mem.hexStringToPattern("00 00 00 00 01 03 ?? BB F6 1E 00 10 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 00 00 ?? ?? ?? ?? ?? ?? 00 00 ?? 00 00 00 00 00 00 00 ?? ?? 00")
        Fish_BaseAddress := mem.processPatternScan(,, aPattern*)
        If (Fish_BaseAddress>0){
            Fish_BaseAddress += 0x20
            GuiControl,, VarProgressButton, 100
            Gosub, LetMeFish
            SetTimer, LetMeFish, 1000
            Return
        }
        GuiControl,, VarFishingText, Status: Memory address not found!
        GuiControl,, VarProgressButton, 0
        FishingFlag := !FishingFlag
        Return
    }
}
LetMeFish:
    Current_State_Fishing:=mem.read(Fish_BaseAddress, "UChar")

    If (Current_State_Fishing=0)
        {
        ControlFocus,,ahk_pid %lotro_window%
        ControlSend,,1,ahk_pid %lotro_window%
        GuiControl,, VarFishingText, Status: Casting Rod
        SetTimer, LetMeFish, 3210
        }
    Else If (Current_State_Fishing=4)
        {
        ControlFocus,,ahk_pid %lotro_window%
        ControlSend,,1,ahk_pid %lotro_window%
        GuiControl,, VarFishingText, Status: Bait! Reeling in.
        VarBait += 1
        GuiControl,, VarBaitText, Bait: %VarBait%
        SetTimer, LetMeFish, 6543
        }
    Else If (Current_State_Fishing=3)
        If (VarFishingText!="Status: Fishing..."){
            GuiControl,, VarFishingText, Status: Fishing...
            SetTimer, LetMeFish, 1000
        }
Return
FoVSlider(){
    global
    VarFoVSlider:=Round(VarFoVSlider / 5) * 5
    FoV_Write := (VarFoVSlider * OutHeight) / OutWidth
    GuiControl,, VarFoVEdit, %VarFoVSlider%
    GuiControl,, VarFoVSlider, %VarFoVSlider%
    mem.write(FoV_AddressBase, FoV_Write, "UFloat")
}
FoVUpDown(){
    global
    FoV_Write := (VarFoVUpDown * OutHeight) / OutWidth
    GuiControl,, VarFoVSlider, % Round(VarFoVUpDown)
    mem.write(FoV_AddressBase, FoV_Write, "UFloat")
}
MaxZoomSlider(){
    global
    VarMaxZoomSlider:=Round(VarMaxZoomSlider / 5) * 5
    GuiControl,, VarMaxZoomEdit, %VarMaxZoomSlider%
    GuiControl,, VarMaxZoomSlider, %VarMaxZoomSlider%
    mem.write(FoV_AddressBase + 0x170, VarMaxZoomSlider, "UFloat")
    mem.write(FoV_AddressBase + 0xA0, VarMaxZoomSlider, "UFloat")
}
MaxZoomUpDown(){
    global
    GuiControl,, VarMaxZoomSlider, % Round(VarMaxZoomUpDown)
    mem.write(FoV_AddressBase + 0x170, VarMaxZoomUpDown, "UFloat")
    mem.write(FoV_AddressBase + 0xA0, VarMaxZoomUpDown, "UFloat")
}
GetCode(){
    global
    GuiControl,, VarCouponText, `n`nRetrieving the latest Coupon Code.`nThis may take a moment...
    Sleep 5
    GetCouponCode(lotro_window)
}
MyTabs(){
    global
    Gui, Submit, NoHide
    If (VarMyTabs="FoV") {
        FoV_Factor_ValueInMem := mem.read(FoV_AddressBase, "UFloat")
        WinGetPos, OutX, OutY, OutWidth, OutHeight, ahk_pid %lotro_window%
        FoVRead := (OutWidth / OutHeight) * FoV_Factor_ValueInMem
        GuiControl,, VarFoVEdit, % Round(FoVRead)
        GuiControl,, VarFoVSlider, % Round(FoVRead)
        GuiControl, Disable, VarFoVSlider
        GuiControl, Enable, VarFoVSlider

        MaximumZoomLevel_ValueInMem := mem.read(FoV_AddressBase + 0x170, "UFloat")
        GuiControl,, VarMaxZoomEdit, % Round(MaximumZoomLevel_ValueInMem)
        GuiControl,, VarMaxZoomSlider, % Round(MaximumZoomLevel_ValueInMem)
        GuiControl, Disable, VarMaxZoomSlider
        GuiControl, Enable, VarMaxZoomSlider
    }
    If (VarMyTabs!="Misc") {
        SetTimer, UpdateCoordinates, Off
    }
    Else {
        SetTimer, UpdateCoordinates, 10
    }
}

WM_LBUTTONDOWN(wParam, lParam, msg, hWnd) {
    X := lParam & 0xFFFF
    Y := lParam >> 16
    MouseGetPos, xpos, ypos, , clickedControl
    if (clickedControl = "Static1")
        Return
    else if (clickedControl = "Static2")
        Return
    Else If (xpos>=0 && xpos<=300 && ypos>=0 && ypos<=23)
        PostMessage, 0x00A1, 2
}

WM_LBUTTONUP(wParam, lParam, msg, hWnd){
    MouseGetPos, xpos, ypos, , clickedControl
    if (clickedControl = "Static1")
        Gui, Hide
    else if (clickedControl = "Static2")
        ExitApp
}

Cleanup(){
    global
}

UpdateCoordinates:
    InstanceID := mem.read(InstanceID_addressBase, "UShort")

    ox:=mem.read(Address_WriteableCoords, "UFloat")
    oy:=mem.read(Address_WriteableCoords + 0x4, "UFloat")
    oz:=mem.read(Address_WriteableCoords + 0x8, "UFloat")
    oxm:=mem.read(Address_WriteableCoords - 0xC, "UChar")
    oym:=mem.read(Address_WriteableCoords - 0xB, "UChar")
    ClientRunTime1:=mem.read(FoV_AddressBase + 0x70, "Double")
    ClientRunTime2:=mem.read(FoV_AddressBase + 0x140, "Double")

    oxCheck:=mem.read(Address_WriteableCoords + 0x70, "UFloat")
    oyCheck:=mem.read(Address_WriteableCoords + 0x74, "UFloat")
    ozCheck:=mem.read(Address_WriteableCoords + 0x78, "UFloat")
    If (ox=0 && oy=0 && oz=0 && oxm=255 && oym=255 && oxCheck=0 && oyCheck=0 && ozCheck=0) {
        If (A_TickCount>MenuCheck+5000) {
            Reload
            ExitApp
        }
    }
    Else
        MenuCheck:=A_TickCount


    If (oxm=255 && oym=255)
        Return

    DevX := oxm * 160 + ox
    DevY := oym * 160 + oy

    directionFloat1:=mem.read(Address_WriteableCoords + 0xC, "UFloat")
    directionFloat2:=mem.read(Address_WriteableCoords + 0x18, "UFloat")
    VerticalSpeed:=mem.read(Address_WriteableCoords + 0x158, "UFloat")
    LateralSpeed:=mem.read(Address_WriteableCoords + 0x160, "UFloat")
    LinearSpeed:=mem.read(Address_WriteableCoords + 0x15C, "UFloat")

    directionDegree := Round(Abs(ATan2(directionFloat2, directionFloat1)) * 360 / 3.141592653589793, 2)
    compassDirections := ["N ", "NE", "E ", "SE", "S ", "SW", "W ", "NW"]
    directionCompass := compassDirections[Mod(Round((directionDegree) / 45), 8) + 1]

    Px := Round((DevX - 29360) / 200,1)
    Px := (Px < 0) ? Round(Abs(Px), 1) "W" : Px .= "E"
    Py := Round((DevY - 24880) / 200,1)
    Py := (Py < 0) ? Round(Abs(Py), 1) "S" : Py .= "N"

    ServerNumber := mem.read(CurrentServer_AddressBase, "UShort")
    InstanceNumber := mem.read(AddressBase + moduleBase + 0x40F4, "UShort")
    RegionNumber := mem.read(AddressBase + moduleBase + 0x40EC, "UChar")
    RegionNames := ["Eriador","Rhovanion","Gondor","Mordor"]

    Gui, ListView, VarListViewTab4_1
    LV_modify(1, "Col2", RegionNumber > 0 ? RegionNames[RegionNumber] : "")
    LV_modify(2, "Col2", ServerNumber > 0 ? ServerNumber : ""),LV_modify(2, "Col3", InstanceNumber > 0 ? " i"InstanceNumber : "")
    LV_modify(3, "Col2", Round(DevX,2)),LV_modify(3, "Col3", Round(DevY,2)),LV_modify(3, "Col4", Round(oz,2))
    LV_modify(4, "Col2", directionDegree . "°"),LV_modify(4, "Col3", directionCompass)
    LV_modify(5, "Col2", Round(Sqrt(VerticalSpeed**2 + LateralSpeed**2 + LinearSpeed**2),2) . " m/s")
    LV_modify(6, "Col2", Round(LinearSpeed,2) . " m/s"),LV_modify(6, "Col3", Round(Abs(VerticalSpeed),2) . " m/s"),LV_modify(6, "Col4", Round(LateralSpeed,2) . " m/s")
    Gui, ListView, VarListViewTab4_2
    LV_modify(1, "Col1", Py ", " Px)
    LV_modify(1, "Col2", InstanceNames[InstanceID][3] != "" ? InstanceNames[InstanceID][3] : InstanceID > 0 ? InstanceID : "")

Return

atan2(y,x) {
    Return atan(y/x)+2*(1+(x<0))*atan((x<=0)*((y>=0)-(y<0)))
}

Get_Address_WriteableCoords(mem,FoV_AddressBase){
    ox1:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xC8, "UChar"))
    ox2:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xC9, "UChar"))
    ox3:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xCA, "UChar"))
    ox4:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xCB, "UChar"))
    oy1:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xCC, "UChar"))
    oy2:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xCD, "UChar"))
    oy3:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xCE, "UChar"))
    oy4:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xCF, "UChar"))
    oz1:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xD0, "UChar"))
    oz2:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xD1, "UChar"))
    oz3:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xD2, "UChar"))
    oz4:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xD3, "UChar"))
    oxm1:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xBC, "UChar"))
    oym1:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xBD, "UChar"))
    heading11:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xD4, "UChar"))
    heading12:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xD5, "UChar"))
    heading13:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xD6, "UChar"))
    heading14:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xD7, "UChar"))
    heading21:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xE0, "UChar"))
    heading22:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xE1, "UChar"))
    heading23:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xE2, "UChar"))
    heading24:= "0x" . Format("{:02X}",mem.read(FoV_AddressBase + 0xE3, "UChar"))

    aPattern := [ox1, ox2, ox3, ox4, oy1, oy2, oy3, oy4, oz1, oz2, oz3, oz4, "?", heading12, heading13, heading14
    , "?", "?", "?", "?", "?", "?", "?", "?", "?", heading22, heading23, "?", "?", "?", "?", "?"
    , "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", oxm1, oym1, "?", "?"
    , "?", "?", "?", "?", "?", "?", "?", "?", ox1, ox2, ox3, ox4, oy1, oy2, oy3, oy4
    , oz1, oz2, oz3, oz4, "?", heading12, heading13, heading14, "?", "?", "?", "?", "?", "?", "?", "?"
    , "?", heading22, heading23, "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?"
    , "?", "?", "?", "?", oxm1, oym1, "?", "?", "?", "?", "?", "?", "?", "?", "?", "?"
    , ox1, ox2, ox3, ox4, oy1, oy2, oy3, oy4, oz1, oz2, oz3, oz4, "?", heading12, heading13, heading14
    , "?", "?", "?", "?", "?", "?", "?", "?", "?", heading22, heading23, "?", "?", "?", "?", "?"]
    Address_WriteableCoords := mem.processPatternScan(,, aPattern*)

    Return Address_WriteableCoords
}

Get_CurrentServer_address(mem){
    aPattern := mem.hexStringToPattern("20 48 ?? ?? ?? ?? 00 00 ?? ?? ?? ?? ?? ?? 00 00 ?? ?? ?? ?? ?? ?? 00 00 ?? ?? ?? ?? ?? ?? 00 00 0B 00 00 00 04 00 00 00 02 00 00 00 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 00 00 ?? ?? ?? ?? ?? ?? 00 00 04 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00")
    CurrentServer_address := mem.processPatternScan(,, aPattern*)  
    If (CurrentServer_address>0)
        CurrentServer_AddressBase := CurrentServer_address + 0x50

    Return CurrentServer_AddressBase
}

Get_InstanceID_address(mem,AddressBase,moduleBase){
    vx1:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27F4, "UChar"))
    vx2:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27F5, "UChar"))
    vx3:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27F6, "UChar"))
    vx4:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27F7, "UChar"))
    vy1:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27F8, "UChar"))
    vy2:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27F9, "UChar"))
    vy3:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27FA, "UChar"))
    vy4:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27FB, "UChar"))
    vz1:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27FC, "UChar"))
    vz2:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27FD, "UChar"))
    vz3:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27FE, "UChar"))
    vz4:= "0x" . Format("{:02X}",mem.read(AddressBase + moduleBase + 0x27FF, "UChar"))
    aPattern := mem.hexStringToPattern(vx1 vx2 vx3 vx4 vy1 vy2 vy3 vy4 vz1 vz2 vz3 vz4 "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" "??" vx1 vx2 vx3 vx4 vy1 vy2 vy3 vy4 vz1 vz2 vz3 vz4)         
    InstanceID_address := mem.processPatternScan(,, aPattern*)
    If (InstanceID_address>0)
        InstanceID_addressBase := InstanceID_address + 0xF8

    Return InstanceID_addressBase
}



Initialize:

AddressData := {}
AddressData.Push(["Engine_Speed", -48, "UChar", "IN", "0,1,2,3,4"]
                ,["Full_Screen_Resolution_Height", 4, "UShort", "BETWEEN", , "180", "8640"]
                ,["Full_Screen_Resolution_Width", 6, "UShort", "BETWEEN", , "320", "15360"]
                ,["Windowed_Resolution_Height", 8, "UShort", "BETWEEN", , "180", "8640"]
                ,["Windowed_Resolution_Width", 10, "UShort", "BETWEEN", , "320", "15360"]
                ,["Screen_Mode", 12, "UChar", "IN", "0,1,2"]
                ,["Refresh_Rate", 16, "UShort", "Between", , "0", "999"]
                ,["Sync_to_Refresh_Rate", 21, "UChar", "IN", "0,1"]
                ,["Triple_Buffering", 20, "UChar", "IN", "0,1"]
                ,["Antialiasing", 24, "UChar", "IN", "0,1,3,7"]
                ,["DirectXVersion", 2380, "UChar", "IN", "0,1,2"]
                ,["Texture_Filtering", 2384, "UChar", "IN", "0,1,2,3,4"]
                ,["Anistropic_Filter_Quality", 2388, "UChar", "IN", "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16"]
                ,["Stencil_Shadows", 2392, "UChar", "IN", "0,1,2,3,4,5"]
                ,["Blob_Shadows", 2396, "UChar", "IN", "0,1"]
                ,["Environment_Stencil_Shadows", 2397, "UChar", "IN", "0,1"]
                ,["DX10_Dynamic_Shadows", 2400, "UChar", "IN", "0,1,2"]
                ,["Texture_Detail", 2404, "UChar", "IN", "0,1,2,3,4"]
                ,["Material_Detail", 2408, "UChar", "IN", "0,1"]
                ,["Model_Detail", 2412, "UChar", "IN", "0,1,2,3,4"]
                ,["Surface_Reflections", 2416, "UChar", "IN", "0,1,2,3,4"]
                ,["Object_Draw_Distance", 2424, "UChar", "IN", "0,1,2,3,4"]
                ,["Landscape_Draw_Distance", 2428, "UChar", "IN", "0,1,2,3,4"]
                ,["Distant_Imposters", 2432, "UChar", "IN", "0,1"]
                ,["Frill_Distance", 2436, "UChar", "IN", "0,1,2,3,4,5"]
                ,["Frill_Density", 2440, "UFloat", "BETWEEN", , "0.0", "1.0"]
                ,["Landscape_Shadows", 2448, "UChar", "IN", "0,1,2,3"]
                ,["Landscape_Lightning_Quality", 2452, "UChar", "IN", "0,1,2"]
                ,["DX10_Distant_Landscape_Lightning", 2456, "UChar", "IN", "0,1"]
                ,["DX11_Ambient_Occlusion", 2457, "UChar", "IN", "0,1"])
AddressData.Push(["Volumetric_Sun_Lightning", 2458, "UChar", "IN", "0,1"]
                ,["DX11_Interactive_Water", 2460, "UChar", "IN", "0,1,2,3"]
                ,["Gamma_Level", 2464, "UFloat", "BETWEEN", , "0.0", "4.4"]
                ,["Brightness", 2468, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["Contrast", 2472, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["Ambient_Light", 2476, "UFloat", "BETWEEN", , "0.0", "1.0"]
                ,["High_Quality_Lightning", 2481, "UChar", "IN", "0,1"]
                ,["Dynamic_Particle_Rendering", 2484, "UChar", "IN", "0,1,2,3,4"]
                ,["Precipitation_Effects", 2488, "UChar", "IN", "0,1"]
                ,["Static_Environmental_Objects", 2489, "UChar", "IN", "0,1"]
                ,["Post_Processing_Effects", 2490, "UChar", "IN", "0,1"]
                ,["Bloom_Intensity", 2528, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["Glow_Mapping", 2532, "UChar", "IN", "0,1"]
                ,["Overbright_Bloom_Filter", 2533, "UChar", "IN", "0,1"]
                ,["Atmospherics_Detail", 2536, "UChar", "IN", "0,1,2"]
                ,["Blur_Filter_Quality", 2540, "UChar", "IN", "0,1,2"]
                ,["Specular_Lightning", 2544, "UChar", "IN", "0,1"]
                ,["Player_Mesh_Combining", 2545, "UChar", "IN", "0,1"]
                ,["Player_Crowd_Quality", 2548, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["3D_Object_Portraits", 2554, "UChar", "IN", "0,1"]
                ,["Texture_Cache_Size", 2556, "UFloat", "BETWEEN", , "0.0", "1.0"]
                ,["Per_Pixel_Lightning_Attenuation", 2561, "UChar", "IN", "0,1"]
                ,["Maximum_Frame_Rate", 4403840, "UShort", "BETWEEN", , "0", "1000"]
                ,["Avatar_Texture_Compositing", 4469464, "UChar", "IN", "0,1"]
                ,["Avatar_Update_Visible", 4469465, "UChar", "IN", "0,1"]
                ,["PvMP_Performance_Override", 4469467, "UChar", "IN", "0,1"])

InstanceNames := {}
InstanceNames[0] := ["","",""]
InstanceNames[3] := ["Instance", "Annuminas", "Ost Elendil"]
InstanceNames[5] := ["", "", "Intro Archet"]
InstanceNames[6] := ["Instance", "Annuminas", "Glinghant"]
InstanceNames[10] := ["Instance", "Annuminas", "Haudh Valandil"]
InstanceNames[15] := ["Non-Scaling Instance", "Angmar", "The Rift of Nurz Ghashu"]
InstanceNames[17] := ["Classic Homestead", "Bree-land", "Bree-Land Homesteads"]
InstanceNames[18] := ["Non-Scaling Instance", "Other", "Goblin-Town Throne Room"]
InstanceNames[35] := ["Non-Scaling Instance", "Garth Agarwen", "Fortress"]
InstanceNames[44] := ["", "", "Intro"]  ;Intro (Man), Instance: Jail Break
InstanceNames[61] := ["Non-Scaling Instance", "Angmar", "Urugarth"]
InstanceNames[75] := ["Instance", "Helegrod", "Spider Wing", "Drake Wing"]
InstanceNames[78] := ["Instance", "Great Barrow", "Great Barrow"] ;"Thadur", "The Maze", "Sambrog"
InstanceNames[82] := ["Non-Scaling Instance", "Angmar", "Carn Dum"]
InstanceNames[111] := ["Non-Scaling Instance", "Moria", "The Forges of Khazad-dûm"]
InstanceNames[114] := ["Non-Scaling Instance", "Angmar", "Barad Gularan"]
InstanceNames[123] := ["Non-Scaling Instance", "Moria", "Skûmfil"]
InstanceNames[124] := ["Non-Scaling Instance", "Moria", "Fil Gashan"]
InstanceNames[125] := ["Non-Scaling Instance", "Moria", "The Forgotten Treasury"]
InstanceNames[126] := ["Non-Scaling Instance", "Moria", "Dâr Narbugud"]
InstanceNames[127] := ["Non-Scaling Instance", "Moria", "The Grand Stair"]
InstanceNames[131] := ["Non-Scaling Instance", "Moria", "The Sixteenth Hall"]
InstanceNames[132] := ["Non-Scaling Instance", "Lothlórien", "Halls of Crafting"]
InstanceNames[133] := ["Non-Scaling Instance", "Moria", "The Vile Maw"]
InstanceNames[134] := ["Non-Scaling Instance", "Moria", "Dark Delvings"]
InstanceNames[150] := ["Instance", "Other", "Library at Tham Mirdain"]
InstanceNames[151] := ["Instance", "Other", "School at Tham Mirdain"]
InstanceNames[181] := ["Skirmish", "Defensive", "Battle of the Deep-Way"]
InstanceNames[182] := ["Skirmish", "Defensive", "Battle of the Twenty-First Hall"]
InstanceNames[183] := ["Skirmish", "Defensive", "Battle of the Way of Smiths"]
InstanceNames[202] := ["Non-Scaling Instance", "Lothlórien", "The Water Wheels: Nalâ-dûm"]
InstanceNames[203] := ["Non-Scaling Instance", "Lothlórien", "The Mirror-halls of Lumul-nar"]
InstanceNames[204] := ["Non-Scaling Instance", "Moria", "Filikul"]
InstanceNames[211] := ["Instance", "Dol Guldur", "Sword-Hall of Dol Guldur"]
InstanceNames[212] := ["Instance", "Dol Guldur", "Sammath Gul"]
InstanceNames[213] := ["Instance", "Dol Guldur", "Barad Guldur"]
InstanceNames[214] := ["Instance", "Dol Guldur", "Warg-Pens of Dol Guldur"]
InstanceNames[215] := ["Instance", "Dol Guldur", "Dungeons of Dol Guldur"]
InstanceNames[216] := ["Skirmish", "Defensive", "Siege of Gondamon"]
InstanceNames[217] := ["Skirmish", "Offensive", "Trouble in Tuckborough"]
InstanceNames[225] := ["Skirmish", "Defensive", "Ford of Bruinen"]
InstanceNames[229] := ["Skirmish", "Defensive", "Stand at Amon Sûl"]
InstanceNames[238] := ["Skirmish", "Offensive", "The Battle in the Tower"]
InstanceNames[239] := ["Skirmish", "Offensive", "Strike Against Dannenglor"]
InstanceNames[240] := ["Skirmish", "Defensive", "Protectors of Thangúlhad"]
InstanceNames[241] := ["Skirmish", "Offensive", "Assault on the Ringwraiths' Lair"]
InstanceNames[247] := ["Skirmish", "Offensive", "Breaching the Necromancer's Gate"]
InstanceNames[259] := ["Skirmish", "Defensive", "Defence of the Prancing Pony"]
InstanceNames[260] := ["Skirmish", "Offensive", "Thievery and Mischief"]
InstanceNames[265] := ["Non-Scaling Instance", "Garth Agarwen", "Arboretum"]
InstanceNames[266] := ["Non-Scaling Instance", "Garth Agarwen", "Barrows"]
InstanceNames[217] := ["Skirmish", "Survival", "Survival: Barrow-Downs"]
InstanceNames[278] := ["Skirmish", "Offensive", "Rescue in Nûrz Ghâshu"]
InstanceNames[292] := ["Instance", "Helegrod", "Giant Wing"]
InstanceNames[306] := ["Instance", "In their Absence", "Lost Temple"]
InstanceNames[307] := ["Instance", "In their Absence", "Ost Dunhoth"] ;"- Disease and Poison Wing", "- Gortheron Wing", "- Wound and Fear Wing"
InstanceNames[308] := ["Instance", "In their Absence", "Sâri-surma"]
InstanceNames[309] := ["Non-Scaling Instance", "Isengard", "Draigoch's Lair"]
InstanceNames[310] := ["Instance", "In their Absence", "Stoneheight"]
InstanceNames[312] := ["Instance", "In their Absence", "The Northcotton Farm"]
InstanceNames[313] := ["Instance", "Other", "Halls of Night"]
InstanceNames[315] := ["Instance", "Other", "Inn of the Forsaken"]
InstanceNames[322] := ["Skirmish", "Offensive", "The Icy Crevasse"]
InstanceNames[327] := ["Skirmish", "Offensive", "Attack at Dawn"]
InstanceNames[362] := ["Non-Scaling Instance", "Isengard", "The Tower of Orthanc"]
InstanceNames[363] := ["Non-Scaling Instance", "Isengard", "Dargnákh Unleashed"]
InstanceNames[368] := ["Non-Scaling Instance", "Isengard", "The Foundry"]
InstanceNames[369] := ["Non-Scaling Instance", "Isengard", "Pits of Isengard"]
InstanceNames[370] := ["Non-Scaling Instance", "Isengard", "Fangorn's Edge"]
InstanceNames[378] := ["Skirmish", "Offensive", "Storm on Methedras"]
InstanceNames[394] := ["Instance", "Fornost", "Wraith of Fire"]
InstanceNames[395] := ["Instance", "Fornost", "Wraith of Water"]
InstanceNames[396] := ["Instance", "Fornost", "Wraith of Earth"]
InstanceNames[397] := ["Instance", "Fornost", "Wraith of Shadow"]
InstanceNames[409] := ["Non-Scaling Instance", "Other", "Roots of Fangorn"]
InstanceNames[513] := ["Instance", "The Road to Erebor", "Iorbar's Peak"]
InstanceNames[514] := ["Instance", "The Road to Erebor", "Webs of the Scuttledells"]
InstanceNames[515] := ["Instance", "The Road to Erebor", "Seat of the Great Goblin"]
InstanceNames[516] := ["Instance", "The Road to Erebor", "Flight to the lonely Mountain"]
InstanceNames[517] := ["Instance", "The Road to Erebor", "The Fires of Smaug"]
InstanceNames[518] := ["Instance", "The Road to Erebor", "The Battle for Erebor"]
InstanceNames[520] := ["Instance", "The Road to Erebor", "The Bells of Dale"]
InstanceNames[571] := ["Epic Battle", "Defence of Rohan", "Helm's Dike"]
InstanceNames[572] := ["Epic Battle", "Defence of Rohan", "Glittering Caves"]
InstanceNames[573] := ["Epic Battle", "Defence of Rohan", "Deeping Wall"]
InstanceNames[577] := ["Epic Battle", "Defence of Rohan", "The Hornburg"]
InstanceNames[579] := ["Epic Battle", "Defence of Rohan", "Deeping-Coomb"]
InstanceNames[658] := ["Epic Battle", "War of Gondor", "Retaking Pelargir"]
InstanceNames[686] := ["Epic Battle", "War of Gondor", "Hammer of the Underworld"]
InstanceNames[687] := ["Epic Battle", "War of Gondor", "The Defence of Minas Tirith"]
InstanceNames[674] := ["Instance", "Osgiliath", "Sunken Labyrinth"]
InstanceNames[679] := ["Instance", "Osgiliath", "The Dome of Stars"]
InstanceNames[680] := ["Instance", "Osgiliath", "The Ruined City"]
InstanceNames[706] := ["Instance", "The Battle of the Pelennor Fields", "The Quays of the Harlond"]
InstanceNames[707] := ["Instance", "The Battle of the Pelennor Fields", "The Silent Street"]
InstanceNames[709] := ["Instance", "The Battle of the Pelennor Fields", "Blood of the Black Serpent"]
InstanceNames[710] := ["Non-Scaling Instance", "The Battle of Pelennor", "Throne of the Dread Terror"]
InstanceNames[803] := ["Instance", "Plateau of Gorgoroth", "The Dungeons of Naerband"]
InstanceNames[804] := ["Instance", "Plateau of Gorgoroth", "The Court of Seregost"]
InstanceNames[805] := ["Non-Scaling Instance", "Plateau of Gorgoroth", "The Abyss of Mordath"]
InstanceNames[826] := ["Seasonal", "Farmers Faire", "Summer: The Perfect Picnic"]
InstanceNames[827] := ["Seasonal", "Farmers Faire", "Boss from the Vaults: Thrang"]
InstanceNames[836] := ["Instance", "Grey Mountains", "Caverns of Thrumfall"]
InstanceNames[837] := ["Instance", "Grey Mountains", "Glimmerdeep"]
InstanceNames[841] := ["Non-Scaling Instance", "Grey Mountains", "The Anvil of Winterstith"]
InstanceNames[843] := ["Instance", "Grey Mountains", "Thikil-Gundu"]
InstanceNames[878] := ["Instance", "Minas Morgul", "Gath Daeroval, the Shadow-roost"]
InstanceNames[879] := ["Instance", "Gladdenmere", "The Depths of Kidzul-kâlah"]
InstanceNames[880] := ["Instance", "Minas Morgul", "Eithel Gwaur, the Filth-well"]
InstanceNames[881] := ["Instance", "Minas Morgul", "Gorthad Nûr, the Deep-barrow"]
InstanceNames[899] := ["Instance", "Minas Morgul", "The Fallen Kings"]
InstanceNames[917] := ["Non-Scaling Instance", "Minas Morgul", "Remmorchant, the Net of Darkness"]
InstanceNames[918] := ["Instance", "Minas Morgul", "Ghashan-kútot, the Hall of Black Lore"]
InstanceNames[919] := ["Instance", "Minas Morgul", "The Harrowing of Morgul"]
InstanceNames[920] := ["Instance", "Minas Morgul", "Bâr Nírnaeth, the Houses of Lamentation"]
InstanceNames[928] := ["Instance", "Other", "Askâd-mazal, the Chamber of Shadows"]
InstanceNames[1036] := ["Non-Scaling Instance", "War of Three Peaks", "Amdân Dammul, the Bloody Threshold"]
InstanceNames[1039] := ["Instance", "War of Three Peaks", "Shakalush, the Stair Battle"]
InstanceNames[1070] := ["Instance", "Other", "Agoroth, The Narrowdelve"]
InstanceNames[1071] := ["Instance", "Other", "Woe of the Willow"]
InstanceNames[1102] := ["Non-Scaling Instance", "War of Three Peaks", "The Fall of Khazad-dûm"]
InstanceNames[1103] := ["Mission", "Gundabad", "Drakes Up Above"]
InstanceNames[1125] := ["Mission", "Gundabad", "Darkness in the Mist"]
InstanceNames[1127] := ["Mission", "Gundabad", "Crystal Conundrum"]
InstanceNames[1135] := ["Mission", "Gundabad", "Assault on Dûn Traikh"]
InstanceNames[1139] := ["Mission", "Gundabad", "Clearing a Path"]
InstanceNames[1141] := ["Public Instance", "Gundabad", "Battle at the Forge"]
InstanceNames[1142] := ["Public Instance", "Gundabad", "Battle at the Lofts"]
InstanceNames[1147] := ["Mission", "Gundabad", "A Large Problem"]
InstanceNames[1164] := ["Instance", "Gundabad", "Den of Pughlak"]
InstanceNames[1168] := ["Mission", "Gundabad", "Drive a Wedge"]
InstanceNames[1169] := ["Mission", "Gundabad", "Culling the Rot"]
InstanceNames[1173] := ["Instance", "Gundabad", "Assault on Dhúrstrok"]
InstanceNames[1184] := ["Instance", "Gundabad", "Adkhât-zahhar, the Houses of Rest"]
InstanceNames[1190] := ["Non-Scaling Instance", "Gundabad", "The Hiddenhoard of Abnankara"]
InstanceNames[1207] := ["Instance", "Swanfleet & Cardolan", "Sarch Vorn, the Black Grave"]
InstanceNames[1208] := ["Skirmish", "Defensive", "Doom of Caras Gelebren"]
InstanceNames[1264] := ["Instance", "Ephel Angren", "Gwathrenost, The Witch-King's Citadel"]
InstanceNames[1265] := ["Instance", "Ephel Angren", "Sant Lhoer, The Poison Gardens"]
InstanceNames[1266] := ["Instance", "Ephel Angren", "Sagroth, Lair of Vermin"]
InstanceNames[1267] := ["Instance", "Ephel Angren", "Thaurisgar, The Vile Apothecary"]
Return
