#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

Gui, Add, TreeView, hwndhTree gNotifications W180 H280
P1 := TV_Add("First parent")
P1C1 := TV_Add("Parent 1's first child", P1)  ; Specify P1 to be this item's parent.
P2 := TV_Add("Second parent")
P2C1 := TV_Add("Parent 2's first child", P2)
P2C2 := TV_Add("Parent 2's second child", P2)
P2C2C1 := TV_Add("Child 2's first child", P2C2)

Gui, Show, W200 H300  ; Show the window and its TreeView.
return

Notifications:
If (A_Guievent = "D")
{
    HitTarget := TV_Drag(A_EventInfo)
    TV_Drop(A_EventInfo, HitTarget, hTree)
}
return

GuiClose:  ; Exit the script when the user closes the TreeView's GUI window.
ExitApp

#Include ../TV_DragAndDrop.ahk