;These functions and labels are related to the preferences file

MaybeWriteHelperWindowPos()
{
   global
   ;Update the Helper Window Position
   IfEqual, XYSaved, 1
   {
      IfNotEqual, XY, 
         IniWrite, %XY%, %A_ScriptDir%\Preferences.ini, HelperWindow, XY
   }
   Return
}

;------------------------------------------------------------------------

ReadPreferences()
{
   global
   Local Prefs
   Local INI
   Local IniToRead
   Local Defaults
   
   Prefs = %A_ScriptDir%\Preferences.ini
   Defaults = %A_ScriptDir%\Defaults.ini
   If FileExist(Prefs)
      IniToRead := Prefs
   else If FileExist(Defaults)
      IniToRead := Defaults
   
   DftTerminatingCharacters = {enter}{space}{esc}{tab}{Home}{End}{PgUp}{PgDn}{Up}{Down}{Left}{Right}.;`,¿?¡!'"()[]{}{}}{{}``~`%$&*-+=\/><^|@#:
   IfNotEqual, IniToRead,
   {
      ;IncludePrograms
      IniRead, IncludeProgramExecutables, %IniToRead%, IncludePrograms, IncludeProgramExecutables, %A_Space%
      IniRead, IncludeProgramTitles, %IniToRead%, IncludePrograms, IncludeProgramTitles, %A_Space%
      ;ExcludePrograms
      IniRead, ExcludeProgramExecutables, %IniToRead%, ExcludePrograms, ExcludeProgramExecutables, %A_Space%
      IniRead, ExcludeProgramTitles, %IniToRead%, ExcludePrograms, ExcludeProgramTitles, %A_Space%
      ;Settings
      IniRead, ETitle, %IniToRead%, Settings, Title, %A_Space%
      IniRead, Wlen, %IniToRead%, Settings, Length, 3
      IniRead, NumPresses, %IniToRead%, Settings, NumPresses, 1
      IniRead, LearnMode, %IniToRead%, Settings, LearnMode, On
      IniRead, LearnCount, %IniToRead%, Settings, LearnCount, 5
      LearnLength := Wlen + 2
      IniRead, LearnLength, %IniToRead%, Settings, LearnLength, %LearnLength%
      IniRead, DoNotLearnStrings, %IniToRead%, Settings, DoNotLearnStrings, %A_Space%
      IniRead, ArrowKeyMethod, %IniToRead%, Settings, ArrowKeyMethod, First
      IniRead, DisabledAutoCompleteKeys, %IniToRead%, Settings, DisabledAutoCompleteKeys, %A_Space%
      IniRead, DetectMouseClickMove, %IniToRead%, Settings, DetectMouseClickMove, On
      IniRead, NoBackSpace, %IniToRead%, Settings, NoBackSpace, On
      IniRead, AutoSpace, %IniToRead%, Settings, AutoSpace, Off
      IniRead, SuppressMatchingWord, %IniToRead%, Settings, SuppressMatchingWord, Off
      IniRead, SendMethod, %IniToRead%, Settings, SendMethod, 1
      IniRead, TerminatingCharacters, %IniToRead%, Settings, TerminatingCharacters, %DftTerminatingCharacters%
      IniRead, ForceNewWordCharacters, %IniToRead%, Settings, ForceNewWordCharacters, %A_Space%
      ;ListBox
      IniRead, ListBoxOffSet, %IniToRead%, ListBoxSettings, ListBoxOffset, 14
      IniRead, ListBoxFontFixed, %IniToRead%, ListBoxSettings, ListBoxFontFixed, Off
      IniRead, ListBoxFontOverride, %IniToRead%, ListBoxSettings, ListBoxFontOverride, %A_Space%
      IniRead, ListBoxFontSize, %IniToRead%, ListBoxSettings, ListBoxFontSize, 10      
      IniRead, ListBoxCharacterWidth, %IniToRead%, ListBoxSettings, ListBoxCharacterWidth, %A_Space%
      IniRead, ListBoxOpacity, %IniToRead%, ListBoxSettings, ListBoxOpacity, 215
      IniRead, ListBoxRows, %IniToRead%, ListBoxSettings, ListBoxRows, 10
      ;HelperWindow
      IniRead, HelperWindowProgramExecutables, %IniToRead%, HelperWindow, HelperWindowProgramExecutables, %A_Space%
      IniRead, HelperWindowProgramTitles, %IniToRead%, HelperWindow, HelperWindowProgramTitles, %A_Space%
      IniRead, XY, %IniToRead%, HelperWindow, XY, %A_Space%
   } else {
            INI= 
               ( 
[IncludePrograms]
;
;IncludeProgramExecutables is a list of executable (.exe) files that TypingAid should be enabled for.
;If one the executables matches the current program, TypingAid is enabled for that program.
; ex: IncludeProgramExecutables=notepad.exe|iexplore.exe
IncludeProgramExecutables=
;
;
;IncludeProgramTitles is a list of strings (separated by | ) to find in the title of the window you want TypingAid enabled for.
;If one of the strings is found in the title, TypingAid is enabled for that window.
; ex: IncludeProgramTitles=Notepad|Internet Explorer
IncludeProgramTitles=
;
;
[ExcludePrograms]
;
;ExcludeProgramExecutables is a list of executable (.exe) files that TypingAid should be disabled for.
;If one the executables matches the current program, TypingAid is disabled for that program.
; ex: ExcludeProgramExecutables=notepad.exe|iexplore.exe
ExcludeProgramExecutables=
;
;
;ExcludeProgramTitles is a list of strings (separated by | ) to find in the title of the window you want TypingAid disabled for.
;If one of the strings is found in the title, TypingAid is disabled for that window.
; ex: ExcludeProgramTitles=Notepad|Internet Explorer
ExcludeProgramTitles=
;
;
[Settings]
;
;Length is the minimum number of characters that need to be typed before the program shows a List of words.
;Generally, the higher this number the better the performance will be.
;For example, if you need to autocomplete "as soon as possible" in the word list, set this to 2, type 'as' and a list will appear.
Length=3
;
;
;NumPresses is the number of times the number hotkey must be tapped for the word to be selected, either 1 or 2.
NumPresses=1
;
;
;LearnMode defines whether or not the script should learn new words as you type them, either On or Off.
;Entries in the wordlist are limited to a length of 123 characters in ANSI version
;or 61 characters in Unicode version if LearnMode is On.
LearnMode=On
;
;
;LearnCount defines the number of times you have to type a word within a single session for it to be learned permanently.
LearnCount=5
;
;
;LearnLength is the minimum number of characters in a word for it to be learned. This must be at least Length+1.
LearnLength=5
;
;
;DoNotLearnStrings is a comma separated list of strings. Any words which contain any of these strings will not be learned.
;This can be used to prevent the program from learning passwords or other critical information.
;For example, if you have ord98 in DoNotLearnStrings, password987 will not be learned.
; ex: DoNotLearnStrings=ord98,fr21
DoNotLearnStrings=
;
;
;ArrowKeyMethod is the way the arrow keys are handled when a list is shown.
;Options are:
;  Off - you can only use the number keys
;  First - resets the selection cursor to the beginning whenever you type a new character
;  LastWord - keeps the selection cursor on the prior selected word if it's still in the list, else resets to the beginning
;  LastPosition - maintains the selection cursor's position
ArrowKeyMethod=First
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
DisabledAutoCompleteKeys=
;
;
;DetectMouseClickMove is used to detect when the cursor is moved with the mouse.
; On - TypingAid will not work when used with an On-Screen keyboard.
; Off - TypingAid will not detect when the cursor is moved within the same line using the mouse, and scrolling the text will clear the list.
DetectMouseClickMove=On
;
;
;NoBackSpace is used to make TypingAid not backspace any of the previously typed characters
;(ie, do not change the case of any previously typed characters).
;  On - characters you have already typed will not be changed
;  Off - characters you have already typed will be backspaced and replaced with the case of the word you have chosen.
NoBackSpace=On
;
;
;AutoSpace is used to automatically add a space to the end of an autocompleted word.
; On - Add a space to the end of the autocompleted word.
; Off - Do not add a space to the end of the autocompleted word.
AutoSpace=Off
;
;
;SuppressMatchingWord is used to suppress a word from the Word list if it matches the typed word.
;  If NoBackspace=On, then the match is case in-sensitive.
;  If NoBackspace=Off, then the match is case-sensitive.
; On - Suppress matching words from the word list.
; Off - Do not suppress matching words from the word list.
SuppressMatchingWord=Off
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
SendMethod=1
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
ForceNewWordCharacters=
;
;
[ListBoxSettings]
;
;ListBoxOffset is the number of pixels below the top of the caret (vertical blinking line) to display the list.
ListBoxOffset=14
;
;
;ListBoxFontFixed controls whether a fixed or variable character font width is used.
;(ie, in fixed width, "i" and "w" take the same number of pixels)
ListBoxFontFixed=Off
;
;
;ListBoxFontOverride is used to specify a font for the List Box to use. The default for Fixed is Courier,
;and the default for Variable is Tahoma.
ListBoxFontOverride=
;
;
;ListBoxFontSize controls the size of the font in the list.
ListBoxFontSize=10
;
;
;ListBoxCharacterWidth is the width (in pixels) of one character in the List Box.
;This number should only need to be changed if the box containing the list is not the correct width.
;Some things which may cause this to need to be changed would include:
; 1. Changing the Font DPI in Windows
; 2. Changing the ListBoxFontFixed setting
; 3. Changing the ListBoxFontSize setting
;Leave this blank to let TypingAid try to compute the width.
ListBoxCharacterWidth=
;
;
;ListBoxOpacity is how transparent (see-through) the ListBox should be. Use a value of 255 to make it so the
;ListBox is fully Opaque, or use a value of 0 to make it so the ListBox cannot be seen at all.
ListBoxOpacity=215
;
;
;ListBoxRows is the maximum number of rows to show in the ListBox. This value can range from 3 to 30.
ListBoxRows=10
;
;
[HelperWindow]
;
;HelperWindowProgramExecutables is a list of executable (.exe) files that the HelperWindow should be automatically enabled for.
;If one the executables matches the current program, the HelperWindow will pop up automatically for that program.
; ex: HelperWindowProgramExecutables=notepad.exe|iexplore.exe
HelperWindowProgramExecutables=
;
;
;HelperWindowProgramTitles is a list of strings (separated by | ) to find in the title of the window that the HelperWindow should be automatically enabled for.
;If one of the strings is found in the title, the HelperWindow will pop up automatically for that program.
; ex: HelperWindowProgramTitles=Notepad|Internet Explorer
HelperWindowProgramTitles=
;
;
; XY specifies the position the HelperWindow opens at. This will be updated automatically when the HelperWindow is
; next opened and closed
XY=200,277
               )
               FileAppendDispatch(INI, Prefs)
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
      Wlen = 3
   }
   
   if NumPresses not in 1,2
      NumPresses = 1
   
   If LearnMode not in On,Off
      LearnMode = On
   
   If LearnCount is not Integer
      LearnCount = 5
      
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
      ArrowKeyMethod = First       
   }
   
   If DetectMouseClickMove not in On,Off
      DetectMouseClickMove = On
   
   If NoBackSpace not in On,Off
      NoBackSpace = On
      
   If AutoSpace not in On,Off
      AutoSpace = Off
   
   if SendMethod not in 1,2,3,1C,2C,3C,4C
      SendMethod = 1
   
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
      ListBoxOffset = 14
      
   if ListBoxFontFixed not in On,Off
      ListBoxFontFixed = Off
   
   If ListBoxFontSize is not Integer
      ListBoxFontSize = 8
   else {
         IfLess, ListBoxFontSize, 2
            ListBoxFontSize = 2
      }
   
   if ListBoxCharacterWidth is not Integer
      ListBoxCharacterWidth = 
         
   IfEqual, ListBoxCharacterWidth,
      ListBoxCharacterWidth := Ceil(ListBoxFontSize * 0.8 )
      
   If ListBoxOpacity is not Integer
      ListBoxOpacity = 215
   else IfLess, ListBoxOpacity, 0
            ListBoxOpacity = 0
         else IfGreater, ListBoxOpacity, 255
                  ListBoxOpacity = 255
                  
   If ListBoxRows is not Integer
      ListBoxRows = 10
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
