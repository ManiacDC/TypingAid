; These functions and labels are related to sending the word to the program

SendKey(Key)
{
   IfEqual, Key, $^Enter
   {
      Key = ^{Enter}
   } else IfEqual, Key, $^Space
   { 
      Key = ^{Space}
   } else {
      Key := "{" . SubStr(Key, 2) . "}"
   }
   
   SendCompatible(Key,1)
   Return
}

;------------------------------------------------------------------------
   
SendWord(WordIndex)
{
   global g_SingleMatch
   global g_SingleMatchReplacement
   ;Send the word
   if (g_SingleMatchReplacement[WordIndex])
   {
      sending := g_SingleMatchReplacement[WordIndex]
      ForceBackspace := true
   } else {
      sending := g_SingleMatch[WordIndex]
      ForceBackspace := false
   }
   ; Update Typed Count
   UpdateWordCount(sending,0)
   SendFull(sending, ForceBackspace)   
   ClearAllVars(true)
   Return
}  

;------------------------------------------------------------------------
            
SendFull(SendValue,ForceBackspace=false)
{
   global g_Active_Id
   global g_Word
   global prefs_AutoSpace
   global prefs_NoBackSpace
   global prefs_SendMethod
   
   SwitchOffListBoxIfActive()
   
   BackSpaceLen := StrLen(g_Word)
   
   if (ForceBackspace || prefs_NoBackspace = "Off") {
      BackSpaceWord := true
   }
   
   ; match case on first letter if we are forcing a backspace AND CaseCorrection is off
   if (ForceBackspace && !(prefs_NoBackspace = "Off")) {
      IfEqual, A_IsUnicode, 1
      {
         if ( RegExMatch(Substr(g_Word, 1, 1), "S)\p{Lu}") > 0 )  
         {
            Capitalize := true
         }
      } else if ( RegExMatch(Substr(g_Word, 1, 1), "S)[A-ZР-жи-п]") > 0 )
      {
         Capitalize := true
      }
      
      StringLeft, FirstLetter, SendValue, 1
         StringTrimLeft, SendValue, SendValue, 1
      if (Capitalize) {
         StringUpper, FirstLetter, FirstLetter
      } else {
         StringLower, FirstLetter, FirstLetter
      }
      SendValue := FirstLetter . SendValue
   }
   
   ; if the user chose a word with accented characters, then we need to
   ; substitute those letters into the word
   StringCaseSenseOld := A_StringCaseSense
   StringCaseSense, Locale   
   if (!BackSpaceWord && !(SubStr(SendValue, 1, BackSpaceLen) = g_Word)) {
      BackSpaceWord := true
      
      SendIndex := 1
      WordIndex := 1
      NewSendValue =
      While (WordIndex <= BackSpaceLen) {
         SendChar := SubStr(SendValue, SendIndex, 1)
         WordChar := SubStr(g_Word, WordIndex, 1)
         SendIndex++
         
         if (SendChar = WordChar) {
            WordIndex++
            NewSendValue .= WordChar
         } else {
            
            SendCharNorm := StrUnmark(SendChar)
            ; if character normalizes to more than 1 character, we need
            ; to increment the WordIndex pointer again
            
            StringUpper, SendCharNormUpper, SendCharNorm
            StringLower, SendCharNormLower, SendCharNorm
            StringUpper, SendCharUpper, SendChar
            StringLower, SendCharLower, SendChar
            WordChar := SubStr(g_Word, WordIndex, StrLen(SendCharNorm))
            
            if (SendCharNorm == WordChar) {
               NewSendValue .= SendChar
            } else if (SendCharNormUpper == WordChar) {
               NewSendValue .= SendCharUpper
            } else if (SendCharNormLower == WordChar) {
               NewSendValue .= SendCharLower
            } else {
               NewSendValue .= SendChar
            }
            WordIndex += StrLen(SendCharNorm)
         }
      }
      
      NewSendValue .= SubStr(SendValue, SendIndex, StrLen(SendValue) - SendIndex + 1)
      
      SendValue := NewSendValue
   }
   StringCaseSense, %StringCaseSenseOld%
   
   ; If we are not backspacing, remove the typed characters from the string to send
   if !(BackSpaceWord)
   {
      StringTrimLeft, SendValue, SendValue, %BackSpaceLen%
   }
   
   ; if autospace is on, add a space to the string to send
   IfEqual, prefs_AutoSpace, On
      SendValue .= A_Space
   
   IfEqual, prefs_SendMethod, 1
   {
      ; Shift key hits are here to account for an occassional bug which misses the first keys in SendPlay
      sending = {Shift Down}{Shift Up}{Shift Down}{Shift Up}      
      if (BackSpaceWord)
      {
         sending .= "{BS " . BackSpaceLen . "}"
      }
      sending .= "{Raw}" . SendValue
         
      SendPlay, %sending% ; First do the backspaces, Then send word (Raw because we want the string exactly as in wordlist.txt) 
      Return
   }

   if (BackSpaceWord)
   {
      sending = {BS %BackSpaceLen%}{Raw}%SendValue%
   } Else {
      sending = {Raw}%SendValue%
   }
   
   IfEqual, prefs_SendMethod, 2
   {
      SendInput, %sending% ; First do the backspaces, Then send word (Raw because we want the string exactly as in wordlist.txt)      
      Return
   }

   IfEqual, prefs_SendMethod, 3
   {
      SendEvent, %sending% ; First do the backspaces, Then send word (Raw because we want the string exactly as in wordlist.txt) 
      Return
   }
   
   ClipboardSave := ClipboardAll
   Clipboard = 
   Clipboard := SendValue
   ClipWait, 0
   
   if (BackSpaceWord)
   {
      sending = {BS %BackSpaceLen%}{Ctrl Down}v{Ctrl Up}
   } else {
   sending = {Ctrl Down}v{Ctrl Up}
   }
   
   IfEqual, prefs_SendMethod, 1C
   {
      sending := "{Shift Down}{Shift Up}{Shift Down}{Shift Up}" . sending
      SendPlay, %sending% ; First do the backspaces, Then send word via clipboard
   } else IfEqual, prefs_SendMethod, 2C
   {
      SendInput, %sending% ; First do the backspaces, Then send word via clipboard
   } else IfEqual, prefs_SendMethod, 3C
   {
      SendEvent, %sending% ; First do the backspaces, Then send word via clipboard
   } else {
      ControlGetFocus, ActiveControl, ahk_id %g_Active_Id%
      IfNotEqual, ActiveControl,
         ControlSend, %ActiveControl%, %sending%, ahk_id %g_Active_Id%
   }
         
   Clipboard := ClipboardSave
   Return
}

;------------------------------------------------------------------------

SendCompatible(SendValue,ForceSendForInput)
{
   global g_IgnoreSend
   global prefs_SendMethod
   IfEqual, ForceSendForInput, 1
   {
      g_IgnoreSend = 
      SendEvent, %SendValue%
      Return
   }
   
   SendMethodLocal := SubStr(prefs_SendMethod, 1, 1)
   IF ( ( SendMethodLocal = 1 ) || ( SendMethodLocal = 2 ) )
   {
      SendInput, %SendValue%
      Return
   }

   IF ( ( SendMethodLocal = 3 ) || ( SendMethodLocal = 4 ) )
   {
      g_IgnoreSend = 1
      SendEvent, %SendValue%
      Return
   }
   
   SendInput, %SendValue%   
   Return
}

;------------------------------------------------------------------------