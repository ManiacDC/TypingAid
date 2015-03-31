;These functions and labels are related to the preferences file

MaybeWriteHelperWindowPos()
{
   global g_XY
   global g_XYSaved
   ;Update the Helper Window Position
   IfEqual, g_XYSaved, 1
   {
      IfNotEqual, g_XY, 
         IniWrite, %g_XY%, %A_ScriptDir%\LastState.ini, HelperWindow, XY
   }
   Return
}

;------------------------------------------------------------------------

ReadPreferences(RestoreDefaults = false,RestorePreferences = false)
{
   global dft_IncludeProgramExecutables
   global dft_IncludeProgramTitles
   global dft_ExcludeProgramExecutables
   global dft_ExcludeProgramTitles
   global dft_Length
   global dft_NumPresses
   global dft_LearnMode
   global dft_LearnCount
   global dft_LearnLength
   global dft_DoNotLearnStrings
   global dft_ArrowKeyMethod
   global dft_DisabledAutoCompleteKeys
   global dft_DetectMouseClickMove
   global dft_NoBackSpace
   global dft_AutoSpace
   global dft_SuppressMatchingWord
   global dft_SendMethod
   global dft_TerminatingCharacters
   global dft_ForceNewWordCharacters
   global dft_ListBoxOffSet
   global dft_ListBoxFontFixed
   global dft_ListBoxFontOverride
   global dft_ListBoxFontSize
   global dft_ListBoxCharacterWidth
   global dft_ListBoxOpacity
   global dft_ListBoxRows
   global dft_HelperWindowProgramExecutables
   global dft_HelperWindowProgramTitles
   
   global prefs_IncludeProgramExecutables
   global prefs_IncludeProgramTitles
   global prefs_ExcludeProgramExecutables
   global prefs_ExcludeProgramTitles
   global prefs_Length
   global prefs_NumPresses
   global prefs_LearnMode
   global prefs_LearnCount
   global prefs_LearnLength
   global prefs_DoNotLearnStrings
   global prefs_ArrowKeyMethod
   global prefs_DisabledAutoCompleteKeys
   global prefs_DetectMouseClickMove
   global prefs_NoBackSpace
   global prefs_AutoSpace
   global prefs_SuppressMatchingWord
   global prefs_SendMethod
   global prefs_TerminatingCharacters
   global prefs_ForceNewWordCharacters
   global prefs_ListBoxOffset
   global prefs_ListBoxFontFixed
   global prefs_ListBoxFontOverride
   global prefs_ListBoxFontSize
   global prefs_ListBoxCharacterWidth
   global prefs_ListBoxOpacity
   global prefs_ListBoxRows
   global prefs_HelperWindowProgramExecutables
   global prefs_HelperWindowProgramTitles
   
   ;g_PrefsFile is global so it works in Settings.ahk
   global g_PrefsFile
   global g_PrefsSections
   global g_XY
   
   g_PrefsFile = %A_ScriptDir%\Preferences.ini
   Defaults = %A_ScriptDir%\Defaults.ini
   LastState = %A_ScriptDir%\LastState.ini
   
   MaybeFixFileEncoding(g_PrefsFile,"UTF-16")
   MaybeFixFileEncoding(Defaults,"UTF-16")
   MaybeFixFileEncoding(LastState,"UTF-16")
   
   dft_TerminatingCharacters = {enter}{space}{esc}{tab}{Home}{End}{PgUp}{PgDn}{Up}{Down}{Left}{Right}.;`,¿?¡!'"()[]{}{}}{{}``~`%$&*-+=\/><^|@#:
   
   
   ; There was a bug in TypingAid 2.19.7 that broke terminating characters for new preference files, this code repairs it
   BrokenTerminatingCharacters = {enter}{space}{esc}{tab}{Home}{End}{PgUp}{PgDn}{Up}{Down}{Left}{Right}.;
   IfExist, %g_PrefsFile%
   {
      IniRead, MaybeFixTerminatingCharacters, %g_PrefsFile%, Settings, TerminatingCharacters, %A_Space%
      IF (MaybeFixTerminatingCharacters == BrokenTerminatingCharacters)
      {
         IniWrite, %dft_TerminatingCharacters%, %g_PrefsFile%, Settings, TerminatingCharacters
      }
   }      
   
   SpaceVar := "%A_Space%"
   
   IniValues =
   (
      dft_IncludeProgramExecutables,prefs_IncludeProgramExecutables,IncludePrograms,%SpaceVar%
      dft_IncludeProgramTitles,prefs_IncludeProgramTitles,IncludePrograms,%SpaceVar%
      dft_ExcludeProgramExecutables,prefs_ExcludeProgramExecutables,ExcludePrograms,%SpaceVar%
      dft_ExcludeProgramTitles,prefs_ExcludeProgramTitles,ExcludePrograms,%SpaceVar%
      ,Title,Settings,%SpaceVar%
      dft_Length,prefs_Length,Settings,3
      dft_NumPresses,prefs_NumPresses,Settings,1
      dft_LearnMode,prefs_LearnMode,Settings,On
      dft_LearnCount,prefs_LearnCount,Settings,5
      dft_LearnLength,prefs_LearnLength,Settings,%SpaceVar%
      dft_DoNotLearnStrings,prefs_DoNotLearnStrings,Settings,%SpaceVar%
      dft_ArrowKeyMethod,prefs_ArrowKeyMethod,Settings,First
      dft_DisabledAutoCompleteKeys,prefs_DisabledAutoCompleteKeys,Settings,%SpaceVar%
      dft_DetectMouseClickMove,prefs_DetectMouseClickMove,Settings,On
      dft_NoBackSpace,prefs_NoBackSpace,Settings,On
      dft_AutoSpace,prefs_AutoSpace,Settings,Off
      dft_SuppressMatchingWord,prefs_SuppressMatchingWord,Settings,Off
      dft_SendMethod,prefs_SendMethod,Settings,1
      dft_TerminatingCharacters,prefs_TerminatingCharacters,Settings,`%dft_TerminatingCharacters`%
      dft_ForceNewWordCharacters,prefs_ForceNewWordCharacters,Settings,%SpaceVar%
      dft_ListBoxOffSet,prefs_ListBoxOffset,ListBoxSettings,14
      dft_ListBoxFontFixed,prefs_ListBoxFontFixed,ListBoxSettings,Off
      dft_ListBoxFontOverride,prefs_ListBoxFontOverride,ListBoxSettings,%SpaceVar%
      dft_ListBoxFontSize,prefs_ListBoxFontSize,ListBoxSettings,10      
      dft_ListBoxCharacterWidth,prefs_ListBoxCharacterWidth,ListBoxSettings,%SpaceVar%
      dft_ListBoxOpacity,prefs_ListBoxOpacity,ListBoxSettings,215
      dft_ListBoxRows,prefs_ListBoxRows,ListBoxSettings,10
      dft_HelperWindowProgramExecutables,prefs_HelperWindowProgramExecutables,HelperWindow,%SpaceVar%
      dft_HelperWindowProgramTitles,prefs_HelperWindowProgramTitles,HelperWindow,%SpaceVar%
      ,XY,HelperWindow,%SpaceVar%
   )
   
   g_PrefsSections := Object()
    
   Loop, Parse, IniValues, `n, `r%A_Space%
   {
      StringSplit, CurrentIniValues, A_LoopField, `,
      DftVariable := CurrentIniValues1
      NormalVariable := CurrentIniValues2
      IniSection := CurrentIniValues3
      DftValue := CurrentIniValues4
      ; maybe strip "prefs_" prefix
      if (substr(NormalVariable, 1, 6) == "prefs_")
      {
         StringTrimLeft, KeyName, NormalVariable, 6
      } else {
         KeyName := NormalVariable
      }
      
      g_PrefsSections[KeyName] := IniSection
      
      ; this is done because certain characters can break the parsing (comma, for example)
      IF (DftValue == "%dft_TerminatingCharacters%")
      {
         DftValue := dft_TerminatingCharacters
      }

      IF ( DftValue = "%A_Space%" )
         DftValue := A_Space
      
      IF !(RestoreDefaults)
         IniRead, %NormalVariable%, %g_PrefsFile%, %IniSection%, %KeyName%, %A_Space%
      
      IF DftVariable
      { 
         IniRead, %DftVariable%, %Defaults%, %IniSection%, %KeyName%, %DftValue%
         IF (RestoreDefaults || %NormalVariable% == "")
         {
            %NormalVariable% := %DftVariable%
         }
      }
   }
   
   ValidatePreferences()
   ParseTerminatingCharacters()
   
   ; Legacy support for old Preferences File
   IfNotEqual, Etitle,
   {
      IfEqual, prefs_IncludeProgramTitles,
      {
         prefs_IncludeProgramTitles = %Etitle%
      } else {
               prefs_IncludeProgramTitles .= "|" . Etitle
            }
      
      Etitle=      
   }
   
   g_XY := XY
   
   IF ( RestoreDefaults || RestorePreferences )
      Return
   
   IfExist, %LastState%
   {    
      IniRead, g_XY, %LastState%, HelperWindow, XY, %A_Space%
   }
   
   ConstructHelpStrings()
         
   Return
}

ValidatePreferences()
{
   global g_ListBoxCharacterWidthComputed, g_NumKeyMethod
   global prefs_ArrowKeyMethod, prefs_DisabledAutoCompleteKeys
   global prefs_AutoSpace, prefs_DetectMouseClickMove, prefs_LearnCount, prefs_LearnLength, prefs_LearnMode, prefs_Length
   global dft_AutoSpace, dft_DetectMouseClickMove, dft_LearnCount, dft_LearnLength, dft_LearnMode, dft_Length
   global prefs_ListBoxCharacterWidth, prefs_ListBoxFontFixed, prefs_ListBoxFontSize, prefs_ListBoxOffset, prefs_ListBoxOpacity, prefs_ListBoxRows
   global dft_ListBoxCharacterWidth, dft_ListBoxFontFixed, dft_ListBoxFontSize, dft_ListBoxOffset, dft_ListBoxOpacity, dft_ListBoxRows
   global prefs_NoBackSpace, prefs_NumPresses, prefs_SendMethod, prefs_SuppressMatchingWord, prefs_TerminatingCharacters
   global dft_NoBackSpace, dft_NumPresses, dft_SendMethod, dft_SuppressMatchingWord, dft_TerminatingCharacters
   
   if prefs_Length is not integer
   {
      prefs_Length := dft_Length
   }
   
   if (prefs_Length < 1) {
      prefs_Length = 1
   }
   
   if prefs_NumPresses not in 1,2
      prefs_NumPresses := dft_NumPresses
   
   If prefs_LearnMode not in On,Off
      prefs_LearnMode := dft_LearnMode
   
   If prefs_LearnCount is not Integer
   {
      prefs_LearnCount := dft_LearnCount
   }
   
   if (prefs_LearnCount < 1)
   {
      prefs_LearnCount = 1
   }
   
   if dft_LearnLength is not Integer
   {
      dft_LearnLength := prefs_Length + 2
   }
   
   if prefs_LearnLength is not Integer
   {
      prefs_LearnLength := dft_LearnLength
   } else If ( prefs_LearnLength < ( prefs_Length + 1 ) )
   {
      prefs_LearnLength := prefs_Length + 1
   }
   
   if prefs_DisabledAutoCompleteKeys contains N
   {
      g_NumKeyMethod = Off
   } else {
      g_NumKeyMethod = On
   }
   
   IfNotEqual, prefs_ArrowKeyMethod, Off
      If prefs_DisabledAutoCompleteKeys contains E
         If prefs_DisabledAutoCompleteKeys contains S
            If prefs_DisabledAutoCompleteKeys contains T
               If prefs_DisabledAutoCompleteKeys contains R
                  If prefs_DisabledAutoCompleteKeys contains U
                     prefs_ArrowKeyMethod = Off
   
   If prefs_ArrowKeyMethod not in First,Off,LastWord,LastPosition
   {
      prefs_ArrowKeyMethod := dft_ArrowKeyMethod
   }
   
   If prefs_DetectMouseClickMove not in On,Off
      prefs_DetectMouseClickMove := dft_DetectMouseClickMove
   
   If prefs_NoBackSpace not in On,Off
      prefs_NoBackSpace := dft_NoBackSpace
      
   If prefs_AutoSpace not in On,Off
      prefs_AutoSpace := dft_AutoSpace
   
   if prefs_SuppressMatchingWord not in On,Off
      prefs_SuppressMatchingWord := dft_SuppressMatchingWord
   
   if prefs_SendMethod not in 1,2,3,1C,2C,3C,4C
      prefs_SendMethod := dft_SendMethod
   
   ;SendPlay does not work when not running as Administrator, switch to SendInput
   If not A_IsAdmin
   {
      IfEqual, prefs_SendMethod, 1
      {
         prefs_SendMethod = 2
      } else IfEqual, prefs_SendMethod, 1C
            {
               prefs_SendMethod = 2C   
            }
   }
   
   IfEqual, prefs_TerminatingCharacters,
      prefs_TerminatingCharacters := dft_TerminatingCharacters
   
   if prefs_ListBoxOffset is not Integer
      prefs_ListBoxOffset := dft_ListBoxOffSet
      
   if prefs_ListBoxFontFixed not in On,Off
      prefs_ListBoxFontFixed := dft_ListBoxFontFixed
   
   If prefs_ListBoxFontSize is not Integer
   {
      prefs_ListBoxFontSize := dft_ListBoxFontSize
   }
   else IfLess, prefs_ListBoxFontSize, 2
   {
      prefs_ListBoxFontSize = 2
   }
   
   if dft_ListBoxCharacterWidth is not Integer
   {
      dft_ListBoxCharacterWidth =
   }
   
   if prefs_ListBoxCharacterWidth is not Integer
   {
      prefs_ListBoxCharacterWidth := dft_ListBoxCharacterWidth
   }
   
   if prefs_ListBoxCharacterWidth is Integer
   {
      g_ListBoxCharacterWidthComputed := prefs_ListBoxCharacterWidth
   } else {
      g_ListBoxCharacterWidthComputed := Ceil(prefs_ListBoxFontSize * 0.8)
   }
      
   If prefs_ListBoxOpacity is not Integer
      prefs_ListBoxOpacity := dft_ListBoxOpacity
   
   IfLess, prefs_ListBoxOpacity, 0
      prefs_ListBoxOpacity = 0
   else IfGreater, prefs_ListBoxOpacity, 255
      prefs_ListBoxOpacity = 255
                  
   If prefs_ListBoxRows is not Integer
      prefs_ListBoxRows := dft_ListBoxRows
   
   IfLess, prefs_ListBoxRows, 3
      prefs_ListBoxRows = 3
   else IfGreater, prefs_ListBoxRows, 30
      prefs_ListBoxRows = 30
            
   Return
}

ParseTerminatingCharacters()
{
   global prefs_TerminatingCharacters
   global g_TerminatingCharactersParsed
   global g_TerminatingEndKeys
   
   Loop, Parse, prefs_TerminatingCharacters
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
   
   g_TerminatingCharactersParsed := TempCharacters
   g_TerminatingEndKeys := TempEndKeys
}

SavePreferences(PrefsToSave)
{
   global
   local index
   local element
   local KeyName
   
   ValidatePreferences()
      
   for index, element in PrefsToSave
   {
      if (substr(element, 1, 6) == "prefs_")
      {
         StringTrimLeft, KeyName, element, 6
      } else {
         KeyName := element
      }
   
      If (%element% == dft_%KeyName%)
      {
         IniDelete, %g_PrefsFile%,% g_PrefsSections[KeyName], %KeyName%
      } else {
         IniWrite,% %element%, %g_PrefsFile%,% g_PrefsSections[KeyName], %KeyName%
      }
   }
   
   Return
}

ConstructHelpStrings()
{
   global
   
helpinfo_IncludeProgramExecutables=
(
;IncludeProgramExecutables is a list of executable (.exe) files that %g_ScriptTitle% should be enabled for.
;If one the executables matches the current program, %g_ScriptTitle% is enabled for that program.
)

helpinfo_IncludeProgramTitles=
(
;IncludeProgramTitles is a list of strings (separated by | ) to find in the title of the window you want %g_ScriptTitle% enabled for.
;If one of the strings is found in the title, %g_ScriptTitle% is enabled for that window.
)

helpinfo_ExcludeProgramExecutables=
(
;ExcludeProgramExecutables is a list of executable (.exe) files that %g_ScriptTitle% should be disabled for.
;If one the executables matches the current program, %g_ScriptTitle% is disabled for that program.
)

helpinfo_ExcludeProgramTitles=
(
;ExcludeProgramTitles is a list of strings (separated by | ) to find in the title of the window you want %g_ScriptTitle% disabled for.
;If one of the strings is found in the title, %g_ScriptTitle% is disabled for that window.
)

helpinfo_Length=
(
;Length is the minimum number of characters that need to be typed before the program shows a List of words.
;Generally, the higher this number the better the performance will be.
;For example, if you need to autocomplete "as soon as possible" in the word list, set this to 2, type 'as' and a list will appear.
)

helpinfo_NumPresses=
(
;NumPresses is the number of times the number hotkey must be tapped for the word to be selected, either 1 or 2.
)

helpinfo_LearnMode=
(
;LearnMode defines whether or not the script should learn new words as you type them, either On or Off.
)

helpinfo_LearnCount=
(
;LearnCount defines the number of times you have to type a word within a single session for it to be learned permanently.
)

helpinfo_LearnLength=
(
;LearnLength is the minimum number of characters in a word for it to be learned. This must be at least Length+1.
)

helpinfo_DoNotLearnStrings=
(
;DoNotLearnStrings is a comma separated list of strings. Any words which contain any of these strings will not be learned.
;This can be used to prevent the program from learning passwords or other critical information.
;For example, if you have ord98 in DoNotLearnStrings, password987 will not be learned.
)

helpinfo_ArrowKeyMethod=
(
;ArrowKeyMethod is the way the arrow keys are handled when a list is shown.
;Options are:
;  Off - you can only use the number keys
;  First - resets the selection cursor to the beginning whenever you type a new character
;  LastWord - keeps the selection cursor on the prior selected word if it's still in the list, else resets to the beginning
;  LastPosition - maintains the selection cursor's position
)

helpinfo_DisabledAutoCompleteKeys=
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

helpinfo_DetectMouseClickMove=
(
;DetectMouseClickMove is used to detect when the cursor is moved with the mouse.
; On - %g_ScriptTitle% will not work when used with an On-Screen keyboard.
; Off - %g_ScriptTitle% will not detect when the cursor is moved within the same line using the mouse, and scrolling the text will clear the list.
)

helpinfo_NoBackSpace=
(
;NoBackSpace is used to make %g_ScriptTitle% not backspace any of the previously typed characters
;(ie, do not change the case of any previously typed characters).
;  On - characters you have already typed will not be changed
;  Off - characters you have already typed will be backspaced and replaced with the case of the word you have chosen.
)

helpinfo_AutoSpace=
(
;AutoSpace is used to automatically add a space to the end of an autocompleted word.
; On - Add a space to the end of the autocompleted word.
; Off - Do not add a space to the end of the autocompleted word.
)

helpinfo_SuppressMatchingWord=
(
;SuppressMatchingWord is used to suppress a word from the Word list if it matches the typed word.
;  If NoBackspace=On, then the match is case in-sensitive.
;  If NoBackspace=Off, then the match is case-sensitive.
; On - Suppress matching words from the word list.
; Off - Do not suppress matching words from the word list.
)

helpinfo_SendMethod=
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

helpinfo_TerminatingCharacters=
(
;TerminatingCharacters is a list of characters (EndKey) which will signal the program that you are done typing a word.
;You probably need to change this only when you want to recognize and type accented (diacritic) or Unicode characters
;or if you are using this with certain programming languages.
;
;For support of special characters, remove the key that is used to type the diacritic symbol (or the character) from the right hand side. 
;For example, if on your keyboard layout, " is used before typing ë, ; is used to type ñ, remove them from the right hand side.
;
;After this, %g_ScriptTitle% can recognize the special character. The side-effect is that, it cannot complete words typed after 
;the symbol, (e.g. "word... ) If you need to complete a word after a quotation mark, first type two quotation marks "" then 
;press left and type the word in the middle.
;
;If unsure, below is a setting for you to copy and use directly:
;
;Universal setting that works for many languages with accented or Unicode characters:
;{enter}{space}{bs}{esc}{tab}{Home}{End}{PgUp}{PdDn}{Up}{Dn}{Left}{Right}¿?¡!()$
;
;Default setting:
;%dft_TerminatingCharacters%
;
; More information on how to configure TerminatingCharacters:
;A list of keys may be found here:
; http://www.autohotkey.com/docs/KeyList.htm
;For more details on how to format the list of characters please see the EndKeys section (paragraphs 2,3,4) of:
; http://www.autohotkey.com/docs/commands/Input.htm
)

helpinfo_ForceNewWordCharacters=
(
;ForceNewWordCharacters is a comma separated list of characters which forces the program to start a new word whenever
;one of those characters is typed. Any words which begin with one of these characters will never be learned (even
;if learning is enabled). If you were typing a word when you hit one of these characters that word will be learned
;if learning is enabled.
;Change this only if you know what you are doing, it is probably only useful for certain programming languages.
; ex: ForceNewWordCharacters=@,:,#
)

helpinfo_ListBoxOffset=
(
;ListBoxOffset is the number of pixels below the top of the caret (vertical blinking line) to display the list.
)

helpinfo_ListBoxFontFixed=
(
;ListBoxFontFixed controls whether a fixed or variable character font width is used.
;(ie, in fixed width, "i" and "w" take the same number of pixels)
)

helpinfo_ListBoxFontOverride=
(
;ListBoxFontOverride is used to specify a font for the List Box to use. The default for Fixed is Courier,
;and the default for Variable is Tahoma.
)

helpinfo_ListBoxFontSize=
(
;ListBoxFontSize controls the size of the font in the list.
)

helpinfo_ListBoxCharacterWidth=
(
;ListBoxCharacterWidth is the width (in pixels) of one character in the List Box.
;This number should only need to be changed if the box containing the list is not the correct width.
;Some things which may cause this to need to be changed would include:
; 1. Changing the Font DPI in Windows
; 2. Changing the ListBoxFontFixed setting
; 3. Changing the ListBoxFontSize setting
;Leave this blank to let %g_ScriptTitle% try to compute the width.
)

helpinfo_ListBoxOpacity=
(
;ListBoxOpacity is how transparent (see-through) the ListBox should be. Use a value of 255 to make it so the
;ListBox is fully Opaque, or use a value of 0 to make it so the ListBox cannot be seen at all.
)

helpinfo_ListBoxRows=
(
;ListBoxRows is the maximum number of rows to show in the ListBox. This value can range from 3 to 30.
)

helpinfo_HelperWindowProgramExecutables=
(
;HelperWindowProgramExecutables is a list of executable (.exe) files that the HelperWindow should be automatically enabled for.
;If one the executables matches the current program, the HelperWindow will pop up automatically for that program.
)

helpinfo_HelperWindowProgramTitles=
(
;HelperWindowProgramTitles is a list of strings (separated by | ) to find in the title of the window that the HelperWindow should be automatically enabled for.
;If one of the strings is found in the title, the HelperWindow will pop up automatically for that program.
)

helpinfo_FullHelpString =
(
%helpinfo_IncludeProgramExecutables% `r`n`r`n %helpinfo_IncludeProgramTitles% `r`n`r`n %helpinfo_ExcludeProgramExecutables% `r`n`r`n %helpinfo_ExcludeProgramTitles%

%helpinfo_Length% `r`n`r`n %helpinfo_NumPresses% `r`n`r`n %helpinfo_LearnMode% `r`n`r`n %helpinfo_LearnCount% `r`n`r`n %helpinfo_LearnLength% `r`n`r`n %helpinfo_DoNotLearnStrings%

%helpinfo_ArrowKeyMethod% `r`n`r`n %helpinfo_DisabledAutoCompleteKeys% `r`n`r`n %helpinfo_DetectMouseClickMove% `r`n`r`n %helpinfo_NoBackSpace% `r`n`r`n %helpinfo_AutoSpace%

%helpinfo_SuppressMatchingWord% `r`n`r`n %helpinfo_SendMethod% `r`n`r`n %helpinfo_TerminatingCharacters% `r`n`r`n %helpinfo_ForceNewWordCharacters% `r`n`r`n %helpinfo_ListBoxOffset%

%helpinfo_ListBoxFontFixed% `r`n`r`n %helpinfo_ListBoxFontOverride% `r`n`r`n %helpinfo_ListBoxFontSize% `r`n`r`n %helpinfo_ListBoxCharacterWidth% `r`n`r`n %helpinfo_ListBoxOpacity%

%helpinfo_ListBoxRows% `r`n`r`n %helpinfo_HelperWindowProgramExecutables% `r`n`r`n %helpinfo_HelperWindowProgramTitles%
)

}
