;  TypingAid
;  http://www.autohotkey.com/forum/viewtopic.php?t=53630
;
;  Press 1 to 0 keys to autocomplete the word upon suggestion 
;  Or use the Up/Down keys to select an item
;  (0 will match suggestion 10) 
;                              Credits:
;                               -Jordi S
;                               -Maniac
;                               -hugov
;                               -kakarukeys
;                               -Asaptrad
;___________________________________________ 

; Press 1 to 0 keys to autocomplete the word upon suggestion 
;___________________________________________

;    CONFIGURATIONS 

#NoTrayIcon
;disable hotkeys until setup is complete
Suspend, On 
#NoEnv
ListLines Off

;Set the Coordinate Modes before any threads can be executed
CoordMode, Caret, Screen
CoordMode, Mouse, Screen

SplitPath, A_ScriptName,,,ScriptExtension,ScriptNoExtension,

If A_Is64bitOS
{
   IF (A_PtrSize = 4)
   {
      IF A_IsCompiled
      {
         
         ScriptPath64 := A_ScriptDir . "\" . ScriptNoExtension . "64." . ScriptExtension
         
         IfExist, %ScriptPath64%
         {
            Run, %ScriptPath64%, %A_WorkingDir%
            ExitApp
         }
      }
   }
}

if (SubStr(ScriptNoExtension, StrLen(ScriptNoExtension)-1, 2) == "64" )
{
   StringTrimRight, ScriptTitle, ScriptNoExtension, 2
} else {
   ScriptTitle := ScriptNoExtension
}

if (InStr(ScriptTitle, "TypingAid"))
{
   ScriptTitle = TypingAid
}

ScriptExtension=
ScriptNoExtension=
ScriptPath64=

SuspendOn()
BuildTrayMenu("Running")      

OnExit, SaveScript

;Change the setup performance speed
SetBatchLines, 20ms
;read in the preferences file
ReadPreferences()

SetTitleMatchMode, 2

;setup code
MouseX = 0 
MouseY = 0 
Helper_id = 
HelperManual = 
DelimiterChar := Chr(2)
AutoTrim, Off 

InitializeListBox()

BlockInput, Send

;Read in the WordList
ReadWordList()

InitializeHotKeys()

DisableKeyboardHotKeys()

WinChangedCallback := RegisterCallback("WinChanged")

if !(WinChangedCallback)
{
   MsgBox, Failed to register callback function
   ExitApp
}

EnableWinHook()
   
;Find the ID of the window we are using
GetIncludedActiveWindow()

;Change the Running performance speed (Priority changed to High in GetIncludedActiveWindow)
SetBatchLines, -1

Loop 
{ 

   ;If the active window has changed, wait for a new one
   IF !( ReturnWinActive() ) 
   {
      Critical, Off
      GetIncludedActiveWindow()
   } else {    
            Critical, Off
         }
   
   ;Get one key at a time 
   Input, chr, L1 V I, {BS}%TerminatingEndKeys%
   
   Critical
   EndKey := ErrorLevel
   
   ProcessKey(chr,EndKey)
}

ProcessKey(chr,EndKey)
{
   global
   
   IfEqual, IgnoreSend, 1
   {
      IgnoreSend = 
      Return
   }

   IfEqual, EndKey,
   {
      EndKey = Max
   }
   
   IfEqual, EndKey, NewInput
      Return

   IfEqual, EndKey, Endkey:Tab
      If ( GetKeyState("Alt") =1 || GetKeyState("LWin") =1 || GetKeyState("RWin") =1 )
         Return
   
   ;If we have no window activated for typing, we don't want to do anything with the typed character
   IfEqual, Active_id,
   {
      GetIncludedActiveWindow()
      Return
   }


   IF !( ReturnWinActive() )
   {
      GetIncludedActiveWindow()
      Return
   }
   
   IfEqual, Active_id, %Helper_id%
   {
      Return
   }
   
   ;If we haven't typed anywhere, set this as the last window typed in
   IfEqual, LastInput_Id,
      LastInput_Id = %Active_id%
   
   IfNotEqual, DetectMouseClickMove, On
   {
      ifequal, OldCaretY,
         OldCaretY := HCaretY()
         
      if ( OldCaretY != HCaretY() )
      {
         ;Don't do anything if we aren't in the original window and aren't starting a new word
         IfNotEqual, LastInput_Id, %Active_id%
            Return
            
         ; add the word if switching lines
         AddWordToList(Word,0)
         ClearAllVars(true)
         Word = %chr%
         Return         
      } 
   }

   OldCaretY := HCaretY()
   OldCaretX := HCaretX()
   
   ;Backspace clears last letter 
   ifequal, EndKey, Endkey:BackSpace
   {
      ;Don't do anything if we aren't in the original window and aren't starting a new word
      IfNotEqual, LastInput_Id, %Active_id%
         Return
      
      StringLen, len, Word
      IfNotEqual, len, 0
      { 
         ifequal, len, 1   
         { 
            ClearAllVars(true)
         } else {
                  StringTrimRight, Word, Word, 1
                }     
      }
   } else if ( ( EndKey == "Max" ) && !(InStr(TerminatingCharactersParsed, chr)) )
         {
            ; If active window has different window ID from the last input,
            ;learn and blank word, then assign number pressed to the word
            IfNotEqual, LastInput_Id, %Active_id%
            {
               AddWordToList(Word,0)
               ClearAllVars(true)
               word := chr
               LastInput_Id := Active_id
               Return
            }
         
            if chr in %ForceNewWordCharacters%
            {
               AddWordToList(Word,0)
               ClearAllVars(true)
               Word := chr
            } else { 
                  Word .= chr
                  }
         } else {
                  ;Don't do anything if we aren't in the original window and aren't starting a new word
                  IfNotEqual, LastInput_Id, %Active_id%
                     Return
                     
                  AddWordToList(Word,0)
                  ClearAllVars(true)
                  Return
                }
                
   ;Wait till minimum letters 
   IF ( StrLen(Word) < Length )
   {
      CloseListBox()
      Return
   }
   SetTimer, RecomputeMatchesTimer, -1
}

RecomputeMatchesTimer:
   Thread, NoTimers
   RecomputeMatches()
   Return

RecomputeMatches()
{
   ; This function will take the given word, and will recompile the list of matches and redisplay the wordlist.
   global
   Local each
   Local LimitTotalMatches
   Local Matches
   Local Normalize
   Local NormalizeTable
   Local OrderByQuery
   Local SuppressMatchingWordQuery
   Local row
   Local ValueType
   Local Values
   Local WhereQuery
   Local WordMatch
   Local WordLen

   SavePriorMatchPosition()

   ;Match part-word with command 
   Num = 
   number = 0 
   
   IfEqual, ArrowKeyMethod, Off
   {
      IfLess, ListBoxRows, 10
         LimitTotalMatches := ListBoxRows
      else LimitTotalMatches = 10
   } else {
      LimitTotalMatches = 200
   }
   
   StringUpper, WordMatch, Word   
   
   IfEqual, SuppressMatchingWord, On
   {
      IfEqual, NoBackSpace, Off
      {
         SuppressMatchingWordQuery := " AND word <> '" . Word . "'"
      } else {
               SuppressMatchingWordQuery := " AND wordindexed <> '" . WordMatch . "'"
            }
   }
   
   WhereQuery := " WHERE wordindexed GLOB '" . WordMatch . "*' " . SuppressMatchingWordQuery
   
   IfEqual, LearnMode, Off
   {
      WhereQuery .= " AND count IS NULL"
      OrderByQuery := " ORDER BY ROWID, Word"
   } else {
   
      NormalizeTable := wDB.Query("SELECT MIN(count) AS normalize FROM Words" . WhereQuery . "AND count IS NOT NULL LIMIT " . LimitTotalMatches . ";")
   
      for each, row in NormalizeTable.Rows
      {
         Normalize := row[1]
      }
      
      IfEqual, Normalize,
      {
         Normalize := 0
      }
      
      WordLen := StrLen(Word)
      OrderByQuery := " ORDER BY CASE WHEN count IS NULL then ROWID else 'z' end, CASE WHEN count IS NOT NULL then ( (count - " . Normalize . ") * ( 1 - ( '0.75' / (LENGTH(word) - " . WordLen . ")))) end DESC, Word"
   }
   
   
   Matches := wDB.Query("SELECT word FROM Words" . WhereQuery . OrderByQuery . " LIMIT " . LimitTotalMatches . ";")
   
   singlematch := Object()
   
   for each, row in Matches.Rows
   {      
      number++
      singlematch[number] := row[1]
      
      continue
   }
   
   ;If no match then clear Tip 
   IfEqual, number, 0
   {
      ClearAllVars(false)
      Return 
   } 
   
   SetupMatchPosition()
   RebuildMatchList()
   ShowListBox()
}

;------------------------------------------------------------------------

~LButton:: 
; Update last click position in case Caret is not detectable
;  and update the Last Window Clicked in
MouseGetPos, MouseX, MouseY, MouseWin_ID
WinGetPos, ,TempY, , , ahk_id %MouseWin_ID%
MouseButtonClick=LButton
; Using GoSub as A_CaretX in function call breaks doubleclick
Gosub, CheckForCaretMove
TempY = 
Return

;------------------------------------------------------------------------

~RButton:: 
; Update the Last Window Clicked in
MouseGetPos, , ,MouseWin_ID
MouseButtonClick=RButton
; Using GoSub as A_CaretX in function call breaks doubleclick
Gosub, CheckForCaretMove
Return

;------------------------------------------------------------------------

CheckForCaretMove:
   ;If we aren't using the DetectMouseClickMoveScheme, skip out
   IfNotEqual, DetectMouseClickMove, On
      Return
   
   IfEqual, MouseButtonClick, LButton
   {
      KeyWait, LButton, U    
   } else KeyWait, RButton, U
   
   IfNotEqual, LastInput_Id, %MouseWin_ID%
   {
      Return
   }
   
   SysGet, SM_CYCAPTION, 4
   SysGet, SM_CYSIZEFRAME, 33
   
   TempY += SM_CYSIZEFRAME
   IF ( ( MouseY >= TempY ) && (MouseY < (TempY + SM_CYCAPTION) ) )
   {
      Return
   }
   
   ; If we have a Word and an OldCaretX, check to see if the Caret moved
   IfNotEqual, OldCaretX, 
   {
      IfNotEqual, Word, 
      {
         if (( OldCaretY != HCaretY() ) || (OldCaretX != HCaretX() ))
         {
            ; add the word if switching lines
            AddWordToList(Word,0)
            ClearAllVars(true)
         }
      }
   }

   MouseButtonClick=
   Return
   
   
;------------------------------------------------------------------------

InitializeHotKeys()
{
   global ArrowKeyMethod
   global DelimiterChar
   global DisabledAutoCompleteKeys
   global EnabledKeyboardHotKeys
   global LearnMode  
   
   EnabledKeyboardHotKeys =

   ;Setup toggle-able hotkeys

   ;Can't disable mouse buttons as we need to check to see if we have clicked the ListBox window


   ; If we disable the number keys they never get to the input for some reason,
   ; so we need to keep them enabled as hotkeys

   IfNotEqual, LearnMode, On
   {
      Hotkey, $^+Delete, Off
   
      HotKey, $^+c, Off
   } else {
      HotKey, $^+c, On
      Hotkey, $^+Delete, Off
      ; We only want Ctrl-Shift-Delete enabled when the listbox is showing.
      EnabledKeyboardHotKeys .= "$^+Delete" . DelimiterChar
   }
   
   IfEqual, ArrowKeyMethod, Off
   {
      Hotkey, $^Enter, Off
      Hotkey, $^Space, Off
      Hotkey, $Tab, Off
      Hotkey, $Right, Off
      Hotkey, $Up, Off
      Hotkey, $Down, Off
      Hotkey, $PgUp, Off
      Hotkey, $PgDn, Off
   } else {
      EnabledKeyboardHotKeys .= "$Up" . DelimiterChar
      EnabledKeyboardHotKeys .= "$Down" . DelimiterChar
      EnabledKeyboardHotKeys .= "$PgUp" . DelimiterChar
      EnabledKeyboardHotKeys .= "$PgDn" . DelimiterChar
      If DisabledAutoCompleteKeys contains E
         Hotkey, $^Enter, Off
      else EnabledKeyboardHotKeys .= "$^Enter" . DelimiterChar
         If DisabledAutoCompleteKeys contains S
            HotKey, $^Space, Off
         else EnabledKeyboardHotKeys .= "$^Space" . DelimiterChar
         If DisabledAutoCompleteKeys contains T
            HotKey, $Tab, Off
         else EnabledKeyboardHotKeys .= "$Tab" . DelimiterChar
         If DisabledAutoCompleteKeys contains R
            HotKey, $Right, Off
         else EnabledKeyboardHotKeys .= "$Right" . DelimiterChar
         If DisabledAutoCompleteKeys contains U
            HotKey, $Enter, Off
         else EnabledKeyboardHotKeys .= "$Enter" . DelimiterChar
   }

   ; remove last ascii 2
   StringTrimRight, EnabledKeyboardHotKeys, EnabledKeyboardHotKeys, 1
   
}

EnableKeyboardHotKeys()
{
   global EnabledKeyboardHotKeys
   global DelimiterChar
   Loop, Parse, EnabledKeyboardHotKeys, %DelimiterChar%
   {
      HotKey, %A_LoopField%, On
   }
   Return
}

DisableKeyboardHotKeys()
{
   global EnabledKeyboardHotKeys
   global DelimiterChar
   Loop, Parse, EnabledKeyboardHotKeys, %DelimiterChar%
   {
      HotKey, %A_LoopField%, Off
   }
   Return
}
   
;------------------------------------------------------------------------

#MaxThreadsPerHotkey 1 
    
$1:: 
$2:: 
$3:: 
$4:: 
$5:: 
$6:: 
$7:: 
$8:: 
$9:: 
$0::
CheckWord(A_ThisHotkey)
Return

$^Enter::
$^Space::
$Tab::
$Up::
$Down::
$PgUp::
$PgDn::
$Right::
$Enter::
EvaluateUpDown(A_ThisHotKey)
Return

$^+h::
MaybeOpenOrCloseHelperWindowManual()
Return

$^+c:: 
AddSelectedWordToList()
Return

$^+Delete::
DeleteSelectedWordFromList()
Return

;------------------------------------------------------------------------

; If hotkey was pressed, check wether there's a match going on and send it, otherwise send the number(s) typed 
CheckWord(Key)
{
   global
   Local ATitle
   Local WordIndex
   Local KeyAgain
   
   StringRight, Key, Key, 1 ;Grab just the number pushed, trim off the "$"
   
   IfEqual, Key, 0
   {
      WordIndex := MatchStart + 9
   } else {
            WordIndex := MatchStart - 1 + Key
         }  
   
   IfEqual, NumKeyMethod, Off
   {
      SendCompatible(Key,0)
      ProcessKey(Key,"")
      Return
   }
   
   IfEqual, NumPresses, 2
      SuspendOn()

   ; If active window has different window ID from before the input, blank word 
   ; (well, assign the number pressed to the word) 
   if ( ReturnWinActive() = )
   { 
      SendCompatible(Key,0)
      ProcessKey(Key,"")
      IfEqual, NumPresses, 2
         SuspendOff()
      Return 
   } 
   
   if ReturnLineWrong() ;Make sure we are still on the same line
   { 
      SendCompatible(Key,0)
      ProcessKey(Key,"") 
      IfEqual, NumPresses, 2
         SuspendOff()
      Return 
   } 

   IfNotEqual, Match, 
   {
      ifequal, ListBox_ID,        ; only continue if match is not empty and list is showing
      { 
         SendCompatible(Key,0)
         ProcessKey(Key,"")
         IfEqual, NumPresses, 2
            SuspendOff()
         Return 
      }
   }

   ifequal, Word,        ; only continue if word is not empty 
   { 
      SendCompatible(Key,0)
      ProcessKey(Key,"")
      IfEqual, NumPresses, 2
         SuspendOff()
      Return 
   }
      
   if ( ( (WordIndex + 1 - MatchStart) > ListBoxRows) || ( Match = "" ) || (singlematch[WordIndex] = "") )   ; only continue singlematch is not empty 
   { 
      SendCompatible(Key,0)
      ProcessKey(Key,"")
      IfEqual, NumPresses, 2
         SuspendOff()
      Return 
   }

   IfEqual, NumPresses, 2
   {
      Input, keyagain, L1 I T0.5, 1234567890
      
      ; If there is a timeout, abort replacement, send key and return
      IfEqual, ErrorLevel, Timeout
      {
         SendCompatible(Key,0)
         ProcessKey(Key,"")
         SuspendOff()
         Return
      }

      ; Make sure it's an EndKey, otherwise abort replacement, send key and return
      IfNotInString, ErrorLevel, EndKey:
      {
         SendCompatible(Key . KeyAgain,0)
         ProcessKey(Key,"")
         ProcessKey(KeyAgain,"")
         SuspendOff()
         Return
      }
   
      ; If the 2nd key is NOT the same 1st trigger key, abort replacement and send keys   
      IfNotInString, ErrorLevel, %key%
      {
         StringTrimLeft, keyagain, ErrorLevel, 7
         SendCompatible(Key . KeyAgain,0)
         ProcessKey(Key,"")
         ProcessKey(KeyAgain,"")
         SuspendOff()
         Return
      }
   }

   SendWord(WordIndex)
   IfEqual, NumPresses, 2
      SuspendOff()
   Return 
}

;------------------------------------------------------------------------

;If a hotkey related to the up/down arrows was pressed
EvaluateUpDown(Key)
{
   global 
   IfEqual, ArrowKeyMethod, Off
   {
      SendKey(Key)
      Return
   }
   
   IfEqual, Match,
   {
      SendKey(Key)
      Return
   }

   IfEqual, ListBox_ID,
   {
      SendKey(Key)
      Return
   }

   if ( ReturnWinActive() = )
   {
      SendKey(Key)
      ClearAllVars(false)
      Return
   }

   if ReturnLineWrong()
   {
      SendKey(Key)
      ClearAllVars(true)
      Return
   }   
   
   IfEqual, Word, ; only continue if word is not empty
   {
      SendKey(Key)
      ClearAllVars(false)
      Return
   }
   
   if ( ( Key = "$^Enter" ) || ( Key = "$Tab" ) || ( Key = "$^Space" ) || ( Key = "$Right") || ( Key = "$Enter") )
   {
      Local KeyTest
      IfEqual, Key, $^Enter
      {
         KeyTest = E
      } else {
               IfEqual, Key, $Tab
               {
                  KeyTest = T
               } else {
                        IfEqual, Key, $^Space
                        {   
                           KeyTest = S 
                        } else {
                                 IfEqual, Key, $Right
                                 {
                                    KeyTest = R
                                 } else {
                                          IfEqual, Key, $Enter
                                             KeyTest = U
                                       }
                              }
                           
                     }
            }
      
      if DisabledAutoCompleteKeys contains %KeyTest%
      {
         SendKey(Key)
         Return     
      }
      
      if (singlematch[MatchPos] = "") ;only continue if singlematch is not empty
      {
         SendKey(Key)
         MatchPos = %Number%
         RebuildMatchList()
         ShowListBox()
         Return
      }
      
      SendWord(MatchPos)
      Return
      
   }

   Local PreviousMatchStart
   PreviousMatchStart = %MatchStart%
   
   IfEqual, Key, $Up
   {   
      MatchPos--
   
      IfLess, MatchPos, 1
      {
         MatchStart := Number - (ListBoxRows - 1)
         IfLess, MatchStart, 1
            MatchStart = 1
         MatchPos := Number
      } else {
               IfLess, MatchPos, %MatchStart%
                  MatchStart --
            }      
   } else {
            IfEqual, Key, $Down
            {
               MatchPos++
               IfGreater, MatchPos, %Number%
               {
                  MatchStart =1
                  MatchPos =1
               } Else {
                        If ( MatchPos > ( MatchStart + (ListBoxRows - 1) ) )
                           MatchStart ++
                     }            
             
            } else {
                     IfEqual, Key, $PgUp
                     {
                        IfEqual, MatchPos, 1
                        {
                           MatchPos := Number - (ListBoxRows - 1)
                           MatchStart := Number - (ListBoxRows - 1)
                        } Else {
                                 MatchPos-=ListBoxRows   
                                 MatchStart-=ListBoxRows
                              }
                        
                        IfLess, MatchPos, 1
                           MatchPos = 1
                        IfLess, MatchStart, 1
                           MatchStart = 1
                        
                     } else {
                              IfEqual, Key, $PgDn
                              {
                                 IfEqual, MatchPos, %Number%
                                 {
                                    MatchPos := ListBoxRows
                                    MatchStart := 1
                                 } else {
                                          MatchPos+=ListBoxRows
                                          MatchStart+=ListBoxRows
                                       }
                                 
                                 IfGreater, MatchPos, %Number%
                                    MatchPos := Number
                                    
                                 If ( MatchStart > ( Number - (ListBoxRows - 1) ) )
                                 {
                                    MatchStart := Number - (ListBoxRows - 1)   
                                    IfLess, MatchStart, 1
                                       MatchStart = 1
                                 }
                              }
                           }
                  }
         }
   
   IfEqual, MatchStart, %PreviousMatchStart%
   {
      Local Rows
      Rows := GetRows()
      IfNotEqual, MatchPos,
         GuiControl, ListBoxGui: Choose, ListBox%Rows%, %MatchPos%
   } else {
            RebuildMatchList()
            ShowListBox()
         }
   Return
}

;------------------------------------------------------------------------

ReturnLineWrong()
{
   global DetectMouseClickMove
   global OldCaretY
   ; Return false if we are using DetectMouseClickMove
   IfEqual, DetectMouseClickMove, On
      Return
      
   Return, ( OldCaretY != HCaretY() )
}

;------------------------------------------------------------------------

AddSelectedWordToList()
{      
   ClipboardSave := ClipboardAll
   Clipboard =
   Sleep, 100
   SendCompatible("^c",0)
   ClipWait, 0
   IfNotEqual, Clipboard, 
   {
      AddWordToList(Clipboard,1,"ForceLearn")
   }
   Clipboard = %ClipboardSave%
}

DeleteSelectedWordFromList()
{
   global MatchPos
   global singlematch
   
   if !(singlematch[MatchPos] = "") ;only continue if singlematch is not empty
   {
      
      DeleteWordFromList(singlematch[MatchPos])
      RecomputeMatches()
      Return
   }
   
}

;------------------------------------------------------------------------

SuspendOn()
{
   global ScriptTitle
   Suspend, On
   Menu, Tray, Tip, %ScriptTitle% - Inactive
   If A_IsCompiled
   {
      Menu, tray, Icon, %A_ScriptName%,3,1
   } else
   {
      Menu, tray, icon, %ScriptTitle%-Inactive.ico, ,1
   }
}

SuspendOff()
{
   global ScriptTitle
   Suspend, Off
   Menu, Tray, Tip, %ScriptTitle% - Active
   If A_IsCompiled
   {
      Menu, tray, Icon, %A_ScriptName%,1,1
   } else
   {
      Menu, tray, icon, %ScriptTitle%-Active.ico, ,1
   }
}   

;------------------------------------------------------------------------

BuildTrayMenu(State)
{

   Menu, Tray, DeleteAll
   Menu, Tray, NoStandard
   Menu, Tray, add, Settings, Configuration
   if (State == "Running")
   {
      Menu, Tray, add, Pause, PauseScript
   } else {
      Menu, Tray, add, Resume, ResumeScript
   }
   IF !(A_IsCompiled)
   {
      Menu, Tray, Standard
   }
   Menu, Tray, Default, Settings
   ;Initialize Tray Icon
   Menu, Tray, Icon
}

;------------------------------------------------------------------------

; This is to blank all vars related to matches, ListBox and (optionally) word 
ClearAllVars(ClearWord)
{
   global
   CloseListBox()
   Ifequal,ClearWord,1
   {
      word =
      OldCaretY=
      OldCaretX=
      LastInput_id=
   }
   
   singlematch =
   sending = 
   key= 
   match= 
   MatchPos=
   MatchStart= 
   Return
}

;------------------------------------------------------------------------

FileAppendDispatch(Text,FileName,ForceEncoding=0)
{
   IfEqual, A_IsUnicode, 1
   {
      IfNotEqual, ForceEncoding, 0
      {
         FileAppend, %Text%, %FileName%, %ForceEncoding%
      } else
      {
         FileAppend, %Text%, %FileName%, UTF-8
      }
   } else {
            FileAppend, %Text%, %FileName%
         }
   Return
}

MaybeFixFileEncoding(File,Encoding)
{
   IfGreaterOrEqual, A_AhkVersion, 1.0.90.0
   {
      
      IfExist, %File%
      {    
         IfNotEqual, A_IsUnicode, 1
         {
            Encoding =
         }
         
         
         EncodingCheck := FileOpen(File,"r")
         
         If EncodingCheck
         {
            If Encoding
            {
               IF !(EncodingCheck.Encoding = Encoding)
                  WriteFile = 1
            } else
            {
               IF (SubStr(EncodingCheck.Encoding, 1, 3) = "UTF")
                  WriteFile = 1
            }
         
            IF WriteFile
            {
               Contents := EncodingCheck.Read()
               EncodingCheck.Close()
               EncodingCheck =
               FileCopy, %File%, %File%.preconv.bak
               FileDelete, %File%
               FileAppend, %Contents%, %File%, %Encoding%
               
               Contents =
            } else
            {
               EncodingCheck.Close()
               EncodingCheck =
            }
         }
      }
   }
}

;------------------------------------------------------------------------

Configuration:
GoSub, LaunchSettings
Return

PauseScript:
DisableWinHook()
SuspendOn()
BuildTrayMenu("Paused")
Pause, On, 1
Return

   
ResumeScript:
Pause, Off
EnableWinHook()
BuildTrayMenu("Running")
Return
   
SaveScript:
; Close the ListBox if it's open
CloseListBox()

SuspendOn()

;Change the cleanup performance speed
SetBatchLines, 20ms
Process, Priority,,Normal

;Grab the Helper Window Position if open
MaybeSaveHelperWindowPos()

;Write the Helper Window Position to the Preferences File
MaybeWriteHelperWindowPos()

; Update the Learned Words
MaybeUpdateWordlist()

ExitApp

#Include %A_ScriptDir%\Includes\ListBox.ahk
#Include %A_ScriptDir%\Includes\Helper.ahk
#Include %A_ScriptDir%\Includes\Preferences File.ahk
#Include %A_ScriptDir%\Includes\Sending.ahk
#Include %A_ScriptDir%\Includes\Settings.ahk
#Include %A_ScriptDir%\Includes\Window.ahk
#Include %A_ScriptDir%\Includes\Wordlist.ahk
#Include <DBA>
