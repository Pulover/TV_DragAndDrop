;========================================================================
;
; 				TreeView Browser
;
; Author:		Pulover [Rodolfo U. Batista]
;				rodolfoub@gmail.com
;
; Requires CreateTreeView.ahk (Thanks Learning one for this function)
; http://www.autohotkey.com/board/topic/92863-function-createtreeview/
;
;========================================================================

#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1

; Customize File Extension (optional)
CustomExt = tvb

Menu, MoveCopyMenu, Add, Move here, MoveNodes
Menu, MoveCopyMenu, Add, Copy here, CopyNodes

ImageListID := IL_Create(10)
Gui, +Resize +MinSize260x60
Gui, Add, Button, Default w70 gLoadFolder, Load Folder
Gui, Add, Button, w70 yp xp+85 gLoadFile, Load File
Gui, Add, Button, w70 yp xp+85 gSaveFile, Save File
Gui, Add, Checkbox, Checked yp+5 xp+85 vLoadIcons gLoadIcons, Load Icons
Gui, Add, TreeView, xm h400 w300 ImageList%ImageListID% hwndTreeHwnd vTreeView gNotifications
Gui, Show,, TreeView Browser
return

Notifications:
If (A_Guievent = "D")
{
	Origin := A_EventInfo
    Target := TV_Drag(Origin, A_Guievent)
	Expanded := TV_Get(Origin, "Expand") = Origin

	If (A_Guievent == "d")
	{
		Menu, MoveCopyMenu, Show
		return
	}
	GuiControl, -Redraw, TreeView
    TV_Drop(Origin, Target,,, Expanded)
	GuiControl, +Redraw, TreeView
}
return

MoveNodes:
GuiControl, -Redraw, TreeView
TV_Drop(Origin, Target, TreeHwnd,, Expanded)
GuiControl, +Redraw, TreeView
return

CopyNodes:
GuiControl, -Redraw, TreeView
TV_Drop(Origin, Target, TreeHwnd, True, Expanded)
GuiControl, +Redraw, TreeView
return

LoadFolder:
Gui, Submit, NoHide
Gui, +OwnDialogs
FileSelectFolder, TreeRoot, *%A_MyDocuments%
if !TreeRoot
	return
TV_Delete()
Progress, M H80 W600 FS10,, Loading folders & files..., TreeView Browser
TVString := CreateString(TreeRoot)
Progress, Off
CreateTreeView(TVString)
return

LoadFile:
Gui, Submit, NoHide
Gui, +OwnDialogs
FileSelectFile, StrFile,,, Load File, TreeView (*.%CustomExt%)
if !StrFile
	return
TV_Delete()
TVString := ""
Progress, M H80 W600 FS10,, % "Loading tree" (LoadIcons ? " & icons" : "") "...", TreeView Browser
Loop, Read, %StrFile%
{
	RegExMatch(A_LoopReadLine, "\t+([^\t]+)", Line)
	TVString .= RegExReplace(A_LoopReadLine, "\tIcon\d+")
	. (LoadIcons ? "`tIcon" GetIcon(Line1) : "") "`n"
	Progress, %A_Index%, %Line1%
}
Progress, Off
CreateTreeView(TVString)
return

SaveFile:
Gui, +OwnDialogs
FileSelectFile, SaveFile, S16, TreeView.%CustomExt%, Save File, TreeView (*.%CustomExt%)
If !SaveFile
	return
SplitPath, SaveFile,,, ext
If (ext <> CustomExt)
	SaveFile .= "." CustomExt
IfExist %SaveFile%
	FileDelete %SaveFile%
FileAppend, %TVString%, %SaveFile%, UTF-8
return

LoadIcons:
Gui, Submit, NoHide
If LoadIcons
	TV_SetImageList(ImageListID)
Else
	TV_SetImageList(0)
return

GuiSize:
if A_EventInfo = 1
    return
GuiControl, Move, TreeView, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 40)
return

GuiClose:
ExitApp

CreateString(Folder, Call=0)
{
	global LoadIcons
	
	Call++
	Loop, %Folder%\*.*, 1
	{
		Progress, %A_Index%, %A_LoopFileDir%
		If LoadIcons
			Icon := "`tIcon" GetIcon(A_LoopFileFullPath)
		If InStr(FileExist(A_LoopFileFullPath), "D")
		{
			Loop, %Call%
				String .= "`t"
			String .= A_LoopFileName . Icon "`n"
			String .= CreateString(A_LoopFileFullPath, Call)
		}
		Else
		{
			Loop, %Call%
				Files .= "`t"
			Files .= A_LoopFileName . Icon "`n"
		}
	}
	String .= Files
	Call--
	return String
}

GetIcon(FileName)
{
	global ImageListID

	sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
	VarSetCapacity(sfi, sfi_size)
	SplitPath, FileName,,, FileExt
	if FileExt in EXE,ICO,ANI,CUR
	{
		ExtID := FileExt
		IconNumber = 0
	}
	else
	{
		ExtID = 0
		Loop 7
		{
			StringMid, ExtChar, FileExt, A_Index, 1
			If not ExtChar
				break
			ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
		}
		IconNumber := IconArray%ExtID%
	}
	If not IconNumber
	{
		if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str",  "." FileExt
			, "uint", (FileExt ? 0x80 : 0), "ptr", &sfi, "uint", sfi_size, "uint", (FileExt ? 0x111 : 0x101))
			IconNumber = 9999999
		else
		{
			hIcon := NumGet(sfi, 0)
			IconNumber := DllCall("ImageList_ReplaceIcon", "ptr", ImageListID, "int", -1, "ptr", hIcon) + 1
			DllCall("DestroyIcon", "ptr", hIcon)
			IconArray%ExtID% := IconNumber
		}
	}
	return IconNumber
}

CreateTreeView(TreeViewDefinitionString) {	; by Learning one
	IDs := {} 
	Loop, parse, TreeViewDefinitionString, `n, `r
	{
		if A_LoopField is space
			continue
		Item := RTrim(A_LoopField, A_Space A_Tab), Item := LTrim(Item, A_Space), Level := 0
		While (SubStr(Item,1,1) = A_Tab)
			Level += 1,	Item := SubStr(Item, 2)
		RegExMatch(Item, "([^`t]*)([`t]*)([^`t]*)", match)	; match1 = ItemName, match3 = Options
		if (Level=0)
			IDs["Level0"] := TV_Add(match1, 0, match3)
		else
			IDs["Level" Level] := TV_Add(match1, IDs["Level" Level-1], match3)
	}
}	; http://www.autohotkey.com/board/topic/92863-function-createtreeview/

#Include ..\TV_DragAndDrop.ahk