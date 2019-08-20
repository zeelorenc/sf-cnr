/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc, Stev
 * Module: cnr/features/paintball.pwn
 * Purpose: paintball related features
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define MAX_PAINTBALL_ARENAS 		( 6 )
#define MAX_RANDOM_SPAWNS 			( 6 )

/* ** Variables ** */
enum E_PAINTBALL_DATA
{
	E_NAME[ 16 ],		E_HOST, 				E_PASSWORD[ 5 ],
	E_LIMIT,			E_WEAPONS[ 3 ],			E_PLAYERS,
	E_ARENA, 			Float: E_ARMOUR, 		Float: E_HEALTH,
	bool: E_ACTIVE,		bool: E_PASSWORDED, 	bool: E_REFILLER,
	E_CD_TIMER,			bool: E_HEADSHOT, 		bool: E_CHAT,
	bool: E_RANDOM
};

enum E_PAINTBALL_ARENAS
{
	Float: E_X, 		Float: E_Y, 			Float: E_Z,
	E_INTERIOR, 		E_NAME[ 16 ]
};

enum E_PAINTBALL_SPAWNS
{
	E_ARENA_ID,			Float: E_X,			Float: E_Y,
	Float: E_Z,			E_INTERIOR
}

new
	g_paintballArenaData			[ ] [ E_PAINTBALL_ARENAS ] =
	{
		{ 1412.639892, -1.787510, 1000.924377, 1 , 	"Warehouse 1" },
		{ 1302.519897, -1.787510, 1001.028259, 18, 	"Warehouse 2" },
		{ 1063.650400, 2134.9487, 10.82030000, 0 , 	"Warehouse 3" },
		{ -2659.28170, 1410.3884, 910.1703000, 3 , 	"Jizzy's" },
		{ 296.8772000, 174.79120, 1007.171900, 3 ,	"LV-PD" },
		//{ 1265.012900, -775.0262, 1091.906300, 5 ,	"Mad Doggs" },
		{ -1401.68950, 107.43800, 1032.273400, 1 , 	"Stadium 1" },
		{ 2193.399700, -1142.272, 1029.796900, 15, 	"Jefferson Motel" },
		{ -949.294600, 1887.0156, 5.000000000, 17, 	"Sherman Dam" },
		{ 1721.863800, -1655.338, 20.96800000, 18,  "Atrium" }
	},

	Float: g_paintballSpawns 				[ sizeof( g_paintballArenaData ) ] [ MAX_RANDOM_SPAWNS ] [ 3 ] =
	{
		// warehouse 1
		{
			{ 1412.6399, -1.7875, 1000.9244 }, 	{ 1367.4644, -1.3951, 1000.9219 }, 	{ 1402.3909, -23.1311, 1000.9103 },
			{ 1384.0382, -22.2924, 1000.9230 }, { 1415.2482, -40.9799, 1000.9257 }, { 1366.4021, -44.1363, 1000.9192 }
		},

		// warehouse 2
		{
			{ 1302.5199, -1.7875, 1001.0283 }, 	{ 1278.9091, -12.1906, 1001.0156 }, { 1252.9880, -58.8240, 1002.4990 },
			{ 1294.0881, -64.9856, 1002.4960 }, { 1303.2255, -44.0086, 1001.0367 }, { 1251.5754, 2.1243, 1001.0344 }
		},

		// warehouse 3
		{
			{ 1063.6504, 2134.9487, 10.8203 },	{ 1089.6921, 2117.0010, 10.8203 },	{ 1089.5262, 2081.0449, 10.8203 },
			{ 1089.7534, 2077.9897, 15.3504 },	{ 1092.3716, 2119.8259, 15.3504 },	{ 1069.9283, 2103.4949, 10.8203 }
		},

		// Jizzy's
		{
			{ -2659.2817, 1410.3884, 910.1703 }, { -2688.3000, 1430.0179, 906.4609 }, { -2652.9834, 1427.8518, 912.4114 },
			{ -2636.7776, 1406.3575, 906.4609 }, { -2633.1707, 1392.9563, 906.4609 }, { -2649.0347, 1391.7921, 918.3582 }
		},

		// LV-PD
		{
			{ 296.8772, 174.7912, 1007.1719 }, { 297.3651, 191.2529, 1007.1719 }, { 246.5930, 185.2390, 1008.1719 },
			{ 231.5877, 171.6264, 1003.0234 }, { 202.1714, 167.9985, 1003.0234 }, { 239.5641, 141.4648, 1003.0234 }
		},
		
		// Stadium 1
		{
			{ -1401.6895, 107.4380, 1032.2734 }, { -1403.2545, 126.9025, 1030.4382 }, { -1419.7942, 127.4668, 1030.7443 },
			{ -1420.6074, 94.6617, 1031.5850 }, { -1403.0911, 87.1951, 1031.0742 }, { -1383.1639, 94.1880, 1030.7531 }
		},
		
		// Jefferson Motel
		{
			{ 2193.3997,- 1142.2720, 1029.7969 }, { 2189.8071,- 1146.4943, 1033.7969 }, { 2186.7761,- 1156.9148, 1029.7969 },
			{ 2187.3259,- 1180.2784, 1029.7969 }, { 2192.7627,- 1181.1935, 1033.7896 }, { 2236.1255,- 1192.7971, 1029.8043 }
		},
		
		// Sherman Dam
		{
			{ -949.2946, 1887.0156, 5.0000 }, { -961.5467, 1867.0323, 9.0000 }, { -951.4822, 1847.6415, 5.0000 },
			{ -956.1313, 1910.7572, 5.0000 }, { -955.7346, 1930.8940, 5.0000 }, { -942.3181, 1951.5886, 5.0000 }
		},
		
		// Atrium
		{
			{ 1721.8638, -1655.3380, 20.9688 }, { 1733.5320, -1640.5344, 20.2306 }, { 1702.6398, -1667.7361, 20.2188 },
			{ 1727.9952, -1640.1686, 23.7289 }, { 1729.5344, -1669.1146, 22.6151 }, { 1709.9868, -1643.1584, 20.2188 }
		}
	},

	g_paintballData       			[ MAX_PAINTBALL_ARENAS ] [ E_PAINTBALL_DATA ],

	bool: p_LeftPaintball           [ MAX_PLAYERS char ],
 	p_PaintBallArena				[ MAX_PLAYERS char ],

	// Iterator
	Iterator:paintball<MAX_PAINTBALL_ARENAS>
;

/* ** Hooks ** */
#if defined AC_INCLUDED
hook OnPlayerDeathEx( playerid, killerid, reason, Float: damage, bodypart )
#else
hook OnPlayerDeath( playerid, killerid, reason )
#endif
{
	if ( ! ( 0 <= killerid < MAX_PLAYERS ) ) // ignore invalid id / npc killers
		return 1;

	if ( p_inPaintBall{ killerid } == true )
	{
		new
			a = p_PaintBallArena{ killerid };

		if ( g_paintballData[ a ] [ E_REFILLER ] )
		{
			SetPlayerHealth( killerid, g_paintballData[ a ] [ E_HEALTH ] );
			SetPlayerArmour( killerid, g_paintballData[ a ] [ E_ARMOUR ] );
		}

		SendDeathMessage( killerid, playerid, reason );
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if ( ( dialogid == DIALOG_PAINTBALL ) && response )
	{
		for( new id, x = 0; id < MAX_PAINTBALL_ARENAS; id ++ )
		{
	       	if ( x == listitem )
	      	{
				if ( Iter_Contains(paintball, id) )
				{
					if ( !g_paintballData[ id ] [ E_ACTIVE ] )
					{
						SendError( playerid, "This paintball lobby is currently not active and being edited." );
						listPaintBallLobbies( playerid );
						return 1;
					}

		      		if ( g_paintballData[ id ] [ E_PASSWORDED ] && !isnull( g_paintballData[ id ] [ E_PASSWORD ] ) && !strmatch( g_paintballData[ id ] [ E_PASSWORD ], "NULL" ) )
		      		{
					 	if ( g_Debugging ) {
					 		SendClientMessageToRCON( COLOR_YELLOW, "PAINTBALL: host %s, passworded %d, password %s", ReturnPlayerName( g_paintballData[ id ] [ E_HOST ] ), g_paintballData[ id ] [ E_PASSWORDED ], g_paintballData[ id ] [ E_PASSWORD ] );
					 	}
						p_PaintBallArena{ playerid } = id;
		      			SendServerMessage( playerid, "You are trying to join the paintball lobby: "COL_GREY"%s", g_paintballData[ id ] [ E_NAME ] );
		      			ShowPlayerDialog( playerid, DIALOG_PAINTBALL_PW, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Join", "{FFFFFF}This lobby requires a password.", "Join", "Back" );
		      			return 1;
		      		}
		      		JoinPlayerPaintball( playerid, id );
				}
				else
				{
			    	if ( hasPaintBallArena( playerid ) )
			    		return SendError( playerid, "You already have an paintball arena set. You've been spawned." ), SpawnPlayer( playerid );

				  	if ( GetPlayerCash( playerid ) < 5000 )
			    		return listPaintBallLobbies( playerid ), SendError( playerid, "You're insufficient of funds. ($5,000)" ), 1;

			    	if ( !CreatePaintballLobby( id, playerid, "Paintball", 8, 0 ) )
			    		return SendError( playerid, "Unable to create lobby due to an error. Maybe someone's occupied the slot?" );

			    	GivePlayerCash( playerid, -5000 );
			    	showPaintBallLobbyData( playerid, id );
			    	p_PaintBallArena{ playerid } = id;
				}
				break;
	   		}
	      	x ++;
		}
	}
	if ( dialogid == DIALOG_PAINTBALL_PW )
	{
		if ( response )
		{
			new
				szPassword[ 5 ];

			strreplacechar( inputtext, '\\', '/' );
			if ( IsPlayerJailed( playerid ) ) return SendError( playerid, "This is no longer available as you're in jail." );
	    	if ( !Iter_Contains( paintball, p_PaintBallArena{ playerid } ) ) return SendError( playerid, "This lobby no longer exists." );
	    	if ( sscanf( inputtext, "s[5]", szPassword ) ) return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_PW, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Join", "{FFFFFF}This lobby requires a password.\n\n"COL_RED"Incorrect password, please try again.", "Join", "Back" );
			if ( g_paintballData[ p_PaintBallArena{ playerid } ] [ E_PASSWORDED ] ) {
				if ( !strmatch( szPassword, g_paintballData[ p_PaintBallArena{ playerid } ] [ E_PASSWORD ] ) ) return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_PW, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Join", "{FFFFFF}This lobby requires a password.\n\n"COL_RED"Incorrect password, please try again.", "Join", "Back" );
			}
			else SendServerMessage( playerid, "Seems like the lobby you were trying to join is not passworded anymore." );
			JoinPlayerPaintball( playerid, p_PaintBallArena{ playerid } );
		}
		else listPaintBallLobbies( playerid );
	}
	if ( dialogid == DIALOG_PAINTBALL_EDIT )
	{
		if ( response )
		{
			new
				iLobby = p_PaintBallArena{ playerid };

			SetPVarInt( playerid, "paintball_edititem", listitem );

			switch( listitem )
			{
				case 0 .. 4: 	ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?", "Commit", "Back" );
				case 5:
				{
					g_paintballData[ iLobby ] [ E_REFILLER ] = !g_paintballData[ iLobby ] [ E_REFILLER ];
					SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" Upon death, armour and/or health will%s be restored.", g_paintballData[ iLobby ] [ E_REFILLER ] == false ? ( " not" ) : ( "" ) );
					showPaintBallLobbyData( playerid, iLobby );
				}
				case 6: 		ShowPlayerPaintballArenas( playerid );
				case 7 .. 9: 	ShowPlayerDialog( playerid, DIALOG_PAINTBALL_WEP, DIALOG_STYLE_LIST, "{FFFFFF}Paintball - Edit", ""COL_RED"Remove Weapon On This Slot\n9mm Pistol\nSilenced Pistol\nDesert Eagle\nShotgun\nSawn-off Shotgun\nSpas 12\nMac 10\nMP5\nAK-47\nM4\nTec 9\nRifle\nSniper", "Select", "Cancel");
				case 10:
				{
					g_paintballData[ iLobby ] [ E_HEADSHOT ] = !g_paintballData[ iLobby ] [ E_HEADSHOT ];
					SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" Headshot mode has been %s.", g_paintballData[ iLobby ] [ E_HEADSHOT ] == false ? ( "un-toggled" ) : ( "toggled" ) );
					showPaintBallLobbyData( playerid, iLobby );
				}
				case 11:
				{
					g_paintballData[ iLobby ] [ E_CHAT ] = !g_paintballData[ iLobby ] [ E_CHAT ];
					SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" Upon death, armour and/or health will%s be restored.", g_paintballData[ iLobby ] [ E_CHAT ] == false ? ( " not" ) : ( "" ) );
					showPaintBallLobbyData( playerid, iLobby );
				}
				case 12:
				{
					g_paintballData[ iLobby ] [ E_RANDOM ] = !g_paintballData[ iLobby ] [ E_RANDOM ];
					SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" Random spawn has been %s.", g_paintballData[ iLobby ] [ E_RANDOM ] == false ? ( "un-toggled" ) : ( "toggled" ) );
					showPaintBallLobbyData( playerid, iLobby );
				}
			}
		}
		else
		{
			new
				i = p_PaintBallArena{ playerid };

			if ( !g_paintballData[ i ] [ E_ACTIVE ] )
			{
				g_paintballData[ i ] [ E_ACTIVE ] = true;
			  	JoinPlayerPaintball( playerid, i );
			  	SendServerMessage( playerid, "You can edit your lobby with "COL_GREY"/paintball edit"COL_WHITE"." );
			}
		}
	}
	if ( dialogid == DIALOG_PAINTBALL_EDIT_VAL )
	{
		new
			iLobby = p_PaintBallArena{ playerid };

		if ( response )
		{
			switch( GetPVarInt( playerid, "paintball_edititem" ) )
			{
				case 0: // name
				{
					new
						szName[ 16 ];

					if ( sscanf( inputtext, "s[16]", szName ) )
				 		return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?\n\n"COL_RED"Invalid Lobby Name.", "Commit", "Back" );

					if ( strlen( inputtext ) < 3 || strlen( inputtext ) >= 16 )
				 		return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?\n\n"COL_RED"The lobby name must be ranged between 3 and 16 characters.", "Commit", "Back" );

					format( g_paintballData[ iLobby ] [ E_NAME ], 16, "%s", szName );
					SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" The lobby name has been updated by %s(%d)", ReturnPlayerName( playerid ), playerid );
				}
				case 1: // pw
				{
					new
						szPassword[ 5 ];

					if ( sscanf( inputtext, "s[5]", szPassword ) ) return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?\n\n"COL_RED"The password can only be a maximum of 4 characters. Set to NULL to disable.", "Commit", "Back" );
					if ( !strlen( szPassword ) || strlen( szPassword ) >= 5 ) return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?\n\n"COL_RED"The password can only be a maximum of 4 characters. Set to NULL to disable.", "Commit", "Back" );

					if ( strmatch( szPassword, "NULL" ) )
					{
						SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" The lobby password has been%sdisabled.", " " );
						g_paintballData[ iLobby ] [ E_PASSWORDED ] = false;
					}
					else
					{
						SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" The lobby password has been changed to: "COL_GREY"%s"COL_WHITE".", szPassword );
						g_paintballData[ iLobby ] [ E_PASSWORDED ] = true;
					}
					format( g_paintballData[ iLobby ] [ E_PASSWORD ], 5, "%s", szPassword );
				}
				case 2: // limit
				{
					new iLimit;

					if ( sscanf( inputtext, "d", iLimit ) )
				 		return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?\n\n"COL_RED"Ensure the player capacity is an integer.", "Commit", "Back" );

					if ( iLimit < 2 || iLimit > 32 )
				 		return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?\n\n"COL_RED"Please specify between 2 and 32 players.", "Commit", "Back" );

					if ( iLimit < g_paintballData[ iLobby ] [ E_PLAYERS ] )
						return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?\n\n"COL_RED"Your limit can not be less than the number of players joined already.", "Commit", "Back" );

				 	g_paintballData[ iLobby ] [ E_LIMIT ] = iLimit;
					SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" The lobby player limit has been set to %d.", g_paintballData[ iLobby ] [ E_LIMIT ] );
				}
				case 3: // health
				{
					new Float: fHealth;

					if ( sscanf( inputtext, "f", fHealth ) )
				 		return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?\n\n"COL_RED"Ensure the player capacity is a numerical number.", "Commit", "Back" );

					if ( fHealth < 1 || fHealth > 150 )
				 		return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?\n\n"COL_RED"Please specify between 1 and 150 health.", "Commit", "Back" );

				 	g_paintballData[ iLobby ] [ E_HEALTH ] = fHealth;
					SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" The lobby spawn health has been set to %0.2f.", g_paintballData[ iLobby ] [ E_HEALTH ] );

					respawnAllInPaintballLobby( iLobby );
				}
				case 4: // armour
				{
					new Float: fArmour;

					if ( sscanf( inputtext, "f", fArmour ) )
				 		return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?\n\n"COL_RED"Ensure the player capacity is a numerical number.", "Commit", "Back" );

					if ( fArmour < 0 || fArmour > 150 )
				 		return ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT_VAL, DIALOG_STYLE_INPUT, "{FFFFFF}Paintball - Edit", "{FFFFFF}What would you like to set the value of this to?\n\n"COL_RED"Please specify between 0 and 150 armour.", "Commit", "Back" );

				 	g_paintballData[ iLobby ] [ E_ARMOUR ] = fArmour;
					SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" The lobby spawn armour has been set to %0.2f.", g_paintballData[ iLobby ] [ E_ARMOUR ] );

					respawnAllInPaintballLobby( iLobby );
				}
			}
			showPaintBallLobbyData( playerid, iLobby );
		}
		else showPaintBallLobbyData( playerid, iLobby );
	}
	if ( dialogid == DIALOG_PAINTBALL_ARENAS )
	{
		new
			iLobby = p_PaintBallArena{ playerid };

		if ( response )
		{
			g_paintballData[ iLobby ] [ E_ARENA ] = listitem;
			SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" The lobby arena has been set to %s.", g_paintballArenaData[ listitem ] [ E_NAME ] );
			respawnAllInPaintballLobby( iLobby );
			showPaintBallLobbyData( playerid, iLobby );
		}
		else showPaintBallLobbyData( playerid, iLobby );
	}
	if ( dialogid == DIALOG_PAINTBALL_WEP )
	{
		new
			iLobby = p_PaintBallArena{ playerid };

		if ( response )
		{
			if ( !listitem )
				g_paintballData[ iLobby ] [ E_WEAPONS ] [ GetPVarInt( playerid, "paintball_edititem" ) - 7 ] = 0;
			else
				g_paintballData[ iLobby ] [ E_WEAPONS ] [ GetPVarInt( playerid, "paintball_edititem" ) - 7 ] = 21 + listitem;

			SendClientMessageToPaintball( iLobby, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" The lobby weapon set has been%supdated.", " " );
			respawnAllInPaintballLobby( iLobby );
			showPaintBallLobbyData( playerid, iLobby );
		}
		else showPaintBallLobbyData( playerid, iLobby );
	}
	return 1;
}

/* ** Commands ** */
CMD:pb( playerid, params[ ] ) return cmd_paintball( playerid, params );
CMD:paintball( playerid, params[ ] )
{
	if ( !IsPlayerInPaintBall( playerid ) )
		return SendError( playerid, "You're not in any paintball lobby." );

	if ( strmatch( params, "leave" ) )
	{
		if ( !IsPlayerInPaintBall( playerid ) )
		    return SendError( playerid, "You're not inside the paintball." );

		LeavePlayerPaintball( playerid );
	    SetPlayerHealth( playerid, -1 );
	    SendServerMessage( playerid, "You have left the paintball arena." );
	    return 1;
	}

	if ( !hasPaintBallArena( playerid ) )
		return SendError( playerid, "This command requires you to be the host of a lobby." );

	new
		id = p_PaintBallArena{ playerid },
		pID
	;

	if ( strmatch( params, "edit" ) )
	{
		showPaintBallLobbyData( playerid, id, "Close" );
	}
	else if ( !strcmp( params, "kick", false, 4 ) )
	{
		if ( sscanf( params[ 5 ], "u", pID ) ) return SendUsage( playerid, "/paintball kick [PLAYER_ID]" );
		else if ( !IsPlayerConnected( pID ) ) return SendError( playerid, "This player is not connected." );
		else if ( !IsPlayerInPaintBall( pID ) ) return SendError( playerid, "This player is not in paintball." );
		else if ( p_PaintBallArena{ pID } != id ) return SendError( playerid, "This player is not in your paintball lobby." );
		else if ( pID == playerid ) return SendError( playerid, "You cannot kick yourself." );
		else
		{
			SendClientMessageToPaintball( id, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" %s(%d) has left the lobby (KICKED)", ReturnPlayerName( pID ), pID );
			LeavePlayerPaintball( pID );
			SetPlayerHealth( pID, -1 );
		}
	}
	else if ( !strcmp( params, "leader", false, 6 ) )
	{
		if ( sscanf( params[ 7 ], "u", pID ) ) return SendUsage( playerid, "/paintball paintball [PLAYER_ID]" );
		else if ( !IsPlayerConnected( pID ) ) return SendError( playerid, "This player is not connected." );
		else if ( !IsPlayerInPaintBall( pID ) ) return SendError( playerid, "This player is not in paintball." );
		else if ( p_PaintBallArena{ pID } != id ) return SendError( playerid, "This player is not in your paintball lobby." );
		else if ( pID == playerid ) return SendError( playerid, "You cannot apply this action to yourself." );
		else
		{
			g_paintballData[ id ] [ E_HOST ] = pID;
			SendClientMessageToPaintball( id, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" %s(%d) is the new paintball leader.", ReturnPlayerName( pID ), pID );
		}
	}
	else if ( !strcmp( params, "countdown", false, 6 ) )
	{
		new
			iSeconds;

		if ( sscanf( params[ 10 ], "D(10)", iSeconds ) ) return SendUsage( playerid, "/paintball countdown [SECONDS]" );
		else if ( iSeconds < 1 || iSeconds > 30 ) return SendError( playerid, "Please specify countdown seconds between 1 and 30." );
		else
		{
			SendServerMessage( playerid, "You have started a countdown from %d in your paintball game.", iSeconds );

		 	KillTimer( g_paintballData[ id ] [ E_CD_TIMER ] );
			g_paintballData[ id ] [ E_CD_TIMER ] = SetTimerEx( "paintballCountDown", 960, false, "dd", id, iSeconds - 1 );
		}
	}
	else
	{
		SendUsage( playerid, "/paintball [LEAVE/EDIT/KICK/COUNTDOWN/LEADER]" );
	}
	return 1;
}

CMD:p( playerid, params[ ] )
{
	if ( !IsPlayerInPaintBall( playerid ) )
		return SendError( playerid, "You're not in any paintball lobby." );

	new
	    id = p_PaintBallArena{ playerid },
	    msg[ 90 ]
	;

	if ( sscanf( params, "s[90]", msg ) ) return SendUsage( playerid, "/p [MESSAGE]" );
	else if ( textContainsIP( msg ) ) return SendServerMessage( playerid, "Please do not advertise." );
    else if ( !g_paintballData[ id ] [ E_CHAT ] ) return SendError( playerid, "Paintball chat is disabled in this lobby." );
    else
	{
		SendClientMessageToPaintball( id, -1, ""COL_GREY"<Paintball Chat> %s(%d):"COL_WHITE" %s", ReturnPlayerName( playerid ), playerid, msg );

		foreach ( new i : Player ) if ( ( p_AdminLevel[ i ] >= 5 || IsPlayerUnderCover( i ) ) && p_TogglePBChat{ i } == true )  {
			SendClientMessageFormatted( i, -1, ""COL_GREY"<Paintball Chat Lobby %d > %s(%d):"COL_WHITE" %s", id, ReturnPlayerName( playerid ), playerid, msg );
		}
	}
	return 1;
}

CMD:pleave( playerid, params[ ] ) return cmd_pb( playerid, "leave" );

/* ** Functions ** */
function paintballCountDown( paintballid, time )
{
	if ( paintballid == -1 )
		return;

	if ( !time )
	{
	    foreach(new playerid : Player)
	    {
	    	if ( IsPlayerInPaintBall( playerid ) && p_PaintBallArena{ playerid } == paintballid )
	    	{
	    		GameTextForPlayer( playerid, "~g~GO!", 2000, 3 );
				PlayerPlaySound( playerid, 1057, 0.0, 0.0, 0.0 );
			}
		}
		g_paintballData[ paintballid ] [ E_CD_TIMER ] = 0xFFFF;
	}
	else
	{
	    foreach(new playerid : Player)
	    {
	    	if ( IsPlayerInPaintBall( playerid ) && p_PaintBallArena{ playerid } == paintballid )
	    	{
	    		GameTextForPlayer( playerid, sprintf( "~y~%d", time ), 2000, 3 );
	    		PlayerPlaySound( playerid, 1056, 0.0, 0.0, 0.0 );
	    	}
	    }
		g_paintballData[ paintballid ] [ E_CD_TIMER ] = SetTimerEx( "paintballCountDown", 960, false, "dd", paintballid, time - 1 );
	}
}

stock CreatePaintballLobby( pid, playerid, const szLobbyName[ 16 ], iPlayerCap, iArena, Float: fHealth = 100.0, Float: fArmour = 100.0 )
{
	if ( !Iter_Contains(paintball, pid) )
	{
		format( g_paintballData[ pid ] [ E_NAME ], 16, "%s", szLobbyName );
		g_paintballData[ pid ] [ E_PASSWORD ] [ 0 ] = '\0';
		g_paintballData[ pid ] [ E_PASSWORDED ]		= false;
		g_paintballData[ pid ] [ E_HOST ] 			= playerid;
		g_paintballData[ pid ] [ E_PLAYERS ] 		= 0;
		g_paintballData[ pid ] [ E_LIMIT ] 			= iPlayerCap;
		g_paintballData[ pid ] [ E_WEAPONS ] [ 0 ] 	= 0;
		g_paintballData[ pid ] [ E_WEAPONS ] [ 1 ] 	= 0;
		g_paintballData[ pid ] [ E_WEAPONS ] [ 2 ] 	= 0;
		g_paintballData[ pid ] [ E_ARMOUR ] 		= fHealth;
		g_paintballData[ pid ] [ E_HEALTH ] 		= fArmour;
		g_paintballData[ pid ] [ E_ARENA ] 			= iArena;
		g_paintballData[ pid ] [ E_ACTIVE ] 		= false;
		g_paintballData[ pid ] [ E_REFILLER ] 		= false;
		g_paintballData[ pid ] [ E_CD_TIMER ] 		= 0xFFFF;
		Iter_Add(paintball, pid);
		return true;
	}
	return false;
}

stock DestroyPaintballArena( p )
{
	if ( !Iter_Contains(paintball, p) )
		return false;

	Iter_Remove(paintball, p);
	g_paintballData[ p ] [ E_HOST ] = INVALID_PLAYER_ID;
	g_paintballData[ p ] [ E_PLAYERS ] = 0;
	g_paintballData[ p ] [ E_ACTIVE ] = false;
	g_paintballData[ p ] [ E_CD_TIMER ] = 0xFFFF;
	return true;
}

stock listPaintBallLobbies( playerid )
{
	if ( p_WantedLevel[ playerid ] ) return SendError( playerid, "You mustn't be wanted to join a paintball arena." );
	if ( p_Class[ playerid ] != CLASS_CIVILIAN ) return SendError( playerid, "You must be a civilian to join a paintball arena." );

	new
		szLobbies[ 64 * MAX_PAINTBALL_ARENAS + 64 ];

	for( new p = 0; p < MAX_PAINTBALL_ARENAS; p++ )
	{
		if ( !g_paintballData[ p ] [ E_ACTIVE ] && !Iter_Contains(paintball, p) ) {
			format( szLobbies, sizeof( szLobbies ), "%s{334D5C}Vacant Paintball Slot ($5,000)\n", szLobbies );
		}
		else if ( Iter_Contains(paintball, p) ) {
			format( szLobbies, sizeof( szLobbies ), "%s%s%s[%02d/%02d] %s hosted by %s\n",
				szLobbies, g_paintballData[ p ] [ E_PASSWORDED ] ? ( "{DF4949}" ) : ( "{53B240}" ), g_paintballData[ p ] [ E_ACTIVE ] ? ( "" ) : ( "{EFC94C}" ), g_paintballData[ p ] [ E_PLAYERS ], g_paintballData[ p ] [ E_LIMIT ], g_paintballData[ p ] [ E_NAME ], ReturnPlayerName( g_paintballData[ p ] [ E_HOST ] )
			);
		}
	}
    return ShowPlayerDialog( playerid, DIALOG_PAINTBALL, DIALOG_STYLE_LIST, "{FFFFFF}Paintball - Selection", szLobbies, "Select", "Cancel" );
}

stock showPaintBallLobbyData( playerid, id, second_button[ ] = "Join Game" )
{
	format( szLargeString, sizeof( szLargeString ), "Lobby Name\t"COL_GREY"%s"COL_WHITE"\nLobby Password\t%s"COL_WHITE"\nPlayer Capacity\t"COL_GREY"%d"COL_WHITE"\nHealth\t"COL_GREY"%0.2f%%"COL_WHITE"\nArmour\t"COL_GREY"%0.2f%%"COL_WHITE"\nRefill Health/Armour\t%s"COL_WHITE"\nArena\t"COL_GREY"%s"COL_WHITE"\nPrimary Weapon\t"COL_GREY"%s"COL_WHITE"\nSecondary Weapon\t"COL_GREY"%s"COL_WHITE"\nTertiary Weapon\t"COL_GREY"%s"COL_WHITE"\nHeadshot Mode\t"COL_GREY"%s"COL_WHITE"\nChat\t"COL_GREY"%s\nRandom Spawns\t"COL_GREY"%s",
		g_paintballData[ id ] [ E_NAME ],
		g_paintballData[ id ] [ E_PASSWORDED ] == true ? ( ""COL_GREEN"ENABLED" ) : ( ""COL_RED"DISABLED" ),
		g_paintballData[ id ] [ E_LIMIT ],
		g_paintballData[ id ] [ E_HEALTH ],
		g_paintballData[ id ] [ E_ARMOUR ],
		g_paintballData[ id ] [ E_REFILLER ] == true ? ( ""COL_GREEN"ENABLED" ) : ( ""COL_RED"DISABLED" ),
		g_paintballArenaData[ g_paintballData[ id ] [ E_ARENA ] ] [ E_NAME ],
		ReturnWeaponName( g_paintballData[ id ] [ E_WEAPONS ] [ 0 ] ),
		ReturnWeaponName( g_paintballData[ id ] [ E_WEAPONS ] [ 1 ] ),
		ReturnWeaponName( g_paintballData[ id ] [ E_WEAPONS ] [ 2 ] ),
		g_paintballData[ id ] [ E_HEADSHOT ] == true ? ( ""COL_GREEN"ENABLED" ) : ( ""COL_RED"DISABLED" ),
		g_paintballData[ id ] [ E_CHAT ] == true ? ( ""COL_GREEN"ENABLED" ) : ( ""COL_RED"DISABLED" ),
		g_paintballData[ id ] [ E_RANDOM ] == true ? ( ""COL_GREEN"ENABLED" ) : ( ""COL_RED"DISABLED" )
	);
	ShowPlayerDialog( playerid, DIALOG_PAINTBALL_EDIT, DIALOG_STYLE_TABLIST, "{FFFFFF}Paintball - Lobby Settings", szLargeString, "Change", second_button );
}

stock ShowPlayerPaintballArenas( playerid )
{
	static
		szArenas[ 16 * sizeof( g_paintballArenaData ) ];

	if ( szArenas[ 0 ] == '\0' )
	{
		for( new i; i < sizeof( g_paintballArenaData ); i++ )
		{
			strcat( szArenas, g_paintballArenaData[ i ] [ E_NAME ] );
			strcat( szArenas, "\n" );
		}
	}

	ShowPlayerDialog( playerid, DIALOG_PAINTBALL_ARENAS, DIALOG_STYLE_LIST, "{FFFFFF}Paintball - Edit", szArenas, "Select", "Back" );
}

stock JoinPlayerPaintball( playerid, p )
{
	if ( !IsPlayerConnected( playerid ) )
		return -1;

	if ( !Iter_Contains( paintball, p ) )
		return -1;

	if ( g_paintballData[ p ] [ E_PLAYERS ] >= g_paintballData[ p ] [ E_LIMIT ] )
		return SendError( playerid, "This lobby is currently full, you're unable to join it." );

	p_PaintBallArena	{ playerid } = p;
	p_inPaintBall		{ playerid } = true;
	g_paintballData 	[ p ] [ E_PLAYERS ] ++;

	SpawnToPaintball( playerid, p );
	SendClientMessageFormatted( playerid, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" You've joined the paintball area: "COL_GREY"%s"COL_WHITE".", g_paintballData[ p ] [ E_NAME ] );
	return 1;
}

stock SpawnToPaintball( playerid, p )
{
	if ( !IsPlayerConnected( playerid ) )
		return;

	if ( !Iter_Contains( paintball, p ) )
		return;

	new
		iArena = g_paintballData[ p ] [ E_ARENA ];

    ResetPlayerWeapons( playerid );

    GivePlayerWeapon( playerid, g_paintballData[ p ] [ E_WEAPONS ] [ 0 ], 16000 );
    GivePlayerWeapon( playerid, g_paintballData[ p ] [ E_WEAPONS ] [ 1 ], 16000 );
    GivePlayerWeapon( playerid, g_paintballData[ p ] [ E_WEAPONS ] [ 2 ], 16000 );

    SetPlayerHealth( playerid, g_paintballData[ p ] [ E_HEALTH ] );
	SetPlayerArmour( playerid, g_paintballData[ p ] [ E_ARMOUR ] );

 	
	// random spawns
	if ( g_paintballData[ p ][ E_RANDOM ] )
	{
		new 
			random_spawn_id = random( MAX_RANDOM_SPAWNS );
		
		SetPlayerPos( playerid, g_paintballSpawns[ iArena ][ random_spawn_id ][ 0 ], g_paintballSpawns[ iArena ][ random_spawn_id ][ 1 ], g_paintballSpawns[ iArena ][ random_spawn_id ][ 2 ] );
	}
	else SetPlayerPos( playerid, g_paintballArenaData[ iArena ] [ E_X ], g_paintballArenaData[ iArena ] [ E_Y ], g_paintballArenaData[ iArena ] [ E_Z ] );

	SetPlayerInterior( playerid, g_paintballArenaData[ iArena ] [ E_INTERIOR ] );
    SetPlayerVirtualWorld( playerid, p + 10000 );
}

stock LeavePlayerPaintball( playerid )
{
	if ( !IsPlayerConnected( playerid ) )
		return;

	new
		p = -1;

	if ( !hasPaintBallArena( playerid, p ) )
		p = p_PaintBallArena{ playerid }; // Backup

	if ( IsPlayerInPaintBall( playerid ) )
	{
		p_inPaintBall		{ playerid } = false;
		p_LeftPaintball		{ playerid } = true;
		g_paintballData 	[ p ] [ E_PLAYERS ] --;
	}

	if ( !Iter_Contains( paintball, p ) )
		return;

	if ( g_paintballData[ p ] [ E_HOST ] == playerid )
	{
		new
			oldHost = g_paintballData[ p ] [ E_HOST ];

		foreach(new i : Player)
		{
			if ( IsPlayerInPaintBall( i ) && p_PaintBallArena{ i } == p && playerid != i )
			{
				g_paintballData[ p ] [ E_HOST ] = i;
				SendClientMessageFormatted( i, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" %s(%d) is now the leader of the lobby.", ReturnPlayerName( i ), i );
				break;
			}
		}

		if ( oldHost == g_paintballData[ p ] [ E_HOST ] )
		{
			SendClientMessage( playerid, -1, ""COL_GREY"[PAINTBALL]"COL_WHITE" There is no one playing in your lobby therefore the game has been destroyed." );
			DestroyPaintballArena( p );
		}
	}
}

stock respawnAllInPaintballLobby( lobby )
{
	foreach(new i : Player)
	{
		if ( IsPlayerInPaintBall( i ) && p_PaintBallArena{ i } == lobby && GetPlayerState( i ) != PLAYER_STATE_WASTED && IsPlayerSpawned( i ) )
			SpawnPlayer( i ), SendServerMessage( i, "As the lobby host changed some settings, you've been spawned." );
	}
}

stock hasPaintBallArena( playerid, &arena = -1 )
{
	foreach(new i : paintball) {
		if ( g_paintballData[ i ] [ E_HOST ] == playerid ) {
			arena = i;
			return true;
		}
	}
	return false;
}

stock IsPlayerLeavingPaintball( playerid ) {
	return p_LeftPaintball{ playerid };
}

stock SendClientMessageToPaintball( paintballid, colour, const format[ ], va_args<> )
{
    static
		out[ 144 ];

    va_format( out, sizeof( out ), format, va_start<3> );

	foreach ( new i : Player ) if ( p_inPaintBall{ i } && p_PaintBallArena{ i } == paintballid ) {
		SendClientMessage( i, colour, out );
	}
	return 1;
}
