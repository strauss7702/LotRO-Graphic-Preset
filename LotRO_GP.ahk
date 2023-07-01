#NoEnv
SetWorkingDir %A_ScriptDir%
#SingleInstance Force
#Include classMemory.ahk        ; https://github.com/Kalamity/classMemory

if !A_IsAdmin 
{
        Run *RunAs "%A_ScriptFullPath%"
        exitapp 
}
if (_ClassMemory.__Class != "_ClassMemory")
{
    msgbox class memory not correctly installed. 
    ExitApp
}
Return

$!^+End::
ExitApp


$!^+s::
{
    mem := new _ClassMemory("ahk_exe lotroclient64.exe",, hProcessCopy) 
	if !isObject(mem) 
		{
		if (hProcessCopy = 0)
			msgbox The program isn't running (not found) or you passed an incorrect program identifier parameter. 
		else if (hProcessCopy = "")
			msgbox OpenProcess failed. If the target process has admin rights, then the script also needs to be ran as admin. _ClassMemory.setSeDebugPrivilege() may also be required. Consult A_LastError for more information.
		ExitApp
		}
    
    InputBox, SettingsName , Safe your Settings, Please enter a name under which your settings should be saved., , , , , , Locale
    If (SettingsName="")
        Return

    If (moduleBase="")
        moduleBase := mem.getModuleBaseAddress("lotroclient64.exe")

    Antialiasing_1:=mem.read(moduleBase + 0x19800FC, "UInt")
    Antialiasing_2:=mem.read(moduleBase + 0x1DB5DD0, "UInt")
    Ambient_Light:=mem.read(moduleBase + 0x1980A90, "UFloat")
    Brightness:=mem.read(moduleBase + 0x1980A88, "UFloat")
    Contrast:=mem.read(moduleBase + 0x1980A8C, "UFloat")
    Gamma_Level:=mem.read(moduleBase + 0x1980A84, "UFloat")

    Object_Draw_Distance:=mem.read(moduleBase + 0x1980A5C, "UInt")
    Model_Detail:=mem.read(moduleBase + 0x1980A50, "UInt")
    Material_Detail:=mem.read(moduleBase + 0x1980A4C, "UInt")
    Landscape_Draw_Distance:=mem.read(moduleBase + 0x1980A60, "UInt")
    Frill_Distance:=mem.read(moduleBase + 0x1980A68, "UInt")
    Frill_Density:=mem.read(moduleBase + 0x1980A6C, "UFloat")
    Distant_Imposters:=mem.read(moduleBase + 0x1980A64, "UInt")
    Atmospherics_Detail:=mem.read(moduleBase + 0x1980ACC, "UInt")
    DX11_Interactive_Water:=mem.read(moduleBase + 0x1980A80, "UInt")
    Texture_Detail:=mem.read(moduleBase + 0x1980A48, "UInt")
    Texture_Filtering:=mem.read(moduleBase + 0x1980A34, "UInt")
    Anistropic_Filter_Quality:=mem.read(moduleBase + 0x1980A38, "UInt")
    High_Quality_Lightning:=mem.read(moduleBase + 0x1980A94, "UInt")
    Per_Pixel_Lightning_Attenuation:=mem.read(moduleBase + 0x1980AE4, "UInt")
    Specular_Lightning___Player_Mesh_Combining:=mem.read(moduleBase + 0x1980AD4, "UInt")
    Surface_Reflections:=mem.read(moduleBase + 0x1980A54, "UInt")
    Landscape_Lightning_Quality:=mem.read(moduleBase + 0x1980A78, "UInt")
    DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning:=mem.read(moduleBase + 0x1980A7C, "UInt")
    Landscape_Shadows:=mem.read(moduleBase + 0x1980A74, "UInt")
    Blob_Shadows___Environment_Stencil_Shadows:=mem.read(moduleBase + 0x1980A40, "UInt")
    Stencil_Shadows:=mem.read(moduleBase + 0x1980A3C, "UInt")
    DX10_Dynamic_Shadows:=mem.read(moduleBase + 0x1980A44, "UInt")
    Dynamic_Particle_Rendering:=mem.read(moduleBase + 0x1980A98, "UInt")
    Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects:=mem.read(moduleBase + 0x1980A9C, "UInt")
    Glow_Mapping___Overbright_Bloom_Filter:=mem.read(moduleBase + 0x1980AC8, "UInt")
    Blur_Filter_Quality:=mem.read(moduleBase + 0x1980AD0, "UInt")
    Bloom_Intensity:=mem.read(moduleBase + 0x1980AC4, "UFloat")
    Avatar_Update_Visible___Avatar_Texture_Compositing:=mem.read(moduleBase + 0x1980A0C, "UInt")
    3D_Object_Portraits:=mem.read(moduleBase + 0x1980ADE, "UChar")
    Texture_Cache_Size:=mem.read(moduleBase + 0x1980AE0, "UFloat")
    Player_Crowd_Quality:=mem.read(moduleBase + 0x1980AD8, "UFloat")

    Maximum_Framerate:=mem.read(moduleBase + 0x1DB2EF4, "UInt")
    Maximum_Framerate_Safe_Value:=mem.read(moduleBase + 0x19800BC, "UInt")

IniWrite, 
(
`tAntialiasing_1=%Antialiasing_1%
`tAntialiasing_2=%Antialiasing_2%
`tAmbient_Light=%Ambient_Light%
`tBrightness=%Brightness%
`tContrast=%Contrast%
`tGamma_Level=%Gamma_Level%
`tObject_Draw_Distance=%Object_Draw_Distance%
`tModel_Detail=%Model_Detail%
`tMaterial_Detail=%Material_Detail%
`tLandscape_Draw_Distance=%Landscape_Draw_Distance%
`tFrill_Distance=%Frill_Distance%
`tFrill_Density=%Frill_Density%
`tDistant_Imposters=%Distant_Imposters%
`tAtmospherics_Detail=%Atmospherics_Detail%
`tDX11_Interactive_Water=%DX11_Interactive_Water%
`tTexture_Detail=%Texture_Detail%
`tTexture_Filtering=%Texture_Filtering%
`tAnistropic_Filter_Quality=%Anistropic_Filter_Quality%
`tHigh_Quality_Lightning=%High_Quality_Lightning%
`tPer_Pixel_Lightning_Attenuation=%Per_Pixel_Lightning_Attenuation%
`tSpecular_Lightning___Player_Mesh_Combining=%Specular_Lightning___Player_Mesh_Combining%
`tSurface_Reflections=%Surface_Reflections%
`tLandscape_Lightning_Quality=%Landscape_Lightning_Quality%
`tDX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning=%DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning%
`tLandscape_Shadows=%Landscape_Shadows%
`tBlob_Shadows___Environment_Stencil_Shadows=%Blob_Shadows___Environment_Stencil_Shadows%
`tStencil_Shadows=%Stencil_Shadows%
`tDX10_Dynamic_Shadows=%DX10_Dynamic_Shadows%
`tDynamic_Particle_Rendering=%Dynamic_Particle_Rendering%
`tStatic_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects=%Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects%
`tGlow_Mapping___Overbright_Bloom_Filter=%Glow_Mapping___Overbright_Bloom_Filter%
`tBlur_Filter_Quality=%Blur_Filter_Quality%
`tBloom_Intensity=%Bloom_Intensity%
`tAvatar_Update_Visible___Avatar_Texture_Compositing=%Avatar_Update_Visible___Avatar_Texture_Compositing%
`t3D_Object_Portraits=%3D_Object_Portraits%
`tTexture_Cache_Size=%Texture_Cache_Size%
`tPlayer_Crowd_Quality=%Player_Crowd_Quality%
`tMaximum_Framerate=%Maximum_Framerate%
`tMaximum_Framerate_Safe_Value=%Maximum_Framerate_Safe_Value%
), settings.ini, %SettingsName%
}
Return



$!^+l::
{
    mem := new _ClassMemory("ahk_exe lotroclient64.exe",, hProcessCopy) 
	if !isObject(mem) 
		{
		if (hProcessCopy = 0)
			msgbox The program isn't running (not found) or you passed an incorrect program identifier parameter. 
		else if (hProcessCopy = "")
			msgbox OpenProcess failed. If the target process has admin rights, then the script also needs to be ran as admin. _ClassMemory.setSeDebugPrivilege() may also be required. Consult A_LastError for more information.
		ExitApp
		}

DropDownSelectionINI:=
IniRead, OutputVarSectionNames, settings.ini
If (OutputVarSectionNames=)
    Return
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
Gui, +AlwaysOnTop
Gui, Add, DropDownList, vMyDropdown, %DropDownSelectionINI%
Gui, Add, Button, Default w80 x30, OK
Gui, Show

}
Return



ButtonOK:
Gui, Submit
IniRead, Antialiasing_1, settings.ini, %MyDropdown%, Antialiasing_1
IniRead, Antialiasing_2, settings.ini, %MyDropdown%, Antialiasing_2
IniRead, Ambient_Light, settings.ini, %MyDropdown%, Ambient_Light
IniRead, Brightness, settings.ini, %MyDropdown%, Brightness
IniRead, Contrast, settings.ini, %MyDropdown%, Contrast
IniRead, Gamma_Level, settings.ini, %MyDropdown%, Gamma_Level
IniRead, Object_Draw_Distance, settings.ini, %MyDropdown%, Object_Draw_Distance
IniRead, Model_Detail, settings.ini, %MyDropdown%, Model_Detail
IniRead, Material_Detail, settings.ini, %MyDropdown%, Material_Detail
IniRead, Landscape_Draw_Distance, settings.ini, %MyDropdown%, Landscape_Draw_Distance
IniRead, Frill_Distance, settings.ini, %MyDropdown%, Frill_Distance
IniRead, Frill_Density, settings.ini, %MyDropdown%, Frill_Density
IniRead, Distant_Imposters, settings.ini, %MyDropdown%, Distant_Imposters
IniRead, Atmospherics_Detail, settings.ini, %MyDropdown%, Atmospherics_Detail
IniRead, DX11_Interactive_Water, settings.ini, %MyDropdown%, DX11_Interactive_Water
IniRead, Texture_Detail, settings.ini, %MyDropdown%, Texture_Detail
IniRead, Texture_Filtering, settings.ini, %MyDropdown%, Texture_Filtering
IniRead, Anistropic_Filter_Quality, settings.ini, %MyDropdown%, Anistropic_Filter_Quality
IniRead, High_Quality_Lightning, settings.ini, %MyDropdown%, High_Quality_Lightning
IniRead, Per_Pixel_Lightning_Attenuation, settings.ini, %MyDropdown%, Per_Pixel_Lightning_Attenuation
IniRead, Specular_Lightning___Player_Mesh_Combining, settings.ini, %MyDropdown%, Specular_Lightning___Player_Mesh_Combining
IniRead, Surface_Reflections, settings.ini, %MyDropdown%, Surface_Reflections
IniRead, Landscape_Lightning_Quality, settings.ini, %MyDropdown%, Landscape_Lightning_Quality
IniRead, DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning, settings.ini, %MyDropdown%, DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning
IniRead, Landscape_Shadows, settings.ini, %MyDropdown%, Landscape_Shadows
IniRead, Blob_Shadows___Environment_Stencil_Shadows, settings.ini, %MyDropdown%, Blob_Shadows___Environment_Stencil_Shadows
IniRead, Stencil_Shadows, settings.ini, %MyDropdown%, Stencil_Shadows
IniRead, DX10_Dynamic_Shadows, settings.ini, %MyDropdown%, DX10_Dynamic_Shadows
IniRead, Dynamic_Particle_Rendering, settings.ini, %MyDropdown%, Dynamic_Particle_Rendering
IniRead, Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects, settings.ini, %MyDropdown%, Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects
IniRead, Glow_Mapping___Overbright_Bloom_Filter, settings.ini, %MyDropdown%, Glow_Mapping___Overbright_Bloom_Filter
IniRead, Blur_Filter_Quality, settings.ini, %MyDropdown%, Blur_Filter_Quality
IniRead, Bloom_Intensity, settings.ini, %MyDropdown%, Bloom_Intensity
IniRead, Avatar_Update_Visible___Avatar_Texture_Compositing, settings.ini, %MyDropdown%, Avatar_Update_Visible___Avatar_Texture_Compositing
IniRead, 3D_Object_Portraits, settings.ini, %MyDropdown%, 3D_Object_Portraits
IniRead, Texture_Cache_Size, settings.ini, %MyDropdown%, Texture_Cache_Size
IniRead, Player_Crowd_Quality, settings.ini, %MyDropdown%, Player_Crowd_Quality
IniRead, Maximum_Framerate, settings.ini, %MyDropdown%, Maximum_Framerate
IniRead, Maximum_Framerate_Safe_Value, settings.ini, %MyDropdown%, Maximum_Framerate_Safe_Value

    If (moduleBase="")
        moduleBase := mem.getModuleBaseAddress("lotroclient64.exe")

If Antialiasing_1 IN 0,1,3,7
    mem.write(moduleBase + 0x19800FC, Antialiasing_1, "UInt")
If Antialiasing_2 IN 0,1,3,7
    mem.write(moduleBase + 0x1DB5DD0, Antialiasing_2, "UInt")
If Ambient_Light between 0.0 and 1.0
    mem.write(moduleBase + 0x1980A90, Ambient_Light, "UFloat")
If Brightness between 0.0 and 2.0
    mem.write(moduleBase + 0x1980A88, Brightness, "UFloat")
If Contrast between 0.0 and 2.0
    mem.write(moduleBase + 0x1980A8C, Contrast, "UFloat")
If Gamma_Level between 0.0 and 4.4
    mem.write(moduleBase + 0x1980A84, Gamma_Level, "UFloat")

If Object_Draw_Distance IN 0,1,2,3,4
    mem.write(moduleBase + 0x1980A5C, Object_Draw_Distance, "UInt")
If Model_Detail IN 0,1,2,3,4
    mem.write(moduleBase + 0x1980A50, Model_Detail, "UInt")
If Material_Detail IN 0,1
    mem.write(moduleBase + 0x1980A4C, Material_Detail, "UInt")
If Landscape_Draw_Distance IN 0,1,2,3,4
    mem.write(moduleBase + 0x1980A60, Landscape_Draw_Distance, "UInt")
If Frill_Distance IN 0,1,2,3,4,5
    mem.write(moduleBase + 0x1980A68, Frill_Distance, "UInt")
If Frill_Density between 0.0 and 1.0
    mem.write(moduleBase + 0x1980A6C, Frill_Density, "UFloat")
If Distant_Imposters IN 0,1
    mem.write(moduleBase + 0x1980A64, Distant_Imposters, "UInt")
If Atmospherics_Detail IN 0,1,2
    mem.write(moduleBase + 0x1980ACC, Atmospherics_Detail, "UInt")
If DX11_Interactive_Water IN 0,1,2,3
    mem.write(moduleBase + 0x1980A80, DX11_Interactive_Water, "UInt")
If Texture_Detail IN 0,1,2,3,4
    mem.write(moduleBase + 0x1980A48, Texture_Detail, "UInt")
If Texture_Filtering IN 0,1,2,3,4
    mem.write(moduleBase + 0x1980A34, Texture_Filtering, "UInt")
If Anistropic_Filter_Quality is integer
    If Anistropic_Filter_Quality between 1 and 16
        mem.write(moduleBase + 0x1980A38, Anistropic_Filter_Quality, "UInt")
If High_Quality_Lightning IN 0,1,256,257
    mem.write(moduleBase + 0x1980A94, High_Quality_Lightning, "UInt")
If Per_Pixel_Lightning_Attenuation IN 0,1,256,257
    mem.write(moduleBase + 0x1980AE4, Per_Pixel_Lightning_Attenuation, "UInt")
If Specular_Lightning___Player_Mesh_Combining IN 0,1,256,257
    mem.write(moduleBase + 0x1980AD4, Specular_Lightning___Player_Mesh_Combining, "UInt")
If Surface_Reflections IN 0,1,2,3,4
    mem.write(moduleBase + 0x1980A54, Surface_Reflections, "UInt")
If Landscape_Lightning_Quality IN 0,1,2
    mem.write(moduleBase + 0x1980A78, Landscape_Lightning_Quality, "UInt")
If DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning IN 0,1,256,257,65536,65537,65792,65793
    mem.write(moduleBase + 0x1980A7C, DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning, "UInt")
If Landscape_Shadows IN 0,1,2,3
    mem.write(moduleBase + 0x1980A74, Landscape_Shadows, "UInt")
If Blob_Shadows___Environment_Stencil_Shadows IN 0,1,256,257
    mem.write(moduleBase + 0x1980A40, Blob_Shadows___Environment_Stencil_Shadows, "UInt")
If Stencil_Shadows IN 0,1,2,3,4,5
    mem.write(moduleBase + 0x1980A3C, Stencil_Shadows, "UInt")
If DX10_Dynamic_Shadows IN 0,1,2
    mem.write(moduleBase + 0x1980A44, DX10_Dynamic_Shadows, "UInt")
If Dynamic_Particle_Rendering IN 0,1,2,3,4
    mem.write(moduleBase + 0x1980A98, Dynamic_Particle_Rendering, "UInt")
If Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects IN 0,1,256,257,65536,65537,65792,65793
    mem.write(moduleBase + 0x1980A9C, Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects, "UInt")
If Glow_Mapping___Overbright_Bloom_Filter IN 0,1,256,257
    mem.write(moduleBase + 0x1980AC8, Glow_Mapping___Overbright_Bloom_Filter, "UInt")
If Blur_Filter_Quality IN 0,1,2
    mem.write(moduleBase + 0x1980AD0, Blur_Filter_Quality, "UInt")
If Bloom_Intensity between 0.0 and 2.0
    mem.write(moduleBase + 0x1980AC4, Bloom_Intensity, "UFloat")
If Avatar_Update_Visible___Avatar_Texture_Compositing IN 16842752,16842753,16843008,16843009
    mem.write(moduleBase + 0x1980A0C, Avatar_Update_Visible___Avatar_Texture_Compositing, "UInt")
If 3D_Object_Portraits IN 0,1
    mem.write(moduleBase + 0x1980ADE, 3D_Object_Portraits, "UChar")
If Texture_Cache_Size between 0.0 and 1.0
    mem.write(moduleBase + 0x1980AE0, Texture_Cache_Size, "UFloat")
If Player_Crowd_Quality between 0.0 and 2.0
    mem.write(moduleBase + 0x1980AD8, Player_Crowd_Quality, "UFloat")

If Maximum_Framerate is integer
    If Maximum_Framerate between 0 and 9999
        mem.write(moduleBase + 0x1DB2EF4, Maximum_Framerate, "UInt")
If Maximum_Framerate_Safe_Value is integer
    If Maximum_Framerate_Safe_Value between 0 and 9999
        mem.write(moduleBase + 0x19800BC, Maximum_Framerate_Safe_Value, "UInt")

Gui, Destroy

return
