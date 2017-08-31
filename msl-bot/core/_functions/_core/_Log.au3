Global $setLogOld = ""

#cs ----------------------------------------------------------------------------

 Function: setLog
 Sets the text for the title of the GUI and Sets Log
 
 strStatus = Message to be logged
 option = ?
 level = level of importance. Info 0, Warning 1, Error 2, Debug 3

#ce ----------------------------------------------------------------------------

Func setLog($strStatus, $option = 0, $level = 0) ;0 is normal, 1 is unimportant, 2 is forced
	If (Not $option = 2) And ($boolRunning = False) Then Return True

	If $iniOutput = 0 And $option = 1 Then Return

	If $level <= $iniLogLevel Then
		_GUICtrlEdit_AppendText($textOutput, "[" & _NowTime(5) & "] " & $strStatus & @CRLF)
		$setLogOld = GUICtrlRead($textOutput)
		_Sleep(100)
	EndIf

	Return False
EndFunc

#cs ----------------------------------------------------------------------------

 Function: setLogReplace
 Replaces most recent line to a new setlog

#ce ----------------------------------------------------------------------------

Func setLogReplace($strStatus, $option = 0) ;0 is normal, 1 is unimportant, 2 is forced
	If (Not $option = 2) And ($boolRunning = False) Then Return True

	If $iniOutput = 0 And $option = 1 Then Return

	_GUICtrlEdit_SetText($textOutput, "")
	_GUICtrlEdit_AppendText($textOutput, $setLogOld & "[" & _NowTime(5) & "] " & $strStatus & @CRLF)

EndFunc

#cs ----------------------------------------------------------------------------

 Function: logUpdate
 Updates old log to new log

#ce ----------------------------------------------------------------------------

Func logUpdate()
	$setLogOld = GUICtrlRead($textOutput)
EndFunc

#cs ----------------------------------------------------------------------------

 Function: setList
 Sets data for the listbox

 @post: Uses global variable: '$globalData' first data input

#ce ----------------------------------------------------------------------------

Func setList($newData)
	GUICtrlSetData($listScript, "")
	If $newData = "" Then
		GUICtrlSetData($listScript, $globalData & "|Time Elapse: " & getTimeString(TimerDiff($globalScriptTimer)/1000))
	Else
		GUICtrlSetData($listScript, $globalData & "|" & $newData & "|Time Elapse: " & getTimeString(TimerDiff($globalScriptTimer)/1000))
	EndIf
EndFunc

Func getTimeString($sec)
	If $sec >= 3600 Then
		Return Int($sec / 60 / 60) & "H " & Int(Mod($sec / 60, 60)) & "M " & Int(Mod($sec, 60)) & "S"
	Else
		Return Int($sec / 60) & "M " & Int(Mod($sec, 60)) & "S"
	EndIf
EndFunc

