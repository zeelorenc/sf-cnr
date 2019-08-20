/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module:
 * Purpose:
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define MENU_ASSAULT      			( 0 )
#define MENU_MELEE					( 1 )
#define MENU_SUB_SMGS				( 2 )
#define MENU_PISTOLS				( 3 )
#define MENU_RIFLES					( 4 )
#define MENU_SHOTGUNS				( 5 )
#define MENU_THROWN					( 6 )
#define MENU_SPECIAL 				( 7 )

/* ** Variables ** */
enum E_WEAPONS_DATA
{
	E_MENU, 				E_NAME[ 32 ],           E_WEPID,
	E_AMMO,					E_PRICE
};

new
	g_AmmunitionCategory[ ] [ ] =
	{
		{ "Assault" },  { "Melee" }, { "Submachine Guns" }, { "Pistols" },
		{ "Rifles" }, { "Shotguns" }, { "Thrown" }, { "Special" }
	},
	g_AmmunationWeapons[ ][ E_WEAPONS_DATA ] =
	{
		{ MENU_MELEE,		"Flowers", 			14,		1, 		75 },
		{ MENU_MELEE,		"Shovel", 			6,		1, 		100 },
		{ MENU_MELEE,		"Pool Cue", 		7,		1, 		125 },
		{ MENU_MELEE,		"Golf Club", 		2,		1, 		125 },
		{ MENU_MELEE,		"Baseball Bat", 	5,		1, 		180 },
		{ MENU_MELEE, 		"Brass Knuckles", 	1,		1, 		200 },
		{ MENU_MELEE,		"Parachute", 		46,		1, 		200 },
		{ MENU_MELEE, 		"Camera",			43, 	1,		250 },
		//{ MENU_MELEE,		"Knife", 			4,		1, 		300 },
		{ MENU_MELEE,		"Katana", 			8,		1, 		600 },
		{ MENU_MELEE,		"Chainsaw", 		9,		1, 		750 },

		{ MENU_PISTOLS,		"9mm Pistol", 		22,		180, 	200 },
		{ MENU_PISTOLS,		"Silenced 9mm", 	23,		180, 	400 },
		{ MENU_PISTOLS,		"Desert Eagle", 	24,		100, 	1250 },

		{ MENU_SHOTGUNS,	"Shotgun", 			25,		75, 	600  },
		{ MENU_SHOTGUNS,	"Sawn-off Shotgun",	26,		100,	1200 },
		{ MENU_SHOTGUNS,	"Combat Shotgun", 	27,		100,	1800 },

		{ MENU_SUB_SMGS,	"MP5", 				29,		250,	500  },
		{ MENU_SUB_SMGS,	"Tec 9", 			32,		250,	600  },
		{ MENU_SUB_SMGS,	"Mac 10", 			28,		250,	700 },

		{ MENU_ASSAULT,		"AK47", 			30,		250,	800  },
		{ MENU_ASSAULT,		"M4", 				31,		250,	1000 },

		{ MENU_RIFLES,		"Rifle", 			33,		100, 	300  },
		{ MENU_RIFLES,		"Sniper", 			34,		75, 	1000 },

		{ MENU_THROWN, 		"Teargas",			17,		5,		500 },
		{ MENU_THROWN, 		"Grenade",			16,		5,		1200 },
		{ MENU_THROWN, 		"Molotov Cocktail",	18,		5,		1400 },

		{ MENU_SPECIAL,	 	"Explosive Round",	102,	2,		20000 },
		{ MENU_SPECIAL,		"Armor", 			101, 	100, 	12500 },
		{ MENU_SPECIAL,		"RPG",				35,		2,		10000 }
	},
 	p_AmmunationMenu               [ MAX_PLAYERS char ]
;

/* ** Functions ** */
stock RedirectAmmunation( playerid, listitem, custom_title[ ] = "{FFFFFF}Ammu-Nation", custom_dialogid = DIALOG_AMMU_BUY, Float: custom_multplier = 1.0, ammo_multiplier = 1 )
{
	new
		szString[ 420 ];

	if ( listitem == MENU_SPECIAL ) szString = ""COL_WHITE"Item\t"COL_WHITE"Price\n";
	else szString = ""COL_WHITE"Weapon\t"COL_WHITE"Ammo\t"COL_WHITE"Price\n";

	for( new i; i < sizeof( g_AmmunationWeapons ); i++ ) if ( g_AmmunationWeapons[ i ] [ E_MENU ] == listitem )
	{
	   	if ( listitem != MENU_SPECIAL ) { // Other multipliers will not specify ammo
	   		format( szString, sizeof( szString ), "%s%s\t%d\t", szString, g_AmmunationWeapons[ i ] [ E_NAME ], listitem == MENU_MELEE ? 1 : ( g_AmmunationWeapons[ i ] [ E_AMMO ] * ammo_multiplier ) );
		} else {
			format( szString, sizeof( szString ), "%s%s\t", szString, g_AmmunationWeapons[ i ] [ E_NAME ] );
		}

		// check for free or not
		if ( custom_multplier > 0.0 ) {
			format( szString, sizeof( szString ), "%s"COL_GOLD"%s\n", szString, cash_format( floatround( g_AmmunationWeapons[ i ] [ E_PRICE ] * custom_multplier ) ) );
		} else {
			strcat( szString, ""COL_GOLD"FREE\n" );
		}
	}
    ShowPlayerDialog( playerid, custom_dialogid, DIALOG_STYLE_TABLIST_HEADERS, custom_title, szString, "Purchase", "Back" );
    return 1;
}

stock ShowAmmunationMenu( playerid, custom_title[ ] = "{FFFFFF}Ammu-Nation", custom_dialogid = DIALOG_AMMU )
{
	static
		szString[ 70 ];

	if ( !szString[ 0 ] )
	{
	    for( new i = 0; i < sizeof( g_AmmunitionCategory ); i++ ) {
	     	format( szString, sizeof( szString ), "%s%s\n", szString, g_AmmunitionCategory[ i ] );
	    }
	}
	return ShowPlayerDialog( playerid, custom_dialogid, DIALOG_STYLE_LIST, custom_title, szString, "Select", "Cancel" );
}
