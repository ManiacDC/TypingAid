; GUI for TypingAid 2.15 configuration
; by HugoV / Maniac

LaunchSettings:
Menu, Tray, Disable, Settings
InSettings := true
ClearAllVars(True)
Menu_RestartValues := LearnCount . DelimiterChar . LearnLength . DelimiterChar . LearnMode
Menu_ChangedPrefs := Object()
ConstructGui()
Return

ConstructGui()
{
   Global ArrowKeyMethod, AutoSpace, DetectMouseClickMove, DisabledAutoCompleteKeys
   Global hArrowKeyMethod, hAutoSpace, hDetectMouseClickMove, hDisabledAutoCompleteKeys
   Global ForceNewWordCharacters, LearnCount, LearnLength, LearnMode, Length
   Global hForceNewWordCharacters, hLearnCount, hLearnLength, hLearnMode, hLength
   Global NoBackSpace, SendMethod, TerminatingCharacters
   Global hNoBackSpace, hSendMethod, hTerminatingCharacters
   Global ExcludeProgramExecutables, ExcludeProgramTitles, IncludeProgramExecutables, IncludeProgramTitles, HelperWindowProgramExecutables, HelperWindowProgramTitles
   Global hExcludeProgramExecutables, hExcludeProgramTitles, hIncludeProgramExecutables, hIncludeProgramTitles, hHelperWindowProgramExecutables, hHelperWindowProgramTitles
   Global ListBoxCharacterWidth, ListBoxFontFixed, ListBoxFontOverride, ListBoxFontSize, ListBoxOffset, ListBoxOpacity, ListBoxRows
   Global hListBoxCharacterWidth, hListBoxFontFixed, hListBoxFontOverride, hListBoxFontSize, hListBoxOffset, hListBoxOpacity, hListBoxRows
   Global Menu_LearnCount, Menu_LearnLength, Menu_LearnMode
   Global Menu_ArrowKeyMethodOptionsText, Menu_CaseCorrection, Menu_ListBoxOpacityUpDown, Menu_SendMethodOptionsCode, Menu_SendMethodC
   Global Menu_CtrlEnter, Menu_CtrlSpace, Menu_Enter, Menu_NumberKeys, Menu_RightArrow, Menu_Tab
   Global MenuAdvGuiHeight, MenuGuiWidth
   Global Length
   Global WM_SETCURSOR, WM_MOUSEMOVE
   
   Menu_CaseCorrection=
   Menu_ArrowKeyMethodOptionsText=
   
   MenuFontList:=Writer_enumFonts() ; see note at function for credit
 
   ; Call "HandleMessage" when script receives WM_SETCURSOR message
   WM_SETCURSOR = 0x20
   OnMessage( WM_SETCURSOR, "HandleMessage" )

   ; Call "HandleMessage" when script receives WM_MOUSEMOVE message
   WM_MOUSEMOVE = 0x200
   OnMessage( WM_MOUSEMOVE, "HandleMessage" )

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
	
   MenuAdvancedSettingsTextHeight = 15
   MenuAdvGuiHeight := MenuGuiHeight + MenuAdvancedSettingsTextHeight + MenuSeparatorY + ( 2 * ( MenuSeparatorY + MenuRowHeight) )

   MenuTextMenuRowY := (MenuRowHeight - 6 ) / 3

   MenuTabWidth:=MenuGuiWidth-4
   MenuTabHeight:=MenuGuiHeight-75
   MenuTabHeightEdit:=MenuTabHeight-40

   MenuOneColGroupWidth := MenuGuiWidth - (2 * MenuSeparatorX)
   MenuTwoColGroupWidth := (MenuGuiWidth - (3 * MenuSeparatorX))/2
   MenuThreeColGroupWidth := (MenuGuiWidth - (4 * MenuSeparatorX))/3

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

   Gui, Font, s8, Arial

   Gui, MenuGui:Add, Tab2, x2 w%MenuTabWidth% h%MenuTabHeight%, General Settings|Wordlist Box|Programs|Advanced (Experts Only)|About && Help

   Gui, MenuGui:Tab, 1 ; General Settings

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Learn new words as you type*
   Menu_LearnModeOptions=|On|Off|
   StringReplace, Menu_LearnModeOptions, Menu_LearnModeOptions, |%LearnMode%|,|%LearnMode%||
   StringTrimLeft, Menu_LearnModeOptions, Menu_LearnModeOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup1EditX% y%MenuRowEditY% r5 vMenu_LearnMode gEditValue, %Menu_LearnModeOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of3HelpX% y%MenuRowHelpY% vhLearnMode gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack


   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Minimum length of word to learn*
   Menu_LearnLengthOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
   StringReplace,  Menu_LearnLengthOptions, Menu_LearnLengthOptions, |%LearnLength%|,|%LearnLength%||
   StringTrimLeft, Menu_LearnLengthOptions, Menu_LearnLengthOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of3EditX% y%MenuRowEditY% r5 vMenu_LearnLength gEditValue, %Menu_LearnLengthOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of3HelpX% y%MenuRowHelpY% vhLearnLength gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack
   

   Gui, MenuGui:Add, GroupBox, x%MenuGroup3of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight%, Add to wordlist after X times*
   Menu_LearnCountOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
   StringReplace,  Menu_LearnCountOptions, Menu_LearnCountOptions, |%LearnCount%|,|%LearnCount%||
   StringTrimLeft, Menu_LearnCountOptions, Menu_LearnCountOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup3of3EditX% y%MenuRowEditY% r5 vMenu_LearnCount gEditValue, %Menu_LearnCountOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup3of3HelpX% y%MenuRowHelpY% vhLearnCount gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack


   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Maximum number of results to show
   Menu_ListBoxRowsOptions=|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|
   StringReplace,  Menu_ListBoxRowsOptions, Menu_ListBoxRowsOptions, |%ListBoxRows%|,|%ListBoxRows%||
   StringTrimLeft, Menu_ListBoxRowsOptions, Menu_ListBoxRowsOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup1EditX% y%MenuRowEditY% r5 vListBoxRows gEditValue, %Menu_ListBoxRowsOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of3HelpX% y%MenuRowHelpY% vhListBoxRows gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Show wordlist after X characters
   Menu_LengthOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
   StringReplace,  Menu_LengthOptions, Menu_LengthOptions, |%Length%|,|%Length%||
   StringTrimLeft, Menu_LengthOptions, Menu_LengthOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of3EditX% y%MenuRowEditY% r5 vLength gEditValue, %Menu_LengthOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of3HelpX% y%MenuRowHelpY% vhLength gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack


   Gui, MenuGui:Add, GroupBox, x%MenuGroup3of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Send Method
   Menu_SendMethodOptionsText=1 - Default (Type)|2 - Fast (Type)|3 - Slow (Type)|4 - Default (Paste)|5 - Fast (Paste)|6 - Slow (Paste)|7 - Alternate method
   Menu_SendMethodOptionsCode=1|2|3|1C|2C|3C|4C
   Loop, parse, Menu_SendMethodOptionsCode, |
   {
	  If (SendMethod = A_LoopField)
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
   Gui, MenuGui:Add, Text, x%MenuGroup3of3HelpX% y%MenuRowHelpY% vhSendMethod gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack
   

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuTwoColGroupWidth% h%MenuRowHeight% , Auto Complete Keys
   ;  E = Ctrl + Enter
   ;  S = Ctrl + Space
   ;  T = Tab
   ;  R = Right Arrow
   ;  N = Number Keys
   ;  U = Enter
   Menu_CheckedE=Checked
   Menu_CheckedS=Checked
   Menu_CheckedT=Checked
   Menu_CheckedR=Checked
   Menu_CheckedN=Checked
   Menu_CheckedU=Checked
   Loop, parse, DisabledAutoCompleteKeys
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
   }

   MenuCheckmarkIndent := MenuTwoColEditWidth/3 + MenuEditIndentX
   Gui, MenuGui:Add, Checkbox, x%MenuGroup1EditX% yp+%MenuTextMenuRowY% vMenu_CtrlEnter gEditValue %Menu_CheckedE%, Ctrl + Enter
   Gui, MenuGui:Add, Checkbox, xp%MenuCheckmarkIndent% yp vMenu_Tab gEditValue %Menu_CheckedT%, Tab
   Gui, MenuGui:Add, Checkbox, xp%MenuCheckmarkIndent% yp vMenu_RightArrow gEditValue %Menu_CheckedR%, Right Arrow
   Gui, MenuGui:Add, Checkbox, x%MenuGroup1EditX% yp+%MenuTextMenuRowY% vMenu_CtrlSpace gEditValue %Menu_CheckedS%, Ctrl + Space
   Gui, MenuGui:Add, Checkbox, xp%MenuCheckmarkIndent% yp vMenu_NumberKeys gEditValue %Menu_CheckedN%, Number Keys
   Gui, MenuGui:Add, Checkbox, xp%MenuCheckmarkIndent% yp vMenu_Enter gEditValue %Menu_CheckedU%, Enter

   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of2HelpX% y%MenuRowHelpY% vhDisabledAutoCompleteKeys gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack


   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of2BoxX% y%MenuRowY% w%MenuTwoColGroupWidth% h%MenuRowHeight% , Wordlist row highlighting
   Menu_ArrowKeyMethodOptionsText=Off - only use the number keys|First - reset selected word to the beginning|LastWord - keep last word selected|LastPosition - keep the last cursor position
   Loop, parse, Menu_ArrowKeyMethodOptionsText, |
   {
	  Menu_ArrowKeyMethodOptions .= A_LoopField "|"
	  StringSplit, Split, A_LoopField, -
      Split1 := Trim(Split1)
	  If (Split1 = ArrowKeyMethod)
	  {
		 Menu_ArrowKeyMethodOptions .= "|"
	  }   
   }

   Gui, MenuGui:Add, DDL, x%MenuGroup2of2EditX% y%MenuRowEditY% w%MenuTwoColEditWidth% r5 vArrowKeyMethod gEditValue altsubmit, %Menu_ArrowKeyMethodOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of2HelpX% y%MenuRowHelpY% vhArrowKeyMethod gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack


   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Case correction
   Menu_CaseCorrectionOptions=|On|Off|
   If (NoBackSpace = "on")
	  Menu_CaseCorrection=Off
   Else If (NoBackSpace = "off")
	  Menu_CaseCorrection=On
   StringReplace,  Menu_CaseCorrectionOptions, Menu_CaseCorrectionOptions, |%Menu_CaseCorrection%|,|%Menu_CaseCorrection%||
   StringTrimLeft, Menu_CaseCorrectionOptions, Menu_CaseCorrectionOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup1EditX% y%MenuRowEditY% r5 vMenu_CaseCorrection gEditValue, %Menu_CaseCorrectionOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of3HelpX% y%MenuRowHelpY% vhNoBackSpace gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack


   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Monitor mouse clicks 
   Menu_DetectMouseClickMoveOptions=|On|Off|
   StringReplace,  Menu_DetectMouseClickMoveOptions, Menu_DetectMouseClickMoveOptions, |%DetectMouseClickMove%|,|%DetectMouseClickMove%||
   StringTrimLeft, Menu_DetectMouseClickMoveOptions, Menu_DetectMouseClickMoveOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of3EditX% y%MenuRowEditY% r5 vDetectMouseClickMove gEditValue, %Menu_DetectMouseClickMoveOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of3HelpX% y%MenuRowHelpY% vhDetectMouseClickMove gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup3of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Type space after autcomplete
   Menu_AutoSpaceOptions=|On|Off|
   StringReplace,  Menu_AutoSpaceOptions, Menu_AutoSpaceOptions, |%AutoSpace%|,|%AutoSpace%||
   StringTrimLeft, Menu_AutoSpaceOptions, Menu_AutoSpaceOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup3of3EditX% y%MenuRowEditY% r5 vAutoSpace gEditValue, %Menu_AutoSpaceOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup3of3HelpX% y%MenuRowHelpY% vhAutoSpace gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   ;NumPresses
   ;
   
   MenuRowY := MenuTabHeight-20
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, Text, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% , *Changing these values requires a restart of TypingAid
   

   Gui, MenuGui:Tab, 2 ; listbox ---------------------------------------------------------


   MenuRowY := MenuSeparatorY + 30
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY


   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , List appears X pixels below cursor
   Menu_ListBoxOffsetOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
   StringReplace,  Menu_ListBoxOffsetOptions, Menu_ListBoxOffsetOptions, |%ListBoxOffset%|,|%ListBoxOffset%||
   StringTrimLeft, Menu_ListBoxOffsetOptions, Menu_ListBoxOffsetOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup1EditX% y%MenuRowEditY% r5 vListBoxOffset gEditValue, %Menu_ListBoxOffsetOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of3HelpX% y%MenuRowHelpY% vhListBoxOffset gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Fixed width font in list
   Menu_ListBoxFontFixedOptions=|On|Off|
   StringReplace,  Menu_ListBoxFontFixedOptions, Menu_ListBoxFontFixedOptions, |%ListBoxFontFixed%|,|%ListBoxFontFixed%||
   StringTrimLeft, Menu_ListBoxFontFixedOptions, Menu_ListBoxFontFixedOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of3EditX% y%MenuRowEditY% r5 vListBoxFontFixed gEditValue, %Menu_ListBoxFontFixedOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of3HelpX% y%MenuRowHelpY% vhListBoxFontFixed gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup3of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , Font size in list
   Menu_ListBoxFontSizeOptions=|8|9|10|11|12|13|14|15|16|17|18|19|20|
   StringReplace,  Menu_ListBoxFontSizeOptions, Menu_ListBoxFontSizeOptions, |%ListBoxFontSize%|,|%ListBoxFontSize%||
   StringTrimLeft, Menu_ListBoxFontSizeOptions, Menu_ListBoxFontSizeOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup3of3EditX% y%MenuRowEditY% r5 vListBoxFontSize gEditValue, %Menu_ListBoxFontSizeOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup3of3HelpX% y%MenuRowHelpY% vhListBoxFontSize gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY


   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , List opacity
   Gui, MenuGui:Add, Edit, xp+10 yp+20 w%MenuThreeColEditWidth% vListBoxOpacity gEditValue, %ListBoxOpacity%
   Gui, MenuGui:Add, UpDown, xp+10 yp+20 w%MenuThreeColEditWidth% vMenu_ListBoxOpacityUpDown Range0-255, %ListBoxOpacity%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of3HelpX% y%MenuRowHelpY% vhListBoxOpacity gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup2of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , List character width override
   Menu_ListBoxCharacterWidthOptions=||5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|
   StringReplace,  Menu_ListBoxCharacterWidthOptions, Menu_ListBoxCharacterWidthOptions, |%ListBoxCharacterWidth%|,|%ListBoxCharacterWidth%||
   StringTrimLeft, Menu_ListBoxCharacterWidthOptions, Menu_ListBoxCharacterWidthOptions, 1
   Gui, MenuGui:Add, DDL, x%MenuGroup2of3EditX% y%MenuRowEditY% r5 vListBoxCharacterWidth gEditValue, %Menu_ListBoxCharacterWidthOptions%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup2of3HelpX% y%MenuRowHelpY% vhListBoxCharacterWidth gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   Gui, MenuGui:Add, GroupBox, x%MenuGroup3of3BoxX% y%MenuRowY% w%MenuThreeColGroupWidth% h%MenuRowHeight% , List font
   MenuFontList := "|" . MenuFontList . "|"
   sort, MenuFontList, D|
   If (MenuListBoxFont = "") or (MenuListBoxFont = " ")
	  StringReplace, MenuFontList, MenuFontList, |%ListBoxFontOverride%|, |%ListBoxFontOverride%||
   Gui, MenuGui:Add, DDL, x%MenuGroup3of3EditX% y%MenuRowEditY% r10 w200 vListBoxFontOverride gEditValue, %MenuFontList%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup3of3HelpX% y%MenuRowHelpY% vhListBoxFontOverride gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY


   Gui, MenuGui:Tab, 3 ; Programs ---------------------------------------------------------


   MenuRowY := MenuSeparatorY + 30
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Window titles you want TypingAid enabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% vIncludeProgramTitles gEditValue, %IncludeProgramTitles%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetEnableTitles, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhIncludeProgramTitles gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack
   
   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Window titles you want TypingAid disabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% vExcludeProgramTitles gEditValue, %ExcludeProgramTitles%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetDisableTitles, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhExcludeProgramTitles gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Processes you want TypingAid enabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% vIncludeProgramExecutables gEditValue, %IncludeProgramExecutables%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetEnableProcess, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhIncludeProgramExecutables gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Processes you want TypingAid disabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% vExcludeProgramExecutables gEditValue, %ExcludeProgramExecutables%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetDisableProcess, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhExcludeProgramExecutables gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   ;HelperWindowProgramTitles

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Window titles you want the helper window enabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% vHelperWindowProgramTitles gEditValue, %HelperWindowProgramTitles%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetHelpTitles, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhHelperWindowProgramTitles gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   ;HelperWindowProgramExecutables

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Processes you want the helper window enabled for
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidthEdit% vHelperWindowProgramExecutables gEditValue, %HelperWindowProgramExecutables%
   Gui, MenuGui:Add, Button, x%MenuOneColEditButton% yp w130 gSetHelpProcess, Edit
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhHelperWindowProgramExecutables gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack



   Gui, MenuGui:Tab, 4 ; advanced  -------------------------------------------------------------------------

   MenuRowY := MenuSeparatorY + 30
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Terminating Characters (see http://www.autohotkey.com/docs/KeyList.htm)
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidth% vTerminatingCharacters gEditValue, %TerminatingCharacters%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhTerminatingCharacters gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack

   MenuRowY := MenuRowY + MenuRowHeight + MenuSeparatorY
   MenuRowEditY := MenuRowY + MenuEditIndentY
   MenuRowHelpY := MenuRowY - MenuHelpIndentY

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuRowHeight% , Force New Word Characters (comma separated)
   Gui, MenuGui:Add, Edit, x%MenuGroup1EditX% y%MenuRowEditY% w%MenuOneColEditWidth% vForceNewWordCharacters gEditValue, %ForceNewWordCharacters%
   Gui, MenuGui:Font, cGreen
   Gui, MenuGui:Add, Text, x%MenuGroup1of1HelpX% y%MenuRowHelpY% vhForceNewWordCharacters gHelpMe, %MenuGuiHelpIcon%
   Gui, MenuGui:Font, cBlack



   Gui, MenuGui:Tab, 5 ; about & help --------------------------------------------

   MenuRowY := MenuSeparatorY + 30
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY

   hIntro=
   (
TypingAid is a simple, compact, and handy auto-completion utility.

It is customizable enough to be useful for regular typing and for programming.

Features:
As you type your word, up to 10 (or as defined in the Preferences file) matches will appear in a drop-down dialog, numbered 1 - 0 (10th). To choose the match you want just hit the associated number on your keyboard (numpad does not work). Alternatively you can select an item from the drop-down using the Up/Down arrows. You can define a fixed position for the drop-down dialog to appear by hitting Ctrl-Shift-H to open a small helper window, or by specifying a list of programs in the preferences file. Please note that in Firefox, Thunderbird, and certain other programs you will probably need to open the helper window due to issues detecting the caret position.

Words should be stored in a file named 'Wordlist.txt' which should be located in the script directory. These words may be commented out by prefixing with a semicolon or simply removed or added. Words may include terminating characters (such as space), but you must select the word before typing the terminating character.

In addition to being able to use the number keys to select a word, you can select words from the drop-down via the Up/Down arrows. Hitting Up on the first item will bring you to the last and hitting Down on the last item will bring you to the first. Hitting Page Up will bring you up 10 items, or to the first item. Hitting Page Down will bring you down 10 items, or to the last item. You can hit Tab, Right Arrow, Ctrl-Space, or Ctrl-Enter to autocomplete the selected word. This feature can be disabled or have some of its behavior modified via the Preferences file.

The script will learn words as you type them if LearnMode=On in the preferences file. If you type a word more than 5 times (or as defined in the preferences.ini file) in a single session the word will be permanently added to the list of learnedd words. Learned words will always appear below predefined words, but will be ranked and ordered among other learned words based on the frequency you type them. You can permanently learn a word by highlighting a word and hitting Ctrl-Shift-C (this works even if LearnMode=Off). You may use Ctrl-Shift-Del to remove the currently selected Learned Word.
Learned words are stored in the WordlistLearned.db sqlite3 database. Learned words are backed up in WordlistLearned.txt. To modify the list of Learned words manually, delete the WordlistLearned.db database, then manually edit the WordlistLearned.txt file. On the next launch of the script, the WordlistLearned.db database will be rebuilt.

The script will automatically create a file named preferences.ini in the script directory. This file allows for customization of the script.
To allow for distribution of standardized preferences, a Defaults.ini may be distributed with the same format as Preferences.ini. If the Defaults.ini is present, Preferences.ini will not be created. A user may override the Defaults.ini by manually creating a Preferences.ini.

Customizable features include (see also detailed description below)

   * List of programs for which you want TypingAid enabled.
   * List of programs for which you do not want TypingAid enabled.
   * Number of characters before the list of words appears.
   * Number of times you must press a number hotkey to select the associated word (options are 1 and 2, 2 has had minimal testing).
   * Enable or disable learning mode.
   * Number of times you must type a word before it is permanently learned.
   * Number of characters a word needs to have in order to be learned.
   * List of strings which will prevent any word which contains one of these strings from being learned.
   * Enable, disable, or customize the arrow key's functionality.
   * Disable certain keys for autocompleting a word selected via the arrow keys.
   * Enable or disable the resetting of the List Box on a mouseclick.
   * Change whether the script simply completes or actually replaces the word (capitalization change based on the wordlist file)
   * Change whether a space should be automatically added after the autocompleted word or not.
   * Change whether the typed word should appear in the word list or not.
   * Change the method used to send the word to the screen.
   * List of characters which terminate a word.
   * List of characters which terminate a word and start a new word.
   * List of programs for which you want the Helper Window to automatically open.
   * Number of pixels below the caret to display the List Box.
   * List Box Default Font of fixed (Courier New) or variable (Tahoma) width.
   * List Box Default Font override.
   * List Box Font Size.
   * List Box Character Width to override the computed character width.
   * List Box Opacity setting to set the transparency of the List Box.
   * List Box Rows to define the number of items to show in the list at once.

Unicode Support:
Full (untested) for UTF-8 character set.
   )
   
   hHelpText = %hIntro%`r`n`r`n%hIncludeProgramExecutables%`r`n`r`n%hIncludeProgramTitles%`r`n`r`n%hExcludeProgramExecutables%`r`n`r`n%hExcludeProgramTitles%`r`n`r`n%hLength%`r`n`r`n%hNumPresses%`r`n`r`n%hLearnMode%`r`n`r`n%hLearnCount%`r`n`r`n%hLearnLength%`r`n`r`n%hArrowKeyMethod%`r`n`r`n%hDisabledAutoCompleteKeys%`r`n`r`n%hDetectMouseClickMove%`r`n`r`n%hNoBackSpace%`r`n`r`n%hAutoSpace%`r`n`r`n%hSendMethod%`r`n`r`n%hTerminatingCharacters%`r`n`r`n%hForceNewWordCharacters%`r`n`r`n%hListBoxOffset%`r`n`r`n%hListBoxFontFixed%`r`n`r`n%hListBoxFontOverride%`r`n`r`n%hListBoxFontSize%`r`n`r`n%hListBoxCharacterWidth%`r`n`r`n%hListBoxOpacity%`r`n`r`n%hListBoxRows%`r`n`r`n%hHelperWindowProgramExecutables%`r`n`r`n%hHelperWindowProgramTitles%

   Loop, Parse, hHelpText,`n, `r
   {
	  IF ( SubStr(A_LoopField, 1,1) = ";")
	  {
		 hModHelpText .= SubStr(A_LoopField,2) . "`r`n"
	  } else
	  {
		 hModHelpText .= A_LoopField . "`r`n"
	  }
   }

   Gui, MenuGui:Add, Edit, ReadOnly x%MenuGroup1BoxX% y%MenuRowY% w%MenuOneColGroupWidth% h%MenuTabHeightEdit%, %hModHelpText%

   hModHelpText =
   hHelpText =
   hIntro =

   Gui, MenuGui:tab, 

   MenuRowY := MenuTabHeight+15
   MenuRowHelpY := MenuRowY - MenuHelpIndentY
   MenuRowEditY := MenuRowY + MenuEditIndentY
   MenuRowThreeButtonWidth := (MenuTwoColGroupWidth - (4 * MenuEditIndentX))/3
   MenuRowThreeButtonNext := MenuEditIndentX + MenuRowThreeButtonWidth

   Gui, MenuGui:Add, GroupBox, x%MenuGroup1BoxX%           y%MenuRowY%     w%MenuTwoColGroupWidth% h50 , Configuration
   Gui, MenuGui:Add, Button,   x%MenuGroup1EditX%          y%MenuRowEditY% w%MenuRowThreeButtonWidth%    gSave   , Save && Exit
   Gui, MenuGui:Add, Button,   xp+%MenuRowThreeButtonNext% yp          w%MenuRowThreeButtonWidth%    gRestore, Restore default
   Gui, MenuGui:Add, Button,   xp+%MenuRowThreeButtonNext% yp          w%MenuRowThreeButtonWidth%    gCancel , Cancel

   Gui, MenuGui:Font, cBlack bold
   Gui, MenuGui:Add, Text, x%MenuGroup2of2EditX% Yp-10 gVisitForum, TypingAid
   Gui, MenuGui:Font, cBlack normal

   Gui, MenuGui:Add, Text, xp+60 Yp gVisitForum, is free software, support forum at
   Gui, MenuGui:Font, cGreen 
   Gui, MenuGui:Add, Text, x%MenuGroup2of2EditX% Yp+%MenuTextMenuRowY% gVisitForum, www.autohotkey.com (click here)
   Gui, MenuGui:Font, cBlack 
   
   Gui, Menugui:+OwnDialogs
   Gui, MenuGui:Show, h%MenuGuiHeight% w%MenuGuiWidth%, TypingAid Settings
   Return
}

SetEnableTitles:
GetList("IncludeProgramTitles",0,IncludeProgramTitles)
Return

SetDisableTitles:
GetList("ExcludeProgramTitles",0,ExcludeProgramTitles)
Return

SetEnableProcess:
GetList("IncludeProgramExecutables",1,IncludeProgramExecutables)
Return

SetDisableProcess:
GetList("ExcludeProgramExecutables",1,ExcludeProgramExecutables)
Return

SetHelpTitles:
GetList("HelperWindowProgramTitles",0,HelperWindowProgramTitles)
Return

SetHelpProcess:
GetList("HelperWindowProgramExecutables",1,HelperWindowProgramExecutables)
Return

GetList(TitleType,GetExe, ByRef ActiveList)
{
   global MenuTitleType
   global InProcessList
   InProcessList := true
   MenuTitleType := TitleType
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
   Gui, ProcessList:Add, ListBox, x110 yp w250 r10, %ActiveList%
   Gui, ProcessList:Add, Button, xp+260 yp gRemoveNew1 w40 , Del
   Gui, ProcessList:Add, Text, x10 yp+170, a) Select a program or window from the list or type a name in the`n%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%'Edit' control (you may need to edit it further)`nb) Click ADD to add it to the list`nc) To remove a program/title, select an item from the 'current list' and`n%A_Space%%A_Space%%A_Space%%A_Space%click DEL.
   Gui, ProcessList:Add, Button, x10 yp+90 w190 gSaveTitleList, Save 
   Gui, ProcessList:Add, Button, xp+210 yp w190 gCancelTitle, Cancel
   Gui, ProcessList:Show, w420 h380, TypingAid Settings
   Return
}


Advanced:
WinGetPos, MenuGuiXPos, MenuGuiYPos,,,A
Gui, MenuGui:Show, h%MenuAdvGuiHeight% w%MenuGuiWidth% y%MenuGuiYPos% x%MenuGuiXPos%, New GUI Window
Return

VisitForum:
MsgBox , 36 , Visit TypingAid forum (www.autohotkey.com), Do you want to visit the TypingAid forum on www.autohotkey.com?
IfMsgBox Yes
	Run, http://www.autohotkey.com/board/topic/49517-ahk-11typingaid-v2198-word-autocompletion-utility/
Return

Restore:
; If Learn settings have changed, we need to reload the script. Otherwise, we can just go through the normal save process.
ReadPreferences("RestoreDefaults")
IF (Menu_RestartValues <> (LearnCount . DelimiterChar . LearnLength . DelimiterChar . LearnMode))
{
   MsgBox, 1, Restore Defaults, Restoring Defaults will change Learn settings.`r`nChanging Learn settings requires a script restart. Continue?
   IfMsgBox, Cancel
   {
      ReadPreferences(,"RestorePreferences")
      return
   }
   try {
      FileCopy, %PrefsFile%, %PrefsFile%-%A_Now%.bak, 1
      FileDelete, %PrefsFile%
   } catch {
      MsgBox,,Restore Defaults,Unable to back up preferences! Canceling...
      ReadPreferences(,"RestorePreferences")
      return
   }
   Reload
   return
} else {
      try {
         FileCopy, %PrefsFile%, %PrefsFile%-%A_Now%.bak, 1
         FileDelete, %PrefsFile%
      } catch {
         MsgBox,,Restore Defaults,Unable to back up preferences! Canceling...
         ReadPreferences(,"RestorePreferences")
         return
      }
      Save()
}
return

MenuGuiGuiEscape:
MenuGuiGuiClose:
Cancel:
Gui, MenuGui:Destroy
InSettings := false
Menu, Tray, Enable, Settings
Return

Save:
; should only save preferences.ini if different from defaults
Menu_ChangedPrefs["ArrowKeyMethod"] := ArrowKeyMethod
Menu_ChangedPrefs["DisabledAutoCompleteKeys"] := DisabledAutoCompleteKeys
Menu_ChangedPrefs["NoBackSpace"] := NoBackSpace
Menu_ChangedPrefs["SendMethod"] := SendMethod
Gui, MenuGui:Submit
ListBoxOpacity := Menu_ListBoxOpacityUpDown
IF (Menu_RestartValues <> (Menu_LearnCount . DelimiterChar . Menu_LearnLength . DelimiterChar . Menu_LearnMode))
{   
   MsgBox, 1, Save, Saving will change Learn settings.`r`nChanging Learn settings requires a script restart. Continue?
   IfMsgBox, Cancel
   {
      ReadPreferences(,"RestorePreferences")
      Gui, MenuGui:Destroy
      return
   }
   SaveSettings()
   Reload
} else {
   SaveSettings()
   Save()
}
Gui, MenuGui:Destroy
Return

SaveSettings()
{
   Global
   
   Local Menu_PrefsToSave
   Local Split
   Local key
   Local value
   
   Menu_PrefsToSave := Object()
  
   Loop, parse, Menu_SendMethodOptionsCode, | ; get sendmethod
   {
      If (Menu_SendMethodC = A_Index)
         SendMethod:=A_LoopField
   }
   
   DisabledAutoCompleteKeys=
   If (Menu_CtrlEnter = 0)
      DisabledAutoCompleteKeys .= "E"
   If (Menu_Tab = 0)
      DisabledAutoCompleteKeys .= "T"
   If (Menu_CtrlSpace = 0)
      DisabledAutoCompleteKeys .= "S"
   If (Menu_RightArrow = 0)
      DisabledAutoCompleteKeys .= "R"
   If (Menu_NumberKeys = 0)
      DisabledAutoCompleteKeys .= "N"
   If (Menu_Enter = 0)
      DisabledAutoCompleteKeys .= "U"

   Loop, parse, Menu_ArrowKeyMethodOptionsText, |
   {
      StringSplit, Split, A_LoopField, -
      Split1 := Trim(Split1)
      If (ArrowKeyMethod = A_Index)
      {
         ArrowKeyMethod := Split1
      }   
   }

   If (Menu_CaseCorrection = "on")
      NoBackSpace=Off
   Else If (Menu_CaseCorrection = "off")
      NoBackSpace=On
   
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

Save()
{
   global InSettings
   ValidatePreferences()
   ParseTerminatingCharacters()
   InitializeHotKeys()
   DestroyListBox()
   InitializeListBox()
   
   InSettings := false
   Menu, Tray, Enable, Settings
   Return

}   

EditValue:
IF (A_GuiControl && !(SubStr(A_GuiControl ,1 ,5) == "Menu_") )
{
   Menu_ChangedPrefs[A_GuiControl] := %A_GuiControl%
}
Return

HelpMe:
Loop, Parse, %A_GuiControl%,`r`n
{
	IF ( SubStr(A_LoopField, 1,1) = ";")
	{
		Menu_Help .= SubStr(A_LoopField,2) . "`r`n"
	} else
	{
		Menu_Help .= A_LoopField . "`r`n"
	}
}
MsgBox , 32 , TypingAid Help, %Menu_Help%
Menu_Help=
Return

   
; derived from work by shimanov, 2005
; http://www.autohotkey.com/forum/viewtopic.php?p=37696#37696
HandleMessage( p_w, p_l, p_m, p_hw )
{
	Global WM_SETCURSOR, WM_MOUSEMOVE
	Static Help_Hover, h_cursor_help, URL_Hover, h_cursor_hand, h_old_cursor, Old_GuiControl
   
	if ( p_m = WM_SETCURSOR )
	{
		if ( Help_Hover)
			return, true
	}
	else if ( p_m = WM_MOUSEMOVE )
	{
		if A_GuiControl in hIncludeProgramExecutables,hIncludeProgramTitles,hExcludeProgramExecutables,hExcludeProgramTitles,hLength,hNumPresses,hLearnMode,hLearnCount,hLearnLength,hArrowKeyMethod,hDisabledAutoCompleteKeys,hDetectMouseClickMove,hNoBackSpace,hAutoSpace,hSendMethod,hTerminatingCharacters,hForceNewWordCharacters,hListBoxOffset,hListBoxFontFixed,hListBoxFontOverride,hListBoxFontSize,hListBoxCharacterWidth,hListBoxOpacity,hListBoxRows,hHelperWindowProgramExecutables,hHelperWindowProgramTitles
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
				Gui, Font, cBlue        ;;; xyz
				GuiControl, Font, %A_GuiControl% ;;; xyz
				Old_GuiControl = %A_GuiControl%
			}
		} else if (A_GuiControl = "VisitForum")
		{	
			if !(URLHover)
			{
				IF !(h_cursor_hand)
				{
					h_cursor_hand := DllCall( "LoadImage", ptr, 0, uint, 32649 , uint, 2, int, 0, int, 0, uint, 0x8000 ) 
				}
				old_cursor := DllCall( "SetCursor", "uint", h_cursor_hand )
				URL_Hover = true
				Help_Hover =
				Gui, Font, cBlue        ;;; xyz
				GuiControl, Font, %A_GuiControl% ;;; xyz
				Old_GuiControl = %A_GuiControl%
			}
				
		} else if (Help_Hover || URL_Hover)
		{
			DllCall( "SetCursor", "uint", h_old_cursor )
			Help_Hover=
			URL_Hover=
			Gui, Font, cGreen     ;;; xyz
			GuiControl, Font, %Old_GuiControl% ;;; xyz
			h_old_cursor=
		}
		IF !(h_old_cursor)
		{
			h_old_cursor := old_cursor
		}
	}
}

SaveTitleList:
ControlGet, MenuTitleList, List, , ListBox1
InProcessList := false
Gui, ProcessList:Destroy
Gui, MenuGui:-Disabled  ; enable main window
Gui, MenuGui:Show
StringReplace, MenuTitleList, MenuTitleList, `n, |, All

%MenuTitleType% := MenuTitleList
GuiControl, MenuGui:Text, %MenuTitleType%, % %MenuTitleType%
	
Return

ProcessListGuiEscape:
ProcessListGuiClose:
CancelTitle:
InProcessList := false
Gui, ProcessList:Destroy
Gui, MenuGui:-Disabled ; enable main window
Gui, MenuGui:Show
Return

ToEdit:
GuiControlGet, MenuOutputVar, ProcessList:,ComboBox1
GuiControl, ProcessList:, Edit1, 
GuiControl, ProcessList:, Edit1, %MenuOutputVar%
ControlFocus, Edit1
Return

AddNew1:
GuiControlGet, MenuOutputVar, ProcessList:,Edit1
GuiControl, ProcessList:, ListBox1, %MenuOutputVar%|
GuiControl, ProcessList:, Edit1, 
ControlFocus, Edit1
Return

RemoveNew1:
GuiControlGet, MenuOutputVar, ProcessList:, Listbox1
ControlGet, MenuTitleList, List, , ListBox1
StringReplace, MenuTitleList, MenuTitleList, `n, |, All
MenuTitleList := "|" MenuTitleList "|"
StringReplace, MenuTitleList, MenuTitleList, |%MenuOutputVar%|, |, all
StringTrimRight, MenuTitleList, MenuTitleList, 1
GuiControl, ProcessList:, ListBox1, |
GuiControl, ProcessList:, ListBox1, %MenuTitleList%
Return

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