;These functions and labels are related to the active window


; Timed function to detect change of focus (and remove ListBox when changing active window) 
Winchanged: 
   
   IF ( ReturnWinActive() )
   {
      IfNotEqual, DetectMouseClickMove, On 
      {
         IfNotEqual, OldCaretY,
         {
            if ( OldCaretY != HCaretY() )
            {
               CloseListBox()
            }
         }
      }
      
   } else {
            GetIncludedActiveWindow()
         }
   Return
   
;------------------------------------------------------------------------

GetIncludedActiveWindow()
{
   global Active_id
   global Active_Title
   global Helper_id
   global LastActiveIdBeforeHelper
   global ListBox_ID
   global MouseWin_ID
   Process, Priority,,Normal
   ;Wait for Included Active Window
   
   Loop
   {
      WinGet, ActiveId, ID, A
      WinGet, ActiveProcess, ProcessName, ahk_id %ActiveId%
      WinGetTitle, ActiveTitle, ahk_id %ActiveId%
      IfEqual, ActiveId, 
      {
         IfNotEqual, MouseWin_ID,
            IfEqual, MouseWin_ID, %ListBox_ID% 
            {
               WinActivate, ahk_id %Active_id%
               Return
            }
         
         ;Force unload of Keyboard Hook
         Input
         SuspendOn()
         CloseListBox()
         MaybeSaveHelperWindowPos()
         ;Wait for an active window, then check again
         ;Wait for any window to be active
         WinWaitActive, , , , ZZZYouWillNeverFindThisStringInAWindowTitleZZZ
         Continue
      }
      IfEqual, ActiveId, %Helper_id%
         Break
      IfEqual, ActiveId, %ListBox_ID%
         Break
      If CheckForActive(ActiveProcess,ActiveTitle)
         Break
      ;Force unload of Keyboard Hook
      Input
      SuspendOn()
      CloseListBox()
      MaybeSaveHelperWindowPos()
      SetTitleMatchMode, 3 ; set the title match mode to exact so we can detect a window title change
      WinWaitNotActive, %ActiveTitle% ahk_id %ActiveId%
      SetTitleMatchMode, 2
      ActiveId = 
      ActiveTitle =
      ActiveProcess =
   }

   IfEqual, ActiveID, %ListBox_ID%
   {
      Active_id :=  ActiveId
      Active_Title := ActiveTitle
      Return
   }
   
   ;if we are in the Helper Window, we don't want to re-enable script functions
   IfNotEqual, ActiveId, %Helper_id%
   {
      ; Check to see if we need to reopen the helper window
      MaybeOpenOrCloseHelperWindow(ActiveProcess,ActiveTitle,ActiveId)
      SuspendOff()
      ;Set the process priority back to High
      Process, Priority,,High
      LastActiveIdBeforeHelper = %ActiveId%
      
   } else {
            IfNotEqual, Active_id, %Helper_id%
               LastActiveIdBeforeHelper = %Active_id%               
         }
   
   global LastInput_Id
   ;Show the ListBox if the old window is the same as the new one
   IfEqual, ActiveId, %LastInput_Id%
   {
      WinWaitActive, ahk_id %LastInput_id%,,0
      ;Check Caret Position again
      MouseButtonClick=LButton
      Gosub, CheckForCaretMove
      ShowListBox()      
   } else {
            CloseListBox()
         }
   Active_id :=  ActiveId
   Active_Title := ActiveTitle
   Return
}

CheckForActive(ActiveProcess,ActiveTitle)
{
   ;Check to see if the Window passes include/exclude tests
   global ExcludeProgramExecutables
   global ExcludeProgramTitles
   global IncludeProgramExecutables
   global IncludeProgramTitles
   global InSettings
   
   If InSettings
      Return,
   
   Loop, Parse, ExcludeProgramExecutables, |
   {
      IfEqual, ActiveProcess, %A_LoopField%
         Return,
   }
   
   Loop, Parse, ExcludeProgramTitles, |
   {
      IfInString, ActiveTitle, %A_LoopField%
         Return,
   }

   IfEqual, IncludeProgramExecutables,
   {
      IfEqual, IncludeProgramTitles,
         Return, 1
   }

   Loop, Parse, IncludeProgramExecutables, |
   {
      IfEqual, ActiveProcess, %A_LoopField%
         Return, 1
   }

   Loop, Parse, IncludeProgramTitles, |
   {
      IfInString, ActiveTitle, %A_LoopField%
         Return, 1
   }

   Return, 
}

;------------------------------------------------------------------------
      
ReturnWinActive()
{
   global Active_id
   global Active_Title
   global InSettings
   
   IF InSettings
      Return,
   
   WinGet, Temp_id, ID, A
   WinGetTitle, Temp_Title, ahk_id %Temp_id%
   Last_Title := Active_Title
   ; remove all asterisks, dashes, and spaces from title in case saved value changes
   StringReplace, Last_Title, Last_Title,*,,All
   StringReplace, Temp_Title, Temp_Title,*,,All
   StringReplace, Last_Title, Last_Title,%A_Space%,,All
   StringReplace, Temp_Title, Temp_Title,%A_Space%,,All
   StringReplace, Last_Title, Last_Title,-,,All
   StringReplace, Temp_Title, Temp_Title,-,,All
   Return, (( Active_id == Temp_id ) && ( Last_Title == Temp_Title ))
}
