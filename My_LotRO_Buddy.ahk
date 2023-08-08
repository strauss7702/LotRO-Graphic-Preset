#NoEnv
SetWorkingDir %A_ScriptDir%
#SingleInstance Force
#Include classMemory.ahk        ; https://github.com/Kalamity/classMemory
OnExit("Cleanup")
OnMessage(0x0201, "WM_LBUTTONDOWN")

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

AddressData1 := [["Engine_Speed", -48, "UChar", "IN", "0,1,2,3,4"]
                ,["Full_Screen_Resolution_Height", 4, "UShort", "BETWEEN", , "180", "8640"]
                ,["Full_Screen_Resolution_Width", 6, "UShort", "BETWEEN", , "320", "15360"]
                ,["Windowed_Resolution_Height", 8, "UShort", "BETWEEN", , "180", "8640"]
                ,["Windowed_Resolution_Width", 10, "UShort", "BETWEEN", , "320", "15360"]
                ,["Screen_Mode", 12, "UChar", "IN", "0,1,2"]
                ,["Refresh_Rate", 16, "UShort", "Between", , "0", "999"]
                ,["Sync_to_Refresh_Rate", 21, "UChar", "IN", "0,1"]
                ,["Triple_Buffering", 20, "UChar", "IN", "0,1"]
                ,["Antialiasing", 24, "UChar", "IN", "0,1,3,7"]]
AddressData2 := [["DirectXVersion", 2380, "UChar", "IN", "0,1,2"]
                ,["Texture_Filtering", 2384, "UChar", "IN", "0,1,2,3,4"]
                ,["Anistropic_Filter_Quality", 2388, "UChar", "IN", "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16"]
                ,["Stencil_Shadows", 2392, "UChar", "IN", "0,1,2,3,4,5"]
                ,["Blob_Shadows", 2396, "UChar", "IN", "0,1"]
                ,["Environment_Stencil_Shadows", 2397, "UChar", "IN", "0,1"]
                ,["DX10_Dynamic_Shadows", 2400, "UChar", "IN", "0,1,2"]
                ,["Texture_Detail", 2404, "UChar", "IN", "0,1,2,3,4"]
                ,["Material_Detail", 2408, "UChar", "IN", "0,1"]
                ,["Model_Detail", 2412, "UChar", "IN", "0,1,2,3,4"]]
AddressData3 := [["Surface_Reflections", 2416, "UChar", "IN", "0,1,2,3,4"]
                ,["Object_Draw_Distance", 2424, "UChar", "IN", "0,1,2,3,4"]
                ,["Landscape_Draw_Distance", 2428, "UChar", "IN", "0,1,2,3,4"]
                ,["Distant_Imposters", 2432, "UChar", "IN", "0,1"]
                ,["Frill_Distance", 2436, "UChar", "IN", "0,1,2,3,4,5"]
                ,["Frill_Density", 2440, "UFloat", "BETWEEN", , "0.0", "1.0"]
                ,["Landscape_Shadows", 2448, "UChar", "IN", "0,1,2,3"]
                ,["Landscape_Lightning_Quality", 2452, "UChar", "IN", "0,1,2"]
                ,["DX10_Distant_Landscape_Lightning", 2456, "UChar", "IN", "0,1"]
                ,["DX11_Ambient_Occlusion", 2457, "UChar", "IN", "0,1"]]
AddressData4 := [["Volumetric_Sun_Lightning", 2458, "UChar", "IN", "0,1"]
                ,["DX11_Interactive_Water", 2460, "UChar", "IN", "0,1,2,3"]
                ,["Gamma_Level", 2464, "UFloat", "BETWEEN", , "0.0", "4.4"]
                ,["Brightness", 2468, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["Contrast", 2472, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["Ambient_Light", 2476, "UFloat", "BETWEEN", , "0.0", "1.0"]
                ,["High_Quality_Lightning", 2481, "UChar", "IN", "0,1"]
                ,["Dynamic_Particle_Rendering", 2484, "UChar", "IN", "0,1,2,3,4"]
                ,["Precipitation_Effects", 2488, "UChar", "IN", "0,1"]
                ,["Static_Environmental_Objects", 2489, "UChar", "IN", "0,1"]]
AddressData5 := [["Post_Processing_Effects", 2490, "UChar", "IN", "0,1"]
                ,["Bloom_Intensity", 2528, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["Glow_Mapping", 2532, "UChar", "IN", "0,1"]
                ,["Overbright_Bloom_Filter", 2533, "UChar", "IN", "0,1"]
                ,["Atmospherics_Detail", 2536, "UChar", "IN", "0,1,2"]
                ,["Blur_Filter_Quality", 2540, "UChar", "IN", "0,1,2"]
                ,["Specular_Lightning", 2544, "UChar", "IN", "0,1"]
                ,["Player_Mesh_Combining", 2545, "UChar", "IN", "0,1"]
                ,["Player_Crowd_Quality", 2548, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["3D_Object_Portraits", 2554, "UChar", "IN", "0,1"]]
AddressData6 := [["Texture_Cache_Size", 2556, "UFloat", "BETWEEN", , "0.0", "1.0"]
                ,["Per_Pixel_Lightning_Attenuation", 2561, "UChar", "IN", "0,1"]
                ,["Maximum_Frame_Rate", 4402800, "UShort", "BETWEEN", , "0", "1000"]
                ,["Avatar_Texture_Compositing", 4468360, "UChar", "IN", "0,1"]
                ,["Avatar_Update_Visible", 4468361, "UChar", "IN", "0,1"]
                ,["PvMP_Performance_Override", 4468363, "UChar", "IN", "0,1"]]

AddressData := []
AddressData.Push(AddressData1)
AddressData.Push(AddressData2)
AddressData.Push(AddressData3)
AddressData.Push(AddressData4)
AddressData.Push(AddressData5)
AddressData.Push(AddressData6)

process, wait, lotroclient64.exe

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

Progress, b w200,, My LotRO Buddy,
Progress, 30
Loop
    {
    aPattern := [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, "?", "?", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70, 0xC1, 0x00, 0x00, 0xC0, 0x40]
    ; FoV_address := mem.modulePatternScan("lotroclient64.exe", aPattern*)
    FoV_address := mem.processPatternScan(,, aPattern*)
    If (A_Index >= 10) {
        Progress, Off
        MsgBox, Pause Here 1
        Gui, +OwnDialogs -Caption +LastFound +ToolWindow +AlwaysOnTop
        Gui, Add, Text, , Pattern not found or error: %address% `nPlease open a new issue on GitHub.com
        Gui Add, Button, w90 gOpenGitHub, Open GitHub
        Gui Add, Button, w90 x+10 gCloseGui, Close
        Gui, Show
        Pause
    }
    VarProgress := 30 + 3 * A_Index
    Progress, %VarProgress%
    }until (FoV_address>0)
FoV_AddressBase := FoV_address - moduleBase + 16
FoV_Factor_ValueInMem := mem.read(FoV_AddressBase + modulebase, "UFloat")
Progress, 80
GetBaseAddress()
Progress, 100
Sleep 500
Progress, Off
CreateGui()
ScriptStatus:=1
Return



$Pause::
if (WinExist("ahk_id " My_LotRO_Buddy_Hwnd))
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
    ; WinActivate, ahk_exe lotroclient64.exe
    Gui, Show
return

ButtonLoad:
    Gui, Submit, NoHide
    If (MyDropdown="")
        Return
    CheckValuesInMemory(0)
    WriteValuesToMemory()
    ; WinActivate, ahk_exe lotroclient64.exe
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

ButtonReset:
    mem.write(moduleBase + FoV_AddressBase, 45, "UFloat")
    WinGetPos, OutX, OutY, OutWidth, OutHeight, ahk_pid %lotro_window%
    FoVRead := (OutWidth / OutHeight) * 45
    GuiControl,, VarFoVEdit, % Round(FoVRead)
    GuiControl,, VarFoVSlider, % Round(FoVRead)
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

    for index, group in AddressData {
        for index, item in group {
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
}

WriteValuesToMemory(){
    global
    for index, group in AddressData {
        for index, item in group {
            Key := item[1]
            IniRead, Value_INI, settings.ini, %MyDropdown%, %Key%
            If (Value_INI!="Value not found" && Value_INI!="" && Value_INI!="ERROR")    ; if Value_INI not in ,Value not found,ERROR
                mem.write(moduleBase + AddressBase + item[2], Value_INI, item[3])
        }
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
    SetTimer, CheckGameProcess, 1000
}

CheckGameProcess:
Process, Exist, lotroclient64.exe
    If (Errorlevel=0)
        Reload
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
    Gui, +OwnDialogs +LastFound -Caption +ToolWindow +HwndMy_LotRO_Buddy_Hwnd
    Gui, Margin,0,0

    Gui Add, Progress, x1 y1 w298 h11 Background1A3461
    Gui Add, Progress, x1 y12 w298 h11 Background000A26
    Gui Add, Progress, x0 y0 w1 h12 Background4A5C7F
    Gui Add, Progress, x0 y12 w1 h12 Background363E54
    Gui Add, Progress, x299 y0 w1 h12 Background1A2843
    Gui Add, Progress, x299 y12 w1 h12 Background000618
    Gui Add, Progress, x0 y0 w300 h1 Background7B8DA9
    Gui Add, Progress, x0 y23 w300 h1 Background00030C
    Gui, Font, s14 cF5DF92
    Gui, Add, Text, x0 y0 w300 h24 Center BackgroundTrans, My LotRO Buddy
    Gui, Font
    Gui, Add, Tab3, x0 y25 w300 h200 0x400 Buttons Border vVarMyTabs gMyTabs,Graphic|FoV|Coupon
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
    Gui, Add, Text, x7 y57 0x800000 vFoVText Center, `nChange your field of view.`nFirst Person not supported at the moment.`n
    FoV_Factor_ValueInMem := mem.read(FoV_AddressBase + modulebase, "UFloat")
    WinGetPos, OutX, OutY, OutWidth, OutHeight, ahk_pid %lotro_window%
    FoVRead := (OutWidth / OutHeight) * FoV_Factor_ValueInMem
    Gui, Add, Slider, y+10 vVarFoVSlider gFoVSlider AltSubmit Range40-200, % Round(FoVRead)
    Gui, Add, Edit, vVarFoVEdit w50 x+5 Center ReadOnly, % Round(FoVRead)        ; w30
    Gui, Add, UpDown, Range40-200 vVarFoVUpDown gFoVUpDown, % Round(FoVRead)
    Gui, Add, Button, x+0 yp-1 w44 vVarButtonReset gButtonReset, Reset

    Gui, Tab, 3
    Gui, Add, Text, x7 y57 w300 h80 vVarCouponText,
    Gui, Add, Button, x7 y150 w85 vVarGetCode gGetCode, Get Code

    WinGet, lotro_window_Hwnd , ID, ahk_pid %lotro_window%
    Gui, +Owner%lotro_window_Hwnd%
    Gui, Show, w300 h200
    WinActivate, ahk_exe lotroclient64.exe
}
FoVSlider(){
    global
    FoV_Write := (VarFoVSlider * OutHeight) / OutWidth
    GuiControl,, VarFoVEdit, % Round(VarFoVSlider)
    mem.write(moduleBase + FoV_AddressBase, FoV_Write, "UFloat")
}
FoVUpDown(){
    global
    GuiControl, Disable, VarFoVEdit
    FoV_Write := (VarFoVUpDown * OutHeight) / OutWidth
    GuiControl,, VarFoVSlider, % Round(VarFoVUpDown)
    mem.write(moduleBase + FoV_AddressBase, FoV_Write, "UFloat")
    GuiControl, Enable, VarFoVEdit
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
        FoV_Factor_ValueInMem := mem.read(FoV_AddressBase + modulebase, "UFloat")
        WinGetPos, OutX, OutY, OutWidth, OutHeight, ahk_pid %lotro_window%
        FoVRead := (OutWidth / OutHeight) * FoV_Factor_ValueInMem
        GuiControl,, VarFoVEdit, % Round(FoVRead)
        GuiControl,, VarFoVSlider, % Round(FoVRead)
        Sleep 5
    }
}

WM_LBUTTONDOWN(){
    PostMessage, 0x00A1, 2
}

Cleanup(){
    global
    If (ScriptStatus=1)
        mem.write(moduleBase + FoV_AddressBase, 45, "UFloat")
}
