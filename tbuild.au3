#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ThinApp.ico
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>

Opt("GUIOnEventMode", 1)

$AppCaption = "ThinApp project builder/relinker by Nomadic"

$DirList = _FileListToArray(@ScriptDir, "*", 2)
If @error = 4 Then
	MsgBox(16, $AppCaption, "ThinApp build's dir not found!")
	Exit
EndIf

$VerList = ""
$LastVer = ""
For $i = 1 To $DirList[0]
	If FileExists(@ScriptDir & "\" & $DirList[$i] & "\tlink.exe") Then
		$LastVer = $DirList[$i]
		$VerList = $VerList & "|" & $LastVer
	EndIf
Next

#region ### START Koda GUI section ###
$MainForm = GUICreate($AppCaption, 389, 114, -1, -1, Default, $WS_EX_ACCEPTFILES)
GUISetOnEvent($GUI_EVENT_DROPPED, "Dropped")
GUISetOnEvent($GUI_EVENT_CLOSE, "ButtonExitClick")
$Group1 = GUICtrlCreateGroup(" Project Path ", 8, 8, 369, 57)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
$InputDir = GUICtrlCreateInput("", 16, 32, 321, 21)
GUICtrlSetOnEvent($InputDir, "InputDirChange")
$ButtonDir = GUICtrlCreateButton("...", 344, 30, 27, 25)
GUICtrlSetOnEvent($ButtonDir, "ButtonDirClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$ButtonBuild = GUICtrlCreateButton("Build", 224, 76, 75, 25)
GUICtrlSetState($ButtonBuild, $GUI_DISABLE)
GUICtrlSetOnEvent($ButtonBuild, "ButtonBuildClick")
$ButtonExit = GUICtrlCreateButton("Exit", 304, 76, 75, 25)
GUICtrlSetOnEvent($ButtonExit, "ButtonExitClick")
$ComboVer = GUICtrlCreateCombo("", 96, 78, 105, 25, $CBS_DROPDOWNLIST + $WS_VSCROLL)
GUICtrlSetData($ComboVer, $VerList, $LastVer)
$Label1 = GUICtrlCreateLabel("ThinApp version", 8, 80, 81, 17)
GUISetState(@SW_SHOW)
#endregion ### END Koda GUI section ###

While 1
	Sleep(100)
WEnd

Func ButtonBuildClick()
	GUICtrlSetState($ButtonBuild, $GUI_DISABLE)
	GUICtrlSetState($ComboVer, $GUI_DISABLE)
	GUICtrlSetState($InputDir, $GUI_DISABLE)
	$filename = GUICtrlRead($InputDir)
	$tversion = GUICtrlRead($ComboVer)
	$WorkDir = StringRegExpReplace($filename, "\\[^\\]*$", "")
	If GUICtrlRead($ButtonBuild) = "Build" Then
		If Not FileExists($WorkDir & '\bin\') Then DirCreate($WorkDir & '\bin\')
		If (FileExists(@ScriptDir & '\' & $tversion & '\vregtool.exe')) And (FileExists(@ScriptDir & '\' & $tversion & '\vftool.exe')) Then
			$Return = RunWait(@ScriptDir & '\' & $tversion & '\vregtool.exe "' & $WorkDir & '\bin\Package.ro.tvr" ImportDir "' & $WorkDir & '"')
			If $Return = 0 Then
				$Return = RunWait(@ScriptDir & '\' & $tversion & '\vftool.exe "' & $WorkDir & '\bin\Package.ro.tvr" ImportDir "' & $WorkDir & '"')
				If $Return = 0 Then
					$Return = RunWait(@ScriptDir & '\' & $tversion & '\tlink.exe "' & $filename & '" -OutDir "' & $WorkDir & '\bin"')
				EndIf
			EndIf
			FileDelete($WorkDir & '\bin\*.tvr')
			FileDelete($WorkDir & '\bin\*.tvr.thfd')
		Else
			MsgBox(16, $AppCaption, @ScriptDir & '\' & $tversion & '\vregtool.exe or vftool.exe not found!')
		EndIf
	Else
		If FileExists(@ScriptDir & '\' & $tversion & '\relink.exe') Then
			RunWait(@ScriptDir & '\' & $tversion & '\relink.exe "' & $filename & '"')
		Else
			MsgBox(16, $AppCaption, @ScriptDir & '\' & $tversion & '\relink.exe not found!')
		EndIf
	EndIf
	GUICtrlSetState($ButtonBuild, $GUI_ENABLE)
	GUICtrlSetState($ComboVer, $GUI_ENABLE)
	GUICtrlSetState($InputDir, $GUI_ENABLE)
EndFunc   ;==>ButtonBuildClick

Func ButtonDirClick()
	$filename = FileOpenDialog("Select ThinApp project file...", "", "ThinApp files (Package.ini;*.exe;)|All files (*.*)")
	If $filename <> "" Then GUICtrlSetData($InputDir, $filename)
	InputDirChange()
EndFunc   ;==>ButtonDirClick

Func ButtonExitClick()
	Exit
EndFunc   ;==>ButtonExitClick

Func InputDirChange()
	$filename = GUICtrlRead($InputDir)
	If (FileExists($filename)) And (Not StringInStr(FileGetAttrib($filename), "D")) Then
		GUICtrlSetState($ButtonBuild, $GUI_ENABLE)
		If StringLower(StringRight($filename, 3)) = 'ini' Then
			GUICtrlSetData($ButtonBuild, "Build")
		ElseIf StringLower(StringRight($filename, 3)) = 'exe' Then
			GUICtrlSetData($ButtonBuild, "Relink")
		Else
			GUICtrlSetState($ButtonBuild, $GUI_DISABLE)
		EndIf
	Else
		GUICtrlSetState($ButtonBuild, $GUI_DISABLE)
	EndIf
EndFunc   ;==>InputDirChange

Func Dropped()
	$filename = @GUI_DragFile
	If $filename <> "" Then GUICtrlSetData($InputDir, $filename)
	InputDirChange()
EndFunc   ;==>Dropped
