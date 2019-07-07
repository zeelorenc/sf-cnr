/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\player\experience.pwn
 * Purpose: player experience system 2.0
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
//#define DIALOG_VIEW_LEVEL			5943
#define DIALOG_VIEW_LEVEL_BENEFIT	5944

/* ** Macros ** */
#define IsDoubleXP() 				( GetGVarInt( "doublexp" ) )

/* ** Constants ** */
enum E_LEVELS {
	E_POLICE,
	E_ROBBERY,
	E_DEATHMATCH,
	E_ROLEPLAY

	/*E_FIREMAN,
	E_PARAMEDIC,
	E_HITMAN,
	E_BURGLAR,
	E_TERRORIST,
	E_CAR_JACKER,
	E_DRUG_PRODUCTION,
	E_MINING,
	E_TRANSPORT*/
};

enum E_LEVEL_DATA {
	E_NAME[ 16 ],					E_COLOUR,

	Float: E_MAX_UNITS,				Float: E_XP_DILATION, 		Float: E_SELL_VALUE
};

enum E_RANK_DATA
{
	Float: E_POINTS,			E_NAME[ 32 ], 					E_MODEL,
	E_COLOR,
};

enum E_BENEFIT_DATA
{
	E_LEVELS: E_LEVEL_INDEX,
	E_BENEFIT[ 64 ],
	Float: E_LEVEL_REQUIRE
};

static const
	Float: EXP_MAX_PLAYER_LEVEL 	= 100.0;

static const
	g_requirementData 				[ ] [ E_BENEFIT_DATA ] =
	{
		// Police benefits
		{ E_POLICE,					"Half the number of seconds you spend in jail", 					75.0 },
		{ E_POLICE,					"Guranteed success when breaking into a safe", 						50.0 },
		{ E_POLICE,					"Success rate for bobby pins increase 1% each 25 levels",			0.0 },
		{ E_POLICE,					"Bail amount decreases 1% each level",								0.0 },

		// Robbery benefits
		{ E_ROBBERY,				"Higher the robbery level, the better success rate of a robbery", 	0.0 },
		{ E_ROBBERY, 				"Higher the robbery level, the faster you can break into a safe", 	0.0 },

		// Deathmatch benefits
		{ E_DEATHMATCH,				"1% chance of dropping armour when you kill a player",			 	50.0 },
		{ E_DEATHMATCH,				"Killed players will drop health equivalent to your level",		 	10.0 },

		// Roleplay benefits
		{ E_ROLEPLAY,				"Increase success rate in mining based on roleplay level",			0.0 }
	}
;

static const
	g_levelData 					[ ] [ E_LEVEL_DATA ] =
	{
		// Level Name 			Bar Color 		Level 100 Req.		XP Dilation 	Sell Value
		{ "Police",				0x3E7EFFFF,		7500.0, 			20.0,			10.0 }, 	// 7.5k arrests
		{ "Robbery", 			0xF83245FF, 	30000.0,			15.0,			10.0 }, 	// 30k robberies
		{ "Deathmatch", 		0xFF9233FF,		75000.0,			10.0,			5.0 }, 		// 75k kills
		{ "Roleplay",			0x33FF50FF,		75000.0,	 		10.0,			5.0 }		// 75k minijob

/*
		{ "Fireman",			10000.0,			9.0 },		// 10k fires
		{ "Hitman",				1500.0,				4.5 },		// 1.5k contracts
		{ "Burglar",			2000.0,				7.5 },		// 2K burglaries
		{ "Terrorist",			15000.0,			6.0 },		// 15k blown entities
		{ "Car Jacker",			10000.0,			6.0 },		// 10k cars jacked
		{ "Drug Production",	10000.0,			6.0	},		// 10k exports drug related
		{ "Mining",				1500.0,				3.0 }		// 1,500 mining ores
*/
	},

	g_seasonalRanks[ ] [ E_RANK_DATA ] =
	{
		{ 49860.3,	"Elite V", 		19780, COLOR_GOLD },
		{ 27833.9,	"Elite IV", 	19782, COLOR_GOLD },
		{ 15537.9, 	"Elite III", 	19781, COLOR_GOLD },
		{ 8673.88, 	"Elite II", 	19784, COLOR_GOLD },
		{ 4842.10, 	"Elite I", 		19783, COLOR_GOLD },
		{ 2703.04,	"Silver V", 	19780, COLOR_GREY },
		{ 1508.94,	"Silver IV", 	19782, COLOR_GREY },
		{ 842.365, 	"Silver III", 	19781, COLOR_GREY },
		{ 470.19, 	"Silver II", 	19784, COLOR_GREY },
		{ 262.5, 	"Silver I", 	19783, COLOR_GREY },
		{ 0.0, 		"unranked",		19300, COLOR_GREY }
	}
;

/* ** Variables ** */
static stock
	Float: g_playerExperience		[ MAX_PLAYERS ] [ E_LEVELS ],
	Float: p_seasonalXP				[ MAX_PLAYERS ],

	PlayerText: p_playerExpTitle 	[ MAX_PLAYERS ] = { PlayerText: INVALID_TEXT_DRAW, ... },
	PlayerText: p_playerExpAwardTD	[ MAX_PLAYERS ] = { PlayerText: INVALID_TEXT_DRAW, ... },
	PlayerBar: p_playerExpProgress 	[ MAX_PLAYERS ],
	p_playerExpHideTimer 			[ MAX_PLAYERS ] = { -1, ... }
;

/* ** Important ** */
stock Float: GetPlayerLevel( playerid, E_LEVELS: level )
{
	new
		Float: player_level = floatsqroot( g_playerExperience[ playerid ] [ level ] / ( ( g_levelData[ _: level ] [ E_MAX_UNITS ] * g_levelData[ _: level ] [ E_XP_DILATION ] ) / ( EXP_MAX_PLAYER_LEVEL * EXP_MAX_PLAYER_LEVEL ) ) );

	return player_level > 100.0 ? 100.0 : player_level;
}

/* ** Hooks ** */
hook OnDialogResponse( playerid, dialogid, response, listitem, inputtext[ ] )
{
	if ( dialogid == DIALOG_VIEW_LEVEL && response )
	{
		new
			watchingid = GetPVarInt( playerid, "experience_watchingid" );

		szLargeString = ""COL_GREY"Benefit\t"COL_GREY"Required Level\n";

		for ( new i = 0; i < sizeof( g_requirementData ); i ++ )
		{
			if ( g_requirementData[ i ] [ E_LEVEL_INDEX ] == E_LEVELS: listitem )
			{
				format(
					szLargeString,
					sizeof( szLargeString ),
					"%s"COL_WHITE"%s\t"COL_GOLD"%s\n",
					szLargeString,
					g_requirementData[ i ] [ E_BENEFIT ],
					number_format( g_requirementData[ i ] [ E_LEVEL_REQUIRE ], .decimals = 0 )
				);
			}
		}
		return ShowPlayerDialog( playerid, DIALOG_VIEW_LEVEL_BENEFIT, DIALOG_STYLE_TABLIST_HEADERS, sprintf( "{FFFFFF}%s's %s Level", ReturnPlayerName( watchingid ), g_levelData[ listitem ] [ E_NAME ] ), szLargeString, "Close", "Back" );
	}
	else if ( dialogid == DIALOG_VIEW_LEVEL_BENEFIT && ! response )
	{
		return cmd_xp( playerid, sprintf( "%d", GetPVarInt( playerid, "experience_watchingid" ) ) );
	}
	else if ( dialogid == DIALOG_XPMARKET && response )
	{
		return ShowPlayerSellXPDialog( playerid, listitem );
	}
	else if ( dialogid == DIALOG_XPMARKET_SELL )
	{
		if ( ! response ) {
			return cmd_xpmarket( playerid, "" );
		}

		new level = GetPVarInt( playerid, "selling_xp_level" );
		new total_xp = floatround( g_playerExperience[ playerid ] [ E_LEVELS: level ], floatround_floor );
		new xp_amount = strval( inputtext );

		if ( ! ( 0 < xp_amount < 10000000 ) )
		{
			SendError( playerid, "You have specified an invalid amount of %s XP.", g_levelData[ level ] [ E_NAME ] );
			return ShowPlayerSellXPDialog( playerid, level );
		}
		else if ( xp_amount > total_xp )
		{
			SendError( playerid, "You do not have this much %s XP.", g_levelData[ level ] [ E_NAME ] );
			return ShowPlayerSellXPDialog( playerid, level );
		}
		else
		{
			new
				credit = floatround( float( xp_amount ) * g_levelData[ level ] [ E_SELL_VALUE ], floatround_floor );

			GivePlayerCash( playerid, credit );
	    	GivePlayerExperience( playerid, E_LEVELS: level, -xp_amount, .with_dilation = false );
			SendServerMessage( playerid, "You have sold %s %s XP for "COL_GOLD"%s"COL_WHITE".", g_levelData[ level ] [ E_NAME ], number_format( xp_amount ), cash_format( credit ) );
		}
		return 1;
	}
	return 1;
}

hook OnPlayerUpdateEx( playerid )
{
	if ( IsPlayerLoggedIn( playerid ) )
	{
		new
			Float: total_experience;

		GetPlayerTotalExperience( playerid, total_experience );
		PlayerTextDrawSetString( playerid, p_ExperienceTD[ playerid ], sprintf( "%08.0f", total_experience ) );
	}
	return 1;
}

hook OnPlayerLogin( playerid )
{
	mysql_tquery( dbHandle, sprintf( "SELECT * FROM `USER_LEVELS` WHERE `USER_ID` = %d", GetPlayerAccountID( playerid ) ), "Experience_OnLoad", "d", playerid );
	return 1;
}

hook OnPlayerConnect( playerid )
{
	// progress bar for xp
 	p_playerExpProgress[ playerid ] = CreatePlayerProgressBar( playerid, 47.000000, 263.000000, 82.500000, 7.199999, COLOR_GOLD, 100.0000, 0 ); // -2007060993

 	// title of progress bar
	p_playerExpTitle[ playerid ] = CreatePlayerTextDraw( playerid, 86.000000, 248.000000, "_" );
	PlayerTextDrawAlignment( playerid, p_playerExpTitle[ playerid ], 2 );
	PlayerTextDrawBackgroundColor( playerid, p_playerExpTitle[ playerid ], 255 );
	PlayerTextDrawFont( playerid, p_playerExpTitle[ playerid ], 1 );
	PlayerTextDrawLetterSize( playerid, p_playerExpTitle[ playerid ], 0.240000, 1.200000 );
	PlayerTextDrawColor( playerid, p_playerExpTitle[ playerid ], COLOR_GOLD );
	PlayerTextDrawSetOutline( playerid, p_playerExpTitle[ playerid ], 1 );
	PlayerTextDrawSetProportional( playerid, p_playerExpTitle[ playerid ], 1 );

	// general reward
	p_playerExpAwardTD[ playerid ] = CreatePlayerTextDraw( playerid,319.000000, 167.000000, "+20 XP" );
	PlayerTextDrawAlignment( playerid, p_playerExpAwardTD[ playerid ], 2 );
	PlayerTextDrawBackgroundColor( playerid, p_playerExpAwardTD[ playerid ], 255 );
	PlayerTextDrawFont( playerid, p_playerExpAwardTD[ playerid ], 3 );
	PlayerTextDrawLetterSize( playerid, p_playerExpAwardTD[ playerid ], 0.450000, 1.599999 );
	PlayerTextDrawColor( playerid, p_playerExpAwardTD[ playerid ], COLOR_GOLD );
	PlayerTextDrawSetOutline( playerid, p_playerExpAwardTD[ playerid ], 1 );
	PlayerTextDrawSetProportional( playerid, p_playerExpAwardTD[ playerid ], 1 );
	PlayerTextDrawSetSelectable( playerid, p_playerExpAwardTD[ playerid ], 0 );
	return 1;
}

hook OnPlayerDisconnect( playerid, reason )
{
	p_seasonalXP[ playerid ] = 0.0;

	// reset levels
	for ( new l = 0; l < sizeof ( g_levelData ); l ++ ) {
		g_playerExperience[ playerid ] [ E_LEVELS: l ] = 0;
	}
	return 1;
}

hook OnPlayerMovieMode( playerid, bool: toggled )
{
	if ( ! toggled )
	{
		TextDrawShowForPlayer( playerid, g_CurrentRankTD );
		TextDrawShowForPlayer( playerid, g_currentXPTD );
		PlayerTextDrawShow( playerid, p_ExperienceTD[ playerid ] );
		ShowPlayerIrresistibleRank( playerid );
	}
	else
	{
		TextDrawHideForPlayer( playerid, g_CurrentRankTD );
		TextDrawHideForPlayer( playerid, g_currentXPTD );
		PlayerTextDrawHide( playerid, p_ExperienceTD[ playerid ] );
		PlayerTextDrawHide( playerid, p_PlayerRankTD[ playerid ] );
		PlayerTextDrawHide( playerid, p_PlayerRankTextTD[ playerid ] );
	}
	return 1;
}

/* ** Commands ** */
CMD:experience( playerid, params[ ] ) return cmd_level( playerid, params );
CMD:levels( playerid, params[ ] ) return cmd_level( playerid, params );
CMD:xp( playerid, params[ ] ) return cmd_level( playerid, params );
CMD:level( playerid, params[ ] )
{
	new
	 	watchingid;

	if ( sscanf( params, "u", watchingid ) )
		watchingid = playerid;

	if ( !IsPlayerConnected( watchingid ) )
		watchingid = playerid;

	new
		player_total_lvl = 0;

	szLargeString = ""COL_GREY"Skill\t"COL_GREY"Current Level\t"COL_GREY"XP Till Next Level\t"COL_GREY"Total XP\n";

	for ( new level_id; level_id < sizeof( g_levelData ); level_id ++ )
	{
		new Float: current_rank = GetPlayerLevel( watchingid, E_LEVELS: level_id );
		new Float: next_lvl = floatround( current_rank, floatround_floor ) + 1.0;
		new Float: next_lvl_xp = ( g_levelData[ level_id ] [ E_MAX_UNITS ] * g_levelData[ level_id ] [ E_XP_DILATION ] ) / ( EXP_MAX_PLAYER_LEVEL * EXP_MAX_PLAYER_LEVEL ) * ( next_lvl * next_lvl );

		player_total_lvl += floatround( current_rank, floatround_floor );
		format( szLargeString, sizeof( szLargeString ), "%s%s Level\t%s%0.0f / %0.0f\t"COL_PURPLE"%0.0f XP\t"COL_GREY"%s\n", szLargeString, g_levelData[ level_id ] [ E_NAME ], current_rank >= 100.0 ? ( COL_GREEN ) : ( COL_GREY ), current_rank, EXP_MAX_PLAYER_LEVEL, next_lvl_xp - g_playerExperience[ watchingid ] [ E_LEVELS: level_id ], number_format( g_playerExperience[ watchingid ] [ E_LEVELS: level_id ], .decimals = 0 ) );
	}

	SetPVarInt( playerid, "experience_watchingid", watchingid );
	return ShowPlayerDialog( playerid, DIALOG_VIEW_LEVEL, DIALOG_STYLE_TABLIST_HEADERS, sprintf( "{FFFFFF}%s's Level - Total Level %d", ReturnPlayerName( watchingid ), player_total_lvl ), szLargeString, "Select", "Close" );
}

CMD:rank( playerid, params[ ] )
{
	new
	 	watchingid;

	if ( sscanf( params, "u", watchingid ) )
		watchingid = playerid;

	if ( !IsPlayerConnected( watchingid ) )
		watchingid = playerid;

	format( szBigString, 196, "SELECT uo.NAME, (SELECT COUNT(DISTINCT ui.`SCORE`) FROM `USERS` ui WHERE ui.`SCORE` >= uo.`SCORE`) AS `GLOBAL_RANK` FROM `USERS` uo WHERE `ID`=%d", p_AccountID[ watchingid ] );
	mysql_function_query( dbHandle, szBigString, true, "currentUserRank", "ii", playerid, watchingid );
	return 1;
}

CMD:xpmarket( playerid, params[ ] )
{
	// header
	szBigString = ""COL_GREY"Skill\t"COL_GREY"Total XP\t"COL_GREY"Value ($)\n";

	// level with user xp
	for ( new level_id; level_id < sizeof( g_levelData ); level_id ++ ) {
		new value = floatround( g_playerExperience[ playerid ] [ E_LEVELS: level_id ] * g_levelData[ level_id ] [ E_SELL_VALUE ] );
		format( szBigString, sizeof( szBigString ), "%s%s Level\t"COL_PURPLE"%s XP\t"COL_GREEN"%s\n", szBigString, g_levelData[ level_id ] [ E_NAME ], number_format( g_playerExperience[ playerid ] [ E_LEVELS: level_id ], .decimals = 0 ), cash_format( value ) );
	}
	return ShowPlayerDialog( playerid, DIALOG_XPMARKET, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}XP Market", szBigString, "Select", "Close" ), 1;
}

/* ** SQL Threads ** */
thread Experience_OnLoad( playerid )
{
	new
		rows = cache_get_row_count( );

	if ( rows )
	{
		for ( new row = 0; row < rows; row ++ )
		{
			new
				level_id = cache_get_field_content_int( row, "LEVEL_ID" );

			// make sure we don't get any deprecated/invalid levels
			if ( level_id < sizeof ( g_levelData ) ) {
				g_playerExperience[ playerid ] [ E_LEVELS: level_id ] = cache_get_field_content_float( row, "EXPERIENCE" );
			}
		}
	}
	return 1;
}

thread currentUserRank( playerid, watchingid )
{
	new
		rows;

    cache_get_data( rows, tmpVariable );

	if ( rows )
	{
		new
			iGroupedRank = GetPlayerRank( watchingid ),
			iGlobalRank = cache_get_field_content_int( 0, "GLOBAL_RANK", dbHandle )
		;
		SendServerMessage( playerid, "%s(%d) is grouped in {%06x}%s"COL_WHITE" and is globally "COL_GREY"#%d"COL_WHITE".", ReturnPlayerName( watchingid ), watchingid, g_seasonalRanks[ iGroupedRank ] [ E_COLOR ] >>> 8, g_seasonalRanks[ iGroupedRank ] [ E_NAME ], iGlobalRank );
	}
	else SendError( playerid, "Couldn't find a rank for this user, try again later." );
	return 1;
}

/* ** Functions ** */
stock Float: GetPlayerExperience( playerid, E_LEVELS: level )
{
	return g_playerExperience[ playerid ] [ level ];
}

stock GivePlayerExperience( playerid, E_LEVELS: level, Float: default_xp = 1.0, bool: with_dilation = true )
{
	if ( ! IsPlayerLoggedIn( playerid ) || ! ( 0 <= _: level < sizeof( g_levelData ) ) )
		return 0;

	// dilation is there so people see +3 when they arrest ... could trigger dopamine levels instead of constantly +1 lol
	new Float: xp_earned = default_xp * ( IsDoubleXP( ) && default_xp > 0.0 ? 2.0 : 1.0 ) * ( with_dilation ? ( g_levelData[ _: level ] [ E_XP_DILATION ] ) : 1.0 );

	// when a player ranks up
	new next_lvl = floatround( GetPlayerLevel( playerid, level ), floatround_floor ) + 1;
	new Float: next_lvl_xp = ( g_levelData[ _: level ] [ E_MAX_UNITS ] * g_levelData[ _: level ] [ E_XP_DILATION ] ) / ( EXP_MAX_PLAYER_LEVEL * EXP_MAX_PLAYER_LEVEL ) * float( next_lvl * next_lvl );

	if ( g_playerExperience[ playerid ] [ level ] + xp_earned >= next_lvl_xp ) {
		ShowPlayerHelpDialog( playerid, 10000, "~p~Congratulations %s!~n~~n~~w~Your %s Level is now ~p~%d.", ReturnPlayerName( playerid ), g_levelData[ _: level ] [ E_NAME ], next_lvl );
		if ( !IsPlayerUsingRadio( playerid ) ) PlayAudioStreamForPlayer( playerid, "http://files.sfcnr.com/game_sounds/levelup.mp3" );
    	PlayerTextDrawSetString( playerid, p_playerExpTitle[ playerid ], sprintf( "%s Level %d", g_levelData[ _: level ] [ E_NAME ], next_lvl ) );
		SetPlayerProgressBarValue( playerid, p_playerExpProgress[ playerid ], 100.0 );
	} else {
    	PlayerTextDrawSetString( playerid, p_playerExpTitle[ playerid ], sprintf( "%s Level %d", g_levelData[ _: level ] [ E_NAME ], next_lvl - 1 ) );
	}

	// check if its over 100 anyway
	if ( ( g_playerExperience[ playerid ] [ level ] += xp_earned ) > g_levelData[ _: level ] [ E_MAX_UNITS ] * g_levelData[ _: level ] [ E_XP_DILATION ] ) {
		// g_playerExperience[ playerid ] [ level ] = g_levelData[ _: level ] [ E_MAX_UNITS ] * g_levelData[ _: level ] [ E_XP_DILATION ]; // stop player from accumulating more exp
		SetPlayerProgressBarValue( playerid, p_playerExpProgress[ playerid ], 100.0 );
	} else {
		new Float: progress = floatfract( GetPlayerLevel( playerid, level ) ) * 100.0;
		SetPlayerProgressBarValue( playerid, p_playerExpProgress[ playerid ], progress );
	}

	// seasonal (only adds, not including removes)
	if ( xp_earned > 0.0 ) GivePlayerSeasonalXP( playerid, xp_earned );

	// alert user
	KillTimer( p_playerExpHideTimer[ playerid ] );
	PlayerTextDrawColor( playerid, p_playerExpTitle[ playerid ], g_levelData[ _: level ] [ E_COLOUR ] );
	PlayerTextDrawShow( playerid, p_playerExpTitle[ playerid ] );
	SetPlayerProgressBarColour( playerid, p_playerExpProgress[ playerid ], g_levelData[ _: level ] [ E_COLOUR ] );
    ShowPlayerProgressBar( playerid, p_playerExpProgress[ playerid ] );
    PlayerTextDrawSetString( playerid, p_playerExpAwardTD[ playerid ], sprintf( "%s%0.0f XP", xp_earned < 0.0 ? ( "~r~" ) : ( "+" ), xp_earned ) );
    PlayerTextDrawShow( playerid, p_playerExpAwardTD[ playerid ] );
	p_playerExpHideTimer[ playerid ] = SetTimerEx( "Experience_HideIncrementTD", 3500, false, "d", playerid );

	// save to database
	format(
		szBigString, sizeof( szBigString ),
		"INSERT INTO `USER_LEVELS` (`USER_ID`,`LEVEL_ID`,`EXPERIENCE`) VALUES(%d,%d,%f) ON DUPLICATE KEY UPDATE `EXPERIENCE`=%f",
		GetPlayerAccountID( playerid ), _: level, g_playerExperience[ playerid ] [ level ], g_playerExperience[ playerid ] [ level ]
	);
	return mysql_single_query( szBigString ), 1;
}

function Experience_HideIncrementTD( playerid )
{
	p_playerExpHideTimer[ playerid ] = -1;
    HidePlayerProgressBar( playerid, p_playerExpProgress[ playerid ] );
	PlayerTextDrawHide( playerid, p_playerExpAwardTD[ playerid ] );
	PlayerTextDrawHide( playerid, p_playerExpTitle[ playerid ] );
	return 1;
}

stock GetPlayerTotalLevel( playerid, &level = 0 ) {
	for ( new l = 0; l < sizeof ( g_levelData ); l ++ ) {
		level += floatround( GetPlayerLevel( playerid, E_LEVELS: l ), floatround_floor );
	}
	return level;
}

stock GetRankFromXP( Float: xp ) {
	new
		iRank;

	for( iRank = 0; iRank < sizeof( g_seasonalRanks ); iRank++ )
		if ( xp >= g_seasonalRanks[ iRank ] [ E_POINTS ] )
			break;

	return iRank;
}

stock GetPlayerTotalExperience( playerid, &Float: experience ) {
	for ( new l = 0; l < sizeof ( g_levelData ); l ++ ) {
		experience += g_playerExperience[ playerid ] [ E_LEVELS: l ];
	}
}

stock GetPlayerRank( playerid ) {
	return GetRankFromXP( p_seasonalXP[ playerid ] );
}

stock ShowPlayerIrresistibleRank( playerid )
{
	new
		iRank = GetPlayerRank( playerid );

	PlayerTextDrawColor( playerid, p_PlayerRankTextTD[ playerid ], g_seasonalRanks[ iRank ] [ E_COLOR ] );
	PlayerTextDrawSetString( playerid, p_PlayerRankTextTD[ playerid ], g_seasonalRanks[ iRank ] [ E_NAME ] );

	PlayerTextDrawColor( playerid, p_PlayerRankTD[ playerid ], g_seasonalRanks[ iRank ] [ E_COLOR ] );
	PlayerTextDrawSetPreviewModel( playerid, p_PlayerRankTD[ playerid ], g_seasonalRanks[ iRank ] [ E_MODEL ] );

	PlayerTextDrawShow( playerid, p_PlayerRankTD[ playerid ] );
	PlayerTextDrawShow( playerid, p_PlayerRankTextTD[ playerid ] );
}

stock GivePlayerSeasonalXP( playerid, Float: default_xp )
{
	if ( ! IsPlayerConnected( playerid ) || ! IsPlayerLoggedIn( playerid ) )
		return;

	new Float: previous_season_xp = p_seasonalXP[ playerid ];
	new Float: current_season_xp = previous_season_xp + default_xp;

	// default 0
	if ( current_season_xp < 0.0 )
		current_season_xp = 0.0;

	new Float: upper_limit = g_seasonalRanks[ 0 ] [ E_POINTS ] + 500.0;

	// so that the player has a chance to be deranked
	if ( current_season_xp > upper_limit )
		current_season_xp = upper_limit;

	for( new iRank = 0; iRank < sizeof( g_seasonalRanks ); iRank++ )
	{
		new bGained = ( previous_season_xp < g_seasonalRanks[ iRank ] [ E_POINTS ] <= current_season_xp );
		new bLost = ( current_season_xp < g_seasonalRanks[ iRank ] [ E_POINTS ] <= previous_season_xp );

		if ( bGained || bLost )
		{
			if ( bGained )
			{
				SendServerMessage( playerid, "Congratulations, your grouped ranking has been increased to {%06x}%s"COL_WHITE"!", g_seasonalRanks[ iRank ] [ E_COLOR ] >>> 8, g_seasonalRanks[ iRank ] [ E_NAME ] );

				PlayerTextDrawColor( playerid, p_PlayerRankTextTD[ playerid ], g_seasonalRanks[ iRank ] [ E_COLOR ] );
				PlayerTextDrawSetString( playerid, p_PlayerRankTextTD[ playerid ], g_seasonalRanks[ iRank ] [ E_NAME ] );

				PlayerTextDrawColor( playerid, p_PlayerRankTD[ playerid ], g_seasonalRanks[ iRank ] [ E_COLOR ] );
				PlayerTextDrawSetPreviewModel( playerid, p_PlayerRankTD[ playerid ], g_seasonalRanks[ iRank ] [ E_MODEL ] );
			}

			if ( bLost )
			{
				SendServerMessage( playerid, "Sorry, your grouped ranking has decreased to {%06x}%s"COL_WHITE"!", g_seasonalRanks[ iRank + 1 ] [ E_COLOR ] >>> 8, g_seasonalRanks[ iRank + 1 ] [ E_NAME ] );

				PlayerTextDrawColor( playerid, p_PlayerRankTextTD[ playerid ], g_seasonalRanks[ iRank + 1 ] [ E_COLOR ] );
				PlayerTextDrawSetString( playerid, p_PlayerRankTextTD[ playerid ], g_seasonalRanks[ iRank + 1 ] [ E_NAME ] );

				PlayerTextDrawColor( playerid, p_PlayerRankTD[ playerid ], g_seasonalRanks[ iRank + 1 ] [ E_COLOR ] );
				PlayerTextDrawSetPreviewModel( playerid, p_PlayerRankTD[ playerid ], g_seasonalRanks[ iRank + 1 ] [ E_MODEL ] );
			}

			PlayerTextDrawShow( playerid, p_PlayerRankTD[ playerid ] );
			PlayerTextDrawShow( playerid, p_PlayerRankTextTD[ playerid ] );
			break;
		}
	}

	//printf( "%s: %f points", ReturnPlayerName( playerid ), current_season_xp );
	p_seasonalXP[ playerid ] = current_season_xp;

	// save to database
	mysql_single_query( sprintf( "UPDATE `USERS` SET `RANK` = %f WHERE `ID` = %d", current_season_xp, GetPlayerAccountID( playerid ) ) );
}

stock ShowPlayerSellXPDialog( playerid, level )
{
	new value = floatround( g_playerExperience[ playerid ] [ E_LEVELS: level ] * g_levelData[ level ] [ E_SELL_VALUE ] );

	format( szBigString, sizeof( szBigString ),
		""COL_WHITE"Please input how much %s XP you want to sell.\n\n"\
		"Exchange Rate is "COL_GOLD"1 XP"COL_WHITE" for %s\n\n"\
		"You have %s XP that can be sold for %s\n\n"\
		""COL_RED"Warning: this action will result in a reduced level.",
		g_levelData[ level ] [ E_NAME ],
		cash_format( g_levelData[ level ] [ E_SELL_VALUE ], .decimals = 0 ),
		number_format( g_playerExperience[ playerid ] [ E_LEVELS: level ], .decimals = 0 ),
		cash_format( value, .decimals = 0 )
	);

	SetPVarInt( playerid, "selling_xp_level", level );
	return ShowPlayerDialog( playerid, DIALOG_XPMARKET_SELL, DIALOG_STYLE_INPUT, "{FFFFFF}XP Market", szBigString, "Sell", "Cancel");
}

/* ** Macros ** */
stock GetSeasonalRankName( rankid, dest[ ], dest_size = sizeof( dest ) ) {
	return format( dest, dest_size, "%s", g_seasonalRanks[ rankid ] [ E_NAME ] );
}

stock GetSeasonalRankColour( rankid ) {
	return g_seasonalRanks[ rankid ] [ E_COLOR ];
}

stock SetPlayerSeasonalXP( playerid, Float: seasonal_xp ) {
	p_seasonalXP[ playerid ] = seasonal_xp;
}

/* ** Migrations ** */
/*
	CREATE TABLE IF NOT EXISTS USER_LEVELS (
		`USER_ID` int(11),
		`LEVEL_ID` int(11),
		`EXPERIENCE` float,
		PRIMARY KEY (USER_ID, LEVEL_ID),
		FOREIGN KEY (USER_ID) REFERENCES USERS (ID) ON DELETE CASCADE
	);

	INSERT INTO USER_LEVELS (USER_ID, LEVEL_ID, EXPERIENCE) (SELECT ID as USER_ID, 0 as LEVEL_ID, ARRESTS * 20.0 AS EXPERIENCE FROM USERS);
	INSERT INTO USER_LEVELS (USER_ID, LEVEL_ID, EXPERIENCE) (SELECT ID as USER_ID, 1 as LEVEL_ID, ROBBERIES * 15.0 AS EXPERIENCE FROM USERS);
	INSERT INTO USER_LEVELS (USER_ID, LEVEL_ID, EXPERIENCE) (SELECT ID as USER_ID, 2 as LEVEL_ID, KILLS * 10.0 AS EXPERIENCE FROM USERS);
	DELETE FROM USER_LEVELS WHERE EXPERIENCE = 0;


	INSERT INTO USER_LEVELS (USER_ID, LEVEL_ID, EXPERIENCE) (SELECT ID as USER_ID, 3 as LEVEL_ID, FIRES * 9.0 AS EXPERIENCE FROM USERS);
	INSERT INTO USER_LEVELS (USER_ID, LEVEL_ID, EXPERIENCE) (SELECT ID as USER_ID, 4 as LEVEL_ID, CONTRACTS * 4.5 AS EXPERIENCE FROM USERS);
	INSERT INTO USER_LEVELS (USER_ID, LEVEL_ID, EXPERIENCE) (SELECT ID as USER_ID, 5 as LEVEL_ID, BURGLARIES * 7.5 AS EXPERIENCE FROM USERS);
	INSERT INTO USER_LEVELS (USER_ID, LEVEL_ID, EXPERIENCE) (SELECT ID as USER_ID, 6 as LEVEL_ID, (BLEW_JAILS + BLEW_VAULT) * 6.0 AS EXPERIENCE FROM USERS);
	INSERT INTO USER_LEVELS (USER_ID, LEVEL_ID, EXPERIENCE) (SELECT ID as USER_ID, 7 as LEVEL_ID, VEHICLES_JACKED * 6.0 AS EXPERIENCE FROM USERS);
	INSERT INTO USER_LEVELS (USER_ID, LEVEL_ID, EXPERIENCE) (SELECT ID as USER_ID, 8 as LEVEL_ID, (METH_YIELDED + (TRUCKED*0.33)) * 6.0 AS EXPERIENCE FROM USERS);
*/
