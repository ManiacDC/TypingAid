; These functions and labels are related maintenance of the wordlist

ReadWordList()
{
   global g_LegacyLearnedWords
   global g_WordListDone
   global g_WordListDB
   ;mark the wordlist as not done
   g_WordListDone = 0
   
   Wordlist = %A_ScriptDir%\Wordlist.txt
   WordlistLearned = %A_ScriptDir%\WordlistLearned.txt
   
   MaybeFixFileEncoding(Wordlist,"UTF-8")
   MaybeFixFileEncoding(WordlistLearned,"UTF-8")

   g_WordListDB := DBA.DataBaseFactory.OpenDataBase("SQLite", A_ScriptDir . "\WordlistLearned.db" )
   if !g_WordListDB
   {
      msgbox Problem opening database '%A_ScriptDir%\WordlistLearned.db' - fatal error...
      exitapp
   }
   
   tableconverted := g_WordListDB.Query("SELECT tableconverted FROM LastState;")
   
   for each, row in tableconverted.Rows
   {
      WordlistConverted := row[1]
   }
   
   IfNotEqual, WordlistConverted, 1
   {
      g_WordListDB.Query("DROP TABLE Words;")
      g_WordListDB.Query("DROP INDEX WordIndex;")
      g_WordListDB.Query("DROP TABLE LastState;")
      
      IF not g_WordListDB.Query("CREATE TABLE Words (wordindexed TEXT, word TEXT UNIQUE, count INTEGER);")
      {
         msgbox Cannot Create Table - fatal error...
         ExitApp
      }
   
      IF not g_WordListDB.Query("CREATE INDEX WordIndex ON Words (wordindexed);")
      {
         msgbox Cannot Create Index - fatal error...
         ExitApp
      }
   
      IF not g_WordListDB.Query("CREATE TABLE LastState (tableconverted INTEGER);")
      {
         MsgBox Cannot Create Table - fatal error...
         ExitApp
      }
   } else
   {
      CleanupWordList()
   }
   
   g_WordListDB.BeginTransaction()
   ;reads list of words from file 
   FileRead, ParseWords, %Wordlist%
   Loop, Parse, ParseWords, `n, `r
   {
      IfEqual, A_LoopField, `;LEARNEDWORDS`;
      {
         IfEqual, WordlistConverted, 1
         {
            break
         } Else {
            LearnedWordsCount=0
            g_LegacyLearnedWords=1 ; Set Flag that we need to convert wordlist file
         }
      } else {
               AddWordToList(A_LoopField,0,"ForceLearn",LearnedWordsCount)
            }
   }
   ParseWords =
   g_WordListDB.EndTransaction()
   
   IfNotEqual, WordlistConverted, 1
   {
      Progress, M, Please wait..., Converting wordlist, %A_ScriptName%
    
      ;Force LearnedWordsCount to 0 if not already set as we are now processing Learned Words
      IfEqual, LearnedWordsCount,
      {
         LearnedWordsCount=0
      }
      
      g_WordListDB.BeginTransaction()
      ;reads list of words from file 
      FileRead, ParseWords, %WordlistLearned%
      Loop, Parse, ParseWords, `n, `r
      {
         
         AddWordToList(A_LoopField,0,"ForceLearn",LearnedWordsCount)
      }
      ParseWords =
      g_WordListDB.EndTransaction()
      
      Progress, 50, Please wait..., Converting wordlist, %A_ScriptName%

      ;reverse the numbers of the word counts in memory
      ReverseWordNums(LearnedWordsCount)
      
      g_WordListDB.Query("INSERT INTO LastState VALUES ('1');")
      
      Progress, Off
   }

   ;mark the wordlist as completed
   g_WordlistDone = 1
   Return
}

;------------------------------------------------------------------------

ReverseWordNums(LearnedWordsCount)
{
   ; This function will reverse the read numbers since now we know the total number of words
   global prefs_LearnCount
   global g_WordListDB

   LearnedWordsCount+= (prefs_LearnCount - 1)

   LearnedWordsTable := g_WordListDB.Query("SELECT word FROM Words WHERE count IS NOT NULL;")

   g_WordListDB.BeginTransaction()
   For each, row in LearnedWordsTable.Rows
   {
      WhereQuery := "WHERE word = '" . row[1] . "'"
      g_WordListDB.Query("UPDATE words SET count = (SELECT " . LearnedWordsCount . " - count FROM words " . WhereQuery . ") " . WhereQuery . ";")
   }
   g_WordListDB.EndTransaction()

   Return
   
}

;------------------------------------------------------------------------

AddWordToList(AddWord,ForceCountNewOnly,ForceLearn=false, ByRef LearnedWordsCount = false)
{
   ;AddWord = Word to add to the list
   ;ForceCountNewOnly = force this word to be permanently learned even if learnmode is off
   ;ForceLearn = disables some checks in CheckValid
   global prefs_DoNotLearnStrings
   global prefs_ForceNewWordCharacters
   global prefs_LearnCount
   global prefs_LearnLength
   global prefs_LearnMode
   global g_WordListDone
   global g_WordListDB
   
   StringUpper, AddWordIndex, AddWord
         
   if !(CheckValid(AddWord,ForceLearn))
      return

   IfEqual, g_WordListDone, 0 ;if this is read from the wordlist
   {
      IfNotEqual,LearnedWordsCount,  ;if this is a stored learned word, this will only have a value when LearnedWords are read in from the wordlist
      {
         g_WordListDB.Query("INSERT INTO words VALUES ('" . AddWordIndex . "','" . AddWord . "','" . LearnedWordsCount++ . "');")
      } else {
         g_WordListDB.Query("INSERT INTO words (wordindexed,word) VALUES ('" . AddWordIndex . "','" . AddWord . "');")
      }
      
   } else if (prefs_LearnMode = "On" || ForceCountNewOnly == 1)
   { 
      ; If this is an on-the-fly learned word
      AddWordInList := g_WordListDB.Query("SELECT * FROM words WHERE word = '" . AddWord . "';")
      
      IF !( AddWordInList.Count() ) ; if the word is not in the list
      {
      
         IfNotEqual, ForceCountNewOnly, 1
         {
            IF (StrLen(AddWord) < prefs_LearnLength) ; don't add the word if it's not longer than the minimum length for learning if we aren't force learning it
               Return
            
            if AddWord contains %prefs_ForceNewWordCharacters%
               Return
                  
            if AddWord contains %prefs_DoNotLearnStrings%
               Return
                  
            CountValue = 1
                  
         } else {
            CountValue := prefs_LearnCount ;set the count to LearnCount so it gets written to the file
         }
         
         IfEqual, prefs_LearnMode, On
         {
            g_WordListDB.Query("INSERT INTO words VALUES ('" . AddWordIndex . "','" . AddWord . "','" . CountValue . "');")
         } else {
            g_WordListDB.Query("INSERT INTO words (wordindexed,word) VALUES ('" . AddWordIndex . "','" . AddWord . "');")
         }
      } else {
         IfEqual, prefs_LearnMode, On
         {
            IfEqual, ForceCountNewOnly, 1                     
            {
               For each, row in AddWordInList.Rows
               {
                  CountValue := row[3]
                  break
               }
               
               IF ( CountValue < prefs_LearnCount )
               {
                  g_WordListDB.QUERY("UPDATE words SET count = ('" . prefs_LearnCount . "') WHERE word = '" . AddWord . "');")
               }
            } else {
               UpdateWordCount(AddWord,0) ;Increment the word count if it's already in the list and we aren't forcing it on
            }
         }
      }
   }
   
   Return
}

CheckValid(Word,ForceLearn=false)
{
   
   Ifequal, Word,  ;If we have no word to add, skip out.
      Return
            
   if Word is space ;If Word is only whitespace, skip out.
      Return
   
   if ( Substr(Word,1,1) = ";" ) ;If first char is ";", clear word and skip out.
   {
      Return
   }
   
   IF ( StrLen(Word) <= prefs_Length ) ; don't add the word if it's not longer than the minimum length
   {
      Return
   }
   
   ;Anything below this line should not be checked if we want to Force Learning the word (Ctrl-Shift-C or coming from wordlist.txt)
   If ForceLearn
      Return, 1
   
   ;if Word does not contain at least one alpha character, skip out.
   IfEqual, A_IsUnicode, 1
   {
      if ( RegExMatch(Word, "S)\pL") = 0 )  
      {
         return
      }
   } else if ( RegExMatch(Word, "S)[a-zA-Zà-öø-ÿÀ-ÖØ-ß]") = 0 )
   {
      Return
   }
   
   Return, 1
}

DeleteWordFromList(DeleteWord)
{
   global prefs_LearnMode
   global g_WordListDB
   
   Ifequal, DeleteWord,  ;If we have no word to delete, skip out.
      Return
            
   if DeleteWord is space ;If DeleteWord is only whitespace, skip out.
      Return
   
   IfNotEqual, prefs_LearnMode, On
      Return
   
   g_WordListDB.Query("DELETE FROM words WHERE word = '" . DeleteWord . "';")
      
   Return   
}

;------------------------------------------------------------------------

UpdateWordCount(word,SortOnly)
{
   global prefs_LearnMode
   global g_WordListDB
   ;Word = Word to increment count for
   ;SortOnly = Only sort the words, don't increment the count
   
   ;Should only be called when LearnMode is on  
   IfEqual, prefs_LearnMode, Off
      Return
   
   IfEqual, SortOnly, 
      Return
   
   WhereQuery := "WHERE word = '" . word . "'"
   g_WordListDB.Query("UPDATE words SET count = (SELECT count + 1 FROM words " . WhereQuery . ") " . WhereQuery . ";")
   
   Return
}

;------------------------------------------------------------------------

CleanupWordList()
{
   global prefs_LearnCount
   global g_WordListDB
   g_WordListDB.Query("DELETE FROM Words WHERE count < " . prefs_LearnCount . " OR count IS NULL;")
}

;------------------------------------------------------------------------

MaybeUpdateWordlist()
{
   global g_LegacyLearnedWords
   global g_WordListDB
   global g_WordListDone
   
   ; Update the Learned Words
   IfEqual, g_WordListDone, 1
   {
      
      CleanupWordList()
      
      SortWordList := g_WordListDB.Query("SELECT Word FROM Words ORDER BY count DESC;")
      
      for each, row in SortWordList.Rows
      {
         TempWordList .= row[1] . "`r`n"
      }
      
      If ( SortWordList.Count() > 0 )
      {
         StringTrimRight, TempWordList, TempWordList, 2
   
         FileDelete, %A_ScriptDir%\Temp_WordlistLearned.txt
         FileAppendDispatch(TempWordList, A_ScriptDir . "\Temp_WordlistLearned.txt")
         FileCopy, %A_ScriptDir%\Temp_WordlistLearned.txt, %A_ScriptDir%\WordlistLearned.txt, 1
         FileDelete, %A_ScriptDir%\Temp_WordlistLearned.txt
         
         ; Convert the Old Wordlist file to not have ;LEARNEDWORDS;
         IfEqual, g_LegacyLearnedWords, 1
         {
            TempWordList =
            FileRead, ParseWords, %A_ScriptDir%\Wordlist.txt
            LearnedWordsPos := InStr(ParseWords, "`;LEARNEDWORDS`;",true,1) ;Check for Learned Words
            TempWordList := SubStr(ParseWords, 1, LearnedwordsPos - 1) ;Grab all non-learned words out of list
            ParseWords = 
            FileDelete, %A_ScriptDir%\Temp_Wordlist.txt
            FileAppendDispatch(TempWordList, A_ScriptDir . "\Temp_Wordlist.txt")
            FileCopy, %A_ScriptDir%\Temp_Wordlist.txt, %A_ScriptDir%\Wordlist.txt, 1
            FileDelete, %A_ScriptDir%\Temp_Wordlist.txt
         }   
      }
   }
   
   g_WordListDB.Close(),
   
}