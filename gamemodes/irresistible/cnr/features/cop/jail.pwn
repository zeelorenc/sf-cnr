/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\cop\jail.pwn
 * Purpose: jail system for players
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define JAIL_SECONDS_MULTIPLIER		( 2 )
#define ALCATRAZ_REQUIRED_TIME		( 150 )

#define ALCATRAZ_TIME_PAUSE 		( 5 )
#define ALCATRAZ_TIME_WANTED 		( 600 )

/* ** Variables ** */
enum E_JAIL_DATA
{
	E_CITY,				Float: E_EXPLODE1_POS[ 3 ],	Float: E_EXPLODE2_POS[ 3 ],
	Float: E_RADIUS,	E_TIMESTAMP,				bool: E_BOMBED
};

static stock
	g_jailData						[ MAX_CITIES ] [ E_JAIL_DATA ] =
	{
		{ CITY_SF, { 217.4585, 113.6866, 999.0156 }, { 225.4888, 113.1873, 999.0156 }, 5.0,  0, false },
		{ CITY_LV, { 194.3351, 179.008, 1003.0234 }, { 193.8611, 158.0657, 1003.024 }, 10.0, 0, false },
		{ CITY_LS, { 268.5573, 86.1785, 1001.0391 }, { 268.1720, 78.5381, 1001.0391 }, 5.0,	 0, false }
	},
	p_JailObjectLV					[ MAX_PLAYERS ] [ 3 ],
	p_JailObjectSF					[ MAX_PLAYERS ] [ 4 ],
	p_JailObjectLS					[ MAX_PLAYERS ] [ 3 ],
	p_AlcatrazObject 				[ MAX_PLAYERS ] = { INVALID_OBJECT_ID, ... },
	p_AlcatrazEscapeTS 				[ MAX_PLAYERS ],
	g_alcatrazTimestamp 			= 0,
	g_AlcatrazArea 					= -1
;

/* ** Forwards ** */
forward OnPlayerJailed( playerid );
forward OnPlayerUnjailed( playerid, reasonid );

/* ** Hooks ** */
hook OnScriptInit( )
{
	// Alcatraz
	g_AlcatrazArea = CreateDynamicRectangle( -1921.6816, 1661.7448, -2172.4653, 1876.0469 );
	return 1;
}

/*hook OnPlayerEnterDynamicCP( playerid, checkpointid ) {
	if ( IsPlayerJailed( playerid ) )  {
		return SendError( playerid, "You're jailed, and you accessed a checkpoint. I smell a cheater." ), KickPlayerTimed( playerid ), Y_HOOKS_BREAK_RETURN_1;
	}
	return 1;
}*/

hook OnPlayerUpdateEx( playerid )
{
    // Alcatraz Escape Mechanism
    if ( g_iTime > p_AlcatrazEscapeTS[ playerid ] && GetPlayerState( playerid ) != PLAYER_STATE_SPECTATING )
    {
        if ( IsPlayerAFK( playerid ) )
            p_AlcatrazEscapeTS[ playerid ] = g_iTime + ALCATRAZ_TIME_PAUSE; // Money farmers?

        if ( IsPlayerInDynamicArea( playerid, g_AlcatrazArea ) && g_iTime > p_AlcatrazSpec[ playerid ] )
        {
            if ( !IsPlayerJailed( playerid ) && p_Class[ playerid ] != CLASS_POLICE && !IsPlayerDetained( playerid ) )
            {
                if ( GetPVarInt( playerid, "AlcatrazWantedCD" ) < g_iTime )
                {
                    SetPVarInt( playerid, "AlcatrazWantedCD", g_iTime + ALCATRAZ_TIME_WANTED );
                    GivePlayerWantedLevel( playerid, 24 );
                    ShowPlayerHelpDialog( playerid, 6000, "Warning! You are now wanted for accessing a ~r~~h~prohibited area!" );
                }
            }
        }
        else
        {
            if ( IsPlayerJailed( playerid ) && IsPlayerSpawned( playerid ) && !IsPlayerAdminOnDuty( playerid ) )
            {
                if ( p_inAlcatraz{ playerid } )
                {
                    if ( p_Class[ playerid ] != CLASS_POLICE && !IsPlayerAdminJailed( playerid ) && !IsPlayerAFK( playerid ) )
                    {
                        SetPVarInt( playerid, "AlcatrazWantedCD", g_iTime + ALCATRAZ_TIME_WANTED );
                        PlainUnjailPlayer 		( playerid );
                        SetPlayerColorToTeam	( playerid );
                        SetPlayerHealth 		( playerid, 100.0 );
                        p_inAlcatraz 			{ playerid } = false;

                        if ( GetPVarInt( playerid, "AlcatrazGiveWantedCD" ) < g_iTime ) {
                            GivePlayerWantedLevel( playerid, 64 );
                            SendGlobalMessage( -1, ""COL_GOLD"[JAIL ESCAPE]{FFFFFF} %s(%d) has escaped from Alcatraz, 64 wanted goes to him!", ReturnPlayerName( playerid ), playerid );
                            SetPVarInt( playerid, "AlcatrazGiveWantedCD", g_iTime + 60 );
                        }
                        else SendGlobalMessage( -1, ""COL_GOLD"[JAIL ESCAPE]{FFFFFF} %s(%d) has escaped from Alcatraz!", ReturnPlayerName( playerid ), playerid );
                    }
                    else
                    {
                        SendError( playerid, "You cannot leave the prison. It's prohibited." );
                        SetPlayerPosToPrison( playerid );
                    }
                }
            }
        }
    }
    return 1;
}

hook OnPlayerFirstSpawn( playerid )
{
    // Jail people that left jailed
    if ( p_JailTime[ playerid ] ) // We load this when the player logs in.
    {
        JailPlayer( playerid, p_JailTime[ playerid ], p_AdminJailed{ playerid } );
        SendGlobalMessage( -1, ""COL_GOLD"[JAIL]{FFFFFF} %s(%d) has been sent to jail "COL_LRED"[Left as a jailed person]", ReturnPlayerName( playerid ), playerid );
        return 0;
    }

    // Jail quit to avoiders
    if ( p_LeftCuffed{ playerid } )
    {
        new
            szServing = 100 + GetPlayerScore( playerid );

        if ( szServing > 1000 ) szServing = 1000;

        p_LeftCuffed{ playerid } = false;
        JailPlayer( playerid, szServing, 1 );
        SendGlobalMessage( -1, ""COL_GOLD"[JAIL]{FFFFFF} %s(%d) has been sent to jail for %d seconds by the server "COL_LRED"[Quit To Avoid]", ReturnPlayerName( playerid ), playerid, szServing );
        return 0;
    }
    return 1;
}

hook OnPlayerC4Blown( playerid, Float: X, Float: Y, Float: Z, worldid )
{
    // check if blown up alcatraz rock
    if ( IsPointToPoint( 10.0, X, Y, Z, -2016.7365, 1826.2612, 43.1458 ) )
    {
        if ( g_iTime > g_alcatrazTimestamp )
        {
            g_alcatrazTimestamp = g_iTime + 300;

            GivePlayerExperience( playerid, E_ROBBERY, 3.5 );
            GivePlayerScore( playerid, 3 );
            GivePlayerWantedLevel( playerid, 24 );
            ach_HandleJailBlown( playerid );

            SendGlobalMessage( -1, ""COL_GREY"[SERVER]"COL_WHITE" %s(%d) has destroyed the "COL_GREY"Alcatraz Rock{FFFFFF}!", ReturnPlayerName( playerid ), playerid );
            massUnjailPlayers( CITY_SF, .alcatraz = true );
        }
    }

    // check if blown up jail cell
    for ( new j = 0; j < sizeof( g_jailData ); j ++ )
    {
        if ( IsPointToPoint( g_jailData[ j ] [ E_RADIUS ], X, Y, Z, g_jailData[ j ] [ E_EXPLODE1_POS ] [ 0 ], g_jailData[ j ] [ E_EXPLODE1_POS ] [ 1 ], g_jailData[ j ] [ E_EXPLODE1_POS ] [ 2 ] ) || IsPointToPoint( g_jailData[ j ] [ E_RADIUS ], X, Y, Z, g_jailData[ j ] [ E_EXPLODE2_POS ] [ 0 ], g_jailData[ j ] [ E_EXPLODE2_POS ] [ 1 ], g_jailData[ j ] [ E_EXPLODE2_POS ] [ 2 ] ) && !g_jailData[ j ] [ E_BOMBED ] )
        {
            if ( g_iTime > g_jailData[ j ] [ E_TIMESTAMP ] )
            {
                g_jailData[ j ] [ E_BOMBED ] = true;
                g_jailData[ j ] [ E_TIMESTAMP ] = g_iTime + 300;

                GivePlayerExperience( playerid, E_ROBBERY, 2.0 );
                GivePlayerScore( playerid, 3 );
                GivePlayerWantedLevel( playerid, 24 );
                ach_HandleJailBlown( playerid );

                SendGlobalMessage( -1, ""COL_GREY"[SERVER]"COL_WHITE" %s(%d) has exploded the "COL_GREY"%s Jail{FFFFFF} and has freed its prisoners.", ReturnPlayerName( playerid ), playerid, returnCityName( g_jailData[ j ] [ E_CITY ] ) );
                massUnjailPlayers( g_jailData[ j ] [ E_CITY ] );
                break;
            }
        }
    }
    return 1;
}

/* ** Commands ** */
CMD:pdjail( playerid, params[ ] )
{
	erase( szBigString );

	new
		time = g_iTime;

	for( new i = 0; i < sizeof( g_jailData ); i++ ) {
		if ( g_jailData[ i ] [ E_TIMESTAMP ] < time )
			format( szBigString, sizeof( szBigString ), "%s"COL_GREY"%s"COL_WHITE"\t"COL_GREEN"Available To Raid!\n", szBigString, returnCityName( g_jailData[ i ] [ E_CITY ] ) );
		else
			format( szBigString, sizeof( szBigString ), "%s"COL_GREY"%s"COL_WHITE"\t%s\n", szBigString, returnCityName( g_jailData[ i ] [ E_CITY ] ), secondstotime( g_jailData[ i ] [ E_TIMESTAMP ] - time ) );
	}

	if ( g_alcatrazTimestamp < time )
		strcat( szBigString, ""COL_GREY"Alcatraz"COL_WHITE"\t"COL_GREEN"Available To Raid!" );
	else
		format( szBigString, sizeof( szBigString ), "%s"COL_GREY"Alcatraz"COL_WHITE"\t%s\n", szBigString, secondstotime( g_alcatrazTimestamp - time ) );

	ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_MSGBOX, "{FFFFFF}Police Jails", szBigString, "Okay", "" );
	return 1;
}

CMD:breakout( playerid, params[ ] )
{
	if ( p_Class[ playerid ] != CLASS_CIVILIAN ) return SendError( playerid, "This is restricted to civilians only." );
	if ( !IsPlayerJailed( playerid ) ) return SendError( playerid, "You can only use this while you're in jail!" );
	if ( IsPlayerAdminJailed( playerid ) ) return SendError( playerid, "You have been admin jailed, disallowing this." );
	if ( p_inAlcatraz{ playerid } ) return SendError( playerid, "You are unable to break out of Alcatraz. Ask a friend to blow you out." );
	if ( p_MetalMelter[ playerid ] > 0 )
	{
	    new
			iRandom = random( 101 );

		if ( p_MetalMelter[ playerid ]-- <= 3 )
			ShowPlayerHelpDialog( playerid, 2500, "You only have %d metal melters left!", p_MetalMelter[ playerid ] );

	    if ( iRandom < 80 ) {
		  	CallLocalFunction( "OnPlayerUnjailed", "dd", playerid, 2 );
		  	GivePlayerWantedLevel( playerid, 24 );
	    }
		else SendServerMessage( playerid, "You have failed to break out." );
	}
	else SendError( playerid, "You have no more Metal Melters available.");
	return 1;
}

/* ** Functions ** */
stock JailPlayer( playerid, seconds, admin = 0 )
{
	if ( playerid == INVALID_PLAYER_ID )
		return 0;

	static
	    Query[ 72 ], Float: armour;

	// Neccessary Checks
	if ( IsPlayerInMethlab( playerid ) ) {
		haltMethamphetamine( playerid, GetPlayerMethLabVehicle( playerid ) );
	}

	// Callback
	CallLocalFunction( "OnPlayerJailed", "d", playerid );

	// Neccessary Functions
	KillTimer 				( p_JailTimer[ playerid ] );
	KillTimer 				( p_CuffAbuseTimer[ playerid ] );
   	PlayerTextDrawSetString	( playerid, p_JailTimeTD[ playerid ], "_" );
	PlayerTextDrawShow		( playerid, p_JailTimeTD[ playerid ] );

	// Primary Jail Variables
	p_Jailed			{ playerid } = true;
	p_JailTime			[ playerid ] = seconds;
	p_AdminJailed		{ playerid } = admin;
	p_JailTimer			[ playerid ] = SetTimerEx( "Unjail", 950, true, "d", playerid );

	// External Variables to Jail (resetting)
	p_Cuffed			{ playerid } = false;
	p_InfectedHIV 		{ playerid } = false;
	p_Detained 		{ playerid } = false;
	Delete3DTextLabel	( p_DetainedLabel[ playerid ] );
	p_DetainedLabel	[ playerid ] = Text3D: INVALID_3DTEXT_ID;
	p_DetainedBy		[ playerid ] = INVALID_PLAYER_ID;

	#if defined __cloudy_event_system
	RemovePlayerFromEvent		( playerid, true );
	#endif
	CancelEdit 					( playerid );
	RemovePlayerStolensFromHands( playerid );
	StopPlayerUsingSlotMachine 	( playerid );
	RemoveEquippedOre			( playerid );
	ClearPlayerWantedLevel 		( playerid );
    ResetPlayerWeapons			( playerid );
	UntiePlayer					( playerid );
	jailDoors 					( playerid, false, true );
	SetPlayerPosToPrison 		( playerid );
	Player_CheckPokerGame 		( playerid, "Jailed" );

	#if defined __cloudy_event_system
	RemovePlayerFromEvent		( playerid, true );
	#endif

	// External Functions
	SetPlayerSpecialAction		( playerid, SPECIAL_ACTION_NONE );
	ClearAnimations 			( playerid );
	RemovePlayerAttachedObject	( playerid, 2 );
    SetPlayerHealth				( playerid, INVALID_PLAYER_ID );

    if ( ! IsPlayerAdminJailed( playerid ) ) {
		if ( p_MetalMelter[ playerid ] ) {
			ShowPlayerHelpDialog( playerid, 4000, "You can break yourself out of prison with ~p~/breakout." );
		} else {
			ShowPlayerHelpDialog( playerid, 4000, "You can buy metal melters at Supa Save or a 24/7 store." );
		}
    }

	format( Query, sizeof( Query ), "UPDATE `USERS` SET JAIL_TIME=%d,JAIL_ADMIN=%d WHERE `ID`=%d", seconds, admin, p_AccountID[ playerid ] );
	mysql_single_query( Query );

    if ( GetPlayerArmour( playerid, armour ) && armour ) {
    	SetPlayerArmour( playerid, 0.0 );
	}
	return 1;
}

function Unjail( playerid )
{
    static
	    Query[ 64 ];

	if ( !IsPlayerConnected( playerid ) ) return KillTimer( p_JailTimer[ playerid ] ), 0;

    p_JailTime[ playerid ] --;

    format( Query, sizeof( Query ), "Time Remaining:~n~%d seconds", p_JailTime[ playerid ] );
	PlayerTextDrawSetString( playerid, p_JailTimeTD[ playerid ], Query );

    if ( p_JailTime[ playerid ] < 1 )
	   	CallLocalFunction( "OnPlayerUnjailed", "dd", playerid, 0 );

    return 1;
}

stock SetPlayerPosToPrison( playerid )
{
	static const
		Float: sf_JailSpawnPoints[ ][ 3 ] =
		{
			{ 215.5644, 110.7332, 999.0156 },
			{ 219.4913, 110.9124, 999.0156 },
			{ 223.4386, 111.0879, 999.0156 },
			{ 227.4427, 111.2414, 999.0156 }
		},

		Float: lv_JailSpawnPoints[ ] [ 3 ] =
		{
			{ 198.6733, 162.2922, 1003.0300 },
			{ 197.4023, 174.4845, 1003.0234 },
			{ 193.2059, 174.6152, 1003.0234 }
		},

		Float: ls_JailSpawnPoints[ ] [ 3 ] =
		{
			{ 264.3201, 86.4325, 1001.0391 },
			{ 264.3130, 81.8108, 1001.0391 },
			{ 264.5371, 77.7982, 1001.0391 }
		},

		Float: alctrazSpawnPoints[ ] [ 3 ] =
		{
			{ -2005.1923, 1748.1976, 43.7386 },
			{ -2013.7557, 1783.2218, 43.7386 },
			{ -2049.5774, 1734.1851, 43.7386 }
		},

		Float: loadingHeight = 0.50
	;

	new
		iRandom;

	jailDoors				( playerid, false, true );
    SetPlayerFacingAngle 	( playerid, 0.0 );
	TogglePlayerControllable( playerid, 0 );
 	SetPlayerVirtualWorld 	( playerid, 30 );
	SetTimerEx 				( "ope_Unfreeze", 5000, false, "d", playerid );
	p_inAlcatraz 			{ playerid } = false;

	if ( p_JailTime[ playerid ] >= ALCATRAZ_REQUIRED_TIME )
	{
	    iRandom = random( sizeof( alctrazSpawnPoints ) );
	    SetPlayerPos 			( playerid, alctrazSpawnPoints[ iRandom ][ 0 ], alctrazSpawnPoints[ iRandom ][ 1 ], alctrazSpawnPoints[ iRandom ][ 2 ] + loadingHeight );
	 	SetPlayerInterior		( playerid, 0 );
	 	SetPlayerVirtualWorld 	( playerid, 0 );
		p_AlcatrazEscapeTS 		[ playerid ] = g_iTime + ALCATRAZ_TIME_PAUSE;
		p_inAlcatraz 			{ playerid } = true;
		return 1;
	}

	switch( getClosestPoliceStation( playerid ) )
	{
		case CITY_LV:
		{
		    iRandom = random( sizeof( lv_JailSpawnPoints ) );
		    SetPlayerPos( playerid, lv_JailSpawnPoints[ iRandom ][ 0 ], lv_JailSpawnPoints[ iRandom ][ 1 ], lv_JailSpawnPoints[ iRandom ][ 2 ] + loadingHeight );
		 	SetPlayerInterior( playerid, 3 );
		}
		case CITY_LS:
		{
		    iRandom = random( sizeof( ls_JailSpawnPoints ) );
		    SetPlayerPos( playerid, ls_JailSpawnPoints[ iRandom ][ 0 ], ls_JailSpawnPoints[ iRandom ][ 1 ], ls_JailSpawnPoints[ iRandom ][ 2 ] + loadingHeight );
		 	SetPlayerInterior( playerid, 6 );
		}
		default:
		{
		    iRandom = random( sizeof( sf_JailSpawnPoints ) );
		    SetPlayerPos( playerid, sf_JailSpawnPoints[ iRandom ][ 0 ], sf_JailSpawnPoints[ iRandom ][ 1 ], sf_JailSpawnPoints[ iRandom ][ 2 ] + loadingHeight );
		 	SetPlayerInterior( playerid, 10 );
		}
	}
    return 1;
}

stock jailMoveGate( playerid, city, bool: close = false, bool: alcatraz = false )
{
	static const
		Float: speed = 2.0;

	if ( !close && IsPlayerAdminJailed( playerid ) )
		return;

	if ( alcatraz )
	{
		if ( close ) MoveDynamicObject( p_AlcatrazObject[ playerid ], -2013.164184, 1827.123168, 41.506713, speed );
		else MoveDynamicObject( p_AlcatrazObject[ playerid ], -2013.164184, 1827.123168, 41.506713 - 10.0, speed );
	 	return;
	}

	switch( city )
	{
		case CITY_LV:
		{
			if ( close )
			{
				MoveDynamicObject( p_JailObjectLV[ playerid ] [ 0 ], 198.94980, 160.26476, 1003.26135, speed );
				MoveDynamicObject( p_JailObjectLV[ playerid ] [ 1 ], 192.95604, 177.08791, 1003.26215, speed );
				MoveDynamicObject( p_JailObjectLV[ playerid ] [ 2 ], 197.19141, 177.08476, 1003.26215, speed );
			}
			else
			{
				MoveDynamicObject( p_JailObjectLV[ playerid ] [ 0 ], 197.18980, 160.26480, 1003.26141, speed );
				MoveDynamicObject( p_JailObjectLV[ playerid ] [ 1 ], 194.69600, 177.08791, 1003.26208, speed );
				MoveDynamicObject( p_JailObjectLV[ playerid ] [ 2 ], 198.95140, 177.08479, 1003.26208, speed );
			}
		}
		case CITY_SF:
		{
			if ( close )
			{
				MoveDynamicObject( p_JailObjectSF[ playerid ] [ 0 ], 214.68274, 112.62182, 999.29553, speed );
				MoveDynamicObject( p_JailObjectSF[ playerid ] [ 1 ], 218.61810, 112.62180, 999.29547, speed );
				MoveDynamicObject( p_JailObjectSF[ playerid ] [ 2 ], 222.62241, 112.62180, 999.29547, speed );
				MoveDynamicObject( p_JailObjectSF[ playerid ] [ 3 ], 226.51570, 112.62180, 999.29547, speed );
			}
			else
			{
				MoveDynamicObject( p_JailObjectSF[ playerid ] [ 0 ], 216.44754, 112.61965, 999.29547, speed );
				MoveDynamicObject( p_JailObjectSF[ playerid ] [ 1 ], 220.40450, 112.62180, 999.29547, speed );
				MoveDynamicObject( p_JailObjectSF[ playerid ] [ 2 ], 224.40781, 112.62180, 999.29547, speed );
				MoveDynamicObject( p_JailObjectSF[ playerid ] [ 3 ], 228.27820, 112.62180, 999.29547, speed );
			}
		}
		case CITY_LS:
		{
			if ( close )
			{
				MoveDynamicObject( p_JailObjectLS[ playerid ] [ 0 ], 266.36481, 85.710700, 1001.27979, speed );
				MoveDynamicObject( p_JailObjectLS[ playerid ] [ 1 ], 266.36481, 81.211600, 1001.27979, speed );
				MoveDynamicObject( p_JailObjectLS[ playerid ] [ 2 ], 266.36481, 76.709470, 1001.27985, speed );
			}
			else
			{
				MoveDynamicObject( p_JailObjectLS[ playerid ] [ 0 ], 266.36481, 87.45710, 1001.27979, speed );
				MoveDynamicObject( p_JailObjectLS[ playerid ] [ 1 ], 266.36481, 82.95660, 1001.27979, speed );
				MoveDynamicObject( p_JailObjectLS[ playerid ] [ 2 ], 266.36481, 78.44830, 1001.27979, speed );
			}
		}
	}
}

stock jailDoors( playerid, remove = false, set_closed = true )
{
	if ( set_closed )
	{
		if ( IsValidDynamicObject( p_JailObjectLV[ playerid ] [ 0 ] ) || IsValidDynamicObject( p_JailObjectSF[ playerid ] [ 0 ] ) || IsValidDynamicObject( p_JailObjectLS[ playerid ] [ 0 ] ) )
		{
			SetDynamicObjectPos( p_JailObjectLV[ playerid ] [ 0 ], 198.94980, 160.26476, 1003.26135 );
			SetDynamicObjectPos( p_JailObjectLV[ playerid ] [ 1 ], 192.95604, 177.08791, 1003.26215 );
			SetDynamicObjectPos( p_JailObjectLV[ playerid ] [ 2 ], 197.19141, 177.08476, 1003.26215 );

			SetDynamicObjectPos( p_JailObjectSF[ playerid ] [ 0 ], 214.68274, 112.62182, 999.29553 );
			SetDynamicObjectPos( p_JailObjectSF[ playerid ] [ 1 ], 218.61810, 112.62180, 999.29547 );
			SetDynamicObjectPos( p_JailObjectSF[ playerid ] [ 2 ], 222.62241, 112.62180, 999.29547 );
			SetDynamicObjectPos( p_JailObjectSF[ playerid ] [ 3 ], 226.51570, 112.62180, 999.29547 );

			SetDynamicObjectPos( p_JailObjectLS[ playerid ] [ 0 ], 266.36481, 85.710700, 1001.27979 );
			SetDynamicObjectPos( p_JailObjectLS[ playerid ] [ 1 ], 266.36481, 81.211600, 1001.27979 );
			SetDynamicObjectPos( p_JailObjectLS[ playerid ] [ 2 ], 266.36481, 76.709470, 1001.27985 );

			SetDynamicObjectPos( p_AlcatrazObject[ playerid ], -2013.164184, 1827.123168, 41.506713 );
			return;
		}
	}

	if ( !remove )
	{
		if ( IsValidDynamicObject( p_JailObjectLV[ playerid ] [ 0 ] ) || IsValidDynamicObject( p_JailObjectSF[ playerid ] [ 0 ] ) || IsValidDynamicObject( p_JailObjectLS[ playerid ] [ 0 ] ) )
		{
			DestroyDynamicObject( p_JailObjectLV[ playerid ] [ 0 ] ), p_JailObjectLV[ playerid ] [ 0 ] = INVALID_OBJECT_ID;
			DestroyDynamicObject( p_JailObjectLV[ playerid ] [ 1 ] ), p_JailObjectLV[ playerid ] [ 1 ] = INVALID_OBJECT_ID;
			DestroyDynamicObject( p_JailObjectLV[ playerid ] [ 2 ] ), p_JailObjectLV[ playerid ] [ 2 ] = INVALID_OBJECT_ID;

			DestroyDynamicObject( p_JailObjectSF[ playerid ] [ 0 ] ), p_JailObjectSF[ playerid ] [ 0 ] = INVALID_OBJECT_ID;
			DestroyDynamicObject( p_JailObjectSF[ playerid ] [ 1 ] ), p_JailObjectSF[ playerid ] [ 1 ] = INVALID_OBJECT_ID;
			DestroyDynamicObject( p_JailObjectSF[ playerid ] [ 2 ] ), p_JailObjectSF[ playerid ] [ 2 ] = INVALID_OBJECT_ID;
			DestroyDynamicObject( p_JailObjectSF[ playerid ] [ 3 ] ), p_JailObjectSF[ playerid ] [ 3 ] = INVALID_OBJECT_ID;

			DestroyDynamicObject( p_JailObjectLS[ playerid ] [ 0 ] ), p_JailObjectLS[ playerid ] [ 0 ] = INVALID_OBJECT_ID;
			DestroyDynamicObject( p_JailObjectLS[ playerid ] [ 1 ] ), p_JailObjectLS[ playerid ] [ 1 ] = INVALID_OBJECT_ID;
			DestroyDynamicObject( p_JailObjectLS[ playerid ] [ 2 ] ), p_JailObjectLS[ playerid ] [ 2 ] = INVALID_OBJECT_ID;

			DestroyDynamicObject( p_AlcatrazObject[ playerid ] ), p_AlcatrazObject[ playerid ] = INVALID_OBJECT_ID;
		}

		p_JailObjectLV[ playerid ] [ 0 ] = CreateDynamicObject( 19303, 198.94980, 160.26476, 1003.26135, 0.00000, 0.00000, 0.00000, -1, -1, playerid );
		p_JailObjectLV[ playerid ] [ 1 ] = CreateDynamicObject( 19302, 192.95604, 177.08791, 1003.26215, 0.00000, 0.00000, 0.00000, -1, -1, playerid );
		p_JailObjectLV[ playerid ] [ 2 ] = CreateDynamicObject( 19302, 197.19141, 177.08476, 1003.26215, 0.00000, 0.00000, 0.00000, -1, -1, playerid );

		p_JailObjectSF[ playerid ] [ 0 ] = CreateDynamicObject( 19302, 214.68274, 112.62182, 999.295530, 0.00000, 0.00000, 0.00000, -1, -1, playerid );
		p_JailObjectSF[ playerid ] [ 1 ] = CreateDynamicObject( 19302, 218.61810, 112.62180, 999.295470, 0.00000, 0.00000, 0.00000, -1, -1, playerid );
		p_JailObjectSF[ playerid ] [ 2 ] = CreateDynamicObject( 19302, 222.62241, 112.62180, 999.295470, 0.00000, 0.00000, 0.00000, -1, -1, playerid );
		p_JailObjectSF[ playerid ] [ 3 ] = CreateDynamicObject( 19302, 226.51570, 112.62180, 999.295470, 0.00000, 0.00000, 0.00000, -1, -1, playerid );

		p_JailObjectLS[ playerid ] [ 0 ] = CreateDynamicObject( 19302, 266.36481, 85.710700, 1001.27979, 0.00000, 0.00000, 90.0000, -1, -1, playerid );
		p_JailObjectLS[ playerid ] [ 1 ] = CreateDynamicObject( 19302, 266.36481, 81.211600, 1001.27979, 0.00000, 0.00000, 90.0000, -1, -1, playerid );
		p_JailObjectLS[ playerid ] [ 2 ] = CreateDynamicObject( 19302, 266.36481, 76.709470, 1001.27985, 0.00000, 0.00000, 90.0000, -1, -1, playerid );

		p_AlcatrazObject[ playerid ] = CreateDynamicObject( 749, -2013.164184, 1827.123168, 41.506713, 11.800004, 0.000000, 0.000000, -1, -1, playerid );
		SetDynamicObjectMaterial( p_AlcatrazObject[ playerid ], 2, 9135, "vgseseabed", "vgs_rockmid1a", -47 );
		SetDynamicObjectMaterial( p_AlcatrazObject[ playerid ], 1, 0, "none", "none", 0 );
	}
	else
	{
		DestroyDynamicObject( p_JailObjectLV[ playerid ] [ 0 ] ), p_JailObjectLV[ playerid ] [ 0 ] = INVALID_OBJECT_ID;
		DestroyDynamicObject( p_JailObjectLV[ playerid ] [ 1 ] ), p_JailObjectLV[ playerid ] [ 1 ] = INVALID_OBJECT_ID;
		DestroyDynamicObject( p_JailObjectLV[ playerid ] [ 2 ] ), p_JailObjectLV[ playerid ] [ 2 ] = INVALID_OBJECT_ID;

		DestroyDynamicObject( p_JailObjectSF[ playerid ] [ 0 ] ), p_JailObjectSF[ playerid ] [ 0 ] = INVALID_OBJECT_ID;
		DestroyDynamicObject( p_JailObjectSF[ playerid ] [ 1 ] ), p_JailObjectSF[ playerid ] [ 1 ] = INVALID_OBJECT_ID;
		DestroyDynamicObject( p_JailObjectSF[ playerid ] [ 2 ] ), p_JailObjectSF[ playerid ] [ 2 ] = INVALID_OBJECT_ID;
		DestroyDynamicObject( p_JailObjectSF[ playerid ] [ 3 ] ), p_JailObjectSF[ playerid ] [ 3 ] = INVALID_OBJECT_ID;

		DestroyDynamicObject( p_JailObjectLS[ playerid ] [ 0 ] ), p_JailObjectLS[ playerid ] [ 0 ] = INVALID_OBJECT_ID;
		DestroyDynamicObject( p_JailObjectLS[ playerid ] [ 1 ] ), p_JailObjectLS[ playerid ] [ 1 ] = INVALID_OBJECT_ID;
		DestroyDynamicObject( p_JailObjectLS[ playerid ] [ 2 ] ), p_JailObjectLS[ playerid ] [ 2 ] = INVALID_OBJECT_ID;

		DestroyDynamicObject( p_AlcatrazObject[ playerid ] ), p_AlcatrazObject[ playerid ] = INVALID_OBJECT_ID;
	}
}
