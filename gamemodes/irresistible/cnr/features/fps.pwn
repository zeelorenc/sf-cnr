/*
 * Irresistible Gaming 2018
 * Developed by Lorenc Pekaj
 * Module: fps.inc
 * Purpose: fps counter in-game
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Variables ** */
new
	Text:  p_FPSCounterTD 			[ MAX_PLAYERS ] = { Text: INVALID_TEXT_DRAW, ... },
	bool: p_FPSCounter 				[ MAX_PLAYERS char ],
	p_FPS_DrunkLevel 				[ MAX_PLAYERS ],
	p_FPS 							[ MAX_PLAYERS ]
;

/* ** Commands ** */
CMD:fps( playerid, params[ ] )
{
	if( ( p_FPSCounter{ playerid } = !p_FPSCounter{ playerid } ) == true )
	{
		formatFPSCounter( playerid );
		TextDrawShowForPlayer( playerid, p_FPSCounterTD[ playerid ] );
	    SendClientMessage( playerid, 0x84aa63ff, "-> FPS counter enabled" );
	}
	else
	{
		TextDrawHideForPlayer( playerid, p_FPSCounterTD[ playerid ] );
	    SendClientMessage( playerid, 0x84aa63ff, "-> FPS counter disabled" );
	}
	return 1;
}

#if defined _streamer_included
CMD:drawdistance( playerid, params[ ] )
{
	if ( strmatch( params, "low" ) ) {
		Streamer_SetVisibleItems( STREAMER_TYPE_OBJECT, 300, playerid );
	    SendClientMessage( playerid, 0x84aa63ff, "-> Draw distance of objects now set to LOW." );
	} else if ( strmatch( params, "medium" ) ) {
		Streamer_SetVisibleItems( STREAMER_TYPE_OBJECT, 625, playerid );
	    SendClientMessage( playerid, 0x84aa63ff, "-> Draw distance of objects now set to MEDIUM." );
	} else if ( strmatch( params, "high" ) ) {
		Streamer_SetVisibleItems( STREAMER_TYPE_OBJECT, 950, playerid );
	    SendClientMessage( playerid, 0x84aa63ff, "-> Draw distance of objects now set to HIGH." );
	} else if ( strmatch( params, "info" ) ) {
	    SendClientMessage( playerid, 0x84aa63ff, sprintf( "-> You have currently %d objects streamed towards your client.", Streamer_GetVisibleItems( STREAMER_TYPE_OBJECT, playerid ) ) );
	}
	else {
		SendClientMessage( playerid, 0xa9c4e4ff, "-> /drawdistance [LOW/MEDIUM/HIGH/INFO]" );
	}
	return 1;
}
#endif

/* ** Hooks ** */
hook OnScriptInit( )
{
	for ( new playerid; playerid != MAX_PLAYERS; playerid ++ )
	{
		p_FPSCounterTD[ playerid ] = TextDrawCreate(636.000000, 2.000000, "_");
		TextDrawAlignment(p_FPSCounterTD[ playerid ], 3);
		TextDrawBackgroundColor(p_FPSCounterTD[ playerid ], 255);
		TextDrawFont(p_FPSCounterTD[ playerid ], 3);
		TextDrawLetterSize(p_FPSCounterTD[ playerid ], 0.300000, 1.500000);
		TextDrawColor(p_FPSCounterTD[ playerid ], -1);
		TextDrawSetOutline(p_FPSCounterTD[ playerid ], 1);
		TextDrawSetProportional(p_FPSCounterTD[ playerid ], 1);
	}
	return 1;
}

/* ** Functions ** */
stock formatFPSCounter( playerid )
{
	if( !p_FPSCounter{ playerid } ) {
		return;
	}

	static
		iFPS,
		szColor[ 10 ],
		szFPS[ sizeof( szColor ) + 4 ]
	;

	switch( ( iFPS = p_FPS[ playerid ] ) ) {
		case 32 .. 120: szColor = "~g~~h~~h~";
		case 18 .. 31: 	szColor = "~y~~h~";
		case 0 .. 17: 	szColor = "~r~~h~~h~";
		default: 		szColor = "~g~~h~~h~";
	}

	format( szFPS, sizeof( szFPS ), "%s%d", szColor, iFPS );
	TextDrawSetString( p_FPSCounterTD[ playerid ], szFPS );
}

stock GetPlayerFPS( playerid ) {
	return p_FPS[ playerid ];
}