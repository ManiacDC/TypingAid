; These functions and labels are related to sending the word to the program

SendKey(Key)
{
   IfEqual, Key, $^Enter
   {
      Key = ^{Enter}
   } else {
            IfEqual, Key, $^Space
            { 
               Key = ^{Space}
            } else {
                     Key := "{" . SubStr(Key, 2) . "}"
                  }
         }
   SendCompatible(Key,1)
   Return
}

;------------------------------------------------------------------------
   
SendWord(WordIndex)
{
   global singlematch
   global Word
   ;Send the word
   sending := singlematch[WordIndex]
   ; Update Typed Count
   UpdateWordCount(sending,0)
   SendFull(sending, StrLen(Word))   
   ClearAllVars(true)
   Return
}  

;------------------------------------------------------------------------
            
SendFull(SendValue,BackSpaceLen)
{
   global SendMethod
   global Active_id
   global NoBackSpace
   global AutoSpace
   
   ; If we are not backspacing, remove the typed characters from the string to send
   IfNotEqual, NoBackSpace, Off
      StringTrimLeft, SendValue, SendValue, %BackSpaceLen%
   
   ; if autospace is on, add a space to the string to send
   IfEqual, AutoSpace, On
      SendValue .= A_Space
   
   IfEqual, SendMethod, 1
   {
      ; Shift key hits are here to account for an occassional bug which misses the first keys in SendPlay
      sending = {Shift Down}{Shift Up}{Shift Down}{Shift Up}      
      IfEqual, NoBackSpace, Off
         sending .= "{BS " . BackSpaceLen . "}"      
      sending .= "{Raw}" . SendValue
         
      SendPlay, %sending% ; First do the backspaces, Then send word (Raw because we want the string exactly as in wordlist.txt) 
      Return
   }

   IfEqual, NoBackSpace, Off
      sending = {BS %BackSpaceLen%}{Raw}%SendValue%
   Else sending = {Raw}%SendValue%
   
   IfEqual, SendMethod, 2
   {
      SendInput, %sending% ; First do the backspaces, Then send word (Raw because we want the string exactly as in wordlist.txt)      
      Return
   }

   IfEqual, SendMethod, 3
   {
      SendEvent, %sending% ; First do the backspaces, Then send word (Raw because we want the string exactly as in wordlist.txt) 
      Return
   }
   
   ClipboardSave := ClipboardAll
   Clipboard = 
   Clipboard := SendValue
   ClipWait, 0
   
   IfEqual, NoBackSpace, Off
      sending = {BS %BackSpaceLen%}{Ctrl Down}v{Ctrl Up}
   Else sending = {Ctrl Down}v{Ctrl Up}
   
   IfEqual, SendMethod, 1C
   {
      sending := "{Shift Down}{Shift Up}{Shift Down}{Shift Up}" . sending
      SendPlay, %sending% ; First do the backspaces, Then send word via clipboard
   } else {
            IfEqual, SendMethod, 2C
            {
               SendInput, %sending% ; First do the backspaces, Then send word via clipboard
            } else {
                     IfEqual, SendMethod, 3C
                     {
                        SendEvent, %sending% ; First do the backspaces, Then send word via clipboard
                     } Else {                      
                              ControlGetFocus, ActiveControl, ahk_id %Active_id%
                              IfNotEqual, ActiveControl,
                                 ControlSend, %ActiveControl%, %sending%, ahk_id %Active_id%
                           }
                  }
         }
         
   Clipboard := ClipboardSave
   Return
}

;------------------------------------------------------------------------

SendCompatible(SendValue,ForceSendForInput)
{
   global SendMethod
   global IgnoreSend
   IfEqual, ForceSendForInput, 1
   {
      IgnoreSend = 
      SendEvent, %SendValue%
      Return
   }
   
   SendMethodLocal := SubStr(SendMethod, 1, 1)
   IF ( ( SendMethodLocal = 1 ) || ( SendMethodLocal = 2 ) )
   {
      SendInput, %SendValue%
      Return
   }

   IF ( ( SendMethodLocal = 3 ) || ( SendMethodLocal = 4 ) )
   {
      IgnoreSend = 1
      SendEvent, %SendValue%
      Return
   }
   
   SendInput, %SendValue%   
   Return
}

;------------------------------------------------------------------------