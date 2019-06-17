/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\gangs\turfs.pwn
 * Purpose: turfing module for gangs
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#if defined MAX_FACILITIES
	#define MAX_TURFS 				( sizeof( g_gangzoneData ) + MAX_FACILITIES )
#else
	#define MAX_TURFS 				( sizeof( g_gangzoneData ) )
#endif

#define COLOR_GANGZONE              0x00000080

#define INVALID_GANG_TURF 			( -1 )

#define TAKEOVER_NEEDED_PEOPLE		( 1 )

/*
	Mean (μ): 61551.012315113
	Median: 38190.51
	Modes: 36520.39 56000.00
	Lowest value: 1561.59
	Highest value: 663634.31
	Range: 662072.72
	Interquartile range: 54438.43
	First quartile: 19224.91
	Third quartile: 73663.34
	Variance (σ2): 5620059337.0135
	Standard deviation (σ): 74967.055010941
	Quartile deviation: 27219.215
	Mean absolute deviation (MAD): 47203.259159645
*/

#define TURF_SIZE_SMALL 			19224.91
#define TURF_SIZE_LARGE 			73663.34

/* ** Variables ** */
enum e_GANG_ZONE_DATA
{
	E_NAME[ 16 ],
	Float: E_MIN_X,
	Float: E_MIN_Y,
	Float: E_MAX_X,
	Float: E_MAX_Y,
	Float: E_SIZE,
	E_CITY
};

new const
	g_gangzoneData[ ] [ e_GANG_ZONE_DATA ] =
	{
		{ "SF-CITY", -2076.0, 1036.5, -1873.0, 1088.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -2014.0, 937.5, -1873.0, 1036.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -2014.0, 829.5, -1886.0, 937.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -1873.0, 937.5, -1787.0, 1112.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -2014.0, 719.5, -1886.0, 829.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -1886.0, 829.5, -1788.0, 937.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -1886.0, 719.5, -1788.0, 829.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -1788.0, 829.5, -1723.0, 937.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -1723.0, 829.5, -1642.0, 937.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -1642.0, 829.5, -1564.0, 937.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -1564.0, 828.5, -1421.0, 1015.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -1667.0, 720.5, -1563.0, 829.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -1788.0, 719.5, -1667.0, 829.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -1787.0, 935.5, -1704.0, 1037.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -1787.0, 1037.5, -1704.0, 1112.5, TURF_SIZE_LARGE, CITY_SF },
		{ "SF-CITY", -2130.0, 816.5, -2014.0, 1036.5, TURF_SIZE_LARGE, CITY_SF }
	}
;

/* ** Variables ** */
enum E_TURF_ZONE_DATA {
	E_ID,

	E_OWNER,
	E_COLOR,

	E_AREA,
	E_FACILITY_GANG
};

new
	g_gangTurfData					[ MAX_TURFS ] [ E_TURF_ZONE_DATA ],
	Iterator: turfs 				< MAX_TURFS >,

	g_gangzoneAttacker				[ MAX_TURFS ] = { INVALID_GANG_ID, ... },
	g_gangzoneAttackCount           [ MAX_TURFS ],
	g_gangzoneAttackTimeout			[ MAX_TURFS ],

	p_TurfProgressTimer				[ MAX_PLAYERS ] = { -1, ... },

	PlayerText: p_playerTurfTitle 	[ MAX_PLAYERS ] = { PlayerText: INVALID_TEXT_DRAW, ... },
	PlayerBar: p_playerTurfProgress [ MAX_PLAYERS ]
;

/* ** Forwards ** */
forward OnPlayerUpdateGangZone( playerid, zoneid );

/* ** Hooks ** */
hook OnGameModeInit( )
{
	/* ** Gangzone Allocation ** */
	for ( new i = 0; i < sizeof( g_gangzoneData ); i++ ) {
		Turf_Create( g_gangzoneData[ i ] [ E_MIN_X ], g_gangzoneData[ i ] [ E_MIN_Y ], g_gangzoneData[ i ] [ E_MAX_X ], g_gangzoneData[ i ] [ E_MAX_Y ], INVALID_GANG_ID, COLOR_GANGZONE );
	}
	return 1;
}

hook OnPlayerConnect( playerid )
{
 	p_playerTurfProgress[ playerid ] = CreatePlayerProgressBar( playerid, 47.000000, 263.000000, 82.500000, 7.199999, COLOR_GOLD, 100.0000, 0 ); // -2007060993
 	
	p_playerTurfTitle[ playerid ] = CreatePlayerTextDraw( playerid, 86.000000, 248.000000, "Control the area" );
	PlayerTextDrawAlignment( playerid, p_playerTurfTitle[ playerid ], 2 );
	PlayerTextDrawBackgroundColor( playerid, p_playerTurfTitle[ playerid ], 255 );
	PlayerTextDrawFont( playerid, p_playerTurfTitle[ playerid ], 1 );
	PlayerTextDrawLetterSize( playerid, p_playerTurfTitle[ playerid ], 0.240000, 1.200000 );
	PlayerTextDrawColor( playerid, p_playerTurfTitle[ playerid ], COLOR_GOLD );
	PlayerTextDrawSetOutline( playerid, p_playerTurfTitle[ playerid ], 1 );
	PlayerTextDrawSetProportional( playerid, p_playerTurfTitle[ playerid ], 1 );
 	return 1;
}

hook OnServerUpdate( )
{
	new
		oCount = 0;

    foreach ( new z : turfs )
	{
	    if ( g_gangzoneAttacker[ z ] != INVALID_GANG_ID )
	    {
	    	new
	    		attacker_member_count = GetPlayersInGangZone( z, g_gangzoneAttacker[ z ] );

	        if ( attacker_member_count >= TAKEOVER_NEEDED_PEOPLE )
	        {
	          	if ( g_gangTurfData[ z ] [ E_OWNER ] != INVALID_GANG_ID )
			      	oCount = GetPlayersInGangZone( z, g_gangTurfData[ z ] [ E_OWNER ] );

				new
					attacker_time_required = -10 * ( attacker_member_count - TAKEOVER_NEEDED_PEOPLE ) + ( g_gangTurfData[ z ] [ E_FACILITY_GANG ] == INVALID_GANG_ID ? 60 : 120 );

			   	// minimum of 20 seconds
				if ( attacker_time_required < 20 )
					attacker_time_required = 20;

	            if ( g_gangzoneAttackCount[ z ] < attacker_time_required && oCount == 0 )
	            {
	            	foreach ( new i : Player ) if ( p_Class[ i ] != CLASS_POLICE && p_GangID[ i ] == g_gangzoneAttacker[ z ] && IsPlayerInDynamicArea( i, g_gangTurfData[ z ] [ E_AREA ] ) )
	            	{
						if ( p_WantedLevel[ i ] < 2 ) GivePlayerWantedLevel( i, 2 - p_WantedLevel[ i ] );
	            		
						ShowPlayerControlArea( i, 1500, g_gangData[ g_gangzoneAttacker[ z ] ] [ E_COLOR ], attacker_time_required, g_gangzoneAttackCount[ z ] );

	            		//ShowPlayerHelpDialog( i, 1500, "~r~Control~w~ the area for %d seconds!", attacker_time_required - g_gangzoneAttackCount[ z ] );
	            	}
	            	g_gangzoneAttackCount[ z ] ++;
                 	g_gangzoneAttackTimeout[ z ] = 0;
					continue;
				}
	            else if ( g_gangzoneAttackCount[ z ] >= attacker_time_required )
	            {
	            	static szLocation[ MAX_ZONE_NAME ], szCity[ MAX_ZONE_NAME ];

                 	new earned_money = 0;
                 	new owner_gang = g_gangTurfData[ z ] [ E_OWNER ];
                 	new attacker_gang = g_gangzoneAttacker[ z ];

					new Float: min_x, Float: min_y;
					Streamer_GetFloatData( STREAMER_TYPE_AREA, g_gangTurfData[ z ] [ E_AREA ], E_STREAMER_MIN_X, min_x );
					Streamer_GetFloatData( STREAMER_TYPE_AREA, g_gangTurfData[ z ] [ E_AREA ], E_STREAMER_MIN_Y, min_y );

				    Get2DCity 				( szCity, min_x, min_y );
				    GetZoneFromCoordinates 	( szLocation, min_x, min_y );

	                GangZoneStopFlashForAll	( g_gangTurfData[ z ] [ E_ID ] );
					GangZoneShowForAll 		( g_gangTurfData[ z ] [ E_ID ], setAlpha( g_gangData[ g_gangzoneAttacker[ z ] ] [ E_COLOR ], 0x80 ) );

					g_gangTurfData[ z ] [ E_COLOR ] = setAlpha( g_gangData[ g_gangzoneAttacker[ z ] ] [ E_COLOR ], 0x80 );
	                g_gangTurfData[ z ] [ E_OWNER ] = g_gangzoneAttacker[ z ];

                 	g_gangzoneAttacker 		[ z ] = INVALID_GANG_ID;
	                g_gangzoneAttackCount	[ z ] = 0;
                 	g_gangzoneAttackTimeout	[ z ] = 0;

                 	// Money Grub
                 	if ( Iter_Contains( gangs, owner_gang ) )
					{
						new afk_opmembers, online_opmembers = GetOnlineGangMembers( owner_gang, .afk_members = afk_opmembers );
						new zone_money = Turf_GetProfitability( z, online_opmembers - afk_opmembers );

						if ( g_gangData[ owner_gang ] [ E_BANK ] > zone_money )
						{
							// deduct from gang bank and give to op, take 10% as fee
				            g_gangData[ owner_gang ] [ E_BANK ] -= zone_money;
				            SaveGangData( owner_gang );

				           	earned_money = floatround( float( zone_money ) * 0.9 );
				            g_gangData[ attacker_gang ] [ E_BANK ] += earned_money;
				       	}

				      	// credit respect
						g_gangData[ attacker_gang ] [ E_RESPECT ] ++;
						SaveGangData( attacker_gang );
					}

					// Alert gang
					if ( earned_money ) {
						SendClientMessageToGang	( attacker_gang, g_gangData[ attacker_gang ] [ E_COLOR ], "[GANG]{FFFFFF} We have captured a turf near %s in %s and earned "COL_GOLD"%s"COL_WHITE"!", szLocation, szCity, cash_format( earned_money ) );
					} else {
						SendClientMessageToGang	( attacker_gang, g_gangData[ attacker_gang ] [ E_COLOR ], "[GANG]{FFFFFF} We have captured a turf near %s in %s!", szLocation, szCity );
					}

                 	// Give Gangmembers XP & Wanted
					foreach(new d : Player)
					{
						new in_area = IsPlayerInDynamicArea( d, g_gangTurfData[ z ] [ E_AREA ] );

						if ( in_area )
							PlayerTextDrawSetString( d, g_ZoneOwnerTD[ d ], sprintf( "~r~~h~(%s)~n~~w~~h~%s", g_gangTurfData[ z ] [ E_FACILITY_GANG ] != INVALID_GANG_ID ? ( "FACILITY" ) : ( "TERRITORY" ), ReturnGangName( attacker_gang ) ) );

						if ( IsPlayerSpawned( d ) && ! IsPlayerAFK( d ) && p_Class[ d ] == CLASS_CIVILIAN && p_GangID[ d ] == attacker_gang && ! IsPlayerInPaintBall( d ) ) {
							if ( in_area ) {
								GivePlayerScore( d, 2 );
								GivePlayerWantedLevel( d, 6 );
							}
							PlayerPlaySound( d, 36205, 0.0, 0.0, 0.0 );
						}
					}
				}
				else if ( g_gangTurfData[ z ] [ E_OWNER ] != INVALID_GANG_ID && oCount > 0 ) {
	            	foreach ( new i : Player ) if ( p_GangID[ i ] != INVALID_GANG_ID && IsPlayerInDynamicArea( i, g_gangTurfData[ z ] [ E_AREA ] ) ) {
	            		// message the attacker that they gotta attack
	            		if ( p_GangID[ i ] == g_gangzoneAttacker[ z ] ) {
		            		ShowPlayerHelpDialog( i, 1500, "~r~Kill~w~ the %d gang member%s in the area!", oCount, oCount == 1 ? ( "" ) : ( "s" ) );
		            	}
		            	// message the defender
		            	else if ( p_GangID[ i ] == g_gangTurfData[ z ] [ E_OWNER ] ) {
		            		ShowPlayerHelpDialog( i, 1500, "~b~Defend~w~ the area from the %d enemy gang member%s!", attacker_member_count, attacker_member_count == 1 ? ( "" ) : ( "s" ) );
		            	}
		            }
				}
	        }
	        else
	        {
	        	if ( ! g_gangzoneAttackTimeout[ z ] ) {
	        		g_gangzoneAttackTimeout[ z ] = g_iTime + 10;
                    SendClientMessageToGang( g_gangzoneAttacker[ z ], g_gangData[ g_gangzoneAttacker[ z ] ] [ E_COLOR ], "[GANG]{FFFFFF} You have 10 seconds to get back in the area until the turf war is stopped!" );
	        	}
	        	else if ( g_iTime >= g_gangzoneAttackTimeout[ z ] )
				{
		         	g_gangzoneAttackCount[ z ] = 0;
		         	g_gangzoneAttackTimeout[ z ] = 0;
		     		GangZoneStopFlashForAll( g_gangTurfData[ z ] [ E_ID ] );
		            g_gangzoneAttacker[ z ] = INVALID_GANG_ID;
				}
	        }
		}
	}
	return 1;
}

hook OnServerGameDayEnd( )
{
	// payday for gangs holding turfs
	foreach ( new g : gangs )
	{
		new
			afk_members, online_members = GetOnlineGangMembers( g, .afk_members = afk_members );

		if ( online_members >= TAKEOVER_NEEDED_PEOPLE )
		{
			new
				profit = 0;

			foreach( new zoneid : turfs ) if ( g_gangTurfData[ zoneid ] [ E_OWNER ] != INVALID_GANG_ID && g_gangTurfData[ zoneid ] [ E_OWNER ] == g )
			{
				// facilities will not pay out respect
				if ( g_gangTurfData[ zoneid ] [ E_FACILITY_GANG ] == INVALID_GANG_ID ) {
					g_gangData[ g ] [ E_RESPECT ] ++;
				}

				// accumulate profit
				profit += Turf_GetProfitability( zoneid, online_members - afk_members );
			}

			GiveGangCash( g, profit );

	    	if ( profit > 0 ) {
	    		SaveGangData( g );
	    		SendClientMessageToGang( g, g_gangData[ g ] [ E_COLOR ], "[GANG] "COL_GOLD"%s"COL_WHITE" has been earned from territories and deposited in the gang bank account.", cash_format( profit ) );
	    	}
		}
	}
	return 1;
}

hook OnPlayerEnterDynArea( playerid, areaid )
{
	if ( ! IsPlayerNPC( playerid ) )
	{
		new
			first_turf = Turf_GetFirstTurf( playerid );

		CallLocalFunction( "OnPlayerUpdateGangZone", "dd", playerid, first_turf );
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerSpawn( playerid )
{
	// Gang Zones
	foreach( new zoneid : turfs )
	{
    	// resume flashing if gang war
    	if ( g_gangzoneAttacker[ zoneid ] != INVALID_GANG_ID && Iter_Contains( gangs, g_gangzoneAttacker[ zoneid ] ) ) {
    		GangZoneFlashForPlayer( playerid, g_gangTurfData[ zoneid ] [ E_ID ], setAlpha( g_gangData[ g_gangzoneAttacker[ zoneid ] ] [ E_COLOR ], 0x80 ) );
    	} else {
	        GangZoneShowForPlayer( playerid, g_gangTurfData[ zoneid ] [ E_ID ], g_gangTurfData[ zoneid ] [ E_COLOR ] );
    	}
	}
	return 1;
}

hook OnPlayerUnloadTextdraws( playerid )
{
	PlayerTextDrawHide( playerid, g_ZoneOwnerTD[ playerid ] );
	return 1;
}

hook OnPlayerLoadTextdraws( playerid )
{
	PlayerTextDrawShow( playerid, g_ZoneOwnerTD[ playerid ] );
	return 1;
}

hook OnPlayerLeaveDynArea( playerid, areaid )
{
	if ( ! IsPlayerNPC( playerid ) )
	{
		new
			total_areas = GetPlayerNumberDynamicAreas( playerid );

		// reduced to another area
		if ( total_areas )
		{
			new
				first_turf = Turf_GetFirstTurf( playerid );

			CallLocalFunction( "OnPlayerUpdateGangZone", "dd", playerid, first_turf );
		}

		// if the player is in no areas, then they left
		else CallLocalFunction( "OnPlayerUpdateGangZone", "dd", playerid, INVALID_GANG_TURF );
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

public OnPlayerUpdateGangZone( playerid, zoneid )
{
	if ( ! IsPlayerMovieMode( playerid ) )
	{
		if ( zoneid == INVALID_GANG_TURF )
			return PlayerTextDrawSetString( playerid, g_ZoneOwnerTD[ playerid ], "_" );

		if ( p_GangID[ playerid ] != INVALID_GANG_ID && g_gangTurfData[ zoneid ] [ E_OWNER ] == INVALID_GANG_ID )
		 	ShowPlayerHelpDialog( playerid, 6000, "You can take over this turf by typing ~g~/takeover" );

		PlayerTextDrawSetString( playerid, g_ZoneOwnerTD[ playerid ], sprintf( "~r~~h~(%s)~n~~w~~h~%s", g_gangTurfData[ zoneid ] [ E_FACILITY_GANG ] != INVALID_GANG_ID ? ( "FACILITY" ) : ( "TERRITORY" ), g_gangTurfData[ zoneid ] [ E_OWNER ] == -1 ? ( "Uncaptured" ) : ( ReturnGangName( g_gangTurfData[ zoneid ] [ E_OWNER ] ) ) ) );
	}
	return 1;
}

/* ** Commands ** */
CMD:takeover( playerid, params[ ] )
{
	if ( p_GangID[ playerid ] == INVALID_GANG_ID )
		return SendError( playerid, "You are not in any gang." );

	if ( p_Class[ playerid ] != CLASS_CIVILIAN )
		return SendError( playerid, "This is restricted to civilians only." );

	if ( GetPlayerInterior( playerid ) != 0 && GetPlayerVirtualWorld( playerid ) != 0 )
	    return SendError( playerid, "You cannot do this inside interiors." );

	if ( IsPlayerJailed( playerid ) || IsPlayerUsingOrbitalCannon( playerid ) )
		return SendError( playerid, "You cannot do this at the moment." );

	new
		g_isAFK = 0,
		g_inAir = 0
	;

    foreach ( new z : Reverse(turfs) )
	{
		if ( IsPlayerInDynamicArea( playerid, g_gangTurfData[ z ] [ E_AREA ] ) )
     	{
	    	new gangid = p_GangID[ playerid ];

	        if ( g_gangTurfData[ z ] [ E_OWNER ] == gangid ) return SendError( playerid, "This turf is already captured by your gang." );
			if ( g_gangzoneAttacker[ z ] != INVALID_GANG_ID ) return SendError( playerid, "This turf is currently being attacked." );

			new opposing_count = GetPlayersInGangZone( z, g_gangTurfData[ z ] [ E_OWNER ] ); // Opposing check

			// existing gang members
			if ( g_gangTurfData[ z ] [ E_OWNER ] != INVALID_GANG_ID && opposing_count ) {
				return SendError( playerid, "There are gang members within this turf, kill them!" );
	        }

	        new attacking_count = GetPlayersInGangZone( z, gangid, g_isAFK, g_inAir );

	        if ( attacking_count < TAKEOVER_NEEDED_PEOPLE && ( attacking_count + g_isAFK + g_inAir ) >= TAKEOVER_NEEDED_PEOPLE )
		   		return SendError( playerid, "You cannot start a turf war if gang members are AFK or extremely high above ground." );

	        //if ( g_gangTurfData[ z ] [ E_OWNER ] != INVALID_GANG_ID && dCount < TAKEOVER_NEEDED_PEOPLE + 1 && ( dCount + g_isAFK + g_inAir ) >= TAKEOVER_NEEDED_PEOPLE + 1 )
		   	//	return SendError( playerid, "You need at least %d gang members to start a gang war with another gang.", TAKEOVER_NEEDED_PEOPLE + 1 );

		   	// Facility check
		   	if ( g_gangTurfData[ z ] [ E_FACILITY_GANG ] != INVALID_GANG_ID && Iter_Contains( gangs, g_gangTurfData[ z ] [ E_FACILITY_GANG ] ) )
		   	{
		   		new facility_gang = g_gangTurfData[ z ] [ E_FACILITY_GANG ];
		   		new facility_members = GetOnlineGangMembers( facility_gang );

		   		if ( g_gangTurfData[ z ] [ E_OWNER ] == facility_gang ) {
			   		if ( facility_members < 3 ) {
			   			return SendError( playerid, "This facility requires at least %d of its gang members online for a takeover.", 3 - facility_members );
			   		}
			   		else if ( attacking_count < 3 ) {
		   				return SendError( playerid, "You need at least %d gang members to take over this facility.", 3 - attacking_count );
			   		}
		   		}
		   	}

		   	// Begin takeover
			if ( attacking_count >= TAKEOVER_NEEDED_PEOPLE && ! opposing_count )
	        {
				g_gangzoneAttacker[ z ] = gangid;
	            g_gangzoneAttackCount[ z ] = 0;
              	GangZoneFlashForAll( g_gangTurfData[ z ] [ E_ID ], setAlpha( g_gangData[ gangid ] [ E_COLOR ], 0x80 ) );
              	SendClientMessage( playerid, g_gangData[ gangid ] [ E_COLOR ], "[TURF]{FFFFFF} You are now beginning to take over the turf. Stay inside the area with your gang for 60 seconds. Don't die." );

	            if ( g_gangTurfData[ z ] [ E_OWNER ] != INVALID_GANG_ID )
	            {
	            	new
						szLocation[ MAX_ZONE_NAME ], Float: min_x, Float: min_y;

					Streamer_GetFloatData( STREAMER_TYPE_AREA, g_gangTurfData[ z ] [ E_AREA ], E_STREAMER_MIN_X, min_x );
					Streamer_GetFloatData( STREAMER_TYPE_AREA, g_gangTurfData[ z ] [ E_AREA ], E_STREAMER_MIN_Y, min_y );

					GetZoneFromCoordinates( szLocation, min_x, min_y );

	            	SendClientMessageToGang( g_gangTurfData[ z ] [ E_OWNER ], g_gangData[ g_gangTurfData[ z ] [ E_OWNER ] ] [ E_COLOR ], "[GANG]"COL_WHITE" Our territory is being attacked by "COL_GREY"%s"COL_WHITE" in %s, defend it!", g_gangData[ g_gangzoneAttacker[ z ] ] [ E_NAME ], szLocation );
	            }
	        }
	        else
	        {
	        	SendError( playerid, "You need at least %d member(s) to take over this turf.", TAKEOVER_NEEDED_PEOPLE );
	        }
	        return 1;
	    }
	}
	return SendError( playerid, "You are not in any gangzone." );
}

/* ** Functions ** */
stock ShowPlayerControlArea( playerid, timeout, gang_color, required, progress )
{
	if ( ! IsPlayerConnected( playerid ) )
		return 0;

	PlayerTextDrawColor( playerid, p_playerTurfTitle[ playerid ], gang_color );
    PlayerTextDrawShow( playerid, p_playerTurfTitle[ playerid ] );

	SetPlayerProgressBarMaxValue( playerid, p_playerTurfProgress[ playerid ], float( required ) );
	SetPlayerProgressBarValue( playerid, p_playerTurfProgress[ playerid ], required - progress );
	SetPlayerProgressBarColour( playerid, p_playerTurfProgress[ playerid ], setAlpha( gang_color, 0x80 ) );
	ShowPlayerProgressBar( playerid, p_playerTurfProgress[ playerid ] );

    KillTimer( p_TurfProgressTimer[ playerid ] );
    p_TurfProgressTimer[ playerid ] = -1;

   	if ( timeout != 0 ) {
   		p_TurfProgressTimer[ playerid ] = SetTimerEx( "HidePlayerControlArea", timeout, false, "d", playerid );
   	}
	return 1;
}

function HidePlayerControlArea( playerid )
{
	p_TurfProgressTimer[ playerid ] = -1;
	HidePlayerProgressBar( playerid, p_playerTurfProgress[ playerid ] );
	PlayerTextDrawHide( playerid, p_playerTurfTitle[ playerid ] );
}


stock Turf_Create( Float: min_x, Float: min_y, Float: max_x, Float: max_y, owner_id = INVALID_GANG_ID, color = COLOR_GANGZONE, facility_gang_id = INVALID_GANG_ID )
{
	new
		id = Iter_Free( turfs );

	if ( id != ITER_NONE )
	{
		// set turf owners
		g_gangTurfData[ id ] [ E_OWNER ] = owner_id;
		g_gangTurfData[ id ] [ E_COLOR ] = color;
		g_gangTurfData[ id ] [ E_FACILITY_GANG ] = facility_gang_id;

		// create area
		g_gangTurfData[ id ] [ E_ID ] = GangZoneCreate( min_x, min_y, max_x, max_y );
		g_gangTurfData[ id ] [ E_AREA ] = CreateDynamicRectangle( min_x, min_y, max_x, max_y, 0, 0 );

		// add to iterator
		Iter_Add( turfs, id );
	}
	return id;
}

stock Turf_GetOwner( id ) {
	return g_gangTurfData[ id ] [ E_OWNER ];
}

stock Turf_GetFacility( id ) {
	return g_gangTurfData[ id ] [ E_FACILITY_GANG ];
}

stock Turf_GetFirstTurf( playerid )
{
	new
		current_areas[ 4 ];

	GetPlayerDynamicAreas( playerid, current_areas );

	foreach( new i : Reverse(turfs) )
	{
		if ( current_areas[ 0 ] == g_gangTurfData[ i ] [ E_AREA ] || current_areas[ 1 ] == g_gangTurfData[ i ] [ E_AREA ] || current_areas[ 2 ] == g_gangTurfData[ i ] [ E_AREA ] || current_areas[ 3 ] == g_gangTurfData[ i ] [ E_AREA ] )
		{
			return i;
		}
	}
	return -1;
}

stock Turf_GetProfitability( zoneid, gang_members, Float: default_pay = 4000.0 )
{
	// size adjustments
	//if ( g_gangzoneData[ zoneid ] [ E_SIZE ] < TURF_SIZE_SMALL ) // lower than 1st quartile, decrease pay
	//	default_pay *= 0.75;

	// Normal Gang Zones
	if ( zoneid < sizeof( g_gangzoneData ) )
	{
		if ( g_gangzoneData[ zoneid ] [ E_SIZE ] > TURF_SIZE_LARGE ) // higher than 1st quartile, increase pay
			default_pay *= 1.25;

		// city adjustments
		if ( g_gangzoneData[ zoneid ] [ E_CITY ] == CITY_SF )
			default_pay *= 1.25;

		if ( g_gangzoneData[ zoneid ] [ E_CITY ] == CITY_COUNTRY || g_gangzoneData[ zoneid ] [ E_CITY ] == CITY_DESERTS )
			default_pay *= 1.1;
	}

	// facility 2x
	if ( g_gangTurfData[ zoneid ] [ E_FACILITY_GANG ] != INVALID_GANG_ID )
		default_pay *= 2;

	// get online players
	new Float: player_boost = 0.0;

	if ( gang_members >= 10 ) player_boost = 1.5;
	else if ( gang_members > 1 ) player_boost = 1.0 + float( gang_members - 1 ) * 0.05;

	// max boost
	default_pay *= player_boost > 1.5 ? 1.5 : player_boost;

	// return rounded number
	return floatround( default_pay );
}

stock Turf_ResetGangTurfs( gangid )
{
 	foreach ( new z : turfs )
 	{
 		if ( g_gangTurfData[ z ] [ E_OWNER ] == gangid )
 		{
			new
				facility_gang = g_gangTurfData[ z ] [ E_FACILITY_GANG ];

		   	if ( g_gangTurfData[ z ] [ E_FACILITY_GANG ] != INVALID_GANG_ID && Iter_Contains( gangs, g_gangTurfData[ z ] [ E_FACILITY_GANG ] ) )
		   	{
	    		g_gangTurfData[ z ] [ E_COLOR ] = setAlpha( g_gangData[ facility_gang ] [ E_COLOR ], 0x80 );
	 			g_gangTurfData[ z ] [ E_OWNER ] = facility_gang;
				GangZoneShowForAll( g_gangTurfData[ z ] [ E_ID ], g_gangTurfData[ z ] [ E_COLOR ] );
		   	}
		   	else
		   	{
	 			g_gangTurfData[ z ] [ E_COLOR ] = COLOR_GANGZONE;
	 			g_gangTurfData[ z ] [ E_OWNER ] = INVALID_GANG_ID;
				GangZoneShowForAll( g_gangTurfData[ z ] [ E_ID ], COLOR_GANGZONE );
		   	}
 		}
 	}
}

stock Turf_ShowGangOwners( playerid )
{
	if ( ! Iter_Count( turfs ) )
		return SendError( playerid, "There is currently no trufs on the server." );

	szHugeString[ 0 ] = '\0';

	foreach( new turfid : turfs )
	{
		new
			szLocation[ MAX_ZONE_NAME ], Float: min_x, Float: min_y;

		Streamer_GetFloatData( STREAMER_TYPE_AREA, g_gangTurfData[ turfid ] [ E_AREA ], E_STREAMER_MIN_X, min_x );
		Streamer_GetFloatData( STREAMER_TYPE_AREA, g_gangTurfData[ turfid ] [ E_AREA ], E_STREAMER_MIN_Y, min_y );

		GetZoneFromCoordinates( szLocation, min_x, min_y );

	    if ( g_gangTurfData[ turfid ][ E_OWNER ] == INVALID_GANG_ID ) {
	    	format( szHugeString, sizeof( szHugeString ), "%s%s\t"COL_GREY"Unoccupied\n", szHugeString, szLocation );
	    }
	    else {
	    	format( szHugeString, sizeof( szHugeString ), "%s%s\t{%06x}%s\n", szHugeString, szLocation, g_gangTurfData[ turfid ][ E_COLOR ] >>> 8 , ReturnGangName( g_gangTurfData[ turfid ][ E_OWNER ] ) );
	    }
	}
	return ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_TABLIST, ""COL_WHITE"Gang Turfs", szHugeString, "Close", "" );
}

stock Turf_RedrawPlayerGangZones( playerid, gangid )
{
	foreach ( new x : turfs )
    {
    	// set the new color to the turfs
    	if ( g_gangTurfData[ x ] [ E_OWNER ] == gangid ) {
    		g_gangTurfData[ x ] [ E_COLOR ] = setAlpha( g_gangData[ gangid ] [ E_COLOR ], 0x80 );
    	}

    	// resume flashing if gang war
    	if ( g_gangzoneAttacker[ x ] == gangid ) {
    		GangZoneStopFlashForPlayer( playerid, g_gangTurfData[ x ] [ E_ID ] );
    		GangZoneFlashForPlayer( playerid, g_gangTurfData[ x ] [ E_ID ], setAlpha( g_gangData[ gangid ] [ E_COLOR ], 0x80 ) );
    	} else {
	        GangZoneHideForPlayer( playerid, g_gangTurfData[ x ] [ E_ID ] );
	        GangZoneShowForPlayer( playerid, g_gangTurfData[ x ] [ E_ID ], g_gangTurfData[ x ] [ E_COLOR ] );
    	}
    }
    return 1;
}

stock Turf_GetCentrePos( zoneid, &Float: X, &Float: Y ) // should return the centre but will do for now
{
	Streamer_GetFloatData( STREAMER_TYPE_AREA, g_gangTurfData[ zoneid ] [ E_AREA ], E_STREAMER_MIN_X, X );
	Streamer_GetFloatData( STREAMER_TYPE_AREA, g_gangTurfData[ zoneid ] [ E_AREA ], E_STREAMER_MIN_Y, Y );
}

stock GetGangCapturedTurfs( gangid )
{
	new
		z,
		c;

	foreach ( z : turfs ) if ( g_gangTurfData[ z ] [ E_OWNER ] != INVALID_GANG_ID && g_gangTurfData[ z ] [ E_OWNER ] == gangid ) {
		c++;
	}
	return c;
}

stock GetPlayersInGangZone( z, g, &is_afk = 0, &in_air = 0 )
{
	if ( g == INVALID_GANG_ID )
		return 0;

	new count = 0;
	new Float: Z;

	foreach ( new i : Player ) if ( p_Class[ i ] == CLASS_CIVILIAN && p_GangID[ i ] == g && IsPlayerInDynamicArea( i, g_gangTurfData[ z ] [ E_AREA ] ) )
	{
		if ( ! IsPlayerSpawnProtected( i ) && GetPlayerState( i ) != PLAYER_STATE_SPECTATING )
		{
            if ( IsPlayerAFK( i ) )
            {
            	is_afk++;
            	continue;
            }
            if ( GetPlayerPos( i, Z, Z, Z ) && Z >= 300.0 )
            {
            	in_air++;
            	continue;
            }
            count++;
		}
	}
	return count;
}
