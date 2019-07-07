/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\robbery\vaults.pwn
 * Purpose: vault opening system (corrolated to robberies)
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define VAULT_BOAT 					( 3 )

/* ** Variables ** */
enum E_BANKDOOR_DATA
{
	E_NAME[ 18 ],
	E_OBJECT,					bool: E_DISABLED,
	E_TIMESTAMP,				E_TIMESTAMP_CLOSE,			E_WORLD,
	Float: E_EXPLODE_POS[ 3 ],	Float: E_OPEN_POS[ 3 ],		Float: E_OPEN_ROT[ 3 ]
}

new
	g_bankvaultData					[ ] [ E_BANKDOOR_DATA ] =
	{
		{ "San Fierro Bank", 	INVALID_OBJECT_ID, false, 0, 0, 23, { -1413.956, 859.16560, 984.71260 }, { -1412.56506, 859.2745360, 978.6328730 }, { -1000.000, -1000.00, -1000.0000 } },
		{ "Las Venturas Bank", 	INVALID_OBJECT_ID, false, 0, 0, 52, { 2116.3513, 1233.0250, 1017.1369 }, { 2113.391357, 1233.155273, 1016.122619 }, { 90.000000, 0.000000, -90.000000 } },
		{ "Los Santos Bank", 	INVALID_OBJECT_ID, false, 0, 0, 56, { 2116.3513, 1233.0250, 1017.1369 }, { 2113.391357, 1233.155273, 1016.122619 }, { 90.000000, 0.000000, -90.000000 } },
		{ "Militia Ship", 		INVALID_OBJECT_ID, false, 0, 0, 0, { -2372.6223, 1551.3984, 2.1172000 }, { -2371.41699, 1552.027709, -0.75281000 }, { 0.0000000, 0.000000, 28.0000000 } }
	}
;

/* ** Hooks ** */
hook OnScriptInit( )
{
	// Boat Hiest
	g_bankvaultData[ VAULT_BOAT ] [ E_OBJECT ] = CreateDynamicObject( 19435, -2371.416992, 1552.027709, 1.907187, 0.000000, 0.000000, 28.0000, g_bankvaultData[ VAULT_BOAT ] [ E_WORLD ] );
	SetDynamicObjectMaterial( g_bankvaultData[ VAULT_BOAT ] [ E_OBJECT ], 0, 18268, "mtbtrackcs_t", "mp_carter_cage", -1 );
	return 1;
}

hook OnServerUpdate( )
{
	// Replenish Vaults
	for( new i = 0; i < sizeof( g_bankvaultData ); i++ ) if ( g_bankvaultData[ i ] [ E_DISABLED ] && g_iTime > g_bankvaultData[ i ] [ E_TIMESTAMP_CLOSE ] )
	{
		StopDynamicObject	( g_bankvaultData[ i ] [ E_OBJECT ] );
		DestroyDynamicObject( g_bankvaultData[ i ] [ E_OBJECT ] );

		g_bankvaultData[ i ] [ E_TIMESTAMP_CLOSE ] = 0;
		g_bankvaultData[ i ] [ E_DISABLED ] = false;

		switch ( i )
		{
			case CITY_SF: SetDynamicObjectMaterial( ( g_bankvaultData[ i ] [ E_OBJECT ] = CreateDynamicObject( 18766, -1412.565063, 859.274536, 983.132873, 0.000000, 90.000000, 90.000000 ) ), 0, 18268, "mtbtrackcs_t", "mp_carter_cage", -1 );
			case CITY_LV: g_bankvaultData[ i ] [ E_OBJECT ] = CreateDynamicObject( 2634, 2114.742431, 1233.155273, 1017.616821, 0.000000, 0.000000, -90.000000, g_bankvaultData[ i ] [ E_WORLD ] );
			case CITY_LS: g_bankvaultData[ i ] [ E_OBJECT ] = CreateDynamicObject( 2634, 2114.742431, 1233.155273, 1017.616821, 0.000000, 0.000000, -90.000000, g_bankvaultData[ i ] [ E_WORLD ] );
			case VAULT_BOAT: SetDynamicObjectMaterial( ( g_bankvaultData[ VAULT_BOAT ] [ E_OBJECT ] = CreateDynamicObject( 19435, -2371.416992, 1552.027709, 1.907187, 0.000000, 0.000000, 28.0000, g_bankvaultData[ VAULT_BOAT ] [ E_WORLD ] ) ), 0, 18268, "mtbtrackcs_t", "mp_carter_cage", -1 );
		}
	}
	return 1;
}

hook OnPlayerUpdateEx( playerid )
{
	// Anti Camping In Vault
	if ( IsPlayerInBank( playerid ) )
	{
		if ( IsPlayerInArea( playerid, -1412.215209, -1400.443237, 853.086669, 865.716735 ) && !g_bankvaultData[ CITY_SF ] [ E_DISABLED ] )
		{
			SendServerMessage( playerid, "You've been moved as you've entered the vault whilst it's closed." );
			SetPlayerPos( playerid, -1416.3499, 859.2744, 984.7126 );
		}

		if ( IsPlayerInArea( playerid, 2102.2590, 2113.5295, 1229.8595, 1246.2588 ) )
		{
			new
				world = GetPlayerVirtualWorld( playerid );

			if ( ( world == g_bankvaultData[ CITY_LV ] [ E_WORLD ] && !g_bankvaultData[ CITY_LV ] [ E_DISABLED ] ) || ( world == g_bankvaultData[ CITY_LS ] [ E_WORLD ] && !g_bankvaultData[ CITY_LS ] [ E_DISABLED ] ) )
			{
				SendServerMessage( playerid, "You've been moved as you've entered the vault whilst it's closed." );
				SetPlayerPos( playerid, 2121.7827, 1233.3225, 1017.1369 );
			}
		}
	}
	return 1;
}

hook OnPlayerC4Blown( playerid, Float: X, Float: Y, Float: Z, worldid )
{
	// check if blown up various vaults
	for( new j = 0; j < sizeof( g_bankvaultData ); j++ )
	{
		// Blow Bank Vault
		if ( IsPointToPoint( 5.0, X, Y, Z, g_bankvaultData[ j ] [ E_EXPLODE_POS ] [ 0 ], g_bankvaultData[ j ] [ E_EXPLODE_POS ] [ 1 ], g_bankvaultData[ j ] [ E_EXPLODE_POS ] [ 2 ] ) && !g_bankvaultData[ j ] [ E_DISABLED ] && worldid == g_bankvaultData[ j ] [ E_WORLD ] )
		{
			if ( g_iTime > g_bankvaultData[ j ] [ E_TIMESTAMP ] )
			{
				g_bankvaultData[ j ] [ E_TIMESTAMP_CLOSE ]	= g_iTime + 240; // time to close
				g_bankvaultData[ j ] [ E_TIMESTAMP ] 		= g_iTime + 600; // time to restore
				g_bankvaultData[ j ] [ E_DISABLED ] 		= true;

				MoveDynamicObject( g_bankvaultData[ j ] [ E_OBJECT ], g_bankvaultData[ j ] [ E_OPEN_POS ] [ 0 ], g_bankvaultData[ j ] [ E_OPEN_POS ] [ 1 ], g_bankvaultData[ j ] [ E_OPEN_POS ] [ 2 ], 2.0, g_bankvaultData[ j ] [ E_OPEN_ROT ] [ 0 ], g_bankvaultData[ j ] [ E_OPEN_ROT ] [ 1 ], g_bankvaultData[ j ] [ E_OPEN_ROT ] [ 2 ] );

                GivePlayerExperience( playerid, E_ROBBERY, 2.0 );
				GivePlayerScore( playerid, 3 );
				GivePlayerWantedLevel( playerid, 24 );
				ach_HandleBankBlown( playerid );

				if ( j == VAULT_BOAT ) {
					TriggerClosestCivilians( playerid, GetClosestRobberyNPC( getClosestRobberySafe( playerid ) ) );
				}

				SendGlobalMessage( -1, ""COL_GREY"[SERVER]"COL_WHITE" %s(%d) has destroyed the "COL_GREY"%s Vault{FFFFFF}!", ReturnPlayerName( playerid ), playerid, g_bankvaultData[ j ] [ E_NAME ] );
				break;
			}
		}
	}
	return 1;
}

/* ** Commands ** */
CMD:banks( playerid, params[ ] )
{
	erase( szBigString );

	for( new i = 0, time = g_iTime; i < sizeof( g_bankvaultData ); i++ ) {
		if ( g_bankvaultData[ i ] [ E_TIMESTAMP ] < time )
			format( szBigString, sizeof( szBigString ), "%s"COL_GREY"%s"COL_WHITE"\t"COL_GREEN"Available To Rob!\n", szBigString, g_bankvaultData[ i ] [ E_NAME ] );
		else
			format( szBigString, sizeof( szBigString ), "%s"COL_GREY"%s"COL_WHITE"\t%s\n", szBigString, g_bankvaultData[ i ] [ E_NAME ], secondstotime( g_bankvaultData[ i ] [ E_TIMESTAMP ] - time ) );
	}
	ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_TABLIST, "{FFFFFF}Banks", szBigString, "Okay", "" );
	return 1;
}

/* ** Functions ** */
stock GetBankVaultWorld( city ) {
	return g_bankvaultData[ city ] [ E_WORLD ];
}
