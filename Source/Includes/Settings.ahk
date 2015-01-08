; GUI for TypingAid 2.15 configuration
; by HugoV / Maniac

LaunchSettings:

ReadPreferences()

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

fontlist:=Writer_enumFonts() ; see note at function for credit


; ---
; The following part was copied from AGU`s script.
; http://www.autohotkey.com/forum/viewtopic.php?p=37633#37633
; Begin
; Retrieve scripts PID
Process, Exist
pid_this := ErrorLevel
 
; Retrieve unique ID number (HWND/handle)
WinGet, hw_gui, ID, ahk_class AutoHotkeyGUI ahk_pid %pid_this%
 
; Call "HandleMessage" when script receives WM_SETCURSOR message
WM_SETCURSOR = 0x20
OnMessage( WM_SETCURSOR, "HandleMessage" )
 
; Call "HandleMessage" when script receives WM_MOUSEMOVE message
WM_MOUSEMOVE = 0x200
OnMessage( WM_MOUSEMOVE, "HandleMessage" )
; End
; ---


GuiWidth=700
GuiHeight=480
GuiRows = 8
GuiHelpIcon = %A_Space%(?)%A_Space%

SeparatorX = 10
SeparatorY = 8
EditIndentX = 10
EditIndentY = 20
HelpIndentX = 30
HelpIndentY = 0

RowHeight := (GuiHeight - ((GuiRows +1 ) * SeparatorY ))/GuiRows

AdvancedSettingsTextHeight = 15
AdvGuiHeight := GuiHeight + AdvancedSettingsTextHeight + SeparatorY + ( 2 * ( SeparatorY + RowHeight) )

TextRowY := (RowHeight - 6 ) / 3

TabWidth:=GuiWidth-4
TabHeight:=GuiHeight-75
TabHeightEdit:=TabHeight-40

OneColGroupWidth := GuiWidth - (2 * SeparatorX)
TwoColGroupWidth := (GuiWidth - (3 * SeparatorX))/2
ThreeColGroupWidth := (GuiWidth - (4 * SeparatorX))/3

OneColEditWidth := OneColGroupWidth - (EditIndentX * 2)
TwoColEditWidth := TwoColGroupWidth - (EditIndentX * 2)
ThreeColEditWidth := ThreeColGroupWidth - (EditIndentX * 2)
OneColEditWidthEdit := OneColEditWidth - 140
OneColEditButton := OneColEditWidthEdit + 30

Group1BoxX := SeparatorX
Group1EditX := Group1BoxX + EditIndentX
Group1of1HelpX := Group1BoxX + OneColGroupWidth - HelpIndentX
Group1of2HelpX := Group1BoxX + TwoColGroupWidth - HelpIndentX
Group1of3HelpX := Group1BoxX + ThreeColGroupWidth - HelpIndentX

Group2of2BoxX := Group1BoxX + TwoColGroupWidth + SeparatorX
Group2of2EditX := Group2of2BoxX + EditIndentX
Group2of2HelpX := Group2of2BoxX + TwoColGroupWidth - HelpIndentX

Group2of3BoxX := Group1BoxX + ThreeColGroupWidth + SeparatorX
Group2of3EditX := Group2of3BoxX + EditIndentX
Group2of3HelpX := Group2of3BoxX + ThreeColGroupWidth - HelpIndentX

Group3of3BoxX := Group2of3BoxX + ThreeColGroupWidth + SeparatorX
Group3of3EditX := Group3of3BoxX + EditIndentX
Group3of3HelpX := Group3of3BoxX + ThreeColGroupWidth - HelpIndentX

RowY := SeparatorY + 30
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

Gui, Font, s8, Arial

Gui, MenuGui:Add, Tab2, x2 w%TabWidth% h%TabHeight%, General Settings|Wordlist Box|Programs|Advanced (Experts Only)|About && Help

Gui, MenuGui:Tab, 1 ; General Settings

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , Learn new words as you type
_LearnModeOptions=|On|Off|
StringReplace, _LearnModeOptions, _LearnModeOptions, |%LearnMode%|,|%LearnMode%||
StringTrimLeft, _LearnModeOptions, _LearnModeOptions, 1
Gui, MenuGui:Add, DDL, x%Group1EditX% y%RowEditY% r5 vLearnMode, %_LearnModeOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of3HelpX% y%RowHelpY% vhLearnMode gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack


Gui, MenuGui:Add, GroupBox, x%Group2of3BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , Minimum length of word to learn
_LearnLengthOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
StringReplace,  _LearnLengthOptions, _LearnLengthOptions, |%LearnLength%|,|%LearnLength%||
StringTrimLeft, _LearnLengthOptions, _LearnLengthOptions, 1
Gui, MenuGui:Add, DDL, x%Group2of3EditX% y%RowEditY% r5 vLearnLength, %_LearnLengthOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group2of3HelpX% y%RowHelpY% vhLearnLength gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack


Gui, MenuGui:Add, GroupBox, x%Group3of3BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight%, Add to wordlist after X times
_LearnCountOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
StringReplace,  _LearnCountOptions, _LearnCountOptions, |%LearnCount%|,|%LearnCount%||
StringTrimLeft, _LearnCountOptions, _LearnCountOptions, 1
Gui, MenuGui:Add, DDL, x%Group3of3EditX% y%RowEditY% r5 vLearnCount, %_LearnCountOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group3of3HelpX% y%RowHelpY% vhLearnCount gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack


RowY := RowY + RowHeight + SeparatorY
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , Maximum number of results to show
_ListBoxRowsOptions=|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|
StringReplace,  _ListBoxRowsOptions, _ListBoxRowsOptions, |%ListBoxRows%|,|%ListBoxRows%||
StringTrimLeft, _ListBoxRowsOptions, _ListBoxRowsOptions, 1
Gui, MenuGui:Add, DDL, x%Group1EditX% y%RowEditY% r5 vListBoxRows, %_ListBoxRowsOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of3HelpX% y%RowHelpY% vhListBoxRows gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack


/* MaxMatches removed
Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , Max. number of matches
_MaxMatchesOptions=|10|11|12|13|14|15|16|17|18|19|20|
StringReplace,  _MaxMatchesOptions, _MaxMatchesOptions, |%MaxMatches%|,|%MaxMatches%||
StringTrimLeft, _MaxMatchesOptions, _MaxMatchesOptions, 1
Gui, MenuGui:Add, DDL, x%Group1EditX% y%RowEditY% r5 vMaxMatches, %_MaxMatchesOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of3HelpX% y%RowHelpY% vhMaxMatches gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack
*/

Gui, MenuGui:Add, GroupBox, x%Group2of3BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , Show wordlist after X characters
_LengthOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
StringReplace,  _LengthOptions, _LengthOptions, |%Wlen%|,|%Wlen%||
StringTrimLeft, _LengthOptions, _LengthOptions, 1
Gui, MenuGui:Add, DDL, x%Group2of3EditX% y%RowEditY% r5 vLength, %_LengthOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group2of3HelpX% y%RowHelpY% vhLength gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack


Gui, MenuGui:Add, GroupBox, x%Group3of3BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , Send Method
_SendMethodOptionsText=1 - Default (Type)|2 - Fast (Type)|3 - Slow (Type)|4 - Default (Paste)|5 - Fast (Paste)|6 - Slow (Paste)|7 - Alternate method
_SendMethodOptionsCode=1|2|3|1C|2C|3C|4C
Loop, parse, _SendMethodOptionsCode, |
	If (SendMethod = A_LoopField)
		_SendCount:=A_Index

Loop, parse, _SendMethodOptionsText, |
{
	_SendMethodOptions .= A_LoopField "|"
    If (A_Index = _SendCount)
		_SendMethodOptions .= "|"
}   
Gui, MenuGui:Add, DDL, x%Group3of3EditX% y%RowEditY% w%ThreeColEditWidth% r5 v_SendMethodC altsubmit, %_SendMethodOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group3of3HelpX% y%RowHelpY% vhSendMethod gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack


RowY := RowY + RowHeight + SeparatorY
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%TwoColGroupWidth% h%RowHeight% , Auto Complete Keys
;  E = Ctrl + Enter
;  S = Ctrl + Space
;  T = Tab
;  R = Right Arrow
;  N = Number Keys
;  U = Enter
CheckedE=Checked
CheckedS=Checked
CheckedT=Checked
CheckedR=Checked
CheckedN=Checked
CheckedU=Checked
Loop, parse, DisabledAutoCompleteKeys
{
	If (A_LoopField = "E")
		CheckedE =
	If (A_LoopField = "S")
		CheckedS =
    If (A_LoopField = "T")
		CheckedT =
    If (A_LoopField = "R")
		CheckedR =
    If (A_LoopField = "N")
		CheckedN =
    If (A_LoopField = "U")
		CheckedU =
}

CheckmarkIndent := TwoColEditWidth/3 + EditIndentX
Gui, MenuGui:Add, Checkbox, x%Group1EditX% yp+%TextRowY% vCtrlEnter  %CheckedE%, Ctrl + Enter
Gui, MenuGui:Add, Checkbox, xp%CheckmarkIndent% yp vTab        %CheckedT%, Tab
Gui, MenuGui:Add, Checkbox, xp%CheckmarkIndent% yp vRightArrow %CheckedR%, Right Arrow
Gui, MenuGui:Add, Checkbox, x%Group1EditX% yp+%TextRowY% vCtrlSpace  %CheckedS%, Ctrl + Space
Gui, MenuGui:Add, Checkbox, xp%CheckmarkIndent% yp vNumberKeys %CheckedN%, Number Keys
Gui, MenuGui:Add, Checkbox, xp%CheckmarkIndent% yp vEnter %CheckedU%, Enter

Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of2HelpX% y%RowHelpY% vhDisabledAutoCompleteKeys gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack


Gui, MenuGui:Add, GroupBox, x%Group2of2BoxX% y%RowY% w%TwoColGroupWidth% h%RowHeight% , Wordlist row highlighting
_ArrowKeyMethodOptionsText=Off - only use the number keys|First - reset selected word to the beginning|LastWord - keep last word selected|LastPosition - keep the last cursor position
Loop, parse, _ArrowKeyMethodOptionsText, |
{
    _ArrowKeyMethodOptions .= A_LoopField "|"
    StringSplit, Split, A_LoopField, -
    Split1=%Split1% ; autotrim
    If (Split1 = ArrowKeyMethod)
    {
		_ArrowKeyMethodOptions .= "|"
	}   
}

Gui, MenuGui:Add, DDL, x%Group2of2EditX% y%RowEditY% w%TwoColEditWidth% r5 vArrowKeyMethod altsubmit, %_ArrowKeyMethodOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group2of2HelpX% y%RowHelpY% vhArrowKeyMethod gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack


RowY := RowY + RowHeight + SeparatorY
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , Case correction
_CaseCorrectionOptions=|On|Off|
If (NoBackSpace = "on")
	_CaseCorrection=Off
Else If (NoBackSpace = "off")
	_CaseCorrection=On
StringReplace,  _CaseCorrectionOptions, _CaseCorrectionOptions, |%_CaseCorrection%|,|%_CaseCorrection%||
StringTrimLeft, _CaseCorrectionOptions, _CaseCorrectionOptions, 1
Gui, MenuGui:Add, DDL, x%Group1EditX% y%RowEditY% r5 v_CaseCorrection, %_CaseCorrectionOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of3HelpX% y%RowHelpY% vhNoBackSpace gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack


Gui, MenuGui:Add, GroupBox, x%Group2of3BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , Monitor mouse clicks 
_DetectMouseClickMoveOptions=|On|Off|
StringReplace,  _DetectMouseClickMoveOptions, _DetectMouseClickMoveOptions, |%DetectMouseClickMove%|,|%DetectMouseClickMove%||
StringTrimLeft, _DetectMouseClickMoveOptions, _DetectMouseClickMoveOptions, 1
Gui, MenuGui:Add, DDL, x%Group2of3EditX% y%RowEditY% r5 vDetectMouseClickMove, %_DetectMouseClickMoveOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group2of3HelpX% y%RowHelpY% vhDetectMouseClickMove gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

Gui, MenuGui:Add, GroupBox, x%Group3of3BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , Type space after autcomplete
_AutoSpaceOptions=|On|Off|
StringReplace,  _AutoSpaceOptions, _AutoSpaceOptions, |%AutoSpace%|,|%AutoSpace%||
StringTrimLeft, _AutoSpaceOptions, _AutoSpaceOptions, 1
Gui, MenuGui:Add, DDL, x%Group3of3EditX% y%RowEditY% r5 vAutoSpace, %_AutoSpaceOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group3of3HelpX% y%RowHelpY% vhAutoSpace gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

;NumPresses
;

Gui, MenuGui:Tab, 2 ; listbox ---------------------------------------------------------


RowY := SeparatorY + 30
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY


Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , List appears X pixels below cursor
_ListBoxOffsetOptions=|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
StringReplace,  _ListBoxOffsetOptions, _ListBoxOffsetOptions, |%ListBoxOffset%|,|%ListBoxOffset%||
StringTrimLeft, _ListBoxOffsetOptions, _ListBoxOffsetOptions, 1
Gui, MenuGui:Add, DDL, x%Group1EditX% y%RowEditY% r5 vListBoxOffset, %_ListBoxOffsetOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of3HelpX% y%RowHelpY% vhListBoxOffset gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

Gui, MenuGui:Add, GroupBox, x%Group2of3BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , Fixed width font in list
_ListBoxFontFixedOptions=|On|Off|
StringReplace,  _ListBoxFontFixedOptions, _ListBoxFontFixedOptions, |%ListBoxFontFixed%|,|%ListBoxFontFixed%||
StringTrimLeft, _ListBoxFontFixedOptions, _ListBoxFontFixedOptions, 1
Gui, MenuGui:Add, DDL, x%Group2of3EditX% y%RowEditY% r5 vListBoxFontFixed, %_ListBoxFontFixedOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group2of3HelpX% y%RowHelpY% vhListBoxFontFixed gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

Gui, MenuGui:Add, GroupBox, x%Group3of3BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , Font size in list
_ListBoxFontSizeOptions=|8|9|10|11|12|13|14|15|16|17|18|19|20|
StringReplace,  _ListBoxFontSizeOptions, _ListBoxFontSizeOptions, |%ListBoxFontSize%|,|%ListBoxFontSize%||
StringTrimLeft, _ListBoxFontSizeOptions, _ListBoxFontSizeOptions, 1
Gui, MenuGui:Add, DDL, x%Group3of3EditX% y%RowEditY% r5 vListBoxFontSize, %_ListBoxFontSizeOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group3of3HelpX% y%RowHelpY% vhListBoxFontSize gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

RowY := RowY + RowHeight + SeparatorY
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY



Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , List opacity
;_ListBoxOpacityOptions=|150|175|200|205|210|215|255|
;StringReplace,  _ListBoxOpacityOptions, _ListBoxOpacityOptions, |%ListBoxOpacity%|,|%ListBoxOpacity%||
;StringTrimLeft, _ListBoxOpacityOptions, _ListBoxOpacityOptions, 1
;Gui, MenuGui:Add, DDL, x%Group2of3EditX% y%RowEditY% r5 vListBoxOpacity, %_ListBoxOpacityOptions%
Gui, MenuGui:Add, Edit, xp+10 yp+20 w%ThreeColEditWidth% vListBoxOpacity, %ListBoxOpacity%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of3HelpX% y%RowHelpY% vhListBoxOpacity gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

Gui, MenuGui:Add, GroupBox, x%Group2of3BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , List character width override
_ListBoxCharacterWidthOptions=||5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|
StringReplace,  _ListBoxCharacterWidthOptions, _ListBoxCharacterWidthOptions, |%ListBoxCharacterWidth%|,|%ListBoxCharacterWidth%||
StringTrimLeft, _ListBoxCharacterWidthOptions, _ListBoxCharacterWidthOptions, 1
Gui, MenuGui:Add, DDL, x%Group2of3EditX% y%RowEditY% r5 vListBoxCharacterWidth, %_ListBoxCharacterWidthOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group2of3HelpX% y%RowHelpY% vhListBoxCharacterWidth gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

Gui, MenuGui:Add, GroupBox, x%Group3of3BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , List font
fontlist := "|" . fontlist . "|"
sort, fontlist, D|
If (listboxfont = "") or (listboxfont = " ")
    StringReplace, fontlist, fontlist, |Courier New|, |Courier New||
Gui, MenuGui:Add, DDL, x%Group3of3EditX% y%RowEditY% r10 w200 vListBoxFontOverride, %fontlist%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group3of3HelpX% y%RowHelpY% vhListBoxFontOverride gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack
/*
Gui, MenuGui:Add, GroupBox, x%Group3of3BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , List size
_ListBoxRowsOptions=|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|
StringReplace,  _ListBoxRowsOptions, _ListBoxRowsOptions, |%ListBoxRows%|,|%ListBoxRows%||
StringTrimLeft, _ListBoxRowsOptions, _ListBoxRowsOptions, 1
Gui, MenuGui:Add, DDL, x%Group3of3EditX% y%RowEditY% r5 vListBoxRows, %_ListBoxRowsOptions%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group3of3HelpX% y%RowHelpY% vhListBoxRows gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack
*/

RowY := RowY + RowHeight + SeparatorY
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY
 

/*
Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%ThreeColGroupWidth% h%RowHeight% , List font
fontlist := "|" . fontlist . "|"
sort, fontlist, D|
If (listboxfont = "") or (listboxfont = " ")
    StringReplace, fontlist, fontlist, |Courier New|, |Courier New||
Gui, MenuGui:Add, DDL, x%Group1EditX% y%RowEditY% r10 w200 vListBoxFontOverride, %fontlist%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of3HelpX% y%RowHelpY% vhListBoxFontOverride gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack
*/


Gui, MenuGui:Tab, 3 ; Programs ---------------------------------------------------------


RowY := SeparatorY + 30
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%OneColGroupWidth% h%RowHeight% , Window titles you want TypingAid enabled for
Gui, MenuGui:Add, Edit, x%Group1EditX% y%RowEditY% w%OneColEditWidthEdit% vIncludeProgramTitles, %IncludeProgramTitles%
Gui, MenuGui:Add, Button, x%OneColEditButton% yp w130 gSetEnableTitles, Edit
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of1HelpX% y%RowHelpY% vhIncludeProgramTitles gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

RowY := RowY + RowHeight + SeparatorY
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%OneColGroupWidth% h%RowHeight% , Window titles you want TypingAid disabled for
Gui, MenuGui:Add, Edit, x%Group1EditX% y%RowEditY% w%OneColEditWidthEdit% vExcludeProgramTitles, %ExcludeProgramTitles%
Gui, MenuGui:Add, Button, x%OneColEditButton% yp w130 gSetDisableTitles, Edit
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of1HelpX% y%RowHelpY% vhExcludeProgramTitles gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

RowY := RowY + RowHeight + SeparatorY
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%OneColGroupWidth% h%RowHeight% , Processes you want TypingAid enabled for
Gui, MenuGui:Add, Edit, x%Group1EditX% y%RowEditY% w%OneColEditWidthEdit% vIncludeProgramExecutables, %IncludeProgramExecutables%
Gui, MenuGui:Add, Button, x%OneColEditButton% yp w130 gSetEnableProcess, Edit
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of1HelpX% y%RowHelpY% vhIncludeProgramExecutables gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

RowY := RowY + RowHeight + SeparatorY
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%OneColGroupWidth% h%RowHeight% , Processes you want TypingAid disabled for
Gui, MenuGui:Add, Edit, x%Group1EditX% y%RowEditY% w%OneColEditWidthEdit% vExcludeProgramExecutables, %ExcludeProgramExecutables%
Gui, MenuGui:Add, Button, x%OneColEditButton% yp w130 gSetDisableProcess, Edit
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of1HelpX% y%RowHelpY% vhExcludeProgramExecutables gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

RowY := RowY + RowHeight + SeparatorY
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

;HelperWindowProgramTitles

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%OneColGroupWidth% h%RowHeight% , Window titles you want the helper window enabled for
Gui, MenuGui:Add, Edit, x%Group1EditX% y%RowEditY% w%OneColEditWidthEdit% vHelperWindowProgramTitles, %HelperWindowProgramTitles%
Gui, MenuGui:Add, Button, x%OneColEditButton% yp w130 gSetHelpTitles, Edit
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of1HelpX% y%RowHelpY% vhHelperWindowProgramTitles gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

RowY := RowY + RowHeight + SeparatorY
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

;HelperWindowProgramExecutables

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%OneColGroupWidth% h%RowHeight% , Processes you want the helper window enabled for
Gui, MenuGui:Add, Edit, x%Group1EditX% y%RowEditY% w%OneColEditWidthEdit% vHelperWindowProgramExecutables, %HelperWindowProgramExecutables%
Gui, MenuGui:Add, Button, x%OneColEditButton% yp w130 gSetHelpProcess, Edit
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of1HelpX% y%RowHelpY% vhHelperWindowProgramExecutables gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack



Gui, MenuGui:Tab, 4 ; advanced  -------------------------------------------------------------------------

RowY := SeparatorY + 30
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%OneColGroupWidth% h%RowHeight% , Terminating Characters (see http://www.autohotkey.com/docs/KeyList.htm)
Gui, MenuGui:Add, Edit, x%Group1EditX% y%RowEditY% w%OneColEditWidth% vTerminatingCharacters, %TerminatingCharacters%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of1HelpX% y%RowHelpY% vhTerminatingCharacters gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack

RowY := RowY + RowHeight + SeparatorY
RowEditY := RowY + EditIndentY
RowHelpY := RowY - HelpIndentY

Gui, MenuGui:Add, GroupBox, x%Group1BoxX% y%RowY% w%OneColGroupWidth% h%RowHeight% , Force New Word Characters (comma separated)
Gui, MenuGui:Add, Edit, x%Group1EditX% y%RowEditY% w%OneColEditWidth% vForceNewWordCharacters, %ForceNewWordCharacters%
Gui, MenuGui:Font, cGreen
Gui, MenuGui:Add, Text, x%Group1of1HelpX% y%RowHelpY% vhForceNewWordCharacters gHelpMe, %GuiHelpIcon%
Gui, MenuGui:Font, cBlack



Gui, MenuGui:Tab, 5 ; about & help --------------------------------------------

RowY := SeparatorY + 30
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY

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

Gui, MenuGui:Add, Edit, ReadOnly x%Group1BoxX% y%RowY% w%OneColGroupWidth% h%TabHeightEdit%, %hModHelpText%

hModHelpText =
hHelpText =
hIntro =


Gui, MenuGui:tab, 

RowY := TabHeight+15
RowHelpY := RowY - HelpIndentY
RowEditY := RowY + EditIndentY
RowThreeButtonWidth := (TwoColGroupWidth - (4 * EditIndentX))/3
RowThreeButtonNext := EditIndentX + RowThreeButtonWidth

Gui, MenuGui:Add, GroupBox, x%Group1BoxX%           y%RowY%     w%TwoColGroupWidth% h50 , Configuration
Gui, MenuGui:Add, Button,   x%Group1EditX%          y%RowEditY% w%RowThreeButtonWidth%    gSave   , Save && Exit
Gui, MenuGui:Add, Button,   xp+%RowThreeButtonNext% yp          w%RowThreeButtonWidth%    gRestore, Restore default
Gui, MenuGui:Add, Button,   xp+%RowThreeButtonNext% yp          w%RowThreeButtonWidth%    gCancel , Cancel

Gui, MenuGui:Font, cBlack bold
Gui, MenuGui:Add, Text, x%Group2of2EditX% Yp-10 gVisitForum, TypingAid
Gui, MenuGui:Font, cBlack normal

Gui, MenuGui:Add, Text, xp+60 Yp gVisitForum, is free software, support forum at
Gui, MenuGui:Font, cGreen 
Gui, MenuGui:Add, Text, x%Group2of2EditX% Yp+%TextRowY% vVisitForum gVisitForum, www.autohotkey.com (click here)
Gui, MenuGui:Font, cBlack 

Gui, MenuGui:Show, h%GuiHeight% w%GuiWidth%, TypingAid Settings
Return

SetEnableTitles:
TitleType=1
GetExe=0
ActiveList:=IncludeProgramTitles
Gosub, GetList
Return

SetDisableTitles:
TitleType=2
GetExe=0
ActiveList:=ExcludeProgramTitles
Gosub, GetList
Return

SetEnableProcess:
TitleType=3
GetExe=1
ActiveList:=IncludeProgramExecutables
Gosub, GetList
Return

SetDisableProcess:
TitleType=4
GetExe=1
ActiveList:=ExcludeProgramExecutables
Gosub, GetList
Return

SetHelpTitles:
TitleType=5
GetExe=0
ActiveList:=HelperWindowProgramTitles
Gosub, GetList
Return

SetHelpProcess:
TitleType=6
GetExe=1
ActiveList:=HelperWindowProgramExecutables
Gosub, GetList
Return


Advanced:
WinGetPos, GuiXPos, GuiYPos,,,A
Gui, MenuGui:Show, h%AdvGuiHeight% w%GuiWidth% y%GuiYPos% x%GuiXPos%, New GUI Window
Return

VisitForum:
MsgBox , 36 , Visit TypingAid forum (www.autohotkey.com), Do you want to visit the TypingAid forum on www.autohotkey.com?
IfMsgBox Yes
	Run, http://www.autohotkey.com/board/topic/49517-ahk-11typingaid-v2198-word-autocompletion-utility/
Return

Restore: ; this could be changed to not restart TA
;FileDelete, Preferences.ini
;WinClose, \TypingAid
;Loop, TypingAid*.ahk
;	{
;	 Run %A_LoopFileName%
;	 Break
;	}
;Reload
Return

Esc::
MenuGuiGuiClose:
Cancel:
Gui, MenuGui:Destroy
;ExitApp
Return

Save:
;Gui, MenuGui:Submit
Gui, MenuGui:Destroy

;Loop, parse, _SendMethodOptionsCode, | ; get sendmethod
;   If (_SendMethodC = A_Index)
;      SendMethod:=A_LoopField

;DisabledAutoCompleteKeys=
;If (CtrlEnter = 0)
;   DisabledAutoCompleteKeys .= "E"
;If (Tab = 0)
;   DisabledAutoCompleteKeys .= "T"
;If (CtrlSpace = 0)
;   DisabledAutoCompleteKeys .= "S"
;If (RightArrow = 0)
;   DisabledAutoCompleteKeys .= "R"
;If (NumberKeys = 0)
;   DisabledAutoCompleteKeys .= "N"
;If (Enter = 0)
;   DisabledAutoCompleteKeys .= "U"

;If (_CaseCorrection = "on")
;	NoBackSpace=Off
;Else If (_CaseCorrection = "off")
;	NoBackSpace=On

;Loop, parse, _ArrowKeyMethodOptionsText, |
;   {
;    StringSplit, Split, A_LoopField, -
;    Split1=%Split1% ; autotrim
;    If (ArrowKeyMethod = A_Index)
;     {
;      ArrowKeyMethod := Split1
;     }   
;   }
   
;SavePreferences()
;WinClose, \TypingAid
;Loop, TypingAid*.ahk
;	{
;	 Run %A_LoopFileName%
;	 Break
;	}
;ExitApp
Return

HelpMe:
Loop, Parse, %A_GuiControl%,`r`n
{
	IF ( SubStr(A_LoopField, 1,1) = ";")
	{
		_help .= SubStr(A_LoopField,2) . "`r`n"
	} else
	{
		_help .= A_LoopField . "`r`n"
	}
}
MsgBox , 32 , TypingAid Help, %_help%
_help=
Return

   
; 2005 by shimanov
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


GetList:
;Gui, MenuGui:Hide
RunningList=
If (GetExe = 1) ; get list of active processes
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
}
Else If (GetExe = 0) ; get list of active window titles
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
Gui, ProcessList:Add, Edit, x110 y40 w250 vAddNew1 
Gui, ProcessList:Add, Button, xp+260 yp gAddNew1 w40 Default, Add
Gui, ProcessList:Add, Text, x10 yp+40, Current list:
Gui, ProcessList:Add, ListBox, x110 yp w250 r10, %ActiveList%
Gui, ProcessList:Add, Button, xp+260 yp gRemoveNew1 w40 , Del
Gui, ProcessList:Add, Text, x10 yp+170, a) Select a program or window from the list or type a name in the`n%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%'Edit' control (you may need to edit it further)`nb) Click ADD to add it to the list`nc) To remove a program/title, select an item from the 'current list' and`n%A_Space%%A_Space%%A_Space%%A_Space%click DEL.
Gui, ProcessList:Add, Button, x10 yp+90 w190 gSaveTitleList, Save 
Gui, ProcessList:Add, Button, xp+210 yp w190 gCancelTitle, Cancel
Gui, ProcessList:Show, w420 h380, TypingAid Settings
Return

SaveTitleList:
ControlGet, List, List, , ListBox1
Gui, ProcessList:Destroy
;Gui, MenuGui:Show
Gui, MenuGui:-Disabled  ; enable main window
WinActivate, TypingAid Settings
StringReplace, List, List, `n, |, All

If (TitleType=1)
{
	IncludeProgramTitles:=List
	GuiControl, MenuGui:Text, Edit2, 
	GuiControl, MenuGui:Text, Edit2, %IncludeProgramTitles%
}
Else If (TitleType=2)
{
	ExcludeProgramTitles:=List
	GuiControl, MenuGui:Text, Edit3, 
	GuiControl, MenuGui:Text, Edit3, %ExcludeProgramTitles%
}
Else If (TitleType=3)
{
	IncludeProgramExecutables:=List
	GuiControl, MenuGui:Text, Edit4, 
	GuiControl, MenuGui:Text, Edit4, %IncludeProgramExecutables%
}
Else If (TitleType=4)
{
	ExcludeProgramExecutables:=List
	GuiControl, MenuGui:Text, Edit5, 
	GuiControl, MenuGui:Text, Edit5, %ExcludeProgramExecutables%
}
Else If (TitleType=5)
{
	HelperWindowProgramTitles:=List
	GuiControl, MenuGui:Text, Edit6, 
	GuiControl, MenuGui:Text, Edit6, %HelperWindowProgramTitles%
}	
Else If (TitleType=6)
{
	HelperWindowProgramExecutables:=List
	GuiControl, MenuGui:Text, Edit7, 
	GuiControl, MenuGui:Text, Edit7, %HelperWindowProgramExecutables%
}	
		
	
Return

CancelTitle:
Gui, ProcessList:Destroy
Gui, MenuGui:-Disabled ; disable main window
WinActivate, TypingAid Settings
Return

ToEdit:
GuiControlGet, OutputVar, ProcessList:,ComboBox1
GuiControl, ProcessList:, Edit1, 
GuiControl, ProcessList:, Edit1, %OutputVar%
ControlFocus, Edit1
Return

AddNew1:
GuiControlGet, OutputVar, ProcessList:,Edit1
GuiControl, ProcessList:, ListBox1, %OutputVar%|
GuiControl, ProcessList:, Edit1, 
ControlFocus, Edit1
Return

RemoveNew1:
GuiControlGet, OutputVar, ProcessList:, Listbox1
ControlGet, List, List, , ListBox1
StringReplace, List, List, `n, |, All
List := "|" list "|"
StringReplace, List, List, |%OutputVar%|, |, all
StringTrimRight, list, list, 1
GuiControl, ProcessList:, ListBox1, |
GuiControl, ProcessList:, ListBox1, %list%
Return

ProcessListGuiClose:
Gui, ProcessList:Destroy
Gui, MenuGui:Show
Return

; copied from font explorer http://www.autohotkey.com/forum/viewtopic.php?t=57501&highlight=font
Writer_enumFonts()
{

	hDC := DllCall("GetDC", "Uint", 0) 
	DllCall("EnumFonts", "Uint", hDC, "Uint", 0, "Uint", RegisterCallback("Writer_enumFontsProc", "F"), "Uint", 0) 
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
	
	return Writer_enumFontsProc(0, 0, 0, 0)
}

Writer_enumFontsProc(lplf, lptm, dwType, lpData)
{
	static s
	
	ifEqual, lplf, 0, return s

	s .= DllCall("MulDiv", "Int", lplf+28, "Int",1, "Int", 1, "str") "|"
	return 1
}