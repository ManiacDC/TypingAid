; These functions and labels are related maintenance of the wordlist

ReadWordList()
{
   global
   ;mark the wordlist as not done
   WordListDone = 0

   ;reads list of words from file 
   FileRead, ParseWords, %A_ScriptDir%\Wordlist.txt
   Loop, Parse, ParseWords, `n, `r
   {
      AddWordToList(A_LoopField,0)
   }
   ParseWords =
    
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
   
LearnedWordsCount+=4
Loop,parse,LearnedWords, %DelimiterChar%
{
   AsciiWord := ConvertWordToAscii(A_LoopField,0)
   zCount%AsciiWord% := LearnedWordsCount - zCount%AsciiWord%
}

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
   
   IfEqual, LearnMode, On
   {
      LearnModeTemp = 1
      ;force words to max of MaxLengthInLearnMode characters
      StringLeft, AddWord, AddWord, %MaxLengthInLearnMode%
   } else {
            IfEqual, ForceCountNewOnly, 1
               LearnModeTemp = 1
         }

   Ifequal, AddWord,  ;If we have no word to add, skip out.
      Return
            
   if AddWord is space ;If addword is only whitespace, skip out.
      Return
   
   ;if addword does not contain at least one alpha character, skip out.
   IfEqual, A_IsUnicode, 1
   {
      if ( RegExMatch(AddWord, "S)\pL") = 0 )  
      {
         return
      }
   } else if ( RegExMatch(AddWord, "S)[a-zA-Zà-öø-ÿÀ-ÖØ-ß]") = 0 )
   {
      Return
   }
   
   if ( Substr(AddWord,1,1) = ";" ) ;If first char is ";", clear word and skip out.
   {
      IfEqual, LearnMode, On ;Check LearnMode here as we only do this if the wordlist is not done
      {
         IfEqual, wordlistdone, 0 ;If we are still reading the wordlist file and we come across ;LEARNEDWORDS; set the LearnedWordsCount flag
         {
            IfEqual, AddWord, `;LEARNEDWORDS`;
               {
                  LegacyLearnedWords=1 ; Set Flag that we need to convert wordlist file
                  IfEqual, LearnedWordsCount, 
                     LearnedWordsCount=0
               }
         }
      }
      Return
   }
   
   IF ( StrLen(AddWord) <= wlen ) ; don't add the word if it's not longer than the minimum length
   {
      Return
   }
   
   ifequal, wordlistdone, 1
   {
      IfNotEqual, LearnModeTemp, 1
         Return    
   }

   Base := ConvertWordToAscii(SubStr(AddWord,1,wlen),1)
   IfEqual, WordListDone, 0 ;if this is read from the wordlist
   {
      IfNotEqual,LearnedWordsCount,  ;if this is a stored learned word, this will only have a value when LearnedWords are read in from the wordlist
      {
         CountWord := ConvertWordToAscii(AddWord,0)
         IfEqual,zCount%CountWord%,  ; if we haven't yet added this word, add it to the count and list
         {
            IfEqual, LearnedWords,     ;if we haven't learned any words yet, set the LearnedWords list to the new word
            {
               LearnedWords = %addword%  
            } else {   ;otherwise append the learned word to the list
                     LearnedWords .= DelimiterChar . addword
                  }
            zCount%CountWord% := LearnedWordsCount++    ;increment the count and store the Weight of the LearnedWord in reverse order (will be inverted later)
         }
      }
      IncrementCounterAndAddWord(Base,AddWord)
      
   } else { ; If this is an on-the-fly learned word
            AddWordInList := CheckIfWordInList(Base,AddWord)
            
            IfEqual, AddWordInList, ; if the word is not in the list
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
            
               IfEqual, LearnMode, On
               {
                  CountWord := ConvertWordToAscii(addWord,0)
                  IfEqual, ForceCountNewOnly, 1
                  {
                     zCount%CountWord% = %LearnCount% ;set the count to LearnCount so it gets written to the file
                  } else {
                           zCount%CountWord% = 1   ;set the count to one as it's the first time we typed it
                        }
               }
               IfEqual, LearnedWords,    ;if we haven't learned any words yet, set the LearnedWords list to the new word
               {
                  LearnedWords = %AddWord%  
               } else {   ;otherwise append the learned word to the list
                        LearnedWords .= DelimiterChar . AddWord
                     }
               IncrementCounterAndAddWord(Base,AddWord)
               
               IfEqual, LearnMode, On
               {
                  IfEqual, ForceCountNewOnly, 1
                     UpdateWordCount(AddWord,1) ;resort the necessary words if it's a forced added word
               }
            } else {
                     IfEqual, LearnMode, On
                     {                  
                        IfEqual, ForceCountNewOnly, 1                     
                        {
                           CountWord := ConvertWordToAscii(AddWord,0)
                           IF ( zCount%CountWord% < LearnCount )
                              zCount%CountWord% = %LearnCount%
                           UpdateWordCount(AddWord,1)
                        } else {
                                 UpdateWordCount(AddWord,0) ;Increment the word count if it's already in the list and we aren't forcing it on
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
   
   Base := ConvertWordToAscii(SubStr(DeleteWord,1,wlen),1)
   
   DeleteWordInList := CheckIfWordInList(Base,DeleteWord)
   
   IFEqual, DeleteWordInList,  ;If the word is not in the list, skip out.
      Return
   
   CountWord := ConvertWordToAscii(DeleteWord,0)
   
   zCount%CountWord% =
   
   CurrentNum := zbasenum%base%
   
   Loop
   {
      IFEqual, CurrentNum, 0, Break
      
      IF ( zword%base%%CurrentNum% == DeleteWord )
      {
         Loop
         {
            NextNum := CurrentNum +1
            IF ( NextNum = zbasenum%base% +1 )
               Break
            zword%base%%CurrentNum% := zword%base%%NextNum%
            CurrentNum ++
         }
         zword%base%%CurrentNum% = 
         zbasenum%base% := zbasenum%base% - 1
         Break
      }
      CurrentNum--
      Continue
         
       
;      IfEqual, zword%base%%a_index%,, Break
;      IF ( zword%base%%a_index% == DeleteWord )
 ;     {
  ;       zword%base%%a_index% =
   ;      DeletedCount++
    ;  } else {
         ;      IfGreaterOrEqual, DeletedCount, 1
     ;;;          {
        ;          DeletedIndex := a_index - DeletedCount
        ;          zword%base%%DeletedIndex% := zword%base%%a_index%
         ;         zword%base%%a_index% = 
          ;     }
           ; }
      
      ;Continue
   }
      
   Return   
}

;------------------------------------------------------------------------

IncrementCounterAndAddWord(Base,AddWord)
{
   global
   local pos
   ; Increment the counter for each hash
   zbasenum%Base%++        
   pos := zbasenum%Base%
   ; Set the hashed value to the word
   zword%Base%%pos% = %addword%
}

CheckIfWordInList(Base,AddWord)
{
   local AddWordInList
   
   Loop ;Check to see if the word is already in the list, case sensitive
   {
      IfEqual, zword%base%%a_index%,, Break
      if ( zword%base%%a_index% == AddWord )
      {
         AddWordInList = 1
         Break
      }            
      Continue            
   }
   Return AddWordInList
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
   
   ;force words to max of MaxLengthInLearnMode characters
   StringLeft, Word, Word, %MaxLengthInLearnMode%
   
   ; If the Count for the word already exists - ie if it's a learned word, increment it, else don't.
   local CountWord := ConvertWordToAscii(word,0)
   IfNotEqual, zCount%CountWord%,
   {
      IfNotEqual, SortOnly, 1 ;don't increment the count if we only want to sort the words
         zCount%CountWord%++  
      local WordBase
      StringLeft, WordBase, word, %wlen% ;find the pseudohash for the word
      WordBase := ConvertWordToAscii(WordBase,1)
      Local ConvertWord = 
      Local LowIndex = 
      Local WordList = 
      Loop
      {
         ifequal, zword%WordBase%%A_Index%, ;Break the loop if no more words to read for the hash
            Break
         CountWord := zword%WordBase%%A_Index% ;Set CountWord to the current Word position
         ConvertWord := ConvertWordToAscii(CountWord,0) ; Find the Ascii equivalent of the word
         IfNotEqual, zCount%ConvertWord%,  ;If there's no count for this word do nothing
         {
            IfEqual, LowIndex,
               LowIndex = %A_Index% ;If this is the first word we've found with a count set this as our starting position
               
            WordList .= DelimiterChar . zCount%ConvertWord% . "z" . CountWord ;prefix all words with (zCount"z")
         }
      }
      
      ifnotequal, Wordlist, ;If we have no words to process, don't
      {
         StringTrimLeft, WordList, WordList, 1
         Sort, WordList, N R D%DelimiterChar% ;Sort the wordlist by order of 
         
         LowIndex-- ;A_Index starts at 1 so this value needs to be decremented
         Local IndexPos = 
         Loop, Parse, WordList, %DelimiterChar%
         {
            IndexPos := LowIndex + A_Index ;Set the current word we are processing to the starting pos plus word position
            StringTrimLeft, CountWord, A_LoopField, InStr(A_LoopField,"z") ;Strip (Number,"z") from beginning
            zword%WordBase%%IndexPos% = %CountWord% ; update the word in the list
            
         }
      }
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
   IfNotEqual, LearnedWords, 
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
   
}