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
   global g_singlematch
   global g_Word
   ;Send the word
   sending := g_singlematch[WordIndex]
   ; Update Typed Count
   UpdateWordCount(sending,0)
   SendFull(sending, StrLen(g_Word))   
   ClearAllVars(true)
   Return
}  

;------------------------------------------------------------------------
            
SendFull(SendValue,BackSpaceLen)
{
   global g_Active_Id
   global prefs_AutoSpace
   global prefs_NoBackSpace
   global prefs_SendMethod
   
   ; If we are not backspacing, remove the typed characters from the string to send
   IfNotEqual, prefs_NoBackSpace, Off
      StringTrimLeft, SendValue, SendValue, %BackSpaceLen%
   
   ; if autospace is on, add a space to the string to send
   IfEqual, prefs_AutoSpace, On
      SendValue .= A_Space
   
   IfEqual, prefs_SendMethod, 1
   {
      ; Shift key hits are here to account for an occassional bug which misses the first keys in SendPlay
      sending = {Shift Down}{Shift Up}{Shift Down}{Shift Up}      
      IfEqual, prefs_NoBackSpace, Off
         sending .= "{BS " . BackSpaceLen . "}"      
      sending .= "{Raw}" . SendValue
         
      SendPlay, %sending% ; First do the backspaces, Then send word (Raw because we want the string exactly as in wordlist.txt) 
      Return
   }

   IfEqual, prefs_NoBackSpace, Off
      sending = {BS %BackSpaceLen%}{Raw}%SendValue%
   Else sending = {Raw}%SendValue%
   
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
   
   IfEqual, prefs_NoBackSpace, Off
      sending = {BS %BackSpaceLen%}{Ctrl Down}v{Ctrl Up}
   Else sending = {Ctrl Down}v{Ctrl Up}
   
   IfEqual, prefs_SendMethod, 1C
   {
      sending := "{Shift Down}{Shift Up}{Shift Down}{Shift Up}" . sending
      SendPlay, %sending% ; First do the backspaces, Then send word via clipboard
   } else {
            IfEqual, prefs_SendMethod, 2C
            {
               SendInput, %sending% ; First do the backspaces, Then send word via clipboard
            } else {
                     IfEqual, prefs_SendMethod, 3C
                     {
                        SendEvent, %sending% ; First do the backspaces, Then send word via clipboard
                     } Else {                      
                              ControlGetFocus, ActiveControl, ahk_id %g_Active_Id%
                              IfNotEqual, ActiveControl,
                                 ControlSend, %ActiveControl%, %sending%, ahk_id %g_Active_Id%
                           }
                  }
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