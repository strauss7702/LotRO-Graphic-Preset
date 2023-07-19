#NoEnv
SetWorkingDir %A_ScriptDir%
#SingleInstance Force
#Include classMemory.ahk        ; https://github.com/Kalamity/classMemory

if !A_IsAdmin {
    Run *RunAs "%A_ScriptFullPath%"
    exitapp 
}
if (_ClassMemory.__Class != "_ClassMemory") {
    MsgBox, 4096, class memory not correctly installed. 
    ExitApp
}

process, wait, lotroclient64.exe
if !(FileExist("settings.ini")) {
    FileAppend,, settings.ini
    IniWrite, 26745392, Addresses.ini, MemoryAddresses, BaseAddress
}
if !(FileExist("Addresses.ini"))
    FileAppend,, Addresses.ini
mem := new _ClassMemory("ahk_exe lotroclient64.exe",, hProcessCopy)
    if !isObject(mem) 
        {
        if (hProcessCopy = 0)
            MsgBox, 4096, The program isn't running (not found) or you passed an incorrect program identifier parameter. 
        else if (hProcessCopy = "")
            MsgBox, 4096, OpenProcess failed. If the target process has admin rights, then the script also needs to be ran as admin. _ClassMemory.setSeDebugPrivilege() may also be required. Consult A_LastError for more information.
        ExitApp
        }
moduleBase := mem.getModuleBaseAddress("lotroclient64.exe")
IniRead, AddressBase, Addresses.ini, MemoryAddresses, BaseAddress

AddressData := [["DirectXVersion", 0, "UInt", "IN", "0,1,2"]
                ,["Texture_Filtering", 4, "UInt", "IN", "0,1,2,3,4"]
                ,["Anistropic_Filter_Quality", 8, "UInt", "IN", "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16"]
                ,["Stencil_Shadows", 12, "UInt", "IN", "0,1,2,3,4,5"]
                ,["Blob_Shadows___Environment_Stencil_Shadows", 16, "UInt", "IN", "0,1,256,257"]
                ,["DX10_Dynamic_Shadows", 20, "UInt", "IN", "0,1,2"]
                ,["Texture_Detail", 24, "UInt", "IN", "0,1,2,3,4"]
                ,["Material_Detail", 28, "UInt", "IN", "0,1"]
                ,["Model_Detail", 32, "UInt", "IN", "0,1,2,3,4"]
                ,["Surface_Reflections", 36, "UInt", "IN", "0,1,2,3,4"]
                ,["Object_Draw_Distance", 44, "UInt", "IN", "0,1,2,3,4"]
                ,["Landscape_Draw_Distance", 48, "UInt", "IN", "0,1,2,3,4"]
                ,["Distant_Imposters", 52, "UInt", "IN", "0,1"]
                ,["Frill_Distance", 56, "UInt", "IN", "0,1,2,3,4,5"]
                ,["Frill_Density", 60, "UFloat", "BETWEEN", , "0.0", "1.0"]
                ,["Landscape_Shadows", 68, "UInt", "IN", "0,1,2,3"]
                ,["Landscape_Lightning_Quality", 72, "UInt", "IN", "0,1,2"]
                ,["DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning", 76, "UInt", "IN", "0,1,256,257,65536,65537,65792,65793"]
                ,["DX11_Interactive_Water", 80, "UInt", "IN", "0,1,2,3"]
                ,["Gamma_Level", 84, "UFloat", "BETWEEN", , "0.0", "4.4"]
                ,["Brightness", 88, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["Contrast", 92, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["Ambient_Light", 96, "UFloat", "BETWEEN", , "0.0", "1.0"]
                ,["High_Quality_Lightning", 100, "UInt", "IN", "0,1,256,257"]
                ,["Dynamic_Particle_Rendering", 104, "UInt", "IN", "0,1,2,3,4"]
                ,["Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects", 108, "UInt", "IN", "0,1,256,257,65536,65537,65792,65793"]
                ,["Bloom_Intensity", 148, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["Glow_Mapping___Overbright_Bloom_Filter", 152, "UInt", "IN", "0,1,256,257"]
                ,["Atmospherics_Detail", 156, "UInt", "IN", "0,1,2"]
                ,["Blur_Filter_Quality", 160, "UInt", "IN", "0,1,2"]
                ,["Specular_Lightning___Player_Mesh_Combining", 164, "UInt", "IN", "0,1,256,257"]
                ,["Player_Crowd_Quality", 168, "UFloat", "BETWEEN", , "0.0", "2.0"]
                ,["3D_Object_Portraits", 172, "UInt", "IN", "0,1,65536,65537"]
                ,["Texture_Cache_Size", 176, "UFloat", "BETWEEN", , "0.0", "1.0"]
                ,["Per_Pixel_Lightning_Attenuation", 180, "UInt", "IN", "0,1,256,257"]]
Return


#IfWinActive ahk_exe lotroclient64.exe
$!^+End::
ExitApp

$!^+s::
    CheckValuesInMemory()
    InputBox, SettingsName , Safe your Settings, Please provide a name to save your preset., , , , , , Locale
    If (SettingsName="")
        Return
    SafeValuesToINI()
Return

$!^+l::
    CheckValuesInMemory()
    DropDownSelectionINI:=
    IniRead, OutputVarSectionNames, settings.ini
    If (OutputVarSectionNames="")
        {
        MsgBox, 4096, No presets have been saved yet.
        Return
        }

    SectionNames := StrSplit(OutputVarSectionNames, "`n")
    For Key, Value in SectionNames
        {
            If (A_Index=1)
                DropDownSelectionINI:=Value "||"
            Else If (A_Index=2)
                DropDownSelectionINI:=DropDownSelectionINI Value
            Else
                DropDownSelectionINI:=DropDownSelectionINI "|" Value
        }

    Gui, Destroy
    Gui, +OwnDialogs -Caption +LastFound +ToolWindow +AlwaysOnTop
    Gui, Add, Text, Center, Which preset would you like to load?
    Gui, Add, DropDownList, vMyDropdown w160 x20, %DropDownSelectionINI%
    Gui, Add, Button, Default w80 x60, OK
    Gui, Show, w200 h80
Return

ButtonOK:
    Gui, Submit
    WriteValuesToMemory()
    Gui, Destroy
return

UpdateBaseAddress(){
    global
    MsgBox, 4096, Updating BaseAddress, Please navigate to the "Options" menu and select "Graphics".`nIn the "Quality" section, locate the setting for "Overall Graphics Quality" and set it to "Very Low".
    
    aPattern := [0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, "?", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    address := mem.modulePatternScan(, aPattern*)
    if address > 0
        {
        AddressBase := address - moduleBase - 4
        IniRead, AddressBaseINI, Addresses.ini, MemoryAddresses, BaseAddress
        If (AddressBaseINI != AddressBase) {
            IniWrite, %AddressBase%, Addresses.ini, MemoryAddresses, BaseAddress
            MsgBox, 4096, Updating BaseAddress, Update successful!
        }
        }
    else
        {
        Gui, +OwnDialogs -Caption +LastFound +ToolWindow +AlwaysOnTop
        Gui, Add, Text, , Pattern not found or error: %address% `nPlease open a new issue on GitHub.com
        Gui Add, Button, w90 gOpenGitHub, Open GitHub
        Gui Add, Button, w90 x+10 gCloseGui, Close
        Gui Show, , Window Title
        }
}

OpenGitHub:
    Run, https://github.com/strauss7702/LotRO-Graphic-Preset/issues/new
    Gui, Destroy
return

CloseGui:
    Gui, Destroy
return

CheckValuesInMemory(){
    global
    for index, item in AddressData {
        ValueInMem := mem.read(moduleBase + AddressBase + item[2], item[3])
        If (item[4]="IN")
            {
            CompareValues:=item[5]
            If ValueInMem not IN %CompareValues%
                {
                MsgBox, 4096, Scan Result, One or more of the values could not be found or are incorrect. The script will now attempt to update itself.
                UpdateBaseAddress()
                Return
                }
            }        
        Else If (item[4]="BETWEEN")
            {
            CompareValueMin:=item[6]
            CompareValueMax:=item[7]
            If ValueInMem not between %CompareValueMin% and %CompareValueMax%
                {
                MsgBox, 4096, Scan Result, One or more of the values could not be found or are incorrect. The script will now attempt to update itself.
                UpdateBaseAddress()
                Return
                }
            }
    }
}

SafeValuesToINI(){
    global
    for index, item in AddressData {
        ValueInMem := mem.read(moduleBase + AddressBase + item[2], item[3])
        Key:=`titem[1]
        IniWrite, %ValueInMem%, Settings.ini, %SettingsName%, %Key%
    }
}

WriteValuesToMemory(){
    global
    for index, item in AddressData {
        Key:=item[1]
        IniRead, Value_INI, settings.ini, %MyDropdown%, %Key%
        mem.write(moduleBase + AddressBase + item[2], Value_INI, item[3])
    }
}
