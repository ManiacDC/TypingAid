; GUI for TypingAid configuration
; by HugoV / Maniac

LaunchSettings:
if (g_InSettings == true)
{
   return
}
InactivateAll()
Menu, Tray, Disable, Settings
g_InSettings := true
ClearAllVars(True)
Menu_OldLearnCount := prefs_LearnCount
; initialize this to make sure the object exists
Menu_ChangedPrefs := Object()
ConstructGui()
; Call "HandleMessage" when script receives WM_SETCURSOR message
OnMessage(g_WM_SETCURSOR, "HandleSettingsMessage")
; Call "HandleMessage" when script receives WM_MOUSEMOVE message
OnMessage(g_WM_MOUSEMOVE, "HandleSettingsMessage")
; clear and re-initialize variables after constructing the GUI as some controls call the edit flag immediately
Menu_ChangedPrefs =
Menu_ChangedPrefs := Object()
Menu_ValueChanged := false
Return

ConstructGui()
{
   global prefs_ArrowKeyMethod, prefs_AutoSpace, prefs_DetectMouseClickMove, prefs_DisabledAutoCompleteKeys, prefs_DoNotLearnStrings
   global helpinfo_ArrowKeyMethod, helpinfo_AutoSpace, helpinfo_DetectMouseClickMove, helpinfo_DisabledAutoCompleteKeys, helpinfo_DoNotLearnStrings
   global prefs_ForceNewWordCharacters, prefs_LearnCount, prefs_LearnLength, prefs_LearnMode, prefs_Length
   global helpinfo_ForceNewWordCharacters, helpinfo_LearnCount, helpinfo_LearnLength, helpinfo_LearnMode, helpinfo_Length
   global prefs_NoBackSpace, prefs_NumPresses, prefs_SendMethod, prefs_ShowLearnedFirst, prefs_SuppressMatchingWord, prefs_TerminatingCharacters
   global helpinfo_NoBackSpace, helpinfo_NumPresses, helpinfo_SendMethod, helpinfo_ShowLearnedFirst, helpinfo_SuppressMatchingWord, helpinfo_TerminatingCharacters
   global prefs_ExcludeProgramExecutables, prefs_ExcludeProgramTitles, prefs_IncludeProgramExecutables, prefs_IncludeProgramTitles, prefs_HelperWindowProgramExecutables, prefs_HelperWindowProgramTitles
   global helpinfo_ExcludeProgramExecutables, helpinfo_ExcludeProgramTitles, helpinfo_IncludeProgramExecutables, helpinfo_IncludeProgramTitles, helpinfo_HelperWindowProgramExecutables, helpinfo_HelperWindowProgramTitles
   global prefs_ListBoxCharacterWidth, prefs_ListBoxFontFixed, prefs_ListBoxFontOverride, prefs_ListBoxFontSize, prefs_ListBoxOffset, prefs_ListBoxOpacity, prefs_ListBoxRows
   global helpinfo_ListBoxCharacterWidth, helpinfo_ListBoxFontFixed, helpinfo_ListBoxFontOverride, helpinfo_ListBoxFontSize, helpinfo_ListBoxOffset, helpinfo_ListBoxOpacity, helpinfo_ListBoxRows
   global helpinfo_FullHelpString
   global Menu_ArrowKeyMethodOptionsText, Menu_CaseCorrection, Menu_ListBoxOpacityUpDown, Menu_SendMethodOptionsCode, Menu_SendMethodC
   global Menu_CtrlEnter, Menu_CtrlSpace, Menu_Enter, Menu_SingleClick, Menu_NumberKeys, Menu_RightArrow, Menu_Tab
   global g_ScriptTitle
   ; Must be global for colors to function, colors will not function if static
   global Menu_VisitForum
   
   Menu_CaseCorrection=
   Menu_ArrowKeyMethodOptionsText=
   
   MenuFontList:=Writer_enumFonts() ; see note at function for credit

   MenuGuiWidth=700
   MenuGuiHeight=480
   MenuGuiRows = 8
   MenuGuiHelpIcon = %A_Space%(?)%A_Space%

   MenuSeparatorX = 10
   MenuSeparatorY = 8
   MenuEditIndentX = 10
   MenuEditIndentY = 20
   MenuHelpIndentX = 30
   MenuHelpIndentY = 0
	
   MenuRowHeight := (MenuGuiHeight - ((MenuGuiRows +1 ) * MenuSeparatorY ))/MenuGuiRows

   MenuTextMenuRowY := (MenuRowHeight - 6 ) / 3

   MenuTabWidth:=MenuGuiWidth-4
   MenuTabHeight:=MenuGuiHeight-75
   MenuTabHeightEdit:=MenuTabHeight-40

   MenuOneColGroupWidth := MenuGuiWidth - (2 * MenuSeparatorX)
   MenuTwoColGroupWidth := (MenuGuiWidth - (3 * MenuSeparatorX))/2
   MenuThreeColGroupWidth := (MenuGuiWidth - (4 * MenuSeparatorX))/3
   MenuDualThreeColGroupWidth := (MenuThreeColGroupWidth * 2) + MenuSeparatorX

   MenuOneColEditWidth := MenuOneColGroupWidth - (MenuEditIndentX * 2)
   MenuTwoColEditWidth := MenuTwoColGroupWidth - (MenuEditIndentX * 2)
   MenuThreeColEditWidth := MenuThreeColGroupWidth - (MenuEditIndentX * 2)
   MenuOneColEditWidthEdit := MenuOneColEditWidth - 140
   MenuOneColEditButton := MenuOneColEditWidthEdit + 30

   MenuGroup1BoxX := MenuSeparatorX
   MenuGroup1EditX := MenuGroup1BoxX + MenuEditIndentX
   MenuGroup1of1HelpX := MenuGroup1BoxX + MenuOneColGroupWidth - MenuHelpIndentX
   MenuGroup1of2HelpX := MenuGroup1BoxX + MenuTwoColGroupWidth - MenuHelpIndentX
   MenuGroup1of3HelpX := MenuGroup1BoxX + MenuThreeColGroupWidth - MenuHelpIndentX

   MenuGroup2of2BoxX := MenuGroup1BoxX + MenuTwoColGroupWidth + MenuSeparatorX
   MenuGroup2of2EditX := MenuGroup2of2BoxX + MenuEditIndentX
   MenuGroup2of2HelpX := MenuGroup2of2BoxX + MenuTwoColGroupWidth - MenuHelpIndentX
   
   MenuGroup2of3BoxX := MenuGroup1BoxX + MenuThreeColGroupWidth + MenuSeparatorX
   MenuGroup2of3EditX := MenuGroup2of3BoxX + MenuEditIndentX
   MenuGroup2of3HelpX := MenuGroup2of3BoxX + MenuThreeColGroupWidth - MenuHelpIndentX
	
   MenuGroup3of3BoxX := MenuGroup2of3BoxX + MenuThreeColGroupWidth + MenuSeparatorX
   MenuGroup3of3EditX := MenuGroup3of3BoxX + MenuEditIndentX
   MenuGroup3of3HelpX := MenuGroup3of3BoxX + MenuThreeColGroupWidth - MenuHelpIndentX
	
   MenuRowY := MenuSeparatorY + 30
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Font, s8, Arial

   Gui, MenuGui:Add, Tab2, x2 w%MenuTabWidth% h%MenuTabHeight%, General Settings|Wordlist Box|Programs|Advanced (Experts Only)|About && Help

   Gui, MenuGui:Tab, 1 ; General Settings

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Learn new words as you type
   Menu_LearnModeOptions=|On|Off|
   StringReplace, Menu_LearnModeOptions, Menu_LearnModeOptions, |%prefs_LearnMode%|,|%prefs_LearnMode%||
   StringTrimLeft, Menu_LearnModeOptions, Menu_LearnModeOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vprefs_LearnMode gEditValue, %Menu_LearnModeOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of3HelpX% y%MenuRowHelpY% vhelpinfo_LearnMode gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack


   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Minimum length of word to learn
   Menu_LearnLengthOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
   StringReplace,  Menu_LearnLengthOptions, Menu_LearnLengthOptions, |%prefs_LearnLength%|,|%prefs_LearnLength%||
   StringTrimLeft, Menu_LearnLengthOptions, Menu_LearnLengthOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of3EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vprefs_LearnLength gEditValue, %Menu_LearnLengthOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of3HelpX% y%MenuRowHelpY% vhelpinfo_LearnLength gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack
   

   Gui, MenuGui:Add, GroupBox, x%MenuGroup3of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight%, Add to wordlist after X times
   Menu_LearnCountOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
   StringReplace,  Menu_LearnCountOptions, Menu_LearnCountOptions, |%prefs_LearnCount%|,|%prefs_LearnCount%||
   StringTrimLeft, Menu_LearnCountOptions, Menu_LearnCountOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup3of3EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vprefs_LearnCount gEditValue, %Menu_LearnCountOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup3of3HelpX% y%MenuRowHelpY% vhelpinfo_LearnCount gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack
   

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuTwoColGroupWidth% h%MenuRowHeight% , Sub-strings to not learn
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuTwoColEditWidth% r1 vprefs_DoNotLearnStrings Password gEditValue, %prefs_DoNotLearnStrings%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of2HelpX% y%MenuRowHelpY% vhelpinfo_DoNotLearnStrings gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of2BoxX% y%MenuRowY% w%MenuTwoColGroupWidth% h%MenuRowHeight% , Number of presses
   Menu_NumPressesOptions=|1|2|
   StringReplace,  Menu_NumPressesOptions, Menu_NumPressesOptions, |%prefs_NumPresses%|,|%prefs_NumPresses%||
   StringTrimLeft, Menu_NumPressesOptions, Menu_NumPressesOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of2EditX% y%MenuRowEditY% w%MenuTwoColEditWidth% r5 vprefs_NumPresses gEditValue, %Menu_NumPressesOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of2HelpX% y%MenuRowHelpY% vhelpinfo_NumPresses gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack


   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuDualThreeColGroupWidth% h%MenuRowHeight% , Auto Complete Keys
   ;  E = Ctrl + Enter
   ;  S = Ctrl + Space
   ;  T = Tab
   ;  R = Right Arrow
   ;  N = Number Keys
   ;  U = Enter
   ;  L = Single Click
   Menu_CheckedE=Checked
   Menu_CheckedS=Checked
   Menu_CheckedT=Checked
   Menu_CheckedR=Checked
   Menu_CheckedN=Checked
   Menu_CheckedU=Checked
   Menu_CheckedL=Checked
   Loop, parse, prefs_DisabledAutoCompleteKeys
   {
	  If (A_LoopField = "E")
		 Menu_CheckedE =
	  If (A_LoopField = "S")
		 Menu_CheckedS =
	  If (A_LoopField = "T")
		 Menu_CheckedT =
	  If (A_LoopField = "R")
		 Menu_CheckedR =
	  If (A_LoopField = "N")
		 Menu_CheckedN =
	  If (A_LoopField = "U")
		 Menu_CheckedU =
	  If (A_LoopField = "L")
		 Menu_CheckedL =
   }

   MenuCheckmarkIndent := MenuTwoColEditWidth/3 + MenuEditIndentX
   Gui, MenuGui:Add, Checkbox, x%MenuGroup1EditX% yp+%MenuTextMenuRowY% vMenu_CtrlEnter gEditValue %Menu_CheckedE%, Ctrl + Enter
   Gui, MenuGui:Add, Checkbox, xp%MenuCheckmarkIndent% yp vMenu_Tab gEditValue %Menu_CheckedT%, Tab
   Gui, MenuGui:Add, Checkbox, xp%MenuCheckmarkIndent% yp vMenu_RightArrow gEditValue %Menu_CheckedR%, Right Arrow
   Gui, MenuGui:Add, Checkbox, xp%MenuCheckmarkIndent% yp vMenu_SingleClick gEditValue %Menu_CheckedL%, Single Click
   Gui, MenuGui:Add, Checkbox, x%MenuGroup1EditX% yp+%MenuTextMenuRowY% vMenu_CtrlSpace gEditValue %Menu_CheckedS%, Ctrl + Space
   Gui, MenuGui:Add, Checkbox, xp%MenuCheckmarkIndent% yp vMenu_NumberKeys gEditValue %Menu_CheckedN%, Number Keys
   Gui, MenuGui:Add, Checkbox, xp%MenuCheckmarkIndent% yp vMenu_Enter gEditValue %Menu_CheckedU%, Enter

   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of3HelpX% y%MenuRowHelpY% vhelpinfo_DisabledAutoCompleteKeys gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack


   Gui, MenuGui:Add, GroupBox, x%MenuGroup3of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Send Method
   Menu_SendMethodOptionsText=1 - Default (Type)|2 - Fast (Type)|3 - Slow (Type)|4 - Default (Paste)|5 - Fast (Paste)|6 - Slow (Paste)|7 - Alternate method
   Menu_SendMethodOptionsCode=1|2|3|1C|2C|3C|4C
   Loop, parse, Menu_SendMethodOptionsCode, |
   {
	  If (prefs_SendMethod = A_LoopField)
		 Menu_SendCount:=A_Index
   }

   Loop, parse, Menu_SendMethodOptionsText, |
   {
	  Menu_SendMethodOptions .= A_LoopField "|"
	  If (A_Index = Menu_SendCount)
		 Menu_SendMethodOptions .= "|"
   }   
   Gui, MenuGui:Add, DDL, x%MenuGroup3of3EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vMenu_SendMethodC gEditValue altsubmit, %Menu_SendMethodOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup3of3HelpX% y%MenuRowHelpY% vhelpinfo_SendMethod gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack
   

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Case correction
   Menu_CaseCorrectionOptions=|On|Off|
   If (prefs_NoBackSpace = "on")
	  Menu_CaseCorrection=Off
   Else If (prefs_NoBackSpace = "off")
	  Menu_CaseCorrection=On
   StringReplace,  Menu_CaseCorrectionOptions, Menu_CaseCorrectionOptions, |%Menu_CaseCorrection%|,|%Menu_CaseCorrection%||
   StringTrimLeft, Menu_CaseCorrectionOptions, Menu_CaseCorrectionOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vMenu_CaseCorrection gEditValue, %Menu_CaseCorrectionOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of3HelpX% y%MenuRowHelpY% vhelpinfo_NoBackSpace gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack


   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Monitor mouse clicks 
   Menu_DetectMouseClickMoveOptions=|On|Off|
   StringReplace,  Menu_DetectMouseClickMoveOptions, Menu_DetectMouseClickMoveOptions, |%prefs_DetectMouseClickMove%|,|%prefs_DetectMouseClickMove%||
   StringTrimLeft, Menu_DetectMouseClickMoveOptions, Menu_DetectMouseClickMoveOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of3EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vprefs_DetectMouseClickMove gEditValue, %Menu_DetectMouseClickMoveOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of3HelpX% y%MenuRowHelpY% vhelpinfo_DetectMouseClickMove gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup3of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Type space after autocomplete
   Menu_AutoSpaceOptions=|On|Off|
   StringReplace,  Menu_AutoSpaceOptions, Menu_AutoSpaceOptions, |%prefs_AutoSpace%|,|%prefs_AutoSpace%||
   StringTrimLeft, Menu_AutoSpaceOptions, Menu_AutoSpaceOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup3of3EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vprefs_AutoSpace gEditValue, %Menu_AutoSpaceOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup3of3HelpX% y%MenuRowHelpY% vhelpinfo_AutoSpace gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Tab, 2 ; listbox ---------------------------------------------------------


   MenuRowY := MenuSeparatorY + 30
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Show wordlist after X characters
   Menu_LengthOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
   StringReplace,  Menu_LengthOptions, Menu_LengthOptions, |%prefs_Length%|,|%prefs_Length%||
   StringTrimLeft, Menu_LengthOptions, Menu_LengthOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of3EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vprefs_Length gEditValue, %Menu_LengthOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of3HelpX% y%MenuRowHelpY% vhelpinfo_Length gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Maximum number of results to show
   Menu_ListBoxRowsOptions=|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|
   StringReplace,  Menu_ListBoxRowsOptions, Menu_ListBoxRowsOptions, |%prefs_ListBoxRows%|,|%prefs_ListBoxRows%||
   StringTrimLeft, Menu_ListBoxRowsOptions, Menu_ListBoxRowsOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vprefs_ListBoxRows gEditValue, %Menu_ListBoxRowsOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of3HelpX% y%MenuRowHelpY% vhelpinfo_ListBoxRows gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup3of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Show learned words first
   Menu_ShowLearnedFirstOptions=|On|Off|
   StringReplace,  Menu_ShowLearnedFirstOptions, Menu_ShowLearnedFirstOptions, |%prefs_ShowLearnedFirst%|,|%prefs_ShowLearnedFirst%||
   StringTrimLeft, Menu_ShowLearnedFirstOptions, Menu_ShowLearnedFirstOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup3of3EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% vprefs_ShowLearnedFirst gEditValue, %Menu_ShowLearnedFirstOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup3of3HelpX% y%MenuRowHelpY% vhelpinfo_ShowLearnedFirst gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY


   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuTwoColGroupWidth% h%MenuRowHeight% , Wordlist row highlighting
   Menu_ArrowKeyMethodOptionsText=Off - only use the number keys|First - reset selected word to the beginning|LastWord - keep last word selected|LastPosition - keep the last cursor position
   Loop, parse, Menu_ArrowKeyMethodOptionsText, |
   {
	  Menu_ArrowKeyMethodOptions .= A_LoopField "|"
	  StringSplit, Split, A_LoopField, -
      Split1 := Trim(Split1)
	  If (Split1 = prefs_ArrowKeyMethod)
	  {
		 Menu_ArrowKeyMethodOptions .= "|"
	  }   
   }

   Gui, MenuGui:Add, DDL, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuTwoColEditWidth% r5 vprefs_ArrowKeyMethod gEditValue altsubmit, %Menu_ArrowKeyMethodOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of2HelpX% y%MenuRowHelpY% vhelpinfo_ArrowKeyMethod gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of2BoxX% y%MenuRowY% w%MenuTwoColGroupWidth% h%MenuRowHeight% , Suppress matching word
   Menu_SuppressMatchingWordOptions=|On|Off|
   StringReplace,  Menu_SuppressMatchingWordOptions, Menu_SuppressMatchingWordOptions, |%prefs_SuppressMatchingWord%|,|%prefs_SuppressMatchingWord%||
   StringTrimLeft, Menu_SuppressMatchingWordOptions, Menu_SuppressMatchingWordOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of2EditX% y%MenuRowEditY% w%MenuTwoColEditWidth% vprefs_SuppressMatchingWord gEditValue, %Menu_SuppressMatchingWordOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of2HelpX% y%MenuRowHelpY% vhelpinfo_SuppressMatchingWord gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY


   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , List appears X pixels below cursor
   Menu_ListBoxOffsetOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32
   StringReplace,  Menu_ListBoxOffsetOptions, Menu_ListBoxOffsetOptions, |%prefs_ListBoxOffset%|,|%prefs_ListBoxOffset%||
   StringTrimLeft, Menu_ListBoxOffsetOptions, Menu_ListBoxOffsetOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vprefs_ListBoxOffset gEditValue, %Menu_ListBoxOffsetOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of3HelpX% y%MenuRowHelpY% vhelpinfo_ListBoxOffset gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Fixed width font in list
   Menu_ListBoxFontFixedOptions=|On|Off|
   StringReplace,  Menu_ListBoxFontFixedOptions, Menu_ListBoxFontFixedOptions, |%prefs_ListBoxFontFixed%|,|%prefs_ListBoxFontFixed%||
   StringTrimLeft, Menu_ListBoxFontFixedOptions, Menu_ListBoxFontFixedOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of3EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vprefs_ListBoxFontFixed gEditValue, %Menu_ListBoxFontFixedOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of3HelpX% y%MenuRowHelpY% vhelpinfo_ListBoxFontFixed gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup3of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Font size in list
   Menu_ListBoxFontSizeOptions=|8|9|10|11|12|13|14|15|16|17|18|19|20|
   StringReplace,  Menu_ListBoxFontSizeOptions, Menu_ListBoxFontSizeOptions, |%prefs_ListBoxFontSize%|,|%prefs_ListBoxFontSize%||
   StringTrimLeft, Menu_ListBoxFontSizeOptions, Menu_ListBoxFontSizeOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup3of3EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vprefs_ListBoxFontSize gEditValue, %Menu_ListBoxFontSizeOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup3of3HelpX% y%MenuRowHelpY% vhelpinfo_ListBoxFontSize gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY


   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , List opacity
   Gui, MenuGui:Add, Edit, xp+10 yp+20 w%MenuThreeColEditWidth% vprefs_ListBoxOpacity gEditValue, %prefs_ListBoxOpacity%
   Gui, MenuGui:Add, UpDown, xp+10 yp+20 w%MenuThreeColEditWidth% vMenu_ListBoxOpacityUpDown Range0-255, %prefs_ListBoxOpacity%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of3HelpX% y%MenuRowHelpY% vhelpinfo_ListBoxOpacity gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , List character width override
   Menu_ListBoxCharacterWidthOptions=||5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|
   StringReplace,  Menu_ListBoxCharacterWidthOptions, Menu_ListBoxCharacterWidthOptions, |%prefs_ListBoxCharacterWidth%|,|%prefs_ListBoxCharacterWidth%||
   StringTrimLeft, Menu_ListBoxCharacterWidthOptions, Menu_ListBoxCharacterWidthOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of3EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r5 vprefs_ListBoxCharacterWidth gEditValue, %Menu_ListBoxCharacterWidthOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of3HelpX% y%MenuRowHelpY% vhelpinfo_ListBoxCharacterWidth gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup3of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , List font
   MenuFontList := "|" . MenuFontList . "|"
   sort, MenuFontList, D|
   If (MenuListBoxFont = "") or (MenuListBoxFont = " ")
	  StringReplace, MenuFontList, MenuFontList, |%prefs_ListBoxFontOverride%|, |%prefs_ListBoxFontOverride%||
   Gui, MenuGui:Add, DDL, x%MenuGroup3of3EditX% y%MenuRowEditY% w%MenuThreeColEditWidth% r10 w200 vprefs_ListBoxFontOverride gEditValue, %MenuFontList%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup3of3HelpX% y%MenuRowHelpY% vhelpinfo_ListBoxFontOverride gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY


   Gui, MenuGui:Tab, 3 ; Programs ---------------------------------------------------------


   MenuRowY := MenuSeparatorY + 30
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Window titles you want %g_ScriptTitle% enabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% r1 vprefs_IncludeProgramTitles gEditValue, %prefs_IncludeProgramTitles%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetEnableTitles, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhelpinfo_IncludeProgramTitles gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack
   
   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Window titles you want %g_ScriptTitle% disabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% r1 vprefs_ExcludeProgramTitles gEditValue, %prefs_ExcludeProgramTitles%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetDisableTitles, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhelpinfo_ExcludeProgramTitles gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Processes you want %g_ScriptTitle% enabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% r1 vprefs_IncludeProgramExecutables gEditValue, %prefs_IncludeProgramExecutables%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetEnableProcess, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhelpinfo_IncludeProgramExecutables gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Processes you want %g_ScriptTitle% disabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% r1 vprefs_ExcludeProgramExecutables gEditValue, %prefs_ExcludeProgramExecutables%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetDisableProcess, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhelpinfo_ExcludeProgramExecutables gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   ;HelperWindowProgramTitles

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Window titles you want the helper window enabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% r1 vprefs_HelperWindowProgramTitles gEditValue, %prefs_HelperWindowProgramTitles%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetHelpTitles, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhelpinfo_HelperWindowProgramTitles gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   ;HelperWindowProgramExecutables

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Processes you want the helper window enabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% r1 vprefs_HelperWindowProgramExecutables gEditValue, %prefs_HelperWindowProgramExecutables%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetHelpProcess, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhelpinfo_HelperWindowProgramExecutables gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack



   Gui, MenuGui:Tab, 4 ; advanced  -------------------------------------------------------------------------

   MenuRowY := MenuSeparatorY + 30
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Terminating Characters (see http://www.autohotkey.com/docs/KeyList.htm)
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidth% r1 vprefs_TerminatingCharacters gEditValue, %prefs_TerminatingCharacters%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhelpinfo_TerminatingCharacters gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowEditY := MenuRowY + MenuEditIndentY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Force New Word Characters (comma separated)
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidth% r1 vprefs_ForceNewWordCharacters gEditValue, %prefs_ForceNewWordCharacters%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhelpinfo_ForceNewWordCharacters gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack



   Gui, MenuGui:Tab, 5 ; about & help --------------------------------------------

   MenuRowY := MenuSeparatorY + 30
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   helpinfo_Intro=
   (
%g_ScriptTitle% is a simple, compact, and handy auto-completion utility.

It is customizable enough to be useful for regular typing and for programming.

Features:
As you type your word, up to 10 (or as defined in Settings) matches will appear in a drop-down dialog, numbered 1 - 0 (10th). To choose the match you want just hit the associated number on your keyboard (numpad does not work). Alternatively you can select an item from the drop-down using the Up/Down arrows. You can define a fixed position for the drop-down dialog to appear by hitting Ctrl-Shift-H to open a small helper window, or by specifying a list of programs in the preferences file. Please note that in Firefox, Thunderbird, and certain other programs you will probably need to open the helper window due to issues detecting the caret position.

Words should be stored in a file named 'Wordlist.txt' which should be located in the script directory. These words may be commented out by prefixing with a semicolon or simply removed or added. Words may include terminating characters (such as space), but you must select the word before typing the terminating character.

In addition to being able to use the number keys to select a word, you can select words from the drop-down via the Up/Down arrows. Hitting Up on the first item will bring you to the last and hitting Down on the last item will bring you to the first. Hitting Page Up will bring you up 10 items, or to the first item. Hitting Page Down will bring you down 10 items, or to the last item. You can hit Tab, Right Arrow, Ctrl-Space, or Ctrl-Enter to autocomplete the selected word. This feature can be disabled or have some of its behavior modified via Settings.

The script will learn words as you type them if "Learn new words as you type" is set to On in Settings. If you type a word more than 5 times (or as defined in "Minimum length of word to learn") in a single session the word will be permanently added to the list of learned words. Learned words will always appear below predefined words, but will be ranked and ordered among other learned words based on the frequency you type them. You can permanently learn a word by highlighting a word and hitting Ctrl-Shift-C (this works even if "Learn new words as you type" is set to Off). You may use Ctrl-Shift-Del to remove the currently selected Learned Word.
Learned words are stored in the WordlistLearned.db sqlite3 database. Learned words are backed up in WordlistLearned.txt. To modify the list of Learned words manually, delete the WordlistLearned.db database, then manually edit the WordlistLearned.txt file. On the next launch of the script, the WordlistLearned.db database will be rebuilt.

When Settings are changed, the script will automatically create a file named Preferences.ini in the script directory. This file allows for sharing settings between users. Users are encouraged to only edit settings by using the Settings window.
To allow for distribution of standardized preferences, a Defaults.ini may be distributed with the same format as Preferences.ini. If the Defaults.ini is present, this will override the hardcoded defaults in the script. A user may override the Defaults.ini by changing settings in the Settings window.

Customizable features include (see also detailed description below)

   * Enable or disable learning mode.
   * Number of characters a word needs to have in order to be learned.
   * Number of times you must type a word before it is permanently learned.
   * Number of items to show in the list at once.
   * Number of characters before the list of words appears.
   * Change the method used to send the word to the screen.
   * Enable, disable, or customize the arrow key's functionality.
   * Disable certain keys for autocompleting a word selected via the arrow keys.
   * Change whether the script simply completes or actually replaces the word (capitalization change based on the wordlist file).
   * Enable or disable the resetting of the Wordlist Box on a mouseclick.
   * Change whether a space should be automatically added after the autocompleted word or not.
   * List of strings which will prevent any word which contains one of these strings from being learned.
   * Change whether the typed word should appear in the word list or not.
   * Number of pixels below the caret to display the Wordlist Box.
   * Wordlist Box Default Font of fixed (Courier New) or variable (Tahoma) width.
   * Wordlist Box Font Size.
   * Wordlist Box Opacity setting to set the transparency of the List Box.
   * Wordlist Box Character Width to override the computed character width.
   * Wordlist Box Default Font override.
   * List of programs for which you want %g_ScriptTitle% enabled.
   * List of programs for which you do not want %g_ScriptTitle% enabled.
   * List of programs for which you want the Helper Window to automatically open.
   * List of characters which terminate a word.
   * List of characters which terminate a word and start a new word.
   * Number of times you must press a number hotkey to select the associated word (options are 1 and 2, 2 is buggy).
   
Unicode Support:
Full support for UTF-8 character set.
   )
   
   helpinfo_HelpText = %helpinfo_Intro%`r`n`r`n%helpinfo_FullHelpString%

   Loop, Parse, helpinfo_HelpText,`n, `r
   {
	  IF ( SubStr(A_LoopField, 1,1) = ";")
	  {
		 helpinfo_ModHelpText .= SubStr(A_LoopField,2) . "`r`n"
	  } else
	  {
		 helpinfo_ModHelpText .= A_LoopField . "`r`n"
	  }
   }

   Gui, MenuGui:Add, Edit, ReadOnly x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuTabHeightEdit%, %helpinfo_ModHelpText%

   helpinfo_ModHelpText =
   helpinfo_HelpText =
   helpinfo_Intro =

   Gui, MenuGui:tab, 

   MenuRowY := MenuTabHeight+15
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY
   MenuRowThreeButtonWidth := (MenuTwoColGroupWidth - (4 * MenuEditIndentX))/3
   MenuRowThreeButtonNext := MenuEditIndentX + MenuRowThreeButtonWidth

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX%           y%MenuRowY%     w%MenuTwoColGroupWidth% h50 , Configuration
   Gui, MenuGui:Add, Button,   x%MenuGroup1EditX%          y%MenuRowEditY% w%MenuRowThreeButtonWidth%    gSave   , Save && Close
   Gui, MenuGui:Add, Button,   xp+%MenuRowThreeButtonNext% yp          w%MenuRowThreeButtonWidth%    gRestore, Restore default
   Gui, MenuGui:Add, Button,   xp+%MenuRowThreeButtonNext% yp          w%MenuRowThreeButtonWidth%    gCancelButton , Cancel

   if (g_ScriptTitle == "TypingAid")
   {
      Gui, MenuGui:Font, cBlack bold
      Gui, MenuGui:Add, Text, x%MenuGroup2of2EditX% Yp-10, %g_ScriptTitle%
      Gui, MenuGui:Font, cBlack normal

      Gui, MenuGui:Add, Text, xp+60 Yp, is free software, support forum at
      Gui, MenuGui:Font, cGreen 
      ;the vMenu_VisitForum variable is necessary for the link highlighting
      Gui, MenuGui:Add, Text, x%MenuGroup2of2EditX% Yp+%MenuTextMenuRowY% vMenu_VisitForum gVisitForum, www.autohotkey.com (click here)
      Gui, MenuGui:Font, cBlack 
   }
   
   Gui, Menugui:+OwnDialogs
   Gui, MenuGui:Show, h%MenuGuiHeight% w%MenuGuiWidth%, %g_ScriptTitle% Settings
   Return
}

SetEnableTitles:
GetList("prefs_IncludeProgramTitles",0)
Return

SetDisableTitles:
GetList("prefs_ExcludeProgramTitles",0)
Return

SetEnableProcess:
GetList("prefs_IncludeProgramExecutables",1)
Return

SetDisableProcess:
GetList("prefs_ExcludeProgramExecutables",1)
Return

SetHelpTitles:
GetList("prefs_HelperWindowProgramTitles",0)
Return

SetHelpProcess:
GetList("prefs_HelperWindowProgramExecutables",1)
Return

GetList(TitleType,GetExe)
{
   global Menu_TitleType
   global Menu_InProcessList
   global g_ScriptTitle
   global prefs_IncludeProgramTitles
   global prefs_ExcludeProgramTitles
   global prefs_IncludeProgramExecutables
   global prefs_ExcludeProgramExecutables
   global prefs_HelperWindowProgramTitles
   global prefs_HelperWindowProgramExecutables
   
   Menu_InProcessList := true
   Menu_TitleType := TitleType
   If (GetExe =1)
   {
      WinGet, id, list,,, Program Manager
      Loop, %id%
      {
         tmptitle=
         tmpid := id%A_Index%
         WinGet, tmptitle, ProcessName, ahk_id %tmpid%
         If (tmptitle <> "")
            RunningList .= tmptitle "|"
      }
   } Else If (GetExe = 0) ; get list of active window titles
   {
      WinGet, id, list,,, Program Manager
      Loop, %id%
      {
         tmptitle=
         tmpid := id%A_Index%
         WinGetTitle, tmptitle, ahk_id %tmpid%
         If (tmptitle <> "")
            RunningList .= tmptitle "|"
      }
   }	
   GetExe=0
   
   GuiControlGet, MenuTitleList, MenuGui: , %Menu_TitleType%
	
   Sort,RunningList, D| U	
   Gui, ProcessList:+OwnerMenuGui
   Gui, ProcessList:+Owner
   Gui, MenuGui:+Disabled  ; disable main window
   Gui, ProcessList:Add, Text,x10 y10, Select program:
   Gui, ProcessList:Add, DDL, x110 y10 w250 R10 gToEdit,%RunningList%
   Gui, ProcessList:Add, Text,x10 y40, Edit:
   Gui, ProcessList:Add, Edit, x110 y40 w250
   Gui, ProcessList:Add, Button, xp+260 yp gAddNew1 w40 Default, Add
   Gui, ProcessList:Add, Text, x10 yp+40, Current list:
   Gui, ProcessList:Add, ListBox, x110 yp w250 r10, %MenuTitleList%
   Gui, ProcessList:Add, Button, xp+260 yp gRemoveNew1 w40 , Del
   Gui, ProcessList:Add, Text, x10 yp+170, a) Select a program or window from the list or type a name in the`n%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%'Edit' control (you may need to edit it further)`nb) Click ADD to add it to the list`nc) To remove a program/title, select an item from the 'current list' and`n%A_Space%%A_Space%%A_Space%%A_Space%click DEL.
   Gui, ProcessList:Add, Button, x10 yp+90 w190 gSaveTitleList, Save 
   Gui, ProcessList:Add, Button, xp+210 yp w190 gCancelTitle, Cancel
   Gui, ProcessList:Show, w420 h380, %g_ScriptTitle% Settings
   Return
}

VisitForum:
MsgBox , 36 , Visit %g_ScriptTitle% forum (www.autohotkey.com), Do you want to visit the %g_ScriptTitle% forum on www.autohotkey.com?
IfMsgBox, Yes
	Run, http://www.autohotkey.com/board/topic/49517-ahk-11typingaid-v2198-word-autocompletion-utility/
Return

Restore:
MsgBox, 1, Restore Defaults, This will restore all settings to default. Continue?
IfMsgBox, Cancel
   return
RestoreDefaults()
gosub, Cancel
return

RestoreDefaults()
{
   global g_PrefsFile
   global g_ScriptTitle
   global Menu_OldLearnCount
   global prefs_LearnCount

   ReadPreferences("RestoreDefaults")

   IF ( Menu_OldLearnCount < prefs_LearnCount )
   {
      MsgBox, 1, Restore Defaults, Restoring Defaults will increase the Learn Count value.`r`nWhen exiting %g_ScriptTitle%, this will permanently delete any words`r`nfrom the Learned Words which have been typed less times`r`nthan the new Learn Count. Continue?
      IfMsgBox, Cancel
      {
         ReturnValue := "Cancel"
      }
   }
   
   if (ReturnValue == "Cancel")
   {
      ReadPreferences(,"RestorePreferences")
      return
   } else {
      
      IfExist, %g_PrefsFile%
      {
         try {
            FileCopy, %g_PrefsFile%, %PrefsFile%-%A_Now%.bak, 1
            FileDelete, %g_PrefsFile%
         } catch {
            MsgBox,,Restore Defaults,Unable to back up preferences! Canceling...
            ReadPreferences(,"RestorePreferences")
            return
         }
      }
      
      ApplyChanges()
      MsgBox,,Restore Defaults, Defaults have been restored.
   }
   
   return
}

MenuGuiGuiEscape:
MenuGuiGuiClose:
CancelButton:
if (Menu_ValueChanged == true)
{
   MsgBox, 4, Cancel, Changes will not be saved. Cancel anyway?
   IfMsgBox, Yes
   {
      gosub, Cancel
   }
} else {
   gosub, Cancel
}
return

Cancel:
Gui, MenuGui:Destroy
; Clear WM_SETCURSOR action
OnMessage(g_WM_SETCURSOR, "")
; Clear WM_MOUSEMOVE action
OnMessage(g_WM_MOUSEMOVE, "")
;Clear mouse flags
HandleSettingsMessage("", "", "", "")
g_InSettings := false
Menu, Tray, Enable, Settings
GetIncludedActiveWindow()
Return

Save:
Save()
return

Save()
{
   global prefs_LearnCount, prefs_ListBoxOpacity
   global Menu_ChangedPrefs, Menu_ListBoxOpacityUpDown, Menu_OldLearnCount
   global g_ScriptTitle
   ; should only save preferences.ini if different from defaults
   Menu_ChangedPrefs["prefs_ArrowKeyMethod"] := prefs_ArrowKeyMethod
   Menu_ChangedPrefs["prefs_DisabledAutoCompleteKeys"] := prefs_DisabledAutoCompleteKeys
   Menu_ChangedPrefs["prefs_NoBackSpace"] := prefs_NoBackSpace
   Menu_ChangedPrefs["prefs_SendMethod"] := prefs_SendMethod
   Gui, MenuGui:Submit
   prefs_ListBoxOpacity := Menu_ListBoxOpacityUpDown
   
   IF (Menu_OldLearnCount < prefs_LearnCount )
   {   
      MsgBox, 1, Save, Saving will increase the Learn Count value.`r`nWhen exiting %g_ScriptTitle%, this will permanently delete any words`r`nfrom the Learned Words which have been typed less times`r`nthan the new Learn Count. Continue?
      IfMsgBox, Cancel
      {
         ReturnValue := "Cancel"
      }
   }
   
   If ( ReturnValue == "Cancel" )
   {
      ReadPreferences(,"RestorePreferences")
   } else {
      SaveSettings()
      ApplyChanges()
   }
   gosub, Cancel
   Return
}

SaveSettings()
{
   Global
   
   Local Menu_PrefsToSave
   Local Split
   Local Split0
   Local Split1

   Local key
   Local value
   
   Menu_PrefsToSave := Object()
  
   Loop, parse, Menu_SendMethodOptionsCode, | ; get sendmethod
   {
      If (Menu_SendMethodC = A_Index)
         prefs_SendMethod:=A_LoopField
   }
   
   prefs_DisabledAutoCompleteKeys=
   If (Menu_CtrlEnter = 0)
      prefs_DisabledAutoCompleteKeys .= "E"
   If (Menu_Tab = 0)
      prefs_DisabledAutoCompleteKeys .= "T"
   If (Menu_CtrlSpace = 0)
      prefs_DisabledAutoCompleteKeys .= "S"
   If (Menu_RightArrow = 0)
      prefs_DisabledAutoCompleteKeys .= "R"
   If (Menu_NumberKeys = 0)
      prefs_DisabledAutoCompleteKeys .= "N"
   If (Menu_Enter = 0)
      prefs_DisabledAutoCompleteKeys .= "U"
   If (Menu_SingleClick = 0)
      prefs_DisabledAutoCompleteKeys .= "L"

   Loop, parse, Menu_ArrowKeyMethodOptionsText, |
   {
      StringSplit, Split, A_LoopField, -
      Split1 := Trim(Split1)
      If (prefs_ArrowKeyMethod = A_Index)
      {
         prefs_ArrowKeyMethod := Split1
      }   
   }

   If (Menu_CaseCorrection = "on")
      prefs_NoBackSpace=Off
   Else If (Menu_CaseCorrection = "off")
      prefs_NoBackSpace=On
   
   ; Determine list of preferences to save
   For key, value in Menu_ChangedPrefs
   {
      IF (%key% <> value)
      {
         Menu_PrefsToSave.Insert(key)
      }
   }

   SavePreferences(Menu_PrefsToSave)
}

ApplyChanges()
{
   ValidatePreferences()
   ParseTerminatingCharacters()
   InitializeHotKeys()
   DestroyListBox()
   InitializeListBox()
   
   Return

}   

EditValue:
Menu_ValueChanged := true
IF (A_GuiControl && !(SubStr(A_GuiControl ,1 ,5) == "Menu_") )
{
   Menu_ChangedPrefs[A_GuiControl] := %A_GuiControl%
}
Return

HelpMe:
HelpMe()
return

HelpMe()
{
   global g_ScriptTitle
   Loop, Parse, %A_GuiControl%,`r`n
   {
      IF ( SubStr(A_LoopField, 1,1) = ";")
      {
         Menu_Help .= SubStr(A_LoopField,2) . "`r`n"
      } else {
         Menu_Help .= A_LoopField . "`r`n"
      }
   }
   MsgBox , 32 , %g_ScriptTitle% Help, %Menu_Help%
   return
}
   
; derived from work by shimanov, 2005
; http://www.autohotkey.com/forum/viewtopic.php?p=37696#37696
HandleSettingsMessage( p_w, p_l, p_m, p_hw )
{
   Global g_WM_SETCURSOR, g_WM_MOUSEMOVE, g_cursor_hand
   Static Help_Hover, h_cursor_help, URL_Hover, h_old_cursor, Old_GuiControl
   
   ; pass in all blanks to clear flags
   if ((!p_w) && (!p_l) && (!p_m) && (!p_hw)) {
      Help_Hover =
      URL_Hover =
      h_old_cursor =
      Old_GuiControl =
   }
   
   if ( p_m = g_WM_SETCURSOR )
   {
      if ( Help_Hover || URL_Hover)
         return, true
   } else if (A_GuiControl == Old_GuiControl)
   {
      return
   } else if ( p_m = g_WM_MOUSEMOVE )
	{
      if (Help_Hover || URL_Hover)
      {
         
			Gui, MenuGui:Font, cGreen     ;;; xyz
			GuiControl, MenuGui:Font, %Old_GuiControl% ;;; xyz
      }
      
      if ( SubStr(A_GuiControl, 1, 9) == "helpinfo_" )
		{
			if !(Help_Hover)
			{
				IF !(h_cursor_help)
				{
					h_cursor_help := DllCall( "LoadImage", ptr, 0, uint, 32651 , uint, 2, int, 0, int, 0, uint, 0x8000 ) 
				}
				old_cursor := DllCall( "SetCursor", "uint", h_cursor_help )
				Help_Hover = true
				URL_Hover = 
				Gui, MenuGui:Font, cBlue        ;;; xyz
				GuiControl, MenuGui:Font, %A_GuiControl% ;;; xyz
			}
		} else if (A_GuiControl == "Menu_VisitForum")
		{	
			if !(URL_Hover)
			{
				old_cursor := DllCall( "SetCursor", "uint", g_cursor_hand )
				URL_Hover = true
				Help_Hover =
				Gui, MenuGui:Font, cBlue        ;;; xyz
				GuiControl, MenuGui:Font, %A_GuiControl% ;;; xyz
			}
				
		} else if (Help_Hover || URL_Hover)
      {
			DllCall( "SetCursor", "uint", h_old_cursor )
			Help_Hover=
			URL_Hover=
			h_old_cursor=
		}
		IF !(h_old_cursor)
		{
			h_old_cursor := old_cursor
      }
      
      Old_GuiControl := A_GuiControl
   }
}

SaveTitleList:
SaveTitleList()
return

SaveTitleList()
{
   global Menu_InProcessList
   global Menu_TitleType
   ControlGet, MenuTitleList, List, , ListBox1
   Menu_InProcessList := false
   Gui, ProcessList:Destroy
   Gui, MenuGui:-Disabled  ; enable main window
   Gui, MenuGui:Show
   StringReplace, MenuTitleList, MenuTitleList, `n, |, All

   GuiControl, MenuGui:Text, %Menu_TitleType%, %MenuTitleList%
   Menu_ChangedPrefs[Menu_TitleType] := %Menu_TitleType%
	
   return
}

ProcessListGuiEscape:
ProcessListGuiClose:
CancelTitle:
Menu_InProcessList := false
Gui, ProcessList:Destroy
Gui, MenuGui:-Disabled ; enable main window
Gui, MenuGui:Show
Return

ToEdit:
ToEdit()
return

ToEdit()
{
   GuiControlGet, MenuOutputVar, ProcessList:,ComboBox1
   GuiControl, ProcessList:, Edit1, 
   GuiControl, ProcessList:, Edit1, %MenuOutputVar%
   ControlFocus, Edit1
   return
}

AddNew1:
AddNew1()
return

AddNew1()
{
   GuiControlGet, MenuOutputVar, ProcessList:,Edit1
   ControlGet, MenuTitleList, List, , ListBox1
   StringReplace, MenuTitleList, MenuTitleList, `n, |, All
   MenuTitleList := "|" . MenuTitleList . "|"
   
   SearchString := "|" . MenuOutputVar . "|"
   
   IfInString, MenuTitleList, |%MenuOutputVar%|
   {
      MsgBox, 16, , Duplicate entry.
      return
   }
   
   GuiControl, ProcessList:, ListBox1, %MenuOutputVar%|
   GuiControl, ProcessList:, Edit1, 
   ControlFocus, Edit1
   return
}

RemoveNew1:
RemoveNew1()
return

RemoveNew1()
{
   GuiControlGet, MenuOutputVar, ProcessList:, Listbox1
   ControlGet, MenuTitleList, List, , ListBox1
   StringReplace, MenuTitleList, MenuTitleList, `n, |, All
   MenuTitleList := "|" . MenuTitleList . "|"
   StringReplace, MenuTitleList, MenuTitleList, |%MenuOutputVar%|, |, all
   StringTrimRight, MenuTitleList, MenuTitleList, 1
   GuiControl, ProcessList:, ListBox1, |
   GuiControl, ProcessList:, ListBox1, %MenuTitleList%
   
   return
}

; copied from font explorer http://www.autohotkey.com/forum/viewtopic.php?t=57501&highlight=font
Writer_enumFonts()
{
   Writer_enumFontsProc(0, 0, 0, 0,"Clear")
   hDC := DllCall("GetDC", "Uint", 0) 
   DllCall("EnumFonts", "Uint", hDC, "Uint", 0, "Uint", RegisterCallback("Writer_enumFontsProc", "F"), "Uint", 0) 
   DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
	
   return Writer_enumFontsProc(0, 0, 0, 0, "ReturnS")
}

Writer_enumFontsProc(lplf, lptm, dwType, lpData, Action = 0)
{
   static s
   
   ifEqual, Action, Clear
   {
      s=
      return
   }
	
   ifEqual, Action, ReturnS, return s

   s .= DllCall("MulDiv", "Int", lplf+28, "Int",1, "Int", 1, "str") "|"
   return 1
}