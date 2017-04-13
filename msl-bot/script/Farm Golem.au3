#cs
	Function: farmGolem
	Calls farmGolemMain with config settings

	Author: GkevinOD (2017)
#ce
Func farmGolem()
	Local $strGolem = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "dungeon", 7))

	Local $buyEggs = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "buy-eggs", 0))
	Local $buySoulstones = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "buy-soulstones", 1))
	Local $maxGoldSpend = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "max-gold-spend", 100000))
	Local $sellGems = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "sell-gems", 1))
	Local $guardian = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "farm-guardian", 0))
	Local $intSellGradeMin = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "sell-grade-min", 4))
	Local $intKeepGradeMinSub = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "keep-grade-min-sub", 5))
	Local $intMinSub = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "min-sub", 4))
	Local $intGem = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "max-spend-gem", 0))
	Local $selectBoss = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "select-boss", 1))
	Local $keepAllGrade = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "keep-all-grade", 6))

	Local $quest = IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "collect-quest", "1")
	Local $hourly = IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "collect-hourly", "1")

	setLog("~~~Starting 'Farm Golem' script~~~", 2)
	farmGolemMain($strGolem, $selectBoss, $sellGems, $keepAllGrade, $intSellGradeMin, $intKeepGradeMinSub, $intMinSub, $intGem, $guardian, $quest, $hourly, $buyEggs, $buySoulstones, $maxGoldSpend)
	setLog("~~~Finished 'Farm Golem' script~~~", 2)
EndFunc   ;==>farmGolem

#cs
	Function: farmGolemMain
	Farms golems while collecting hourly and quests, and selling and collecting gems.

	Parameters:
	strGolem: (Int) The golem stage.
	selectBoss: (Int) 1=True; 0=False
	sellGems: (Int) 1=True; 0=False
	intSellGradeMin: (Int) Bot will sell any gems with <= this number.
	intKeepGradeMinSub: (Int) Grade of gem that will be kept if intMinSub is met.
	intMinSub: (Int) Keep gems that fit intKeepGradeMinSub and has >= this number.
	intGem: (Int) Maximum number of gems the bot can spend for refill.
	guardian: (Int) 1=True; 0=False
	quest: (Int) 1=True; 0=False
	hourly: (Int) 1=True; 0=False

	Author: GkevinOD (2017)
#ce
Func farmGolemMain($strGolem, $selectBoss, $sellGems, $keepAllGrade, $intSellGradeMin, $intKeepGradeMinSub, $intMinSub, $intGem, $guardian, $quest, $hourly, $buyEggs, $buySoulstones, $maxGoldSpend)
	Local $intGoldEnergy = 12231
	Local $intGolem = 7
	Switch ($strGolem)
		Case 1 To 3
			$intGolem = 5
		Case 4 To 6
			$intGolem = 6
		Case 7 To 9
			$intGolem = 7
		Case 10
			$intGolem = 8
	EndSwitch

	Local $intGemUsed = 0

	Local $intStartTime = TimerInit()
	Local $intGoldPrediction = 0
	Local $intRunCount = 0
	Local $intTimeElapse = 0
	Local $intGuardian = 0
	Local $getGuardian = False

	Local $getHourly = False
	Local $checkHourly = True ;bool to prevent checking twice

	Local $numEggs = 0 ;keeps count of number of eggs found
	Local $numGemsKept = 0; keeps count of number of eggs kept

	Local $goldSpent = 0

	While True
		If _Sleep(50) Then ExitLoop
		$intTimeElapse = Int(TimerDiff($intStartTime) / 1000)

		Switch StringSplit(_NowTime(4), ":", 2)[1]
			Case "00"
				If $checkHourly = True Then $getHourly = True
			Case "01" ;to prevent checking twice
				$checkHourly = True
		EndSwitch

		If $guardian = 1 And Mod($intRunCount + 1, 10) = 0 Then $getGuardian = True

		Local $strData = "Runs: " & $intRunCount & " (Guardian:" & $intGuardian & ")|Profit: " & StringRegExpReplace(String($intGoldPrediction), "(\d)(?=(\d{3})+$)", "$1,") & "|Gems Used: " & ($intGemUsed & "/" & $intGem) & "|Time Elapse: " & StringFormat("%.2f", $intTimeElapse / 60) & " Min." & "|Avg. Time: " & StringFormat("%.2f", $intTimeElapse / $intRunCount / 60) & " Min.|Eggs: " & $numEggs & "|Gems Kept: " & $numGemsKept

		GUICtrlSetData($listScript, "")
		GUICtrlSetData($listScript, $strData)

		Switch getLocation()
			Case "battle"
				clickPoint($battle_coorAuto)
			Case "battle-end"
				If $quest = 1 And checkPixel($battle_pixelQuest) = True Then
					If setLog("Detected quest complete, navigating to village.", 1) Then ExitLoop
					If navigate("village", "quests") = True Then
						If setLog("Collecting quests.", 1) Then ExitLoop
						For $questTab In $village_coorArrayQuestsTab ;quest tabs
							clickPoint(StringSplit($questTab, ",", 2))
							While IsArray(findImage("misc-quests-get-reward", 100, 3)) = True
								If _Sleep(10) Then ExitLoop (3)
								clickPoint(findImage("misc-quests-get-reward", 100))
							WEnd
						Next
					EndIf
					navigate("map") ;go back to map to repeat golem process
				EndIf

				If $hourly = 1 And $getHourly = True Then
					If getHourly() = 1 Then
						$getHourly = False
						$checkHourly = False
					EndIf

					If $buySoulstones = 1 Then
						Local $itemsBought = buyItem("soulstone", $maxGoldSpend-$goldSpent)
						If isArray($itemsBought) Then
							For $item In $itemsBought
								$goldSpent += Int(StringSplit($item, ",", 2)[1])
							Next
						EndIf
					EndIf

					If $buyEggs = 1 Then
						Local $itemsBought = buyItem("egg", $maxGoldSpend-$goldSpent)
						If isArray($itemsBought) Then
							For $item In $itemsBought
								$goldSpent += Int(StringSplit($item, ",", 2)[1])
							Next
						EndIf
					EndIf
				EndIf

				If $getGuardian = True Then
					If $guardian = 1 Then $intGuardian += farmGuardian($sellGems, $intGem, $intGemUsed)
					$getGuardian = False
				EndIf

				If getLocation() = "battle-end" Then
					Local $quickRestart = findImage("battle-quick-restart", 30)
					clickWhile($quickRestart, "battle-end")
					$intRunCount += 1
				EndIf

				If getLocation() = "battle-end" Then navigate("map")
			Case "refill"
				If $intGemUsed + 30 <= $intGem Then
					While getLocation() = "refill"
						clickPoint($game_coorRefill, 1, 1000)
					WEnd

					If getLocation() = "buy-gem" Or getLocation() = "unknown" Then
						setLog("Out of gems!", 2)
						ExitLoop
					EndIf

					clickUntil($game_coorRefillConfirm, "refill")
					clickWhile("705, 99", "refill")

					If setLog("Refill gems: " & $intGemUsed + 30 & "/" & $intGem, 0) Then ExitLoop
					$intGemUsed += 30
				Else
					setLog("Gem used exceed max gems!", 0)
					ExitLoop
				EndIf
			Case "map", "village", "astroleague", "map-stage", "map-battle", "toc", "association", "clan", "starstone-dungeons", "golem-dungeons", "elemental-dungeons", "gold-dungeons"
				If navigate("map", "golem-dungeons") = True Then
					Local $tempCurrLocation = getLocation()
					While Not ($tempCurrLocation = "map-battle")
						If $tempCurrLocation = "autobattle-prompt" Then
							clickPoint($map_coorCancelAutoBattle, 1, 500)
						EndIf

						clickPoint(Eval("map_coorB" & $strGolem), 1, 500)
						$tempCurrLocation = getLocation()
					WEnd

					clickUntil($map_coorBattle, "battle")

					$intRunCount += 1
				Else
					setLog("Unable to navigate to dungeon, trying again.", 1)
				EndIf
			Case "battle-end-exp", "battle-sell"
				clickUntil($game_coorTap, "battle-sell")
				If _Sleep(10) Then ExitLoop

				If $sellGems = 1 Then
					Local $gemInfo = sellGem("B" & $strGolem, $intSellGradeMin, True, $keepAllGrade, $intKeepGradeMinSub, $intMinSub)
					If IsArray($gemInfo) Then
						If StringInStr($gemInfo[6], "!") And Not($gemInfo[0] = "EGG") Then
							$intGoldPrediction += $intGoldEnergy
						Else
							$numGemsKept += 1
						EndIf

						If $gemInfo[0] = "EGG" Then $numEggs += 1
					EndIf
				Else
					sellGem("B" & $strGolem, 0, False, 6, 0, 0) ;Does not sell, only records data
				EndIf

				clickPoint($game_coorTap)
			Case "battle-gem-full"
				setLog("Gem inventory is full!", 2)
				ExitLoop
			Case "defeat"
				clickPoint(findImage("battle-give-up", 30))
				clickUntil($game_coorTap, "battle-end", 20, 1000)
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
			Case "unknown"
				If Not waitLocation("battle-boss", 3000) = "" Then
					If $selectBoss = 1 Then
						waitLocation("battle-auto", 5000)
						clickPoint("406, 209")
					EndIf
				EndIf

				clickPoint($game_coorTap)
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
			Case "pause"
				clickPoint($battle_coorContinue)
		EndSwitch
	WEnd
EndFunc   ;==>farmGolemMain