; These functions and labels are related maintenance of the wordlist

ReadWordList()
{
   global
   ;mark the wordlist as not done
   WordListDone = 0
   
   wDB := DBA.DataBaseFactory.OpenDataBase("SQLite", A_ScriptDir . "\WordlistLearned.db" )
   if !wDB
   {
      msgbox Problem opening database '%A_ScriptDir%\WordlistLearned.db' - fatal error...
      exitapp
   }
   
   IF not wDB.Query("CREATE TEMP TABLE Words (hash TEXT, word TEXT UNIQUE, count INTEGER);")
   {
      msgbox Cannot Create Table - fatal error...
      ExitApp
   }
   
   IF not wDB.Query("CREATE INDEX temp.Hash ON Words (hash);")
   {
      msgbox Cannot Create Index - fatal error...
      ExitApp
   }
   
   wDB.BeginTransaction()   
   ;reads list of words from file 
   FileRead, ParseWords, %A_ScriptDir%\Wordlist.txt
   Loop, Parse, ParseWords, `n, `r
   {
      AddWordToList(A_LoopField,0)
   }
   ParseWords =
   wDB.EndTransaction()
    
   ;Force LearnedWordsCount to 0 as we are now reading Learned Words from the Learned Words file
   IfEqual, LearnedWordsCount, 
      LearnedWordsCount=0
 
   ;reads list of words from file 
   FileRead, ParseWords, %A_ScriptDir%\WordlistLearned.txt
   Loop, Parse, ParseWords, `n, `r
   {
      AddWordToList(A_LoopField,0)
   }
   ParseWords =

   ;reverse the numbers of the word counts in memory
   GoSub, ReverseWordNums

   ;mark the wordlist as completed
   WordlistDone = 1
   Return
}

;------------------------------------------------------------------------
   
; This sub will reverse the read numbers since now we know the total number of words
ReverseWordNums:

;We don't need to deal with any counters if LearnMode is off
IfEqual, LearnMode, Off,
   Return

wDB.BeginTransaction()
LearnedWordsCount+=4
Loop,parse,LearnedWords, %DelimiterChar%
{
   StringLeft, baseword, A_LoopField, %wlen%
   baseword := ConvertWordToAscii(baseword,1)
   WhereQuery := "WHERE word = '" . A_LoopField . "'"
   wDB.Query("UPDATE words SET count = (SELECT " . LearnedWordsCount . " - count FROM words " . WhereQuery . ") WHERE " . WhereQuery . ";")
}
wDB.EndTransaction()

AsciiWord = 
LearnedWordsCount = 

Return

;------------------------------------------------------------------------

AddWordToList(AddWord,ForceCountNewOnly)
{
   ;AddWord = Word to add to the list
   ;ForceCountNewOnly = force this word to be permanently learned even if learnmode is off
   global
   Local CharTerminateList
   Local Base
   Local AddWordInList
   Local CountWord
   Local pos
   Local LearnModeTemp
   Local WhereQuery
   Local QueryResult
   Local CountValue
   Local each
   Local row
   
   IfEqual, LearnMode, On
   {
      LearnModeTemp = 1
      ;force words to max of MaxLengthInLearnMode characters
      StringLeft, AddWord, AddWord, %MaxLengthInLearnMode%
   } else {
            IfEqual, ForceCountNewOnly, 1
               LearnModeTemp = 1
         }

   Ifequal, Addword,  ;If we have no word to add, skip out.
      Return
            
   if addword is space ;If addword is only whitespace, skip out.
      Return
   
   ;if addword does not contain at least one alpha character, skip out.
   if ( RegExMatch(addword, "S)[a-zA-Z]") = 0 )   
      Return
   
   if ( Substr(addword,1,1) = ";" ) ;If first char is ";", clear word and skip out.
   {
      IfEqual, LearnMode, On ;Check LearnMode here as we only do this if the wordlist is not done
      {
         IfEqual, wordlistdone, 0 ;If we are still reading the wordlist file and we come across ;LEARNEDWORDS; set the LearnedWordsCount flag
         {
            IfEqual, AddWord, `;LEARNEDWORDS`;
               {
                  LegacyLearnedWords=1 ; Set Flag that we need to convert wordlist file
                  IfEqual, LearnedWordsCount, 
                  {
                     LearnedWordsCount=0
                     wDB.EndTransaction()
                  }
               }
         }
      }
      Return
   }
   
   IF ( StrLen(addword) <= wlen ) ; don't add the word if it's not longer than the minimum length
   {
      Return
   }
   
   ifequal, wordlistdone, 1
   {
      IfNotEqual, LearnModeTemp, 1
         Return    
   }

   Base := ConvertWordToAscii(SubStr(addword,1,wlen),1)
   IfEqual, WordListDone, 0 ;if this is read from the wordlist
   {
      IfNotEqual,LearnedWordsCount,  ;if this is a stored learned word, this will only have a value when LearnedWords are read in from the wordlist
      {
         WhereQuery := "WHERE word = '" . addword . "'"
         QueryResult := wDB.Query("SELECT * FROM words " . WhereQuery . ";")
         IF !QueryResult  ; if we haven't yet added this word, add it to the count and list
         {
            IfEqual, LearnedWords,     ;if we haven't learned any words yet, set the LearnedWords list to the new word
            {
               LearnedWords = %addword%  
            } else {   ;otherwise append the learned word to the list
                     LearnedWords .= DelimiterChar . addword
                  }
            wDB.Query("INSERT INTO words VALUES ('" . base . "','" . addword . "','" . LearnedWordsCount++ . "');")
         }
      } else {
               wDB.Query("INSERT INTO words (hash,word) VALUES ('" . base . "','" . addword . "');")
            }
      
   } else { ; If this is an on-the-fly learned word
            AddWordInList := wDB.Query("SELECT * FROM words WHERE word = '" . AddWord . "';")
            
            IfEqual, AddWordInList, ; if the word is not in the list
            {
            
               IfNotEqual, ForceCountNewOnly, 1
               {
                  IF ( StrLen(addword) < LearnLength ) ; don't add the word if it's not longer than the minimum length for learning if we aren't force learning it
                     Return
               
                  if addword contains %ForceNewWordCharacters%
                     Return
                  
                  if addword contains %DoNotLearnStrings%
                     Return
                  
               }
               
               IfEqual, ForceCountNewOnly, 1
               {
                  CountValue = %LearnCount% ;set the count to LearnCount so it gets written to the file
               } else {
                        CountValue = 1   ;set the count to one as it's the first time we typed it
                     }
               
               IfEqual, LearnMode, On
               {
                  wDB.Query("INSERT INTO words VALUES ('" . base . "','" . addword . "','" . CountValue . "');")
               } else {
                        wDB.Query("INSERT INTO words (hash,word) VALUES ('" . base . "','" . addword . "');")
                     }
                     
               IfEqual, LearnedWords,    ;if we haven't learned any words yet, set the LearnedWords list to the new word
               {
                  LearnedWords = %addword%  
               } else {   ;otherwise append the learned word to the list
                        LearnedWords .= DelimiterChar . addword
                     }
               
               IfEqual, LearnMode, On
               {
                  IfEqual, ForceCountNewOnly, 1
                     UpdateWordCount(addword,1) ;re-sort the necessary words if it's a forced added word
               }
            } else {
                     IfEqual, LearnMode, On
                     {
                        IfEqual, ForceCountNewOnly, 1                     
                        {
                        
                           For each, row in AddWordList.Rows
                           {
                              CountValue := row[3]
                              break
                           }
                           
                           IF ( CountValue < LearnCount )
                           {
                              wDB.QUERY("UPDATE words SET count = ('" . LearnCount . "') WHERE word = '" . addword . "');")
                           }
                           UpdateWordCount(addWord,1)
                        } else {
                                 UpdateWordCount(addword,0) ;Increment the word count if it's already in the list and we aren't forcing it on
                              }
                     }
                  }
         }
   
   Return
}

DeleteWordFromList(DeleteWord)
{
   global
   
   Local Base
   Local DeleteWordInList
   Local CountWord
   Local Pos   
   Local OldStringCaseSense
   Local SearchableLearnedWords
   Local SearchDeleteWord
   Local CurrentNum
   Local NextNum

   Ifequal, DeleteWord,  ;If we have no word to delete, skip out.
      Return
            
   if DeleteWord is space ;If DeleteWord is only whitespace, skip out.
      Return
   
   IfNotEqual, LearnMode, On
      Return
   
   ; add surrounding delimiter chars
   SearchableLearnedWords = %DelimiterChar%%LearnedWords%%DelimiterChar%
   SearchDeleteWord = %DelimiterChar%%DeleteWord%%DelimiterChar%
   WordInLearnedWords := InStr(SearchableLearnedWords,SearchDeleteWord,CaseSensitive)
   
   IFEqual, WordInLearnedWords,
      Return
   
   ; Set Case Sensitive
   OldStringCaseSense := A_StringCaseSense
   StringCaseSense, On
   ;Remove word from LearnedWords if present   
   ; remove DeleteWord
   StringReplace, LearnedWords, SearchableLearnedWords, %DelimiterChar%%DeleteWord%%DelimiterChar%, %DelimiterChar%, All   
   ; remove surrounding delimiter chars
   StringTrimLeft, LearnedWords, LearnedWords, 1
   StringTrimRight, LearnedWords, LearnedWords, 1
   ; Restore old case sensitive setting
   StringCaseSense, %OldStringCaseSense%
   
   wDB.Query("DELETE FROM words WHERE word = '" . DeleteWord . "';")
      
   Return   
}

;------------------------------------------------------------------------

UpdateWordCount(word,SortOnly)
{
   global
   ;Word = Word to increment count for
   ;SortOnly = Only sort the words, don't increment the count
   
   ;Should only be called when LearnMode is on  
   IfEqual, LearnMode, Off
      Return
   
   IfEqual, SortOnly, 
      Return
   
   Local CountValue
   Local Query
   Local ValueType
   Local Values
   Local each
   Local row
   
   Query := wDB.Query("SELECT count FROM words WHERE word = '" . word . "';")
   
   For each, row in Query.Rows
   {
      CountValue := row[1]
      break
   }
   
   IfNotEqual, CountValue,
   {
      Query := wDB.Query("UPDATE words SET count = ('" . CountValue++ . "') WHERE word = '" . word . "';")
   }
   Return
}

;------------------------------------------------------------------------
      
ConvertWordToAscii(Base,Caps)
{
; Return the word in Hex Ascii or Unicode numbers padded to length 2 (ascii mode) or 4 (unicode mode) per character
; Capitalize the string if NoCaps is not set
   global AsciiPrefix
   global AsciiTrimLength
   IfEqual, Caps, 1
      StringUpper, Base, Base
   Critical, On
   SetFormat,Integer, H
   Loop, Parse, Base
   {
      IfEqual, A_FormatInteger, D
         SetFormat, Integer, H
      New .= SubStr( AsciiPrefix . SubStr(Asc(A_LoopField),3), AsciiTrimLength)
   }
   SetFormat,Integer,D
   Critical, Off
Return New
}

;------------------------------------------------------------------------

MaybeUpdateWordlist()
{
   global
    
   local TempWordList
   local SortWordList
   local AppendWord
   local LearnedwordsPos
   local ParseWords
   ; Update the Learned Words
   ;IfNotEqual, LearnedWords, 
   If (!1)
   {
      IfEqual, WordlistDone, 1
      {
         ; Parse the learned words and store them in a new list by count if their total count is greater than LearnCount.
         ; Prefix the word with the count and "z" for sorting
      
         IfEqual, LearnMode, Off
         {
            SortWordList := LearnedWords
         } else {
   
                  Loop, Parse, LearnedWords, %DelimiterChar%
                  { 
                     SortWord := ConvertWordToAscii(A_LoopField,0)
         
                     IfGreaterOrEqual, zCount%SortWord%, %LearnCount%
                     {
                        SortWordList .= DelimiterChar . zCount%SortWord% . "z" . A_LoopField
                     }
                  }
      
                  StringTrimLeft, SortWordList, SortWordList, 1 ;remove extra starting ASCII 2
   
                  Sort, SortWordList, N R D%DelimiterChar% ; Sort numerically, comma delimiter
               }
   
         IfNotEqual, SortWordList, ; If SortWordList exists write to the file, otherwise don't.
         {
				         
            Loop, Parse, SortWordList, %DelimiterChar%
            {
               IfEqual, LearnMode, On
               {
                  StringTrimLeft, AppendWord, A_LoopField, InStr(A_LoopField,"z") ;Strip (Number,"z") from beginning
               } else {
                        AppendWord := A_LoopField
                        }
               
               TempWordList .= AppendWord . "`r`n"
            }
                
            StringTrimRight, TempWordList, TempWordList, 2
   
            FileDelete, %A_ScriptDir%\Temp_WordlistLearned.txt
            FileAppendDispatch(TempWordList, A_ScriptDir . "\Temp_WordlistLearned.txt")
            FileCopy, %A_ScriptDir%\Temp_WordlistLearned.txt, %A_ScriptDir%\WordlistLearned.txt, 1
            FileDelete, %A_ScriptDir%\Temp_WordlistLearned.txt
         }
         
         ; Convert the Old Wordlist file to not have ;LEARNEDWORDS;
         IfEqual, LegacyLearnedWords, 1
         {
            TempWordList =
            FileRead, ParseWords, %A_ScriptDir%\Wordlist.txt
            LearnedwordsPos := InStr(ParseWords, "`;LEARNEDWORDS`;",true,1) ;Check for Learned Words
            TempWordList := SubStr(ParseWords, 1, LearnedwordsPos - 1) ;Grab all non-learned words out of list
            ParseWords = 
            FileDelete, %A_ScriptDir%\Temp_Wordlist.txt
            FileAppendDispatch(TempWordList, A_ScriptDir . "\Temp_Wordlist.txt")
            FileCopy, %A_ScriptDir%\Temp_Wordlist.txt, %A_ScriptDir%\Wordlist.txt, 1
            FileDelete, %A_ScriptDir%\Temp_Wordlist.txt
         }   
      }
   }
   
   wDb.Query("DROP INDEX temp.hash ON Words;"),
   wDB.Query("DROP TABLE Words;"),
   wDB.Close(),
   
}