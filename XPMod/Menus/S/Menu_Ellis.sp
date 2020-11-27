//Ellis Menu////////////////////////////////////////////////////////////////

//Ellis Menu Draw
public Action:EllisMenuDraw(iClient) 
{
	decl String:text[512];

	CheckMenu(iClient);
	
	DeleteAllMenuParticles(iClient);
	g_hMenu_XPM[iClient] = CreateMenu(EllisMenuHandler);
	SetMenuPagination(g_hMenu_XPM[iClient], MENU_NO_PAGINATION);
	
	FormatEx(text, sizeof(text), "Level %d   XP: %d/%d   Skill Points: %d\n=	=	=	=	=	=	=	=	=	=	=	=	=	=\n \n			Ellis's Weapons Expert Talents\n ",g_iClientLevel[iClient], g_iClientXP[iClient], g_iClientNextLevelXPAmount[iClient], g_iSkillPoints[iClient]);
	SetMenuTitle(g_hMenu_XPM[iClient], text);
	
	FormatEx(text, sizeof(text), "	[Level %d]	Overconfidence", g_iOverLevel[iClient]);
	AddMenuItem(g_hMenu_XPM[iClient], "option1", text);
	FormatEx(text, sizeof(text), "	[Level %d]	Bring the Pain!", g_iBringLevel[iClient]);
	AddMenuItem(g_hMenu_XPM[iClient], "option2", text);
	FormatEx(text, sizeof(text), "	[Level %d]	Jammin' to the Music", g_iJamminLevel[iClient]);
	AddMenuItem(g_hMenu_XPM[iClient], "option3", text);
	FormatEx(text, sizeof(text), "	[Level %d]	Weapons Training", g_iWeaponsLevel[iClient]);
	AddMenuItem(g_hMenu_XPM[iClient], "option4", text);
	FormatEx(text, sizeof(text), "	[Level %d]	Mechanic Affinity (Bind 1)                ", g_iMetalLevel[iClient]);
	AddMenuItem(g_hMenu_XPM[iClient], "option5", text);
	FormatEx(text, sizeof(text), "	[Level %d]	Fire Storm (Bind 2)\n ", g_iFireLevel[iClient]);
	AddMenuItem(g_hMenu_XPM[iClient], "option6", text);
	
	AddMenuItem(g_hMenu_XPM[iClient], "option7", "Level Up All Talents\n ");
	
	AddMenuItem(g_hMenu_XPM[iClient], "option8", "Detailed Talent Descriptions\n ");
	
	AddMenuItem(g_hMenu_XPM[iClient], "option9", "Back\n \n=	=	=	=	=	=	=	=	=	=	=	=	=	=\n \n \n \n \n \n \n ");
	SetMenuExitButton(g_hMenu_XPM[iClient], false);
	DisplayMenu(g_hMenu_XPM[iClient], iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Level Up All Question for Ellis
public Action:LevelUpAllEllisFunc(iClient) 
{
	CheckMenu(iClient);
	
	g_hMenu_XPM[iClient] = CreateMenu(LevelUpAllEllisHandler);
	
	SetMenuTitle(g_hMenu_XPM[iClient], "Are you sure you want to use all your skillpoints to level up talents for Ellis?\n \n");
	AddMenuItem(g_hMenu_XPM[iClient], "option1", "Yes");
	AddMenuItem(g_hMenu_XPM[iClient], "option2", "No");
	SetMenuExitButton(g_hMenu_XPM[iClient], false);
	DisplayMenu(g_hMenu_XPM[iClient], iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Overconfidence
public Action:OverMenuDraw(iClient) 
{
	decl String:text[512];

	CheckMenu(iClient);
	
	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Over[iClient] = WriteParticle(iClient, "md_ellis_over", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	g_hMenu_XPM[iClient] = CreateMenu(OverMenuHandler);
	
	FormatEx(text, sizeof(text), "Level %d		Skill Points: %d\n=	=	=	=	=	=	=	=	=	=	=	=	=	=	=	=\n \n 					Overconfidence (Level %d):\n \nLevel 1:\n+4 pill & shot health per level\n+8%%%% reload speed per level\n(Stacks) (Team) +1 second adrenaline duration per level\nIf within 20 points of max health:\n+2% speed && +2 damage to all guns per level\n \n \nSkill Uses:\nAdrenaline (Stacks) with itself\nUnlimited stacks\n \n=	=	=	=	=	=	=	=	=	=	=	=	=	=	=	=",g_iClientLevel[iClient], g_iSkillPoints[iClient], g_iOverLevel[iClient]);
	SetMenuTitle(g_hMenu_XPM[iClient], text);

	AddMenuItem(g_hMenu_XPM[iClient], "option1", "Level Up");
	AddMenuItem(g_hMenu_XPM[iClient], "option2", "Level Down");
	AddMenuItem(g_hMenu_XPM[iClient], "option3", "Back\n \n \n \n \n \n \n \n ");

	SetMenuExitButton(g_hMenu_XPM[iClient], false);
	DisplayMenu(g_hMenu_XPM[iClient], iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Bring the Pain!
public Action:BringMenuDraw(iClient) 
{
	decl String:text[512];

	CheckMenu(iClient);
	
	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Bring[iClient] = WriteParticle(iClient, "md_ellis_bring", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	g_hMenu_XPM[iClient] = CreateMenu(BringMenuHandler);
	
	FormatEx(text, sizeof(text), "Level %d		Skill Points: %d\n=	=	=	=	=	=	=	=	=\n \n		Bring the Pain!(Level %d):\n \nOn Special Infected kill:\n \nLevel 1:\nRegen +1 health per level (+8 at max)\n+20 clip ammo per level\n(Stacks) +1%%%% movement speed\n \n \nSkill Uses:\n+6 max (Stacks) per level\n \n=	=	=	=	=	=	=	=	=",g_iClientLevel[iClient], g_iSkillPoints[iClient], g_iBringLevel[iClient]);
	SetMenuTitle(g_hMenu_XPM[iClient], text);
	
	AddMenuItem(g_hMenu_XPM[iClient], "option1", "Level Up");
	AddMenuItem(g_hMenu_XPM[iClient], "option2", "Level Down");
	AddMenuItem(g_hMenu_XPM[iClient], "option3", "Back\n \n \n \n \n \n \n \n ");

	SetMenuExitButton(g_hMenu_XPM[iClient], false);
	DisplayMenu(g_hMenu_XPM[iClient], iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Weapons Training
public Action:WeaponsMenuDraw(iClient) 
{
	decl String:text[512];

	CheckMenu(iClient);
	
	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Weapons[iClient] = WriteParticle(iClient, "md_ellis_weapons", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	g_hMenu_XPM[iClient] = CreateMenu(WeaponsMenuHandler);
		
	FormatEx(text, sizeof(text), "Level %d		Skill Points: %d\n=	=	=	=	=	=	=	=	=	=	=\n \n		Weapons Training (Level %d):\n \nLevel 1:\n+10%%%% reload speed per level\n(Team) +8%%%% laser accuracy per level\n \nLevel 5:\nAutomatic laser sight\nEllis can carry 2 primary weapons\n[WALK+ZOOM] to cycle weapons\n \n=	=	=	=	=	=	=	=	=	=	=",g_iClientLevel[iClient], g_iSkillPoints[iClient], g_iWeaponsLevel[iClient]);
	SetMenuTitle(g_hMenu_XPM[iClient], text);
	
	AddMenuItem(g_hMenu_XPM[iClient], "option1", "Level Up");
	AddMenuItem(g_hMenu_XPM[iClient], "option2", "Level Down");
	AddMenuItem(g_hMenu_XPM[iClient], "option3", "Back\n \n \n \n \n \n \n \n ");

	SetMenuExitButton(g_hMenu_XPM[iClient], false);
	DisplayMenu(g_hMenu_XPM[iClient], iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Jammin' to the Music
public Action:JamminMenuDraw(iClient) 
{
	decl String:text[512];

	CheckMenu(iClient);
	
	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Jammin[iClient] = WriteParticle(iClient, "md_ellis_jammin", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	g_hMenu_XPM[iClient] = CreateMenu(JamminMenuHandler);
	
	FormatEx(text, sizeof(text), "Level %d		Skill Points: %d\n=	=	=	=	=	=	=	=	=	=	=	=	=\n \n		Jammin' to the Music (Level %d):\n \nOn Tank spawn:\n \nLevel 1:\n+4%%%% movement speed per level\n+5 temp health per level\n \nLevel 5:\nGain a molotov when you have no grenade\n \n=	=	=	=	=	=	=	=	=	=	=	=	=",g_iClientLevel[iClient], g_iSkillPoints[iClient], g_iJamminLevel[iClient]);
	SetMenuTitle(g_hMenu_XPM[iClient], text);
	
	AddMenuItem(g_hMenu_XPM[iClient], "option1", "Level Up");
	AddMenuItem(g_hMenu_XPM[iClient], "option2", "Level Down");
	AddMenuItem(g_hMenu_XPM[iClient], "option3", "Back\n \n \n \n \n \n \n \n ");

	SetMenuExitButton(g_hMenu_XPM[iClient], false);
	DisplayMenu(g_hMenu_XPM[iClient], iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Metal Storm (Mechanic Affinity)
public Action:MetalMenuDraw(iClient) 
{
	decl String:text[512];

	CheckMenu(iClient);
	
	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Bring[iClient] = WriteParticle(iClient, "md_ellis_mechanic", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	g_hMenu_XPM[iClient] = CreateMenu(MetalMenuHandler);
	
	FormatEx(text, sizeof(text), "Level %d		Skill Points: %d\n=	=	=	=	=	=	=	=	=	=	=	=	=\n \n				Mechanic Affinity (Level %d):\n					Requires Level 11\n \nLevel 1:\n+4 clip size per level (SMG/Rifle/Sniper only)\n+8%%%% firing rate per level\n+8%%%% reload speed per level\n \nLevel 5:\n[WALK+USE] quadruple firing rate for 10 seconds\nDestroys weapon after\n \n \n					Bind 1: Ammo Refill\n				+1 use every other level\n \nLevel 1:\nDeploy an ammo stash\n \n=	=	=	=	=	=	=	=	=	=	=	=	=",g_iClientLevel[iClient], g_iSkillPoints[iClient], g_iMetalLevel[iClient]);
	SetMenuTitle(g_hMenu_XPM[iClient], text);
	
	AddMenuItem(g_hMenu_XPM[iClient], "option1", "Level Up");
	AddMenuItem(g_hMenu_XPM[iClient], "option2", "Level Down");
	AddMenuItem(g_hMenu_XPM[iClient], "option3", "Back\n \n \n \n \n \n \n \n ");
	
	SetMenuExitButton(g_hMenu_XPM[iClient], false);
	DisplayMenu(g_hMenu_XPM[iClient], iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Fire Storm
public Action:FireMenuDraw(iClient) 
{
	decl String:text[512];

	CheckMenu(iClient);
	
	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Fire[iClient] = WriteParticle(iClient, "md_ellis_fire", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	g_hMenu_XPM[iClient] = CreateMenu(FireMenuHandler);
	
	FormatEx(text, sizeof(text), "Level %d		Skill Points: %d\n=	=	=	=	=	=	=	=	=	=	=	=	=	=	=\n \n						Fire Storm(Level %d):\n						Requires Level 26\n \nLevel 1:\n+6 clip size per level (SMG/Rifle/Sniper only)\n+10%%%% reload speed per level\n+12%%%% firing rate per level (Requires Mechanic Affinity)\nFire immunity\n \n \n			Bind 2: Summon Kagu-Tsuchi's Wrath\n						+1 use every other level\n \nLevel 1: +6 seconds of incendiary attacks\nand burn duration per level\nBurning a calm Witch\nimmediately neutralizes her\n \n=	=	=	=	=	=	=	=	=	=	=	=	=	=	=",g_iClientLevel[iClient], g_iSkillPoints[iClient], g_iFireLevel[iClient]);
	SetMenuTitle(g_hMenu_XPM[iClient], text);
	
	AddMenuItem(g_hMenu_XPM[iClient], "option1", "Level Up");
	AddMenuItem(g_hMenu_XPM[iClient], "option2", "Level Down");
	AddMenuItem(g_hMenu_XPM[iClient], "option3", "Back\n \n \n \n \n \n \n \n ");
	
	SetMenuExitButton(g_hMenu_XPM[iClient], false);
	DisplayMenu(g_hMenu_XPM[iClient], iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Handlers//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Level Up All for Ellis
public LevelUpAllEllisHandler(Handle:hmenu, MenuAction:action, iClient, itemNum)
{
	if(action==MenuAction_Select) 
	{
		switch (itemNum)
		{
			case 0: //Yes
			{
				LevelUpAllEllis(iClient);
				EllisMenuDraw(iClient);
			}
			case 1: //No
			{
				EllisMenuDraw(iClient);
			}
		}
	}
}


LevelUpAllEllis(iClient)
{
	if(g_iChosenSurvivor[iClient] != 3)
		g_iChosenSurvivor[iClient] = 3;
	ResetSkillPoints(iClient,iClient);
	if(g_iSkillPoints[iClient]>0)
	{
		if(g_iSkillPoints[iClient] > 4)
		{
			g_iSkillPoints[iClient] -= 5;
			g_iOverLevel[iClient] += 5;
		}
		else
		{
			g_iOverLevel[iClient] += g_iSkillPoints[iClient];
			g_iSkillPoints[iClient] = 0;
		}
		if(g_iSkillPoints[iClient] > 4)
		{
			g_iSkillPoints[iClient] -= 5;
			g_iBringLevel[iClient] += 5;
		}
		else
		{
			g_iBringLevel[iClient] += g_iSkillPoints[iClient];
			g_iSkillPoints[iClient] = 0;
		}
		if(g_iSkillPoints[iClient] > 4)
		{
			g_iSkillPoints[iClient] -= 5;
			g_iJamminLevel[iClient] += 5;
		}
		else
		{
			g_iJamminLevel[iClient] += g_iSkillPoints[iClient];
			g_iSkillPoints[iClient] = 0;
		}
		if(g_iSkillPoints[iClient] > 4)
		{
			g_iSkillPoints[iClient] -= 5;
			g_iWeaponsLevel[iClient] += 5;
		}
		else
		{
			g_iWeaponsLevel[iClient] += g_iSkillPoints[iClient];
			g_iSkillPoints[iClient] = 0;
		}
		if(g_iSkillPoints[iClient] > 4)
		{
			g_iSkillPoints[iClient] -= 5;
			g_iMetalLevel[iClient] += 5;
		}
		else
		{
			g_iMetalLevel[iClient] += g_iSkillPoints[iClient];
			g_iSkillPoints[iClient] = 0;
		}
		if(g_iSkillPoints[iClient] > 4)
		{
			g_iSkillPoints[iClient] -= 5;
			g_iFireLevel[iClient] += 5;
		}
		else
		{
			g_iFireLevel[iClient] += g_iSkillPoints[iClient];
			g_iSkillPoints[iClient] = 0;
		}
		PrintToChat(iClient, "\x03[XPMod] \x01All your skillpoints have been assigned to Ellis.");
	}
	else
		PrintToChat(iClient, "\x03[XPMod] \x01You dont have any skillpoints.");
}

//Ellis Menu Handler
public EllisMenuHandler(Handle:hmenu, MenuAction:action, iClient, itemNum)
{
	if(action==MenuAction_Select) 
	{
		switch (itemNum)
		{
			case 0: //Overconfidence
			{
				OverMenuDraw(iClient);
			}
			case 1: //Bring the Pain!
			{
				BringMenuDraw(iClient);
			}
			case 2: //Jammin to the Music
			{
				JamminMenuDraw(iClient);
			}
			case 3: //Weapons Training
			{
				WeaponsMenuDraw(iClient);
			}
			case 4: //Mechanic Affinity
			{
				MetalMenuDraw(iClient); //uses metal for mechanic affinity
			}
			case 5: //Fire Storm
			{
				FireMenuDraw(iClient);
			}
			case 6: //Level Up All
			{
				if(g_bTalentsConfirmed[iClient] == false || g_iChosenSurvivor[iClient] == ELLIS)
					LevelUpAllEllisFunc(iClient);
				else
				{
					EllisMenuDraw(iClient);
					PrintToChat(iClient, "\x03[XPMod] \x05You cannot change your character after confirming it for the round."); 
				}
			}
			case 7: //Detailed Talent Descriptions
			{
				OpenMOTDPanel(iClient, "", "http://xpmod.net/talents/survivors/ceda%20files/ellis/xpmod_ig_talents_survivors_ellis.html", MOTDPANEL_TYPE_URL);
				EllisMenuDraw(iClient);
			}
			case 8: //Back
			{
				ClassMenuDraw(iClient);
			}
		}
	}
}

//Overconfidence Handler
public OverMenuHandler(Handle:hmenu, MenuAction:action, iClient, itemNum)
{
	if( action == MenuAction_Select )
	{
		switch (itemNum)
		{
			case 0: //Level up
			{
				if(g_bTalentsConfirmed[iClient] == false || g_iChosenSurvivor[iClient] == ELLIS)
				{
					if(g_iChosenSurvivor[iClient] == ELLIS)
					{
						if(g_iSkillPoints[iClient]>0)
						{
							if(g_iOverLevel[iClient] <=4 )
							{
								g_iSkillPoints[iClient]--;
								g_iOverLevel[iClient]++;
							}
							else
								PrintToChat(iClient, "\x03[XPMod] This talent is already maxed out.");
						}
						else
							PrintToChat(iClient, "\x03[XPMod] No skill points remaining.");
						OverMenuDraw(iClient);
					}
					else
					{
						ChangeChar(iClient, 3);
						PrintToChat(iClient, "\x03[XPMod] You dont have Ellis selected.");
					}
				}
				else
				{
					OverMenuDraw(iClient);
					PrintToChat(iClient, "\x03[XPMod] \x05You cannot change your character after confirming it for the round."); 
				}
			}
			case 1: //Drop Level
            {
				if(g_iChosenSurvivor[iClient] == ELLIS)
				{
					if(g_iOverLevel[iClient]>0)
					{
						if(g_bTalentsConfirmed[iClient] == false)
						{
							g_iSkillPoints[iClient]++;
							g_iOverLevel[iClient]--;
						}
						else
							PrintToChat(iClient, "\x03[XPMod] \x05You cannot drop any levels after confirming your talents for the round."); 
					}
					else
						PrintToChat(iClient, "\x03[XPMod] This talent level is already at zero.");
				}
				else
					PrintToChat(iClient, "\x03[XPMod] You don't have Ellis selected.");
					
				OverMenuDraw(iClient);
            }
			case 2: //Back
            {
				EllisMenuDraw(iClient);
            }
        }
    }
}

//Bring the Pain Handler
public BringMenuHandler(Handle:hmenu, MenuAction:action, iClient, itemNum)
{
	if( action == MenuAction_Select )
	{
		switch (itemNum)
		{
			case 0: //Level up
			{
				if(g_bTalentsConfirmed[iClient] == false || g_iChosenSurvivor[iClient] == ELLIS)
				{
					if(g_iChosenSurvivor[iClient]==3)
					{
						if(g_iSkillPoints[iClient]>0)
						{
							if(g_iBringLevel[iClient] <=4 )
							{
								g_iSkillPoints[iClient]--;
								g_iBringLevel[iClient]++;
							}
							else
								PrintToChat(iClient, "\x03[XPMod] This talent is already maxed out.");
						}
						else
							PrintToChat(iClient, "\x03[XPMod] No skill points remaining.");
						BringMenuDraw(iClient);
					}
					else
					{
						ChangeChar(iClient, 3);
						PrintToChat(iClient, "\x03[XPMod] You dont have Ellis selected.");
					}
				}
				else
				{
					BringMenuDraw(iClient);
					PrintToChat(iClient, "\x03[XPMod] \x05You cannot change your character after confirming it for the round."); 
				}
			}
			case 1: //Drop Level
            {
				if(g_iChosenSurvivor[iClient]==3)
				{
					if(g_iBringLevel[iClient]>0) 			//cant drop level if not beginning of the round for all////////////////////////////////////////////////////
					{
						if(g_bTalentsConfirmed[iClient] == false)
						{
							g_iSkillPoints[iClient]++;
							g_iBringLevel[iClient]--;
						}
						else
							PrintToChat(iClient, "\x03[XPMod] \x05You cannot drop any levels after confirming your talents for the round."); 
					}
					else
						PrintToChat(iClient, "\x03[XPMod] This talent level is already at zero.");
					}
				else
					PrintToChat(iClient, "\x03[XPMod] You don't have Ellis selected.");
				BringMenuDraw(iClient);
            }
			case 2: //Back
            {
				EllisMenuDraw(iClient);
            }
        }
    }
}


//Weapons Training Handler
public WeaponsMenuHandler(Handle:hmenu, MenuAction:action, iClient, itemNum)
{
	if( action == MenuAction_Select )
	{
		switch (itemNum)
		{
			case 0: //Level up
			{
				if(g_bTalentsConfirmed[iClient] == false || g_iChosenSurvivor[iClient] == ELLIS)
				{
					if(g_iChosenSurvivor[iClient]==3)
					{
						if(g_iSkillPoints[iClient]>0)
						{
							if(g_iWeaponsLevel[iClient] <=4 )
							{
								g_iSkillPoints[iClient]--;
								g_iWeaponsLevel[iClient]++;
								
								if((0.4 - (float(g_iWeaponsLevel[iClient])*0.08)) < g_fMaxLaserAccuracy)
								{
									g_fMaxLaserAccuracy = 0.4 - (float(g_iWeaponsLevel[iClient])*0.08);
									SetConVarFloat(FindConVar("upgrade_laser_sight_spread_factor"), g_fMaxLaserAccuracy);
								}
							}
							else
								PrintToChat(iClient, "\x03[XPMod] This talent is already maxed out.");
						}
						else
							PrintToChat(iClient, "\x03[XPMod] No skill points remaining.");
						WeaponsMenuDraw(iClient);
					}
					else
					{
						ChangeChar(iClient, 3);
						PrintToChat(iClient, "\x03[XPMod] You dont have Ellis selected.");
					}
				}
				else
				{
					WeaponsMenuDraw(iClient);
					PrintToChat(iClient, "\x03[XPMod] \x05You cannot change your character after confirming it for the round."); 
				}
			}
			case 1: //Drop Level
            {
				if(g_iChosenSurvivor[iClient]==3)
				{
					if(g_iWeaponsLevel[iClient]>0) 			//cant drop level if not beginning of the round for all////////////////////////////////////////////////////
					{
						if(g_bTalentsConfirmed[iClient] == false)
						{
							g_iSkillPoints[iClient]++;
							g_iWeaponsLevel[iClient]--;
						}
						else
							PrintToChat(iClient, "\x03[XPMod] \x05You cannot drop any levels after confirming your talents for the round."); 
					}
					else
						PrintToChat(iClient, "\x03[XPMod] This talent level is already at zero.");
					}
				else
					PrintToChat(iClient, "\x03[XPMod] You don't have Ellis selected.");
				WeaponsMenuDraw(iClient);
            }
			case 2: //Back
            {
				EllisMenuDraw(iClient);
            }            
        }
    }
}


//Jammin to the Music Handler
public JamminMenuHandler(Handle:hmenu, MenuAction:action, iClient, itemNum)
{
	if( action == MenuAction_Select )
	{
		switch (itemNum)
		{
			case 0: //Level up
			{
				if(g_bTalentsConfirmed[iClient] == false || g_iChosenSurvivor[iClient] == ELLIS)
				{
					if(g_iChosenSurvivor[iClient]==3)
					{
						if(g_iSkillPoints[iClient]>0)
						{
							if(g_iJamminLevel[iClient] <=4 )
							{
								g_iSkillPoints[iClient]--;
								g_iJamminLevel[iClient]++;
							}
							else
								PrintToChat(iClient, "\x03[XPMod] This talent is already maxed out.");
						}
						else
							PrintToChat(iClient, "\x03[XPMod] No skill points remaining.");
						JamminMenuDraw(iClient);
					}
					else
					{
						ChangeChar(iClient, 3);
						PrintToChat(iClient, "\x03[XPMod] You dont have Ellis selected.");
					}
				}
				else
				{
					JamminMenuDraw(iClient);
					PrintToChat(iClient, "\x03[XPMod] \x05You cannot change your character after confirming it for the round."); 
				}
			}
			case 1: //Drop Level
            {
				if(g_iChosenSurvivor[iClient]==3)
				{
					if(g_iJamminLevel[iClient]>0) 			//cant drop level if not beginning of the round for all////////////////////////////////////////////////////
					{
						if(g_bTalentsConfirmed[iClient] == false)
						{
							g_iSkillPoints[iClient]++;
							g_iJamminLevel[iClient]--;
						}
						else
							PrintToChat(iClient, "\x03[XPMod] \x05You cannot drop any levels after confirming your talents for the round."); 
					}
					else
						PrintToChat(iClient, "\x03[XPMod] This talent level is already at zero.");
					}
				else
					PrintToChat(iClient, "\x03[XPMod] You don't have Ellis selected.");
				JamminMenuDraw(iClient);
            }
			case 2: //Back
            {
				EllisMenuDraw(iClient);
            }            
        }
    }
}


//Metal Storm Handler and Mechanic Affinity
public MetalMenuHandler(Handle:hmenu, MenuAction:action, iClient, itemNum)
{
	if( action == MenuAction_Select )
	{
		switch (itemNum)
		{
			case 0: //Level up
			{
				if(g_bTalentsConfirmed[iClient] == false || g_iChosenSurvivor[iClient] == ELLIS)
				{
					if(g_iChosenSurvivor[iClient]==3)
					{
						if(g_iSkillPoints[iClient]>0)
						{
							if(g_iMetalLevel[iClient] <=4 )
							{
								if(g_iClientLevel[iClient] > 10 + g_iMetalLevel[iClient])
								{
									g_iSkillPoints[iClient]--;
									g_iMetalLevel[iClient]++;
									if(g_iMetalLevel[iClient]==1)
										push(iClient, 1);
								}
								else
									PrintToChat(iClient, "\x03[XPMod] \x05You must be \x04level %d \x05to level up this talent.", (11 + g_iMetalLevel[iClient]));
							}
							else
								PrintToChat(iClient, "\x03[XPMod] This talent is already maxed out.");
						}
						else
							PrintToChat(iClient, "\x03[XPMod] No skill points remaining.");
						MetalMenuDraw(iClient);
					}
					else
					{
						ChangeChar(iClient, 3);
						PrintToChat(iClient, "\x03[XPMod] You dont have Ellis selected.");
					}
				}
				else
				{
					MetalMenuDraw(iClient);
					PrintToChat(iClient, "\x03[XPMod] \x05You cannot change your character after confirming it for the round."); 
				}
			}
			case 1: //Drop Level
            {
				if(g_iChosenSurvivor[iClient]==3)
				{
					if(g_iMetalLevel[iClient]>0) 			//cant drop level if not beginning of the round for all////////////////////////////////////////////////////
					{
						if(g_bTalentsConfirmed[iClient] == false)
						{
							g_iSkillPoints[iClient]++;
							g_iMetalLevel[iClient]--;
							if(g_iMetalLevel[iClient]==0)
								pop(iClient, 1);
						}
						else
							PrintToChat(iClient, "\x03[XPMod] \x05You cannot drop any levels after confirming your talents for the round."); 
					}
					else
						PrintToChat(iClient, "\x03[XPMod] This talent level is already at zero.");
					}
				else
					PrintToChat(iClient, "\x03[XPMod] You don't have Ellis selected.");
				MetalMenuDraw(iClient);
            }
			case 2: //Back
            {
				EllisMenuDraw(iClient);
            }
        }
    }
}


//Fire Storm Handler
public FireMenuHandler(Handle:hmenu, MenuAction:action, iClient, itemNum)
{
	if( action == MenuAction_Select )
	{
		switch (itemNum)
		{
			case 0: //Level up
			{
				if(g_bTalentsConfirmed[iClient] == false || g_iChosenSurvivor[iClient] == ELLIS)
				{
					if(g_iChosenSurvivor[iClient]==3)
					{
						if(g_iSkillPoints[iClient]>0)
						{
							if(g_iFireLevel[iClient] <= 4)
							{
								if(g_iClientLevel[iClient] > 25 + g_iFireLevel[iClient])
								{
									g_iSkillPoints[iClient]--;
									g_iFireLevel[iClient]++;
								}
								else
									PrintToChat(iClient, "\x03[XPMod] \x05You must be \x04level %d \x05to level up this talent.", (26 + g_iFireLevel[iClient]));
							}
							else
								PrintToChat(iClient, "\x03[XPMod] This talent is already maxed out.");
						}
						else
							PrintToChat(iClient, "\x03[XPMod] No skill points remaining.");
						FireMenuDraw(iClient);
					}
					else
					{
						ChangeChar(iClient, 3);
						PrintToChat(iClient, "\x03[XPMod] You dont have Ellis selected.");
					}
				}
				else
				{
					FireMenuDraw(iClient);
					PrintToChat(iClient, "\x03[XPMod] \x05You cannot change your character after confirming it for the round."); 
				}
			}
			case 1: //Drop Level
            {
				if(g_iChosenSurvivor[iClient]==3)
				{
					if(g_iFireLevel[iClient]>0) 			//cant drop level if not beginning of the round for all////////////////////////////////////////////////////
					{
						if(g_bTalentsConfirmed[iClient] == false)
						{
							g_iSkillPoints[iClient]++;
							g_iFireLevel[iClient]--;
						}
						else
							PrintToChat(iClient, "\x03[XPMod] \x05You cannot drop any levels after confirming your talents for the round."); 
					}
					else
						PrintToChat(iClient, "\x03[XPMod] This talent level is already at zero.");
					}
				else
					PrintToChat(iClient, "\x03[XPMod] You don't have Ellis selected.");
				FireMenuDraw(iClient);
            }
			case 2: //Back
            {
				EllisMenuDraw(iClient);
            }
        }
    }
}