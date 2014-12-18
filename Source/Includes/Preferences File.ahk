;These functions and labels are related to the preferences file

MaybeWriteHelperWindowPos()
{
   global
   ;Update the Helper Window Position
   IfEqual, XYSaved, 1
   {
      IfNotEqual, XY, 
         IniWrite, %XY%, %A_ScriptDir%\LastState.ini, HelperWindow, XY
   }
   Return
}

;------------------------------------------------------------------------

ReadPreferences()
{
   global
   Local Prefs
   Local INI
   Local Defaults
   Local LastState
   Local IniValues
   Local CurrentIniValues
   Local CurrentIniValues0
   Local CurrentIniValues1
   Local CurrentIniValues2
   Local CurrentIniValues3
   Local CurrentIniValues4
   Local CurrentIniValues5
   Local SpaceVar
   Local DftVariable
   Local NormalVariable
   Local IniSection
   Local IniKey
   Local DftValue
   Local BrokenTerminatingCharacters
   
   Local DftIncludeProgramExecutables
   Local DftIncludeProgramTitles
   Local DftExcludeProgramExecutables
   Local DftExcludeProgramTitles
   Local DftWlen
   Local DftNumPresses
   Local DftLearnMode
   Local DftLearnCount
   Local DftLearnLength
   Local DftDoNotLearnStrings
   Local DftArrowKeyMethod
   Local DftDisabledAutoCompleteKeys
   Local DftDetectMouseClickMove
   Local DftNoBackSpace
   Local DftAutoSpace
   Local DftSuppressMatchingWord
   Local DftSendMethod
   ;DftTerminatingCharacters should be global so it works in the help strings
   Local DftForceNewWordCharacters
   Local DftListBoxOffSet
   Local DftListBoxFontFixed
   Local DftListBoxFontOverride
   Local DftListBoxFontSize
   Local DftListBoxCharacterWidth
   Local DftListBoxOpacity
   Local DftListBoxRows
   Local DftHelperWindowProgramExecutables
   Local DftHelperWindowProgramTitles
   
   Prefs = %A_ScriptDir%\Preferences.ini
   Defaults = %A_ScriptDir%\Defaults.ini
   LastState = %A_ScriptDir%\LastState.ini
   
   MaybeFixFileEncoding(Prefs,"UTF-16")
   MaybeFixFileEncoding(Defaults,"UTF-16")
   MaybeFixFileEncoding(LastState,"UTF-16")
   
   DftTerminatingCharacters = {enter}{space}{esc}{tab}{Home}{End}{PgUp}{PgDn}{Up}{Down}{Left}{Right}.;`,¿?¡!'"()[]{}{}}{{}``~`%$&*-+=\/><^|@#:
   
   
   ; There was a bug in TypingAid 2.19.7 that broke terminating characters for new preference files, this code repairs it
   BrokenTerminatingCharacters = {enter}{space}{esc}{tab}{Home}{End}{PgUp}{PgDn}{Up}{Down}{Left}{Right}.;
   IfExist, %Prefs%
   {
      IniRead, MaybeFixTerminatingCharacters, %Prefs%, Settings, TerminatingCharacters, %A_Space%
      IF (MaybeFixTerminatingCharacters == BrokenTerminatingCharacters)
      {
         IniWrite, %DftTerminatingCharacters%, %Prefs%, Settings, TerminatingCharacters
      }
   }      
   
   SpaceVar := "%A_Space%"
   
   IniValues =
   (
      DftIncludeProgramExecutables,IncludeProgramExecutables,IncludePrograms,IncludeProgramExecutables,%SpaceVar%
      DftIncludeProgramTitles,IncludeProgramTitles,IncludePrograms,IncludeProgramTitles,%SpaceVar%
      DftExcludeProgramExecutables,ExcludeProgramExecutables,ExcludePrograms,ExcludeProgramExecutables,%SpaceVar%
      DftExcludeProgramTitles,ExcludeProgramTitles,ExcludePrograms,ExcludeProgramTitles,%SpaceVar%
      ,Title,Settings,Title,%SpaceVar%
      DftWlen,Wlen,Settings,Length,3
      DftNumPresses,NumPresses,Settings,NumPresses,1
      DftLearnMode,LearnMode,Settings,LearnMode,On
      DftLearnCount,LearnCount,Settings,LearnCount,5
      DftLearnLength,LearnLength,Settings,LearnLength,%SpaceVar%
      DftDoNotLearnStrings,DoNotLearnStrings,Settings,DoNotLearnStrings,%SpaceVar%
      DftArrowKeyMethod,ArrowKeyMethod,Settings,ArrowKeyMethod,First
      DftDisabledAutoCompleteKeys,DisabledAutoCompleteKeys,Settings,DisabledAutoCompleteKeys,%SpaceVar%
      DftDetectMouseClickMove,DetectMouseClickMove,Settings,DetectMouseClickMove,On
      DftNoBackSpace,NoBackSpace,Settings,NoBackSpace,On
      DftAutoSpace,AutoSpace,Settings,AutoSpace,Off
      DftSuppressMatchingWord,SuppressMatchingWord,Settings,SuppressMatchingWord,Off
      DftSendMethod,SendMethod,Settings,SendMethod,1
      DftTerminatingCharacters,TerminatingCharacters,Settings,TerminatingCharacters,`%DftTerminatingCharacters`%
      DftForceNewWordCharacters,ForceNewWordCharacters,Settings,ForceNewWordCharacters,%SpaceVar%
      DftListBoxOffSet,ListBoxOffset,ListBoxSettings,ListBoxOffset,14
      DftListBoxFontFixed,ListBoxFontFixed,ListBoxSettings,ListBoxFontFixed,Off
      DftListBoxFontOverride,ListBoxFontOverride,ListBoxSettings,ListBoxFontOverride,%SpaceVar%
      DftListBoxFontSize,ListBoxFontSize,ListBoxSettings,ListBoxFontSize,10      
      DftListBoxCharacterWidth,ListBoxCharacterWidth,ListBoxSettings,ListBoxCharacterWidth,%SpaceVar%
      DftListBoxOpacity,ListBoxOpacity,ListBoxSettings,ListBoxOpacity,215
      DftListBoxRows,ListBoxRows,ListBoxSettings,ListBoxRows,10
      DftHelperWindowProgramExecutables,HelperWindowProgramExecutables,HelperWindow,HelperWindowProgramExecutables,%SpaceVar%
      DftHelperWindowProgramTitles,HelperWindowProgramTitles,HelperWindow,HelperWindowProgramTitles,%SpaceVar%
      ,XY,HelperWindow,XY,%SpaceVar%
   )
    
   Loop, Parse, IniValues, `n, `r%A_Space%
   {
      StringSplit, CurrentIniValues, A_LoopField, `,
      DftVariable := CurrentIniValues1
      NormalVariable := CurrentIniValues2
      IniSection := CurrentIniValues3
      IniKey := CurrentIniValues4
      DftValue := CurrentIniValues5
      
      IF (DftValue == "%DftTerminatingCharacters%")
      {
         DftValue := DftTerminatingCharacters
      }

      IF ( DftValue = "%A_Space%" )
         DftValue := A_Space
      
      IniRead, %NormalVariable%, %Prefs%, %IniSection%, %IniKey%, %A_Space%
      
      IF DftVariable
      { 
         IniRead, %DftVariable%, %Defaults%, %IniSection%, %IniKey%, %DftValue%
         IfEqual, %NormalVariable%,
            %NormalVariable% := %DftVariable%
      }
   }
   
   IfEqual, LearnLength,
      LearnLength := Wlen +2
   
   IfExist, %LastState%
   {
      IniRead, XY, %LastState%, HelperWindow, XY, %A_Space%
   }
   
   If !(FileExist(Prefs) || FileExist(Defaults))
   {
      INI= 
               ( 
[IncludePrograms]
;
;IncludeProgramExecutables is a list of executable (.exe) files that TypingAid should be enabled for.
;If one the executables matches the current program, TypingAid is enabled for that program.
; ex: IncludeProgramExecutables=notepad.exe|iexplore.exe
IncludeProgramExecutables=%DftIncludeProgramExecutables%
;
;
;IncludeProgramTitles is a list of strings (separated by | ) to find in the title of the window you want TypingAid enabled for.
;If one of the strings is found in the title, TypingAid is enabled for that window.
; ex: IncludeProgramTitles=Notepad|Internet Explorer
IncludeProgramTitles=%DftIncludeProgramTitles%
;
;
[ExcludePrograms]
;
;ExcludeProgramExecutables is a list of executable (.exe) files that TypingAid should be disabled for.
;If one the executables matches the current program, TypingAid is disabled for that program.
; ex: ExcludeProgramExecutables=notepad.exe|iexplore.exe
ExcludeProgramExecutables=%DftExcludeProgramExecutables%
;
;
;ExcludeProgramTitles is a list of strings (separated by | ) to find in the title of the window you want TypingAid disabled for.
;If one of the strings is found in the title, TypingAid is disabled for that window.
; ex: ExcludeProgramTitles=Notepad|Internet Explorer
ExcludeProgramTitles=%DftExcludeProgramTitles%
;
;
[Settings]
;
;Length is the minimum number of characters that need to be typed before the program shows a List of words.
;Generally, the higher this number the better the performance will be.
;For example, if you need to autocomplete "as soon as possible" in the word list, set this to 2, type 'as' and a list will appear.
Length=%DftWlen%
;
;
;NumPresses is the number of times the number hotkey must be tapped for the word to be selected, either 1 or 2.
NumPresses=%DftNumPresses%
;
;
;LearnMode defines whether or not the script should learn new words as you type them, either On or Off.
;Entries in the wordlist are limited to a length of 123 characters in ANSI version
;or 61 characters in Unicode version if LearnMode is On.
LearnMode=%DftLearnMode%
;
;
;LearnCount defines the number of times you have to type a word within a single session for it to be learned permanently.
LearnCount=%DftLearnCount%
;
;
;LearnLength is the minimum number of characters in a word for it to be learned. This must be at least Length+1.
LearnLength=%DftLearnLength%
;
;
;DoNotLearnStrings is a comma separated list of strings. Any words which contain any of these strings will not be learned.
;This can be used to prevent the program from learning passwords or other critical information.
;For example, if you have ord98 in DoNotLearnStrings, password987 will not be learned.
; ex: DoNotLearnStrings=ord98,fr21
DoNotLearnStrings=%DftDoNotLearnStrings%
;
;
;ArrowKeyMethod is the way the arrow keys are handled when a list is shown.
;Options are:
;  Off - you can only use the number keys
;  First - resets the selection cursor to the beginning whenever you type a new character
;  LastWord - keeps the selection cursor on the prior selected word if it's still in the list, else resets to the beginning
;  LastPosition - maintains the selection cursor's position
ArrowKeyMethod=%DftArrowKeyMethod%
;
;
;DisabledAutoCompleteKeys is used to disable certain hotkeys from autocompleting the selected item in the list.
;Place the character listed for each key you want to disable in the list.
; ex: DisabledAutoCompleteKeys=ST
;will disable Ctrl+Space and Tab.
;  E = Ctrl + Enter
;  S = Ctrl + Space
;  T = Tab
;  R = Right Arrow
;  N = Number Keys
;  U = Enter
DisabledAutoCompleteKeys=%DftDisabledAutoCompleteKeys%
;
;
;DetectMouseClickMove is used to detect when the cursor is moved with the mouse.
; On - TypingAid will not work when used with an On-Screen keyboard.
; Off - TypingAid will not detect when the cursor is moved within the same line using the mouse, and scrolling the text will clear the list.
DetectMouseClickMove=%DftDetectMouseClickMove%
;
;
;NoBackSpace is used to make TypingAid not backspace any of the previously typed characters
;(ie, do not change the case of any previously typed characters).
;  On - characters you have already typed will not be changed
;  Off - characters you have already typed will be backspaced and replaced with the case of the word you have chosen.
NoBackSpace=%DftNoBackSpace%
;
;
;AutoSpace is used to automatically add a space to the end of an autocompleted word.
; On - Add a space to the end of the autocompleted word.
; Off - Do not add a space to the end of the autocompleted word.
AutoSpace=%DftAutoSpace%
;
;
;SuppressMatchingWord is used to suppress a word from the Word list if it matches the typed word.
;  If NoBackspace=On, then the match is case in-sensitive.
;  If NoBackspace=Off, then the match is case-sensitive.
; On - Suppress matching words from the word list.
; Off - Do not suppress matching words from the word list.
SuppressMatchingWord=%DftSuppressMatchingWord%
;
;
;SendMethod is used to change the way the program sends the keys to the screen, this is included for compatibility reasons.
;Try changing this only when you encounter a problem with key sending during autocompletion.
;  1 = Fast method that reliably buffers key hits while sending. HAS BEEN KNOWN TO NOT FUNCTION ON SOME MACHINES.
;      (Might not work with characters that cannot be typed using the current keyboard layout.)
;  2 = Fastest method with unreliable keyboard buffering while sending. Has been known to not function on some machines.
;  3 = Slowest method, will not buffer or accept keyboard input while sending. Most compatible method.
;The options below use the clipboard to copy and paste the data to improve speed, but will leave an entry in any clipboard 
;history tracking routines you may be running. Data on the clipboard *will* be preserved prior to autocompletion.
;  1C = Same as 1 above.
;  2C = Same as 2 above, doesn't work on some machines.
;  3C = Same as 3 above.
;  4C = Alternate method.
SendMethod=%DftSendMethod%
;
;
;TerminatingCharacters is a list of characters (EndKey) which will signal the program that you are done typing a word.
;You probably need to change this only when you want to recognize and type accented (diacritic) or Unicode characters
;or if you are using this with certain programming languages.
;
;For support of special characters, remove the key that is used to type the diacritic symbol (or the character) from the right hand side. 
;For example, if on your keyboard layout, " is used before typing ë, ; is used to type ñ, remove them from the right hand side.
;
;After this, TypingAid can recognize the special character. The side-effect is that, it cannot complete words typed after 
;the symbol, (e.g. "word... ) If you need to complete a word after a quotation mark, first type two quotation marks "" then 
;press left and type the word in the middle.
;
;If unsure, below is a setting for you to copy and use directly:
;
;Universal setting that works for many languages with accented or Unicode characters:
;{enter}{space}{bs}{esc}{tab}{Home}{End}{PgUp}{PdDn}{Up}{Dn}{Left}{Right}¿?¡!()$
;
;Default setting:
;%DftTerminatingCharacters%
;
; More information on how to configure TerminatingCharacters:
;A list of keys may be found here:
; http://www.autohotkey.com/docs/KeyList.htm
;For more details on how to format the list of characters please see the EndKeys section (paragraphs 2,3,4) of:
; http://www.autohotkey.com/docs/commands/Input.htm
TerminatingCharacters=%DftTerminatingCharacters%
;
;
;ForceNewWordCharacters is a comma separated list of characters which forces the program to start a new word whenever
;one of those characters is typed. Any words which begin with one of these characters will never be learned (even
;if learning is enabled). If you were typing a word when you hit one of these characters that word will be learned
;if learning is enabled.
;Change this only if you know what you are doing, it is probably only useful for certain programming languages.
; ex: ForceNewWordCharacters=@,:,#
ForceNewWordCharacters=%DftForceNewWordCharacters%
;
;
[ListBoxSettings]
;
;ListBoxOffset is the number of pixels below the top of the caret (vertical blinking line) to display the list.
ListBoxOffset=%DftListBoxOffSet%
;
;
;ListBoxFontFixed controls whether a fixed or variable character font width is used.
;(ie, in fixed width, "i" and "w" take the same number of pixels)
ListBoxFontFixed=%DftListBoxFontFixed%
;
;
;ListBoxFontOverride is used to specify a font for the List Box to use. The default for Fixed is Courier,
;and the default for Variable is Tahoma.
ListBoxFontOverride=%DftListBoxFontOverride%
;
;
;ListBoxFontSize controls the size of the font in the list.
ListBoxFontSize=%DftListBoxFontSize%
;
;
;ListBoxCharacterWidth is the width (in pixels) of one character in the List Box.
;This number should only need to be changed if the box containing the list is not the correct width.
;Some things which may cause this to need to be changed would include:
; 1. Changing the Font DPI in Windows
; 2. Changing the ListBoxFontFixed setting
; 3. Changing the ListBoxFontSize setting
;Leave this blank to let TypingAid try to compute the width.
ListBoxCharacterWidth=%DftListBoxCharacterWidth%
;
;
;ListBoxOpacity is how transparent (see-through) the ListBox should be. Use a value of 255 to make it so the
;ListBox is fully Opaque, or use a value of 0 to make it so the ListBox cannot be seen at all.
ListBoxOpacity=%DftListBoxOpacity%
;
;
;ListBoxRows is the maximum number of rows to show in the ListBox. This value can range from 3 to 30.
ListBoxRows=%DftListBoxRows%
;
;
[HelperWindow]
;
;HelperWindowProgramExecutables is a list of executable (.exe) files that the HelperWindow should be automatically enabled for.
;If one the executables matches the current program, the HelperWindow will pop up automatically for that program.
; ex: HelperWindowProgramExecutables=notepad.exe|iexplore.exe
HelperWindowProgramExecutables=%DftHelperWindowProgramExecutables%
;
;
;HelperWindowProgramTitles is a list of strings (separated by | ) to find in the title of the window that the HelperWindow should be automatically enabled for.
;If one of the strings is found in the title, the HelperWindow will pop up automatically for that program.
; ex: HelperWindowProgramTitles=Notepad|Internet Explorer
HelperWindowProgramTitles=%DftHelperWindowProgramTitles%
               )
               FileAppendDispatch(INI, Prefs, "UTF-16")
         }
   
   ; Legacy support for old Preferences File
   IfNotEqual, Etitle,
   {
      IfEqual, IncludeProgramTitles,
      {
         IncludeProgramTitles = %Etitle%
      } else {
               IncludeProgramTitles .= "|" . Etitle
            }
      
      Etitle=      
   }
   
   if Wlen is not integer
   {
      Wlen = %DftWlen%
   }
   
   if NumPresses not in 1,2
      NumPresses = %DftNumPresses%
   
   If LearnMode not in On,Off
      LearnMode = %DftLearnMode%
   
   If LearnCount is not Integer
      LearnCount = %DftLearnCount%
      
   If LearnLength is not Integer
   {
      LearnLength := Wlen + 2
   } else {
            If ( LearnLength < ( Wlen + 1 ) )
               LearnLength := Wlen + 1
         }
   
   if DisabledAutoCompleteKeys contains N
      NumKeyMethod = Off
   
   IfNotEqual, ArrowKeyMethod, Off
      If DisabledAutoCompleteKeys contains E
         If DisabledAutoCompleteKeys contains S
            If DisabledAutoCompleteKeys contains T
               If DisabledAutoCompleteKeys contains R
                  ArrowKeyMethod = Off
   
   If ArrowKeyMethod not in First,Off,LastWord,LastPosition
   {
      ArrowKeyMethod = %DftArrowKeyMethod%       
   }
   
   If DetectMouseClickMove not in On,Off
      DetectMouseClickMove = %DftDetectMouseClickMove%
   
   If NoBackSpace not in On,Off
      NoBackSpace = %DftNoBackSpace%
      
   If AutoSpace not in On,Off
      AutoSpace = %DftAutoSpace%
   
   if SendMethod not in 1,2,3,1C,2C,3C,4C
      SendMethod = %DftSendMethod%
   
   ;SendPlay does not work when not running as Administrator, switch to SendInput
   If not A_IsAdmin
   {
      IfEqual, SendMethod, 1
      {
         SendMethod = 2
      }
      
      else IfEqual, SendMethod, 1C
            {
               SendMethod = 2C   
            }
   }
         
      
   IfEqual, TerminatingCharacters,
      TerminatingCharacters = %DftTerminatingCharacters%
   
   ParseTerminatingCharacters()
   
   if ListBoxOffset is not Integer
      ListBoxOffset = %DftListBoxOffSet%
      
   if ListBoxFontFixed not in On,Off
      ListBoxFontFixed = %DftListBoxFontFixed%
   
   If ListBoxFontSize is not Integer
      ListBoxFontSize = %DftListBoxFontSize%
   else {
         IfLess, ListBoxFontSize, 2
            ListBoxFontSize = 2
      }
   
   if ListBoxCharacterWidth is not Integer
      ListBoxCharacterWidth = %DftListBoxCharacterWidth%
         
   IfEqual, ListBoxCharacterWidth,
      ListBoxCharacterWidth := Ceil(ListBoxFontSize * 0.8 )
      
   If ListBoxOpacity is not Integer
      ListBoxOpacity = %DftListBoxOpacity%
   else IfLess, ListBoxOpacity, 0
            ListBoxOpacity = 0
         else IfGreater, ListBoxOpacity, 255
                  ListBoxOpacity = 255
                  
   If ListBoxRows is not Integer
      ListBoxRows = %DftListBoxRows%
   else IfLess, ListBoxRows, 3
            ListBoxRows = 3
         else IfGreater, ListBoxRows, 30
                  ListBoxRows = 30
         
   Return
}

ParseTerminatingCharacters()
{
   global TerminatingCharacters
   global TerminatingEndKeys
   
   Loop, Parse, TerminatingCharacters
   {
      IfEqual, OpenWord, 1
      {
         If ( A_LoopField == "{" )
         {
            TempCharacters .= A_LoopField
         } else If ( A_LoopField == "}" )
         {
            OpenWord =
            TempEndKeys .= "{" . Word . "}"
            Word =
         } else 
         {
            Word .= A_LoopField
         }
      } else if ( A_LoopField  == "{" )
      {
         OpenWord = 1
      } else
      {
         TempCharacters .= A_LoopField
      }
   }
      
      IfNotEqual, Word,
         TempCharacters .= Word
   
   TerminatingCharacters := TempCharacters
   TerminatingEndKeys := TempEndKeys
}
