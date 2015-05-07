;These functions and labels are related to the active window

EnableWinHook()
{
   global g_EVENT_SYSTEM_FOREGROUND
   global g_NULL
   global g_WINEVENT_SKIPOWNPROCESS
   global g_WinChangedEventHook
   global g_WinChangedCallback
   ; Set a hook to check for a changed window
   If !(g_WinChangedEventHook)
   {
      MaybeCoInitializeEx()
      g_WinChangedEventHook := DllCall("SetWinEventHook", "Uint", g_EVENT_SYSTEM_FOREGROUND, "Uint", g_EVENT_SYSTEM_FOREGROUND, "Ptr", g_NULL, "Uint", g_WinChangedCallback, "Uint", g_NULL, "Uint", g_NULL, "Uint", g_WINEVENT_SKIPOWNPROCESS)
      
      if !(g_WinChangedEventHook)
      {
         MsgBox, Failed to register Event Hook!
         ExitApp
      }
   }
   
   Return
}

DisableWinHook()
{
   global g_WinChangedEventHook
   
   if (g_WinChangedEventHook)
   {
      if (DllCall("UnhookWinEvent", "Uint", g_WinChangedEventHook))
      {
         g_WinChangedEventHook =
         MaybeCoUninitialize()
      } else {
         MsgBox, Failed to Unhook WinEvent!
         ExitApp
      }
   }
   return
}

; Hook function to detect change of focus (and remove ListBox when changing active window) 
WinChanged(hWinEventHook, event, wchwnd, idObject, idChild, dwEventThread, dwmsEventTime)
{
   global g_inSettings
   global g_ManualActivate
   global g_OldCaretY
   global prefs_DetectMouseClickMove
   
   If (event <> 3)
   {
      return
   }
   
   if (g_ManualActivate = true)
   {
      ; ignore activations we've set up manually and clear the flag
      g_ManualActivate = 
      return
   }      
   
   if (g_inSettings = true )
   {
      return
   }
   
   if (SwitchOffListBoxIfActive())
   {
      return
   }
   
   IF ( ReturnWinActive() )
   {
      IfNotEqual, prefs_DetectMouseClickMove, On 
      {
         IfNotEqual, g_OldCaretY,
         {
            if ( g_OldCaretY != HCaretY() )
            {
               CloseListBox()
            }
         }
      }
      
   } else {
      GetIncludedActiveWindow()
   }
   Return
}

SwitchOffListBoxIfActive()
{   
   global g_Active_Id
   global g_ListBox_Id
   global g_ManualActivate
   
   if (g_Active_Id && g_ListBox_Id) {
      WinGet, Temp_id, ID, A   
      IfEqual, Temp_id, %g_ListBox_Id%
      {
         ;set so we don't process this activation
         g_ManualActivate := true
         WinActivate, ahk_id %g_Active_Id%
         return, true
      }
   }
   return, false
}
   
   
;------------------------------------------------------------------------

; Wrapper function to ensure we always enable the WinEventHook after waiting for an active window
; Returns true if the current window is included
GetIncludedActiveWindow()
{
   CurrentWindowIsActive := GetIncludedActiveWindowGuts()
   EnableWinHook()
   Return, CurrentWindowIsActive
}

GetIncludedActiveWindowGuts()
{
   global g_Active_Id
   global g_Active_Title
   global g_Helper_Id
   global g_LastActiveIdBeforeHelper
   global g_ListBox_Id
   global g_MouseWin_Id
   Process, Priority,,Normal
   ;Wait for Included Active Window
   
   CurrentWindowIsActive := true
   
   Loop
   {
      WinGet, ActiveId, ID, A
      WinGet, ActiveProcess, ProcessName, ahk_id %ActiveId%
      WinGetTitle, ActiveTitle, ahk_id %ActiveId%
      IfEqual, ActiveId, 
      {
         IfNotEqual, g_MouseWin_Id,
         {
            IfEqual, g_MouseWin_Id, %g_ListBox_Id% 
            {
               WinActivate, ahk_id %g_Active_Id%
               Return, CurrentWindowIsActive
            }
         }
         
         CurrentWindowIsActive := false
         InactivateAll()
         ;Wait for any window to be active
         WinWaitActive, , , , ZZZYouWillNeverFindThisStringInAWindowTitleZZZ
         Continue
      }
      IfEqual, ActiveId, %g_Helper_Id%
         Break
      IfEqual, ActiveId, %g_ListBox_Id%
         Break
      If CheckForActive(ActiveProcess,ActiveTitle)
         Break
      
      CurrentWindowIsActive := false
      InactivateAll()
      SetTitleMatchMode, 3 ; set the title match mode to exact so we can detect a window title change
      ; Wait for the current window to no longer be active
      WinWaitNotActive, %ActiveTitle% ahk_id %ActiveId%
      SetTitleMatchMode, 2
      ActiveId = 
      ActiveTitle =
      ActiveProcess =
   }

   IfEqual, ActiveId, %g_ListBox_Id%
   {
      g_Active_Id :=  ActiveId
      g_Active_Title := ActiveTitle
      Return, CurrentWindowIsActive
   }
   
   ;if we are in the Helper Window, we don't want to re-enable script functions
   IfNotEqual, ActiveId, %g_Helper_Id%
   {
      ; Check to see if we need to reopen the helper window
      MaybeOpenOrCloseHelperWindow(ActiveProcess,ActiveTitle,ActiveId)
      SuspendOff()
      ;Set the process priority back to High
      Process, Priority,,High
      g_LastActiveIdBeforeHelper = %ActiveId%
      
   } else {
      IfNotEqual, g_Active_Id, %g_Helper_Id%
         g_LastActiveIdBeforeHelper = %g_Active_Id%               
   }
   
   global g_LastInput_Id
   ;Show the ListBox if the old window is the same as the new one
   IfEqual, ActiveId, %g_LastInput_Id%
   {
      WinWaitActive, ahk_id %g_LastInput_Id%,,0
      ;Check Caret Position again
      CheckForCaretMove("LButton")
      ShowListBox()      
   } else {
      CloseListBox()
   }
   g_Active_Id :=  ActiveId
   g_Active_Title := ActiveTitle
   Return, CurrentWindowIsActive
}

CheckForActive(ActiveProcess,ActiveTitle)
{
   ;Check to see if the Window passes include/exclude tests
   global g_InSettings
   global prefs_ExcludeProgramExecutables
   global prefs_ExcludeProgramTitles
   global prefs_IncludeProgramExecutables
   global prefs_IncludeProgramTitles
   
   quotechar := """"
   
   If g_InSettings
      Return,
   
   Loop, Parse, prefs_ExcludeProgramExecutables, |
   {
      IfEqual, ActiveProcess, %A_LoopField%
         Return,
   }
   
   Loop, Parse, prefs_ExcludeProgramTitles, |
   {
      
      if (SubStr(A_LoopField, 1, 1) == quotechar)
      {
         StringTrimLeft, TrimmedString, A_LoopField, 1
         StringTrimRight, TrimmedString, TrimmedString, 1
         IfEqual, ActiveTitle, %TrimmedString%
         {
            return,
         }
      }  else IfInString, ActiveTitle, %A_LoopField%
      {
         return,
      }
   }

   IfEqual, prefs_IncludeProgramExecutables,
   {
      IfEqual, prefs_IncludeProgramTitles,
         Return, 1
   }

   Loop, Parse, prefs_IncludeProgramExecutables, |
   {
      IfEqual, ActiveProcess, %A_LoopField%
         Return, 1
   }

   Loop, Parse, prefs_IncludeProgramTitles, |
   {
      if (SubStr(A_LoopField, 1, 1) == quotechar)
      {
         StringTrimLeft, TrimmedString, A_LoopField, 1
         StringTrimRight, TrimmedString, TrimmedString, 1
         IfEqual, ActiveTitle, %TrimmedString%
         {
            Return, 1
         }
      } else IfInString, ActiveTitle, %A_LoopField%
      {
         Return, 1
      }
   }

   Return, 
}

;------------------------------------------------------------------------
      
ReturnWinActive()
{
   global g_Active_Id
   global g_Active_Title
   global g_InSettings
   
   IF g_InSettings
      Return
   
   if (SwitchOffListBoxIfActive())
   {
      return, true
   }
   
   WinGet, Temp_id, ID, A
   WinGetTitle, Temp_Title, ahk_id %Temp_id%
   Last_Title := g_Active_Title
   ; remove all asterisks, dashes, and spaces from title in case saved value changes
   StringReplace, Last_Title, Last_Title,*,,All
   StringReplace, Temp_Title, Temp_Title,*,,All
   StringReplace, Last_Title, Last_Title,%A_Space%,,All
   StringReplace, Temp_Title, Temp_Title,%A_Space%,,All
   StringReplace, Last_Title, Last_Title,-,,All
   StringReplace, Temp_Title, Temp_Title,-,,All
   Return, (( g_Active_Id == Temp_id ) && ( Last_Title == Temp_Title ))
}
