/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc Pekaj
 * Module: gangs.inc
 * Purpose: gang system
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define MAX_GANGS                   ( MAX_PLAYERS ) // safest is MAX_PLAYERS
#define INVALID_GANG_ID 			( -1 )

#define MAX_COLEADERS				( 3 )

/* ** Macros ** */
#define IsGangPrivate(%0)			( g_gangData[ %0 ] [ E_INVITE_ONLY ] )

/* ** Variables ** */
enum e_gang_data
{
	E_SQL_ID, 						E_NAME[ 30 ], 					E_LEADER,
	E_COLOR,						E_SOFT_DELETE_TS,

	E_BANK, 						E_KILLS, 						E_DEATHS,
	E_SCORE, 						E_RESPECT,

	E_COLEADER[ MAX_COLEADERS ], 	bool: E_INVITE_ONLY, 			E_JOIN_MSG[ 96 ],

	bool: E_HAS_FACILITY
};

enum E_GANG_LEAVE_REASON
{
	GANG_LEAVE_QUIT,
	GANG_LEAVE_KICK,
	GANG_LEAVE_UNKNOWN
};

new
	g_gangColors[ ] = { 0x99FF00FF, 0x00CC00FF, 0x009999FF, 0x0033CCFF, 0x330099FF, 0x660099FF, 0xCC0099FF },

	g_gangData						[ MAX_GANGS ] [ e_gang_data ],
	g_sortedGangData 				[ MAX_GANGS ] [ e_gang_data ], // used for sorting only
	p_GangID                        [ MAX_PLAYERS ],

	bool: p_gangInvited           	[ MAX_PLAYERS ] [ MAX_GANGS ],
	p_gangInviteTick                [ MAX_PLAYERS ],

	Iterator:gangs<MAX_GANGS>
;

/* ** Forwards ** */
forward OnPlayerLeaveGang( playerid, gangid, reason );
forward ZoneTimer( );

/* ** Hooks ** */
hook OnGameModeInit( )
{
	#if !defined DEBUG_MODE
		// Remove inactive gang members
		// mysql_single_query( "UPDATE `USERS` SET `GANG_ID`=-1 WHERE UNIX_TIMESTAMP()-`USERS`.`LASTLOGGED` > 1209600" );

		// Remove gangs with a non existant gang leader / unmatched player gang id to gang leader id
		mysql_single_query( "DELETE g FROM GANGS g LEFT JOIN USERS u ON g.LEADER = u.ID WHERE (u.GANG_ID != g.ID OR u.ID IS NULL) AND g.LEADER >= 0" );
	#endif
	return 1;
}

/* ** Functions ** */
stock SetPlayerGang( playerid, joining_gang )
{
	if ( ! Iter_Contains( gangs, joining_gang ) )
		return 0;

	// remove from existing gang
	if ( p_GangID[ playerid ] != INVALID_GANG_ID ) {
		RemovePlayerFromGang( playerid, GANG_LEAVE_QUIT );
	}

	p_GangID[ playerid ] = joining_gang;
    if ( GetPlayerWantedLevel( playerid ) < 1 ) SetPlayerColor( playerid, g_gangData[ joining_gang ] [ E_COLOR ] );
	mysql_single_query( sprintf( "UPDATE `USERS` SET `GANG_ID`=%d WHERE `ID`=%d", g_gangData[ joining_gang ] [ E_SQL_ID ], GetPlayerAccountID( playerid ) ) );
	SendClientMessageToGang( joining_gang, g_gangData[ joining_gang ] [ E_COLOR ], "[GANG]{FFFFFF} %s(%d) has joined the gang.", ReturnPlayerName( playerid ), playerid );
	return 1;
}