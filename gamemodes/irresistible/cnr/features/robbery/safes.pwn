/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\robbery\safes.pwn
 * Purpose: safe robbery system (within stores)
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define MAX_ROBBERIES 				( 500 )
#define MAX_ROBBERY_WAIT            ( 300 )
#define MAX_DRILL_STRENGTH 			( 200 )
#define ROBBERY_MONEYCASE_BONUS		( 1.4 )

#define STATE_NONE 					( 0 )
#define STATE_ROBBED 				( 1 )
#define STATE_PICKED 				( 2 )

/* ** Macros ** */
#define IsPlayerRobbing(%0)			( p_UsingRobberySafe[ %0 ] != -1 )

/* ** Variables ** */
enum E_ROBBERY_SYSTEM
{
	E_NAME[ 32 ],       E_ROB_VALUE, 	 		E_WORLD,
	E_ROB_TIME, 		bool: E_ROBBED,     	E_STATE,

	E_SAFE,				E_SAFE_DOOR,			E_SAFE_MONEY,
	E_SAFE_LOOT,		E_ROBTIMER,				bool: E_OPEN,

	E_C4,				bool: E_C4_SLOT,
	E_DRILL,			E_DRILL_PLACER,			E_DRILL_EFFECT,

	Float: E_DOOR_X, 	Float: E_DOOR_Y, 		Float: E_DOOR_Z,
	Float: E_DOOR_ROT,

	Text3D: E_LABEL,	Float: E_MULTIPLIER, 	E_BUSINESS_ID
};

enum
{
	ROBBERY_TYPE_DRILL,
	ROBBERY_TYPE_C4,
	ROBBERY_TYPE_LABOR
};

new
	g_robberyData					[ MAX_ROBBERIES ] [ E_ROBBERY_SYSTEM ],
	p_drillStrength					[ MAX_PLAYERS ],

	Iterator:RobberyCount<MAX_ROBBERIES>
;

/* ** Forwards ** */
stock Float: distanceFromSafe( iPlayer, iRobbery, &Float: fDistance = Float: 0x7F800000 )
{
    static
    	Float: fX, Float: fY, Float: fZ;

    if ( ! Iter_Contains( RobberyCount, iRobbery ) )
    	return fDistance;

	if ( g_robberyData[ iRobbery ] [ E_WORLD ] != -1 && g_robberyData[ iRobbery ] [ E_WORLD ] != GetPlayerVirtualWorld( iPlayer ) )
		return fDistance;

    if ( GetDynamicObjectPos( g_robberyData[ iRobbery ] [ E_SAFE ], fX, fY, fZ ) )
		fDistance = GetPlayerDistanceFromPoint( iPlayer, fX, fY, fZ );

    return fDistance;
}

/* ** Hooks ** */
hook OnServerUpdate( )
{
	// Replenish Robberies
	foreach ( new robberyid : RobberyCount ) if ( g_iTime > g_robberyData[ robberyid ] [ E_ROB_TIME ] && g_robberyData[ robberyid ] [ E_ROBBED ] ) {
		setSafeReplenished( robberyid );
	}
	return 1;
}

hook OnPlayerRegister( playerid )
{
	p_drillStrength[ playerid ] = MAX_DRILL_STRENGTH;
	return 1;
}

hook OnPlayerKeyStateChange( playerid, newkeys, oldkeys )
{
	if ( PRESSED( KEY_WALK ) )
	{
		if ( ! IsPlayerInAnyVehicle( playerid ) )
	    {
	       	return SetPlayerHandleNearestSafe( playerid );
		}
	}
	return 1;
}

hook OnPlayerProgressUpdate( playerid, progressid, bool: canceled, params )
{
	if ( progressid == PROGRESS_ROBBING || progressid == PROGRESS_SAFEPICK )
	{
		new
			Float: distance = distanceFromSafe( playerid, params );

		new abort = ( !IsPlayerSpawned( playerid ) || !IsPlayerConnected( playerid ) || IsPlayerTied( playerid ) || IsPlayerInAnyVehicle( playerid ) || GetPlayerState( playerid ) == PLAYER_STATE_WASTED || IsPlayerAFK( playerid ) || params == -1 || distance > 1.5 || distance < 0.0 || canceled );

		if ( g_Debugging )
		{
			//SendClientMessageFormatted( playerid, COLOR_YELLOW, "distance: %f, params: %d, player: %d, jacked: %d", distance, params, p_UsingRobberySafe	[ playerid ], g_robberyData[ params ] [ E_STATE ] );
			new robberyid = params; printf("[DEBUG] [ROBBERY] [%d] Robbing/Picking [progress : %d, distance : %f, abort : %d] { open : %d, robbed : %d, c4: %d, drill : %d, dplacer : %d, deffect : %d, replenish : %d, raw ts : %d, current ts : %d, name : %s, state : %d }",
				robberyid, progressid, distance, abort,
				g_robberyData[ robberyid ] [ E_OPEN ], g_robberyData[ robberyid ] [ E_ROBBED ], g_robberyData[ robberyid ] [ E_C4 ],
				g_robberyData[ robberyid ] [ E_DRILL ], g_robberyData[ robberyid ] [ E_DRILL_PLACER ], g_robberyData[ robberyid ] [ E_DRILL_EFFECT ], g_robberyData[ robberyid ] [ E_ROB_TIME ] - g_iTime,
				g_robberyData[ robberyid ] [ E_ROB_TIME ], g_iTime, g_robberyData[ robberyid ] [ E_NAME ], g_robberyData[ robberyid ] [ E_STATE ] );
		}

		if ( abort )
		{
			RemovePlayerAttachedObject( playerid, 0 );
			g_robberyData 		[ params ] [ E_STATE ] = STATE_NONE;
			p_UsingRobberySafe	[ playerid ] = -1;
			return StopProgressBar( playerid ), 1;
		}

		// force angle
		SetPlayerFacingAngle( playerid, g_robberyData[ params ] [ E_DOOR_ROT ] );
	}
	return 1;
}

hook OnProgressCompleted( playerid, progressid, params )
{
	static
		Float: X, Float: Y, Float: Z;

	if ( progressid == PROGRESS_ROBBING )
	{
		new
			robberyid = params,
			Float: distance = distanceFromSafe( playerid, robberyid )
		;

		if ( robberyid != -1 && distance < 2.5 || distance > 0.0 )
		{
			if ( IsValidDynamicObject( g_robberyData[ robberyid ] [ E_SAFE_MONEY ] ) )
			{
		        if ( g_robberyData[ robberyid ] [ E_STATE ] != STATE_ROBBED ) return SendError( playerid, "This safe can no longer be robbed." );
		        else
		        {
				    static szLocation[ MAX_ZONE_NAME ], szCity[ MAX_ZONE_NAME ];

					ClearAnimations 	( playerid );
		        	g_robberyData 		[ robberyid ] [ E_STATE ] = STATE_NONE;
    				p_UsingRobberySafe 	[ playerid ] = -1;

    				new businessid = g_robberyData[ robberyid ] [ E_BUSINESS_ID ];

					if ( businessid == -1 && IsPlayerConnected( playerid ) && p_MoneyBag{ playerid } == true ) {
						new extra_loot = floatround( float( g_robberyData[ robberyid ] [ E_SAFE_LOOT ] ) * ROBBERY_MONEYCASE_BONUS );
						g_robberyData[ robberyid ] [ E_SAFE_LOOT ] = extra_loot;
					}

					if ( GetPlayerInterior( playerid ) != 0 )
					{
					    if ( p_LastEnteredEntrance[ playerid ] != -1 )
					  	{
					  		new id = p_LastEnteredEntrance[ playerid ];
						    Get2DCity( szCity, g_entranceData[ id ] [ E_EX ], g_entranceData[ id ] [ E_EY ], g_entranceData[ id ] [ E_EZ ] );
						    GetZoneFromCoordinates( szLocation, g_entranceData[ id ] [ E_EX ], g_entranceData[ id ] [ E_EY ], g_entranceData[ id ] [ E_EZ ] );
						    if ( !strmatch( szCity, "San Fierro" ) && !strmatch( szCity, "Las Venturas" ) && !strmatch( szCity, "Los Santos" ) ) g_robberyData[ robberyid ] [ E_SAFE_LOOT ] /= 2; // Halve Profit outside SF, LV & LS
							if ( strmatch( szCity, "Las Venturas" ) || strmatch( szCity, "Los Santos" ) ) g_robberyData[ robberyid ] [ E_SAFE_LOOT ] = floatround( g_robberyData[ robberyid ] [ E_SAFE_LOOT ] * 0.8 ); // Remove 20%
							SendGlobalMessage( COLOR_GOLD, "[ROBBERY]"COL_WHITE" %s(%d) has robbed "COL_GOLD"%s"COL_WHITE" from %s near %s in %s!", ReturnPlayerName( playerid ), playerid, cash_format( g_robberyData[ robberyid ] [ E_SAFE_LOOT ] ), g_robberyData[ robberyid ] [ E_NAME ], szLocation, szCity );
					    }
					    else if ( p_InBusiness[ playerid ] != -1 )
					    {
						    Get2DCity( szCity, g_businessData[ businessid ] [ E_X ], g_businessData[ businessid ] [ E_Y ], g_businessData[ businessid ] [ E_Z ] );
						    GetZoneFromCoordinates( szLocation, g_businessData[ businessid ] [ E_X ], g_businessData[ businessid ] [ E_Y ], g_businessData[ businessid ] [ E_Z ] );
							SendGlobalMessage( COLOR_GOLD, "[ROBBERY]"COL_WHITE" %s(%d) has robbed "COL_GOLD"%s"COL_WHITE" from %s"COL_WHITE" near %s in %s!", ReturnPlayerName( playerid ), playerid, cash_format( g_robberyData[ robberyid ] [ E_SAFE_LOOT ] ), g_robberyData[ robberyid ] [ E_NAME ], szLocation, szCity );
					    }
					    else
					    {
					    	SendServerMessage( playerid, "You've been kicked due to suspected teleport hacking." );
					    	KickPlayerTimed( playerid );
					    	return 1;
					    }
					}
					else
					{
						GetPlayerPos( playerid, X, Y, Z );
					    Get2DCity( szCity, X, Y, Z );
					    if ( !strmatch( szCity, "San Fierro" ) && !strmatch( szCity, "Las Venturas" ) && !strmatch( szCity, "Los Santos" ) ) g_robberyData[ robberyid ] [ E_SAFE_LOOT ] /= 2; // Halve Profit outside SF, LV & LS
						//if ( strmatch( szCity, "Las Venturas" ) || strmatch( szCity, "Los Santos" ) ) g_robberyData[ robberyid ] [ E_SAFE_LOOT ] = floatround( g_robberyData[ robberyid ] [ E_SAFE_LOOT ] * 0.75 ); // Remove 25%
						SendGlobalMessage( -1, ""COL_GOLD"[ROBBERY]"COL_WHITE" %s(%d) has robbed "COL_GOLD"%s"COL_WHITE" from %s in %s!", ReturnPlayerName( playerid ), playerid, cash_format( g_robberyData[ robberyid ] [ E_SAFE_LOOT ] ), g_robberyData[ robberyid ] [ E_NAME ], szCity );
					}

					GivePlayerScore( playerid, 2 );
					GivePlayerWantedLevel( playerid, 6 );
					GivePlayerExperience( playerid, E_ROBBERY );
		        	SplitPlayerCashForGang( playerid, float( g_robberyData[ robberyid ] [ E_SAFE_LOOT ] ) );
					g_robberyData[ robberyid ] [ E_SAFE_LOOT ] = 0;
					DestroyDynamicObject( g_robberyData[ robberyid ] [ E_SAFE_MONEY ] );
					g_robberyData[ robberyid ] [ E_SAFE_MONEY ] = INVALID_OBJECT_ID;
					g_robberyData[ robberyid ] [ E_ROBBED ] = true;
    				g_robberyData[ robberyid ] [ E_ROB_TIME ] = g_iTime + MAX_ROBBERY_WAIT;
           			//SendClientMessageToAdmins(COLOR_ORANGE,"%s(%d) robbed safe %d (%d sec)", ReturnPlayerName( playerid ), playerid, robberyid, g_robberyData[ robberyid ] [ E_ROB_TIME ] - gettime());

					if ( g_Debugging )
					{
						printf("[DEBUG] [ROBBERY] [%d] Store Robbed [progress : %d, distance : %f] { open : %d, robbed : %d, c4: %d, drill : %d, dplacer : %d, deffect : %d, replenish : %d, raw ts : %d, current ts : %d, name : %s, state : %d }",
							robberyid, progressid, distance,
							g_robberyData[ robberyid ] [ E_OPEN ], g_robberyData[ robberyid ] [ E_ROBBED ], g_robberyData[ robberyid ] [ E_C4 ],
							g_robberyData[ robberyid ] [ E_DRILL ], g_robberyData[ robberyid ] [ E_DRILL_PLACER ], g_robberyData[ robberyid ] [ E_DRILL_EFFECT ], g_robberyData[ robberyid ] [ E_ROB_TIME ] - g_iTime,
							g_robberyData[ robberyid ] [ E_ROB_TIME ], g_iTime, g_robberyData[ robberyid ] [ E_NAME ], g_robberyData[ robberyid ] [ E_STATE ] );
					}
					ach_HandlePlayerRobbery( playerid );
		        }
			}
		}
	}
	else if ( progressid == PROGRESS_SAFEPICK )
	{
		new
			robberyid = p_UsingRobberySafe[ playerid ],
			Float: distance = distanceFromSafe( playerid, robberyid )
		;

		if ( robberyid != -1 && 0.0 < distance <= 2.5 )
		{
			if ( !g_robberyData[ robberyid ] [ E_ROBBED ] && !IsValidDynamicObject( g_robberyData[ robberyid ] [ E_SAFE_MONEY ] ) )
			{
				static
					Float: pZ, Float: sZ;

		        if ( g_robberyData[ robberyid ] [ E_STATE ] != STATE_PICKED ) return SendError( playerid, "This safe can no longer be picked." );

		        p_UsingRobberySafe[ playerid ] = -1;
				RemovePlayerAttachedObject( playerid, 0 );
		        SendServerMessage( playerid, "You've opened the safe door." );

		        g_robberyData[ robberyid ] [ E_STATE ] 	  = STATE_NONE;
		        g_robberyData[ robberyid ] [ E_ROBTIMER ] = SetTimerEx( "onSafeBust", 1000, false, "dddd", playerid, robberyid, ROBBERY_TYPE_LABOR, 0 );

				if ( g_Debugging )
				{
					printf("[DEBUG] [ROBBERY] [%d] Safe Picked [progress : %d, distance : %f] { open : %d, robbed : %d, c4: %d, drill : %d, dplacer : %d, deffect : %d, replenish : %d, raw ts : %d, current ts : %d, name : %s, state : %d }",
						robberyid, progressid, distance,
						g_robberyData[ robberyid ] [ E_OPEN ], g_robberyData[ robberyid ] [ E_ROBBED ], g_robberyData[ robberyid ] [ E_C4 ],
						g_robberyData[ robberyid ] [ E_DRILL ], g_robberyData[ robberyid ] [ E_DRILL_PLACER ], g_robberyData[ robberyid ] [ E_DRILL_EFFECT ], g_robberyData[ robberyid ] [ E_ROB_TIME ] - g_iTime,
						g_robberyData[ robberyid ] [ E_ROB_TIME ], g_iTime, g_robberyData[ robberyid ] [ E_NAME ], g_robberyData[ robberyid ] [ E_STATE ] );
				}

       	 		GetDynamicObjectPos( g_robberyData[ robberyid ] [ E_SAFE ], sZ, sZ, sZ );
				GetPlayerPos( playerid, pZ, pZ, pZ );

        		if ( sZ < pZ )
					ApplyAnimation( playerid, "ROB_BANK", "CAT_Safe_Open", 4.1, 0, 0, 0, 0, 0, 0 );
			}
		}
	}
	return 1;
}

/* ** Functions ** */
stock CreateRobberyCheckpoint( szName[ 32 ], iRobValue, Float: fX, Float: fY, Float: fZ, Float: rotation, worldid )
{
	new Float: offsetX, Float: offsetY;
	new rID = Iter_Free( RobberyCount );

	if ( rID != ITER_NONE )
	{
		Iter_Add( RobberyCount, rID );

		//fX += 0.1 * floatsin( rotation, degrees );
		//fY += 0.1 * floatcos( rotation, degrees );
		g_robberyData[ rID ] [ E_SAFE ] = CreateDynamicObject( 19618, fX, fY, fZ, 0, 0, rotation, worldid );

		offsetX = 0.48 * floatsin( -( rotation + 119 ), degrees );
		offsetY = 0.48 * floatcos( -( rotation + 119 ), degrees );

		// SAFE DOOR
		g_robberyData[ rID ] [ E_DOOR_X ] = fX + offsetX;
		g_robberyData[ rID ] [ E_DOOR_Y ] = fY + offsetY;
		g_robberyData[ rID ] [ E_DOOR_Z ] = fZ;
		g_robberyData[ rID ] [ E_DOOR_ROT ] = rotation;

		g_robberyData[ rID ] [ E_SAFE_DOOR ] = CreateDynamicObject( 19619, fX + offsetX, fY + offsetY, fZ, 0, 0, rotation, worldid );

		// SetDynamicObjectMaterial( g_robberyData[ rID ] [ E_SAFE ], 5, 1829, "kbmiscfrn2", "man_mny1", 0 );
		// SetDynamicObjectMaterial( g_robberyData[ rID ] [ E_SAFE_DOOR ], 2, 0, "none", "none", -1 );

		g_robberyData[ rID ] [ E_LABEL ] = CreateDynamic3DTextLabel( sprintf( "%s\n"COL_WHITE"Left ALT To Crack Safe", szName ), COLOR_GREY, fX, fY, fZ, 15.0, .testlos = 0, .worldid = worldid );
	    format( g_robberyData[ rID ] [ E_NAME ], 32, "%s", szName );

	    g_robberyData[ rID ] [ E_WORLD ] 		= worldid;
	    g_robberyData[ rID ] [ E_ROB_VALUE ] 	= iRobValue;
	    g_robberyData[ rID ] [ E_ROBBED ] 		= false;
	    g_robberyData[ rID ] [ E_STATE ] 		= STATE_NONE;
	    g_robberyData[ rID ] [ E_ROBTIMER ] 	= 0xFFFF;
	    g_robberyData[ rID ] [ E_DRILL_PLACER ] = INVALID_PLAYER_ID;
	    g_robberyData[ rID ] [ E_DRILL_EFFECT ] = INVALID_OBJECT_ID;
	    g_robberyData[ rID ] [ E_MULTIPLIER ] 	= 1.0;
	    g_robberyData[ rID ] [ E_BUSINESS_ID ] 	= -1;
	    return rID;
	}
	else
	{
		static surplus;
		printf("Too many robberies created. Increase MAX_BUSINESSES to %d", ++surplus + MAX_BUSINESSES );
	}
   	return ITER_NONE; // if there's multiple, we will return none
}

stock CreateMultipleRobberies( szName[ 32 ], iRobValue, Float: fX, Float: fY, Float: fZ, Float: rotation, ... ) {
	for( new i = 6; i < numargs( ); i++ ) {
		new worldid = getarg( i );
		CreateRobberyCheckpoint( szName, iRobValue, fX, fY, fZ, rotation, worldid );
		if ( worldid == -1 ) break;
	}
}

stock getClosestRobberySafe( playerid, &Float: dis = 99999.99 )
{
	new
		Float: dis2,
		object = INVALID_OBJECT_ID,
		Float: X, Float: Y, Float: Z,
		world = GetPlayerVirtualWorld( playerid )
	;
	foreach(new i : RobberyCount)
	{
		if ( world != 0 && g_robberyData[ i ] [ E_WORLD ] != -1 && g_robberyData[ i ] [ E_WORLD ] != world ) continue;
		GetDynamicObjectPos( g_robberyData[ i ] [ E_SAFE ], X, Y, Z );
    	dis2 = GetPlayerDistanceFromPoint( playerid, X, Y, Z );
    	if ( dis2 < dis && dis2 != -1.00 ) {
    	    dis = dis2;
    	    object = i;
		}
	}
	return object;
}

stock GetEntranceClosestRobberySafe( entranceid, &Float: distance = FLOAT_INFINITY )
{
    new iCurrent = INVALID_PLAYER_ID, Float: fTmp;
	new world = GetEntranceWorld( entranceid );

	foreach ( new robberyid : RobberyCount )
	{
		if ( world != 0 && g_robberyData[ robberyid ] [ E_WORLD ] != -1 && g_robberyData[ robberyid ] [ E_WORLD ] != world )
			continue;

		static
			Float: X, Float: Y, Float: Z;

		if ( GetEntranceInsidePos( entranceid, X, Y, Z ) )
		{
	        if ( 0.0 < ( fTmp = GetDistanceBetweenPoints( g_robberyData[ robberyid ] [ E_DOOR_X ], g_robberyData[ robberyid ] [ E_DOOR_Y ], g_robberyData[ robberyid ] [ E_DOOR_Z ], X, Y, Z ) ) < distance ) // Y_Less mentioned there's no need to sqroot
	        {
	            distance = fTmp;
	            iCurrent = robberyid;
	        }
		}
    }
    return iCurrent;
}

stock GetXYInFrontOfSafe( robberyid, &Float: X, &Float: Y, &Float: Z, Float: distance = 1.1 ) // old 1.25
{
	static
		Float: iFloat;

	GetDynamicObjectPos( g_robberyData[ robberyid ] [ E_SAFE ], X, Y, Z );
	GetDynamicObjectRot( g_robberyData[ robberyid ] [ E_SAFE ], iFloat, iFloat, iFloat );

	X += distance * -floatsin( -iFloat, degrees );
	Y += distance * -floatcos( -iFloat, degrees );
}

stock AttachToRobberySafe( robberyid, playerid, type )
{
	if ( !IsPlayerConnected( playerid ) )
		return 0; // Not connected

	if (!Iter_Contains(RobberyCount, robberyid))
		return 0; // Invalid Robbery

	if ( ( g_robberyData[ robberyid ] [ E_C4_SLOT ] == true && type == ROBBERY_TYPE_DRILL ) || ( g_robberyData[ robberyid ] [ E_DRILL_PLACER ] != INVALID_PLAYER_ID && type == ROBBERY_TYPE_C4 ) )
		return 0; // Is occupied?

	if ( g_robberyData[ robberyid ] [ E_ROBBED ] || g_robberyData[ robberyid ] [ E_OPEN ] || g_robberyData[ robberyid ] [ E_ROBTIMER ] != 0xFFFF )
		return 0; // It's been robbed/opened!

	if ( p_Class[ playerid ] == CLASS_POLICE )
		return 0; // Not civilian

	if ( IsPlayerAttachedObjectSlotUsed( playerid, 0 ) || g_robberyData[ robberyid ] [ E_STATE ] )
		return 0; // Currently picking/being robbed/being picked

	//if ( g_robberyData[ robberyid ] [ E_BUSINESS_ID ] != -1 && ! g_businessData[ g_robberyData[ robberyid ] [ E_BUSINESS_ID ] ] [ E_BANK ] )
	//	return 0xBF; // has $0 in bank as biz

	if ( g_robberyData[ robberyid ] [ E_BUSINESS_ID ] != -1 && ! IsPlayerJob( playerid, JOB_BURGLAR ) )
		return 0; // must be burglar to rob safe

	if ( IsBusinessAssociate( playerid, g_robberyData[ robberyid ] [ E_BUSINESS_ID ] ) )
		return 0; // is biz associate

	static
		Float: fX, Float: fY, Float: fZ,
		Float: offsetX, Float: offsetY, Float: rotation
	;

	GetDynamicObjectPos( g_robberyData[ robberyid ] [ E_SAFE ], fX, fY, fZ );
	GetDynamicObjectRot( g_robberyData[ robberyid ] [ E_SAFE ], rotation, rotation, rotation );

	if ( g_Debugging )
	{
		printf("[DEBUG] [ROBBERY] [%d] AttachToRobberySafe( %d, %d, %d ) { open : %d, robbed : %d, c4: %d, drill : %d, dplacer : %d, deffect : %d, replenish : %d, raw ts : %d, current ts : %d, name : %s,  state : %d }",
				robberyid, robberyid, playerid, type,
				g_robberyData[ robberyid ] [ E_OPEN ], g_robberyData[ robberyid ] [ E_ROBBED ], g_robberyData[ robberyid ] [ E_C4 ],
				g_robberyData[ robberyid ] [ E_DRILL ], g_robberyData[ robberyid ] [ E_DRILL_PLACER ], g_robberyData[ robberyid ] [ E_DRILL_EFFECT ], g_robberyData[ robberyid ] [ E_ROB_TIME ] - g_iTime,
				g_robberyData[ robberyid ] [ E_ROB_TIME ], g_iTime, g_robberyData[ robberyid ] [ E_NAME ], g_robberyData[ robberyid ] [ E_STATE ] );
	}

	// start the drill/c4
	switch( type )
	{
		case ROBBERY_TYPE_DRILL:
		{
			if ( p_drillStrength[ playerid ] <= 0 )
				return 0;

			if ( g_robberyData[ robberyid ] [ E_DRILL_PLACER ] != INVALID_PLAYER_ID || IsValidDynamicObject( g_robberyData[ robberyid ] [ E_DRILL ] ) )
				return 0; // Valid drill/driller already on?

			// DRILL
			offsetX = 0.8 * floatsin( -( rotation + 200 ), degrees );
			offsetY = 0.8 * floatcos( -( rotation + 200 ), degrees );

			g_robberyData[ robberyid ] [ E_DRILL_PLACER ] = playerid;
			g_robberyData[ robberyid ] [ E_DRILL ] = CreateDynamicObject( 341, fX + offsetX, fY + offsetY, fZ, 0, 24.0, rotation + 90, g_robberyData[ robberyid ] [ E_WORLD ] );

			offsetX = -1.4 * floatsin( -( rotation + 170 ), degrees );
			offsetY = -1.4 * floatcos( -( rotation + 170 ), degrees );
			g_robberyData[ robberyid ] [ E_DRILL_EFFECT ] = CreateDynamicObject( 18718, fX + offsetX, fY + offsetY, fZ, 90, 0, rotation, g_robberyData[ robberyid ] [ E_WORLD ] );

			new
				Float: speed_up = GetPlayerLevel( playerid, E_ROBBERY ) * 37.5;

			if ( speed_up >= 37.5 ) {
				SendServerMessage( playerid, "You have attached your thermal drill (%0.1f%s faster) on this "COL_ORANGE"safe"COL_WHITE".", ( speed_up / 7500.0 ) * 100.0, "%%" );
			} else {
				SendServerMessage( playerid, "You have attached your thermal drill on this "COL_ORANGE"safe"COL_WHITE"." );
			}

			g_robberyData[ robberyid ] [ E_ROBTIMER ] = SetTimerEx( "onSafeBust", 7500 - floatround( speed_up ), false, "dddd", playerid, robberyid, type, 0 );

			p_drillStrength[ playerid ] -= 10;
			Streamer_Update( playerid );
			return 1;
		}

		case ROBBERY_TYPE_C4:
		{
			if ( g_robberyData[ robberyid ] [ E_C4_SLOT ] == false )
			{
				// slot 1 = orignally 185 degrees
				offsetX = 0.35 * floatsin( -( rotation + 180 ), degrees );
				offsetY = 0.35 * floatcos( -( rotation + 180 ), degrees );
				//case 0: g_robberyData[ robberyid ] [ E_C4 ] [ 0 ] = CreateDynamicObject( 363, fX + offsetX, fY + offsetY, fZ + 0.18534, 0, 0, rotation, g_robberyData[ robberyid ] [ E_WORLD ] );
				//case 1: g_robberyData[ robberyid ] [ E_C4 ] [ 1 ] = CreateDynamicObject( 363, fX + offsetX, fY + offsetY, fZ + 0.44483, 0, 90, rotation, g_robberyData[ robberyid ] [ E_WORLD ] );
				//case 2: g_robberyData[ robberyid ] [ E_C4 ] [ 2 ] = CreateDynamicObject( 363, fX + offsetX, fY + offsetY, fZ - 0.06090, 0, 90, rotation, g_robberyData[ robberyid ] [ E_WORLD ] );
				g_robberyData[ robberyid ] [ E_C4 ] = CreateDynamicObject( 363, fX + offsetX, fY + offsetY, fZ + 0.18534, 0, 0, rotation, g_robberyData[ robberyid ] [ E_WORLD ] );
				g_robberyData[ robberyid ] [ E_C4_SLOT ] = true;
				g_robberyData[ robberyid ] [ E_ROBTIMER ] = SetTimerEx( "onSafeBust", 960, false, "dddd", playerid, robberyid, type, 0 );
				return 1;
			}
		}
	}
	return 0;
}

stock RemoveRobberyAttachments( robberyid )
{
	if (!Iter_Contains(RobberyCount, robberyid))
		return; // Invalid Robbery

	DestroyDynamicObject( g_robberyData[ robberyid ] [ E_DRILL ] );
	DestroyDynamicObject( g_robberyData[ robberyid ] [ E_DRILL_EFFECT ] );
	DestroyDynamicObject( g_robberyData[ robberyid ] [ E_C4 ] );
	g_robberyData[ robberyid ] [ E_C4_SLOT ] = false;
	g_robberyData[ robberyid ] [ E_C4 ] = INVALID_OBJECT_ID;
	g_robberyData[ robberyid ] [ E_DRILL ] = INVALID_OBJECT_ID;
	g_robberyData[ robberyid ] [ E_DRILL_PLACER ] = INVALID_PLAYER_ID;
	g_robberyData[ robberyid ] [ E_DRILL_EFFECT ] = INVALID_OBJECT_ID;

	if ( g_Debugging )
	{
		printf("[DEBUG] [ROBBERY] [%d] RemoveRobberyAttachments { open : %d, robbed : %d, c4: %d, drill : %d, dplacer : %d, deffect : %d, replenish : %d, raw ts : %d, current ts : %d, name : %s, state : %d }",
				robberyid,
				g_robberyData[ robberyid ] [ E_OPEN ], g_robberyData[ robberyid ] [ E_ROBBED ], g_robberyData[ robberyid ] [ E_C4 ],
				g_robberyData[ robberyid ] [ E_DRILL ], g_robberyData[ robberyid ] [ E_DRILL_PLACER ], g_robberyData[ robberyid ] [ E_DRILL_EFFECT ], g_robberyData[ robberyid ] [ E_ROB_TIME ] - g_iTime,
				g_robberyData[ robberyid ] [ E_ROB_TIME ], g_iTime, g_robberyData[ robberyid ] [ E_NAME ], g_robberyData[ robberyid ] [ E_STATE ] );
	}
}

stock createRobberyLootInstance( playerid, robberyid, type )
{
	if (!Iter_Contains(RobberyCount, robberyid))
		return; // Invalid Robbery

	static Float: fX, Float: fY, Float: fZ, Float: fRotation;

	GetDynamicObjectPos( g_robberyData[ robberyid ] [ E_SAFE ], fX, fY, fZ );
	GetDynamicObjectRot( g_robberyData[ robberyid ] [ E_SAFE ], fRotation, fRotation, fRotation );

	// new businessid = g_robberyData[ robberyid ] [ E_BUSINESS_ID ];
	// new bool: business_robbery = businessid != -1;
	new Float: random_chance = fRandomEx( 0.0, 101.0 );

	/*if ( business_robbery )
	{
		switch ( g_businessData[ businessid ] [ E_SECURITY_LEVEL ] )
		{
			case 0: probability = 25.0;
			case 1: probability = 50.0;
			case 2: probability = 75.0;
			case 3: probability = 101.0; // must be over 100.0%
		}
	}*/

	// 100% success rate for newbs
	if ( p_Robberies[ playerid ] < 10.0 ) {
		random_chance = 100.0;
	}

	if ( GetPlayerLevel( playerid, E_POLICE ) >= 50.0 ) {
		random_chance = 100.0;
	}

	// level increase chance of success
	random_chance += GetPlayerLevel( playerid, E_ROBBERY ) * 0.2; // increase success rate by 0.2% per level

	// potential for a 20% fail rate
	if ( random_chance > 20.0 )
	{
		new Float: iRobAmount = float( g_robberyData[ robberyid ] [ E_ROB_VALUE ] );
		new Float: iLoot = fRandomEx( iRobAmount / 2.0, iRobAmount );

		// Apply multiplier
		iLoot *= g_robberyData[ robberyid ] [ E_MULTIPLIER ];
		g_robberyData[ robberyid ] [ E_MULTIPLIER ] = 1.0;

		// check if this is a business safe
		/*if ( business_robbery )
		{
			new Float: final_bank = float( g_businessData[ businessid ] [ E_BANK ] );
			switch ( g_businessData[ businessid ] [ E_SECURITY_LEVEL ] )
			{
				case 0: iLoot = floatround( final_bank * 0.75 );
				case 1: iLoot = floatround( final_bank * 0.5 );
				case 2: iLoot = floatround( final_bank * 0.25 );
				case 3: iLoot = 0; // floatround( final_bank * 0.1 );
			}

			// update business data
            g_businessData[ businessid ] [ E_BANK ] -= floatround( iLoot );
            UpdateBusinessData( businessid );

            // tax 10 percent for me
            iLoot *= 0.9;

            // add loot anyway under 3k
            if ( iLoot < 3000 ) iLoot = RandomEx( 1500, 3000 );
		}*/

		// Loose 50% because of impact
		// if ( type == ROBBERY_TYPE_C4 ) iLoot *= 0.50;

		// money offset
		fX += 0.07 * floatsin( -fRotation, degrees );
		fY += 0.07 * floatcos( -fRotation, degrees );

		DestroyDynamicObject( g_robberyData[ robberyid ] [ E_SAFE_MONEY ] );
		g_robberyData[ robberyid ] [ E_SAFE_MONEY ] = CreateDynamicObject( 2005, fX, fY, fZ - 0.1, 0, 0, g_robberyData[ robberyid ] [ E_DOOR_ROT ], g_robberyData[ robberyid ] [ E_WORLD ] );
		SetDynamicObjectMaterial( g_robberyData[ robberyid ] [ E_SAFE_MONEY ], 0, 2005, "cr_safe_cash", "man_mny2", 0xFF98FB98 );

		g_robberyData[ robberyid ] [ E_SAFE_LOOT ] = floatround( iLoot );
		if ( IsPlayerConnected( playerid ) ) Streamer_Update( playerid );
	}
	else
	{
		if ( IsPlayerConnected( playerid ) && p_Class[ playerid ] != CLASS_POLICE )
		{
		    new
				szLocation[ MAX_ZONE_NAME ],
				id = p_LastEnteredEntrance[ playerid ],
				business_id = g_robberyData[ robberyid ] [ E_BUSINESS_ID ]
			;

			if ( id != -1 ) // Sometimes the player isn't even inside a home.
				GetZoneFromCoordinates( szLocation, g_entranceData[ id ] [ E_EX ], g_entranceData[ id ] [ E_EY ], g_entranceData[ id ] [ E_EZ ] );
			else if ( business_id != -1 )
				GetZoneFromCoordinates( szLocation, g_businessData[ business_id ] [ E_X ], g_businessData[ business_id ] [ E_Y ], g_businessData[ business_id ] [ E_Z ] );

			if ( GetPlayerInterior( playerid ) != 0 )
		    	SendClientMessageToCops( -1, ""COL_BLUE"[ROBBERY]"COL_WHITE" %s has failed robbing %s"COL_WHITE" near %s.", ReturnPlayerName( playerid ), g_robberyData[ robberyid ] [ E_NAME ], szLocation );
			else
				SendClientMessageToCops( -1, ""COL_BLUE"[ROBBERY]"COL_WHITE" %s has failed robbing %s"COL_WHITE".", ReturnPlayerName( playerid ), g_robberyData[ robberyid ] [ E_NAME ] );

			SendClientMessage( playerid, -1, ""COL_GREY"[SERVER]"COL_WHITE" No loot, and the alarm went off. Cops have been alerted." );
			GivePlayerWantedLevel( playerid, 6 );
			CreateCrimeReport( playerid );
		}
		g_robberyData[ robberyid ] [ E_ROB_TIME ] = g_iTime + MAX_ROBBERY_WAIT;
		g_robberyData[ robberyid ] [ E_ROBBED ] = true;
	}

	if ( g_Debugging )
	{
		printf("[DEBUG] [ROBBERY] [%d] createRobberyLootInstance( %d, %d, %d ) { open : %d, robbed : %d, c4: %d, drill : %d, dplacer : %d, deffect : %d, replenish : %d, raw ts : %d, current ts : %d, name : %s, state : %d }",
				robberyid, playerid, robberyid, type,
				g_robberyData[ robberyid ] [ E_OPEN ], g_robberyData[ robberyid ] [ E_ROBBED ], g_robberyData[ robberyid ] [ E_C4 ],
				g_robberyData[ robberyid ] [ E_DRILL ], g_robberyData[ robberyid ] [ E_DRILL_PLACER ], g_robberyData[ robberyid ] [ E_DRILL_EFFECT ], g_robberyData[ robberyid ] [ E_ROB_TIME ] - g_iTime,
				g_robberyData[ robberyid ] [ E_ROB_TIME ], g_iTime, g_robberyData[ robberyid ] [ E_NAME ], g_robberyData[ robberyid ] [ E_STATE ] );
	}
}

function onSafeBust( playerid, robberyid, type, index )
{
	new
		bConnected = IsPlayerConnected( playerid );

	switch( type )
	{
		case ROBBERY_TYPE_C4:
		{
			if ( index < 3 )
			{
				if ( bConnected ) {
					PlayerPlaySound( playerid, 1056, g_robberyData[ robberyid ] [ E_DOOR_X ], g_robberyData[ robberyid ] [ E_DOOR_Y ], g_robberyData[ robberyid ] [ E_DOOR_Z ] );
	        		GameTextForPlayer( playerid, "~r~Fall back!~n~c4 in detonation!", 4000, 3 );
	        	}
				g_robberyData[ robberyid ] [ E_ROBTIMER ] = SetTimerEx( "onSafeBust", 960, false, "dddd", playerid, robberyid, type, index + 1 );
			}
			else
			{
				if ( bConnected ) {
        			GameTextForPlayer( playerid, "~g~We're in!", 4000, 3 );
					PlayerPlaySound( playerid, 1057, g_robberyData[ robberyid ] [ E_DOOR_X ], g_robberyData[ robberyid ] [ E_DOOR_Y ], g_robberyData[ robberyid ] [ E_DOOR_Z ] );
				}

				g_robberyData[ robberyid ] [ E_STATE ]    = STATE_NONE;
				g_robberyData[ robberyid ] [ E_ROBTIMER ] = 0xFFFF;

				RemoveRobberyAttachments( robberyid );
				ControlRobberySafe( robberyid, true );
				createRobberyLootInstance( playerid, robberyid, type );

				CreateExplosionEx( g_robberyData[ robberyid ] [ E_DOOR_X ], g_robberyData[ robberyid ] [ E_DOOR_Y ], g_robberyData[ robberyid ] [ E_DOOR_Z ], 12, 0.0, g_robberyData[ robberyid ] [ E_WORLD ], -1 );
			}
		}

		case ROBBERY_TYPE_DRILL, ROBBERY_TYPE_LABOR:
		{
			g_robberyData[ robberyid ] [ E_STATE ]    = STATE_NONE;
			g_robberyData[ robberyid ] [ E_ROBTIMER ] = 0xFFFF;
			RemoveRobberyAttachments( robberyid );
			ControlRobberySafe( robberyid, true );
			createRobberyLootInstance( playerid, robberyid, type );
			if ( type == ROBBERY_TYPE_LABOR ) SetTimerEx( "SetPlayerHandleNearestSafe", 1350, false, "d", playerid );
		}
	}

	if ( g_Debugging )
	{
		printf("[DEBUG] [ROBBERY] [%d] onSafeBust( %d, %d, %d, %d ) { open : %d, robbed : %d, c4: %d, drill : %d, dplacer : %d, deffect : %d, replenish : %d, raw ts : %d, current ts : %d, name : %s, state : %d }",
				robberyid, playerid, robberyid, type, index,
				g_robberyData[ robberyid ] [ E_OPEN ], g_robberyData[ robberyid ] [ E_ROBBED ], g_robberyData[ robberyid ] [ E_C4 ],
				g_robberyData[ robberyid ] [ E_DRILL ], g_robberyData[ robberyid ] [ E_DRILL_PLACER ], g_robberyData[ robberyid ] [ E_DRILL_EFFECT ], g_robberyData[ robberyid ] [ E_ROB_TIME ] - g_iTime,
				g_robberyData[ robberyid ] [ E_ROB_TIME ], g_iTime, g_robberyData[ robberyid ] [ E_NAME ], g_robberyData[ robberyid ] [ E_STATE ] );
	}
}

stock ControlRobberySafe( rID, bool: open )
{
	static
		Float: Z;

	if (Iter_Contains(RobberyCount, rID))
	{
		GetDynamicObjectPos( g_robberyData[ rID ] [ E_SAFE_DOOR ], Z, Z, Z );

		if ( g_robberyData[ rID ] [ E_OPEN ] == true && open == true )
		{
			printf("[GM:WARNING] Safe %d was stopped from opening twice.", rID );
			return;
		}

		if ( open )
		{
			// Must close it
			SetDynamicObjectPos( g_robberyData[ rID ] [ E_SAFE_DOOR ], g_robberyData[ rID ] [ E_DOOR_X ], g_robberyData[ rID ] [ E_DOOR_Y ], Z );
			SetDynamicObjectRot( g_robberyData[ rID ] [ E_SAFE_DOOR ], 0.0, 0.0, g_robberyData[ rID ] [ E_DOOR_ROT ] );
			SetTimerEx( "Physics_OpenSafe", 450, false, "dd", rID, 0 );
		}
		else
		{
			SetDynamicObjectPos( g_robberyData[ rID ] [ E_SAFE_DOOR ], g_robberyData[ rID ] [ E_DOOR_X ], g_robberyData[ rID ] [ E_DOOR_Y ], Z );
			SetDynamicObjectRot( g_robberyData[ rID ] [ E_SAFE_DOOR ], 0.0, 0.0, g_robberyData[ rID ] [ E_DOOR_ROT ] );
			g_robberyData[ rID ] [ E_OPEN ] = false;
		}

		if ( g_Debugging )
		{
			new robberyid = rID; printf("[DEBUG] [ROBBERY] [%d] ControlRobberySafe( %d, %d ) { open : %d, robbed : %d, c4: %d, drill : %d, dplacer : %d, deffect : %d, replenish : %d, raw ts : %d, current ts : %d, name : %s, state : %d }",
					robberyid, rID, open,
					g_robberyData[ robberyid ] [ E_OPEN ], g_robberyData[ robberyid ] [ E_ROBBED ], g_robberyData[ robberyid ] [ E_C4 ],
					g_robberyData[ robberyid ] [ E_DRILL ], g_robberyData[ robberyid ] [ E_DRILL_PLACER ], g_robberyData[ robberyid ] [ E_DRILL_EFFECT ], g_robberyData[ robberyid ] [ E_ROB_TIME ] - g_iTime,
					g_robberyData[ robberyid ] [ E_ROB_TIME ], g_iTime, g_robberyData[ robberyid ] [ E_NAME ], g_robberyData[ robberyid ] [ E_STATE ] );
		}
	}
}

function Physics_OpenSafe( handle, time_elapsed )
{
	// two seconds elapsed
	if ( time_elapsed >= 2000 ) {
		g_robberyData[ handle ] [ E_OPEN ] = true;
		return 1;
	}
	new Float: angle = 50.0 * floatlog( ( time_elapsed + 167.5 ) / 3.0, 2.72 ) - 200.0; // natural log (use https://www.geogebra.org/graphing)
	SetDynamicObjectRot( g_robberyData[ handle ] [ E_SAFE_DOOR ], 0.0, 0.0, g_robberyData[ handle ] [ E_DOOR_ROT ] - angle );
	return SetTimerEx( "Physics_OpenSafe", 15, false, "dd", handle, time_elapsed + 15 );
}

stock setSafeReplenished( rID )
{
	static
		Float: Z;

	if (Iter_Contains(RobberyCount, rID))
	{
		DestroyDynamicObject( g_robberyData[ rID ] [ E_SAFE_MONEY ] );

		g_robberyData[ rID ] [ E_ROBBED ] 		= false;
		g_robberyData[ rID ] [ E_ROBTIMER ] 	= 0xFFFF;
		g_robberyData[ rID ] [ E_DRILL_PLACER ] = INVALID_PLAYER_ID;
		g_robberyData[ rID ] [ E_DRILL_EFFECT ] = INVALID_OBJECT_ID;
		g_robberyData[ rID ] [ E_ROB_TIME ] 	= -1;
		g_robberyData[ rID ] [ E_ROBBED ] 		= false;
		g_robberyData[ rID ] [ E_STATE ] 		= STATE_NONE;
		g_robberyData[ rID ] [ E_OPEN ] 		= false;
		g_robberyData[ rID ] [ E_SAFE_MONEY ] 	= 0xFFFF;
		g_robberyData[ rID ] [ E_SAFE_LOOT ] 	= 0;

		StopDynamicObject( g_robberyData[ rID ] [ E_SAFE_DOOR ] );
		GetDynamicObjectPos( g_robberyData[ rID ] [ E_SAFE_DOOR ], Z, Z, Z );
		SetDynamicObjectPos( g_robberyData[ rID ] [ E_SAFE_DOOR ], g_robberyData[ rID ] [ E_DOOR_X ], g_robberyData[ rID ] [ E_DOOR_Y ], Z );
		SetDynamicObjectRot( g_robberyData[ rID ] [ E_SAFE_DOOR ], 0.0, 0.0, g_robberyData[ rID ] [ E_DOOR_ROT ] );

		if ( g_Debugging )
		{
			new robberyid = rID; printf("[DEBUG] [ROBBERY] [%d] setSafeReplenished( %d ) { open : %d, robbed : %d, c4: %d, drill : %d, dplacer : %d, deffect : %d, replenish : %d, raw ts : %d, current ts : %d, name : %s, state : %d }",
					robberyid, rID,
					g_robberyData[ robberyid ] [ E_OPEN ], g_robberyData[ robberyid ] [ E_ROBBED ], g_robberyData[ robberyid ] [ E_C4 ],
					g_robberyData[ robberyid ] [ E_DRILL ], g_robberyData[ robberyid ] [ E_DRILL_PLACER ], g_robberyData[ robberyid ] [ E_DRILL_EFFECT ], g_robberyData[ robberyid ] [ E_ROB_TIME ] - g_iTime,
					g_robberyData[ robberyid ] [ E_ROB_TIME ], g_iTime, g_robberyData[ robberyid ] [ E_NAME ], g_robberyData[ robberyid ] [ E_STATE ] );
		   	//SendClientMessageToAdmins( -1, ""COL_ORANGE"[DEBUG]"COL_GREY" Robbery "COL_GREY"%s(%d)"COL_GREY" has been replenished!", g_robberyData[ rID ] [ E_NAME ], rID );
		}
	   	return 1;
	}
	printf( "[WARNING] Invalid safe %d is being set for replenishment.", rID );
	return 0;
}

stock haltRobbery( rID )
{
	KillTimer( g_robberyData[ rID ] [ E_ROBTIMER ] );

	g_robberyData[ rID ] [ E_ROBTIMER ] = 0xFFFF;

	RemoveRobberyAttachments( rID );

	if ( g_Debugging )
	{
		printf("[DEBUG] [ROBBERY] [%d] haltRobbery( %d ) { open : %d, robbed : %d, c4: %d, drill : %d, dplacer : %d, deffect : %d, replenish : %d, raw ts : %d, current ts : %d, name : %s, state : %d }",
				robberyid, rID,
				g_robberyData[ robberyid ] [ E_OPEN ], g_robberyData[ robberyid ] [ E_ROBBED ], g_robberyData[ robberyid ] [ E_C4 ],
				g_robberyData[ robberyid ] [ E_DRILL ], g_robberyData[ robberyid ] [ E_DRILL_PLACER ], g_robberyData[ robberyid ] [ E_DRILL_EFFECT ], g_robberyData[ robberyid ] [ E_ROB_TIME ] - g_iTime,
				g_robberyData[ robberyid ] [ E_ROB_TIME ], g_iTime, g_robberyData[ robberyid ] [ E_NAME ], g_robberyData[ robberyid ] [ E_STATE ] );
	}
}

stock truncateDrills( playerid )
{
	foreach(new i : RobberyCount)
	{
		if ( g_robberyData[ i ] [ E_DRILL_PLACER ] == playerid )
			haltRobbery( i );
	}
}

function SetPlayerHandleNearestSafe( playerid )
{
	if ( ! IsPlayerConnected( playerid ) )
		return 0;

	new
		Float: X, Float: Y, Float: Z,
	    Float: distance = 99999.99,
		robberyid = getClosestRobberySafe( playerid, distance ),
	 	Float: sZ
	;

	if ( robberyid != INVALID_OBJECT_ID && distance < 1.5 )
	{
		if ( !g_robberyData[ robberyid ] [ E_STATE ] && !g_robberyData[ robberyid ] [ E_ROBBED ] && !IsValidDynamicObject( g_robberyData[ robberyid ] [ E_SAFE_MONEY ] ) )
		{
			if ( IsPlayerCuffed( playerid ) || IsPlayerTazed( playerid ) || IsPlayerTied( playerid ) ) return SendError( playerid, "You cannot pick the safe at the moment." );

			if ( p_drillStrength[ playerid ] )
			{
				if ( AttachToRobberySafe( robberyid, playerid, ROBBERY_TYPE_DRILL ) ) {
					p_UsingRobberySafe[ playerid ] = robberyid;
				}
			}
			else
			{
	       	 	if ( g_robberyData[ robberyid ] [ E_STATE ] ) return SendError( playerid, "This safe must be in an idle state to pick it." );
	       	 	//else if ( p_UsingRobberySafe[ playerid ] != -1 ) return SendError( playerid, "You're currently working on another safe." );
	       	 	else if ( g_robberyData[ robberyid ] [ E_OPEN ] ) return 1; //SendError( playerid, "This safe is open." );
	       	 	else if ( IsPlayerUsingAnimation( playerid ) ) return 1; //SendError( playerid, "You mustn't be using an animation." );
	       	 	else if ( g_robberyData[ robberyid ] [ E_ROBTIMER ] != 0xFFFF ) return SendError( playerid, "This safe is currently busy." );
	       	 	else if ( p_Class[ playerid ] == CLASS_POLICE ) return SendError( playerid, "You cannot pick this safe as a law enforcement officer." );
	       	 	// else if ( g_robberyData[ robberyid ] [ E_BUSINESS_ID ] != -1 && ! g_businessData[ g_robberyData[ robberyid ] [ E_BUSINESS_ID ] ] [ E_BANK ] ) return SendError( playerid, "There is nothing to rob from this business safe." );
	       	 	else if ( g_robberyData[ robberyid ] [ E_BUSINESS_ID ] != -1 && ! IsPlayerJob( playerid, JOB_BURGLAR ) ) return SendError( playerid, "You need to be a burglar to rob this safe." );
				else if ( IsBusinessAssociate( playerid, g_robberyData[ robberyid ] [ E_BUSINESS_ID ] ) ) return SendError( playerid, "You are an associate of this business, you cannot rob it!" );
	       	 	else if ( g_robberyData[ robberyid ] [ E_DRILL_PLACER ] != INVALID_PLAYER_ID || IsValidDynamicObject( g_robberyData[ robberyid ] [ E_DRILL ] ) ) return SendError( playerid, "The safe is currently occupied by a drill." );
	       	 	else
	       	 	{
	       	 		// TriggerRobberyForClerks( playerid, robberyid );

					p_UsingRobberySafe[ playerid ] = robberyid;
	       	 		GetDynamicObjectPos( g_robberyData[ robberyid ] [ E_SAFE ], X, Y, Z );
					SetPlayerFacingAngle( playerid, g_robberyData[ robberyid ] [ E_DOOR_ROT ] );
		        	GetXYInFrontOfSafe( robberyid, X, Y, sZ );
					GetPlayerPos( playerid, Z, Z, Z );
		        	SetPlayerPos( playerid, X, Y, Z );

		        	if ( sZ > Z )
						ApplyAnimation( playerid, "PED", "bomber", 4.1, 1, 1, 1, 1, 0, 1 );
					else
						ApplyAnimation( playerid, "BOMBER", "BOM_Plant", 4.1, 1, 1, 1, 1, 0, 1 );

					SetPlayerArmedWeapon( playerid, 0 );
					RemovePlayerAttachedObject( playerid, 0 );
		        	SetPlayerAttachedObject( playerid, 0, 18634, 6, 0.073999, 0.036999, 0.095999, 88.400009, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 );

					// trigger the robbery bot
					TriggerRobberyForClerks( playerid, robberyid );

					new
						Float: speed_up = GetPlayerLevel( playerid, E_ROBBERY ) * 50.0;

					if ( speed_up >= 50.0 ) {
						SendClientMessageFormatted( playerid, -1, ""COL_GOLD"[ROBBERY]"COL_WHITE" You are now picking a safe (%0.1f%s faster), please wait until you've finished. Press C to stop.", ( speed_up / 10000.0 ) * 100.0, "%%" );
					} else {
						SendClientMessage( playerid, -1, ""COL_GOLD"[ROBBERY]"COL_WHITE" You are now picking a safe, please wait until you've finished. Press C to stop." );
					}

					g_robberyData[ robberyid ] [ E_STATE ] = STATE_PICKED;
					ShowProgressBar( playerid, "Picking Safe", PROGRESS_SAFEPICK, 10000 - floatround( speed_up ), COLOR_WANTED12, robberyid );
				}
			}
		}

		if ( IsValidDynamicObject( g_robberyData[ robberyid ] [ E_SAFE_MONEY ] ) )
		{
	    	if ( g_robberyData[ robberyid ] [ E_STATE ] ) return SendError( playerid, "This safe must be in an idle state to rob it." );
	       	else if ( p_Class[ playerid ] == CLASS_POLICE ) return SendError( playerid, "You cannot rob this safe as a law enforcement officer." );
	        else
	        {
				p_UsingRobberySafe[ playerid ] = robberyid;
	   	 		GetDynamicObjectPos( g_robberyData[ robberyid ] [ E_SAFE ], X, Y, Z );
				SetPlayerFacePoint( playerid, X, Y );
	        	GetXYInFrontOfSafe( robberyid, X, Y, sZ );
				GetPlayerPos( playerid, Z, Z, Z );
	        	SetPlayerPos( playerid, X, Y, Z );

	        	if ( sZ > Z )
					ApplyAnimation( playerid, "CARRY", "liftup105", 4.0, 1, 0, 0, 1, 0 );
				else
					ApplyAnimation( playerid, "ROB_BANK", "CAT_Safe_Rob", 4.0, 1, 0, 0, 1, 0 );

	        	g_robberyData[ robberyid ] [ E_STATE ] = STATE_ROBBED;

				ShowProgressBar( playerid, "Robbing Safe", PROGRESS_ROBBING, 2500, COLOR_YELLOW, robberyid );
	        }
		}
	}
	return 1;
}

stock GetPlayerDrillStrength( playerid ) return p_drillStrength[ playerid ];

stock SetPlayerDrillStrength( playerid, strength ) {
	p_drillStrength[ playerid ] = strength;
}