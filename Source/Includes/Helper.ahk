; These functions and labels are related to interacting with the Helper Window

MaybeOpenOrCloseHelperWindow(ActiveProcess,ActiveTitle,ActiveId)
{
   ; This is called when switching the active window
   global g_HelperManual
   
   IfNotEqual, g_HelperManual,
   {
      MaybeCreateHelperWindow()
      Return
   }

   IF ( CheckHelperWindowAuto(ActiveProcess,ActiveTitle) )
   {
      global g_HelperClosedWindowIds
      ; Remove windows which were closed
      Loop, Parse, g_HelperClosedWindowIDs, |
      {
         IfEqual, A_LoopField,
            Continue
            
         IfWinExist, ahk_id %A_LoopField%
         {
            TempHelperClosedWindowIDs .= "|" . A_LoopField . "|"
         }
      }
      
      g_HelperClosedWindowIDs = %TempHelperClosedWindowIDs%
      TempHelperClosedWindowIDs =
      
      SearchText := "|" . ActiveId . "|"
      
      IfInString, g_HelperClosedWindowIDs, %SearchText%
      {
         MaybeSaveHelperWindowPos()
      } else MaybeCreateHelperWindow()
   
   } else MaybeSaveHelperWindowPos()

   Return
   
}

CheckHelperWindowAuto(ActiveProcess,ActiveTitle)
{
   global prefs_HelperWindowProgramExecutables
   global prefs_HelperWindowProgramTitles
   
   Loop, Parse, prefs_HelperWindowProgramExecutables, |
   {
      IfEqual, ActiveProcess, %A_LoopField%
         Return, true
   }

   Loop, Parse, prefs_HelperWindowProgramTitles, |
   {
      IfInString, ActiveTitle, %A_LoopField%
         Return, true
   }

   Return
}

MaybeOpenOrCloseHelperWindowManual()
{
   ;Called when we hit Ctrl-Shift-H
      
   global g_Helper_Id
   global g_HelperManual
   
   ;If a helper window already exists 
   IfNotEqual, g_Helper_Id,
   {
      ; If we've forced a manual helper open, close it. Else mark it as forced open manually
      IfNotEqual, g_HelperManual,
      {
         HelperWindowClosed()
      } else g_HelperManual=1
   } else {
            global g_Active_Id
            WinGetTitle, ActiveTitle, ahk_id %g_Active_Id%
            WinGet, ActiveProcess, ProcessName, ahk_id %g_Active_Id%
            ;Check for Auto Helper, and if Auto clear closed flag and open
            IF ( CheckHelperWindowAuto(ActiveProcess,ActiveTitle) )
            {
               global g_HelperClosedWindowIDs
               SearchText := "|" . g_Active_Id . "|"
               StringReplace, g_HelperClosedWindowIDs, g_HelperClosedWindowIDs, %SearchText%
               
            } else {
                     ; else Open a manually opened helper window
                     g_HelperManual=1
                  }
            MaybeCreateHelperWindow()
         }
      
   Return
}

;------------------------------------------------------------------------

;Create helper window for showing ListBox
MaybeCreateHelperWindow()
{
   Global g_Helper_Id
   Global g_XY
   ;Don't open a new Helper Window if One is already open
   IfNotEqual, g_Helper_Id,
      Return
      
   Gui, HelperGui:+Owner -MinimizeBox -MaximizeBox +AlwaysOnTop
   Gui, HelperGui:+LabelHelper_
   Gui, HelperGui:Add, Text,,List appears here 
   IfNotEqual, g_XY, 
   {
      StringSplit, Pos, g_XY, `, 
      Gui, HelperGui:Show, X%Pos1% Y%Pos2% NoActivate
   } else {
            Gui, HelperGui:Show, NoActivate
         }
   WinGet, g_Helper_Id, ID,,List appears here 
   WinSet, Transparent, 125, ahk_id %g_Helper_Id%
   return 
}

;------------------------------------------------------------------------

Helper_Close:
HelperWindowClosed()
Return

HelperWindowClosed()
{
   global g_Helper_Id
   global g_HelperManual
   IfNotEqual, g_Helper_Id,
   {
      ;Check g_LastActiveIdBeforeHelper and not g_Active_Id in case we are on the Helper Window
      global g_LastActiveIdBeforeHelper
      WinGetTitle, ActiveTitle, ahk_id %g_LastActiveIdBeforeHelper%
      WinGet, ActiveProcess, ProcessName, ahk_id %g_LastActiveIdBeforeHelper%
      
      If ( CheckHelperWindowAuto(ActiveProcess,ActiveTitle) )
      {
         global g_HelperClosedWindowIDs
         
         SearchText := "|" . g_LastActiveIdBeforeHelper . "|"         
         IfNotInString g_HelperClosedWindowIDs, %SearchText%
            g_HelperClosedWindowIDs .= SearchText
      }
   
      g_HelperManual=   
   
      MaybeSaveHelperWindowPos()
   }
   Return
}

;------------------------------------------------------------------------

MaybeSaveHelperWindowPos()
{
   global g_Helper_Id
   IfNotEqual, g_Helper_Id, 
   {
      global g_XY
      global g_XYSaved
      WinGetPos, hX, hY, , , ahk_id %g_Helper_Id%
      g_XY = %hX%`,%hY%
      g_XYSaved = 1
      g_Helper_Id = 
      Gui, HelperGui:Hide
   }
   Return
}

;------------------------------------------------------------------------