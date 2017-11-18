#include-once
#include "../imports.au3"

#cs
    Function: Sleep that accounts for script state
    Parameters:
        $iDuration: Amount of time to sleep in milliseconds
    Returns: True if script needs to be stopped.
#ce
Func _Sleep($iDuration)
    Local $vTimerInit = TimerInit()
    While TimerDiff($vTimerInit) < $iDuration
        If ($g_bRunning = True) And ($g_hScriptTimer <> Null) Then
            WinSetTitle($hParent, "", $g_sAppTitle & ": " & StringReplace($g_sScript, "_", "") & " - " & getTimeString(TimerDiff($g_hScriptTimer)/1000))
        EndIf
        
        displayLog($g_aLog, $hLV_Log)
        While $g_bPaused = True
            displayLog($g_aLog, $hLV_Log)
            GUI_HANDLE()
        WEnd

        If $g_bRunning = False Then Return True 
        GUI_HANDLE()
    WEnd
    Return False
EndFunc

#cs 
    Function: Displays global debug variable.
    Parameter:
        $vDebug: Data containing debug information.
#ce
Func DisplayDebug($vDebug = $g_vDebug)
    If isArray($vDebug) = True Then
        _ArrayDisplay($vDebug)
        MsgBox(0, "MSL Bot DEBUG", "Error Message:" & @CRLF & $g_sErrorMessage)
    Else   
        MsgBox(0, "MSL Bot DEBUG", $vDebug & @CRLF & "Error Message:" & @CRLF & $g_sErrorMessage)
    EndIf
EndFunc

Func ForceQuit()
    Local $aWindows = WinList()

    Local $sBotsList = "" ;List of opened instances, used if more than one instance
    Local $iSize = 0 ;size of aBots
    Local $aBots[0][2]

    For $i = 0 To UBound($aWindows, $UBOUND_ROWS)-1
        If StringLeft($aWindows[$i][0], 9) = "MSL Bot v" Then
            $iSize = UBound($aBots, $UBOUND_ROWS)
            ReDim $aBots[$iSize+1][2]

            $aBots[$iSize][0] = $aWindows[$i][0]
            $aBots[$iSize][1] = $aWindows[$i][1]

            $sBotsList &= "[" & $iSize & "] " & $aWindows[$i][0] & " (" & $aWindows[$i][1] & ")" & @CRLF
        EndIf
    Next

    Local $iResult = 0
    If $iSize > 1 Then 
        Do 
            $iResult = InputBox("Multiple instances detected.", "Select which # bot to close: " & @CRLF & @CRLF & $sBotsList)
            If $iResult = "" Then Return
        Until ($iResult >= 0) And ($iResult <= $iSize)
    EndIf

    ProcessClose(WinGetProcess($aBots[$iResult][1]))
EndFunc

;calls for debug prompt
Func Debug()
    If $g_bRunning = False Then
        $g_sScript = "_Debug"
        $g_aScriptArgs = Null

        Start()
    EndIf
EndFunc

Func _Debug()
    ;Prompting for code
    Local $aLines = StringSplit(InputBox("Debug Input", "Enter an expression: " & @CRLF & "- Lines of expressions can be separated by '|' character.", default, default, default, 150), "|", $STR_NOCOUNT)

    addLog($g_aLog, "```Debug script has started.", $LOG_NORMAL)
    ;Process each line of code
    For $i = 0 To UBound($aLines, $UBOUND_ROWS)-1
        If $aLines[$i] = "" Then ContinueLoop
        Local $sResult = Execute($aLines[$i])
        If $sResult = "" Then $sResult = "N/A"

        If isArray($sResult) Then
            _ArrayDisplay($sResult)
            addLog($g_aLog, "{Array} <= " & $aLines[$i], $LOG_NORMAL)
        Else
            If $sResult = False Then $sResult = "False"
            addLog($g_aLog, $sResult & " <= " & $aLines[$i], $LOG_NORMAL)
        EndIf
        
    Next

    ;Exit
    addLog($g_aLog, "Debug script has stopped.```")
    Stop()
EndFunc