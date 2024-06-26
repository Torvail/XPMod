void OnPlayerRunCmd_BileCleanse(int iClient, &iButtons)
{
	// If they started a bile cleanse, handle if something prevented contiuation
	if (g_iBileCleansingFrameTimeCtr[iClient] >= 0 && 
		(!(iButtons & IN_USE) || 
		 IsClientGrappled(iClient) == true || 
		 IsIncap(iClient) == true) )
	{
		g_iBileCleansingFrameTimeCtr[iClient] = -1;

		if (IsFakeClient(iClient) == false)
			PrintHintText(iClient, "Bile Cleansing Interrupted...");
	}
	
	// Make sure the player is actually biled before continuing
	if (g_iVomitVictimAttacker[iClient] == 0)
		return;

	// Check that the player has a self revive and is pressing the button while incap
	if (g_iBileCleansingKits[iClient] <= 0 ||
		!(iButtons & IN_USE) ||
		g_iClientTeam[iClient] != TEAM_SURVIVORS || 
		RunClientChecks(iClient) == false ||
		IsClientGrappled(iClient) == true ||
		IsIncap(iClient) == true ||
		IsFakeClient(iClient) == true)
		return;

	DebugLog(DEBUG_MODE_VERBOSE, "OnPlayerRunCmd_BileCleanse");

	// Increment the frame counter to measure time the USE button has been pressed
	g_iBileCleansingFrameTimeCtr[iClient]++;

	// Display that they are using the kit
	if (g_iBileCleansingFrameTimeCtr[iClient] == 15)
		PrintHintText(iClient, "Using Bile Cleansing Kit...");

	// Use the bile cleansing kit
	if (g_iBileCleansingFrameTimeCtr[iClient] >= BILE_CLEANSING_COMPLETION_FRAME)
	{
		g_iBileCleansingFrameTimeCtr[iClient] = -1;
		g_iBileCleansingKits[iClient]--;

		SDKCall(g_hSDK_UnVomitOnPlayer, iClient);

		PrintHintText(iClient, "%i Bile Cleansing Kit%s Remaining",
			g_iBileCleansingKits[iClient],
			g_iBileCleansingKits[iClient] == 1 ? "" : "s");
	}
}

void OnPlayerRunCmd_SelfRevive(int iClient, &iButtons)
{
	// The GetEntProp method for getting buttons doesnt work for IN_USE
	// while incap, but it will still be caught in here. So, stop the
	// self revive if they let go.
	// Note: this is apparently stoppeed by being hit by CI. In order
	// to disable this, perhaps make a counter to check how long the
	// IN_USE has been let go before calling EndSelfRevive
	if (g_bSelfReviving[iClient] == true && !(iButtons & IN_USE))
		EndSelfRevive(iClient);

	// Check that the player has a self revive and is pressing the button while incap
	if (g_iSelfRevives[iClient] <= 0 ||
		!(iButtons & IN_USE) ||
		g_bSelfReviving[iClient] == true ||
		g_iClientTeam[iClient] != TEAM_SURVIVORS || 
		RunClientChecks(iClient) == false ||
		IsIncap(iClient) == false ||
		IsFakeClient(iClient))
		return;

	DebugLog(DEBUG_MODE_VERBOSE, "OnPlayerRunCmd_SelfRevive");

	StartSelfRevive(iClient);
}

void StartSelfRevive(int iClient)
{
	DebugLog(DEBUG_MODE_VERBOSE, "StartSelfRevive");

	// Note, its very important to check if someone else is reviving
	// here. Notice the last line of this if statement.  If they are,
	// then do not continue with self revive or they will never to go down
	if (g_bSelfReviving[iClient] == true ||
		g_iClientTeam[iClient] != TEAM_SURVIVORS || 
		IsClientGrappled(iClient) ||
		RunClientChecks(iClient) == false ||
		IsFakeClient(iClient) ||
		IsIncap(iClient) == false ||
		GetEntPropEnt(iClient, Prop_Send, "m_reviveOwner") != -1)
		return;
	
	g_bSelfReviving[iClient] = true;
	g_fSelfRevivingFinishTime[iClient] = GetGameTime() + SELF_REVIVE_TIME;
	SetEntPropFloat(iClient, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	SetEntPropFloat(iClient, Prop_Send, "m_flProgressBarDuration", SELF_REVIVE_TIME);
	SetEntPropEnt(iClient, Prop_Send, "m_reviveOwner", iClient);

	delete g_hTimer_SelfReviveCheck[iClient];
	g_hTimer_SelfReviveCheck[iClient] = CreateTimer(0.1, TimerSelfReviveCheck, iClient, TIMER_REPEAT);
}

Action:TimerSelfReviveCheck(Handle:timer, any:iClient)
{
	DebugLog(DEBUG_MODE_VERBOSE, "TimerSelfReviveCheck");
	if (g_iClientTeam[iClient] != TEAM_SURVIVORS || 
		IsClientGrappled(iClient) ||
		RunClientChecks(iClient) == false ||
		IsFakeClient(iClient) ||
		IsIncap(iClient) == false)
	{
		EndSelfRevive(iClient);
		g_hTimer_SelfReviveCheck[iClient] = null;
		return Plugin_Stop;
	}
	
	//Check for a completed self revive
	if (g_fSelfRevivingFinishTime[iClient] <= GetGameTime() && 
		g_fSelfRevivingFinishTime[iClient] > 0 &&
		g_bSelfReviving[iClient])
	{
		SuccessfulSelfRevive(iClient);
	}
	// Check if still self reviving and continue
	else if (g_bSelfReviving[iClient])
	{
		return Plugin_Continue;
	}

	EndSelfRevive(iClient);
	g_hTimer_SelfReviveCheck[iClient] = null;
	return Plugin_Stop;
}

void SuccessfulSelfRevive(int iClient)
{
	DebugLog(DEBUG_MODE_VERBOSE, "SuccessfulSelfRevive");
	bool bIsLedgeRevive = GetEntProp(iClient, Prop_Send, "m_isHangingFromLedge") == 1;

	// Revive them by using cheat command to give full health
	RunCheatCommand(iClient, "give", "give health");

	g_bIsClientDown[iClient] = false;

	if (bIsLedgeRevive)
	{
		// If its a self revive off ledge, Use the stored health values
		if (g_iPlayerHealth[iClient] <= 1)
			g_iPlayerHealth[iClient] = 1;
		// Change health to self revive health
		SetPlayerHealth(iClient, -1, g_iPlayerHealth[iClient]);
		// Change temp health to self revive health
		ResetTempHealthToSurvivor(iClient);
		AddTempHealthToSurvivor(iClient, float(g_iPlayerHealthTemp[iClient]));
	}
	else
	{
		// Change health to self revive health
		SetPlayerHealth(iClient, -1, SELF_REVIVE_HEALTH);
		// Change temp health to self revive health
		ResetTempHealthToSurvivor(iClient);
		AddTempHealthToSurvivor(iClient, float(SELF_REVIVE_TEMP_HEALTH));
	}

	// We must now handle this, instead of the game.
	SetEntPropFloat(iClient, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	SetEntPropFloat(iClient, Prop_Send, "m_flProgressBarDuration", 0.0);
	SetEntPropEnt(iClient, Prop_Send, "m_reviveOwner", -1);

	// Remove the self revive from the client
	g_iSelfRevives[iClient]--;

	HandlePostSelfRevive(iClient);
}

void EndSelfRevive(int iClient)
{
	DebugLog(DEBUG_MODE_VERBOSE, "EndSelfRevive");
	if (RunClientChecks(iClient) == false)
		return;
	
	g_bSelfReviving[iClient] = false;
	g_fSelfRevivingFinishTime[iClient] = -1.0;

	// We must now handle this, instead of the game, if the player stoppeed a self revive
	if (GetEntPropEnt(iClient, Prop_Send, "m_reviveOwner") == iClient)
	{
		SetEntPropFloat(iClient, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntPropFloat(iClient, Prop_Send, "m_flProgressBarDuration", 0.0);
		SetEntPropEnt(iClient, Prop_Send, "m_reviveOwner", -1);
	}
}

void HandlePostSelfRevive(iClient)
{
	HandleEllisSelfRevive(iClient);
}

int GetIncapOrDeadSurvivorCount()
{
	int iDownedPlayerCount = 0;
	for (int iPlayer=1; iPlayer <= MaxClients; iPlayer++)
	{
		if (g_iClientTeam[iPlayer] != TEAM_SURVIVORS ||
			RunClientChecks(iPlayer) == false)
			continue;
		
		if (IsPlayerAlive(iPlayer) == false ||
			(IsIncap(iPlayer) == true &&
			GetEntProp(iPlayer, Prop_Send, "m_isHangingFromLedge") == 0))
			iDownedPlayerCount++;
	}

	return iDownedPlayerCount;
}