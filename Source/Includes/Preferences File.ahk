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

ReadPreferences(RestoreDefaults = false,RestorePreferences = false)
{
   global DftIncludeProgramExecutables
   global DftIncludeProgramTitles
   global DftExcludeProgramExecutables
   global DftExcludeProgramTitles
   global DftLength
   global DftNumPresses
   global DftLearnMode
   global DftLearnCount
   global DftLearnLength
   global DftDoNotLearnStrings
   global DftArrowKeyMethod
   global DftDisabledAutoCompleteKeys
   global DftDetectMouseClickMove
   global DftNoBackSpace
   global DftAutoSpace
   global DftSuppressMatchingWord
   global DftSendMethod
   global DftTerminatingCharacters
   global DftForceNewWordCharacters
   global DftListBoxOffSet
   global DftListBoxFontFixed
   global DftListBoxFontOverride
   global DftListBoxFontSize
   global DftListBoxCharacterWidth
   global DftListBoxOpacity
   global DftListBoxRows
   global DftHelperWindowProgramExecutables
   global DftHelperWindowProgramTitles
   
   global IncludeProgramExecutables
   global IncludeProgramTitles
   global ExcludeProgramExecutables
   global ExcludeProgramTitles
   global Length
   global NumPresses
   global LearnMode
   global LearnCount
   global LearnLength
   global DoNotLearnStrings
   global ArrowKeyMethod
   global DisabledAutoCompleteKeys
   global DetectMouseClickMove
   global NoBackSpace
   global AutoSpace
   global SuppressMatchingWord
   global SendMethod
   global TerminatingCharacters
   global ForceNewWordCharacters
   global ListBoxOffset
   global ListBoxFontFixed
   global ListBoxFontOverride
   global ListBoxFontSize
   global ListBoxCharacterWidth
   global ListBoxOpacity
   global ListBoxRows
   global HelperWindowProgramExecutables
   global HelperWindowProgramTitles
   
   ;PrefsFile is global so it works in Settings.ahk
   global PrefsFile
   global PrefsSections
   
   PrefsFile = %A_ScriptDir%\Preferences.ini
   Defaults = %A_ScriptDir%\Defaults.ini
   LastState = %A_ScriptDir%\LastState.ini
   
   MaybeFixFileEncoding(PrefsFile,"UTF-16")
   MaybeFixFileEncoding(Defaults,"UTF-16")
   MaybeFixFileEncoding(LastState,"UTF-16")
   
   DftTerminatingCharacters = {enter}{space}{esc}{tab}{Home}{End}{PgUp}{PgDn}{Up}{Down}{Left}{Right}.;`,¿?¡!'"()[]{}{}}{{}``~`%$&*-+=\/><^|@#:
   
   
   ; There was a bug in TypingAid 2.19.7 that broke terminating characters for new preference files, this code repairs it
   BrokenTerminatingCharacters = {enter}{space}{esc}{tab}{Home}{End}{PgUp}{PgDn}{Up}{Down}{Left}{Right}.;
   IfExist, %PrefsFile%
   {
      IniRead, MaybeFixTerminatingCharacters, %PrefsFile%, Settings, TerminatingCharacters, %A_Space%
      IF (MaybeFixTerminatingCharacters == BrokenTerminatingCharacters)
      {
         IniWrite, %DftTerminatingCharacters%, %PrefsFile%, Settings, TerminatingCharacters
      }
   }      
   
   SpaceVar := "%A_Space%"
   
   IniValues =
   (
      DftIncludeProgramExecutables,IncludeProgramExecutables,IncludePrograms,%SpaceVar%
      DftIncludeProgramTitles,IncludeProgramTitles,IncludePrograms,%SpaceVar%
      DftExcludeProgramExecutables,ExcludeProgramExecutables,ExcludePrograms,%SpaceVar%
      DftExcludeProgramTitles,ExcludeProgramTitles,ExcludePrograms,%SpaceVar%
      ,Title,Settings,%SpaceVar%
      DftLength,Length,Settings,3
      DftNumPresses,NumPresses,Settings,1
      DftLearnMode,LearnMode,Settings,On
      DftLearnCount,LearnCount,Settings,5
      DftLearnLength,LearnLength,Settings,%SpaceVar%
      DftDoNotLearnStrings,DoNotLearnStrings,Settings,%SpaceVar%
      DftArrowKeyMethod,ArrowKeyMethod,Settings,First
      DftDisabledAutoCompleteKeys,DisabledAutoCompleteKeys,Settings,%SpaceVar%
      DftDetectMouseClickMove,DetectMouseClickMove,Settings,On
      DftNoBackSpace,NoBackSpace,Settings,On
      DftAutoSpace,AutoSpace,Settings,Off
      DftSuppressMatchingWord,SuppressMatchingWord,Settings,Off
      DftSendMethod,SendMethod,Settings,1
      DftTerminatingCharacters,TerminatingCharacters,Settings,`%DftTerminatingCharacters`%
      DftForceNewWordCharacters,ForceNewWordCharacters,Settings,%SpaceVar%
      DftListBoxOffSet,ListBoxOffset,ListBoxSettings,14
      DftListBoxFontFixed,ListBoxFontFixed,ListBoxSettings,Off
      DftListBoxFontOverride,ListBoxFontOverride,ListBoxSettings,%SpaceVar%
      DftListBoxFontSize,ListBoxFontSize,ListBoxSettings,10      
      DftListBoxCharacterWidth,ListBoxCharacterWidth,ListBoxSettings,%SpaceVar%
      DftListBoxOpacity,ListBoxOpacity,ListBoxSettings,215
      DftListBoxRows,ListBoxRows,ListBoxSettings,10
      DftHelperWindowProgramExecutables,HelperWindowProgramExecutables,HelperWindow,%SpaceVar%
      DftHelperWindowProgramTitles,HelperWindowProgramTitles,HelperWindow,%SpaceVar%
      ,XY,HelperWindow,%SpaceVar%
   )
   
   PrefsSections := Object()
    
   Loop, Parse, IniValues, `n, `r%A_Space%
   {
      StringSplit, CurrentIniValues, A_LoopField, `,
      DftVariable := CurrentIniValues1
      NormalVariable := CurrentIniValues2
      IniSection := CurrentIniValues3
      DftValue := CurrentIniValues4
      
      PrefsSections[NormalVariable] := IniSection
      
      IF (DftValue == "%DftTerminatingCharacters%")
      {
         DftValue := DftTerminatingCharacters
      }

      IF ( DftValue = "%A_Space%" )
         DftValue := A_Space
      
      IF !(RestoreDefaults)
         IniRead, %NormalVariable%, %PrefsFile%, %IniSection%, %NormalVariable%, %A_Space%
      
      IF DftVariable
      { 
         IniRead, %DftVariable%, %Defaults%, %IniSection%, %NormalVariable%, %DftValue%
         IfEqual, %NormalVariable%,
            %NormalVariable% := %DftVariable%
      }
   }
   
   ValidatePreferences()
   ParseTerminatingCharacters()
   
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
   
   IF ( RestoreDefaults || RestorePreferences )
      Return
   
   IfExist, %LastState%
   {    
      IniRead, XY, %LastState%, HelperWindow, XY, %A_Space%
   }
   
   ConstructHelpStrings()
         
   Return
}

ValidatePreferences()
{
   
   global
   
   if Length is not integer
   {
      Length := DftLength
   }
   
   if (Length < 1) {
      Length = 1
   }
   
   if NumPresses not in 1,2
      NumPresses := DftNumPresses
   
   If LearnMode not in On,Off
      LearnMode := DftLearnMode
   
   If LearnCount is not Integer
   {
      LearnCount := DftLearnCount
   }
   
   if (LearnCount < 1)
   {
      LearnCount = 1
   }
   
   if LearnLength is not Integer
   {
      LearnLength := Length + 2
   } else If ( LearnLength < ( Length + 1 ) )
   {
      LearnLength := Length + 1
   }
   
   if DisabledAutoCompleteKeys contains N
      NumKeyMethod = Off
   
   IfNotEqual, ArrowKeyMethod, Off
      If DisabledAutoCompleteKeys contains E
         If DisabledAutoCompleteKeys contains S
            If DisabledAutoCompleteKeys contains T
               If DisabledAutoCompleteKeys contains R
                  If DisabledAutoCompleteKeys contains U
                     ArrowKeyMethod = Off
   
   If ArrowKeyMethod not in First,Off,LastWord,LastPosition
   {
      ArrowKeyMethod := DftArrowKeyMethod
   }
   
   If DetectMouseClickMove not in On,Off
      DetectMouseClickMove := DftDetectMouseClickMove
   
   If NoBackSpace not in On,Off
      NoBackSpace := DftNoBackSpace
      
   If AutoSpace not in On,Off
      AutoSpace := DftAutoSpace
   
   if SuppressMatchingWord not in On,Off
      SuppressMatchingWord := DftSuppressMatchingWord
   
   if SendMethod not in 1,2,3,1C,2C,3C,4C
      SendMethod := DftSendMethod
   
   ;SendPlay does not work when not running as Administrator, switch to SendInput
   If not A_IsAdmin
   {
      IfEqual, SendMethod, 1
      {
         SendMethod = 2
      } else IfEqual, SendMethod, 1C
            {
               SendMethod = 2C   
            }
   }
   
   IfEqual, TerminatingCharacters,
      TerminatingCharacters := DftTerminatingCharacters
   
   if ListBoxOffset is not Integer
      ListBoxOffset := DftListBoxOffSet
      
   if ListBoxFontFixed not in On,Off
      ListBoxFontFixed := DftListBoxFontFixed
   
   If ListBoxFontSize is not Integer
   {
      ListBoxFontSize := DftListBoxFontSize
   }
   else IfLess, ListBoxFontSize, 2
   {
      ListBoxFontSize = 2
   }
   
   if ListBoxCharacterWidth is not Integer
      ListBoxCharacterWidth := DftListBoxCharacterWidth
         
   IfEqual, ListBoxCharacterWidth,
      ListBoxCharacterWidth := Ceil(ListBoxFontSize * 0.8 )
      
   If ListBoxOpacity is not Integer
      ListBoxOpacity := DftListBoxOpacity
   
   IfLess, ListBoxOpacity, 0
      ListBoxOpacity = 0
   else IfGreater, ListBoxOpacity, 255
      ListBoxOpacity = 255
                  
   If ListBoxRows is not Integer
      ListBoxRows := DftListBoxRows
   
   IfLess, ListBoxRows, 3
      ListBoxRows = 3
   else IfGreater, ListBoxRows, 30
      ListBoxRows = 30
            
   Return
}

ParseTerminatingCharacters()
{
   global TerminatingCharacters
   global TerminatingCharactersParsed
   global TerminatingEndKeys
   
   Loop, Parse, TerminatingCharacters
   {
      IfEqual, OpenWord, 1
      {
         If ( A_LoopField == "}" )
         {
            OpenWord =
            IF !(Word)
               TempCharacters .= "{}"
            else If ( Word = "{" || Word = "}")
               TempCharacters .= Word
            else
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
   
   TerminatingCharactersParsed := TempCharacters
   TerminatingEndKeys := TempEndKeys
}

SavePreferences(ByRef PrefsToSave)
{
   global
   local index
   local element
   
   ValidatePreferences()
      
   for index, element in PrefsToSave
   {
   
      If (%element% == Dft%element%)
      {
         IniDelete, %PrefsFile%,% PrefsSections[element], %element%
      } else {
         IniWrite,% %element%, %PrefsFile%,% PrefsSections[element], %element%
      }
   }
   
   ;do stuff
   Return
}

ConstructHelpStrings()
{
   global
   
hIncludeProgramExecutables=
(
;IncludeProgramExecutables is a list of executable (.exe) files that TypingAid should be enabled for.
;If one the executables matches the current program, TypingAid is enabled for that program.
)

hIncludeProgramTitles=
(
;IncludeProgramTitles is a list of strings (separated by | ) to find in the title of the window you want TypingAid enabled for.
;If one of the strings is found in the title, TypingAid is enabled for that window.
)

hExcludeProgramExecutables=
(
;ExcludeProgramExecutables is a list of executable (.exe) files that TypingAid should be disabled for.
;If one the executables matches the current program, TypingAid is disabled for that program.
)

hExcludeProgramTitles=
(
;ExcludeProgramTitles is a list of strings (separated by | ) to find in the title of the window you want TypingAid disabled for.
;If one of the strings is found in the title, TypingAid is disabled for that window.
)

hLength=
(
;Length is the minimum number of characters that need to be typed before the program shows a List of words.
;Generally, the higher this number the better the performance will be.
;For example, if you need to autocomplete "as soon as possible" in the word list, set this to 2, type 'as' and a list will appear.
)

hNumPresses=
(
;NumPresses is the number of times the number hotkey must be tapped for the word to be selected, either 1 or 2.
)

hLearnMode=
(
;LearnMode defines whether or not the script should learn new words as you type them, either On or Off.
)

hLearnCount=
(
;LearnCount defines the number of times you have to type a word within a single session for it to be learned permanently.
)

hLearnLength=
(
;LearnLength is the minimum number of characters in a word for it to be learned. This must be at least Length+1.
)

hDoNotLearnStrings=
(
;DoNotLearnStrings is a comma separated list of strings. Any words which contain any of these strings will not be learned.
;This can be used to prevent the program from learning passwords or other critical information.
;For example, if you have ord98 in DoNotLearnStrings, password987 will not be learned.
)

hArrowKeyMethod=
(
;ArrowKeyMethod is the way the arrow keys are handled when a list is shown.
;Options are:
;  Off - you can only use the number keys
;  First - resets the selection cursor to the beginning whenever you type a new character
;  LastWord - keeps the selection cursor on the prior selected word if it's still in the list, else resets to the beginning
;  LastPosition - maintains the selection cursor's position
)

hDisabledAutoCompleteKeys=
(
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
)

hDetectMouseClickMove=
(
;DetectMouseClickMove is used to detect when the cursor is moved with the mouse.
; On - TypingAid will not work when used with an On-Screen keyboard.
; Off - TypingAid will not detect when the cursor is moved within the same line using the mouse, and scrolling the text will clear the list.
)

hNoBackSpace=
(
;NoBackSpace is used to make TypingAid not backspace any of the previously typed characters
;(ie, do not change the case of any previously typed characters).
;  On - characters you have already typed will not be changed
;  Off - characters you have already typed will be backspaced and replaced with the case of the word you have chosen.
)

hAutoSpace=
(
;AutoSpace is used to automatically add a space to the end of an autocompleted word.
; On - Add a space to the end of the autocompleted word.
; Off - Do not add a space to the end of the autocompleted word.
)

hSuppressMatchingWord=
(
;SuppressMatchingWord is used to suppress a word from the Word list if it matches the typed word.
;  If NoBackspace=On, then the match is case in-sensitive.
;  If NoBackspace=Off, then the match is case-sensitive.
; On - Suppress matching words from the word list.
; Off - Do not suppress matching words from the word list.
)

hSendMethod=
(
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
)

hTerminatingCharacters=
(
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
)

hForceNewWordCharacters=
(
;ForceNewWordCharacters is a comma separated list of characters which forces the program to start a new word whenever
;one of those characters is typed. Any words which begin with one of these characters will never be learned (even
;if learning is enabled). If you were typing a word when you hit one of these characters that word will be learned
;if learning is enabled.
;Change this only if you know what you are doing, it is probably only useful for certain programming languages.
; ex: ForceNewWordCharacters=@,:,#
)

hListBoxOffset=
(
;ListBoxOffset is the number of pixels below the top of the caret (vertical blinking line) to display the list.
)

hListBoxFontFixed=
(
;ListBoxFontFixed controls whether a fixed or variable character font width is used.
;(ie, in fixed width, "i" and "w" take the same number of pixels)
)

hListBoxFontOverride=
(
;ListBoxFontOverride is used to specify a font for the List Box to use. The default for Fixed is Courier,
;and the default for Variable is Tahoma.
)

hListBoxFontSize=
(
;ListBoxFontSize controls the size of the font in the list.
)

hListBoxCharacterWidth=
(
;ListBoxCharacterWidth is the width (in pixels) of one character in the List Box.
;This number should only need to be changed if the box containing the list is not the correct width.
;Some things which may cause this to need to be changed would include:
; 1. Changing the Font DPI in Windows
; 2. Changing the ListBoxFontFixed setting
; 3. Changing the ListBoxFontSize setting
;Leave this blank to let TypingAid try to compute the width.
)

hListBoxOpacity=
(
;ListBoxOpacity is how transparent (see-through) the ListBox should be. Use a value of 255 to make it so the
;ListBox is fully Opaque, or use a value of 0 to make it so the ListBox cannot be seen at all.
)

hListBoxRows=
(
;ListBoxRows is the maximum number of rows to show in the ListBox. This value can range from 3 to 30.
)

hHelperWindowProgramExecutables=
(
;HelperWindowProgramExecutables is a list of executable (.exe) files that the HelperWindow should be automatically enabled for.
;If one the executables matches the current program, the HelperWindow will pop up automatically for that program.
)

hHelperWindowProgramTitles=
(
;HelperWindowProgramTitles is a list of strings (separated by | ) to find in the title of the window that the HelperWindow should be automatically enabled for.
;If one of the strings is found in the title, the HelperWindow will pop up automatically for that program.
)

hFullHelpString =
(
%hIncludeProgramExecutables% `r`n`r`n %hIncludeProgramTitles% `r`n`r`n %hExcludeProgramExecutables% `r`n`r`n %hExcludeProgramTitles%

%hLength% `r`n`r`n %hNumPresses% `r`n`r`n %hLearnMode% `r`n`r`n %hLearnCount% `r`n`r`n %hLearnLength% `r`n`r`n %hDoNotLearnStrings%

%hArrowKeyMethod% `r`n`r`n %hDisabledAutoCompleteKeys% `r`n`r`n %hDetectMouseClickMove% `r`n`r`n %hNoBackSpace% `r`n`r`n %hAutoSpace%

%hSuppressMatchingWord% `r`n`r`n %hSendMethod% `r`n`r`n %hTerminatingCharacters% `r`n`r`n %hForceNewWordCharacters% `r`n`r`n %hListBoxOffset%

%hListBoxFontFixed% `r`n`r`n %hListBoxFontOverride% `r`n`r`n %hListBoxFontSize% `r`n`r`n %hListBoxCharacterWidth% `r`n`r`n %hListBoxOpacity%

%hListBoxRows% `r`n`r`n %hHelperWindowProgramExecutables% `r`n`r`n %hHelperWindowProgramTitles%
)

}
