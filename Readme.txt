TypingAid is a simple, compact, and handy auto-completion utility.

It is customizable enough to be useful for regular typing and for programming.

[b]Download:[/b]
[url=https://github.com/ManiacDC/TypingAid/releases/download/v2.19.5/TypingAid.exe]TypingAid v2.19.5 Precompiled Executable[/url]
[url=https://github.com/ManiacDC/TypingAid/archive/v2.19.5.zip]TypingAid v2.19.5 AHK Script[/url]

English Wordlists:
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/Wordlist%201200%20frequency%20weighted.txt]1200 English Words Weighted By Frequency[/url]
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/Wordlist%202000%20common.txt]2000 Common English Words[/url]
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/Wordlist%202000%20common%202.txt]2000 Common English Words (Alternative)[/url]
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/Wordlist%203600.txt]3600 English Words[/url]
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/English%20wordlist%20unfiltered.txt]Large English Wordlist (Unfiltered, may contain curse words, etc)[/url]

AHK Keyword Wordlist:
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/WordList%20AHK.txt]Wordlist AHK.txt[/url] (Thanks [url=http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-22#entry425973]tidbit[/url].)

[b]Screenshots:[/b]
[img=https://github.com/ManiacDC/TypingAid/raw/master/Images/TypingAidListBox.png]

[b][url=https://github.com/ManiacDC/TypingAid/raw/master/Changelog.txt]Change Log[/url][/b]

[b]Features:[/b]
As you type your word, up to 10 (or as defined in the Preferences file) matches will appear in a drop-down dialog, numbered 1 - 0 (10th). To choose the match you want just hit the associated number on your keyboard (numpad does not work). Alternatively you can select an item from the drop-down using the Up/Down arrows. You can define a fixed position for the drop-down dialog to appear by hitting Ctrl-Shift-H to open a small helper window, or by specifying a list of programs in the preferences file. Please note that in Firefox, Thunderbird, and certain other programs you will probably need to open the helper window due to issues detecting the caret position.

Words should be stored in a file named 'Wordlist.txt' which should be located in the script directory. These words may be commented out by prefixing with a semicolon or simply removed or added. Words may include terminating characters (such as space), but you must select the word before typing the terminating character.

In addition to being able to use the number keys to select a word, you can select words from the drop-down via the Up/Down arrows. Hitting Up on the first item will bring you to the last and hitting Down on the last item will bring you to the first. Hitting Page Up will bring you up 10 items, or to the first item. Hitting Page Down will bring you down 10 items, or to the last item. You can hit Tab, Right Arrow, Ctrl-Space, or Ctrl-Enter to autocomplete the selected word. This feature can be disabled or have some of its behavior modified via the Preferences file.

The script will learn words as you type them if LearnMode=On in the preferences file. If you type a word more than 5 times (or as defined in the preferences.ini file) in a single session the word will be added to a WordlistLearned.txt file. Learned words are stored in the WordlistLearned.txt file. Learned words will always appear below predefined words, but will be ranked and ordered among other learned words based on the frequency you type them. You can permanently learn a word by highlighting a word and hitting Ctrl-Shift-C (this works even if LearnMode=Off). You may use Ctrl-Shift-Del to remove the currently selected Learned Word, or you may manually remove them while the script is off.
When LearnMode=On, entries in the wordlist file and learned words are limited to a length of 123 (or 61 when using Unicode AHK) characters due to internal workings.

The script will automatically create a file named preferences.ini in the script directory. This file allows for customization of the script.
To allow for distribution of standardized preferences, a Defaults.ini may be distributed with the same format as Preferences.ini. If the Defaults.ini is present, Preferences.ini will not be created. A user may override the Defaults.ini by manually creating a Preferences.ini.

Customizable features include:
[LIST]
[*]List of programs for which you want TypingAid enabled.[/*]
[*]List of programs for which you do not want TypingAid enabled.[/*]
[*]Number of characters before the list of words appears.[/*]
[*]Number of times you must press a number hotkey to select the associated word (options are 1 and 2, 2 has had minimal testing).[/*]
[*]Enable or disable learning mode.[/*]
[*]Number of times you must type a word before it is permanently learned.[/*]
[*]Number of characters a word needs to have in order to be learned.[/*]
[*]List of strings which will prevent any word which contains one of these strings from being learned.[/*]
[*]Enable, disable, or customize the arrow key's functionality.[/*]
[*]Disable certain keys for autocompleting a word selected via the arrow keys.[/*]
[*]Enable or disable the resetting of the List Box on a mouseclick.[/*]
[*]Change whether the script simply completes or actually replaces the word (capitalization change based on the wordlist file)[/*]
[*]Change whether a space should be automatically added after the autocompleted word or not.[/*]
[*]Change whether the typed word should appear in the word list or not.[/*]
[*]Change the method used to send the word to the screen.[/*]
[*]List of characters which terminate a word.[/*]
[*]List of characters which terminate a word and start a new word.[/*]
[*]List of programs for which you want the Helper Window to automatically open.[/*]
[*]Number of pixels below the caret to display the List Box.[/*]
[*]List Box Default Font of fixed (Courier New) or variable (Tahoma) width.[/*]
[*]List Box Default Font override.[/*]
[*]List Box Font Size.[/*]
[*]List Box Character Width to override the computed character width.[/*]
[*]List Box Opacity setting to set the transparency of the List Box.[/*]
[*]List Box Rows to define the number of items to show in the list at once.[/*]
[/LIST]
[b]Unicode Support:[/b]
Full (untested) for UTF-8 character set.
[url=http://www.autohotkey.net/~Lexikos/AutoHotkey_L/]AHK_L[/url] is required.

[b]Known Issues:[/b]
[LIST]
[*]The caret position cannot be detected in certain applications, such as FireFox, OpenOffice.org, and Thunderbird. As a workaround for this the drop-down will open at the last position you clicked with your mouse, or you can open a helper window by hitting Ctrl-Shift-H.[/*]
[*]There are problems correctly handling dead keys like `" in certain keyboard layouts where they are used to type accented characters.[/*]
[*]Similar to the above, Chinese/Japanese IME (and any other languages which operate by changing characters) input will have issues.[/*]
[*]Occasionally the program might fail to delete one or two characters during autocompletion. There are 2 reasons for this - A. It is possible to type fast enough that the script misses keys. B. I have noticed that sometimes the script attempts to send the right number of backspaces, but the active window doesn't receive all of them. Changing the SendMethod in the Preferences.ini file may address this.[/*]
[*]SendMethod=1 is unable to send characters which do not exist on your keyboard layout. Try switching to a different SendMethod in the Preferences.ini file if you find that you are unable to autocomplete certain characters.[/*]
[*]With CAPS lock on, if you hit the Up/Down arrow to change lines and begin typing, the first character you type will not be capitalized on some machines.[/*]
[*]If using an On-Screen Keyboard, please disable DetectMouseClickMove or the word will be reset while typing.[/*]
[*]If you have changed the Font DPI in windows there may be issues calculating the width of the List Box, this can be addressed via the ListBoxCharacterWidth parameter in the Preferences.ini file.[/*]
[*]When NumPresses=2, numbers aren't learned when there are items to autocomplete, but the number is only hit once.[/*]
[*]Running another script in conjunction with TypingAid can cause extra characters to be typed occasionally (possible fix via I parameter to Input command, http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-15#entry358321 ).[/*]
[*]When Colemak v1.1 is the default keyboard layout on Windows 7 (and possibly XP or Vista, but untested), using ` and ~ as endkeys map to R and G respectively; so R and G terminate the word. Reported here. This can be worked around by removing ` and ~ from the "TerminatingCharacters" value in the Preferences.ini file and adding them to "ForceNewWordCharacters" (note the word you type following these characters will not be learned).[/*]
[*]If TypingAid doesn't exit cleanly, the learned words are not updated.[/*]
[/LIST]
[b]Future Features:[/b]
[LIST]
[*]A toggle hotkey to activate/suspend script, also via tray menu (configurable)[/*]
[*]Add a tray menu to allow for configuring settings more easily[/*]
[*]Possibly implement a method of checking to see if the typed letter actually typed a letter (when helper window is not open - check to see if caret moved).[/*]
[*]Possibly add customized autocomplete combinations (such as send word and a space, or send word and a period, http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-10#entry324795 ).[/*]
[*]Allow a way to add more "weight" to words when you type/complete them so they jump up the list faster ( http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-14#entry341770 ).[/*]
[*]Add word replacement ( http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-19#entry400346 ).[/*]
[*]Add tiered wordlists (Parent>Child relationships) ( http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-20#entry401897 ).[/*]
[*]Add sentence and/or pattern learning. ( http://www.autohotkey.com/board/topic/49517-typingaid-v219b-word-autocompletion-utility/page-40#entry590757 ).[/*]
[*]Allow TypingAid to send in non-raw format (for putting in special characters). ( http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-21#entry406500 )[/*]
[*]Allow users to customize shortcut keys. ( http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-21#entry408261 )[/*]
[*]Monitor the clipboard to find words to add to the list. ( http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-23#entry443169 )[/*]
[*]Add a way to use a hardcoded list of words rather than wordlist.txt[/*]
[*]Add a new type of Helper Window which would basically be a self-contained edit window. ( hhttp://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-31#entry473544 )[/*]
[*]Add the ability to parse out and index CamelCase strings by UpperCase letters. ( http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-33#entry511828 )[/*]
[*]Warn the user when the Wordlist file does not exist or is empty. ( http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-34#entry524677 )[/*]
[*]Add support for Russian ( http://www.autohotkey.com/board/topic/49517-typingaid-v218-word-autocompletion-utility/page-38#entry553085 )[/*]
[*]Add an option to suppress plural forms of words ( http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-40#entry590557 )[/*]
[*]Add a way to reorder the wordlist based on # Characters left to type in combination with the existing frequency weighting ( http://www.autohotkey.com/board/topic/49517-typingaid-v219d-word-autocompletion-utility/#entry591512 )[/*]
[*]Changed Learned Words to be stored in a SQL database ( http://www.autohotkey.com/board/topic/49517-typingaid-v219d-word-autocompletion-utility/page-41#entry592912 )[/*]
[*]Allow a way to quickly switch between different wordlists ( http://www.autohotkey.com/board/topic/49517-typingaid-v219d-word-autocompletion-utility/page-43#entry635313 )[/*]
[*]Allow the script to recognize multiple partial string matches ( http://www.autohotkey.com/board/topic/49517-typingaid-v219d-word-autocompletion-utility/?p=640330 )[/*]
[*]Add word descriptions ( http://www.autohotkey.com/board/topic/49517-typingaid-v2195-word-autocompletion-utility/page-46#entry673435 )[/*]
[*]Allow learned words to appear before static words ( http://www.autohotkey.com/board/topic/49517-typingaid-v2195-word-autocompletion-utility/page-46#entry672898 )[/*]
[/LIST]
[b]Credits:[/b]
Jordi S
Maniac
HugoV
kakarukeys
Asaptrad


[b][url=http://www.autohotkey.com/board/topic/636-intellisense-like-autoreplacement-with-multiple-suggestions/]Original Thread[/url][/b]