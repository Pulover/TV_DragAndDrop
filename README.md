# TV_DragAndDrop

## Drag & Drop function for TreeView controls

AHK version: 1.1.32.00

## Public Functions
* TV_Drag(Origin [DragButton, AutoDrop, LineThick, Color])
* TV_Drop(Origin, Target [, Hwnd, Copy, Expand, FirstChild])

- - -

## Usage
Call **TV_Drag()** from the TreeView's G-Label when A_GuiEvent contains "D" or "d". A line will show across the TreeView while holding the button to indicate the destination where the selected node will be dropped with its children.

If you point the mouse cursor to the half bottom part of the node text it will be dropped as a child of the pointed node. If you point it to the upper part it will drop it as sibling right below the pointed node.
    
**TV_Drag()** returns the target node id (if valid) which you can use to call **TV_Drop()** and effectively move the selection. Alternatively you can set AutoDrop option on as a shorthand.

Separating the Drag and Drop calls allows to check if the returned destination is a valid node to drop in as well as setting `GuiControl, -Redraw` to avoid flickering.

**TV_Drop()** may be called directly to move or copy nodes programmatically. You may pass the TreeView control's hwnd to keep icons and set Copy parameter to true if you want to copy nodes instead of moving.

## TV_Drag()
Drags the selected item showing a destination bar. Must be called in the TreeView G-Label subroutine when A_GuiEvent returns "D" or "d".

### Parameters
* **Origin** - The ID of the selected item. Simply pass A_EventInfo.
* **DragButton** - If it is a lower case "d" it will be recognized as a Right-Click drag, otherwise it will be recognized as a Left-Click drag. You may pass A_GuiEvent as the parameter.
* **AutoDrop** - Set to True to automatically drop the items into the selected position. This is set off by default to allow to check if the returned destination is a valid node to drop in.
* **LineThick** - Thickness of the destination bar in pixels. Default is 2px.
* **Color** - Color of destination bar. Default is "Black".

### Return
The ID of the destination item. If dropping as a sibling it returns a negative version of the ID.

## TV_Drop()
Drops the selected item on to the destination node as a child, if positive, or as a sibling, if negative.

### Parameters
* **Origin** - The ID of the selected item. Simply pass A_EventInfo.
* **Target** - The ID of the dragged item returned by TV_Drag(). To drop the item as sibling below the target instead of as a child, make the ID a negative number.
* **Hwnd** - The hwnd of the TreeView (necessary for keeping the icons of moved/copied nodes). If omitted the hwnd of the control under the mouse cursor will be used.
* **Copy** - If *True*, it will drop a copy of the node but will not delete the original.
* **Expand** - If *false* it will not expand the dropped node.
* **FirstChild** - If *True* it will drop the node as the first/top sibling inside the target node.

### Return
The ID of the top node added at the destination position.

