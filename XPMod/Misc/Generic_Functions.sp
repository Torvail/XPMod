//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////        MISCELLANEOUS FUNCTIONS       //////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/**************************************************************************************************************************
 *                                                Show XPMod Info To Server                                               *
 **************************************************************************************************************************/
 
void ShowXPModInfoToServer()
{
	PrintToServer(":---------<|============================================|>---------:");
	PrintToServer(":---------<|              XP Mod %s             |>---------:", PLUGIN_VERSION);
	PrintToServer(":---------<|============================================|>---------:");
	PrintToServer(":---------<| Created by: Chris Pringle & Ezekiel Keener |>---------:");
	PrintToServer(":---------<|============================================|>---------:");
}

bool RunClientChecks(int iClient)
{
	if (iClient < 1 || 
		iClient > MaxClients || 
		IsValidEntity(iClient) == false || 
		IsClientInGame(iClient) == false)
		return false;

	return true;
}

bool RunEntityChecks(int iEntity)
{
	if (iEntity < 1 || IsValidEntity(iEntity) == false)
		return false;

	return true;
}

bool IsIncap(int iClient)
{
	return GetEntProp(iClient, Prop_Send, "m_isIncapacitated") == 1;
}

bool KillEntitySafely(int iEntity)
{
	if (RunEntityChecks(iEntity) == false)
		return false;

	AcceptEntityInput(iEntity, "Kill");
	return true;
}

// Returns the count of records found
int GetAllEntitiesInRadiusOfEntity(int iEntity, float fRadius, int iReturnEntities[MAXENTITIES], const char[][] strClassNames, int iClassNameCount = 0)
{
	float xyzLocation[3];
	GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", xyzLocation);

	return GetAllEntitiesInRadiusOfVector(xyzLocation, fRadius, iReturnEntities, strClassNames, iClassNameCount);
}

// Returns the count of records found
int GetAllEntitiesInRadiusOfVector(float xyzLocation[3], float fRadius, int iReturnEntities[MAXENTITIES], const char[][] strClassNames, int iClassNameCount = 0)
{
	float xyzEntityLocation[3];
	char strEntityClassName[32];

	int iValidEntityCtr = 0;

	for (int iEntity=1; iEntity < MAXENTITIES; iEntity++)
	{
		if (IsValidEntity(iEntity) == false)
			continue;

		// Any entities needed will have vecOrigin property so check for that first
		if (HasEntProp(iEntity, Prop_Send, "m_vecOrigin") == false)
			continue;

		// Get the radius location and check how far away the entity is before continuing
		GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", xyzEntityLocation);
		if (GetVectorDistance(xyzLocation, xyzEntityLocation) > fRadius)
			continue;

		// If not checking against class names then add to list of return entities and move on to next
		if (iClassNameCount <= 0)
		{
			iReturnEntities[iValidEntityCtr++] = iEntity;
			continue;
		}

		strEntityClassName = "";
		GetEntityClassname(iEntity, strEntityClassName, 32);
		//PrintToServer("GetAllEntitiesInRadiusOfVector: i: %i, GetEntityClassname = %s", iEntity, strEntityClassName)
		
		// Check each, add to the list of return entities only if its an exact classname match
		for (int iIndex=0; iIndex < iClassNameCount; iIndex++)
		{
			if (strcmp(strEntityClassName, strClassNames[iIndex], true) == 0)
			{
				iReturnEntities[iValidEntityCtr++] = iEntity;
				continue;
			}
		}
	}

	return iValidEntityCtr;
}

int GetHumanPlayerCount()
{
	int iCount = 0;
	for(int i=1;i <= MaxClients; i++)
		if (RunClientChecks(i) && IsClientInGame(i) && !IsFakeClient(i))
			iCount++;
	
	return iCount;
}

void StorePlayerHealth(int iClient)
{
	if (RunClientChecks(iClient) == false ||
		IsPlayerAlive(iClient) == false ||
		IsIncap(iClient) == true)
		return;
	
	g_iPlayerHealth[iClient] = GetPlayerHealth(iClient);
	g_iPlayerHealthTemp[iClient] =  GetSurvivorTempHealth(iClient);
}

Action:TimerStorePlayerHealth(Handle timer, int iClient)
{
	StorePlayerHealth(iClient);

	return Plugin_Continue;
}

Action:TimerRepeatStoreAllPlayersHealth(Handle timer, int iNothing)
{
	for (int i=1; i <= MaxClients; i++)
		StorePlayerHealth(i);

	return Plugin_Continue;
}

// This is purely a time saver, just to get rid of the warning that a variable is 
// not being used. It can be used for simlar functions that might have a need for
// a variable later, its just not used yet.
void SuppressNeverUsedWarning(any:var1=0, any:var2=0, any:var3=0, any:var4=0, any:var5=0, any:var6=0, any:var7=0, any:var8=0, any:var9=0, any:var10=0)
{
	bool ignore;
	if(ignore) PrintToServer("THIS IS NEVER GOING TO BE RAN",var1, var2, var3, var4, var5, var6, var7, var8, var9, var10);
}

int GetClientAdminLevel(iClient)
{
	if (CheckCommandAccess(iClient, "", ADMFLAG_BAN, true))
		return ADMFLAG_BAN;
	if (CheckCommandAccess(iClient, "", ADMFLAG_KICK, true))
		return ADMFLAG_KICK;
	if (CheckCommandAccess(iClient, "", ADMFLAG_SLAY, true))
		return ADMFLAG_SLAY;
	if (CheckCommandAccess(iClient, "", ADMFLAG_GENERIC, true))
		return ADMFLAG_GENERIC;

	return -1;
}

//Find the current gamemode and store it into this plugin
void FindGameMode()
{
	//Get the gamemode string from the game
	decl String:strGameMode[20];
	GetConVarString(FindConVar("mp_gamemode"), strGameMode, sizeof(strGameMode));
	
	//Set the global gamemode int for this plugin
	if(StrEqual(strGameMode, "coop"))
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "realism"))
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode,"versus"))
		g_iGameMode = GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "teamversus"))
		g_iGameMode = GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "scavenge"))
		g_iGameMode = GAMEMODE_SCAVENGE;
	else if(StrEqual(strGameMode, "teamscavenge"))
		g_iGameMode = GAMEMODE_SCAVENGE;
	else if(StrEqual(strGameMode, "survival"))
		g_iGameMode = GAMEMODE_SURVIVAL;
	else if(StrEqual(strGameMode, "mutation1"))		//Last Man On Earth
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation2"))		//Headshot!
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation3"))		//Bleed Out
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation4"))		//Hard Eight
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation5"))		//Four Swordsmen
		g_iGameMode = GAMEMODE_COOP;
	//else if(StrEqual(strGameMode, "mutation6"))	//Nothing here
	//	g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation7"))		//Chainsaw Massacre
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation8"))		//Ironman
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation9"))		//Last Gnome On Earth
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation10"))	//Room For One
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation11"))	//Healthpackalypse!
		g_iGameMode = GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "mutation12"))	//Realism Versus
		g_iGameMode = GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "mutation13"))	//Follow the Liter
		g_iGameMode = GAMEMODE_SCAVENGE;
	else if(StrEqual(strGameMode, "mutation14"))	//Gib Fest
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation15"))	//Versus Survival
		g_iGameMode = GAMEMODE_VERSUS_SURVIVAL;
	else if(StrEqual(strGameMode, "mutation16"))	//Hunting Party
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation17"))	//Lone Gunman
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation18"))	//Bleed Out Versus
		g_iGameMode = GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "mutation19"))	//Taaannnkk!
		g_iGameMode = GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "mutation20"))	//Healing Gnome
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "community1"))	//Special Delivery
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "community2"))	//Flu Season
		g_iGameMode = GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "community3"))	//Riding My Survivor
		g_iGameMode = GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "community4"))	//Nightmare
		g_iGameMode = GAMEMODE_SURVIVAL;
	else if(StrEqual(strGameMode, "community5"))	//Death's Door
		g_iGameMode = GAMEMODE_COOP;
	else
		g_iGameMode = GAMEMODE_UNKNOWN;
}

bool RunCheatCommand(int iClient, const char [] strCommandName, const char [] strCommandWithArgs)
{
	if (RunClientChecks(iClient) == false)
		return false;

	// Get the command flags
	new iFlag = GetCommandFlags(strCommandName);
	if (iFlag == INVALID_FCVAR_FLAGS)
	{
		PrintToServer("ERROR GETTING COMMAND FLAGS!");
		return false;
	}

	// Handle XPMod Related Tasks
	HandleCheatCommandTasks(iClient, strCommandWithArgs);

	// Temp turn on the cheats for this command, run command,
	// and then turn off the cheats again
	SetCommandFlags(strCommandName, iFlag & ~FCVAR_CHEAT);
	FakeClientCommand(iClient, strCommandWithArgs);
	SetCommandFlags(strCommandName, iFlag);

	return true;
}

void HandleCheatCommandTasks(int iClient, const char [] strCommandWithArgs)
{
	HandleCheatCommandTasks_Ellis(iClient, strCommandWithArgs);
	HandleCheatCommandTasks_Nick(iClient);
	HandleCheatCommandTasks_Louis(iClient, strCommandWithArgs);
}

Action:Timer_ShowXPModInfoToServer(Handle:timer, any:data)
{
	ShowXPModInfoToServer();
	
	return Plugin_Stop;
}

AdvertiseXPModToNewUser(iClient, bool:bShowInChat = false)
{
	EmitSoundToClient(iClient, SOUND_XPM_ADVERTISEMENT, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_TRAIN);
	PrintHintText(iClient, "Type xpm in chat to use XPMod");
	if(bShowInChat)
		PrintToChat(iClient, "\x05Type \x04xpm\x05 in chat to use \x03XPMod\x05!");
}

AdvertiseConfirmXPModTalents(iClient)
{
	PrintHintText(iClient, "Your abilities are NOT loaded. Type xpm in chat and confirm to gain them.");
	//PrintToChat(iClient, "\x03[XPMod] \x05Your talents are NOT loaded. Type \x04xpm\x05 and confirm them.");
}

/**************************************************************************************************************************
 *                                                                                                        *
 **************************************************************************************************************************/

OpenMOTDPanel(iClient, const String:title[], const  String:msg[], type = MOTDPANEL_TYPE_INDEX)
{
	if (RunClientChecks(iClient) == false || IsFakeClient(iClient) == true)
		return;
	
	decl String:num[3];
	new Handle:Kv = CreateKeyValues("data");
	IntToString(type, num, sizeof(num));
	
	KvSetString(Kv, "title", title);
	KvSetString(Kv, "type", num);
	KvSetString(Kv, "msg", msg);
	ShowVGUIPanel(iClient, "info", Kv, true);
	CloseHandle(Kv);
}

Action:MotdPanel(iClient, args)
{
	//OpenMOTDPanel(iClient, "Choose Your Survivor", "addons/sourcemod/plugins/xpmod/XPMod Website - InGame/Home/xpmod_ig_home.html", MOTDPANEL_TYPE_FILE);
	OpenMOTDPanel(iClient, "XPMod Website", "http://xpmod.net", MOTDPANEL_TYPE_URL);
	return;
}

//Probe Teams for Real Players.   Returns true if there is a non-bot player on inputed team
bool:ProbeTeams(team)
{
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)  && g_iClientTeam[i] == team && IsFakeClient(i) == false)
			return true;
	
	return false;
}

//Taken from djromero's switch players plugin
bool:IsTeamFull(team)
{
	// Spectator's team is never full
	if (team == 1)
		return false;
	
	new max;
	new count;
	new i;
	
	// we count the players in the survivor's team
	if (team == 2)
	{
		max = GetConVarInt(FindConVar("survivor_limit"));
		count = 0;
		for (i=1;i<= MaxClients;i++)
			if ((IsClientInGame(i))&&(!IsFakeClient(i))&&(GetClientTeam(i)==2))
				count++;
	}
	else if (team == 3) // we count the players in the infected's team
	{
		max = GetConVarInt(FindConVar("z_max_player_zombies"));
		count = 0;
		for (i=1;i<= MaxClients;i++)
			if ((IsClientInGame(i))&&(!IsFakeClient(i))&&(GetClientTeam(i)==3))
				count++;
	}
	
	// If full ...
	if (count >= max)
		return true;

	return false;
}

SetMoveType(iClient, movetype, movecollide)
{
	SetEntData(iClient, g_iOffset_MoveType, movetype);
	SetEntData(iClient, g_iOffset_MoveCollide, movecollide);

	// PrintToChatAll("SetMoveType: %N", iClient);
}

SetSurvivorModel(iClient)
{
	if (GetClientTeam(iClient) != TEAM_SURVIVORS)
	{
		PrintToChat (iClient, "\x03You are not on the Survivors.");
		return;
	}
	
	
	switch(g_iChosenSurvivor[iClient])
	{
		// Note: SetEntProp works, but it causes the characters (bot or human) to
		// disappear from the ui like tab menu and the bottom of the screen.  So,
		// its better to just not set this and leave the character hands/voice/icon.
		case BILL:
		{
			//SetEntProp(iClient, Prop_Send, "m_survivorCharacter", 4);
			SetEntityModel(iClient, "models/survivors/survivor_namvet.mdl");
		}
		case ROCHELLE:
		{
			//SetEntProp(iClient, Prop_Send, "m_survivorCharacter", 1);
			SetEntityModel(iClient, "models/survivors/survivor_producer.mdl");
		}
		case COACH:
		{
			//SetEntProp(iClient, Prop_Send, "m_survivorCharacter", 2);
			SetEntityModel(iClient, "models/survivors/survivor_coach.mdl");
		} 	
		case ELLIS:
		{
			//SetEntProp(iClient, Prop_Send, "m_survivorCharacter", 3);
			SetEntityModel(iClient, "models/survivors/survivor_mechanic.mdl");
		} 	
		case NICK:
		{
			//SetEntProp(iClient, Prop_Send, "m_survivorCharacter", 0);
			SetEntityModel(iClient, "models/survivors/survivor_gambler.mdl");
		}
		case LOUIS:
		{
			//SetEntProp(iClient, Prop_Send, "m_survivorCharacter", 0);
			SetEntityModel(iClient, "models/survivors/survivor_manager.mdl");
		}

		// NOTE, when adding zoey here, there could be issues...
		// This SCS survivor_chat_select plugin changes to a differnt model
		// https://forums.alliedmods.net/showthread.php?p=2399163#post2399163

		// Probably need a fix for l4d1 survivors on the passing campaign (Francis was specifically mentioned)
		// Recommended plugin: The Passing CSM Fix 2.0 (prevents game breaking bugs if L4D1 survivors are used in The Passing)
		// Fixes the bug where players with L4D1 survivors are teleported away or kicked on The Passing
		// https://forums.alliedmods.net/showthread.php?p=2407497#post2407497 
	}
}

//Toggles
Action:ToggleAnnouncerVoice(iClient)	//Toggles the announcers voice
{
	if(iClient!=0)
	{
		if(g_bAnnouncerOn[iClient]==false)
		{
			decl Float:vec[3];
			GetClientEyePosition(iClient, vec);
			EmitAmbientSound(SOUND_GETITON, vec, iClient, SNDLEVEL_NORMAL);
			g_bAnnouncerOn[iClient] = true;
			PrintHintText(iClient, "Announcer is now ON.");
		}
		else
		{
			PrintHintText(iClient, "Announcer is now OFF.");
			g_bAnnouncerOn[iClient] = false;
		}
	}
	return Plugin_Handled;
}

Action:ToggleVGUIDesc(iClient)	//Toggles the vgui menu descriptions for talents
{
	if(iClient!=0)
	{
		if(g_bEnabledVGUI[iClient]==false)
		{
			g_bEnabledVGUI[iClient] = true;
			PrintHintText(iClient, "VGUI Menu Descriptions are now ON.");
		}
		else
		{
			PrintHintText(iClient, "VGUI Menu Descriptions are now OFF.");
			g_bEnabledVGUI[iClient] = false;
		}
	}
	
	return Plugin_Handled;
}

ShowHudOverlayColor(iClient, iRed, iGreen, iBlue, iAlpha, iDuration, iBehavior = FADE_SOLID)
{
	decl clients[1];
	clients[0] = iClient;
	new Handle:message = StartMessageEx(g_umsgFade, clients, 1);
	
	BfWriteShort(message, iDuration);
	BfWriteShort(message, iDuration);
	BfWriteShort(message, iBehavior);
	BfWriteByte(message, iRed);
	BfWriteByte(message, iGreen);
	BfWriteByte(message, iBlue);
	BfWriteByte(message, iAlpha);
	EndMessage();
}

StopHudOverlayColor(iClient)
{
	ShowHudOverlayColor(iClient, 0, 0, 0, 0, 100, FADE_STOP);
}

Action:ShowBindsRemaining(iClient, args)
{
	if(iClient < 1 || IsClientInGame(iClient) == false || IsFakeClient(iClient) == true)
		return;
	
	decl String:strText[64];
	FormatEx(strText, sizeof(strText), "\x05Bind 1: %d Uses Remain\nBind 2: %d Uses Remain", (3 - g_iClientBindUses_1[iClient]), (3 - g_iClientBindUses_2[iClient]));
	PrintToChat(iClient, strText);
}

GiveClientXP(iClient, iAmount, iSprite, iVictim, String:strMessage[64], bool:bCenterText = false, Float:fLifeTime = 3.0)
{
	if(iClient < 1 || IsClientInGame(iClient) == false || IsFakeClient(iClient) == true)
		return;
	
	g_iClientXP[iClient] += iAmount;
	CheckLevel(iClient);
	
	if(g_iXPDisplayMode[iClient] == 0)
		ShowXPSprite(iClient, iSprite, iVictim, fLifeTime);
	else if(g_iXPDisplayMode[iClient] == 1)
	{
		if(bCenterText == false)
			PrintToChat(iClient, "\x03[XPMod] %s You gain %d XP", strMessage, iAmount);
		// else
		// 	PrintCenterText(iClient, "%s You gain %d XP", strMessage, iAmount);
	}	
}

void GotoThirdPerson(int iClient)
{
	SetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget", 0);
	SetEntProp(iClient, Prop_Send, "m_iObserverMode", 1);
	SetEntProp(iClient, Prop_Send, "m_bDrawViewmodel", 0);
}

void GotoFirstPerson(int iClient)
{
	SetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget", -1);
	SetEntProp(iClient, Prop_Send, "m_iObserverMode", 0);
	SetEntProp(iClient, Prop_Send, "m_bDrawViewmodel", 1);
}

Action TimerResetPlayerMoveType(Handle:timer, int iClient)
{
	g_bMovementLocked[iClient] = false;
	SetClientSpeed(iClient);
	SetPlayerMoveType(iClient);
	return Plugin_Stop;
}

int SetPlayerMoveType(int iClient, int iMoveType = MOVETYPE_WALK)
{
	if (RunClientChecks(iClient) == false ||
		IsPlayerAlive(iClient) == false)
		return -1;

	SetEntProp(iClient, Prop_Send, "movetype", iMoveType, 1);

	//PrintToChat(iClient, "movetype now %i", GetEntProp(iClient, Prop_Send, "movetype", 1));

	return  GetEntProp(iClient, Prop_Send, "movetype", 1);
}

void LockPlayerFromAttacking(int iClient)
{
	// PrintToChat(iClient, "LockPlayerFromAttacking start");
	new iWeaponEntity = GetEntDataEnt2(iClient,g_iOffset_ActiveWeapon);
	if (RunEntityChecks(iWeaponEntity) == false)
		return;
	
	//float flNextTime_ret = GetEntDataFloat(iWeaponEntity,g_iOffset_NextPrimaryAttack);

	SetEntDataFloat(iWeaponEntity, g_iOffset_TimeWeaponIdle, 999999.9, true);
	SetEntDataFloat(iWeaponEntity, g_iOffset_NextPrimaryAttack, 999999.0, true);
	SetEntDataFloat(iClient, g_iOffset_NextAttack, 999999.0, true);

	// PrintToChat(iClient, "LockPlayerFromAttacking end");
}

void UnlockPlayerFromAttacking(int iClient)
{
	if (RunClientChecks(iClient) == false ||
		IsPlayerAlive(iClient) == false)
		return;

	// PrintToChat(iClient, "UnlockPlayerFromAttacking start");
	new iWeaponEntity = GetEntDataEnt2(iClient, g_iOffset_ActiveWeapon);
	if (RunEntityChecks(iWeaponEntity) == false)
		return;
	
	//float flNextTime_ret = GetEntDataFloat(iWeaponEntity,g_iOffset_NextPrimaryAttack);

	float fGameTime = GetGameTime();

	SetEntDataFloat(iWeaponEntity, g_iOffset_TimeWeaponIdle, fGameTime, true);
	SetEntDataFloat(iWeaponEntity, g_iOffset_NextPrimaryAttack, fGameTime, true);
	SetEntDataFloat(iClient, g_iOffset_NextAttack, fGameTime, true);

	// PrintToChat(iClient, "UnlockPlayerFromAttacking end");
}


// Note: this actually creates a damage event, so no need to reduce damage here
void DealDamage(int iVictim, int iAttacker, int iAmount, int iDamageType = DAMAGETYPE_INFECTED_MELEE)
{
	//This function was originally written by AtomikStryker
	decl Float:iVictimPosition[3], String:strDamage[16], String:strDamageType[16], String:strDamageTarget[16];
	
	//GetClientEyePosition(iVictim, iVictimPosition);
	GetEntPropVector(iVictim, Prop_Send, "m_vecOrigin", iVictimPosition);
	IntToString(iAmount, strDamage, sizeof(strDamage));
	IntToString(iDamageType, strDamageType, sizeof(strDamageType));
	Format(strDamageTarget, sizeof(strDamageTarget), "hurtme%d", iVictim);
	
	new entPointHurt = CreateEntityByName("point_hurt");
	if(!entPointHurt)
		return;
	
	// Config, create point_hurt
	DispatchKeyValue(iVictim, "targetname", strDamageTarget);
	DispatchKeyValue(entPointHurt, "DamageTarget", strDamageTarget);
	DispatchKeyValue(entPointHurt, "Damage", strDamage);
	//DispatchKeyValue(entPointHurt, "DamageType", blockreviving ? "65536" : "128");
	DispatchKeyValue(entPointHurt, "DamageType", strDamageType);
	DispatchSpawn(entPointHurt);
	
	// Teleport, activate point_hurt
	TeleportEntity(entPointHurt, iVictimPosition, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entPointHurt, "Hurt", (iAttacker > 0 && iAttacker <= MaxClients && IsClientInGame(iAttacker)) ? iAttacker : -1);
	
	// Config, delete point_hurt
	DispatchKeyValue(entPointHurt, "classname", "point_hurt");
	DispatchKeyValue(iVictim, "targetname", "null");

	if (entPointHurt > 0 && IsValidEntity(entPointHurt))
		AcceptEntityInput(entPointHurt, "Kill");
}

void ReduceDamageTakenForNewPlayers(int iVictim, int iAttacker, int iDmgAmount)
{
	// Reduce damage for low level human survivor players that are not incaped
	if (g_iClientTeam[iVictim] != TEAM_SURVIVORS || 
		g_iClientLevel[iVictim] == 30 || 
		RunClientChecks(iVictim) == false ||
		// IsFakeClient(iVictim) || 
		IsIncap(iVictim) == true)
		return;

	// Skip if the attacker is a Nick (could be using pistol healing)
	if (g_iChosenSurvivor[iAttacker] == NICK &&
		g_iClientTeam[iAttacker] == TEAM_SURVIVORS &&
		g_bTalentsConfirmed[iAttacker] == true &&
		RunClientChecks(iAttacker) == true)
		return

	// new iCurrentHealth = GetPlayerHealth(iVictim);
	new iReductionAmount = RoundToFloor(( iDmgAmount * ( NEW_PLAYER_MAX_DAMAGE_REDUCTION * (1.0 - (float(g_iClientLevel[iVictim]) / 30.0)) ) ) );
	//Ensure at least 1 damage is done
	if (iReductionAmount >= iDmgAmount)
		iReductionAmount = iDmgAmount - 1;

	// There is a cvar called z_hit_from_behind_factor that reduces player damage from CI when hit behind by 50% default
	// This is problematic here, because the player_hurt event does not have a way of capturing this
	// The compromise made here is when its an infected common attacking, limit to never give more than half damage - 1 more health
	// This will make it so that the player always loses at least 1 health when hit by common infected
	if ( iAttacker <= 0 && iDmgAmount >= 2 && iReductionAmount > (RoundToNearest(iDmgAmount * 0.5) - 1) )
		iReductionAmount = RoundToNearest(iDmgAmount * 0.5) - 1;

	// Dont take more health
	if (iReductionAmount < 1)
		return;

	// PrintToChatAll("%N iCurrentHealth = %i dmg = %i, reduction %i", iVictim, iCurrentHealth, iDmgAmount, iReductionAmount);
	SetPlayerHealth(iVictim, iAttacker, iReductionAmount, true);
}

// NOTE: This function is for additional damage, not handling the original damage amount
int CalculateDamageTakenForVictimTalents(int iVictim, int iDmgAmount, const char[] strWeaponClass = "")
{
	if (RunClientChecks(iVictim) == false || 
		IsPlayerAlive(iVictim) == false)
		return 0;
	
	int iDmgReductionOrAddition = 0;

	iDmgReductionOrAddition = CalculateDamageForVictimTalents_Tank_Vampiric(iVictim, iDmgAmount, strWeaponClass);

	return iDmgReductionOrAddition == 0 ? iDmgAmount : iDmgReductionOrAddition;
}

//This function was originally written by AtomikStryker
bool:IsVisibleTo(Float:position[3], Float:targetposition[3])
{
	decl Float:vAngles[3], Float:vLookAt[3];
	
	MakeVectorFromPoints(position, targetposition, vLookAt); // compute vector from start to target
	GetVectorAngles(vLookAt, vAngles); // get angles from vector for trace
	
	// execute Trace
	new Handle:trace = TR_TraceRayFilterEx(position, vAngles, MASK_SHOT, RayType_Infinite, TraceRayTryToHit);
	
	new bool:isVisible = false;
	
	if (TR_DidHit(trace))
	{
		decl Float:vStart[3];
		TR_GetEndPosition(vStart, trace); // retrieve our trace endpoint
		
		if ((GetVectorDistance(position, vStart, false) + 25.0) >= GetVectorDistance(position, targetposition))
		{
			isVisible = true; // if trace ray lenght plus tolerance equal or bigger absolute distance, you hit the target
		}
	}
	//else
	//	isVisible = true;
	
	CloseHandle(trace);
	
	return isVisible;
}

// Check if player can be seen by other players, return their distance in the array
void GetAllVisiblePlayersForClient(int iClient, float[] fVisibleClientDistance, int iTeamToCheck=-1, float fMinDistanceOverride=0.0)
{
	float xyzClientLocation[3], xyzTargetLocation[3], fDistance;
	GetClientEyePosition(iClient, xyzClientLocation);

	// Check for visible targets that are within range
	for (int iTarget; iTarget <= MaxClients; iTarget++)
	{
		if (RunClientChecks(iTarget) == false || 
			(iTeamToCheck != -1 && g_iClientTeam[iTarget] != iTeamToCheck) ||
			IsPlayerAlive(iTarget) == false)
			continue;

		GetClientEyePosition(iTarget, xyzTargetLocation);
		fDistance = GetVectorDistance(xyzClientLocation, xyzTargetLocation);
		// Get if the target is visible to and check the range if target to worry about
		if (IsVisibleTo(xyzClientLocation, xyzTargetLocation) || 
			(fMinDistanceOverride > 0.0 && fDistance <= fMinDistanceOverride))
		{
			// PrintToChat(iClient, "Viable Target %N Spotted by %N", iTarget, iClient);
			fVisibleClientDistance[iTarget] = fDistance;
		}
	}
}


void GetLookAtAnglesFromPoints(const float xyzPositionStart[3], const float xyzPositionEnd[3], float vLookAtAngles[3])
{
	float vLookVectorLine[3];
	MakeVectorFromPoints(xyzPositionStart, xyzPositionEnd, vLookVectorLine);
	GetVectorAngles(vLookVectorLine, vLookAtAngles);

	// PrintToChatAll("xyzPositionStart: %f %f %f", xyzPositionStart[0], xyzPositionStart[1], xyzPositionStart[2]);
	// PrintToChatAll("xyzPositionEnd: %f %f %f", xyzPositionEnd[0], xyzPositionEnd[1], xyzPositionEnd[2]);
	// PrintToChatAll("vLookVectorLine: %f %f %f", vLookVectorLine[0], vLookVectorLine[1], vLookVectorLine[2]);
	// PrintToChatAll("vLookAtAngles: %f %f %f", vLookAtAngles[0], vLookAtAngles[1], vLookAtAngles[2]);
}

AttachInfected(i_Ent, Float:fOrigin[3])
{
	decl i_InfoEnt, String:s_TargetName[32];
	
	i_InfoEnt = CreateEntityByName("info_goal_infected_chase");
	
	if (IsValidEdict(i_InfoEnt))
	{
		fOrigin[2] += 20.0;
		DispatchKeyValueVector(i_InfoEnt, "origin", fOrigin);
		FormatEx(s_TargetName, sizeof(s_TargetName), "goal_infected%d", i_Ent);
		DispatchKeyValue(i_InfoEnt, "targetname", s_TargetName);
		GetEntPropString(i_Ent, Prop_Data, "m_iName", s_TargetName, sizeof(s_TargetName));
		DispatchKeyValue(i_InfoEnt, "parentname", s_TargetName);
		DispatchSpawn(i_InfoEnt);
		SetVariantString(s_TargetName);
		AcceptEntityInput(i_InfoEnt, "SetParent", i_InfoEnt, i_InfoEnt, 0);
		ActivateEntity(i_InfoEnt);
		AcceptEntityInput(i_InfoEnt, "Enable");
	}

	return i_InfoEnt;
}



/**************************************************************************************************************************
 *                                                     Player Freezing                                                    *
 **************************************************************************************************************************/
 
Action:FreezeGame(admin, args)
{
	g_bGameFrozen = true;
	new String:time[20];
	GetCmdArg(1, time, sizeof(time));
	new freezetime;
	for(new i=1;i<=MaxClients;i++)
	{
		if(RunClientChecks(i) && GetClientTeam(i) == TEAM_SURVIVORS)
		{
			decl Float:vec[3];
			//GetClientAbsOrigin(i, vec);
			//vec[2] += 10;
			GetClientEyePosition(i, vec);
			EmitAmbientSound(SOUND_FREEZE, vec, i, SNDLEVEL_NORMAL);
			SetEntityRenderMode(i, RenderMode:3);
			SetEntityRenderColor(i, 0, 180, 255, 160);
			SetEntDataFloat(i , FindSendPropInfo("CTerrorPlayer","m_flLaggedMovementValue"), 0.0, true);
			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
			new Float:cvec[3];
			cvec[0] = 10.0;
			cvec[1] = 10.0;
			cvec[2] = 10.0;
			g_iClientBindUses_1[i] = 0;
			g_iClientBindUses_2[i] = 0;
			//new gc = FindDataMapInfo(i,"m_glowColor");
			//SetEntDataVector(i, gc, cvec, true);
			//SetEntPropVector(i, Prop_Data, "glowcolor", cvec);
			//DispatchKeyValue(i, "m_glowColor", "0 0 0");
			//m_glowColor (Save|Key)(4 Bytes) - glowcolor
		}
	}
	freezetime = StringToInt(time);
	CreateTimer(float(freezetime), TimerUnfreeze, 0, TIMER_FLAG_NO_MAPCHANGE);
	PrintHintTextToAll("Survivors are frozen for %d more seconds to choose your talents.", freezetime);
}

PlayerFreeze(iClient)
{
	if(IsClientInGame(iClient)==true)
	{
		CreateTimer(0.1, FreezeColor, iClient, TIMER_FLAG_NO_MAPCHANGE);
		SetEntDataFloat(iClient , FindSendPropInfo("CTerrorPlayer","m_flLaggedMovementValue"), 0.0, true);
		SetEntProp(iClient, Prop_Data, "m_takedamage", 0, 1);
	}
	PrintHintText(iClient, "Survivors are temporarily frozen to choose your talents.");
}

/**************************************************************************************************************************
 *                                                     Find Playerrs                                                      *
 **************************************************************************************************************************/


// FindAllPlayers(clients[])
// {
// 	new ctr = 0;
// 	decl i;
// 	for(i = 1;i <= MaxClients;i++)
// 	{
// 		if(IsClientInGame(i))
// 		{
// 			clients[ctr] = i;
// 			ctr++;
// 		}
// 	}
// 	return ctr;
// }

FindPlayerByName(iClient, const String:targetname[])
{
	new String:name[128];
	new i, temp;
	for (i=1;i <= MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;
		if(IsFakeClient(i))
			continue;
		GetClientName(i, name, sizeof(name));
		temp = StrContains(name,targetname,false);
		if(temp > -1)
			return i;
	}
	if(iClient==0)
		PrintToServer("[XPMod] Could not find player with %s in their name.", targetname);
	else
		PrintToChat(iClient, "\x03[XPMod] \x01Could not find player with \x04%s \x01in their name.", targetname);
	return -1;
}

/**************************************************************************************************************************
 *                                                Play Sounds for Events                                                  *
 **************************************************************************************************************************/

PlayKillSound(iClient)
{
	switch(g_iStat_ClientInfectedKilled[iClient])
	{
		case 1:
		{
			EmitSoundToClient(iClient, SOUND_1KILL);
		}
		case 2:
		{
			EmitSoundToClient(iClient, SOUND_2KILLS);
		}
		case 3:
		{
			EmitSoundToClient(iClient, SOUND_3KILLS);
		}
		case 4:
		{
			EmitSoundToClient(iClient, SOUND_4KILLS);
		}
		case 5:
		{
			EmitSoundToClient(iClient, SOUND_5KILLS);
		}
		case 6:
		{
			EmitSoundToClient(iClient, SOUND_6KILLS);
		}
		case 7:
		{
			EmitSoundToClient(iClient, SOUND_7KILLS);
		}
		case 8:
		{
			EmitSoundToClient(iClient, SOUND_8KILLS);
		}
		case 9:
		{
			EmitSoundToClient(iClient, SOUND_9KILLS);
		}
		case 10:
		{
			EmitSoundToClient(iClient, SOUND_10KILLS);
		}
		case 11:
		{
			EmitSoundToClient(iClient, SOUND_11KILLS);
		}
		case 12:
		{
			EmitSoundToClient(iClient, SOUND_12KILLS);
		}
		case 13:
		{
			EmitSoundToClient(iClient, SOUND_13KILLS);
		}
		case 14:
		{
			EmitSoundToClient(iClient, SOUND_14KILLS);
		}
		case 15:
		{
			EmitSoundToClient(iClient, SOUND_15KILLS);
		}
		default:
		{
			EmitSoundToClient(iClient, SOUND_16KILLS);
		}
	}
}

PlayHeadshotSound(iClient)
{
	decl random;
	random = GetRandomInt(1,3);
	switch(random)
	{
		case 1:
		{
			EmitSoundToClient(iClient, SOUND_HEADSHOT1);
		}
		case 2:
		{
			EmitSoundToClient(iClient, SOUND_HEADSHOT2);
		}
		case 3:
		{
			EmitSoundToClient(iClient, SOUND_HEADSHOT3);
		}
	}
	g_bCanPlayHeadshotSound[iClient] = false;
}

/**************************************************************************************************************************
 *                                                      Trace Filters                                                     *
 **************************************************************************************************************************/

bool:TraceRayTryToHit(entity,mask)
{
	if((entity > 0) && (entity <= 64))	// Check if the beam hit a player and tell it to keep tracing if it did
		return false;
	
	return true;
}

// bool:TraceRayGrabEnt(entity,mask)
// {
// 	if(entity > 0)	// Check if the beam hit an entity other than the grabber, and stop if it does
// 	{
// 		if((entity <= 64) && (!g_bUsingTongueRope[entity]))
// 			return true;
// 		if(entity > 64)
// 			return true;
// 	}
	
// 	return false;
// }

// bool:TraceEntityFilter_NotSelf(iEntity, mask, any:data)
// {
//     if (iEntity == data)	// Check if the TraceRay hit the itself.
//         return false;	// Don't let the entity be hit
		
//     return true;		// It didn't hit itself
// }

public bool:TraceEntityFilter_NotAPlayer(iEntity, iContentsMask, any:data)
{
	// Check for collision with self
	if (iEntity == data)
		return false;

	for(int iClient = 1; iClient <= MaxClients; iClient++)
	{		
		if(RunClientChecks(iClient) == false)
			continue;

		if (iEntity == iClient)	// Check if the TraceRay hit the a client.
			return false;		// Don't let the entity be hit
	}

	return true;		// It didn't hit a client
}

bool IsClientGrappled(iClient)
{
	if (g_bChargerCarrying[iClient] == true || 
		g_bChargerGrappled[iClient] == true || 
		g_bSmokerGrappled[iClient] == true || 
		g_bJockeyGrappled[iClient] == true || 
		g_bHunterGrappled[iClient] == true)
	{
		DebugLog(DEBUG_MODE_VERBOSE, "IsClientGrappled(%N): true", iClient);
		return true;
	}
		
	DebugLog(DEBUG_MODE_VERBOSE, "IsClientGrappled(%N): false", iClient);
	return false;
}

// bool:IsJockeyGrappled(iClient)
// {
// 	decl i;
// 	for(i = 0; i <= MaxClients; i++)
// 		if(g_iJockeyVictim[i] == iClient)
// 			return true;
	
// 	return false;
// }

Action:OpenHelpMotdPanel(iClient, args)
{
	OpenMOTDPanel(iClient, "", "http://xpmod.net/help/xpmod_ig_help.html", MOTDPANEL_TYPE_URL);
	return Plugin_Handled;
}

int FindIndexInArrayListUsingValue(ArrayList list, iValueToFind, iColumn=0)
{
	if (list == INVALID_HANDLE)
		return -1;

	for (int i=0; i < list.Length; i++)
	{
		new currentValue = list.Get(i, iColumn);
		if (currentValue == iValueToFind)
			return i;
	}

	return -1;
}

int FindIndexInStringArrayUsingValue(const char[][] strArray, const iSizeOfArray, const char[] strValue)
{
	for (int i=0; i < iSizeOfArray; i++)
	{
		// PrintToServer("%i sizeofarray %i, value=%s", i, iSizeOfArray, strValue);
		if (strcmp(strArray[i], strValue, true) == 0)
			return i;
	}

	return -1;
}

void ShiftArrayOfStrings(char[][] strArray, const int iStringSize, const int iStartPoint=0, const int iEndPoint=1)
{
	for (int i=iEndPoint-1; i >= iStartPoint; i--)
	{
		// This needs to be done with the temp string
		// If doing strArray[i+1] = strArray[i] directly it fails
		char strTemp[256] = "";
		strcopy(strTemp, iStringSize, strArray[i]);
		strcopy(strArray[i+1], iStringSize, strTemp);
	}
}

bool IsEntityUncommonInfected(iInfectedEntity)
{
	// Get the infected entity type (common or uncommon)
	decl String:strClassname[99];
	GetEdictClassname(iInfectedEntity, strClassname, sizeof(strClassname));
	//PrintToChatAll("edict classname: %s", strClassname);
	if (StrEqual(strClassname, "infected", true) == false)
		return false;

	// Get the infected model name
	new String:strModelName[128];
	GetEntPropString(iInfectedEntity, Prop_Data, "m_ModelName", strModelName, 128);

	// Check if the model name corresponds to an uncommon one
	for (new i; i < sizeof(UNCOMMON_INFECTED_MODELS); i++)
	{
		//PrintToChatAll("CHECKING %s", UNCOMMON_INFECTED_MODELS[i]);
		if (StrEqual(strModelName, UNCOMMON_INFECTED_MODELS[i], false))
			return true;
	}

	return false;		
}

// float FindClosestSurvivorDistance(iClient)
// {
// 	if (RunClientChecks(iClient) == false)
// 		return 999999.0;

// 	new Float:fdistance = 999999.0;
// 	decl Float:xyzClientOrigin[3], Float:xyzTargetOrigin[3];
// 	GetClientEyePosition(iClient, xyzClientOrigin);	//Get clients location origin vectors

// 	// Loop through the survivors and find the closest by checking distances
// 	for (new iTarget; iTarget <= MaxClients; iTarget++)
// 	{
// 		if (RunClientChecks(iTarget) && g_iClientTeam[iTarget] == TEAM_SURVIVORS)
// 		{
// 			GetClientEyePosition(iTarget, xyzTargetOrigin);
// 			new Float:fNewDistance = GetVectorDistance(xyzTargetOrigin, xyzClientOrigin);
// 			//PrintToChatAll("Checking: %N -> %f", iTarget, fNewDistance);
// 			if (fNewDistance < fdistance)
// 				fdistance = fNewDistance;
// 		}
// 	}

// 	//PrintToChatAll("FindClosestSurvivorDistance %f", fdistance);
// 	return fdistance;		
// }

int FindClosestSurvivor(int iClient, bool bIgnoreIncap = false)
{
	if (RunClientChecks(iClient) == false)
		return -1;

	int iClosestSurvivor = -1;
	float fdistance = 999999.0;
	float xyzClientOrigin[3], xyzTargetOrigin[3];
	GetClientEyePosition(iClient, xyzClientOrigin);	//Get clients location origin vectors

	// Loop through the survivors and find the closest by checking distances
	for (new iTarget = 1; iTarget <= MaxClients; iTarget++)
	{
		if (iTarget == iClient || 
			RunClientChecks(iTarget) == false || 
			g_iClientTeam[iTarget] != TEAM_SURVIVORS ||
			IsPlayerAlive(iTarget) == false ||
			(bIgnoreIncap && IsIncap(iTarget))) // For ignoring incap players
			continue;

		GetClientEyePosition(iTarget, xyzTargetOrigin);
		new Float:fNewDistance = GetVectorDistance(xyzTargetOrigin, xyzClientOrigin);

		//PrintToChatAll("Checking: %N -> %f", iTarget, fNewDistance);
		if (fNewDistance < fdistance)
		{
			fdistance = fNewDistance;
			iClosestSurvivor =  iTarget;
		}
	}

	return iClosestSurvivor;		
}

void GetLocationVectorInfrontOfClient(iClient, float xyzLocation[3], float xyzAngles[3], float fForwardOffset = 40.0, float fVerticalOffset = 1.0, float fLeftRightOffset = 0.0)
{
	float vDirection[3];

	GetEntPropVector(iClient, Prop_Send, "m_angRotation", xyzAngles);	// Get clients Angles to know get what direction face
	GetAngleVectors(xyzAngles, vDirection, NULL_VECTOR, NULL_VECTOR);	// Get the direction the iClient is looking
	xyzAngles[0] = 0.0;	//Lock x and z axis, in other words, only do rotation as if a person is standing up and turning
	xyzAngles[2] = 0.0;

	GetClientAbsOrigin(iClient, xyzLocation);				// Get Clients location origin vectors
	xyzLocation[0] += (vDirection[0] * fForwardOffset);		// Offset x and y a bit forward of the players view
	xyzLocation[1] += (vDirection[1] * fForwardOffset);
	xyzLocation[2] += (vDirection[2] + fVerticalOffset);	// Raise it up slightly to prevent glitches

	// Check if need to move left or right before continuing
	if (fLeftRightOffset == 0.0)
		return;

	// The goal here is move left or right from the point just figured out.
	// To do this figure out a perpendicular vector from the forward direction and move along it -/+ direction to move left/right.
	float vPerpendicularDirection[3], vRandomVector[3];
	vRandomVector[0] = 32.1;
	vRandomVector[1] = 32.1;
	vRandomVector[2] = 32.1;
	// Cross product will give a perpendicular vector when original vector is combined with an arbitrary vector
	// Just chose a 32.1 at random.
	GetVectorCrossProduct(vDirection, vRandomVector, vPerpendicularDirection);

	// PrintToChatAll("vPerpendicularDirection: %f, %f, %f", vPerpendicularDirection[0], vPerpendicularDirection[1], vPerpendicularDirection[1]);
	xyzLocation[0] += (vPerpendicularDirection[0] * fLeftRightOffset);		// Offset x and y a bit left or right of the current 3d point
	xyzLocation[1] += (vPerpendicularDirection[1] * fLeftRightOffset);
}


// void GetLocationVectorInfrontOfClientEyes(iClient, float xyzLocation[3], float xyzAngles[3], float fForwardOffset = 40.0, float fVerticalOffset = 1.0, float perpOffset = 0.0)
// {
// 	float vDirection[3];

// 	GetClientEyeAngles(iClient, xyzAngles);	// Get clients Eye Angles to know get what direction face
// 	GetAngleVectors(xyzAngles, vDirection, NULL_VECTOR, NULL_VECTOR);	// Get the direction the iClient is looking
// 	xyzAngles[0] = 0.0;	//Lock x and z axis, in other words, only do rotation as if a person is standing up and turning
// 	xyzAngles[2] = 0.0;

// 	GetClientEyePosition(iClient, xyzLocation);				// Get Clients location origin vectors
// 	xyzLocation[0] += (vDirection[0] * fForwardOffset);		// Offset x and y a bit forward of the players view
// 	xyzLocation[1] += (vDirection[1] * fForwardOffset);
// 	xyzLocation[2] += (vDirection[2] + fVerticalOffset);	// Raise it up slightly to prevent glitches

// 	float vPerpendicularDirection[3], vRandomVector[3];
// 	vRandomVector[0] = 32.3;
// 	vRandomVector[1] = 32.3;
// 	vRandomVector[2] = 32.3;
// 	GetVectorCrossProduct(vDirection, vRandomVector, vPerpendicularDirection);

// 	PrintToChatAll("EYES vPerpendicularDirection: %f, %f, %f", vPerpendicularDirection[0], vPerpendicularDirection[1], vPerpendicularDirection[1]);

// 	if (perpOffset != 0.0) xyzLocation[0] += (vPerpendicularDirection[0] * perpOffset);		// Offset x and y a bit forward of the players view
// 	if (perpOffset != 0.0) xyzLocation[1] += (vPerpendicularDirection[1] * perpOffset);
// }

 
/**************************************************************************************************************************/

// bool DidClientMoveEyesOrPosition(iClient)
// {
// 	if (!RunClientChecks(iClient))
// 		return true;

// 	decl Float:currentvorigin[3], Float:currentvangles[3];
// 	GetClientEyePosition(iClient, currentvorigin);	//Get clients location origin vectors
// 	GetClientEyeAngles(iClient, currentvangles);	//Get clients Eye Angles
// 	PrintToServer("currentvorigin %f, %f, %f", currentvorigin[0], currentvorigin[1], currentvorigin[2]);
// 	PrintToServer("currentvangles %f, %f, %f", currentvangles[0], currentvangles[1], currentvangles[2]);

// 	// Set a minimum threshold that must be passed in order to trigger a move
// 	new Float:vOriginMovementThreshold = 30.0;
// 	new Float:vAnglesmovementThreshold = 20.0;

// 	if (FloatAbs(currentvorigin[0] - g_xyzClientVOrigin[iClient][0]) > vOriginMovementThreshold ||
// 		FloatAbs(currentvorigin[1] - g_xyzClientVOrigin[iClient][1]) > vOriginMovementThreshold ||
// 		FloatAbs(currentvorigin[2] - g_xyzClientVOrigin[iClient][2]) > vOriginMovementThreshold) //||
// 		//FloatAbs(currentvangles[0] - g_xyzClientVAngles[iClient][0]) > vAnglesmovementThreshold ||
// 		//FloatAbs(currentvangles[1] - g_xyzClientVAngles[iClient][1]) > vAnglesmovementThreshold)
// 		return true;

// 	return false;
// }



// Setting a really high positive value will cause the ability to never cooldown. Abilties can be used to deactivate with this.
// Setting a negative value will subtract time (seconds) away from the cooldown.  Setting a value to the existing game time 
// will cause an instant cooldown allowing for the abilty to be used instantly (bCalculateFromCurrentGameTime true & fTimeToWait 0)
// Note: The game is going to do a comparison of fNextActivationGameTime and the game time to see if
// this ability is in cooldown. So if fNextActivationGameTime was previously set to a high value, use 
// bCalculateFromCurrentGameTime to switch the mode the activate + or - from the current game time instead.
SetSIAbilityCooldown(iClient, Float:fTimeToWait = 0.0, bool bCalculateFromCurrentGameTime = true)
{
	if (RunClientChecks(iClient)== false || 
		IsPlayerAlive(iClient) == false || 
		g_iClientTeam[iClient] != TEAM_INFECTED)
		return;

	new iEntID = GetEntDataEnt2(iClient, g_iOffset_CustomAbility);
	if (!IsValidEntity(iEntID))
		return;

	// Get the actual cooldown wait period, this is the next activation game time at which the ability will be activated once reached
	new Float:fNextActivationGameTime = GetEntDataFloat(iEntID, g_iOffset_NextActivation + 8);
	new Float:fGameTime = GetGameTime();
	//PrintToChatAll("PRE fNextActivationGameTime: %f, GetGameTime() %f", fNextActivationGameTime, fGameTime);

	// Calculate the new ability activation game time
	decl Float:fNewNextActivationGameTime;
	// If bCalculateFromCurrentGameTime, then the coder wants to calc next activation starting with the current game time
	if (bCalculateFromCurrentGameTime)
		fNewNextActivationGameTime = fGameTime + fTimeToWait;
	// If its false, then set it to new activation starting with the existing next activation + or - time to wait
	else
		fNewNextActivationGameTime = fNextActivationGameTime + fTimeToWait;
	
	SetEntDataFloat(iEntID, g_iOffset_NextActivation + 8, fNewNextActivationGameTime, true);

	//PrintToChatAll("POST fNextActivationGameTime: %f, GetGameTime()%f", fNewNextActivationGameTime, GetGameTime());
}

RandomSortIntArray(int[] iArray, int iArraySize, int iPasses)
{
	int slot1, slot2;
	for(int i=0; i<iPasses; i++)
	{
		slot1 = GetRandomInt(0, iArraySize - 1);
		slot2 = GetRandomInt(0, iArraySize - 1);
		if (slot1 == slot2)
			continue;
		
		int tmp = iArray[slot1];
		iArray[slot1] = iArray[slot2];
		iArray[slot2] = tmp;
	}
}