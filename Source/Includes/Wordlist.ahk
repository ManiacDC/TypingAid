; These functions and labels are related maintenance of the wordlist

ReadWordList()
{
   global
   ;mark the wordlist as not done
   WordListDone = 0
   
   Local ParseWords
   Local LearnedWordsTable
   Local TempAddToLearned
   Local each
   Local row
   Local WordList
   Local WordlistLearned
   Local tableconverted
   Local WordlistConverted
   
   Wordlist = %A_ScriptDir%\Wordlist.txt
   WordlistLearned = %A_ScriptDir%\WordlistLearned.txt
   
   MaybeFixFileEncoding(Wordlist,"UTF-8")
   MaybeFixFileEncoding(WordlistLearned,"UTF-8")

   wDB := DBA.DataBaseFactory.OpenDataBase("SQLite", A_ScriptDir . "\WordlistLearned.db" )
   if !wDB
   {
      msgbox Problem opening database '%A_ScriptDir%\WordlistLearned.db' - fatal error...
      exitapp
   }
   
   tableconverted := wDB.Query("SELECT tableconverted FROM LastState;")
   
   for each, row in tableconverted.Rows
   {
      WordlistConverted := row[1]
   }
   
   IfNotEqual, WordlistConverted, 1
   {
      wDB.Query("DROP TABLE Words;")
      wDB.Query("DROP INDEX WordIndex;")
      wDB.Query("DROP TABLE LearnedWords;")
      wDB.Query("DROP TABLE LastState;")
      
      IF not wDB.Query("CREATE TABLE Words (wordindexed TEXT, word TEXT UNIQUE, count INTEGER);")
      ;IF not wDB.Query("CREATE TABLE Words (wordindexed TEXT, word TEXT UNIQUE, count INTEGER);")
      {
         msgbox Cannot Create Table - fatal error...
         ExitApp
      }
   
      IF not wDB.Query("CREATE INDEX WordIndex ON Words (wordindexed);")
      ;IF not wDB.Query("CREATE INDEX WordIndex ON Words (wordindexed);")
      {
         msgbox Cannot Create Index - fatal error...
         ExitApp
      }
   
      IF not wDB.Query("CREATE TABLE LastState (tableconverted INTEGER);")
      ;IF not wDB.Query("CREATE TABLE LearnedWords (learnedword TEXT UNIQUE);")
      {
         MsgBox Cannot Create Table - fatal error...
         ExitApp
      }
   } else
   {
      wDB.Query("DELETE FROM Words WHERE count IS NULL;")
      wDB.Query("DELETE FROM Words WHERE count < " . LearnCount . ";")
   }
   
   wDB.BeginTransaction()
   ;reads list of words from file 
   FileRead, ParseWords, %Wordlist%
   Loop, Parse, ParseWords, `n, `r
   {
      IfEqual, A_LoopField, `;LEARNEDWORDS`;
      {
         IfEqual, WordlistConverted, 1
         {
            break
         } Else IfEqual, LearnMode, On
         {
            LearnedWordsCount=0
            LegacyLearnedWords=1 ; Set Flag that we need to convert wordlist file
         }
      } else {
                  AddWordToList(A_LoopField,0)
            }
   }
   ParseWords =
   wDB.EndTransaction()
   
   IfNotEqual, WordlistConverted, 1
   {
      Progress, M, Please wait..., Converting wordlist, %A_ScriptName%
    
      ;Force LearnedWordsCount to 0 if not already set as we are now processing Learned Words
      IfEqual, LearnedWordsCount,
      {
         LearnedWordsCount=0
      }
      
      wDB.BeginTransaction()
      ;reads list of words from file 
      FileRead, ParseWords, %WordlistLearned%
      Loop, Parse, ParseWords, `n, `r
      {
         
         AddWordToList(A_LoopField,0)
      }
      ParseWords =
      wDB.EndTransaction()
      
      Progress, 50, Please wait..., Converting wordlist, %A_ScriptName%

      ;reverse the numbers of the word counts in memory
      GoSub, ReverseWordNums
      
      wDB.Query("INSERT INTO LastState VALUES ('1');")
      
      Progress, Off
   }

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

LearnedWordsCount+= (LearnCount - 1)

LearnedWordsTable := wDB.Query("SELECT word FROM Words WHERE count IS NOT NULL;")

wDB.BeginTransaction()
For each, row in LearnedWordsTable.Rows
{
   WhereQuery := "WHERE word = '" . row[1] . "'"
   wDB.Query("UPDATE words SET count = (SELECT " . LearnedWordsCount . " - count FROM words " . WhereQuery . ") " . WhereQuery . ";")
}
wDB.EndTransaction()

each=
row=
LearnedWordsTable =
LearnedWordsCount = 

Return

;------------------------------------------------------------------------

AddWordToList(AddWord,ForceCountNewOnly)
{
   ;AddWord = Word to add to the list
   ;ForceCountNewOnly = force this word to be permanently learned even if learnmode is off
   global
   Local CharTerminateList
   Local AddWordInList
   Local CountWord
   Local pos
   Local LearnModeTemp
   Local WhereQuery
   Local QueryResult
   Local CountValue
   Local each
   Local row
   Local AddWordIndex
   
   StringUpper, AddWordIndex, AddWord
   
   IfEqual, LearnMode, On
   {
      LearnModeTemp = 1
   } else {
            IfEqual, ForceCountNewOnly, 1
               LearnModeTemp = 1
         }
         
   if !(CheckValid(AddWord))
      return
   
   ifequal, wordlistdone, 1
   {
      IfNotEqual, LearnModeTemp, 1
         Return    
   }

   IfEqual, WordListDone, 0 ;if this is read from the wordlist
   {
      IfNotEqual,LearnedWordsCount,  ;if this is a stored learned word, this will only have a value when LearnedWords are read in from the wordlist
      {
         wDB.Query("INSERT INTO words VALUES ('" . AddWordIndex . "','" . AddWord . "','" . LearnedWordsCount++ . "');")
      } else {
               wDB.Query("INSERT INTO words (wordindexed,word) VALUES ('" . AddWordIndex . "','" . AddWord . "');")
            }
      
   } else { ; If this is an on-the-fly learned word
            AddWordInList := wDB.Query("SELECT * FROM words WHERE word = '" . AddWord . "';")
            
            IF !( AddWordInList.Count() ) ; if the word is not in the list
            {
            
               IfNotEqual, ForceCountNewOnly, 1
               {
                  IF ( StrLen(AddWord) < LearnLength ) ; don't add the word if it's not longer than the minimum length for learning if we aren't force learning it
                     Return
               
                  if AddWord contains %ForceNewWordCharacters%
                     Return
                  
                  if AddWord contains %DoNotLearnStrings%
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
                  wDB.Query("INSERT INTO words VALUES ('" . AddWordIndex . "','" . AddWord . "','" . CountValue . "');")
               } else {
                        wDB.Query("INSERT INTO words (wordindexed,word) VALUES ('" . AddWordIndex . "','" . AddWord . "');")
                     }
            } else {
                     IfEqual, LearnMode, On
                     {
                        IfEqual, ForceCountNewOnly, 1                     
                        {
                        
                           For each, row in AddWordInList.Rows
                           {
                              CountValue := row[3]
                              break
                           }
                           
                           IF ( CountValue < LearnCount )
                           {
                              wDB.QUERY("UPDATE words SET count = ('" . LearnCount . "') WHERE word = '" . AddWord . "');")
                           }
                        } else {
                                 UpdateWordCount(AddWord,0) ;Increment the word count if it's already in the list and we aren't forcing it on
                              }
                     }
                  }
         }
   
   Return
}

CheckValid(Word)
{
   
   Ifequal, Word,  ;If we have no word to add, skip out.
      Return
            
   if Word is space ;If Word is only whitespace, skip out.
      Return
   
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
   
   if ( Substr(Word,1,1) = ";" ) ;If first char is ";", clear word and skip out.
   {
      Return
   }
   
   IF ( StrLen(Word) <= wlen ) ; don't add the word if it's not longer than the minimum length
   {
      Return
   }
   
   Return, 1
}

DeleteWordFromList(DeleteWord)
{
   global
   
   Ifequal, DeleteWord,  ;If we have no word to delete, skip out.
      Return
            
   if DeleteWord is space ;If DeleteWord is only whitespace, skip out.
      Return
   
   IfNotEqual, LearnMode, On
      Return
   
   wDB.Query("DELETE FROM words WHERE word = '" . DeleteWord . "';")
      
   Return   
}

;------------------------------------------------------------------------

UpdateWordCount(word,SortOnly)
{
   global
   Local WhereQuery
   ;Word = Word to increment count for
   ;SortOnly = Only sort the words, don't increment the count
   
   ;Should only be called when LearnMode is on  
   IfEqual, LearnMode, Off
      Return
   
   IfEqual, SortOnly, 
      Return
   
   WhereQuery := "WHERE word = '" . word . "'"
   wDB.Query("UPDATE words SET count = (SELECT count + 1 FROM words " . WhereQuery . ") " . WhereQuery . ";")
   
   Return
}

;------------------------------------------------------------------------

MaybeUpdateWordlist()
{
   global
    
   local TempWordList
   local SortWordList
   local LearnedWordsPos
   local ParseWords
   Local each
   Local row
   ; Update the Learned Words
   IfEqual, WordListDone, 1
   {
      
      wDB.Query("DELETE FROM Words WHERE count IS NULL;")
      wDB.Query("DELETE FROM Words WHERE count < " . LearnCount . ";")
      
      SortWordList := wDB.Query("SELECT Word FROM Words ORDER BY count DESC;")
      
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
         IfEqual, LegacyLearnedWords, 1
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
   
   wDB.Close(),
   
}