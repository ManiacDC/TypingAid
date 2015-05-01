TypingAid is a simple, compact, and handy auto-completion utility.

It is customizable enough to be useful for regular typing and for programming.

[b]Download:[/b]
[url=https://github.com/ManiacDC/TypingAid/releases/download/v2.21.0/TypingAid.zip]TypingAid v2.21.0 Precompiled Executable[/url]
[url=https://github.com/ManiacDC/TypingAid/archive/v2.21.0.zip]TypingAid v2.21.0 AHK Script[/url]

As of version 2.19.7.0, the script is no longer compatible with AHK Basic. Please get the newest version from [url]http://www.ahkscript.org[/url].

English Wordlists:
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/Wordlist%201200%20frequency%20weighted.txt]1200 English Words Weighted By Frequency[/url]
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/Wordlist%202000%20common.txt]2000 Common English Words[/url]
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/Wordlist%202000%20common%202.txt]2000 Common English Words (Alternative)[/url]
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/Wordlist%203600.txt]3600 English Words[/url]
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/English%20wordlist%20unfiltered.txt]Large English Wordlist (Unfiltered, may contain curse words, etc)[/url]

Non-English Wordlists
[url=https://raw.githubusercontent.com/ManiacDC/TypingAid/master/Wordlists/Wordlist%20Romanian.txt]Romanian Wordlist (282,000+ words)[/url] Thanks to [url=http://www.autohotkey.com/board/user/38990-ochisor/]Ochisor[/url]. Extracted from [url=http://www.ub-filosofie.ro/~solcan/wt/gnu/s/aspell-ro.html]here[/url].

AHK Keyword Wordlist:
[url=https://github.com/ManiacDC/TypingAid/raw/master/Wordlists/WordList%20AHK.txt]Wordlist AHK.txt[/url] (Thanks [url=http://www.autohotkey.com/board/topic/49517-typingaid-v219-word-autocompletion-utility/page-22#entry425973]tidbit[/url].)

[b]Screenshots:[/b]
[img]https://github.com/ManiacDC/TypingAid/raw/master/Images/TypingAidListBox.png[/img]
[img]https://github.com/ManiacDC/TypingAid/raw/master/Images/TypingAidSettings.png[/img]

[b][url=https://github.com/ManiacDC/TypingAid/raw/master/Changelog.txt]Change Log[/url][/b]

[b]Features:[/b]
As you type your word, up to 10 (or as defined in Settings) matches will appear in a drop-down dialog, numbered 1 - 0 (10th). To choose the match you want just hit the associated number on your keyboard (numpad does not work). Alternatively you can select an item from the drop-down using the Up/Down arrows or the mouse. You can define a fixed position for the drop-down dialog to appear by hitting Ctrl-Shift-H to open a small helper window, or by specifying a list of programs in the preferences file. Please note that in Firefox, Thunderbird, and certain other programs you will probably need to open the helper window due to issues detecting the caret position.

Words should be stored in a file named 'Wordlist.txt' which should be located in the script directory. These words may be commented out by prefixing with a semicolon or simply removed or added. Words may include terminating characters (such as space), but you must select the word before typing the terminating character.

In addition to being able to use the number keys to select a word, you can select words from the drop-down via the Up/Down arrows. Hitting Up on the first item will bring you to the last and hitting Down on the last item will bring you to the first. Hitting Page Up will bring you up 10 items, or to the first item. Hitting Page Down will bring you down 10 items, or to the last item. You can hit Tab, Right Arrow, Ctrl-Space, or Ctrl-Enter to autocomplete the selected word. This feature can be disabled or have some of its behavior modified via Settings.

The script will learn words as you type them if "Learn new words as you type" is set to On in Settings. If you type a word more than 5 times (or as defined in "Minimum length of word to learn") in a single session the word will be permanently added to the list of learned words. Learned words will always appear below predefined words, but will be ranked and ordered among other learned words based on the frequency you type them. You can permanently learn a word by highlighting a word and hitting Ctrl-Shift-C (this works even if "Learn new words as you type" is set to Off). You may use Ctrl-Shift-Del to remove the currently selected Learned Word.
Learned words are stored in the WordlistLearned.db sqlite3 database. Learned words are backed up in WordlistLearned.txt. To modify the list of Learned words manually, delete the WordlistLearned.db database, then manually edit the WordlistLearned.txt file. On the next launch of the script, the WordlistLearned.db database will be rebuilt.

When Settings are changed, the script will automatically create a file named Preferences.ini in the script directory. This file allows for sharing settings between users. Users are encouraged to only edit settings by using the Settings window.
To allow for distribution of standardized preferences, a Defaults.ini may be distributed with the same format as Preferences.ini. If the Defaults.ini is present, this will override the hardcoded defaults in the script. A user may override the Defaults.ini by changing settings in the Settings window.

Customizable features include:
[LIST]
[*]Enable or disable learning mode.[/*]
[*]Number of characters a word needs to have in order to be learned.[/*]
[*]Number of times you must type a word before it is permanently learned.[/*]
[*]List of strings which will prevent any word which contains one of these strings from being learned.[/*]
[*]Number of times you must press a number hotkey to select the associated word.[/*]
[*]Change whether single or double clicking is required to autocomplete a word with the mouse.[/*]
[*]Disable certain keys for autocompleting a word selected via the arrow keys.[/*]
[*]Change the method used to send the word to the screen.[/*]
[*]Change whether the script simply completes or actually replaces the word (capitalization change based on the wordlist file).[/*]
[*]Enable or disable the resetting of the Wordlist Box on a mouseclick.[/*]
[*]Change whether a space should be automatically added after the autocompleted word or not.[/*]
[*]Number of items to show in the list at once.[/*]
[*]Number of characters before the list of words appears.[/*]
[*]Choose whether to display learned words before words in Wordlist.txt.[/*]
[*]Enable, disable, or customize the arrow key's functionality.[/*]
[*]Change whether the typed word should appear in the word list or not.[/*]
[*]Number of pixels below the caret to display the Wordlist Box.[/*]
[*]Wordlist Box Default Font of fixed (Courier New) or variable (Tahoma) width.[/*]
[*]Wordlist Box Font Size.[/*]
[*]Wordlist Box Opacity setting to set the transparency of the List Box.[/*]
[*]Wordlist Box Character Width to override the computed character width.[/*]
[*]Wordlist Box Default Font override.[/*]
[*]List of programs for which you want %g_ScriptTitle% enabled.[/*]
[*]List of programs for which you do not want %g_ScriptTitle% enabled.[/*]
[*]List of programs for which you want the Helper Window to automatically open.[/*]
[*]List of characters which terminate a word.[/*]
[*]List of characters which terminate a word and start a new word.[/*]
[*]List of characters which end a word, add that character to the word, and force the word to be learned.[/*]
[/LIST]
[b]Unicode Support:[/b]
Full support for UTF-8 character set.

[b][url=https://github.com/ManiacDC/TypingAid/issues?q=is%3Aopen+is%3Aissue]Known Issues[/url][/b]

[b][url=https://github.com/ManiacDC/TypingAid/issues?q=is%3Aissue+is%3Aclosed+label%3Awontfix]Workarounds[/url][/b]

[b][url=https://github.com/ManiacDC/TypingAid/issues?q=is%3Aopen+is%3Aissue+label%3Aenhancement]Future Features[/url][/b]

[b]Credits:[/b]
Maniac
Jordi S
HugoV
kakarukeys
Asaptrad
j4hangir
Theclaw


[b][url=http://www.autohotkey.com/board/topic/636-intellisense-like-autoreplacement-with-multiple-suggestions/]Original Thread[/url][/b]
