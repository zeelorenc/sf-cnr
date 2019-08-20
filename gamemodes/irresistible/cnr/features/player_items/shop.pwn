/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\shop.pwn
 * Purpose: shop system for in-game items
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Variables ** */
enum E_SHOP_ITEMS
{
	SHOP_ITEM_DRAIN_CLEANER,
	SHOP_ITEM_STONE_CLEANER,
	SHOP_ITEM_GAS_TANK,
	SHOP_ITEM_CHASITY_BELT,
	SHOP_ITEM_SECURE_WALLET,
	SHOP_ITEM_SCISSOR,
	SHOP_ITEM_ROPES,
	SHOP_ITEM_FOIL,
	SHOP_ITEM_BOBBY_PIN,
	SHOP_ITEM_MONEY_CASE,
	SHOP_ITEM_DRILL,
	SHOP_ITEM_METAL_MELTER,
	SHOP_ITEM_WEED_SEED,
	SHOP_ITEM_FIREWORKS,
	SHOP_ITEM_BOOMBOX
}

enum E_SHOP_DATA
{
	E_SHOP_ITEMS: E_ID,		bool: E_SAVABLE, 	E_NAME[ 24 ],
	E_USAGE[ 32 ], 			E_LIMIT, 			E_PRICE
};

new
	g_shopItemData 					[ ] [ E_SHOP_DATA ] =
	{
 		{ SHOP_ITEM_DRAIN_CLEANER,	true , "Drain Cleaner", 	"Caustic Soda",				 	16,		190 },
 		{ SHOP_ITEM_STONE_CLEANER,	true , "Stone Cleaner",		"Muriatic Acid", 			 	16,		275 },
 		{ SHOP_ITEM_GAS_TANK,	 	true , "Gas Tank",			"Hydrogen Chloride", 		 	16,		330 },
 		{ SHOP_ITEM_CHASITY_BELT,	false, "Chastity Belt", 	"Protection from aids", 	 	1,		550 },
 		{ SHOP_ITEM_SECURE_WALLET,	false, "Secure Wallet", 	"Protection from robberies",  	1,		660 },
 		{ SHOP_ITEM_WEED_SEED,	 	false, "Weed Seed",			"Grow weed", 		 			8,		750 },
 		{ SHOP_ITEM_SCISSOR,	 	true , "Scissors", 			"Automatically cut ties", 		8,		1100 },
 		{ SHOP_ITEM_ROPES,	 		true , "Rope", 				"/tie", 					 	8,		1500 },
 		{ SHOP_ITEM_BOBBY_PIN,	 	true , "Bobby Pin", 		"Automatically break cuffs", 	16,		1950 }, // [1000] -makecopgreatagain
 		{ SHOP_ITEM_FOIL,	 		true , "Aluminium Foil", 	"Automatically deflect EMP",	8,		3400 },
 		{ SHOP_ITEM_MONEY_CASE,		false, "Money Case", 		"Increases robbing amount", 	1,		4500 }, // [1250]
 		{ SHOP_ITEM_DRILL,	 		true , "Thermal Drill", 	"Halves safe cracking time",  	1,		5000 },
 		{ SHOP_ITEM_METAL_MELTER,	true , "Metal Melter", 		"/breakout", 				 	4,		7500 },
 		{ SHOP_ITEM_FIREWORKS,		true , "Firework", 			"/fireworks", 				 	0,		50000 },
		{ SHOP_ITEM_BOOMBOX,		false, "Boombox",			"/boombox",						1,		15000 }
	},
	g_playerShopItems 				[ MAX_PLAYERS ] [ E_SHOP_ITEMS ] // gradually move to this
;

/* ** Hooks ** */
hook OnPlayerDisconnect( playerid, reason )
{
	for ( new i = 0; i < sizeof( g_shopItemData ); i ++ ) {
		g_playerShopItems[ playerid ] [ E_SHOP_ITEMS: i ] = 0;
	}
	return 1;
}

hook OnDialogResponse( playerid, dialogid, response, listitem, inputtext[ ] )
{
	if ( dialogid == DIALOG_SHOP_MENU && response )
    {
	    if ( IsPlayerJailed( playerid ) ) return SendError( playerid, "You cannot use this while you're in jail." );

        if ( g_shopItemData[ listitem ] [ E_LIMIT ] <= 1 )
        {
        	ShowPlayerShopMenu( playerid );

        	if ( GetPlayerCash( playerid ) < g_shopItemData[ listitem ] [ E_PRICE ] ) return SendError( playerid, "You don't have enough money for this item." );

        	switch( g_shopItemData[ listitem ] [ E_ID ] )
        	{
        		case SHOP_ITEM_CHASITY_BELT:
        		{
        			if ( p_AidsVaccine{ playerid } == true ) return SendError( playerid, "You have already purchased this item." );
        			p_AidsVaccine{ playerid } = true;
        		}
        		case SHOP_ITEM_SECURE_WALLET:
        		{
        			if ( p_SecureWallet{ playerid } == true ) return SendError( playerid, "You have already purchased this item." );
        			p_SecureWallet{ playerid } = true;
        		}
        		case SHOP_ITEM_MONEY_CASE:
        		{
        			if ( p_MoneyBag{ playerid } == true ) return SendError( playerid, "You have already purchased this item." );
					if ( p_Class[ playerid ] != CLASS_POLICE ) SetPlayerAttachedObject( playerid, 1, 1210, 7, 0.302650, -0.002469, -0.193321, 296.124053, 270.396881, 8.941717, 1.000000, 1.000000, 1.000000 );
        			p_MoneyBag{ playerid } = true;
        		}
        		case SHOP_ITEM_DRILL:
        		{
        			if ( p_drillStrength[ playerid ] == MAX_DRILL_STRENGTH ) return SendError( playerid, "You have already purchased this item." );
        			p_drillStrength[ playerid ] = MAX_DRILL_STRENGTH;
        		}
        		case SHOP_ITEM_FIREWORKS:
        		{
        			GivePlayerFireworks( playerid, 1 );
        		}
				case SHOP_ITEM_BOOMBOX:
				{
					if ( GetPlayerBoombox( playerid ) ) return SendError( playerid, "You have already purchased this item." );
					SetPlayerBoombox( playerid, true );
				}
        	}
			GivePlayerCash( playerid, -( g_shopItemData[ listitem ] [ E_PRICE ] ) );
			SendServerMessage( playerid, "You have bought a "COL_GREY"%s"COL_WHITE" for "COL_GOLD"%s"COL_WHITE".", g_shopItemData[ listitem ] [ E_NAME ], cash_format( g_shopItemData[ listitem ] [ E_PRICE ] ) );
        }
        else
       	{
       		SetPVarInt( playerid, "shop_item", listitem );
       		ShowPlayerDialog( playerid, DIALOG_SHOP_AMOUNT, DIALOG_STYLE_LIST, "{FFFFFF}Shop Items - Buy Quantity", "Buy 1\nBuy 5\nBuy Max", "Select", "Back" );
       	}
    }
    else if ( dialogid == DIALOG_SHOP_AMOUNT )
    {
    	if ( response )
    	{
	    	if ( IsPlayerJailed( playerid ) ) return SendError( playerid, "You cannot use this while you're in jail." );

    		new
    			iAmount = 1,

    			i = GetPVarInt( playerid, "shop_item" ),
    			iCurrentQuantity = GetShopItemAmount( playerid, i ),

    			iLimit = g_shopItemData[ i ] [ E_LIMIT ] + ( 2 * p_VIPLevel[ playerid ] )
    		;

    		switch( listitem )
    		{
    			case 0: iAmount = 1;
    			case 1: iAmount = 5;
    			case 2: iAmount = iLimit;
    		}

    		if ( iLimit != 0 && ( iCurrentQuantity + iAmount ) > iLimit )
    		{
    			// Specified more than he can carry!
    			if ( ( iAmount = iLimit - iCurrentQuantity ) != 0 )
    				SendServerMessage( playerid, "You've breached the quantity limit therefore we have set it to %d.", iAmount );
    		}

    		if ( GetPlayerCash( playerid ) < ( g_shopItemData[ i ] [ E_PRICE ] * iAmount ) ) SendError( playerid, "You cannot afford the price of the item(s)." );
    		else if ( iAmount <= 0 ) SendError( playerid, "You cannot buy anymore of this item." );
    		else {
    			new total_cost = g_shopItemData[ i ] [ E_PRICE ] * iAmount;
    			SetPlayerShopItemAmount( playerid, i, iCurrentQuantity + iAmount );
    			GivePlayerCash( playerid, -total_cost );
				StockMarket_UpdateEarnings( E_STOCK_SUPA_SAVE, total_cost, 0.25 );
				SendServerMessage( playerid, "You have bought %dx "COL_GREY"%s"COL_WHITE" for "COL_GOLD"%s"COL_WHITE".", iAmount, g_shopItemData[ i ] [ E_NAME ], cash_format( total_cost ) );
    		}

    		ShowPlayerDialog( playerid, DIALOG_SHOP_AMOUNT, DIALOG_STYLE_LIST, "{FFFFFF}Shop Items - Buy Quantity", "Buy 1\nBuy 5\nBuy Max", "Select", "Back" );
    	}
    	else ShowPlayerShopMenu( playerid );
    }
	return 1;
}

/* ** Functions ** */
stock ShowPlayerShopMenu( playerid )
{
	static szString[ 1024 ];

	if ( szString[ 0 ] == '\0' )
	{
		strcat( szString, " \t"COL_GREY"Grey options do not save!\t \n" );
		for( new i; i < sizeof( g_shopItemData ); i++ ) {
	 		format( szString, sizeof( szString ), "%s%s%s\t"COL_ORANGE"%s\t"COL_GOLD"%s\n", szString, g_shopItemData[ i ] [ E_SAVABLE ] ? ( COL_WHITE ) : ( COL_GREY ), g_shopItemData[ i ] [ E_NAME ], g_shopItemData[ i ] [ E_USAGE ], cash_format( g_shopItemData[ i ] [ E_PRICE ] ) );
		}
	}
	return ShowPlayerDialog( playerid, DIALOG_SHOP_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Shop Items", szString, "Select", "Cancel" );
}

stock GetShopItemAmount( playerid, id )
{
	switch( g_shopItemData[ id ] [ E_ID ] )
	{
		case SHOP_ITEM_DRAIN_CLEANER: return GetPlayerCausticSoda( playerid );
		case SHOP_ITEM_STONE_CLEANER: return GetPlayerMuriaticAcid( playerid );
		case SHOP_ITEM_GAS_TANK: return GetPlayerHydrogenChloride( playerid );
		case SHOP_ITEM_CHASITY_BELT: return p_AidsVaccine{ playerid };
		case SHOP_ITEM_SECURE_WALLET: return p_SecureWallet{ playerid };
		case SHOP_ITEM_SCISSOR: return p_Scissors[ playerid ];
		case SHOP_ITEM_BOBBY_PIN: return p_BobbyPins[ playerid ];
		case SHOP_ITEM_MONEY_CASE: return p_MoneyBag{ playerid };
		case SHOP_ITEM_ROPES: return p_Ropes[ playerid ];
		case SHOP_ITEM_FOIL: return p_AntiEMP[ playerid ];
		case SHOP_ITEM_DRILL: return p_drillStrength[ playerid ];
		case SHOP_ITEM_METAL_MELTER: return p_MetalMelter[ playerid ];
		case SHOP_ITEM_WEED_SEED: return g_playerShopItems[ playerid ] [ SHOP_ITEM_WEED_SEED ];
		case SHOP_ITEM_FIREWORKS: return p_Fireworks[ playerid ];
		case SHOP_ITEM_BOOMBOX: return GetPlayerBoombox( playerid );
	}
	return 0;
}

stock SetPlayerShopItemAmount( playerid, id, value )
{
	switch( g_shopItemData[ id ] [ E_ID ] )
	{
		case SHOP_ITEM_DRAIN_CLEANER: SetPlayerCausticSoda( playerid, value );
		case SHOP_ITEM_STONE_CLEANER: SetPlayerMuriaticAcid( playerid, value );
		case SHOP_ITEM_GAS_TANK: SetPlayerHydrogenChloride( playerid, value );
		case SHOP_ITEM_CHASITY_BELT: p_AidsVaccine{ playerid } = !!value;
		case SHOP_ITEM_SECURE_WALLET: p_SecureWallet{ playerid } = !!value;
		case SHOP_ITEM_SCISSOR: p_Scissors[ playerid ] = value;
		case SHOP_ITEM_BOBBY_PIN: p_BobbyPins[ playerid ] = value;
		case SHOP_ITEM_MONEY_CASE: p_MoneyBag{ playerid } = !!value;
		case SHOP_ITEM_ROPES: p_Ropes[ playerid ] = value;
		case SHOP_ITEM_FOIL: p_AntiEMP[ playerid ] = value;
		case SHOP_ITEM_DRILL: p_drillStrength[ playerid ] = value;
		case SHOP_ITEM_METAL_MELTER: p_MetalMelter[ playerid ] = value;
		case SHOP_ITEM_WEED_SEED: g_playerShopItems[ playerid ] [ SHOP_ITEM_WEED_SEED ] = value;
		case SHOP_ITEM_FIREWORKS: p_Fireworks[ playerid ] = value;
		case SHOP_ITEM_BOOMBOX: SetPlayerBoombox( playerid, !!value );
	}
	return 1;
}

stock GivePlayerShopItem( playerid, E_SHOP_ITEMS: itemid, amount ) {
	g_playerShopItems[ playerid ] [ itemid ] += amount;
}

stock GetPlayerShopItemAmount( playerid, E_SHOP_ITEMS: itemid ) {
	return g_playerShopItems[ playerid ] [ itemid ];
}

stock GetShopItemCost( E_SHOP_ITEMS: item_id )
{
	for ( new i = 0; i < sizeof( g_shopItemData ); i ++ ) if ( g_shopItemData[ i ] [ E_ID ] == item_id ) {
		return g_shopItemData[ i ] [ E_PRICE ];
	}
	return 1;
}

stock GetShopItemLimit( E_SHOP_ITEMS: item_id )
{
	for ( new i = 0; i < sizeof( g_shopItemData ); i ++ ) if ( g_shopItemData[ i ] [ E_ID ] == item_id ) {
		return g_shopItemData[ i ] [ E_LIMIT ];
	}
	return 1;
}
