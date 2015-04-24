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
      ;can't use a g-label here as windows sometimes passes the click message when spamming the scrollbar arrows
      Gui, ListBoxGui: Add, ListBox, vg_ListBox%A_Index% R%A_Index% X0 Y0 hwndg_ListBoxHwnd%A_Index%
   }

   Return
}
   
ListBoxClickItem(wParam, lParam, msg, ClickedHwnd)
{
   global
   Local NewClickedItem
   Local TempRows
   static LastClickedItem
   
   TempRows := GetRows()
   
   if !(ClickedHwnd == g_ListBoxHwnd%TempRows%)
   {
      return
   }
   
   ; if we clicked in the scrollbar, jump out
   if (A_GuiX > (g_ListBoxPosX + g_ListBoxContentWidth))
   {
      SetSwitchOffListBoxTimer()
      Return
   }
   
   GuiControlGet, g_MatchPos, ListBoxGui:, g_ListBox%TempRows%
   
   if (msg == g_WM_LBUTTONUP)
   {
      if prefs_DisabledAutoCompleteKeys not contains L
      {
         SwitchOffListBoxIfActive()
         EvaluateUpDown("$LButton")   
      } else {
         ; Track this to make sure we're double clicking on the same item
         NewClickedItem := g_MatchPos
         SetSwitchOffListBoxTimer()
      }
         
   } else if (msg == g_WM_LBUTTONDBLCLK)
   {
      SwitchOffListBoxIfActive()
      
      if prefs_DisabledAutoCompleteKeys contains L
      {
         if (LastClickedItem == g_MatchPos)
         {
            EvaluateUpDown("$LButton")   
         }
      }
   } else {
      SwitchOffListBoxIfActive()
   }
      
   ; clear or set LastClickedItem
   LastClickedItem := NewClickedItem
   
   Return
}

SetSwitchOffListBoxTimer()
{
   static DoubleClickTime
   
   if !(DoubleClickTime)
   {
      DoubleClickTime := DllCall("GetDoubleClickTime")
   }
   ;When single click is off, we have to wait for the double click time to pass
   ; before re-activating the edit window to allow double click to work
   SetTimer, SwitchOffListBoxIfActiveSub, -%DoubleClickTime%
}
   

SwitchOffListBoxIfActiveSub:
SwitchOffListBoxIfActive()
Return

ListBoxScroll()
{
   global
   
   Local MatchEnd
   Local SI
   Local TempRows
   Local Position
   
   if (g_ListBox_Id)
   {
   
      TempRows := GetRows()
      SI:=GetScrollInfo(g_ListBoxHwnd%TempRows%)
   
      if (!SI.npos)
      {
         return
      }
   
      if (SI.npos == g_MatchStart)
      {
         return
      }
   
      g_MatchStart := SI.npos
   
      SetSwitchOffListBoxTimer()   
   }
}

; based on code by HotKeyIt
;  http://www.autohotkey.com/board/topic/78829-ahk-l-scrollinfo/
;  http://www.autohotkey.com/board/topic/55150-class-structfunc-sizeof-updated-010412-ahkv2/
GetScrollInfo(ctrlhwnd) {
  global g_SB_VERT
  global g_SIF_POS
  SI:=new _Struct("cbSize,fMask,nMin,nMax,nPage,nPos,nTrackPos")
  SI.cbSize:=sizeof(SI)
  SI.fMask := g_SIF_POS
  If !DllCall("GetScrollInfo","PTR",ctrlhwnd,"Int",g_SB_VERT,"PTR",SI[""])
    Return false
  else Return SI
}

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
      ListBoxEnd()
   }
   Return
}

DestroyListBox()
{
   Gui, ListBoxGui:Destroy
   ListBoxEnd()
   Return
}

ListBoxEnd()
{
   global g_ScrollEventHook
   global g_ScrollEventHookThread
   global g_ListBox_Id
   global g_WM_LBUTTONUP
   global g_WM_LBUTTONDBLCLK
   
   g_ListBox_Id =
   
   OnMessage(g_WM_LBUTTONUP, "")
   OnMessage(g_WM_LBUTTONDBLCLK, "")

   if (g_ScrollEventHook) {
      DllCall("UnhookWinEvent", "Uint", g_ScrollEventHook)
      g_ScrollEventHook =
      g_ScrollEventHookThread =
      MaybeCoUninitialize()
   }
   DisableKeyboardHotKeys()
   return
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
   global g_MatchPos
   global g_MatchStart
   global g_MatchTotal
   global g_OriginalMatchStart
   global g_singlematch
   global prefs_ListBoxRows
   
   g_Match = 
   g_MatchLongestLength =
   
   if (!g_MatchPos)
   {
      ; do nothing
   } else if (g_MatchPos < g_MatchStart)
   {
      g_MatchStart := g_MatchPos
   } else if (g_MatchPos > (g_MatchStart + (prefs_ListBoxRows - 1)))
   {
      g_MatchStart := g_MatchPos - (prefs_ListBoxRows -1)
   }
   
   g_OriginalMatchStart := g_MatchStart
   
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
      Local ListBoxPosY
      Local ListBoxSizeX
      Local ListBoxThread
      Local MatchEnd
      Local Rows
      Local ScrollBarWidth
      static ListBox_Old_Cursor

      Rows := GetRows()
      
      IfGreater, g_MatchTotal, %Rows%
      {
         SysGet, ScrollBarWidth, %g_SM_CXVSCROLL%
         if ScrollBarWidth is not integer
               ScrollBarWidth = 17         
      } else ScrollBarWidth = 0
   
      ; Grab the internal border width of the ListBox box
      SysGet, BorderWidthX, %g_SM_CXFOCUSBORDER%
      If BorderWidthX is not integer
         BorderWidthX = 1
      
      
      ;Use 8 pixels for each character in width
      ListBoxSizeX := g_ListBoxCharacterWidthComputed * g_MatchLongestLength + g_ListBoxCharacterWidthComputed + ScrollBarWidth + (BorderWidthX * 2)
      
      
      g_ListBoxPosX := HCaretX()
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
      
      ForceWithinMonitorBounds(g_ListBoxPosX,ListBoxPosY,ListBoxActualSizeW,ListBoxActualSizeH,Rows)
      
      g_ListBoxContentWidth := ListBoxActualSizeW - ScrollBarWidth - BorderWidthX
      
      ; In rare scenarios, the Cursor may not have been detected. In these cases, we just won't show the ListBox.
      IF (!(g_ListBoxPosX) || !(ListBoxPosY))
      {
         return
      }
      
      IfEqual, g_ListBox_Id,
      {
         
         if prefs_DisabledAutoCompleteKeys not contains L
         {
            if (!ListBox_Old_Cursor)
            {
               ListBox_Old_Cursor := DllCall(g_SetClassLongFunction, "Uint", g_ListBoxHwnd%Rows%, "int", g_GCLP_HCURSOR, "int", g_cursor_hand)
            }
            
            DllCall(g_SetClassLongFunction, "Uint", g_ListBoxHwnd%Rows%, "int", g_GCLP_HCURSOR, "int", g_cursor_hand)
            
         ; we only need to set it back to the default cursor if we've ever unset the default cursor
         } else if (ListBox_Old_Cursor)
         {
            DllCall(g_SetClassLongFunction, "Uint", g_ListBoxHwnd%Rows%, "int", g_GCLP_HCURSOR, "int", ListBox_Old_Cursor)
         }
            
      }
      
      Gui, ListBoxGui: Show, NoActivate X%g_ListBoxPosX% Y%ListBoxPosY% H%ListBoxActualSizeH% W%ListBoxActualSizeW%, Word List Appears Here.
      Gui, ListBoxGui: +LastFound +AlwaysOnTop
      
      IfEqual, g_ListBox_Id,
      {
         
         EnableKeyboardHotKeys()   
      }
      
      WinGet, g_ListBox_Id, ID, Word List Appears Here.
      
      ListBoxThread := DllCall("GetWindowThreadProcessId", "Ptr", g_ListBox_Id)
      if (g_ScrollEventHook && (ListBoxThread != g_ScrollEventHookThread))
      {
         DllCall("UnhookWinEvent", "Uint", g_ScrollEventHook)
         g_ScrollEventHook =
         g_ScrollEventHookThread =
         MaybeCoUninitialize()
      }
         
      if (!g_ScrollEventHook) {
         MaybeCoInitializeEx()
         g_ScrollEventHook := DllCall("SetWinEventHook", "Uint", g_EVENT_SYSTEM_SCROLLINGEND, "Uint", g_EVENT_SYSTEM_SCROLLINGEND, "Ptr", g_NULL, "Uint", g_ListBoxScrollCallback, "Uint", g_PID, "Uint", ListBoxThread, "Uint", g_NULL)
         g_ScrollEventHookThread := ListBoxThread
      }
      
      OnMessage(g_WM_LBUTTONUP, "ListBoxClickItem")
      OnMessage(g_WM_LBUTTONDBLCLK, "ListBoxClickItem")
      
      IfNotEqual, prefs_ListBoxOpacity, 255
         WinSet, Transparent, %prefs_ListBoxOpacity%, ahk_id %g_ListBox_Id%
   }
}

ForceWithinMonitorBounds(ByRef ListBoxPosX,ByRef ListBoxPosY,ListBoxActualSizeW,ListBoxActualSizeH,Rows)
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