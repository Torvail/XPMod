//SQL Database File Functions

#include "XPMod/Models/Database/DB_Users.sp"

bool:ConnectDB()
{	
	new Handle:hKeyValues = CreateKeyValues("sql");
	KvSetString(hKeyValues, "driver", "mysql");
	KvSetString(hKeyValues, "host", DB_HOST);
	KvSetString(hKeyValues, "database", DB_DATABASE);
	KvSetString(hKeyValues, "user", DB_USER);
	KvSetString(hKeyValues, "pass", DB_PASSWORD);

	decl String:error[255];
	g_hDatabase = SQL_ConnectCustom(hKeyValues, error, sizeof(error), true);
	CloseHandle(hKeyValues);

	if (g_hDatabase == INVALID_HANDLE)
	{
		LogError("MySQL Connection For XPMod User Database Failed: %s", error);
		return false;
	}
	
	return true;
}

//Callback function for an SQL SaveUserData
public SQLGetUserDataCallback(Handle:owner, Handle:hQuery, const String:error[], any:hDataPack)
{
	if (hDataPack == INVALID_HANDLE)
	{
		LogError("SQLGetUserDataCallback: INVALID HANDLE on hDataPack");
		return;
	}
	ResetPack(hDataPack);
	new iClient = ReadPackCell(hDataPack);
	bool bOnlyWebsiteChangableData = ReadPackCell(hDataPack);
	CloseHandle(hDataPack);

	// PrintToChatAll("GetUserData Callback Started. %i: %N", iClient, iClient);
	// PrintToServer("GetUserData Callback Started. %i: %N", iClient, iClient);

	if (g_hDatabase == INVALID_HANDLE)
	{
		PrintToChatAll("Unable to connect to XPMod SQL Database.");
		return;
	}

	if (IsValidEntity(iClient) == false || IsFakeClient(iClient))
	{
		LogError("SQLGetUserDataCallback: INVALID ENTITY OR IS FAKE CLIENT");
		return;
	}
	
	if(!StrEqual("", error))
	{
		LogError("SQL Error: %s", error);
		return;
	}
	
	decl String:strData[20];
	int iInfectedID[3], iEquipmentSlot[6], iOption[2];
	int iFieldIndex = 0, iSkillPointsUsed = 0;
	
	if (bOnlyWebsiteChangableData == false)
	{
		ResetSkillPoints(iClient, iClient);
	}

	// Set the start index offset to caluclate the correct field index value
	int startFieldIndexOffset = DB_COL_INDEX_USERS_XP;
	
	if(SQL_FetchRow(hQuery))
	{
		if (bOnlyWebsiteChangableData == false)
		{
			//Get Client XP from the SQL database
			iFieldIndex = DB_COL_INDEX_USERS_XP - startFieldIndexOffset;
			if(SQL_FetchString(hQuery, iFieldIndex, strData, sizeof(strData)) != 0)
				g_iClientXP[iClient] += StringToInt(strData);
			else
				LogError("SQL Error getting XP string from query");
		
			//Get survivor character id from the SQL database
			iFieldIndex = DB_COL_INDEX_USERS_SURVIVOR_ID - startFieldIndexOffset;
			if(SQL_FetchString(hQuery, iFieldIndex, strData, sizeof(strData)) != 0)
				g_iChosenSurvivor[iClient] = StringToInt(strData);
			else
				LogError("SQL Error getting SurvivorID string from query");
		}
		
		//Get Infecteed Talent ID from the SQL database
		iFieldIndex = DB_COL_INDEX_USERS_INFECTED_ID_1 - startFieldIndexOffset;
		for(new i = 0; i < 3; i++)
		{
			if(SQL_FetchString(hQuery, iFieldIndex++, strData, sizeof(strData)) != 0)
			{
				iInfectedID[i] = StringToInt(strData);
			}
			else
				LogError("SQL Error getting iInfectedID[%d] string from query", i);
		}
		
		if (bOnlyWebsiteChangableData == false)
		{
			iFieldIndex = DB_COL_INDEX_USERS_EQUIPMENT_PRIMARY - startFieldIndexOffset;
			//Get Equipment slot IDs from the SQL database
			for(new i = 0; i < 6; i++)
			{
				if(SQL_FetchString(hQuery, iFieldIndex++, strData, sizeof(strData)) != 0)
					iEquipmentSlot[i] = StringToInt(strData);
				else
					LogError("SQL Error getting iEquipmentSlot[%d] string from query", i);
			}
			
			iFieldIndex = DB_COL_INDEX_USERS_OPTION_ANNOUNCER - startFieldIndexOffset;
			//Get the user's Options from the SQL database
			for(new i = 0; i < 2; i++)
			{
				if(SQL_FetchString(hQuery, iFieldIndex++, strData, sizeof(strData)) != 0)
					iOption[i] = StringToInt(strData);
				else
					LogError("SQL Error getting iOption[%d] string from query", i);
			}
		}
		
		//Set Infected Classes
		g_iClientInfectedClass1[iClient] = iInfectedID[0];
		g_iClientInfectedClass2[iClient] = iInfectedID[1];
		g_iClientInfectedClass3[iClient] = iInfectedID[2];

		//Set the infected class strings
		SetInfectedClassSlot(iClient, 1, g_iClientInfectedClass1[iClient]);
		SetInfectedClassSlot(iClient, 2, g_iClientInfectedClass2[iClient]);
		SetInfectedClassSlot(iClient, 3, g_iClientInfectedClass3[iClient]);

		if (bOnlyWebsiteChangableData == false)
		{
			//Calculate level and next level g_iClientXP
			calclvlandnextxp(iClient);
			
			//Calculate g_iSkillPoints
			g_iSkillPoints[iClient] = g_iClientLevel[iClient] - iSkillPointsUsed;
			g_iInfectedLevel[iClient] = RoundToFloor(g_iClientLevel[iClient] * 0.5);
			//iskillpoints[iClient] = g_iInfectedLevel[iClient] * 3;

			//Set Survivor Class Levels
			switch(g_iChosenSurvivor[iClient])
			{
				case BILL:
				{
					LevelUpAllBill(iClient);
				}
				case ROCHELLE:
				{
					LevelUpAllRochelle(iClient);
				}
				case COACH:
				{
					LevelUpAllCoach(iClient);
				}
				case ELLIS:
				{
					LevelUpAllEllis(iClient);
				}
				case NICK:
				{
					LevelUpAllNick(iClient);
				}
			}

			//Set the user's survivor equipment
			g_iClientPrimarySlotID[iClient] = iEquipmentSlot[0];
			g_iClientSecondarySlotID[iClient] = iEquipmentSlot[1];
			g_iClientExplosiveSlotID[iClient] = iEquipmentSlot[2];
			g_iClientHealthSlotID[iClient] = iEquipmentSlot[3];
			g_iClientBoostSlotID[iClient] = iEquipmentSlot[4];
			g_iClientLaserSlotID[iClient] = iEquipmentSlot[5];
		
			//Get loadout weapon names and g_iClientXP costs
			GetWeaponNames(iClient);
		
			new i = 0;
			//Set the user's XPMod Options
			if(iOption[i++] == 1)
			{
				//Turn the Announcer on
				g_bAnnouncerOn[iClient] = true;
			
				//Play the Announcer Sound
				decl Float:vec[3];
				GetClientEyePosition(iClient, vec);
				EmitAmbientSound(SOUND_GETITON, vec, iClient, SNDLEVEL_NORMAL);
				
				//Tell the user that the Announcer is on
				PrintHintText(iClient, "Announcer is now ON.");
			}
			else
				g_bAnnouncerOn[iClient] = false;
			
			// //VGUI Particle Descriptions Option
			// if(iOption[i++] == 1)
			// 	g_bEnabledVGUI[iClient] = false;
			// else
			// 	g_bEnabledVGUI[iClient] = false;
			
			//XP Display Option
			switch(iOption[i++])
			{
				case 0:		g_iXPDisplayMode[iClient] = 0;
				case 1:		g_iXPDisplayMode[iClient] = 1;
				case 2:		g_iXPDisplayMode[iClient] = 2;
			}
			
			//Set the user to be logged in
			g_bClientLoggedIn[iClient] = true;
			
			PrintToChatAll("\x05<-=- \x03%N (Level %d) has joined\x05 -=->", iClient, g_iClientLevel[iClient]);
			PrintToServer(":-=-=-=-=-<[%N (Level %d) logged in]>-=-=-=-=-:", iClient, g_iClientLevel[iClient]);
			PrintHintText(iClient, "Welcome back %N", iClient);
		}
	}
	else if (bOnlyWebsiteChangableData == false)
	{
		PrintToChatAll("\x03[XPMod] %N has no account.", iClient);
		PrintToServer("[XPMod] %N has no account.", iClient);
	}

	// PrintToChatAll("GetUserData Callback Complete.  %i: %N", iClient, iClient);
	// PrintToServer("GetUserData Callback Complete.  %i: %N", iClient, iClient);
}

GetUserData(any:iClient, bool:bOnlyWebsiteChangableData = false)
{
	// PrintToChatAll("GetUserData. %i: %N", iClient, iClient);
	// PrintToServer("GetUserData. %i: %N", iClient, iClient);
	if(iClient == 0)
		iClient = 1;
	
	if (g_hDatabase == INVALID_HANDLE)
	{
		PrintToChatAll("Unable to connect to XPMod SQL Database.");
		return;
	}
	
	if (!IsClientInGame(iClient) || IsFakeClient(iClient) || (g_bClientLoggedIn[iClient] && bOnlyWebsiteChangableData == false))
		return;
	
	//Get SteamID
	decl String:strSteamID[32];
	GetClientAuthId(iClient, AuthId_SteamID64, strSteamID, sizeof(strSteamID));
	
	// Save the new user data into the SQL database with the matching Steam ID
	decl String:strQuery[1024] = "";
	decl String:strAttributes[1024] = "";
	// Build the attribute strings for the query
	GetAttributesStringForQuery(strAttributes, sizeof(strAttributes), DB_COL_INDEX_USERS_XP, DB_COL_INDEX_USERS_OPTION_DISPLAY_XP);
	// Combine it all into the query
	Format(strQuery, sizeof(strQuery), "SELECT %s FROM %s WHERE steam_id = %s", strAttributes, DB_TABLENAME, strSteamID);
	
	// Create a data pack to pass multiple parameters to the callback
	new Handle:hDataPackage = CreateDataPack();
	WritePackCell(hDataPackage, iClient);
	WritePackCell(hDataPackage, bOnlyWebsiteChangableData);

	SQL_TQuery(g_hDatabase, SQLGetUserDataCallback, strQuery, hDataPackage);
}

//Callback function for an SQL CreateNewUser
public SQLCreateNewUserCallback(Handle:owner, Handle:hQuery, const String:error[], any:iClient)
{
	if (g_hDatabase == INVALID_HANDLE)
	{
		PrintToChatAll("Unable to connect to XPMod SQL Database.");
		return;
	}
	
	if (!IsClientInGame(iClient) || IsFakeClient(iClient))
		return;
	
	if(!StrEqual("", error))
		LogError("SQL Error: %s", error);
	else
		g_bClientLoggedIn[iClient] = true;
	
	//PrintToChatAll("New User Creation Callback Complete.  %i: %N", iClient, iClient);
	//PrintToServer("New User Creation Callback Complete.  %i: %N", iClient, iClient);
}

CreateNewUser(iClient)
{
	//PrintToChatAll("New User Creation.  %i: %N", iClient, iClient);
	//PrintToServer("New User Creation.  %i: %N", iClient, iClient);
	if(iClient == 0)
		iClient = 1;
	
	//g_bClientLoggedIn[iClient] = true;
	
	if (g_hDatabase == INVALID_HANDLE)
	{
		PrintToChatAll("Unable to connect to XPMod SQL Database.");
		return;
	}
		
	if(!IsClientInGame(iClient) || IsFakeClient(iClient) || g_bClientLoggedIn[iClient])
		return;
	
	//Get SteamID
	decl String:strSteamID[32];
	GetClientAuthId(iClient, AuthId_SteamID64, strSteamID, sizeof(strSteamID));
	
	//Get Client Name
	decl String:strClientName[32];
	GetClientName(iClient, strClientName, sizeof(strClientName));
	
	//PrintToChatAll(strClientName);
	
	//Give bonus XP
	g_iClientXP[iClient] += 10000;
	
	//Get Client XP
	decl String:strClientXP[10];
	if(g_iClientXP[iClient]>99999999)
		IntToString(99999999, strClientXP, sizeof(strClientXP));
	else
		IntToString(g_iClientXP[iClient], strClientXP, sizeof(strClientXP));
	
	//Create new entry into the SQL database with the users information
	decl String:strQuery[256];
	Format(strQuery, sizeof(strQuery), "INSERT INTO %s (steam_id, user_name, xp) VALUES ('%s', '%s', %s)", DB_TABLENAME, strSteamID, strClientName, strClientXP);
	SQL_TQuery(g_hDatabase, SQLCreateNewUserCallback, strQuery, iClient);
}

//Callback function for an SQL SaveUserData
public SQLSaveUserDataCallback(Handle:owner, Handle:hQuery, const String:error[], any:iClient)
{
	if (g_hDatabase == INVALID_HANDLE)
	{
		PrintToChatAll("Unable to connect to XPMod SQL Database.");
		return;
	}
	
	if(!StrEqual("", error))
		LogError("SQL Error: %s", error);

	// PrintToChatAll("Save User Data Callback Complete. %i: %N", iClient, iClient);
	// PrintToServer("Save User Data Callback Complete. %i: %N", iClient, iClient);
}

SaveUserData(iClient)
{
	// PrintToChatAll("Save User Data. %i: %N", iClient, iClient);
	// PrintToServer("Save User Data. %i: %N", iClient, iClient);
	if(iClient == 0)
		iClient = 1;
	
	if (g_hDatabase == INVALID_HANDLE)
	{
		PrintToChatAll("Unable to connect to XPMod SQL Database.");
		return;
	}	
	
	if (!g_bClientLoggedIn[iClient] || g_iClientXP[iClient]<0)
		return;
		
	decl String:strSteamID[32], String:strClientName[32], String:strClientXP[10], String:strSurvivorID[3], 
		String:strSurvivorTalent[6][2], String:strInfectedID[3][2], String:strEquipmentSlotID[6][3], String:strOption[3][2];
	
	//Get SteamID
	GetClientAuthId(iClient, AuthId_SteamID64, strSteamID, sizeof(strSteamID));
	
	//Get Client Name
	GetClientName(iClient, strClientName, sizeof(strClientName));
	
	//Get Client XP
	if(g_iClientXP[iClient]>99999999)
		IntToString(99999999, strClientXP, sizeof(strClientXP));
	else
		IntToString(g_iClientXP[iClient], strClientXP, sizeof(strClientXP));
		
	//Get SurvivorID
	IntToString(g_iChosenSurvivor[iClient], strSurvivorID, sizeof(strSurvivorID))
	
	// //Get Survivor Talent IDs
	// switch(g_iChosenSurvivor[iClient])
	// {
	// 	case BILL:
	// 	{
	// 		IntToString(g_iInspirationalLevel[iClient], strSurvivorTalent[0], 2);
	// 		IntToString(g_iGhillieLevel[iClient], strSurvivorTalent[1], 2);
	// 		IntToString(g_iWillLevel[iClient], strSurvivorTalent[2], 2);
	// 		IntToString(g_iExorcismLevel[iClient], strSurvivorTalent[3], 2);
	// 		IntToString(g_iDiehardLevel[iClient], strSurvivorTalent[4], 2);
	// 		IntToString(g_iPromotionalLevel[iClient], strSurvivorTalent[5], 2);
	// 	}
	// 	case ROCHELLE:
	// 	{
	// 		IntToString(g_iGatherLevel[iClient], strSurvivorTalent[0], 2);
	// 		IntToString(g_iHunterLevel[iClient], strSurvivorTalent[1], 2);
	// 		IntToString(g_iSniperLevel[iClient], strSurvivorTalent[2], 2);
	// 		IntToString(g_iSilentLevel[iClient], strSurvivorTalent[3], 2);
	// 		IntToString(g_iSmokeLevel[iClient], strSurvivorTalent[4], 2);
	// 		IntToString(g_iShadowLevel[iClient], strSurvivorTalent[5], 2);
	// 	}
	// 	case COACH:
	// 	{
	// 		IntToString(g_iBullLevel[iClient], strSurvivorTalent[0], 2);
	// 		IntToString(g_iWreckingLevel[iClient], strSurvivorTalent[1], 2);
	// 		IntToString(g_iSprayLevel[iClient], strSurvivorTalent[2], 2);
	// 		IntToString(g_iHomerunLevel[iClient], strSurvivorTalent[3], 2);
	// 		IntToString(g_iLeadLevel[iClient], strSurvivorTalent[4], 2);
	// 		IntToString(g_iStrongLevel[iClient], strSurvivorTalent[5], 2);
	// 	}
	// 	case ELLIS:
	// 	{
	// 		IntToString(g_iOverLevel[iClient], strSurvivorTalent[0], 2);
	// 		IntToString(g_iBringLevel[iClient], strSurvivorTalent[1], 2);
	// 		IntToString(g_iJamminLevel[iClient], strSurvivorTalent[2], 2);
	// 		IntToString(g_iWeaponsLevel[iClient], strSurvivorTalent[3], 2);
	// 		IntToString(g_iMetalLevel[iClient], strSurvivorTalent[4], 2);
	// 		IntToString(g_iFireLevel[iClient], strSurvivorTalent[5], 2);
	// 	}
	// 	case NICK:
	// 	{
	// 		IntToString(g_iSwindlerLevel[iClient], strSurvivorTalent[0], 2);
	// 		IntToString(g_iLeftoverLevel[iClient], strSurvivorTalent[1], 2);
	// 		IntToString(g_iRiskyLevel[iClient], strSurvivorTalent[2], 2);
	// 		IntToString(g_iEnhancedLevel[iClient], strSurvivorTalent[3], 2);
	// 		IntToString(g_iMagnumLevel[iClient], strSurvivorTalent[4], 2);
	// 		IntToString(g_iDesperateLevel[iClient], strSurvivorTalent[5], 2);
	// 	}
	// }
	
	//Get Infected Class IDs
	IntToString(g_iClientInfectedClass1[iClient], strInfectedID[0], 2);
	IntToString(g_iClientInfectedClass2[iClient], strInfectedID[1], 2);
	IntToString(g_iClientInfectedClass3[iClient], strInfectedID[2], 2);
	
	//Get Equpiment Slot IDs
	IntToString(g_iClientPrimarySlotID[iClient], strEquipmentSlotID[0], 3);
	IntToString(g_iClientSecondarySlotID[iClient], strEquipmentSlotID[1], 3);
	IntToString(g_iClientExplosiveSlotID[iClient], strEquipmentSlotID[2], 3);
	IntToString(g_iClientHealthSlotID[iClient], strEquipmentSlotID[3], 3);
	IntToString(g_iClientBoostSlotID[iClient], strEquipmentSlotID[4], 3);
	IntToString(g_iClientLaserSlotID[iClient], strEquipmentSlotID[5], 3);
	
	new i = 0;
	IntToString(g_bAnnouncerOn[iClient], strOption[i++], 2);
	IntToString(g_bEnabledVGUI[iClient], strOption[i++], 2);
	IntToString(g_iXPDisplayMode[iClient], strOption[i++], 2);
	
	//Save the new user data into the SQL database with the matching Steam ID
	decl String:strQuery[1024];
	Format(strQuery, sizeof(strQuery), "\
		UPDATE %s SET \
		user_name = '%s', \
		xp = %s, \
		survivor_id = %s, \
		infected_id_1 = %s, \
		infected_id_2 = %s, \
		infected_id_3 = %s, \
		equipment_primary = %s, \
		equipment_secondary = %s, \
		equipment_explosive = %s, \
		equipment_health = %s, \
		equipment_boost = %s, \
		equipment_laser = %s, \
		option_announcer  = %s, \
		option_display_xp = %s \
		WHERE steam_id = '%s'", 
		DB_TABLENAME, 
		strClientName, 
		strClientXP, 
		strSurvivorID,
		strInfectedID[0],
		strInfectedID[1],
		strInfectedID[2],
		strEquipmentSlotID[0],
		strEquipmentSlotID[1],
		strEquipmentSlotID[2],
		strEquipmentSlotID[3],
		strEquipmentSlotID[4],
		strEquipmentSlotID[5],
		strOption[0],
		strOption[2],
		strSteamID);
	
	SQL_TQuery(g_hDatabase, SQLSaveUserDataCallback, strQuery, iClient);
}


//Logout                                                                                                        
Logout(iClient)
{
	//PrintToChatAll("Logout. %i: %N", iClient, iClient);
	//PrintToServer("Logout. %i: %N", iClient, iClient);
	if(iClient==0)
	{
		iClient = 1;			//Changed this and the folwogin two lines
		//PrintToServer("Server host cannot login through the console, go into chat and type /login to login in.");
		//return Plugin_Handled;
	}
	if(!IsClientInGame(iClient))
		return;
	g_bTalentsConfirmed[iClient] = false;
	g_bUserStoppedConfirmation[iClient] = false;
	g_bAnnouncerOn[iClient] = false;
	g_bEnabledVGUI[iClient] = false;
	if(g_bClientLoggedIn[iClient] == true)
	{
		ResetAll(iClient, iClient);
		g_bClientLoggedIn[iClient] = false;
		//PrintToChatAll("\x03[XPMod] \x04%N Logged Out", iClient, iClient);
		return;
	}

	//PrintToChatAll("Logout Complete. %i: %N", iClient, iClient);
	//PrintToServer("Logout Complete. %i: %N", iClient, iClient);
	
	return;
}


GetAttributesStringForQuery(char[] strAttributes, int bufferSize, int startIndex, int endIndex)
{
	for (int i=DB_COL_INDEX_USERS_XP; i<=DB_COL_INDEX_USERS_OPTION_DISPLAY_XP; i++)
	{
		StrCat(strAttributes, bufferSize, strUsersTableColumnNames[i]);
		int len = strlen(strAttributes);
		strAttributes[len] = ',';
		strAttributes[len+1] = '\0';
	}
	// Remove the last comma
	strAttributes[strlen(strAttributes)-1] = '\0';
}
