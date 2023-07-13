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

    InputBox, SettingsName , Safe your Settings, Please provide a name to save your preset., , , , , , Locale
    If (SettingsName="")
        Return

    If (moduleBase=""){
        moduleBase := mem.getModuleBaseAddress("lotroclient64.exe")
        AddressBase := 0x014C9E18
        Offset1:= 0x3F8
    }

    DirectXVersion:=mem.read(moduleBase + AddressBase, "UInt", Offset1)
;--------------------------------------------------------------------------------
    Antialiasing:=mem.read(moduleBase + 0x01DC5370, "UInt", 0x78, 0x90, 0x258, 0x14)
    Ambient_Light:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x60)
    Brightness:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x58)
    Contrast:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x5C)
    Gamma_Level:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x54)

    Object_Draw_Distance:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x2C)
    Model_Detail:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x20)
    Material_Detail:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x1C)
    Landscape_Draw_Distance:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x30)
    Frill_Distance:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x38)
    Frill_Density:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x3C)
    Distant_Imposters:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x34)
    Atmospherics_Detail:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x9C)
    DX11_Interactive_Water:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x50)
    Texture_Detail:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x18)
    Texture_Filtering:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x4)
    Anistropic_Filter_Quality:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x8)
    High_Quality_Lightning:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x64)
    Per_Pixel_Lightning_Attenuation:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0xB4)
    Specular_Lightning___Player_Mesh_Combining:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0xA4)
    Surface_Reflections:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x24)
    Landscape_Lightning_Quality:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x48)
    DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x4C)
    Landscape_Shadows:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x44)
    Blob_Shadows___Environment_Stencil_Shadows:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x10)
    Stencil_Shadows:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0xC)
    DX10_Dynamic_Shadows:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x14)
    Dynamic_Particle_Rendering:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x68)
    Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x6C)
    Glow_Mapping___Overbright_Bloom_Filter:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x98)
    Blur_Filter_Quality:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0xA0)
    Bloom_Intensity:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x94)
;--------------------------------------------------------------------------------
    Avatar_Update_Visible___Avatar_Texture_Compositing:=mem.read(moduleBase + 0x01DB4410, "UInt", 0x68, 0x48, 0x28, 0xB0, 0x18, 0x0)
    3D_Object_Portraits:=mem.read(moduleBase + AddressBase, "UChar", Offset1 + 0xAC)
    Texture_Cache_Size:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0xB0)
    Player_Crowd_Quality:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0xA8)

;--------------------------------------------------------------------------------
    Maximum_Framerate:=mem.read(moduleBase + 0x01DB3E18, "UInt", 0x130, 0x110, 0x70, 0x8, 0x50, 0x8, 0x154)

IniWrite, 
(
`tDirectXVersion=%DirectXVersion%
`tAntialiasing=%Antialiasing%
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
If (OutputVarSectionNames="")
    {
    MsgBox You have not saved any preset yet.
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
Gui, +AlwaysOnTop
Gui, Add, Text, Center, Which preset would you like to load?
Gui, Add, DropDownList, vMyDropdown w160 x20, %DropDownSelectionINI%
Gui, Add, Button, Default w80 x60, OK
Gui, Show, w200 h80

}
Return



ButtonOK:
Gui, Submit
IniRead, DirectXVersion, settings.ini, %MyDropdown%, DirectXVersion
IniRead, Antialiasing, settings.ini, %MyDropdown%, Antialiasing
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

If (moduleBase=""){
    moduleBase := mem.getModuleBaseAddress("lotroclient64.exe")
    AddressBase := 0x014C9E18
    Offset1:= 0x3F8
}

DirectXVersion_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1)
;--------------------------------------------------------------------------------
Antialiasing_mem:=mem.read(moduleBase + 0x01DC5370, "UInt", 0x78, 0x90, 0x258, 0x14)
Ambient_Light_mem:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x60)
Brightness_mem:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x58)
Contrast_mem:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x5C)
Gamma_Level_mem:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x54)

Object_Draw_Distance_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x2C)
Model_Detail_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x20)
Material_Detail_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x1C)
Landscape_Draw_Distance_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x30)
Frill_Distance_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x38)
Frill_Density_mem:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x3C)
Distant_Imposters_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x34)
Atmospherics_Detail_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x9C)
DX11_Interactive_Water_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x50)
Texture_Detail_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x18)
Texture_Filtering_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x4)
Anistropic_Filter_Quality_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x8)
High_Quality_Lightning_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x64)
Per_Pixel_Lightning_Attenuation_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0xB4)
Specular_Lightning___Player_Mesh_Combining_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0xA4)
Surface_Reflections_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x24)
Landscape_Lightning_Quality_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x48)
DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x4C)
Landscape_Shadows_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x44)
Blob_Shadows___Environment_Stencil_Shadows_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x10)
Stencil_Shadows_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0xC)
DX10_Dynamic_Shadows_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x14)
Dynamic_Particle_Rendering_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x68)
Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x6C)
Glow_Mapping___Overbright_Bloom_Filter_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0x98)
Blur_Filter_Quality_mem:=mem.read(moduleBase + AddressBase, "UInt", Offset1 + 0xA0)
Bloom_Intensity_mem:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0x94)
;--------------------------------------------------------------------------------
Avatar_Update_Visible___Avatar_Texture_Compositing_mem:=mem.read(moduleBase + 0x01DB4410, "UInt", 0x68, 0x48, 0x28, 0xB0, 0x18, 0x0)
3D_Object_Portraits_mem:=mem.read(moduleBase + AddressBase, "UChar", Offset1 + 0xAC)
Texture_Cache_Size_mem:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0xB0)
Player_Crowd_Quality_mem:=mem.read(moduleBase + AddressBase, "UFloat", Offset1 + 0xA8)

;--------------------------------------------------------------------------------
Maximum_Framerate_mem:=mem.read(moduleBase + 0x01DB3E18, "UInt", 0x130, 0x110, 0x70, 0x8, 0x50, 0x8, 0x154)



If Antialiasing IN 0,1,3,7
    If Antialiasing_mem IN 0,1,3,7
        mem.write(moduleBase + 0x01DC5370, Antialiasing, "UInt", 0x78, 0x90, 0x258, 0x14)
If Ambient_Light between 0.0 and 1.0
    If Ambient_Light_mem between 0.0 and 1.0
        mem.write(moduleBase + AddressBase, Ambient_Light, "UFloat", Offset1 + 0x60)
If Brightness between 0.0 and 2.0
    If Brightness_mem between 0.0 and 2.0
        mem.write(moduleBase + AddressBase, Brightness, "UFloat", Offset1 + 0x58)
If Contrast between 0.0 and 2.0
    If Contrast_mem between 0.0 and 2.0
        mem.write(moduleBase + AddressBase, Contrast, "UFloat", Offset1 + 0x5C)
If Gamma_Level between 0.0 and 4.4
    If Gamma_Level_mem between 0.0 and 4.4
        mem.write(moduleBase + AddressBase, Gamma_Level, "UFloat", Offset1 + 0x54)

If Object_Draw_Distance IN 0,1,2,3,4
    If Object_Draw_Distance_mem IN 0,1,2,3,4
        mem.write(moduleBase + AddressBase, Object_Draw_Distance, "UInt", Offset1 + 0x2C)
If Model_Detail IN 0,1,2,3,4
    If Model_Detail_mem IN 0,1,2,3,4
        mem.write(moduleBase + AddressBase, Model_Detail, "UInt", Offset1 + 0x20)
If Material_Detail IN 0,1
    If Material_Detail_mem IN 0,1
        mem.write(moduleBase + AddressBase, Material_Detail, "UInt", Offset1 + 0x1C)
If Landscape_Draw_Distance IN 0,1,2,3,4
    If Landscape_Draw_Distance_mem IN 0,1,2,3,4
        mem.write(moduleBase + AddressBase, Landscape_Draw_Distance, "UInt", Offset1 + 0x30)
If Frill_Distance IN 0,1,2,3,4,5
    If Frill_Distance_mem IN 0,1,2,3,4,5
        mem.write(moduleBase + AddressBase, Frill_Distance, "UInt", Offset1 + 0x38)
If Frill_Density between 0.0 and 1.0
    If Frill_Density_mem between 0.0 and 1.0
        mem.write(moduleBase + AddressBase, Frill_Density, "UFloat", Offset1 + 0x3C)
If Distant_Imposters IN 0,1
    If Distant_Imposters_mem IN 0,1
        mem.write(moduleBase + AddressBase, Distant_Imposters, "UInt", Offset1 + 0x34)
If Atmospherics_Detail IN 0,1,2
    If Atmospherics_Detail_mem IN 0,1,2
        mem.write(moduleBase + AddressBase, Atmospherics_Detail, "UInt", Offset1 + 0x9C)
If DX11_Interactive_Water IN 0,1,2,3
    If DX11_Interactive_Water_mem IN 0,1,2,3
        mem.write(moduleBase + AddressBase, DX11_Interactive_Water, "UInt", Offset1 + 0x50)
If Texture_Detail IN 0,1,2,3,4
    If Texture_Detail_mem IN 0,1,2,3,4
        mem.write(moduleBase + AddressBase, Texture_Detail, "UInt", Offset1 + 0x18)
If Texture_Filtering IN 0,1,2,3,4
    If Texture_Filtering_mem IN 0,1,2,3,4
        mem.write(moduleBase + AddressBase, Texture_Filtering, "UInt", Offset1 + 0x4)
If Anistropic_Filter_Quality is integer
    If Anistropic_Filter_Quality between 1 and 16
        If Anistropic_Filter_Quality_mem is integer
            If Anistropic_Filter_Quality_mem between 1 and 16
                mem.write(moduleBase + AddressBase, Anistropic_Filter_Quality, "UInt", Offset1 + 0x8)
If High_Quality_Lightning IN 0,1,256,257
    If High_Quality_Lightning_mem IN 0,1,256,257
        mem.write(moduleBase + AddressBase, High_Quality_Lightning, "UInt", Offset1 + 0x64)
If Per_Pixel_Lightning_Attenuation IN 0,1,256,257
    If Per_Pixel_Lightning_Attenuation_mem IN 0,1,256,257
        mem.write(moduleBase + AddressBase, Per_Pixel_Lightning_Attenuation, "UInt", Offset1 + 0xB4)
If Specular_Lightning___Player_Mesh_Combining IN 0,1,256,257
    If Specular_Lightning___Player_Mesh_Combining_mem IN 0,1,256,257
        mem.write(moduleBase + AddressBase, Specular_Lightning___Player_Mesh_Combining, "UInt", Offset1 + 0xA4)
If Surface_Reflections IN 0,1,2,3,4
    If Surface_Reflections_mem IN 0,1,2,3,4
        mem.write(moduleBase + AddressBase, Surface_Reflections, "UInt", Offset1 + 0x24)
If Landscape_Lightning_Quality IN 0,1,2
    If Landscape_Lightning_Quality_mem IN 0,1,2
        mem.write(moduleBase + AddressBase, Landscape_Lightning_Quality, "UInt", Offset1 + 0x48)
If DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning IN 0,1,256,257,65536,65537,65792,65793
    If DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning_mem IN 0,1,256,257,65536,65537,65792,65793
        mem.write(moduleBase + AddressBase, DX10_Distant_Landscape_Lightning___DX11_Ambient_Occlusion___Volumetric_Sun_Lightning, "UInt", Offset1 + 0x4C)
If Landscape_Shadows IN 0,1,2,3
    If Landscape_Shadows_mem IN 0,1,2,3
        mem.write(moduleBase + AddressBase, Landscape_Shadows, "UInt", Offset1 + 0x44)
If Blob_Shadows___Environment_Stencil_Shadows IN 0,1,256,257
    If Blob_Shadows___Environment_Stencil_Shadows_mem IN 0,1,256,257
        mem.write(moduleBase + AddressBase, Blob_Shadows___Environment_Stencil_Shadows, "UInt", Offset1 + 0x10)
If Stencil_Shadows IN 0,1,2,3,4,5
    If Stencil_Shadows_mem IN 0,1,2,3,4,5
        mem.write(moduleBase + AddressBase, Stencil_Shadows, "UInt", Offset1 + 0xC)
If DX10_Dynamic_Shadows IN 0,1,2
    If DX10_Dynamic_Shadows_mem IN 0,1,2
        mem.write(moduleBase + AddressBase, DX10_Dynamic_Shadows, "UInt", Offset1 + 0x14)
If Dynamic_Particle_Rendering IN 0,1,2,3,4
    If Dynamic_Particle_Rendering_mem IN 0,1,2,3,4
        mem.write(moduleBase + AddressBase, Dynamic_Particle_Rendering, "UInt", Offset1 + 0x68)
If Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects IN 0,1,256,257,65536,65537,65792,65793
    If Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects_mem IN 0,1,256,257,65536,65537,65792,65793
        mem.write(moduleBase + AddressBase, Static_Environmental_Objects___Precipitation_Effects___Post_Processing_Effects, "UInt", Offset1 + 0x6C)
If Glow_Mapping___Overbright_Bloom_Filter IN 0,1,256,257
    If Glow_Mapping___Overbright_Bloom_Filter_mem IN 0,1,256,257
        mem.write(moduleBase + AddressBase, Glow_Mapping___Overbright_Bloom_Filter, "UInt", Offset1 + 0x98)
If Blur_Filter_Quality IN 0,1,2
    If Blur_Filter_Quality_mem IN 0,1,2
        mem.write(moduleBase + AddressBase, Blur_Filter_Quality, "UInt", Offset1 + 0xA0)
If Bloom_Intensity between 0.0 and 2.0
    If Bloom_Intensity_mem between 0.0 and 2.0
        mem.write(moduleBase + AddressBase, Bloom_Intensity, "UFloat", Offset1 + 0x94)
If Avatar_Update_Visible___Avatar_Texture_Compositing IN 16842752,16842753,16843008,16843009
    If Avatar_Update_Visible___Avatar_Texture_Compositing_mem IN 16842752,16842753,16843008,16843009
        mem.write(moduleBase + 0x01DB4410, Avatar_Update_Visible___Avatar_Texture_Compositing, "UInt", 0x68, 0x48, 0x28, 0xB0, 0x18, 0x0)
If 3D_Object_Portraits IN 0,1
    If 3D_Object_Portraits_mem IN 0,1
        mem.write(moduleBase + AddressBase, 3D_Object_Portraits, "UChar", Offset1 + 0xAC)
If Texture_Cache_Size between 0.0 and 1.0
    If Texture_Cache_Size_mem between 0.0 and 1.0
        mem.write(moduleBase + AddressBase, Texture_Cache_Size, "UFloat", Offset1 + 0xB0)
If Player_Crowd_Quality between 0.0 and 2.0
    If Player_Crowd_Quality_mem between 0.0 and 2.0
        mem.write(moduleBase + AddressBase, Player_Crowd_Quality, "UFloat", Offset1 + 0xA8)

If Maximum_Framerate is integer
    If Maximum_Framerate between 0 and 9999
        If Maximum_Framerate_mem is integer
            If Maximum_Framerate_mem between 0 and 9999
                mem.write(moduleBase + 0x01DB3E18, Maximum_Framerate, "UInt", 0x130, 0x110, 0x70, 0x8, 0x50, 0x8, 0x154)

Gui, Destroy

return