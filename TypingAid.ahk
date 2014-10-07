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


;disable hotkeys until setup is complete
Suspend, On 
#NoEnv
ListLines Off

;Set the Coordinate Modes before any threads can be executed
CoordMode, Caret, Screen
CoordMode, Mouse, Screen

OnExit, SaveScript

;Change the setup performance speed
SetBatchLines, 20ms
;read in the preferences file
ReadPreferences()

SetTitleMatchMode, 2

;setup code
clearword=1
MouseX = 0 
MouseY = 0 
Helper_id = 
HelperManual = 
DelimiterChar := Chr(2)
AutoTrim, Off 

;Gui Init Code
ListBoxGui=1
HelperGui=2
MenuGui=3

InitializeListBox()

BlockInput, Send

IfEqual, A_IsUnicode, 1
{
   ; MaxLengthInLearnMode = (253 (max len of var name) - zcount)/ 4 rounded down
   MaxLengthInLearnMode = 61
   ; Need 4 characters in Unicode mode
   AsciiPrefix = 000
   AsciiTrimLength = -3
} else {
         ; MaxLengthInLearnMode = (253 (max len of var name) - zcount)/ 2 rounded down
         MaxLengthInLearnMode = 123
         ; Need 2 characters in Ascii mode
         AsciiPrefix = 0
         AsciiTrimLength = -1
      }

;Read in the WordList
ReadWordList()

;Setup toggle-able hotkeys

;Can't disable mouse buttons as we need to check to see if we have clicked the ListBox window

EnabledKeyboardHotKeys = 

; If we disable the number keys they never get to the input for some reason,
; so we need to keep them enabled as hotkeys

IfNotEqual, LearnMode, On
{
   Hotkey, $^+Delete, Off
   ; We only want Ctrl-Shift-Delete enabled when the listbox is showing.
   EnabledKeyboardHotKeys .= "$^+Delete" . DelimiterChar
   
   HotKey, $^+c, Off
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

DisableKeyboardHotKeys()
   
;Find the ID of the window we are using
GetIncludedActiveWindow()  

; Set a timer to check for a changed window
SetTimer, Winchanged, 100

;Change the Running performance speed (Priority changed to High in GetIncludedActiveWindow)
SetBatchLines, -1

Loop 
{ 

   ;If the active window has changed, wait for a new one
   IF !( ReturnWinActive() ) 
      GetIncludedActiveWindow()
   
   ;Get one key at a time 
   Input, chr, L1 V, {BS}%TerminatingCharacters%
   
   ProcessKey(chr,errorlevel)
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

   IfEqual, EndKey, Endkey:Tab
      If ( GetKeyState("Alt") =1 || GetKeyState("LWin") =1 || GetKeyState("RWin") =1 )
         Return
   
   ;If we have no window activated for typing, we don't want to do anything with the typed character
   IfEqual, A_id,
   {
      GetIncludedActiveWindow()
      Return
   }


   IF !( ReturnWinActive() )
   {
      GetIncludedActiveWindow()
      Return
   }
   
   IfEqual, A_id, %Helper_id%
   {
      Return
   }
   
   ;If we haven't typed anywhere, set this as the last window typed in
   IfEqual, LastInput_Id,
      LastInput_Id = %A_id%
   
   IfNotEqual, DetectMouseClickMove, On
   {
      ifequal, OldCaretY,
         OldCaretY := HCaretY()
         
      if ( OldCaretY != HCaretY() )
      {
         ;Don't do anything if we aren't in the original window and aren't starting a new word
         IfNotEqual, LastInput_Id, %A_id%
            Return
            
         ; add the word if switching lines
         AddWordToList(Word,0)
         Gosub,clearallvars
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
      IfNotEqual, LastInput_Id, %A_id%
         Return
      
      StringLen, len, Word
      IfNotEqual, len, 0
      { 
         ifequal, len, 1   
         { 
            Gosub,clearallvars
         } else {
                  StringTrimRight, Word, Word, 1
                }     
      }
   } else ifequal, EndKey, Max
         {
            ; If active window has different window ID from the last input,
            ;learn and blank word, then assign number pressed to the word
            IfNotEqual, LastInput_Id, %A_id%
            {
               AddWordToList(Word,0)
               Gosub, clearallvars
               word = %chr%
               LastInput_Id = %A_id%
               Return
            }
         
            if chr in %ForceNewWordCharacters%
            {
               AddWordToList(Word,0)
               Gosub, clearallvars
               Word = %chr%
               Return
            } else { 
                  Word .= chr
                  }
         } else {
                  ;Don't do anything if we aren't in the original window and aren't starting a new word
                  IfNotEqual, LastInput_Id, %A_id%
                     Return
                     
                  AddWordToList(Word,0)
                  Gosub, clearallvars   
                  Return
                }
    
   ;Wait till minimum letters 
   IF ( StrLen(Word) < wlen )
   {
      CloseListBox()
      Return
   }
   
   RecomputeMatches()
}

RecomputeMatches()
{
   ; This function will take the given word, and will recompile the list of matches and redisplay the wordlist.
   global

   SavePriorMatchPosition()

   ;Match part-word with command 
   Num = 
   number = 0 
   StringLeft, baseword, Word, %wlen%
   baseword := ConvertWordToAscii(baseword,1)
   
   IfEqual, ArrowKeyMethod, Off
   {
      IfLess, ListBoxRows, 10
         LimitTotalMatches = %ListBoxRows%
      else LimitTotalMatches = 10
   }

   Loop
   {
      IfEqual, zword%baseword%%a_index%,, Break
      
      IfEqual, ArrowKeyMethod, Off
      {
         IfGreaterOrEqual, number, %LimitTotalMatches%
            Break
      }
      
      IfEqual, SuppressMatchingWord, On
      {
         IfEqual, NoBackSpace, Off
         {
            If ( zword%baseword%%a_index% == Word )
               continue
         } else If ( zword%baseword%%a_index% = Word )
                     continue
      }
      
      if ( SubStr(zword%baseword%%a_index%, 1, StrLen(Word)) = Word )
      {
         number ++
         singlematch := zword%baseword%%a_index%
         singlematch%number% = %singlematch%
            
         Continue            
      }
   }
   
   ;If no match then clear Tip 
   IfEqual, number, 0
   {
      clearword=0 
      Gosub,clearallvars 
      Return 
   } 
   
   SetupMatchPosition()
   RebuildMatchList()
   ShowListBox()
}

;------------------------------------------------------------------------

~LButton:: 
;make sure we are in decimal format in case ConvertWordToAscii was interrupted
IfEqual, A_FormatInteger, H
   SetFormat,Integer,D
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
      
   ;make sure we are in decimal format in case ConvertWordToAscii was interrupted
   IfEqual, A_FormatInteger, H
      SetFormat,Integer,D
   
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
         if ( OldCaretY != HCaretY() )
         {
            ; add the word if switching lines
            AddWordToList(Word,0)
            Gosub,clearallvars
         } else if (OldCaretX != HCaretX() )
               {
                  AddWordToList(Word,0)
                  Gosub,clearallvars
               }
      }
   }

   MouseButtonClick=
   Return
   
   
;------------------------------------------------------------------------

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
   ;make sure we are in decimal format in case ConvertWordToAscii was interrupted
   IfEqual, A_FormatInteger, H
      SetFormat,Integer,D
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
      Suspend, On

   ; If active window has different window ID from before the input, blank word 
   ; (well, assign the number pressed to the word) 
   if ( ReturnWinActive() = )
   { 
      SendCompatible(Key,0)
      ProcessKey(Key,"")
      IfEqual, NumPresses, 2
         Suspend, Off
      Return 
   } 
   
   if ReturnLineWrong() ;Make sure we are still on the same line
   { 
      SendCompatible(Key,0)
      ProcessKey(Key,"") 
      IfEqual, NumPresses, 2
         Suspend, Off
      Return 
   } 

   IfNotEqual, Match, 
   {
      ifequal, ListBox_ID,        ; only continue if match is not empty and list is showing
      { 
         SendCompatible(Key,0)
         ProcessKey(Key,"")
         IfEqual, NumPresses, 2
            Suspend, Off
         Return 
      }
   }

   ifequal, Word,        ; only continue if word is not empty 
   { 
      SendCompatible(Key,0)
      ProcessKey(Key,"")
      IfEqual, NumPresses, 2
         Suspend, Off
      Return 
   }
      
   if ( ( (WordIndex + 1 - MatchStart) > ListBoxRows) || ( Match = "" ) || (singlematch%WordIndex% = "") )   ; only continue singlematch is not empty 
   { 
      SendCompatible(Key,0)
      ProcessKey(Key,"")
      IfEqual, NumPresses, 2
         Suspend, Off
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
         Suspend, off
         Return
      }

      ; Make sure it's an EndKey, otherwise abort replacement, send key and return
      IfNotInString, ErrorLevel, EndKey:
      {
         SendCompatible(Key . KeyAgain,0)
         ProcessKey(Key,"")
         ProcessKey(KeyAgain,"")
         Suspend, off
         Return
      }
   
      ; If the 2nd key is NOT the same 1st trigger key, abort replacement and send keys   
      IfNotInString, ErrorLevel, %key%
      {
         StringTrimLeft, keyagain, ErrorLevel, 7
         SendCompatible(Key . KeyAgain,0)
         ProcessKey(Key,"")
         ProcessKey(KeyAgain,"")
         Suspend, Off
         Return
      }
   }

   SendWord(WordIndex)
   IfEqual, NumPresses, 2
      Suspend, Off
   Return 
}

;------------------------------------------------------------------------

;If a hotkey related to the up/down arrows was pressed
EvaluateUpDown(Key)
{
   global 
   ;make sure we are in decimal format in case ConvertWordToAscii was interrupted
   IfEqual, A_FormatInteger, H
      SetFormat,Integer,D
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
      clearword=0
      Gosub, ClearAllVars
      Return
   }

   if ReturnLineWrong()
   {
      SendKey(Key)
      GoSub, ClearAllVars
      Return
   }   
   
   IfEqual, Word, ; only continue if word is not empty
   {
      SendKey(Key)
      ClearWord = 0
      GoSub, ClearAllVars
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
      
      IfEqual, singlematch%MatchPos%, ;only continue if singlematch is not empty
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
         GuiControl, %ListBoxGui%: Choose, ListBox%Rows%, %MatchPos%
   } else {
            RebuildMatchList()
            ShowListBox()
         }
   Return
}

;------------------------------------------------------------------------

ReturnLineWrong()
{
   global
   ; Return false if we are using DetectMouseClickMove
   IfEqual, DetectMouseClickMove, On
      Return
      
   Return, ( OldCaretY != HCaretY() )
}

;------------------------------------------------------------------------

AddSelectedWordToList()
{
   ;make sure we are in decimal format in case ConvertWordToAscii was interrupted
   IfEqual, A_FormatInteger, H
      SetFormat,Integer,D
      
   ClipboardSave := ClipboardAll
   Clipboard =
   Sleep, 100
   SendCompatible("^c",0)
   ClipWait, 0
   IfNotEqual, Clipboard, 
   {
      AddWordToList(Clipboard,1)
   }
   Clipboard = %ClipboardSave%
}

DeleteSelectedWordFromList()
{
   global
   ;make sure we are in decimal format in case ConvertWordToAscii was interrupted
   IfEqual, A_FormatInteger, H
      SetFormat,Integer,D
   
   IfNotEqual, singlematch%MatchPos%, ;only continue if singlematch is not empty
   {
      
      DeleteWordFromList(singlematch%MatchPos%)
      RecomputeMatches()
      Return
   }
   
}

;------------------------------------------------------------------------

; This is to blank all vars related to matches, ListBox and (optionally) word 
clearallvars: 
   ;make sure we are in decimal format in case ConvertWordToAscii was interrupted
   IfEqual, A_FormatInteger, H
      SetFormat,Integer,D
   CloseListBox()
   Ifequal,clearword,1
   {
      word =
      OldCaretY=
      OldCaretX=
      LastInput_id=
   }
   ; Clear all singlematches 
   Loop,
   { 
      IfEqual, singlematch%A_Index%,
         Break
         
      singlematch%a_index% = 
   } 
   sending = 
   key= 
   match= 
   MatchPos=
   MatchStart=
   clearword=1 
   Return

;------------------------------------------------------------------------

FileAppendDispatch(Text,FileName)
{
   IfEqual, A_IsUnicode, 1
   {
      FileAppend, %Text%, %FileName%, UTF-8
   } else {
            FileAppend, %Text%, %FileName%
         }
   Return
}

;------------------------------------------------------------------------
   
SaveScript:
;make sure we are in decimal format in case ConvertWordToAscii was interrupted
IfEqual, A_FormatInteger, H
   SetFormat,Integer,D

; Close the ListBox if it's open
CloseListBox()

Suspend, On

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
#Include %A_ScriptDir%\Includes\Window.ahk
#Include %A_ScriptDir%\Includes\Wordlist.ahk
