;These functions and labels are related to the shown list of words

InitializeListBox()
{
   global
   
   Gui, ListBoxGui: -Caption +AlwaysOnTop +ToolWindow +Delimiter%DelimiterChar%
   
   Local ListBoxFont
   IfNotEqual, ListBoxFontOverride,
      ListBoxFont := ListBoxFontOverride
   else {
         IfEqual, ListBoxFontFixed, On   
            ListBoxFont = Courier New
         else ListBoxFont = Tahoma
      }
      
   Gui, ListBoxGui:Font, s%ListBoxFontSize%, %ListBoxFont%

   Loop, %ListBoxRows%
   {
      GuiControl, -Redraw, ListBox%A_Index%
      Gui, ListBoxGui: Add, ListBox, vListBox%A_Index% R%A_Index% X0 Y0 GListBoxClick
   }
   Return
}

ListBoxClick:
   ListBoxChooseItem()
   Return
   
ListBoxChooseItem()
{
   Local TempRows
   TempRows := GetRows()
   GuiControlGet, MatchPos, ,ListBox%TempRows%
   Return
}

;------------------------------------------------------------------------

CloseListBox()
{
   global ListBoxGui
   global ListBox_ID
   IfNotEqual, ListBox_ID,
   {
      Gui, ListBoxGui: Hide
      ListBox_ID = 
      DisableKeyboardHotKeys()
   }
   Return
}

;------------------------------------------------------------------------

SavePriorMatchPosition()
{
   global
   
   IfNotEqual, MatchPos, 
   {
      IfEqual, ArrowKeyMethod, LastWord
      {
         OldMatch := singlematch%MatchPos%
         OldMatchStart = 
      } else {
               IfEqual, ArrowKeyMethod, LastPosition
               {
                  OldMatch = %MatchPos%
                  OldMatchStart = %MatchStart%
               } else {
                        OldMatch =
                        OldMatchStart =
                     }
            }
   
   } else {
            OldMatch =
            OldMatchStart = 
         }
      
   Return
}

SetupMatchPosition()
{
   global
   
   IfEqual, OldMatch, 
   {
      IfEqual, ArrowKeyMethod, Off
      {
         MatchPos = 
         MatchStart = 1
      } else {
               MatchPos = 1
               MatchStart = 1
            }
   } Else IfEqual, ArrowKeyMethod, Off
         {
            MatchPos = 
            MatchStart = 1
         } else IfEqual, ArrowKeyMethod, LastPosition
               {
                  IfGreater, OldMatch, %Number%
                  {
                     MatchStart := Number - (ListBoxRows - 1)
                     IfLess, MatchStart, 1
                        MatchStart = 1
                     MatchPos = %Number%
                  } else {
                           MatchStart = %OldMatchStart%
                           If ( MatchStart > (Number - (ListBoxRows - 1) ))
                           {
                              MatchStart := Number - (ListBoxRows - 1)
                              IfLess, MatchStart, 1
                                 MatchStart = 1
                           }
                           MatchPos = %OldMatch%
                        }
                     
               } else IfEqual, ArrowKeyMethod, LastWord
                     {
                        Pos =
                        Loop, %Number%
                        {
                           if ( OldMatch == singlematch%A_Index% )
                           {
                              Pos = %A_Index%
                              Break
                           }
                        }
                        IfEqual, pos, 
                        {
                           MatchPos = 1
                           MatchStart = 1
                        } Else {
                                 MatchStart := Pos - (ListBoxRows - 1)
                                 IfLess, MatchStart, 1
                                    MatchStart = 1
                                 MatchPos = %Pos%
                              }
                     } else {
                              MatchPos = 1
                              MatchStart = 1
                           }
             
   OldMatch = 
   OldMatchStart = 
   Return
}

RebuildMatchList()
{
   global
   match = 
   MatchLongestLength =
   Local CurrentLength
   Loop, %Number%
   {
      CurrentLength := AddToMatchList(A_Index,singlematch%A_Index%)
      IfGreater, CurrentLength, %MatchLongestLength%
         MatchLongestLength := CurrentLength      
   }
   StringTrimRight, match, match, 1        ; Get rid of the last linefeed 
   Return
}

AddToMatchList(position,value)
{
   global
   Local prefix
   IfEqual, NumKeyMethod, Off
      prefix =
   else {
            IfLess, position, %MatchStart%
               prefix =
            else {
                  if ( position > ( MatchStart + 9 ) )
                     prefix = 
                  else prefix := Mod(position - MatchStart +1,10) . " "
               }
         }
   match .= prefix . value . DelimiterChar
   Return, StrLen("8 " . value)
}

;------------------------------------------------------------------------

;Show matched values
ShowListBox()
{
   global

   IfNotEqual, Match,
   {
      Local ListBoxSizeX
      Local ListBoxPosY
      Local ListBoxPosX
      Local Rows
      Local ScrollBarWidth
      Local ListBoxActualSize
      Local ListBoxActualSizeH
      Local ListBoxActualSizeW
      Local BorderWidthX
      Local MatchEnd

      Rows := GetRows()
      
      IfGreater, Number, %Rows%
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
      ListBoxSizeX := ListBoxCharacterWidth * MatchLongestLength + ListBoxCharacterWidth + ScrollBarWidth + (BorderWidthX *2)
      
      ListBoxPosX := HCaretX()
      ; + ListBoxOffset Move ListBox down a little so as not to hide the caret. 
      ListBoxPosY := HCaretY()+ListBoxOffset
      
      Loop, %ListBoxRows%
      { 
         IfEqual, A_Index, %Rows%
         {
            GuiControl, ListBoxGui: -Redraw, ListBox%A_Index%
            GuiControl, ListBoxGui: Move, ListBox%A_Index%, w%ListBoxSizeX%
            GuiControl, ListBoxGui: ,ListBox%A_Index%, %DelimiterChar%%match%
            MatchEnd := MatchStart + (ListBoxRows - 1)
            IfNotEqual, MatchPos,
            {
               GuiControl, ListBoxGui: Choose, ListBox%A_Index%, %MatchEnd%
               GuiControl, ListBoxGui: Choose, ListBox%A_Index%, %MatchPos%
            }
            GuiControl, ListBoxGui: +AltSubmit +Redraw, ListBox%A_Index%
            GuiControl, ListBoxGui: Show, ListBox%A_Index%
            GuiControlGet, ListBoxActualSize, ListBoxGui: Pos, ListBox%A_Index%
            Continue
         }
      
         GuiControl, ListBoxGui: Hide, ListBox%A_Index%
         GuiControl, ListBoxGui: -Redraw, ListBox%A_Index%
         GuiControl, ListBoxGui: , ListBox%A_Index%, %DelimiterChar%
      }
   
      ForceWithinMonitorBounds(ListBoxPosX,ListBoxPosY,ListBoxActualSizeH,ListBoxActualSizeW,Rows,ListBoxOffset)
      
      ; In rare scenarios, the Cursor may not have been detected. In these cases, we just won't show the ListBox.
      IF (!(ListBoxPosX) || !(ListBoxPosY))
      {
         return
      }
      
      Gui, ListBoxGui: Show, NoActivate X%ListBoxPosX% Y%ListBoxPosY% H%ListBoxActualSizeH% W%ListBoxActualSizeW%, Word List Appears Here.
      Gui, ListBoxGui: +LastFound +AlwaysOnTop
      IfEqual, ListBox_ID,
      {
         EnableKeyboardHotKeys()   
      }
      WinGet, ListBox_ID, ID, Word List Appears Here.
      IfNotEqual, ListBoxOpacity, 255
         WinSet, Transparent, %ListBoxOpacity%, ahk_id %ListBox_ID%
      WinSet, Disable, , ahk_id %ListBox_ID%
   }
}

ForceWithinMonitorBounds(ByRef ListBoxPosX,ByRef ListBoxPosY,ListBoxActualSizeH,ListBoxActualSizeW,Rows,ListBoxOffset)
{
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
          ListBoxPosY := HCaretY() - Ceil(ListBoxOffset - (ListBoxActualSizeH / Rows )) - ListBoxActualSizeH  
         
      Break
   }

   Return      
}

;------------------------------------------------------------------------

GetRows()
{
   global Number
   global ListBoxRows
   IfGreater, Number, %ListBoxRows%
      Rows := ListBoxRows
   else Rows := Number
   
   Return, Rows
}
;------------------------------------------------------------------------

; function to grab the X position of the caret for the ListBox
HCaretX() 
{ 
   global MouseX
   global Helper_id
    
   WinGetPos, HelperX,,,, ahk_id %Helper_id% 
   if HelperX !=
   { 
      return HelperX
   } 
   if ( CheckIfCaretNotDetectable() )
   { 
      if MouseX != 0 
      { 
         return MouseX 
      } 
   } 
   return A_CaretX 
} 

;------------------------------------------------------------------------

; function to grab the Y position of the caret for the ListBox
HCaretY() 
{ 
   global MouseY
   global Helper_id

   
   WinGetPos,,HelperY,,, ahk_id %Helper_id% 
   if HelperY != 
   { 
      return HelperY
   } 
   if ( CheckIfCaretNotDetectable() )
   { 
      if MouseY != 0 
      { 
         return MouseY + 20
      } 
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
   
   ;if the X caret position is equal to the leftmost border of the monitor +1, we can't detect the caret position.
   Loop, %NumMonitors%
   {
      SysGet, Mon, Monitor, %A_Index%
      if ( A_CaretX = ( MonLeft + 1 ) )
         Return, A_CaretX
      
   }
   
   Return
}