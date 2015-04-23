;These functions and labels are related to the shown list of words

InitializeListBox()
{
   global
   
   Gui, ListBoxGui: -Caption +AlwaysOnTop +ToolWindow +Delimiter%g_DelimiterChar%
   
   Local ListBoxFont
   IfNotEqual, prefs_ListBoxFontOverride,
      ListBoxFont := prefs_ListBoxFontOverride
   else {
         IfEqual, prefs_ListBoxFontFixed, On   
            ListBoxFont = Courier New
         else ListBoxFont = Tahoma
      }
      
   Gui, ListBoxGui:Font, s%prefs_ListBoxFontSize%, %ListBoxFont%

   Loop, %prefs_ListBoxRows%
   {
      GuiControl, ListBoxGui:-Redraw, g_ListBox%A_Index%
      Gui, ListBoxGui: Add, ListBox, vg_ListBox%A_Index% R%A_Index% X0 Y0 gListBoxClick hwndg_ListBoxHwnd%A_Index%
   }
   Return
}

ListBoxClick:
   ListBoxClickItem()
   Return
   
ListBoxClickItem()
{
   Local TempRows
   Local Temp_id
   static DoubleClickTime
   
   TempRows := GetRows()
   
   GuiControlGet, g_MatchPos, ListBoxGui:, g_ListBox%TempRows%
   
   if (A_GuiControlEvent == "Normal")
   {
      if prefs_DisabledAutoCompleteKeys not contains L
      {
         SwitchOffListBoxIfActive()
         EvaluateUpDown("$LButton")   
      } else {
         
         if !(DoubleClickTime)
         {
            DoubleClickTime := DllCall("GetDoubleClickTime")
         }
         ;When single click is off, we have to wait for the double click time to pass
         ; before re-activating the edit window to allow double click to work
         SetTimer, SwitchOffListBoxIfActiveSub, -%DoubleClickTime%
      }
         
   } else if (A_GuiControlEvent == "DoubleClick")
   {
      SwitchOffListBoxIfActive()
      
      if prefs_DisabledAutoCompleteKeys contains L
      {
         EvaluateUpDown("$LButton")   
      }
   } else {
      SwitchOffListBoxIfActive()
   }
      
   
   Return
}

SwitchOffListBoxIfActiveSub:
SwitchOffListBoxIfActive()
Return

ListBoxChooseItem(Row)
{
   global
   GuiControl, ListBoxGui: Choose, g_ListBox%Row%, %g_MatchPos%
}

;------------------------------------------------------------------------

CloseListBox()
{
   global g_ListBox_Id
   IfNotEqual, g_ListBox_Id,
   {
      Gui, ListBoxGui: Hide
      g_ListBox_Id = 
      DisableKeyboardHotKeys()
   }
   Return
}

DestroyListBox()
{
   global g_ListBox_Id
   g_ListBox_Id =
   Gui, ListBoxGui:Destroy
   DisableKeyboardHotKeys()
   Return
}

;------------------------------------------------------------------------

SavePriorMatchPosition()
{
   global g_MatchPos
   global g_MatchStart
   global g_OldMatch
   global g_OldMatchStart
   global g_singlematch
   global prefs_ArrowKeyMethod
   
   if !(g_MatchPos)
   {
      g_OldMatch =
      g_OldMatchStart = 
   } else IfEqual, prefs_ArrowKeyMethod, LastWord
   {
      g_OldMatch := g_singlematch[g_MatchPos]
      g_OldMatchStart = 
   } else IfEqual, prefs_ArrowKeyMethod, LastPosition
   {
      g_OldMatch := g_MatchPos
      g_OldMatchStart := g_MatchStart
   } else {
      g_OldMatch =
      g_OldMatchStart =
   }
      
   Return
}

SetupMatchPosition()
{
   global g_MatchPos
   global g_MatchStart
   global g_MatchTotal
   global g_OldMatch
   global g_OldMatchStart
   global g_singlematch
   global prefs_ArrowKeyMethod
   global prefs_ListBoxRows
   
   IfEqual, g_OldMatch, 
   {
      IfEqual, prefs_ArrowKeyMethod, Off
      {
         g_MatchPos = 
         g_MatchStart = 1
      } else {
         g_MatchPos = 1
         g_MatchStart = 1
      }
   } else IfEqual, prefs_ArrowKeyMethod, Off
   {
      g_MatchPos = 
      g_MatchStart = 1
   } else IfEqual, prefs_ArrowKeyMethod, LastPosition
   {
      IfGreater, g_OldMatch, %g_MatchTotal%
      {
         g_MatchStart := g_MatchTotal - (prefs_ListBoxRows - 1)
         IfLess, g_MatchStart, 1
            g_MatchStart = 1
         g_MatchPos := g_MatchTotal
      } else {
         g_MatchStart := g_OldMatchStart
         If ( g_MatchStart > (g_MatchTotal - (prefs_ListBoxRows - 1) ))
         {
            g_MatchStart := g_MatchTotal - (prefs_ListBoxRows - 1)
            IfLess, g_MatchStart, 1
               g_MatchStart = 1
         }
         g_MatchPos := g_OldMatch
      }
   
   } else IfEqual, prefs_ArrowKeyMethod, LastWord
   {
      ListPosition =
      Loop, %g_MatchTotal%
      {
         if ( g_OldMatch == g_singlematch[A_Index] )
         {
            ListPosition := A_Index
            Break
         }
      }
      IfEqual, ListPosition, 
      {
         g_MatchPos = 1
         g_MatchStart = 1
      } Else {
         g_MatchStart := ListPosition - (prefs_ListBoxRows - 1)
         IfLess, g_MatchStart, 1
            g_MatchStart = 1
         g_MatchPos := ListPosition
      }
   } else {
      g_MatchPos = 1
      g_MatchStart = 1
   }
             
   g_OldMatch = 
   g_OldMatchStart = 
   Return
}

RebuildMatchList()
{
   global g_Match
   global g_MatchLongestLength
   global g_MatchTotal
   global g_singlematch
   
   g_Match = 
   g_MatchLongestLength =
   
   Loop, %g_MatchTotal%
   {
      CurrentLength := AddToMatchList(A_Index,g_singlematch[A_Index])
      IfGreater, CurrentLength, %g_MatchLongestLength%
         g_MatchLongestLength := CurrentLength      
   }
   StringTrimRight, g_Match, g_Match, 1        ; Get rid of the last linefeed 
   Return
}

AddToMatchList(position,value)
{
   global g_DelimiterChar
   global g_Match
   global g_MatchStart
   global g_NumKeyMethod
   
   IfEqual, g_NumKeyMethod, Off
   {
      prefix =
   } else IfLess, position, %g_MatchStart%
   {
      prefix =
   } else if ( position > ( g_MatchStart + 9 ) )
   {
      prefix = 
   } else {
      prefix := Mod(position - g_MatchStart +1,10) . " "
   }
   
   g_Match .= prefix . value . g_DelimiterChar
   Return, StrLen("8 " . value)
}

;------------------------------------------------------------------------

;Show matched values
ShowListBox()
{
   global

   IfNotEqual, g_Match,
   {
      Local BorderWidthX
      Local ListBoxActualSize
      Local ListBoxActualSizeH
      Local ListBoxActualSizeW
      Local ListBoxPosX
      Local ListBoxPosY
      Local ListBoxSizeX
      Local MatchEnd
      Local Rows
      Local ScrollBarWidth
      static ListBox_Old_Cursor

      Rows := GetRows()
      
      IfGreater, g_MatchTotal, %Rows%
      {
         SysGet, ScrollBarWidth, 2        
         if ScrollBarWidth is not integer
               ScrollBarWidth = 17         
      } else ScrollBarWidth = 0
   
      ; Grab the internal border width of the ListBox box
      SysGet, BorderWidthX, 83
      If BorderWidthX is not integer
         BorderWidthX = 1
      
      ;Use 8 pixels for each character in width
      ListBoxSizeX := g_ListBoxCharacterWidthComputed * g_MatchLongestLength + g_ListBoxCharacterWidthComputed + ScrollBarWidth + (BorderWidthX *2)
      
      ListBoxPosX := HCaretX()
      ; + ListBoxOffset Move ListBox down a little so as not to hide the caret. 
      ListBoxPosY := HCaretY()+prefs_ListBoxOffset
      
      Loop, %prefs_ListBoxRows%
      { 
         IfEqual, A_Index, %Rows%
         {
            GuiControl, ListBoxGui: -Redraw, g_ListBox%A_Index%
            GuiControl, ListBoxGui: Move, g_ListBox%A_Index%, w%ListBoxSizeX%
            GuiControl, ListBoxGui: ,g_ListBox%A_Index%, %g_DelimiterChar%%g_Match%
            MatchEnd := g_MatchStart + (prefs_ListBoxRows - 1)
            IfNotEqual, g_MatchPos,
            {
               GuiControl, ListBoxGui: Choose, g_ListBox%A_Index%, %MatchEnd%
               GuiControl, ListBoxGui: Choose, g_ListBox%A_Index%, %g_MatchPos%
            }
            GuiControl, ListBoxGui: +AltSubmit +Redraw, g_ListBox%A_Index%
            GuiControl, ListBoxGui: Show, g_ListBox%A_Index%
            GuiControlGet, ListBoxActualSize, ListBoxGui: Pos, g_ListBox%A_Index%
            Continue
         }
      
         GuiControl, ListBoxGui: Hide, g_ListBox%A_Index%
         GuiControl, ListBoxGui: -Redraw, g_ListBox%A_Index%
         GuiControl, ListBoxGui: , g_ListBox%A_Index%, %g_DelimiterChar%
      }
   
      ForceWithinMonitorBounds(ListBoxPosX,ListBoxPosY,ListBoxActualSizeH,ListBoxActualSizeW,Rows)
      
      ; In rare scenarios, the Cursor may not have been detected. In these cases, we just won't show the ListBox.
      IF (!(ListBoxPosX) || !(ListBoxPosY))
      {
         return
      }
      
      Gui, ListBoxGui: Show, NoActivate X%ListBoxPosX% Y%ListBoxPosY% H%ListBoxActualSizeH% W%ListBoxActualSizeW%, Word List Appears Here.
      Gui, ListBoxGui: +LastFound +AlwaysOnTop
      IfEqual, g_ListBox_Id,
      {
         
         EnableKeyboardHotKeys()   
         if prefs_DisabledAutoCompleteKeys not contains L
         {
            if (!ListBox_Old_Cursor)
            {
               ListBox_Old_Cursor := DllCall(g_SetClassLongFunction, "Uint", g_ListBoxHwnd1, "int", -12, "int", g_cursor_hand)
            }
            
            Loop, %prefs_ListBoxRows%
            {
               DllCall(g_SetClassLongFunction, "Uint", g_ListBoxHwnd%A_Index%, "int", -12, "int", g_cursor_hand)
            }
            
         ; we only need to set it back to the default cursor if we've ever unset the default cursor
         } else if (ListBox_Old_Cursor)
         {
            Loop, %prefs_ListBoxRows%
            {
               DllCall(g_SetClassLongFunction, "Uint", g_ListBoxHwnd%A_Index%, "int", -12, "int", ListBox_Old_Cursor)
            }
         }
            
      }
      WinGet, g_ListBox_Id, ID, Word List Appears Here.
      IfNotEqual, prefs_ListBoxOpacity, 255
         WinSet, Transparent, %prefs_ListBoxOpacity%, ahk_id %g_ListBox_Id%
   }
}

ForceWithinMonitorBounds(ByRef ListBoxPosX,ByRef ListBoxPosY,ListBoxActualSizeH,ListBoxActualSizeW,Rows)
{
   global prefs_ListBoxOffset
   ;Grab the number of non-dummy monitors
   SysGet, NumMonitors, 80
   
   IfLess, NumMonitors, 1
      NumMonitors =1
         
   Loop, %NumMonitors%
   {
      SysGet, Mon, Monitor, %A_Index%
      IF ( ( ListBoxPosX < MonLeft ) || (ListBoxPosX > MonRight ) || ( ListBoxPosY < MonTop ) || (ListBoxPosY > MonBottom ) )
         Continue
      
      If ( (ListBoxPosX + ListBoxActualSizeW ) > MonRight )
      {
         ListBoxPosX := MonRight - ListBoxActualSizeW
         If ( ListBoxPosX < MonLeft )
            ListBoxPosX := MonLeft
      }
         
      If ( (ListBoxPosY + ListBoxActualSizeH ) > MonBottom )
          ListBoxPosY := HCaretY() - Ceil(prefs_ListBoxOffset - (ListBoxActualSizeH / Rows )) - ListBoxActualSizeH  
         
      Break
   }

   Return      
}

;------------------------------------------------------------------------

GetRows()
{
   global g_MatchTotal
   global prefs_ListBoxRows
   IfGreater, g_MatchTotal, %prefs_ListBoxRows%
      Rows := prefs_ListBoxRows
   else Rows := g_MatchTotal
   
   Return, Rows
}
;------------------------------------------------------------------------

; function to grab the X position of the caret for the ListBox
HCaretX() 
{ 
   global g_Helper_Id
    
   WinGetPos, HelperX,,,, ahk_id %g_Helper_Id% 
   if HelperX !=
   { 
      return HelperX
   } 
   if ( CheckIfCaretNotDetectable() )
   { 
      MouseGetPos, MouseX
      return MouseX
   } 
   return A_CaretX 
} 

;------------------------------------------------------------------------

; function to grab the Y position of the caret for the ListBox
HCaretY() 
{ 
   global g_Helper_Id

   WinGetPos,,HelperY,,, ahk_id %g_Helper_Id% 
   if HelperY != 
   { 
      return HelperY
   } 
   if ( CheckIfCaretNotDetectable() )
   { 
      MouseGetPos, , MouseY
      return MouseY + 20
   } 
   return A_CaretY 
}

;------------------------------------------------------------------------

CheckIfCaretNotDetectable()
{
   ;Grab the number of non-dummy monitors
   SysGet, NumMonitors, 80
   
   IfLess, NumMonitors, 1
      NumMonitors = 1
   
   if !(A_CaretX)
   {
      Return, 1
   }
   
   ;if the X caret position is equal to the leftmost border of the monitor +1, we can't detect the caret position.
   Loop, %NumMonitors%
   {
      SysGet, Mon, Monitor, %A_Index%
      if ( A_CaretX = ( MonLeft ) )
      {
         Return, 1
      }
      
   }
   
   Return, 0
}