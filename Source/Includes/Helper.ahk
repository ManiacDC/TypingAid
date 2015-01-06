; These functions and labels are related to interacting with the Helper Window

MaybeOpenOrCloseHelperWindow(ActiveProcess,ActiveTitle,ActiveId)
{
   ; This is called when switching the active window
   global HelperManual
   
   IfNotEqual, HelperManual,
   {
      MaybeCreateHelperWindow()
      Return
   }

   IF ( CheckHelperWindowAuto(ActiveProcess,ActiveTitle) )
   {
      global HelperClosedWindowIds
      ; Remove windows which were closed
      Loop, Parse, HelperClosedWindowIDs, |
      {
         IfEqual, A_LoopField,
            Continue
            
         IfWinExist, ahk_id %A_LoopField%
         {
            TempHelperClosedWindowIDs .= "|" . A_LoopField . "|"
         }
      }
      
      HelperClosedWindowIDs = %TempHelperClosedWindowIDs%
      TempHelperClosedWindowIDs =
      
      SearchText := "|" . ActiveId . "|"
      
      IfInString, HelperClosedWindowIDs, %SearchText%
      {
         MaybeSaveHelperWindowPos()
      } else MaybeCreateHelperWindow()
   
   } else MaybeSaveHelperWindowPos()

   Return
   
}

CheckHelperWindowAuto(ActiveProcess,ActiveTitle)
{
   global HelperWindowProgramExecutables
   global HelperWindowProgramTitles
   
   Loop, Parse, HelperWindowProgramExecutables, |
   {
      IfEqual, ActiveProcess, %A_LoopField%
         Return, true
   }

   Loop, Parse, HelperWindowProgramTitles, |
   {
      IfInString, ActiveTitle, %A_LoopField%
         Return, true
   }

   Return
}

MaybeOpenOrCloseHelperWindowManual()
{
   ;Called when we hit Ctrl-Shift-H
      
   global Helper_id
   global HelperManual
   
   ;If a helper window already exists 
   IfNotEqual, Helper_id,
   {
      ; If we've forced a manual helper open, close it. Else mark it as forced open manually
      IfNotEqual, HelperManual,
      {
         HelperWindowClosed()
      } else HelperManual=1
   } else {
            global Active_id
            WinGetTitle, ActiveTitle, ahk_id %Active_id%
            WinGet, ActiveProcess, ProcessName, ahk_id %Active_id%
            ;Check for Auto Helper, and if Auto clear closed flag and open
            IF ( CheckHelperWindowAuto(ActiveProcess,ActiveTitle) )
            {
               global HelperClosedWindowIDs
               SearchText := "|" . Active_id . "|"
               StringReplace, HelperClosedWindowIDs, HelperClosedWindowIDs, %SearchText%
               
            } else {
                     ; else Open a manually opened helper window
                     HelperManual=1
                  }
            MaybeCreateHelperWindow()
         }
      
   Return
}

;------------------------------------------------------------------------

;Create helper window for showing ListBox
MaybeCreateHelperWindow()
{
   Global Helper_id
   ;Don't open a new Helper Window if One is already open
   IfNotEqual, Helper_id,
      Return
      
   Global XY
   Gui, HelperGui:+Owner -MinimizeBox -MaximizeBox +AlwaysOnTop
   Gui, HelperGui:+LabelHelper_
   Gui, HelperGui:Add, Text,,List appears here 
   IfNotEqual, XY, 
   {
      StringSplit, Pos, XY, `, 
      Gui, HelperGui:Show, X%Pos1% Y%Pos2% NoActivate
   } else {
            Gui, HelperGui:Show, NoActivate
         }
   WinGet, Helper_id, ID,,List appears here 
   WinSet, Transparent, 125, ahk_id %Helper_id%
   return 
}

;------------------------------------------------------------------------

Helper_Close:
HelperWindowClosed()
Return

HelperWindowClosed()
{
   global Helper_id
   global HelperManual
   IfNotEqual, Helper_id,
   {
      ;Check LastActiveIdBeforeHelper and not Active_id in case we are on the Helper Window
      global LastActiveIdBeforeHelper
      WinGetTitle, ActiveTitle, ahk_id %LastActiveIdBeforeHelper%
      WinGet, ActiveProcess, ProcessName, ahk_id %LastActiveIdBeforeHelper%
      
      If ( CheckHelperWindowAuto(ActiveProcess,ActiveTitle) )
      {
         global HelperClosedWindowIDs
         
         SearchText := "|" . LastActiveIdBeforeHelper . "|"         
         IfNotInString HelperClosedWindowIDs, %SearchText%
            HelperClosedWindowIDs .= SearchText
      }
   
      HelperManual=   
   
      MaybeSaveHelperWindowPos()
   }
   Return
}

;------------------------------------------------------------------------

MaybeSaveHelperWindowPos()
{
   global Helper_id
   IfNotEqual, Helper_id, 
   {
      global XY
      global XYSaved
      WinGetPos, hX, hY, , , ahk_id %Helper_id%
      XY = %hX%`,%hY%
      XYSaved = 1
      Helper_id = 
      Gui, HelperGui:Hide
   }
   Return
}

;------------------------------------------------------------------------