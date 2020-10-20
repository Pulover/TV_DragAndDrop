#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

Gui, Add, TreeView, gNotifications W180 H180 Checked
P1 := TV_Add("First parent")
P1C1 := TV_Add("Parent 1's first child", P1)
P2 := TV_Add("Second parent")
P2C1 := TV_Add("Parent 2's first child", P2)
P2C2 := TV_Add("Parent 2's second child", P2)
P2C2C1 := TV_Add("Child 2's first child", P2C2)

Gui, Show, W200 H200
return

Notifications:
If (A_Guievent = "D")
{
    Target := TV_Drag(A_EventInfo)
    TV_Drop(A_EventInfo, Target)
}
return

GuiClose:
ExitApp

#Include ../TV_DragAndDrop.ahk