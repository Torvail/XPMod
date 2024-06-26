void Handle2SecondClientTimers_Coach(int iClient)
{
	if (g_iHomerunLevel[iClient] == 5)
		SetEntData(iClient, g_iOffset_ShovePenalty,0);

	HandleCoachJetPack2SecondTick(iClient);
}

Action:TimerStartJetPack(Handle:timer, any:iClient)
{
	if(RunClientChecks(iClient)==false || IsPlayerAlive(iClient)==false)
		return Plugin_Stop;

	new Float:vec[3];
	GetClientAbsOrigin(iClient, vec);
	EmitSoundToAll(SOUND_JPIDLEREV, iClient, SNDCHAN_AUTO,	SNDLEVEL_NORMAL, SND_NOFLAGS, 0.3, SNDPITCH_NORMAL, -1, vec, NULL_VECTOR, true, 0.0);
	g_bIsJetpackOn[iClient] = true;
	PrintCoachJetpackFuelGauge(iClient)
	return Plugin_Stop;
}

Action:TimerGiveFirstExplosive(Handle:timer, any:iClient)
{
	if(RunClientChecks(iClient)==false || IsPlayerAlive(iClient)==false)
		return Plugin_Stop;
	
	if(GetPlayerWeaponSlot(iClient, 2) == -1)
	{
		if(g_iStrongLevel[iClient]==1 || g_iStrongLevel[iClient]==2)
		{
			CreateTimer(3.0, TimerGiveExplosive, iClient, TIMER_FLAG_NO_MAPCHANGE);
			g_iExtraExplosiveUses[iClient] = 2;
		}
		else if(g_iStrongLevel[iClient]==3 || g_iStrongLevel[iClient]==4)
		{
			CreateTimer(3.0, TimerGiveExplosive, iClient, TIMER_FLAG_NO_MAPCHANGE);
			g_iExtraExplosiveUses[iClient] = 1;
		}
		else
		{
			CreateTimer(3.0, TimerGiveExplosive, iClient, TIMER_FLAG_NO_MAPCHANGE);
			g_iExtraExplosiveUses[iClient] = 0;
		}
	}
	return Plugin_Stop;
}

Action:TimerGiveExplosive(Handle:timer, any:iClient)
{
	if(RunClientChecks(iClient) == false || IsPlayerAlive(iClient) == false)
		return Plugin_Stop;
	
	g_iExtraExplosiveUses[iClient]++;
	new randnum = GetRandomInt(0, 2);

	switch(randnum)
	{
		case 0:	RunCheatCommand(iClient, "give", "give pipe_bomb");
		case 1:	RunCheatCommand(iClient, "give", "give molotov");
		case 2:	RunCheatCommand(iClient, "give", "give vomitjar");
	}

	
	g_bExplosivesJustGiven[iClient] = false;
	//CreateTimer(0.1, TimerGiveExplosive, iClient, TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

// Action:Timer_ResetExplosiveJustGiven(Handle:timer, any:iClient)
// {
// 	g_bExplosivesJustGiven[iClient] = true;
// 	return Plugin_Stop;
// }

Action:TimerCoachCIHeadshotSpeedReset(Handle:timer, any:iClient)
{
	g_iCoachCIHeadshotCounter[iClient]--;
	if(g_iCoachCIHeadshotCounter[iClient] > 0)
	{
		CreateTimer(5.0, TimerCoachCIHeadshotSpeedReset, iClient, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bCoachInCISpeed[iClient] = false;
		SetClientSpeed(iClient);
	}
	return Plugin_Stop;
}

Action:TimerCoachSIHeadshotSpeedReset(Handle:timer, any:iClient)
{
	//g_fCoachSIHeadshotSpeed[iClient] = 0.0;
	
	g_iCoachSIHeadshotCounter[iClient]--;
	if(g_iCoachSIHeadshotCounter[iClient] > 0)
	{
		CreateTimer(10.0, TimerCoachSIHeadshotSpeedReset, iClient, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bCoachInSISpeed[iClient] = false;
		SetClientSpeed(iClient);
	}
	return Plugin_Stop;
}

Action:TimerCoachRageReset(Handle:timer, any:iClient)
{
	g_bCoachRageIsActive[iClient] = false;
	g_iCoachRageMeleeDamage[iClient] = 0;
	g_bCoachRageIsInCooldown[iClient] = true;
	
	SetClientSpeed(iClient);
	CreateTimer(180.0, TimerCoachRageCooldown, iClient, TIMER_FLAG_NO_MAPCHANGE);
	
	if (RunClientChecks(iClient) && IsFakeClient(iClient) == false)
		PrintHintText(iClient, "Rage is in cooldown, healing and speed talents disabled for 3 minutes.");
	
	return Plugin_Stop;
}

Action:TimerCoachRageCooldown(Handle:timer, any:iClient)
{
	g_bCoachRageIsAvailable[iClient] = true;
	g_bCoachRageIsInCooldown[iClient] = false;

	SetClientSpeed(iClient);

	return Plugin_Stop;
}

Action:TimerCoachRageRegenTick(Handle:timer, any:iClient)
{
	if (RunClientChecks(iClient) == false || 
		IsFakeClient(iClient) ||
		IsPlayerAlive(iClient) == false ||
		g_iClientTeam[iClient] != TEAM_SURVIVORS)
		return Plugin_Stop;

	if(g_iCoachRageRegenCounter[iClient] == 20)
	{
		g_iCoachRageRegenCounter[iClient] = 0;
		return Plugin_Stop;
	}
	
	if(g_iCoachRageRegenCounter[iClient] < 2)
	{
		new currentHP = GetPlayerHealth(iClient);
		new maxHP = GetPlayerMaxHealth(iClient);
		if(currentHP < (maxHP - 5))
			SetPlayerHealth(iClient, -1, currentHP + 5);
		else if(currentHP >= (maxHP - 5))
			SetPlayerHealth(iClient, -1, maxHP);
	}
	else if(g_iCoachRageRegenCounter[iClient] < 5)
	{
		new currentHP = GetPlayerHealth(iClient);
		new maxHP = GetPlayerMaxHealth(iClient);
		if(currentHP < (maxHP - 4))
			SetPlayerHealth(iClient, -1, currentHP + 4);
		else if(currentHP >= (maxHP - 4))
			SetPlayerHealth(iClient, -1, maxHP);
	}
	else if(g_iCoachRageRegenCounter[iClient] < 9)
	{
		new currentHP = GetPlayerHealth(iClient);
		new maxHP = GetPlayerMaxHealth(iClient);
		if(currentHP < (maxHP - 3))
			SetPlayerHealth(iClient, -1, currentHP + 3);
		else if(currentHP >= (maxHP - 3))
			SetPlayerHealth(iClient, -1, maxHP);
	}
	else if(g_iCoachRageRegenCounter[iClient] < 14)
	{
		new currentHP = GetPlayerHealth(iClient);
		new maxHP = GetPlayerMaxHealth(iClient);
		if(currentHP < (maxHP - 2))
			SetPlayerHealth(iClient, -1, currentHP + 2);
		else if(currentHP >= (maxHP - 2))
			SetPlayerHealth(iClient, -1, maxHP);
	}
	else
	{
		new currentHP = GetPlayerHealth(iClient);
		new maxHP = GetPlayerMaxHealth(iClient);
		if(currentHP < (maxHP - 1))
			SetPlayerHealth(iClient, -1, currentHP + 1);
		else if(currentHP >= (maxHP - 1))
			SetPlayerHealth(iClient, -1, maxHP);
	}
	g_iCoachRageRegenCounter[iClient]++;
	//PrintToChatAll("Rage Regen Counter = %d", g_iCoachRageRegenCounter[iClient]);
	CreateTimer(1.0, TimerCoachRageRegenTick, iClient, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

Action:TimerWreckingChargeRetrigger(Handle:timer, any:iClient)
{
	g_iWreckingBallChargeCounter[iClient] = 0;
	g_bIsWreckingBallCharged[iClient] = true;
	new Float:vec[3];
	GetClientAbsOrigin(iClient, vec);
	new rand = GetRandomInt(1, 3);
	switch(rand)
	{
		case 1: EmitSoundToAll(SOUND_COACH_CHARGE1, iClient, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vec, NULL_VECTOR, true, 0.0);
		case 2: EmitSoundToAll(SOUND_COACH_CHARGE2, iClient, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vec, NULL_VECTOR, true, 0.0);
		case 3: EmitSoundToAll(SOUND_COACH_CHARGE3, iClient, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vec, NULL_VECTOR, true, 0.0);
	}
	
	g_iPID_CoachMeleeCharge1[iClient] = CreateParticle("coach_melee_charge_wepbone", 0.0, iClient, ATTACH_WEAPON_BONE);
	g_iPID_CoachMeleeCharge2[iClient] = CreateParticle("coach_melee_charge_muzbone", 0.0, iClient, ATTACH_MUZZLE_FLASH);
	PrintHintText(iClient, "Wrecking Ball has been recharged!");
	return Plugin_Stop;
}

Action:TimerCoachAssignGrenades(Handle:timer, any:iClient)
{
	decl AssignGrenadeSlot1, AssignGrenadeSlot2, AssignGrenadeSlot3;
	AssignGrenadeSlot1 = GetRandomInt(0,2);
	AssignGrenadeSlot2 = GetRandomInt(0,2);
	AssignGrenadeSlot3 = GetRandomInt(0,2);
	if(!StrContains(g_strCoachGrenadeSlot1, "vomitjar", false) && !StrContains(g_strCoachGrenadeSlot1, "molotov", false) && !StrContains(g_strCoachGrenadeSlot1, "pipe_bomb", false))
	{
		//PrintToChatAll("Slot 1 did not contain a grenade");
		switch (AssignGrenadeSlot1)
		{
			case 0:
			{

				RunCheatCommand(iClient, "give", "give vomitjar");
				g_strCoachGrenadeSlot1 = "weapon_vomitjar";
				//PrintToChatAll("Slot 1 Assigned = %s", g_strCoachGrenadeSlot1);
			}
			case 1:
			{

				RunCheatCommand(iClient, "give", "give molotov");
				g_strCoachGrenadeSlot1 = "weapon_molotov";
				//PrintToChatAll("Slot 1 Assigned = %s", g_strCoachGrenadeSlot1);
			}
			case 2:
			{

				RunCheatCommand(iClient, "give", "give pipe_bomb");
				g_strCoachGrenadeSlot1 = "weapon_pipe_bomb";
				//PrintToChatAll("Slot 1 Assigned = %s", g_strCoachGrenadeSlot1);
			}
		}
	}
	if(g_iStrongLevel[iClient] == 2 || g_iStrongLevel[iClient] == 3)
	{
		//PrintToChatAll("Slot 2 was assigned a grenade");
		switch (AssignGrenadeSlot2)
		{
			case 0:
			{
				g_strCoachGrenadeSlot2 = "weapon_vomitjar";
				//PrintToChatAll("Slot 2 Assigned = %s", g_strCoachGrenadeSlot2);
			}
			case 1:
			{
				g_strCoachGrenadeSlot2 = "weapon_molotov";
				//PrintToChatAll("Slot 2 Assigned = %s", g_strCoachGrenadeSlot2);
			}
			case 2:
			{
				g_strCoachGrenadeSlot2 = "weapon_pipe_bomb";
				//PrintToChatAll("Slot 2 Assigned = %s", g_strCoachGrenadeSlot2);
			}
		}
	}
	else if(g_iStrongLevel[iClient] == 4 || g_iStrongLevel[iClient] == 5)
	{
		//PrintToChatAll("Slot 2 was assigned a grenade");
		switch (AssignGrenadeSlot2)
		{
			case 0:
			{
				g_strCoachGrenadeSlot2 = "weapon_vomitjar";
				//PrintToChatAll("Slot 2 Assigned = %s", g_strCoachGrenadeSlot2);
			}
			case 1:
			{
				g_strCoachGrenadeSlot2 = "weapon_molotov";
				//PrintToChatAll("Slot 2 Assigned = %s", g_strCoachGrenadeSlot2);
			}
			case 2:
			{
				g_strCoachGrenadeSlot2 = "weapon_pipe_bomb";
				//PrintToChatAll("Slot 2 Assigned = %s", g_strCoachGrenadeSlot2);
			}
		}
		//PrintToChatAll("Slot 3 was assigned a grenade");
		switch (AssignGrenadeSlot3)
		{
			case 0:
			{
				g_strCoachGrenadeSlot3 = "weapon_vomitjar";
				//PrintToChatAll("Slot 3 Assigned = %s", g_strCoachGrenadeSlot3);
			}
			case 1:
			{
				g_strCoachGrenadeSlot3 = "weapon_molotov";
				//PrintToChatAll("Slot 3 Assigned = %s", g_strCoachGrenadeSlot3);
			}
			case 2:
			{
				g_strCoachGrenadeSlot3 = "weapon_pipe_bomb";
				//PrintToChatAll("Slot 3 Assigned = %s", g_strCoachGrenadeSlot3);
			}
		}
	}
	return Plugin_Stop;
}

Action:TimerCanCoachGrenadeCycleReset(Handle:timer, any:iClient)
{
	g_bCanCoachGrenadeCycle[iClient] = true;
	return Plugin_Stop;
}

Action:TimerCoachGrenadeFireCycle(Handle:timer, any:iClient)
{
	if(g_iStrongLevel[iClient] == 2 || g_iStrongLevel[iClient] == 3)
	{
		if(g_iCoachCurrentGrenadeSlot[iClient] == 0)
		{
			if(StrContains(g_strCoachGrenadeSlot2, "vomitjar", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 1;

				RunCheatCommand(iClient, "give", "give vomitjar");
			}
			else if(StrContains(g_strCoachGrenadeSlot2, "molotov", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 1;

				RunCheatCommand(iClient, "give", "give molotov");
			}
			else if(StrContains(g_strCoachGrenadeSlot2, "pipe_bomb", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 1;

				RunCheatCommand(iClient, "give", "give pipe_bomb");
			}
		}
		else if(g_iCoachCurrentGrenadeSlot[iClient] == 1)
		{
			if(StrContains(g_strCoachGrenadeSlot1, "vomitjar", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 0;

				RunCheatCommand(iClient, "give", "give vomitjar");
			}
			else if(StrContains(g_strCoachGrenadeSlot1, "molotov", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 0;

				RunCheatCommand(iClient, "give", "give molotov");
			}
			else if(StrContains(g_strCoachGrenadeSlot1, "pipe_bomb", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 0;

				RunCheatCommand(iClient, "give", "give pipe_bomb");
			}
		}
	}
	else if(g_iStrongLevel[iClient] == 4 || g_iStrongLevel[iClient] == 5)
	{
		if(g_iCoachCurrentGrenadeSlot[iClient] == 0)
		{
			if(StrContains(g_strCoachGrenadeSlot2, "vomitjar", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 1;

				RunCheatCommand(iClient, "give", "give vomitjar");
			}
			else if(StrContains(g_strCoachGrenadeSlot2, "molotov", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 1;

				RunCheatCommand(iClient, "give", "give molotov");
			}
			else if(StrContains(g_strCoachGrenadeSlot2, "pipe_bomb", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 1;

				RunCheatCommand(iClient, "give", "give pipe_bomb");
			}
			else if(StrContains(g_strCoachGrenadeSlot2, "empty", false) != -1)
			{
				if(StrContains(g_strCoachGrenadeSlot3, "vomitjar", false) != -1)
				{
					g_iCoachCurrentGrenadeSlot[iClient] = 2;

					RunCheatCommand(iClient, "give", "give vomitjar");
				}
				else if(StrContains(g_strCoachGrenadeSlot3, "molotov", false) != -1)
				{
					g_iCoachCurrentGrenadeSlot[iClient] = 2;

					RunCheatCommand(iClient, "give", "give molotov");
				}
				else if(StrContains(g_strCoachGrenadeSlot3, "pipe_bomb", false) != -1)
				{
					g_iCoachCurrentGrenadeSlot[iClient] = 2;

					RunCheatCommand(iClient, "give", "give pipe_bomb");
				}
			}
		}
		else if(g_iCoachCurrentGrenadeSlot[iClient] == 1)
		{
			if(StrContains(g_strCoachGrenadeSlot3, "vomitjar", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 2;

				RunCheatCommand(iClient, "give", "give vomitjar");
			}
			else if(StrContains(g_strCoachGrenadeSlot3, "molotov", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 2;

				RunCheatCommand(iClient, "give", "give molotov");
			}
			else if(StrContains(g_strCoachGrenadeSlot3, "pipe_bomb", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 2;

				RunCheatCommand(iClient, "give", "give pipe_bomb");
			}
			else if(StrContains(g_strCoachGrenadeSlot3, "empty", false) != -1)
			{
				if(StrContains(g_strCoachGrenadeSlot1, "vomitjar", false) != -1)
				{
					g_iCoachCurrentGrenadeSlot[iClient] = 0;

					RunCheatCommand(iClient, "give", "give vomitjar");
				}
				else if(StrContains(g_strCoachGrenadeSlot1, "molotov", false) != -1)
				{
					g_iCoachCurrentGrenadeSlot[iClient] = 0;

					RunCheatCommand(iClient, "give", "give molotov");
				}
				else if(StrContains(g_strCoachGrenadeSlot1, "pipe_bomb", false) != -1)
				{
					g_iCoachCurrentGrenadeSlot[iClient] = 0;

					RunCheatCommand(iClient, "give", "give pipe_bomb");
				}
			}
		}
		else if(g_iCoachCurrentGrenadeSlot[iClient] == 2)
		{
			if(StrContains(g_strCoachGrenadeSlot1, "vomitjar", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 0;

				RunCheatCommand(iClient, "give", "give vomitjar");
			}
			else if(StrContains(g_strCoachGrenadeSlot1, "molotov", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 0;

				RunCheatCommand(iClient, "give", "give molotov");
			}
			else if(StrContains(g_strCoachGrenadeSlot1, "pipe_bomb", false) != -1)
			{
				g_iCoachCurrentGrenadeSlot[iClient] = 0;

				RunCheatCommand(iClient, "give", "give pipe_bomb");
			}
			else if(StrContains(g_strCoachGrenadeSlot1, "empty", false) != -1)
			{
				if(StrContains(g_strCoachGrenadeSlot2, "vomitjar", false) != -1)
				{
					g_iCoachCurrentGrenadeSlot[iClient] = 1;

					RunCheatCommand(iClient, "give", "give vomitjar");
				}
				else if(StrContains(g_strCoachGrenadeSlot2, "molotov", false) != -1)
				{
					g_iCoachCurrentGrenadeSlot[iClient] = 1;

					RunCheatCommand(iClient, "give", "give molotov");
				}
				else if(StrContains(g_strCoachGrenadeSlot2, "pipe_bomb", false) != -1)
				{
					g_iCoachCurrentGrenadeSlot[iClient] = 1;

					RunCheatCommand(iClient, "give", "give pipe_bomb");
				}
			}
		}
	}
	g_bIsCoachGrenadeFireCycling[iClient] = false;
	g_iEventWeaponFireCounter[iClient] = 0;
	return Plugin_Stop;
}
