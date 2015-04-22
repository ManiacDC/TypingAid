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
   global dft_ShowLearnedFirst
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
   global prefs_ShowLearnedFirst
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
      dft_ShowLearnedFirst,prefs_ShowLearnedFirst,Settings,Off
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
   global prefs_NoBackSpace, prefs_NumPresses, prefs_SendMethod, prefs_ShowLearnedFirst, prefs_SuppressMatchingWord, prefs_TerminatingCharacters
   global dft_NoBackSpace, dft_NumPresses, dft_SendMethod, dft_ShowLearnedFirst, dft_SuppressMatchingWord, dft_TerminatingCharacters
   
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
   
   if prefs_ShowLearnedFirst not in On,Off
      prefs_ShowLearnedFirst := dft_ShowLearnedFirst
   
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
   local PrefsExist
   
   ValidatePreferences()
   
   IfExist, %g_PrefsFile%
   {
      PrefsExist := true
   } else {
      PrefsExist := false
   }
      
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
         ; Make sure preferences already exist so we don't create 0 byte file
         if (PrefsExist == true)
         {
            IniDelete, %g_PrefsFile%,% g_PrefsSections[KeyName], %KeyName%
         }
      } else {
         IniWrite,% %element%, %g_PrefsFile%,% g_PrefsSections[KeyName], %KeyName%
      }
   }
   
   Return
}

ConstructHelpStrings()
{
   global

helpinfo_LearnMode=
(
;"Learn new words as you type" defines whether or not the script should learn new words as you type them, either On or Off.
)

helpinfo_LearnLength=
(
;"Minimum length of words to learn" is the minimum number of characters in a word for it to be learned. This must be at least Length+1.
)

helpinfo_LearnCount=
(
;"Add to wordlist after X times" defines the number of times you have to type a word within a single session for it to be learned permanently.
)

helpinfo_ListBoxRows=
(
;"Maximum number of results to show" is the maximum number of rows to show in the ListBox. This value can range from 3 to 30.
)

helpinfo_Length=
(
;"Show wordlist after X characters" is the minimum number of characters that need to be typed before the program shows a List of words.
;For example, if you need to autocomplete "assemble" in the word list, set this to 2, type 'as' and a list will appear.
)

helpinfo_SendMethod=
(
;"Send Method" is used to change the way the program sends the keys to the screen, this is included for compatibility reasons.
;Try changing this only when you encounter a problem with key sending during autocompletion.
;  1 = Fast method that reliably buffers key hits while sending. HAS BEEN KNOWN TO NOT FUNCTION ON SOME MACHINES.
;      If the script detects that this method will not work on the machine, it will switch to method 2.
;      (Might not work with characters that cannot be typed using the current keyboard layout.)
;  2 = Fastest method with unreliable keyboard buffering while sending. Has been known to not function on some machines.
;  3 = Slowest method, will not buffer or accept keyboard input while sending. Most compatible method.
;The options below use the clipboard to copy and paste the data to improve speed, but will leave an entry in any clipboard 
;history tracking routines you may be running. Data on the clipboard *will* be preserved prior to autocompletion.
;  4 = Same as 1 above.
;  5 = Same as 2 above, doesn't work on some machines.
;  6 = Same as 3 above.
;  7 = Alternate method.
)

helpinfo_DisabledAutoCompleteKeys=
(
;"Auto Complete Keys" is used to enable or disable hotkeys for autocompleting the selected item in the list.
)

helpinfo_ArrowKeyMethod=
(
;"Wordlist row highlighting" is the way the arrow keys are handled when a list is shown.
;Options are:
;  Off - only use the number keys
;  First - resets the highlighted row to the beginning whenever you type a new character
;  LastWord - keeps the highlighted row on the prior selected word if it's still in the list, else resets to the beginning
;  LastPosition - maintains the highlighted row's position
)

helpinfo_NoBackSpace=
(
;"Case correction" is used to correct the case of any previously typed characters.
;  On - characters you have already typed will be backspaced and replaced with the case of the word you have chosen.
;  Off - characters you have already typed will not be changed
)

helpinfo_DetectMouseClickMove=
(
;"Monitor mouse clicks" is used to detect when the cursor is moved with the mouse.
; On - %g_ScriptTitle% will not work when used with an On-Screen keyboard.
; Off - %g_ScriptTitle% will not detect when the cursor is moved within the same line using the mouse, and scrolling the text will clear the list.
)

helpinfo_AutoSpace=
(
;"Type space after autocomplete" is used to automatically add a space to the end of an autocompleted word.
; On - Add a space to the end of the autocompleted word.
; Off - Do not add a space to the end of the autocompleted word.
)

helpinfo_DoNotLearnStrings=
(
;"Sub-strings to not learn" is a comma separated list of strings. Any words which contain any of these strings will not be learned.
;This can be used to prevent the program from learning passwords or other critical information.
;For example, if you have ord98 in "Sub-strings to not learn", password987 will not be learned.
)

helpinfo_SuppressMatchingWord=
(
;"Suppress matching word" is used to suppress a word from the Word list if it matches the typed word.
;  If "Case correction" is On, then the match is case-sensitive.
;  If "Case correction" is Off, then the match is case in-sensitive.
; On - Suppress matching word from the word list.
; Off - Do not suppress matching word from the word list.
)

helpinfo_NumPresses=
(
;"Number of presses" is the number of times the number hotkey must be tapped for the word to be selected, either 1 or 2.
)

helpinfo_ShowLearnedFirst=
(
;"Show learned words first" controls whether the learned words appear before or after the words from Wordlist.txt.
)

helpinfo_ListBoxOffset=
(
;"List appears X pixels below cursor" is the number of pixels below the top of the caret (vertical blinking line) to display the list.
)

helpinfo_ListBoxFontFixed=
(
;"Fixed width font in list" controls whether a fixed or variable character font width is used.
;(e.g., in fixed width, "i" and "w" take the same number of pixels)
)

helpinfo_ListBoxFontSize=
(
;"Font size in list" controls the size of the font in the list.
)

helpinfo_ListBoxOpacity=
(
;"list opacity" is how transparent (see-through) the Wordlist Box should be. Use a value of 255 to make it so the
;Wordlist Box is fully ypaque, or use a value of 0 to make it so the Wordlist Box cannot be seen at all.
)

helpinfo_ListBoxCharacterWidth=
(
;"List character width override" is the width (in pixels) of one character in the Wordlist Box.
;This number should only need to be changed if the box containing the list is not the correct width.
;Some things which may cause this to need to be changed would include:
; 1. Changing the Font DPI in Windows
; 2. Changing the "Fixed width font in list" setting
; 3. Changing the "Font size in list" setting
;Leave this blank to let %g_ScriptTitle% try to compute the width.
)

helpinfo_ListBoxFontOverride=
(
;"list font" is used to specify a font for the Wordlist Box to use. The default for Fixed is Courier,
;and the default for Variable is Tahoma.
)

helpinfo_IncludeProgramTitles=
(
;"Window titles you want %g_ScriptTitle% enabled for" is a list of strings (separated by | ) to find in the title of the window you want %g_ScriptTitle% enabled for.
;If one of the strings is found in the title, %g_ScriptTitle% is enabled for that window.
)

helpinfo_ExcludeProgramTitles=
(
;"Window titles you want %g_ScriptTitle% disabled for" is a list of strings (separated by | ) to find in the title of the window you want %g_ScriptTitle% disabled for.
;If one of the strings is found in the title, %g_ScriptTitle% is disabled for that window.
)
   
helpinfo_IncludeProgramExecutables=
(
;"Processes you want %g_ScriptTitle% enabled for" is a list of executable (.exe) files that %g_ScriptTitle% should be enabled for.
;If one of the executables matches the current program, %g_ScriptTitle% is enabled for that program.
)

helpinfo_ExcludeProgramExecutables=
(
;"Processes you want %g_ScriptTitle% disabled for" is a list of executable (.exe) files that %g_ScriptTitle% should be disabled for.
;If one of the executables matches the current program, %g_ScriptTitle% is disabled for that program.
)

helpinfo_HelperWindowProgramTitles=
(
;"Window titles you want the helper window enabled for" is a list of strings (separated by | ) to find in the title of the window that the helper window should be automatically enabled for.
;If one of the strings is found in the title, the helper window will pop up automatically for that program.
)

helpinfo_HelperWindowProgramExecutables=
(
;"Processes you want the helper window enabled for" is a list of executable (.exe) files that the helper window should be automatically enabled for.
;If one of the executables matches the current program, the helper window will pop up automatically for that program.
)

helpinfo_TerminatingCharacters=
(
;"Terminating Characters" is a list of characters (EndKey) which will signal the program that you are done typing a word.
;You probably need to change this only when using this with certain programming languages.
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
;"Force New Word Characters" is a comma separated list of characters which forces the program to start a new word whenever
;one of those characters is typed. Any words which begin with one of these characters will never be learned (even
;if learning is enabled). If you were typing a word when you hit one of these characters that word will be learned
;if learning is enabled.
;Change this only if you know what you are doing, it is probably only useful for certain programming languages.
; ex: ForceNewWordCharacters=@,:,#
)

helpinfo_FullHelpString =
(
%helpinfo_LearnMode%`r`n`r`n%helpinfo_LearnLength%`r`n`r`n%helpinfo_LearnCount%

%helpinfo_DoNotLearnStrings%`r`n`r`n%helpinfo_NumPresses%

%helpinfo_DisabledAutoCompleteKeys%`r`n`r`n%helpinfo_SendMethod%

%helpinfo_NoBackSpace%`r`n`r`n%helpinfo_DetectMouseClickMove%`r`n`r`n%helpinfo_AutoSpace%

%helpinfo_ListBoxRows%`r`n`r`n%helpinfo_Length%`r`n`r`n%helpinfo_ShowLearnedFirst%

%helpinfo_ArrowKeyMethod%`r`n`r`n%helpinfo_SuppressMatchingWord%

%helpinfo_ListBoxOffset%`r`n`r`n%helpinfo_ListBoxFontFixed%`r`n`r`n%helpinfo_ListBoxFontSize%

%helpinfo_ListBoxOpacity%`r`n`r`n%helpinfo_ListBoxCharacterWidth%`r`n`r`n%helpinfo_ListBoxFontOverride%

%helpinfo_IncludeProgramTitles%`r`n`r`n%helpinfo_ExcludeProgramTitles%`r`n`r`n%helpinfo_IncludeProgramExecutables%`r`n`r`n%helpinfo_ExcludeProgramExecutables%

%helpinfo_HelperWindowProgramTitles%`r`n`r`n%helpinfo_HelperWindowProgramExecutables%

%helpinfo_TerminatingCharacters%`r`n`r`n%helpinfo_ForceNewWordCharacters% 
)

}
