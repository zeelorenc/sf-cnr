/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\houses\furniture.pwn
 * Purpose: furniture module for homes
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define MAX_FURNITURE 				( 50 )

// Furniture Categories
#define FC_DOORS        0
#define FC_TABLECHAIR   1
#define FC_FITNESS      2
#define FC_KITCHENBATH  3
#define FC_ELECTRONIC   4
#define FC_BEDROOM      5
#define FC_LOUNGE       6
#define FC_FLOWERS      7
#define FC_MISC         8
#define FC_WEAPONS		9
#define FC_HOLIDAYS 	10
#define FC_FOODRINK 	11

/* ** Variables ** */
enum E_FURINTURE_DATA
{
	E_CATEGORY,			E_NAME[ 21 ],       E_MODEL,
	E_COST
};

new
  	g_furnitureCategory[ ] [ ] =
	{
	    { "Doors" }, { "Tables and Chairs" }, { "Fitness" }, { "Kitchen and Bathroom" }, { "Electronics" }, { "Bedroom" },
	    { "Lounge" }, { "Flowers and Plants" }, { "Miscellaneous" }, { "Weapons" }, { "Holiday" }, { "Food/Drink" }
	},
	g_houseFurniture[ ] [ E_FURINTURE_DATA ] =
	{
		// Doors
	    { FC_DOORS, 		"Red Door", 			1504, 175 },
	    { FC_DOORS, 		"Blue Door", 			1505, 175 },
	    { FC_DOORS, 		"White Door", 			1506, 175 },
	    { FC_DOORS, 		"Yellow Door", 			1507, 175 },
	    // Tables and Chairs
  	  	{ FC_TABLECHAIR, 	"Wooden Open Table", 	1817, 50 },
	    { FC_TABLECHAIR,    "Dining Chair",         2079, 60 },
	    { FC_TABLECHAIR,    "Office Chair",         1806, 62 },
	    { FC_TABLECHAIR, 	"Wooden Circle Table", 	1815, 75 },
		{ FC_TABLECHAIR, 	"Cluckin' Table Sml",	2763, 80 },
		{ FC_TABLECHAIR, 	"Cluckin' Table", 		2762, 125 },
		{ FC_TABLECHAIR,    "Dining Table",         2115, 135 },
		{ FC_TABLECHAIR,    "Circle Dining Chair",  2125, 135 },
		{ FC_TABLECHAIR,    "Circle Dining Table",  2030, 150 },
		{ FC_TABLECHAIR,    "Swivel Chair",      	1663, 180 },
		{ FC_TABLECHAIR, 	"Rocking Chair", 		11734, 200 },
		{ FC_TABLECHAIR, 	"Gamer Chair", 			19999, 320 },
		{ FC_TABLECHAIR, 	"Poker Table", 			19474, 500 },
		{ FC_TABLECHAIR, 	"Lab Table",			3383, 900 },
		// Fitness
	    { FC_FITNESS, 		"Mattress #1", 			2815, 50 },
	    { FC_FITNESS, 		"Mattress #2", 			2817, 50 },
	    { FC_FITNESS, 		"Mattress #3", 			2833, 50 },
	    { FC_FITNESS, 		"Mattress #4", 			2836, 50 },
	    { FC_FITNESS, 		"Mattress #5", 			2847, 50 },
	    { FC_FITNESS, 		"Cycle", 				2630, 950 },
	    { FC_FITNESS, 		"Treadmill", 			2627, 1250 },
	    { FC_FITNESS, 		"Weight Lifting", 		2628, 1550 },
	    // Kitchen and Bathroom
		{ FC_KITCHENBATH, 	"Soap", 				19874, 15 },
		{ FC_KITCHENBATH, 	"Toilet Paper", 		19873, 20 },
		{ FC_KITCHENBATH, 	"Towel holder", 		11707, 300 },
	    { FC_KITCHENBATH,	"Double Metal Cabin", 	2007, 400 },
	    { FC_KITCHENBATH,	"Metal Shelf x4", 		2063, 400 },
	    { FC_KITCHENBATH,	"Metal Table", 			941, 500 },
	    { FC_KITCHENBATH,	"Metal Counter", 		937, 600 },
	    { FC_KITCHENBATH,	"Metal Bench-top", 		936, 685 },
	    { FC_KITCHENBATH,	"Toilet",  				2514, 700 },
	    { FC_KITCHENBATH,	"Bathroom Sink", 		2523, 900 },
	    { FC_KITCHENBATH,   "Wooden Double Draw", 	2139, 910 },
	    { FC_KITCHENBATH,   "Wooden Low-unit",      2138, 925 },
	    { FC_KITCHENBATH,	"Washing Machine", 		1208, 925 },
	    { FC_KITCHENBATH,   "Laundry Unit",         2303, 980 },
	    { FC_KITCHENBATH,	"White Bath Tub",		2519, 1000 },
	    { FC_KITCHENBATH,   "Corner Wooden Bench",	2305, 1100 },
	    { FC_KITCHENBATH,   "Wooden Bench w/ Sink", 2136, 1185 },
	    { FC_KITCHENBATH,   "Stable Counter",       2339, 1200 },
	    { FC_KITCHENBATH,	"Bath Tub", 			2526, 1200 },
	    { FC_KITCHENBATH,	"Shower System",		14481, 1290 },
	    { FC_KITCHENBATH,   "Stable Shelf",       	2141, 1300 },
	    { FC_KITCHENBATH,   "Stable Sink",          2132, 1500 },
		{ FC_KITCHENBATH, 	"Love Spa", 			11732, 2000 },
	    { FC_KITCHENBATH,   "Cooker and Oven",      2135, 2200 },
	    { FC_KITCHENBATH,	"Deep Fryer", 			2413, 2300 },
		// Electronics
		{ FC_ELECTRONIC, 	"Blender", 				19830, 120 },
	    { FC_ELECTRONIC,	"Mini Stereo Speaker", 	2233, 450 },
		{ FC_ELECTRONIC, 	"Coffee Machine", 		11743, 500 },
	    { FC_ELECTRONIC,	"Red Guitar",          	19317, 650 },
	    { FC_ELECTRONIC,	"White Guitar",        	19318, 675 },
	    { FC_ELECTRONIC,	"Bass speaker", 		2229, 675 },
	    { FC_ELECTRONIC,	"Black Guitar",       	19319, 700 },
	    { FC_ELECTRONIC,	"8 Bit TV", 			1748, 700 },
	    { FC_ELECTRONIC,	"VCR Player", 			1719, 900 },
	    { FC_ELECTRONIC, 	"Gaming Console",		2028, 1000 },
	    { FC_ELECTRONIC, 	"Small TV with VCR",	2595, 1100 },
		{ FC_ELECTRONIC, 	"Laptop", 				19893, 1250 },
	    { FC_ELECTRONIC,	"TV Small", 			1518, 1575 },
	    { FC_ELECTRONIC, 	"Swank TV",				1792, 1600 },
	    { FC_ELECTRONIC,	"TV with Wall Hook", 	2596, 1790 },
	    { FC_ELECTRONIC,    "TV With Stance",       1717, 2000 },
	    { FC_ELECTRONIC, 	"Doozy TV with Stance",	2224, 2050 },
	    { FC_ELECTRONIC,	"Stereo System", 		2100, 2175 },
	    { FC_ELECTRONIC,	"Wide-screen TV", 		1786, 2500 },
		{ FC_ELECTRONIC, 	"Huge LCD", 			19786, 3000 },
	    { FC_ELECTRONIC,    "PC with Desk",     	2181, 3400 },
	    { FC_ELECTRONIC,	"Small TV Unit", 		2297, 3700 },
	    { FC_ELECTRONIC,    "TV Unit",              2296, 4000 },
		// Bedroom
	    { FC_BEDROOM,		"Wooden Stance", 		1743, 650 },
	    { FC_BEDROOM,		"Wooden Counter", 		1416, 750 },
	    { FC_BEDROOM,		"Wooden Drawer", 		1417, 800 },
	    { FC_BEDROOM,		"Hobo bed", 			1745, 800 },
	    { FC_BEDROOM,		"Luxurious bed", 		2298, 1300 },
	    { FC_BEDROOM,		"Super Luxurious bed", 	2563, 1750 },
		{ FC_BEDROOM, 		"Lavish Red Bed", 		11720, 2000 },
		{ FC_BEDROOM, 		"Love Bed", 			11731, 4200 },
		// Lounge
	    { FC_LOUNGE,		"Wooden Couch", 		1755, 275 },
	    { FC_LOUNGE,		"Couch", 				1754, 350 },
	    { FC_LOUNGE,		"Leather Couch",		1702, 500 },
	    { FC_LOUNGE,		"Single Couch", 		1704, 850 },
	    { FC_LOUNGE, 		"Luxury Mattress", 		1828, 900 },
	    { FC_LOUNGE,		"Bookshelf", 			1742, 1000 },
	    { FC_LOUNGE,		"Leather Couch",		1723, 1650 },
	    { FC_LOUNGE,		"TV Stand",				2313, 1700 },
		{ FC_LOUNGE, 		"Fireplace", 			11724, 4800 },
		{ FC_LOUNGE, 		"Chandelier",			19806, 5200 },
		// Flowers and plants
	    { FC_FLOWERS,		"Flower Plant 3", 		2001, 30 },
	    { FC_FLOWERS,		"Flower Plant 4", 		2253, 35 },
	    { FC_FLOWERS, 		"Clear Flower Vase",	2247, 35 },
	    { FC_FLOWERS,		"Painted Flower Vase", 	2251, 40 },
	    { FC_FLOWERS,		"Plant Vase", 			2245, 50 },
	    { FC_FLOWERS,		"Flower Wall-Mount", 	3810, 120 },
	    { FC_FLOWERS,		"Weed Plant", 			19473, 2250 },
		// Miscellaneous
		{ FC_MISC, 			"Chainsaw Dildo", 		19086, 69 },
		{ FC_MISC,			"Massive Die",			1851, 80 },
	    { FC_MISC,			"Deer Head Mount",   	1736, 120 },
	    { FC_MISC,			"Striped Surfboard",   	2404, 140 },
	    { FC_MISC,			"Beach Surfboard",     	2406, 150 },
	    { FC_MISC,			"Flamed Torch",       	3461, 175 },
		{ FC_MISC, 			"Rocking Unicorn", 		11733, 180 },
		{ FC_MISC, 			"Do Not Cross Tape",	19834, 250 },
		{ FC_MISC, 			"Grill",				19831, 300 },
	    { FC_MISC,			"Boxing Bag",         	1985, 300 },
		{ FC_MISC, 			"Car Engine", 			19917, 500 },
		{ FC_MISC, 			"Drum Kit",				19609, 800 },
		{ FC_MISC, 			"Mechanic Computer", 	19903, 1000 },
	    { FC_MISC,			"Pool Table",         	2964, 1250 },
		{ FC_MISC, 			"Cow",					19833, 1337 },
	    { FC_MISC,			"Deer", 				19315, 1337 },
	    { FC_MISC,			"Money Safe", 			2332, 2000 },
		{ FC_MISC, 			"Mechanic Shelves",		19899, 2000 },
	    { FC_MISC,			"Dance Floor", 			19128, 3250 },
	    { FC_MISC,			"Craps Table", 			1824, 4000 },
	    { FC_MISC, 			"Boxing Arena",			14781, 15000 },
	    // Weapons
		{ FC_WEAPONS, 		"Brass Knuckles", 		331, 25 },
		{ FC_WEAPONS,		"Pool Cue",				338, 40 },
		{ FC_WEAPONS, 		"Parachute", 			371, 60 },
		{ FC_WEAPONS, 		"Purple Dildo", 		321, 69 },
		{ FC_WEAPONS, 		"Sledge Hammer", 		19631, 90 },
		{ FC_WEAPONS, 		"Landmine", 			19602, 100 },
		{ FC_WEAPONS, 		"Ammo Box", 			19832, 120 },
		{ FC_WEAPONS, 		"Antique Sword", 		19590, 250 },
		{ FC_WEAPONS, 		"Mac 10", 				352, 250 },
		{ FC_WEAPONS, 		"Tec 9", 				372, 290 },
		{ FC_WEAPONS, 		"Rifle", 				357, 300 },
		{ FC_WEAPONS, 		"Desert Eagle", 		348, 500 },
		{ FC_WEAPONS, 		"Shotgun", 				349, 600 },
		{ FC_WEAPONS, 		"Sawn-off Shotgun", 	350, 800 },
		{ FC_WEAPONS, 		"Sniper", 				358, 800 },
		{ FC_WEAPONS, 		"Spas 12", 				351, 900 },
		{ FC_WEAPONS, 		"M4", 					356, 900 },
		{ FC_WEAPONS, 		"Minigun", 				362, 1337 },
		{ FC_WEAPONS, 		"Heatseeker", 			360, 1337 },
		{ FC_WEAPONS, 		"RPG", 					359, 1337 },
		// Holiday
		{ FC_HOLIDAYS, 		"Xmas Box 1", 			19054, 100 },
		{ FC_HOLIDAYS, 		"Xmas Box 2", 			19055, 100 },
		{ FC_HOLIDAYS, 		"Xmas Box 3", 			19056, 100 },
		{ FC_HOLIDAYS, 		"Xmas Box 4", 			19057, 100 },
		{ FC_HOLIDAYS, 		"Xmas Box 5", 			19058, 100 },
		{ FC_HOLIDAYS, 		"Witch Pot",			19527, 200 },
		{ FC_HOLIDAYS, 		"Devil Face",			11704, 666 },
		{ FC_HOLIDAYS, 		"Xmas Tree", 			19076, 777 },
		// Food/Drink
		{ FC_FOODRINK, 		"Pizza Box", 			19571, 10 },
		{ FC_FOODRINK, 		"Coffee Mug", 			19835, 15 },
		{ FC_FOODRINK, 		"Pizza", 				19580, 30 },
		{ FC_FOODRINK, 		"Ordinary Brandy", 		19821, 45 },
		{ FC_FOODRINK, 		"Fine Scotch", 			19823, 90 },
		{ FC_FOODRINK, 		"Beer Keg", 			19812, 150 },
		{ FC_FOODRINK, 		"Vintage Whiskey", 		19824, 155 },
		{ FC_FOODRINK, 		"Premium Brandy", 		19820, 190 },
		{ FC_FOODRINK, 		"Premium Wine", 		19822, 220 }
	},
	g_houseFurnitureData 			[ MAX_HOUSES ] [ MAX_FURNITURE ],
	Iterator: housefurniture 		[ MAX_HOUSES ] < MAX_FURNITURE >
;

/* ** Hooks ** */
hook OnScriptInit( )
{
	mysql_function_query( dbHandle, "SELECT * FROM `FURNITURE`", true, "OnFurnitureLoad", "" );
	return 1;
}

hook OnPlayerEditDynObject( playerid, objectid, response, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz )
{
	new
		houseid = p_InHouse[ playerid ];

    if ( houseid != -1 )
    {
	 	new editing_house = GetPVarInt( playerid, "furniture_house" );
	 	new editing_furniture = GetPVarInt( playerid, "furniture_id" );

	    if ( houseid != editing_house )
	   		return SendError( playerid, "There was an issue editing the furniture of this home, try again." );

	   	if ( ! IsPlayerHomeOwner( playerid, houseid ) )
	   	 	return SendError( playerid, "You are not the owner of this house." );

		static Float: lastX, Float: lastY, Float: lastZ;
		static Float: lastRX, Float: lastRY, Float: lastRZ;

		GetDynamicObjectPos( objectid, lastX, lastY, lastZ );
		GetDynamicObjectRot( objectid, lastRX, lastRY, lastRZ );

		switch ( response )
		{
		    case EDIT_RESPONSE_FINAL:
		    {
				SetDynamicObjectPos( objectid, x, y, z );
				SetDynamicObjectRot( objectid, rx, ry, rz );

				format( szBigString, sizeof( szBigString ), "UPDATE `FURNITURE` SET `X`=%f,`Y`=%f,`Z`=%f,`RX`=%f,`RY`=%f,`RZ`=%f WHERE `ID`=%d AND `HOUSE_ID`=%d", x, y, z, rx, ry, rz, editing_furniture, editing_house );
				mysql_single_query( szBigString );

				SendServerMessage( playerid, "Furniture has been successfully updated." );
	        	ShowPlayerDialog( playerid, DIALOG_FURNITURE, DIALOG_STYLE_LIST, "{FFFFFF}Furniture", "Purchase Furniture\nSelect Furniture Easily\nSelect Furniture Manually\nSelect Furniture Nearest\n"COL_RED"Remove All Furniture", "Confirm", "Back" );
			}
			case EDIT_RESPONSE_CANCEL:
			{
				SetDynamicObjectPos( objectid, lastX, lastY, lastZ );
				SetDynamicObjectRot( objectid, lastRX, lastRY, lastRZ );
				SendServerMessage( playerid, "You have canceled editing the piece of furniture selected." );
	        	ShowPlayerDialog( playerid, DIALOG_FURNITURE, DIALOG_STYLE_LIST, "{FFFFFF}Furniture", "Purchase Furniture\nSelect Furniture Easily\nSelect Furniture Manually\nSelect Furniture Nearest\n"COL_RED"Remove All Furniture", "Confirm", "Back" );
			}
		}
	}
	return 1;
}

hook OnDialogResponse( playerid, dialogid, response, listitem, inputtext[ ] )
{
	if ( dialogid == DIALOG_FURNITURE )
	{
		new houseid = p_InHouse[ playerid ];

	    if ( houseid == -1 )
	   		return SendError( playerid, "You're not inside any house." );

		if ( !IsPlayerHomeOwner( playerid, houseid ) )
	   	 	return SendError( playerid, "You are not the owner of this house." );

	    if ( response )
	    {
			switch( listitem )
			{
			    case 0: ShowFurnitureCategory( playerid );
			    case 1: SendServerMessage( playerid, "You are now editing your furniture. Simply drag your mouse over a piece of furniture and click to edit." ), SelectObject( playerid );
				case 2: ShowOwnedFurnitureList( playerid, houseid );
				case 3:
				{
					new fhandle = ITER_NONE;
				    new i = GetClosestFurniture( houseid, playerid, .furniture_handle = fhandle );
				    if ( i == INVALID_OBJECT_ID || fhandle == ITER_NONE ) return SendError( playerid, "There are no nearby furniture." );
			    	SetPVarInt( playerid, "furniture_house", houseid );
			    	SetPVarInt( playerid, "furniture_id", fhandle );
					ShowPlayerDialog( playerid, DIALOG_FURNITURE_OPTION, DIALOG_STYLE_LIST, "Furniture", "Use Editor\nEdit Rotation X\nEdit Rotation Y\nEdit Rotation Z\nSell Object", "Select", "Back" );
      			}
      			case 4: ShowPlayerDialog( playerid, DIALOG_TRUNCATE_FURNITURE, DIALOG_STYLE_MSGBOX, "Furniture", ""COL_WHITE"Are you sure you want to truncate your furniture?", "Confirm", "Back" );
			}
	    }
	    else
	    {
	    	if ( p_InHouse[ playerid ] != -1 ) return cmd_h( playerid, "config" );
	    	return cmd_flat( playerid, "config" );
	    }
	}
	else if ( dialogid == DIALOG_TRUNCATE_FURNITURE )
	{
	    if ( p_InHouse[ playerid ] == -1 )
	   		return SendError( playerid, "You're not inside any house." );

		if ( !strmatch( g_houseData[ p_InHouse[ playerid ] ] [ E_OWNER ], ReturnPlayerName( playerid ) ) )
	   	 	return SendError( playerid, "You are not the owner of this house." );

		if ( response )
	   	 	destroyAllFurniture( p_InHouse[ playerid ] );

		return ShowPlayerDialog( playerid, DIALOG_FURNITURE, DIALOG_STYLE_LIST, "{FFFFFF}Furniture", "Purchase Furniture\nSelect Furniture Easily\nSelect Furniture Manually\nSelect Furniture Nearest\n"COL_RED"Remove All Furniture", "Confirm", "Back" );
	}
	else if ( dialogid == DIALOG_FURNITURE_CATEGORY )
	{
		if ( !response ) return ShowPlayerDialog( playerid, DIALOG_FURNITURE, DIALOG_STYLE_LIST, "{FFFFFF}Furniture", "Purchase Furniture\nSelect Furniture Easily\nSelect Furniture Manually\nSelect Furniture Nearest\n"COL_RED"Remove All Furniture", "Confirm", "Back" );
		ShowFurnitureList( playerid, listitem );
		p_FurnitureCategory{ playerid } = listitem;
	}
	else if ( dialogid == DIALOG_FURNITURE_MAN_SEL )
	{
	    if ( response )
	    {
	    	new houseid = p_InHouse[ playerid ];

		    if ( houseid == -1 )
		   		return SendError( playerid, "You're not inside any house." );

			if ( !IsPlayerHomeOwner( playerid, houseid ) )
		   	 	return SendError( playerid, "You are not the owner of this house." );

		   	new x = 0;

		   	foreach ( new fhandle : housefurniture[ houseid ] )
			{
				new objectid = g_houseFurnitureData[ houseid ] [ fhandle ];

				if ( IsValidDynamicObject( objectid ) )
				{
				    if ( x == listitem )
				    {
				    	SetPVarInt( playerid, "furniture_house", houseid );
				    	SetPVarInt( playerid, "furniture_id", fhandle );
						ShowPlayerDialog( playerid, DIALOG_FURNITURE_OPTION, DIALOG_STYLE_LIST, "Furniture", "Use Editor\nEdit Rotation X\nEdit Rotation Y\nEdit Rotation Z\nSell Object", "Select", "Back" );
				        break;
				    }
				    x++;
				}
			}
	    }
	    else ShowPlayerDialog( playerid, DIALOG_FURNITURE, DIALOG_STYLE_LIST, "{FFFFFF}Furniture", "Purchase Furniture\nSelect Furniture Easily\nSelect Furniture Manually\nSelect Furniture Nearest\n"COL_RED"Remove All Furniture", "Confirm", "Back" );
	}
	else if ( dialogid == DIALOG_FURNITURE_OPTION )
	{
	    if ( !response )
	    	return ShowPlayerDialog( playerid, DIALOG_FURNITURE, DIALOG_STYLE_LIST, "{FFFFFF}Furniture", "Purchase Furniture\nSelect Furniture Easily\nSelect Furniture Manually\nSelect Furniture Nearest\n"COL_RED"Remove All Furniture", "Confirm", "Back" );

	 	new editing_house = GetPVarInt( playerid, "furniture_house" );
	 	new editing_furniture = GetPVarInt( playerid, "furniture_id" );

		new houseid = p_InHouse[ playerid ];

	    if ( houseid == -1 )
	   		return SendError( playerid, "You're not inside any house." );

	    if ( houseid != editing_house )
	   		return SendError( playerid, "There was an issue editing the furniture of this home, try again." );

	   	if ( !IsPlayerHomeOwner( playerid, houseid ) )
	   	 	return SendError( playerid, "You are not the owner of this house." );

	 	new objectid = g_houseFurnitureData[ editing_house ] [ editing_furniture ];
	 	new modelid = Streamer_GetIntData( STREAMER_TYPE_OBJECT, objectid, E_STREAMER_MODEL_ID );

        switch( listitem )
        {
            case 0: EditDynamicObject( playerid, objectid );
            case 1 .. 3:
            {
            	p_FurnitureRotAxis{ playerid } = listitem;
            	ShowPlayerDialog( playerid, DIALOG_FURNITURE_ROTATION, DIALOG_STYLE_INPUT, "{FFFFFF}Furniture", "{FFFFFF}Input your axis' value below.", "Confirm", "Back" );
            }
            case 4:
            {
				new i = getFurnitureID( modelid );

		        if ( ! Iter_Count( housefurniture[ houseid ] ) )
		        	return SendError( playerid, "There is no furniture left to sell." );

				if ( i == -1 )
					return SendError( playerid, "Unable to sell furniture due to an unexpected error (0x8F)." );

                DestroyDynamicObject( objectid );
				mysql_single_query( sprintf( "DELETE FROM `FURNITURE` WHERE `ID`=%d AND `HOUSE_ID`=%d", editing_furniture, editing_house ) );
				Iter_Remove( housefurniture[ houseid ], i );

				new iNetProfit = floatround( g_houseFurniture[ i ] [ E_COST ] / 2 );

				GivePlayerCash( playerid, iNetProfit );
				SendClientMessageFormatted( playerid, -1, ""COL_GREY"[FURNITURE]"COL_WHITE" You have successfully sold your "COL_WHITE"%s"COL_WHITE" for "COL_GOLD"%s"COL_WHITE".", g_houseFurniture[ i ] [ E_NAME ], cash_format( iNetProfit ) );
        		ShowPlayerDialog( playerid, DIALOG_FURNITURE, DIALOG_STYLE_LIST, "{FFFFFF}Furniture", "Purchase Furniture\nSelect Furniture Easily\nSelect Furniture Manually\nSelect Furniture Nearest\n"COL_RED"Remove All Furniture", "Confirm", "Back" );
			}
        }
	}
	else if ( dialogid == DIALOG_FURNITURE_ROTATION )
	{
	 	new editing_house = GetPVarInt( playerid, "furniture_house" );
	 	new editing_furniture = GetPVarInt( playerid, "furniture_id" );

		new houseid = p_InHouse[ playerid ];

	    if ( houseid == -1 )
	   		return SendError( playerid, "You're not inside any house." );

	    if ( houseid != editing_house )
	   		return SendError( playerid, "There was an issue editing the furniture of this home, try again." );

	   	if ( !IsPlayerHomeOwner( playerid, houseid ) )
	   	 	return SendError( playerid, "You are not the owner of this house." );

	 	new objectid = g_houseFurnitureData[ editing_house ] [ editing_furniture ];

	    if ( !response )
	    	return ShowPlayerDialog( playerid, DIALOG_FURNITURE, DIALOG_STYLE_LIST, "{FFFFFF}Furniture", "Purchase Furniture\nSelect Furniture Easily\nSelect Furniture Manually\nSelect Furniture Nearest\n"COL_RED"Remove All Furniture", "Confirm", "Back" );

		new Float: angle;

		if ( sscanf( inputtext, "f", angle ) )
			return ShowPlayerDialog( playerid, DIALOG_FURNITURE_ROTATION, DIALOG_STYLE_INPUT, "{FFFFFF}Furniture", "{FFFFFF}Input your axis' value below.\n\n"COL_RED"Invalid Value!", "Confirm", "Back" );

		new Float: rotX, Float: rotY, Float: rotZ;
	    GetDynamicObjectRot( objectid, rotX, rotY, rotZ );

	    switch( p_FurnitureRotAxis{ playerid } )
	    {
			case 1: SetDynamicObjectRot( objectid, angle, rotY, rotZ );
			case 2: SetDynamicObjectRot( objectid, rotX, angle, rotZ );
			case 3: SetDynamicObjectRot( objectid, rotX, rotY, angle );
	    }

	    GetDynamicObjectRot( objectid, rotX, rotY, rotZ ); // finalize
		format( szBigString, sizeof( szBigString ), "UPDATE `FURNITURE` SET `RX`=%f,`RY`=%f,`RZ`=%f WHERE `ID`=%d AND `HOUSE_ID`=%d", rotX, rotY, rotZ, editing_furniture, editing_house );
		mysql_single_query( szBigString );

		SendServerMessage( playerid, "Furniture has been successfully updated." );
        ShowPlayerDialog( playerid, DIALOG_FURNITURE, DIALOG_STYLE_LIST, "{FFFFFF}Furniture", "Purchase Furniture\nSelect Furniture Easily\nSelect Furniture Manually\nSelect Furniture Nearest\n"COL_RED"Remove All Furniture", "Confirm", "Back" );
	}
	else if ( dialogid == DIALOG_FURNITURE_LIST )
	{
	    if ( !response ) return ShowFurnitureCategory( playerid );

		new houseid = p_InHouse[ playerid ];

	    if ( houseid == -1 )
	   		return SendError( playerid, "You're not inside any house." );

	   	if ( !IsPlayerHomeOwner( playerid, houseid ) )
	   	 	return SendError( playerid, "You are not the owner of this house." );

		new vip_slots = 25 + ( GetPlayerVIPLevel( playerid ) * 5 );

		if ( vip_slots > MAX_FURNITURE )
			vip_slots = MAX_FURNITURE; // just to be sure

		new total_furniture = Iter_Count( housefurniture[ houseid ] );

		if ( total_furniture > vip_slots )
			return SendError( playerid, "You have reached the maximum furniture limit of %d.", vip_slots );

	    for( new i, x = 0; i < sizeof( g_houseFurniture ); i++ )
		{
			if ( p_FurnitureCategory{ playerid } == g_houseFurniture[ i ] [ E_CATEGORY ] )
		 	{
		       	if ( x == listitem )
		      	{
		      		if ( GetPlayerCash( playerid ) < g_houseFurniture[ i ] [ E_COST ] )
				    {
						ShowFurnitureList( playerid, p_FurnitureCategory{ playerid } );
				        return SendError( playerid, "You don't have enough money for this piece of furniture." );
				    }

					new Float: X, Float: Y, Float: Z;
					GetXYInFrontOfPlayer( playerid, X, Y, Z, 2.0 );

					new fhandle = CreateFurniture( houseid, g_houseFurniture[ i ] [ E_MODEL ], X, Y, Z, 0.0, 0.0, 0.0, .creator = p_AccountID[ playerid ] );

					if ( fhandle == ITER_NONE )
						return SendError( playerid, "You do not have any more slots available to add furniture." );

					GivePlayerCash( playerid, -g_houseFurniture[ i ] [ E_COST ] );
					Streamer_Update( playerid ); // SyncObject( playerid );

					SendServerMessage( playerid, "You have purchased a "COL_GREY"%s"COL_WHITE". "COL_ORANGE"[%d/%d]", g_houseFurniture[ i ] [ E_NAME ], total_furniture, vip_slots );
					ShowFurnitureList( playerid, p_FurnitureCategory{ playerid } );
				 	break;
	      		}
		      	x ++;
			}
		}
	}
	return 1;
}

hook OnPlayerSelectDynObject( playerid, objectid, modelid, Float:x, Float:y, Float:z )
{
	new houseid = p_InHouse[ playerid ];

	if ( houseid == -1 )
		return SendError( playerid, "You're not inside any house." );

	if ( ! IsPlayerHomeOwner( playerid, houseid ) )
		return SendError( playerid, "You are not the owner of this house." );

	if ( isFurnitureObject( modelid ) )
	{
		new fhandle;

		// check the handle of the modelid
		foreach ( fhandle : housefurniture[ houseid ] ) {
			new furniture_model = Streamer_GetIntData( STREAMER_TYPE_OBJECT, g_houseFurnitureData[ houseid ] [ fhandle ], E_STREAMER_MODEL_ID );
			if ( furniture_model == modelid ) break;
		}

		// notify
		if ( fhandle != ITER_NONE ) {
			SetPVarInt( playerid, "furniture_house", houseid );
			SetPVarInt( playerid, "furniture_id", fhandle );
			ShowPlayerDialog( playerid, DIALOG_FURNITURE_OPTION, DIALOG_STYLE_LIST, "Furniture", "Use Editor\nEdit Rotation X\nEdit Rotation Y\nEdit Rotation Z\nSell Object", "Select", "Back" );
		}
		else SendError( playerid, "This furniture item cannot be edited as its model is unrecogized in the house." );
	}
	CancelEdit( playerid );
	return 1;
}

hook OnHouseOwnerChange( houseid, owner )
{
	if ( owner != 0 ) // transfer furniture only to valid owner
	{
		mysql_single_query( sprintf( "UPDATE `FURNITURE` SET `OWNER`=%d WHERE `HOUSE_ID`=%d", owner, houseid ) );
	}
	return 1;
}

hook OnPlayerConnect( playerid )
{
	//Katie - 271.884979,306.631988,999.148437 - DEFAULT - 2
	RemoveBuildingForPlayer( playerid, 2251, 266.4531, 303.3672, 998.9844, 0.25 );
	RemoveBuildingForPlayer( playerid, 14867, 270.2813, 302.5547, 999.6797, 0.25 );
	RemoveBuildingForPlayer( playerid, 1720, 272.9063, 304.7891, 998.1641, 0.25 );
	RemoveBuildingForPlayer( playerid, 14870, 273.1641, 303.1719, 1000.9141, 0.25 );
	RemoveBuildingForPlayer( playerid, 2251, 273.9922, 303.3672, 998.9844, 0.25 );
	RemoveBuildingForPlayer( playerid, 14868, 274.1328, 304.5078, 1001.1953, 0.25 );
	RemoveBuildingForPlayer( playerid, 948, 266.5703, 306.4453, 998.1406, 0.25 );
	RemoveBuildingForPlayer( playerid, 14866, 270.1172, 307.6094, 998.7578, 0.25 );
	RemoveBuildingForPlayer( playerid, 14869, 273.8125, 305.0156, 998.9531, 0.25 );
	//Denise - 244.411987,305.032989,999.148437 - $10,000 - 1
	RemoveBuildingForPlayer( playerid, 14862, 245.5547, 300.8594, 998.8359, 0.25 );
	RemoveBuildingForPlayer( playerid, 1740, 243.8828, 301.9766, 998.2344, 0.25 );
	RemoveBuildingForPlayer( playerid, 14861, 245.7578, 302.2344, 998.5469, 0.25 );
	RemoveBuildingForPlayer( playerid, 14860, 246.5156, 301.5859, 1000.0000, 0.25 );
	RemoveBuildingForPlayer( playerid, 14864, 246.1875, 303.1094, 998.2656, 0.25 );
	RemoveBuildingForPlayer( playerid, 1734, 246.7109, 303.8750, 1002.1172, 0.25 );
	RemoveBuildingForPlayer( playerid, 14863, 246.9844, 303.5781, 998.7500, 0.25 );
	RemoveBuildingForPlayer( playerid, 2103, 248.4063, 300.5625, 999.3047, 0.25 );
	RemoveBuildingForPlayer( playerid, 2088, 248.4922, 304.3516, 998.2266, 0.25 );
	RemoveBuildingForPlayer( playerid, 1741, 248.4844, 306.1250, 998.1406, 0.25 );
	RemoveBuildingForPlayer( playerid, 1741, 248.8672, 301.9609, 998.1406, 0.25 );
	RemoveBuildingForPlayer( playerid, 1744, 250.1016, 301.9609, 999.4531, 0.25 );
	RemoveBuildingForPlayer( playerid, 1744, 250.1016, 301.9609, 1000.1563, 0.25 );
	//Michelle - 302.180999,300.722991,999.148437 - $25,000 - 4
	RemoveBuildingForPlayer( playerid, 2338, 299.9375, 300.5078, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2334, 299.9375, 301.5000, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2336, 301.9297, 300.5000, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2334, 299.9375, 302.5000, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2170, 299.9141, 303.3906, 1002.5313, 0.25 );
	RemoveBuildingForPlayer( playerid, 2334, 299.9375, 304.2734, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2334, 302.9219, 301.5000, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2338, 302.9219, 300.5078, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2226, 303.1797, 302.4219, 1003.7109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2335, 302.9219, 302.5000, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2337, 302.9219, 303.5000, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2335, 302.9219, 304.5000, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2069, 304.1641, 300.3594, 1002.3828, 0.25 );
	RemoveBuildingForPlayer( playerid, 1768, 306.3906, 302.4219, 1002.2969, 0.25 );
	RemoveBuildingForPlayer( playerid, 1782, 304.0156, 302.8281, 1002.3047, 0.25 );
	RemoveBuildingForPlayer( playerid, 1752, 303.9063, 304.2109, 1002.8359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2235, 304.6641, 303.6797, 1002.3438, 0.25 );
	RemoveBuildingForPlayer( playerid, 2158, 299.9297, 305.3516, 1002.5469, 0.25 );
	RemoveBuildingForPlayer( playerid, 2158, 299.9297, 306.3516, 1002.5469, 0.25 );
	RemoveBuildingForPlayer( playerid, 2147, 299.9141, 307.3906, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2335, 302.9219, 305.5000, 1002.5391, 0.25 );
	RemoveBuildingForPlayer( playerid, 1768, 307.0313, 305.4375, 1002.2969, 0.25 );
	RemoveBuildingForPlayer( playerid, 14880, 309.1484, 301.7266, 1002.7031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2069, 310.5547, 300.3594, 1002.3828, 0.25 );
	RemoveBuildingForPlayer( playerid, 14879, 308.3203, 305.9141, 1002.6172, 0.25 );
	//Gang House - 318.564971,1118.209960,1083.882812 - $35,000 - 5
	RemoveBuildingForPlayer( playerid, 2158, 305.2188, 1120.2109, 1082.8359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2330, 308.6953, 1120.8203, 1082.8672, 0.25 );
	RemoveBuildingForPlayer( playerid, 1802, 307.1875, 1121.8281, 1082.8828, 0.25 );
	RemoveBuildingForPlayer( playerid, 2846, 309.9844, 1121.4063, 1082.8906, 0.25 );
	RemoveBuildingForPlayer( playerid, 2840, 309.8125, 1123.4766, 1082.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2855, 309.0391, 1124.5547, 1082.8828, 0.25 );
	RemoveBuildingForPlayer( playerid, 1720, 309.8594, 1124.5938, 1082.8906, 0.25 );
	RemoveBuildingForPlayer( playerid, 1750, 315.6797, 1116.6563, 1082.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2867, 318.0703, 1122.9844, 1082.8828, 0.25 );
	RemoveBuildingForPlayer( playerid, 2858, 321.4141, 1122.4063, 1082.8984, 0.25 );
	RemoveBuildingForPlayer( playerid, 2855, 316.2578, 1124.5469, 1083.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2855, 316.3359, 1124.5547, 1082.8828, 0.25 );
	RemoveBuildingForPlayer( playerid, 2855, 316.4688, 1125.0313, 1083.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2855, 316.4688, 1125.0313, 1082.8828, 0.25 );
	RemoveBuildingForPlayer( playerid, 2855, 316.7266, 1124.5547, 1082.8828, 0.25 );
	RemoveBuildingForPlayer( playerid, 2855, 316.7266, 1124.5547, 1083.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2852, 316.5469, 1124.7031, 1083.1563, 0.25 );
	RemoveBuildingForPlayer( playerid, 1728, 319.0469, 1124.3047, 1082.8828, 0.25 );
	RemoveBuildingForPlayer( playerid, 2262, 317.7266, 1124.8047, 1084.8594, 0.25 );
	RemoveBuildingForPlayer( playerid, 2844, 321.6406, 1127.9375, 1082.9531, 0.25 );
	RemoveBuildingForPlayer( playerid, 1793, 321.3828, 1128.4453, 1082.8828, 0.25 );
	RemoveBuildingForPlayer( playerid, 2859, 324.4453, 1118.9844, 1082.9063, 0.25 );
	RemoveBuildingForPlayer( playerid, 2860, 324.6094, 1120.7969, 1082.8906, 0.25 );
	RemoveBuildingForPlayer( playerid, 2103, 327.0391, 1116.9766, 1082.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 1710, 326.2109, 1121.2656, 1082.8984, 0.25 );
	RemoveBuildingForPlayer( playerid, 2147, 331.9922, 1118.8672, 1082.8594, 0.25 );
	RemoveBuildingForPlayer( playerid, 2338, 334.3906, 1118.8203, 1082.8438, 0.25 );
	RemoveBuildingForPlayer( playerid, 2337, 334.3906, 1119.8125, 1082.8438, 0.25 );
	RemoveBuildingForPlayer( playerid, 2170, 334.4531, 1121.8281, 1082.8516, 0.25 );
	RemoveBuildingForPlayer( playerid, 2116, 331.4922, 1122.5469, 1082.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2857, 322.2422, 1123.7109, 1082.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2295, 326.8438, 1124.4844, 1082.8594, 0.25 );
	RemoveBuildingForPlayer( playerid, 2336, 334.2500, 1123.8672, 1082.8438, 0.25 );
	RemoveBuildingForPlayer( playerid, 2335, 334.2422, 1124.8672, 1082.8438, 0.25 );
	RemoveBuildingForPlayer( playerid, 2334, 334.2422, 1125.8672, 1082.8438, 0.25 );
	RemoveBuildingForPlayer( playerid, 2852, 321.6719, 1130.3516, 1083.5547, 0.25 );
	RemoveBuildingForPlayer( playerid, 1728, 325.5078, 1130.8516, 1082.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2819, 323.4453, 1131.1250, 1082.8984, 0.25 );
	//Carl - 2496.049804,-1695.238159,1014.742187 - $50,000 - 3
	RemoveBuildingForPlayer( playerid, 2865, 2499.5000, -1712.2188, 1014.8672, 0.25 );
	RemoveBuildingForPlayer( playerid, 2821, 2500.9297, -1710.3516, 1014.8516, 0.25 );
	RemoveBuildingForPlayer( playerid, 1509, 2501.1953, -1710.6953, 1015.0547, 0.25 );
	RemoveBuildingForPlayer( playerid, 2277, 2494.7578, -1705.3281, 1018.8984, 0.25 );
	RemoveBuildingForPlayer( playerid, 1512, 2500.8906, -1706.5703, 1015.0547, 0.25 );
	RemoveBuildingForPlayer( playerid, 1509, 2501.1953, -1706.8594, 1015.0547, 0.25 );
	RemoveBuildingForPlayer( playerid, 1520, 2501.2969, -1707.2344, 1014.9141, 0.25 );
	RemoveBuildingForPlayer( playerid, 1520, 2501.2969, -1707.3594, 1014.9141, 0.25 );
	RemoveBuildingForPlayer( playerid, 2830, 2491.8359, -1702.9375, 1014.5703, 0.25 );
	RemoveBuildingForPlayer( playerid, 2306, 2491.8359, -1701.2813, 1017.3516, 0.25 );
	RemoveBuildingForPlayer( playerid, 1794, 2492.9688, -1701.8516, 1017.3672, 0.25 );
	RemoveBuildingForPlayer( playerid, 2275, 2493.4297, -1699.8594, 1019.1797, 0.25 );
	RemoveBuildingForPlayer( playerid, 2306, 2494.0156, -1701.3125, 1017.3516, 0.25 );
	RemoveBuildingForPlayer( playerid, 2247, 2494.1172, -1700.3359, 1018.8203, 0.25 );
	RemoveBuildingForPlayer( playerid, 14478, 2494.4297, -1698.3359, 1014.0391, 0.25 );
	RemoveBuildingForPlayer( playerid, 1740, 2495.2891, -1704.4922, 1017.3672, 0.25 );
	RemoveBuildingForPlayer( playerid, 2816, 2494.8047, -1702.5156, 1018.0469, 0.25 );
	RemoveBuildingForPlayer( playerid, 2272, 2496.2188, -1702.5234, 1018.5859, 0.25 );
	RemoveBuildingForPlayer( playerid, 14477, 2501.0703, -1697.6172, 1016.1250, 0.25 );
	RemoveBuildingForPlayer( playerid, 14490, 2501.0703, -1697.6172, 1016.1250, 0.25 );
	RemoveBuildingForPlayer( playerid, 14491, 2501.0703, -1697.6172, 1016.1250, 0.25 );
	RemoveBuildingForPlayer( playerid, 2252, 2493.0469, -1697.1875, 1014.5703, 0.25 );
	RemoveBuildingForPlayer( playerid, 2827, 2497.6563, -1697.0703, 1014.7266, 0.25 );
	RemoveBuildingForPlayer( playerid, 14489, 2490.4453, -1694.8672, 1015.4609, 0.25 );
	RemoveBuildingForPlayer( playerid, 2028, 2491.3438, -1694.7656, 1013.8359, 0.25 );
	//colonelhouse - 2807.619873,-1171.899902,1025.570312 - $60,000 - 8
	RemoveBuildingForPlayer( playerid, 2046, 2806.2266, -1174.5703, 1026.3594, 0.25 );
	RemoveBuildingForPlayer( playerid, 2049, 2805.2109, -1173.4922, 1026.5234, 0.25 );
	RemoveBuildingForPlayer( playerid, 2241, 2805.6875, -1173.5156, 1025.0703, 0.25 );
	RemoveBuildingForPlayer( playerid, 2060, 2810.3047, -1172.8516, 1025.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2060, 2810.3047, -1172.8516, 1025.0469, 0.25 );
	RemoveBuildingForPlayer( playerid, 2060, 2810.3047, -1172.8516, 1024.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2060, 2810.3047, -1172.8516, 1024.7031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2060, 2811.6016, -1172.8516, 1024.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2060, 2811.6016, -1172.8516, 1024.7031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2060, 2811.6016, -1172.8516, 1025.0469, 0.25 );
	RemoveBuildingForPlayer( playerid, 2060, 2811.6016, -1172.8516, 1025.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2048, 2805.2109, -1172.0547, 1026.8906, 0.25 );
	RemoveBuildingForPlayer( playerid, 2055, 2805.1953, -1170.5391, 1026.5078, 0.25 );
	RemoveBuildingForPlayer( playerid, 2060, 2810.0234, -1171.2266, 1024.7031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2064, 2810.8359, -1171.8984, 1025.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2068, 2809.2031, -1169.3672, 1027.5313, 0.25 );
	RemoveBuildingForPlayer( playerid, 2069, 2806.3906, -1166.8203, 1024.6250, 0.25 );
	RemoveBuildingForPlayer( playerid, 1764, 2808.6563, -1166.9531, 1024.5703, 0.25 );
	RemoveBuildingForPlayer( playerid, 2100, 2805.5078, -1165.5625, 1024.5703, 0.25 );
	RemoveBuildingForPlayer( playerid, 2276, 2809.2109, -1165.2734, 1026.6875, 0.25 );
	RemoveBuildingForPlayer( playerid, 1821, 2810.5938, -1167.6172, 1024.5625, 0.25 );
	RemoveBuildingForPlayer( playerid, 2053, 2810.6094, -1167.5781, 1024.6328, 0.25 );
	RemoveBuildingForPlayer( playerid, 2058, 2809.6406, -1165.3359, 1024.5781, 0.25 );
	RemoveBuildingForPlayer( playerid, 2272, 2811.3438, -1165.2734, 1026.7891, 0.25 );
	RemoveBuildingForPlayer( playerid, 2297, 2811.0234, -1165.0625, 1024.5625, 0.25 );
	RemoveBuildingForPlayer( playerid, 1765, 2811.4766, -1168.4063, 1024.5625, 0.25 );
	RemoveBuildingForPlayer( playerid, 2241, 2811.6875, -1168.5078, 1028.6797, 0.25 );
	RemoveBuildingForPlayer( playerid, 2059, 2814.8359, -1173.4766, 1025.3594, 0.25 );
	RemoveBuildingForPlayer( playerid, 2116, 2814.3047, -1173.4219, 1024.5547, 0.25 );
	RemoveBuildingForPlayer( playerid, 2050, 2813.1250, -1173.3359, 1026.3359, 0.25 );
	RemoveBuildingForPlayer( playerid, 1736, 2812.8281, -1172.2969, 1027.0469, 0.25 );
	RemoveBuildingForPlayer( playerid, 2051, 2813.1250, -1171.2891, 1026.3359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2121, 2813.9531, -1172.4609, 1025.0859, 0.25 );
	RemoveBuildingForPlayer( playerid, 2121, 2815.3828, -1172.4844, 1025.0859, 0.25 );
	RemoveBuildingForPlayer( playerid, 2275, 2812.6094, -1168.1094, 1026.4453, 0.25 );
	RemoveBuildingForPlayer( playerid, 2156, 2813.6484, -1167.0000, 1024.5703, 0.25 );
	RemoveBuildingForPlayer( playerid, 2160, 2815.8984, -1164.9063, 1024.5625, 0.25 );
	RemoveBuildingForPlayer( playerid, 2159, 2817.2656, -1164.9063, 1024.5625, 0.25 );
	RemoveBuildingForPlayer( playerid, 2157, 2818.7109, -1173.9531, 1024.5703, 0.25 );
	RemoveBuildingForPlayer( playerid, 2157, 2818.6406, -1164.9063, 1024.5625, 0.25 );
	RemoveBuildingForPlayer( playerid, 2300, 2818.6484, -1166.5078, 1028.1719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2046, 2819.4453, -1174.0000, 1026.3594, 0.25 );
	RemoveBuildingForPlayer( playerid, 2091, 2819.8047, -1165.6641, 1028.1641, 0.25 );
	RemoveBuildingForPlayer( playerid, 2157, 2820.6328, -1167.3125, 1024.5703, 0.25 );
	RemoveBuildingForPlayer( playerid, 2255, 2814.5703, -1169.2891, 1029.9141, 0.25 );
	RemoveBuildingForPlayer( playerid, 2047, 2817.3125, -1170.9688, 1031.1719, 0.25 );
	//Modern Style - 2260.70,-1210.45,1049.02 - $70,000 - 10
	RemoveBuildingForPlayer( playerid, 1741, 2261.6953, -1223.0781, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2088, 2258.1406, -1220.5859, 1048.0078, 0.25 );
	RemoveBuildingForPlayer( playerid, 2090, 2258.5938, -1221.5469, 1048.0625, 0.25 );
	RemoveBuildingForPlayer( playerid, 2249, 2251.3594, -1218.1797, 1048.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2528, 2254.4063, -1218.2734, 1048.0234, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2247.5547, -1213.9219, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2247.5547, -1212.9375, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2121, 2250.3047, -1213.9375, 1048.5234, 0.25 );
	RemoveBuildingForPlayer( playerid, 2526, 2252.4297, -1215.4531, 1048.0391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2523, 2254.1953, -1215.4531, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2297, 2255.4219, -1213.5313, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2248, 2262.3906, -1215.5469, 1048.6094, 0.25 );
	RemoveBuildingForPlayer( playerid, 1816, 2261.4141, -1213.4531, 1048.0078, 0.25 );
	RemoveBuildingForPlayer( playerid, 2249, 2247.2969, -1212.1641, 1049.6250, 0.25 );
	RemoveBuildingForPlayer( playerid, 2249, 2247.2969, -1208.8594, 1049.6250, 0.25 );
	RemoveBuildingForPlayer( playerid, 2139, 2247.5625, -1211.9531, 1048.0078, 0.25 );
	RemoveBuildingForPlayer( playerid, 2136, 2247.5469, -1210.9688, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2303, 2247.5469, -1208.9844, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2247.5547, -1207.9766, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2305, 2247.5547, -1206.9922, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2109, 2250.2813, -1212.2500, 1048.4141, 0.25 );
	RemoveBuildingForPlayer( playerid, 2121, 2249.2344, -1211.4531, 1048.5234, 0.25 );
	RemoveBuildingForPlayer( playerid, 2121, 2250.3047, -1210.8984, 1048.5234, 0.25 );
	RemoveBuildingForPlayer( playerid, 2135, 2248.5234, -1206.9922, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2319, 2250.3438, -1206.9609, 1048.0078, 0.25 );
	RemoveBuildingForPlayer( playerid, 1760, 2261.4609, -1212.0625, 1048.0078, 0.25 );
	RemoveBuildingForPlayer( playerid, 2126, 2258.1094, -1210.3750, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 15044, 2255.0938, -1209.7813, 1048.0313, 0.25 );
	RemoveBuildingForPlayer( playerid, 2247, 2258.4766, -1209.7891, 1048.9922, 0.25 );
	RemoveBuildingForPlayer( playerid, 2099, 2262.8047, -1208.4922, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2254, 2254.1172, -1206.5000, 1050.7578, 0.25 );
	RemoveBuildingForPlayer( playerid, 2240, 2254.6328, -1207.2734, 1048.5625, 0.25 );
	RemoveBuildingForPlayer( playerid, 2252, 2256.2109, -1206.1016, 1048.8281, 0.25 );
	RemoveBuildingForPlayer( playerid, 2235, 2256.2188, -1206.8594, 1048.0078, 0.25 );
	RemoveBuildingForPlayer( playerid, 1760, 2257.6172, -1207.7266, 1048.0078, 0.25 );
	RemoveBuildingForPlayer( playerid, 2235, 2261.4297, -1206.2031, 1048.0078, 0.25 );
	RemoveBuildingForPlayer( playerid, 2252, 2262.1172, -1206.1016, 1048.8281, 0.25 );
	//Modern-Stlyle - 2365.42,-1131.8,1050.88 - $72,000 - 8
	RemoveBuildingForPlayer( playerid, 2077, 2357.5469, -1134.1875, 1050.7031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2298, 2361.2969, -1134.1484, 1049.8594, 0.25 );
	RemoveBuildingForPlayer( playerid, 2141, 2367.5625, -1135.3906, 1049.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2339, 2367.5625, -1134.3906, 1049.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2134, 2367.5625, -1133.3906, 1049.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2077, 2357.5469, -1131.5234, 1050.6875, 0.25 );
	RemoveBuildingForPlayer( playerid, 2271, 2357.8594, -1132.8828, 1051.2813, 0.25 );
	RemoveBuildingForPlayer( playerid, 2087, 2360.2969, -1129.9766, 1049.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2103, 2360.8281, -1130.1406, 1051.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2279, 2369.8125, -1135.4375, 1052.1094, 0.25 );
	RemoveBuildingForPlayer( playerid, 2125, 2370.5781, -1134.0313, 1050.1797, 0.25 );
	RemoveBuildingForPlayer( playerid, 2125, 2371.7500, -1133.5938, 1050.1797, 0.25 );
	RemoveBuildingForPlayer( playerid, 2278, 2372.1875, -1135.4297, 1052.1250, 0.25 );
	RemoveBuildingForPlayer( playerid, 2030, 2371.2266, -1132.9219, 1050.2734, 0.25 );
	RemoveBuildingForPlayer( playerid, 2812, 2371.2969, -1133.0156, 1050.6641, 0.25 );
	RemoveBuildingForPlayer( playerid, 2125, 2371.7500, -1131.8594, 1050.1797, 0.25 );
	RemoveBuildingForPlayer( playerid, 2125, 2370.5781, -1131.8594, 1050.1797, 0.25 );
	RemoveBuildingForPlayer( playerid, 2141, 2374.5000, -1135.3906, 1049.8203, 0.25 );
	RemoveBuildingForPlayer( playerid, 2132, 2374.5000, -1131.3906, 1049.8203, 0.25 );
	RemoveBuildingForPlayer( playerid, 2339, 2374.5078, -1134.3828, 1049.8203, 0.25 );
	RemoveBuildingForPlayer( playerid, 2134, 2374.5078, -1133.3828, 1049.8203, 0.25 );
	RemoveBuildingForPlayer( playerid, 2339, 2374.5078, -1130.3828, 1049.8203, 0.25 );
	RemoveBuildingForPlayer( playerid, 2225, 2369.1797, -1125.8047, 1049.8672, 0.25 );
	RemoveBuildingForPlayer( playerid, 2260, 2369.7188, -1123.8594, 1052.0781, 0.25 );
	RemoveBuildingForPlayer( playerid, 2331, 2367.3672, -1123.1563, 1050.1172, 0.25 );
	RemoveBuildingForPlayer( playerid, 2302, 2364.5547, -1122.9688, 1049.8672, 0.25 );
	RemoveBuildingForPlayer( playerid, 2259, 2368.6094, -1122.5078, 1052.0469, 0.25 );
	RemoveBuildingForPlayer( playerid, 2333, 2367.5703, -1122.1484, 1049.8672, 0.25 );
	RemoveBuildingForPlayer( playerid, 2255, 2361.5703, -1122.1484, 1052.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2811, 2372.7031, -1128.9141, 1049.8203, 0.25 );
	RemoveBuildingForPlayer( playerid, 15061, 2371.6094, -1128.1875, 1051.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 15062, 2371.6094, -1128.1875, 1051.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2868, 2370.1250, -1125.2344, 1049.8672, 0.25 );
	RemoveBuildingForPlayer( playerid, 1703, 2370.3906, -1124.4375, 1049.8438, 0.25 );
	RemoveBuildingForPlayer( playerid, 1822, 2372.0938, -1124.2188, 1049.8516, 0.25 );
	RemoveBuildingForPlayer( playerid, 2828, 2374.2578, -1129.2578, 1050.7891, 0.25 );
	RemoveBuildingForPlayer( playerid, 2084, 2374.4688, -1129.2109, 1049.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 1703, 2374.6797, -1122.5313, 1049.8438, 0.25 );
	RemoveBuildingForPlayer( playerid, 2281, 2375.6641, -1128.1016, 1051.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2868, 2374.9766, -1125.2344, 1049.8672, 0.25 );
	RemoveBuildingForPlayer( playerid, 2280, 2375.6484, -1122.3828, 1051.9922, 0.25 );
	RemoveBuildingForPlayer( playerid, 2227, 2370.2344, -1120.5859, 1049.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 1742, 2366.6953, -1119.2500, 1049.8750, 0.25 );
	RemoveBuildingForPlayer( playerid, 1703, 2371.6016, -1121.5078, 1049.8438, 0.25 );
	RemoveBuildingForPlayer( playerid, 2227, 2375.5859, -1120.9922, 1049.8750, 0.25 );
	//Nice House - 2324.419921,-1145.568359,1050.710083 - $80000 - 12
	RemoveBuildingForPlayer( playerid, 2123, 2312.9609, -1145.0703, 1050.3203, 0.25 );
	RemoveBuildingForPlayer( playerid, 2123, 2314.2969, -1146.3125, 1050.3203, 0.25 );
	RemoveBuildingForPlayer( playerid, 2123, 2315.4219, -1145.0703, 1050.3203, 0.25 );
	RemoveBuildingForPlayer( playerid, 2086, 2314.2734, -1144.8984, 1050.0859, 0.25 );
	RemoveBuildingForPlayer( playerid, 2123, 2314.2969, -1143.6250, 1050.3203, 0.25 );
	RemoveBuildingForPlayer( playerid, 15045, 2324.4297, -1143.3125, 1049.6016, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2331.3359, -1144.0859, 1049.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2335.3594, -1144.0703, 1049.6719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2135, 2336.3516, -1144.0781, 1049.6719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2305, 2337.3203, -1144.0781, 1049.6719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2331.3359, -1143.1016, 1049.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2337.3203, -1143.0938, 1049.6719, 0.25 );
	RemoveBuildingForPlayer( playerid, 1703, 2322.2266, -1142.4766, 1049.4766, 0.25 );
	RemoveBuildingForPlayer( playerid, 1822, 2323.9297, -1142.2578, 1049.4844, 0.25 );
	RemoveBuildingForPlayer( playerid, 1741, 2312.6484, -1140.7891, 1053.3750, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2331.3359, -1142.1094, 1049.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2331.3359, -1141.1172, 1049.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2334.4219, -1140.9688, 1050.3359, 0.25 );
	RemoveBuildingForPlayer( playerid, 1703, 2326.5234, -1140.5703, 1049.4766, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2337.3203, -1142.1094, 1049.6719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2139, 2337.3125, -1141.1094, 1049.6641, 0.25 );
	RemoveBuildingForPlayer( playerid, 2088, 2338.4531, -1141.3672, 1053.2734, 0.25 );
	RemoveBuildingForPlayer( playerid, 15050, 2330.3281, -1140.3047, 1051.9063, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2331.3359, -1140.1328, 1049.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 1703, 2323.4375, -1139.5469, 1049.4766, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2333.3281, -1139.8672, 1050.3359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2115, 2334.4297, -1139.6250, 1049.7109, 0.25 );
	RemoveBuildingForPlayer( playerid, 15049, 2334.3281, -1139.5859, 1051.1953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2335.3672, -1139.8750, 1050.3359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2303, 2337.3281, -1140.1172, 1049.6719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2090, 2309.5156, -1139.3438, 1053.4219, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2331.3359, -1139.1406, 1049.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2333.3281, -1138.8281, 1050.3359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2335.3672, -1138.8359, 1050.3359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2298, 2336.5391, -1138.7891, 1053.2813, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2331.3359, -1138.1563, 1049.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2136, 2337.3281, -1138.1328, 1049.6719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2240, 2319.2500, -1137.8750, 1050.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2240, 2329.5000, -1137.8750, 1050.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2331.3359, -1137.1641, 1049.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2334.4219, -1137.5859, 1050.3359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2139, 2337.3125, -1137.1484, 1049.6641, 0.25 );
	RemoveBuildingForPlayer( playerid, 2088, 2310.6641, -1136.3047, 1053.3672, 0.25 );
	RemoveBuildingForPlayer( playerid, 2257, 2320.4141, -1134.6328, 1053.8281, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2331.3359, -1136.1719, 1049.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2331.3359, -1135.1875, 1049.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2254, 2328.1484, -1134.6172, 1054.0625, 0.25 );
	RemoveBuildingForPlayer( playerid, 2281, 2335.2656, -1136.4063, 1054.7266, 0.25 );
	RemoveBuildingForPlayer( playerid, 2106, 2336.5156, -1135.0156, 1053.8047, 0.25 );
	RemoveBuildingForPlayer( playerid, 2271, 2337.8047, -1135.3516, 1054.7031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2337.3203, -1136.1641, 1049.6719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2337.3203, -1135.1797, 1049.6719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2106, 2339.2031, -1135.0156, 1053.8047, 0.25 );
	// Butcher
	RemoveBuildingForPlayer( playerid, 14612, 961.1719, 2166.5781, 1012.7344, 0.25 );
	// Mundus
	RemoveBuildingForPlayer( playerid, 2240, 26.1563, 1343.2969, 1083.9531, 0.25 );
	// Godfather
	RemoveBuildingForPlayer( playerid, 1739, 149.2266, 1381.5234, 1083.7500, 0.25 );
	RemoveBuildingForPlayer( playerid, 1739, 149.2266, 1380.5469, 1083.7500, 0.25 );
	RemoveBuildingForPlayer( playerid, 1739, 151.5469, 1380.5469, 1083.7500, 0.25 );
	RemoveBuildingForPlayer( playerid, 1739, 151.5469, 1381.5234, 1083.7500, 0.25 );
	RemoveBuildingForPlayer( playerid, 2117, 150.4297, 1381.6016, 1082.8516, 0.25 );
	RemoveBuildingForPlayer( playerid, 1739, 149.2266, 1382.7422, 1083.7500, 0.25 );
	RemoveBuildingForPlayer( playerid, 1739, 151.5469, 1382.6563, 1083.7500, 0.25 );
	RemoveBuildingForPlayer( playerid, 2117, 150.4297, 1383.5938, 1082.8516, 0.25 );
	RemoveBuildingForPlayer( playerid, 1739, 151.5469, 1383.7500, 1083.7500, 0.25 );
	RemoveBuildingForPlayer( playerid, 1739, 149.2266, 1383.8203, 1083.7500, 0.25 );
	RemoveBuildingForPlayer( playerid, 2312, 151.818466, 1369.827148, 1083.859375, 19994.000 );
	// Lorem
	RemoveBuildingForPlayer( playerid, 2524, 219.6719, 1072.9922, 1083.1641, 0.25 );
	RemoveBuildingForPlayer( playerid, 2525, 219.6250, 1074.4844, 1083.1875, 0.25 );
	RemoveBuildingForPlayer( playerid, 2526, 219.5859, 1076.3750, 1083.1719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2524, 225.1563, 1085.5313, 1086.8125, 0.25 );
	RemoveBuildingForPlayer( playerid, 2526, 227.4766, 1087.1875, 1086.8047, 0.25 );
	RemoveBuildingForPlayer( playerid, 2525, 225.1563, 1087.2734, 1086.8203, 0.25 );
	RemoveBuildingForPlayer( playerid, 2527, -64.8281, 1355.4609, 1079.1719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2526, -64.1875, 1353.5781, 1079.1797, 0.25 );
	RemoveBuildingForPlayer( playerid, 2525, -62.7734, 1356.4844, 1079.1953, 0.25 );
	// Bulbus
	RemoveBuildingForPlayer( playerid, 2527, -64.8281, 1355.4609, 1079.1719, 0.25 );
	RemoveBuildingForPlayer( playerid, 2526, -64.1875, 1353.5781, 1079.1797, 0.25 );
	RemoveBuildingForPlayer( playerid, 2525, -62.7734, 1356.4844, 1079.1953, 0.25 );
	// Fossor
	RemoveBuildingForPlayer( playerid, 2523, 249.6953, 1291.7813, 1079.2578, 0.25 );
	RemoveBuildingForPlayer( playerid, 2528, 249.5938, 1293.5469, 1079.2500, 0.25 );
	RemoveBuildingForPlayer( playerid, 2520, 252.3203, 1293.4844, 1079.2344, 0.25 );
	RemoveBuildingForPlayer( playerid, 2522, 249.6719, 1294.4766, 1079.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 15035, 2205.9375, -1073.9922, 1049.4844, 0.25 );
	// Angusto
	RemoveBuildingForPlayer( playerid, 2523, 249.6953, 1291.7813, 1079.2578, 0.25 );
	RemoveBuildingForPlayer( playerid, 2528, 249.5938, 1293.5469, 1079.2500, 0.25 );
	RemoveBuildingForPlayer( playerid, 2520, 252.3203, 1293.4844, 1079.2344, 0.25 );
	RemoveBuildingForPlayer( playerid, 2522, 249.6719, 1294.4766, 1079.2031, 0.25 );
	// Artus
	RemoveBuildingForPlayer( playerid, 2248, 2235.8281, -1081.6484, 1048.5781, 0.25 );
	RemoveBuildingForPlayer( playerid, 2248, 2239.2266, -1081.6484, 1048.5781, 0.25 );
	RemoveBuildingForPlayer( playerid, 1798, 2242.0469, -1078.4297, 1048.0547, 0.25 );
	RemoveBuildingForPlayer( playerid, 1798, 2244.5469, -1078.4297, 1048.0547, 0.25 );
	RemoveBuildingForPlayer( playerid, 2248, 2235.8281, -1070.2188, 1048.5781, 0.25 );
	RemoveBuildingForPlayer( playerid, 2523, 2236.0391, -1068.9063, 1048.0547, 0.25 );
	RemoveBuildingForPlayer( playerid, 2249, 2236.1406, -1064.1953, 1048.6641, 0.25 );
	RemoveBuildingForPlayer( playerid, 2264, 2239.0156, -1071.6094, 1050.0625, 0.25 );
	RemoveBuildingForPlayer( playerid, 15057, 2240.6016, -1072.7031, 1048.0391, 0.25 );
	RemoveBuildingForPlayer( playerid, 2270, 2238.9063, -1068.9844, 1050.0469, 0.25 );
	RemoveBuildingForPlayer( playerid, 2248, 2239.2188, -1070.2188, 1048.5781, 0.25 );
	RemoveBuildingForPlayer( playerid, 2280, 2240.3203, -1070.8906, 1050.2188, 0.25 );
	RemoveBuildingForPlayer( playerid, 1703, 2240.7344, -1069.5156, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2526, 2237.2500, -1066.5391, 1048.0078, 0.25 );
	RemoveBuildingForPlayer( playerid, 2088, 2237.9063, -1064.2891, 1047.9766, 0.25 );
	RemoveBuildingForPlayer( playerid, 2528, 2238.8516, -1068.1563, 1048.0234, 0.25 );
	RemoveBuildingForPlayer( playerid, 2249, 2238.9531, -1064.8125, 1050.5625, 0.25 );
	RemoveBuildingForPlayer( playerid, 2269, 2240.3203, -1068.4453, 1050.1094, 0.25 );
	RemoveBuildingForPlayer( playerid, 2108, 2240.7734, -1066.3047, 1048.0234, 0.25 );
	RemoveBuildingForPlayer( playerid, 1741, 2241.3125, -1072.4688, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2297, 2242.1719, -1066.2266, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 1822, 2243.3281, -1067.8281, 1048.0234, 0.25 );
	RemoveBuildingForPlayer( playerid, 1703, 2243.8203, -1073.1875, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2271, 2245.3203, -1068.4453, 1050.1172, 0.25 );
	RemoveBuildingForPlayer( playerid, 1703, 2245.0313, -1067.6094, 1048.0156, 0.25 );
	RemoveBuildingForPlayer( playerid, 2108, 2244.7969, -1066.2734, 1048.0234, 0.25 );
	// Vindemia
	RemoveBuildingForPlayer( playerid, 2523, 284.5078, 1480.5156, 1079.2500, 0.25 );
	RemoveBuildingForPlayer( playerid, 2528, 284.4063, 1482.2813, 1079.2500, 0.25 );
	RemoveBuildingForPlayer( playerid, 2522, 284.4844, 1484.4219, 1079.1953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2520, 287.1328, 1483.4297, 1079.2266, 0.25 );
	// Caelum
	RemoveBuildingForPlayer( playerid, 1567, 2231.2969, -1111.4609, 1049.8594, 0.25 );
	RemoveBuildingForPlayer( playerid, 15039, 2232.3438, -1106.7422, 1049.7500, 0.25 );
	RemoveBuildingForPlayer( playerid, 15038, 2235.2891, -1108.1328, 1051.2656, 0.25 );
	//Ascensor
	RemoveBuildingForPlayer( playerid, 2259, 2316.3125, -1024.5156, 1051.3203, 0.25 );
	RemoveBuildingForPlayer( playerid, 2242, 2321.4609, -1019.7500, 1049.3672, 0.25 );
	RemoveBuildingForPlayer( playerid, 2078, 2318.2578, -1017.6016, 1049.1953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2203, 2312.1641, -1014.5547, 1050.4219, 0.25 );
	RemoveBuildingForPlayer( playerid, 2139, 2312.3750, -1014.5547, 1049.1953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2830, 2312.1406, -1013.6719, 1050.2578, 0.25 );
	RemoveBuildingForPlayer( playerid, 2139, 2312.3750, -1013.5625, 1049.1953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2241, 2322.4453, -1026.4453, 1050.5000, 0.25 );
	RemoveBuildingForPlayer( playerid, 2244, 2322.3594, -1019.8906, 1049.4844, 0.25 );
	RemoveBuildingForPlayer( playerid, 2112, 2322.6563, -1026.4219, 1049.5938, 0.25 );
	RemoveBuildingForPlayer( playerid, 2105, 2323.0156, -1026.8594, 1050.4453, 0.25 );
	RemoveBuildingForPlayer( playerid, 2224, 2322.6953, -1019.0859, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2281, 2324.3125, -1017.7969, 1051.2266, 0.25 );
	RemoveBuildingForPlayer( playerid, 2261, 2322.4609, -1015.4297, 1051.1563, 0.25 );
	RemoveBuildingForPlayer( playerid, 2165, 2323.3750, -1015.8984, 1053.7031, 0.25 );
	RemoveBuildingForPlayer( playerid, 1714, 2323.7500, -1014.8594, 1053.7109, 0.25 );
	RemoveBuildingForPlayer( playerid, 1755, 2325.2734, -1025.0625, 1049.1406, 0.25 );
	RemoveBuildingForPlayer( playerid, 2229, 2325.6406, -1017.2813, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2107, 2326.0703, -1016.6719, 1050.6641, 0.25 );
	RemoveBuildingForPlayer( playerid, 2088, 2325.5313, -1015.0938, 1053.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 15060, 2326.6641, -1022.1953, 1049.2266, 0.25 );
	RemoveBuildingForPlayer( playerid, 2280, 2327.3125, -1017.7969, 1051.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2104, 2327.1719, -1017.2109, 1049.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2088, 2327.4766, -1015.0938, 1053.6953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2139, 2312.3750, -1012.5703, 1049.1953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2303, 2312.3594, -1011.5859, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2313.8906, -1011.5781, 1049.8359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2314.9844, -1012.6797, 1049.8359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2115, 2314.9922, -1011.4063, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2832, 2315.0547, -1011.2813, 1050.0000, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2315.9297, -1011.5859, 1049.8359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2831, 2312.1875, -1010.6563, 1050.2656, 0.25 );
	RemoveBuildingForPlayer( playerid, 2136, 2312.3594, -1010.6094, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2313.8906, -1010.5391, 1049.8359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2315.9297, -1010.5469, 1049.8359, 0.25 );
	RemoveBuildingForPlayer( playerid, 2139, 2317.3438, -1009.5938, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2079, 2314.9844, -1009.2969, 1049.8359, 0.25 );
	RemoveBuildingForPlayer( playerid, 1822, 2324.3359, -1012.2188, 1049.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2333, 2323.4922, -1009.7266, 1053.7031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2291, 2323.7891, -1009.5938, 1049.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2291, 2324.7813, -1009.5938, 1049.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2331, 2323.4453, -1009.2813, 1053.9531, 0.25 );
	RemoveBuildingForPlayer( playerid, 2298, 2325.0625, -1010.7188, 1053.7031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2291, 2325.7813, -1009.5938, 1049.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 1822, 2326.6250, -1012.2188, 1049.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2291, 2326.7734, -1009.5938, 1049.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2312.3672, -1008.6094, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2138, 2314.3281, -1007.6328, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2305, 2312.3672, -1007.6250, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2135, 2313.3359, -1007.6250, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2139, 2317.3438, -1008.6016, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 1735, 2318.8047, -1007.9688, 1049.1953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2139, 2317.3438, -1007.6094, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2287, 2320.0547, -1007.2500, 1055.7578, 0.25 );
	RemoveBuildingForPlayer( playerid, 2194, 2322.3594, -1008.4453, 1054.9453, 0.25 );
	RemoveBuildingForPlayer( playerid, 2106, 2325.0391, -1006.9453, 1054.2266, 0.25 );
	RemoveBuildingForPlayer( playerid, 2528, 2321.2656, -1006.0313, 1053.7266, 0.25 );
	RemoveBuildingForPlayer( playerid, 2249, 2323.0156, -1005.8828, 1054.3984, 0.25 );
	RemoveBuildingForPlayer( playerid, 2526, 2318.3750, -1003.0703, 1053.7422, 0.25 );
	RemoveBuildingForPlayer( playerid, 2523, 2322.2500, -1003.0703, 1053.7188, 0.25 );
	RemoveBuildingForPlayer( playerid, 1760, 2327.8047, -1021.0313, 1049.1953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2295, 2328.7891, -1015.8281, 1049.1953, 0.25 );
	RemoveBuildingForPlayer( playerid, 1739, 2328.8359, -1023.6016, 1050.1094, 0.25 );
	RemoveBuildingForPlayer( playerid, 1739, 2329.0469, -1022.6953, 1050.1094, 0.25 );
	RemoveBuildingForPlayer( playerid, 2229, 2329.0703, -1017.2813, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 2295, 2329.2578, -1015.8281, 1053.7891, 0.25 );
	RemoveBuildingForPlayer( playerid, 2291, 2327.7578, -1009.5938, 1049.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2106, 2327.7266, -1006.9453, 1054.2266, 0.25 );
	RemoveBuildingForPlayer( playerid, 2291, 2329.1875, -1011.0078, 1049.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2291, 2329.1875, -1011.9922, 1049.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2291, 2329.1875, -1010.0234, 1049.2109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2285, 2328.9766, -1007.6406, 1051.2266, 0.25 );
	RemoveBuildingForPlayer( playerid, 2869, 2329.2891, -1025.8672, 1049.2266, 0.25 );
	RemoveBuildingForPlayer( playerid, 2829, 2329.4688, -1023.6250, 1050.0078, 0.25 );
	RemoveBuildingForPlayer( playerid, 2868, 2329.7656, -1023.0156, 1050.0000, 0.25 );
	RemoveBuildingForPlayer( playerid, 2117, 2329.6953, -1022.5859, 1049.2031, 0.25 );
	RemoveBuildingForPlayer( playerid, 1739, 2330.3672, -1023.5156, 1050.1094, 0.25 );
	RemoveBuildingForPlayer( playerid, 1739, 2330.3672, -1022.6875, 1050.1094, 0.25 );
	RemoveBuildingForPlayer( playerid, 2243, 2329.2969, -1018.0313, 1049.3984, 0.25 );
	RemoveBuildingForPlayer( playerid, 2096, 2330.2266, -1012.9688, 1053.7109, 0.25 );
	RemoveBuildingForPlayer( playerid, 2240, 2330.7422, -1010.7813, 1054.2578, 0.25 );
	RemoveBuildingForPlayer( playerid, 2096, 2330.2266, -1009.1875, 1053.7109, 0.25 );
	// Aurora
	RemoveBuildingForPlayer( playerid, 1738, -2171.4766, 643.6875, 1057.2344, 0.25 );
	RemoveBuildingForPlayer( playerid, 2233, -2167.4219, 640.7500, 1056.5781, 0.25 );
	RemoveBuildingForPlayer( playerid, 2296, -2168.4219, 643.7344, 1056.5781, 0.25 );
	RemoveBuildingForPlayer( playerid, 2028, -2167.5859, 644.6875, 1056.6797, 0.25 );
	RemoveBuildingForPlayer( playerid, 2108, -2168.3125, 646.7656, 1056.6016, 0.25 );
	RemoveBuildingForPlayer( playerid, 2233, -2165.4531, 640.7500, 1056.5781, 0.25 );
	RemoveBuildingForPlayer( playerid, 2225, -2166.2344, 640.9297, 1056.5781, 0.25 );
	RemoveBuildingForPlayer( playerid, 14554, -2164.5469, 641.1016, 1056.0000, 0.25 );
	RemoveBuildingForPlayer( playerid, 1819, -2167.2422, 643.7031, 1056.5859, 0.25 );
	RemoveBuildingForPlayer( playerid, 2288, -2166.7344, 646.7734, 1058.2266, 0.25 );
	RemoveBuildingForPlayer( playerid, 14543, -2163.6563, 644.9063, 1058.6250, 0.25 );
	RemoveBuildingForPlayer( playerid, 2271, -2161.9609, 646.7422, 1058.1953, 0.25 );
	RemoveBuildingForPlayer( playerid, 2270, -2158.4141, 646.7656, 1058.2188, 0.25 );
	RemoveBuildingForPlayer( playerid, 2108, -2163.8438, 646.9844, 1056.6016, 0.25 );
	RemoveBuildingForPlayer( playerid, 1742, -2160.3906, 647.3906, 1056.5859, 0.25 );
	RemoveBuildingForPlayer( playerid, 1738, -2158.3906, 647.0859, 1057.2344, 0.25 );
}

/* ** SQL Threads ** */
thread OnFurnitureLoad( )
{
	new rows, i = -1;
	new loadingTick = GetTickCount( );

	cache_get_data( rows, tmpVariable );
	if ( rows )
	{
		while( ++i < rows )
		{
			new fhandle = CreateFurniture(
				cache_get_field_content_int( i, "HOUSE_ID", dbHandle ),
				cache_get_field_content_int( i, "MODEL", dbHandle ),
				cache_get_field_content_float( i, "X", dbHandle ),
				cache_get_field_content_float( i, "Y", dbHandle ),
				cache_get_field_content_float( i, "Z", dbHandle ),
				cache_get_field_content_float( i, "RX", dbHandle ),
				cache_get_field_content_float( i, "RY", dbHandle ),
				cache_get_field_content_float( i, "RZ", dbHandle ),
				cache_get_field_content_int( i, "ID", dbHandle ),
				.creator = -1
			);
			if ( fhandle == ITER_NONE ) printf( "[FURNITURE ERROR] Too much furniture created for house id %d.", fhandle );
		}
	}
	printf( "[FURNITURE]: %d objects have been loaded. (Tick: %dms)", i, GetTickCount( ) - loadingTick );
	return 1;
}

/* ** Functions ** */
stock CreateFurniture( houseid, modelid, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz, fhandle = ITER_NONE, creator = 0 )
{
	if ( ! ( 0 <= houseid < MAX_HOUSES ) )
		return ITER_NONE;

	if ( fhandle == ITER_NONE ) // find free slot if not preloaded
		fhandle = Iter_Free( housefurniture[ houseid ] );

	if ( fhandle != ITER_NONE )
	{
		// insert into iterator
		Iter_Add( housefurniture[ houseid ], fhandle );
		g_houseFurnitureData[ houseid ] [ fhandle ] = CreateDynamicObject( modelid, x, y, z, rx, ry, rz, houseid + MAX_HOUSES );

		// insert into database
		if ( creator >= 0 )
		{
			format( szBigString, sizeof ( szBigString ), "INSERT INTO `FURNITURE`(`ID`,`HOUSE_ID`,`OWNER`,`MODEL`,`X`,`Y`,`Z`,`RX`,`RY`,`RZ`) VALUES (%d,%d,%d,%d,%f,%f,%f,%f,%f,%f)", fhandle, houseid, creator, modelid, x, y, z, rx, ry, rz );
			mysql_single_query( szBigString );
		}
	}
	return fhandle;
}

stock isFurnitureObject( modelid )
{
	for( new i = 0; i < sizeof( g_houseFurniture ); i++ )
		if ( g_houseFurniture[ i ] [ E_MODEL ] == modelid )
		    return true;

	return false;
}

stock destroyAllFurniture( houseid )
{
	if ( ! Iter_Contains( houses, houseid ) )
	    return 0;

	foreach ( new fhandle : housefurniture[ houseid ] ) {
		DestroyDynamicObject( g_houseFurnitureData[ houseid ] [ fhandle ] ), g_houseFurnitureData[ houseid ] [ fhandle ] = -1;
		Iter_SafeRemove( housefurniture[ houseid ], fhandle, fhandle );
	}

	mysql_single_query( sprintf( "DELETE FROM `FURNITURE` WHERE `HOUSE_ID`=%d", houseid ) );
	return 1;
}

stock getFurnitureID( modelid )
{
	for( new i = 0; i < sizeof( g_houseFurniture ); i++ )
		if ( modelid == g_houseFurniture[ i ] [ E_MODEL ] ) return i;

	return -1;
}

stock ShowOwnedFurnitureList( playerid, houseid )
{
	if ( Iter_Count( housefurniture[ houseid ] ) > 0 )
	{
		szLargeString = ""COL_WHITE"Furniture Item\n";
		foreach ( new fhandle : housefurniture[ houseid ] ) {
			new modelid = Streamer_GetIntData( STREAMER_TYPE_OBJECT, g_houseFurnitureData[ houseid ] [ fhandle ], E_STREAMER_MODEL_ID );
			new furniture_item = getFurnitureID( modelid );
			if ( furniture_item != -1 ) {
				format( szLargeString, sizeof( szLargeString ), "%s%s\n", szLargeString, g_houseFurniture[ furniture_item ] [ E_NAME ] );
			} else {
				strcat( szLargeString, "Unknown\n" );
			}
		}
		ShowPlayerDialog( playerid, DIALOG_FURNITURE_MAN_SEL, DIALOG_STYLE_TABLIST_HEADERS, "Furniture", szLargeString, "Select", "Back" );
	}
	else
	{
		SendError( playerid, "You don't own any furniture." );
		ShowPlayerDialog( playerid, DIALOG_FURNITURE, DIALOG_STYLE_LIST, "{FFFFFF}Furniture", "Purchase Furniture\nSelect Furniture Easily\nSelect Furniture Manually\nSelect Furniture Nearest\n"COL_RED"Remove All Furniture", "Confirm", "Back" );
	}
}

stock ShowFurnitureCategory( playerid )
{
	static
	    szCategory[ 148 ];

	if ( szCategory[ 0 ] == '\0' )
	{
	    for( new i = 0; i < sizeof( g_furnitureCategory ); i++ )
	        format( szCategory, sizeof( szCategory ), "%s%s\n", szCategory, g_furnitureCategory[ i ] );
	}
	ShowPlayerDialog( playerid, DIALOG_FURNITURE_CATEGORY, DIALOG_STYLE_LIST, "Furniture", szCategory, "Select", "Back" );
	return 1;
}

stock ShowFurnitureList( playerid, category )
{
	szLargeString = ""COL_WHITE"Furniture\t"COL_WHITE"Cost\n";

    for( new i = 0; i < sizeof( g_houseFurniture ); i++ ) if ( g_houseFurniture[ i ] [ E_CATEGORY ] == category )
		format( szLargeString, sizeof( szLargeString ), "%s%s\t"COL_GOLD"%s\n", szLargeString, g_houseFurniture[ i ] [ E_NAME ], cash_format( g_houseFurniture[ i ] [ E_COST ] ) );

	ShowPlayerDialog( playerid, DIALOG_FURNITURE_LIST, DIALOG_STYLE_TABLIST_HEADERS, "Furniture", szLargeString, "Select", "Back" );
}

stock GetClosestFurniture( houseid, playerid, &Float: dis = 99999.99, &furniture_handle = ITER_NONE )
{
	new
		Float: dis2,
		object = INVALID_OBJECT_ID,
		Float: X, Float: Y, Float: Z
	;
	foreach ( new fhandle : housefurniture[ houseid ] )
	{
		new objectid = g_houseFurnitureData[ houseid ] [ fhandle ];
		if ( IsValidDynamicObject( objectid ) )
		{
			GetDynamicObjectPos( objectid, X, Y, Z );
	    	dis2 = GetPlayerDistanceFromPoint( playerid, X, Y, Z );
	    	if ( dis2 < dis && dis2 != -1.00 ) {
	    	    dis = dis2;
	    	    object = objectid;
	    	    furniture_handle = fhandle;
			}
		}
	}
	return object;
}

stock FillHomeWithFurniture( houseid, interior_id ) {
	if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Cattus Interior" ) ) {
		CreateFurniture( houseid, 2181, 273.795989, 304.962005, 998.148010, 0.000000, 0.000000, -90.000000 );
		CreateFurniture( houseid, 19317, 273.561004, 307.549011, 998.896972, -8.899999, 0.000000, -44.599998 );
		CreateFurniture( houseid, 1745, 269.713012, 305.380004, 998.057983, 0.000000, 0.000000, 0.000000 );
	}
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Assum Interior" ) ) {
		CreateFurniture( houseid, 1745, 246.465103, 302.465484, 998.127441, 0.000000, 0.000000, -90.000000 );
		CreateFurniture( houseid, 1717, 244.388854, 301.269592, 998.117431, 0.000000, 0.000000, 47.600032 );
		CreateFurniture( houseid, 1742, 250.075302, 305.350036, 998.127441, 0.000000, 0.000000, -90.000000 );
		CreateFurniture( houseid, 349, 248.876480, 302.361389, 998.922302, -95.399993, 0.000000, 0.000000 );
	}
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Fossor Interior" ) ) {
		CreateFurniture( houseid, 11720, 2210.785888, -1072.437988, 1049.422973, 0.000000, 0.000000, -90.000000 );
		CreateFurniture( houseid, 2100, 2214.089111, -1078.663940, 1049.483032, 0.000000, 0.000000, 180.000000 );
		CreateFurniture( houseid, 19317, 2212.149902, -1072.442993, 1051.865966, 0.000000, -45.000000, -90.000000 );
		CreateFurniture( houseid, 19317, 2212.149902, -1072.442993, 1051.865966, 0.000000, 45.000000, -90.000000 );
	}
	/*else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Angusto Interior" ) ) {
		CreateFurniture( houseid, 11743, 265.862518, 1290.442016, 1080.305175, 0.000000, 0.000000, 180.000000 );
	}*/
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Organum Interior" ) ) {
		CreateFurniture( houseid, 2297, 308.390014, 300.296997, 1002.294006, 0.000000, 0.000000, 135.000000 );
		CreateFurniture( houseid, 1754, 308.322998, 303.714996, 1002.304016, 0.000000, 0.000000, -15.600000 );
		CreateFurniture( houseid, 1754, 306.437988, 303.539001, 1002.304016, 0.000000, 0.000000, 33.099998 );
		CreateFurniture( houseid, 19631, 303.839996, 302.459014, 1002.731994, 70.099998, 93.000000, 94.300003 );
	}
	/*else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Bulbus Interior" ) ) {
		CreateFurniture( houseid, 19893, -69.010528, 1362.585815, 1079.770507, 0.000000, 0.000000, -110.200012 );
	}
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Vindemia Interior" ) ) {
		CreateFurniture( houseid, 1518, 292.440887, 1472.344360, 1080.087646, 0.000000, 0.000000, 180.000000 );
		CreateFurniture( houseid, 1748, 288.720428, 1490.140014, 1079.787353, 0.000000, 0.000000, 45.699871 );
		CreateFurniture( houseid, 19893, 302.293579, 1475.090209, 1079.957519, 0.000000, 0.000000, -160.199905 );
	}*/
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Aurora Interior" ) ) {
		CreateFurniture( houseid, 1828, -2165.865966, 644.096984, 1056.583007, 0.000000, 0.000000, 0.000000 );
		CreateFurniture( houseid, 11743, -2162.052978, 637.107971, 1057.515991, 0.000000, 0.000000, 129.699996 );
		CreateFurniture( houseid, 19830, -2158.127929, 637.051025, 1057.505981, 0.000000, 0.000000, -147.300003 );
		CreateFurniture( houseid, 19893, -2161.440917, 643.953002, 1057.384033, 0.000000, 0.000000, -85.699996 );
	}
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Fragor Interior" ) ) {
		CreateFurniture( houseid, 2563, 307.286010, 1121.037963, 1082.881958, 0.000000, 0.000000, 90.000000 );
		CreateFurniture( houseid, 2313, 318.532989, 1124.858032, 1082.871948, 0.000000, 0.000000, 0.000000 );
		CreateFurniture( houseid, 1786, 319.161987, 1125.123046, 1083.342041, 0.000000, 0.000000, 0.000000 );
		CreateFurniture( houseid, 1828, 323.757995, 1129.447021, 1082.871948, 0.000000, 0.000000, 90.000000 );
	}
	/*else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Mundus Interior" ) ) {
		CreateFurniture( houseid, 19893, 26.778570, 1347.625488, 1088.554687, 0.000000, 0.000000, 124.699920 );
		CreateFurniture( houseid, 356, 31.855621, 1346.810668, 1083.904663, 85.500068, -65.499977, -2.500000 );
	}*/
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Artus Interior" ) ) {
		CreateFurniture( houseid, 19786, 2242.808105, -1065.896972, 1049.543945, 0.000000, 0.000000, 0.000000 );
		CreateFurniture( houseid, 2313, 2242.090087, -1066.394042, 1048.050048, 0.000000, 0.000000, 0.000000 );
		CreateFurniture( houseid, 1702, 2243.757080, -1069.983032, 1047.969970, 0.000000, 0.000000, 180.000000 );
		CreateFurniture( houseid, 1704, 2244.997070, -1067.770996, 1047.969970, 0.000000, 0.000000, -102.800003 );
		CreateFurniture( houseid, 1704, 2240.719970, -1068.850952, 1047.969970, 0.000000, 0.000000, 95.699996 );
	}
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Caelum Interior" ) ) {
		CreateFurniture( houseid, 11720, 2230.312988, -1106.276000, 1049.852050, 0.000000, 0.000000, 90.000000 );
		CreateFurniture( houseid, 2100, 2235.194091, -1110.384033, 1049.881958, 0.000000, 0.000000, -90.000000 );
		CreateFurniture( houseid, 321, 2230.624023, -1107.496948, 1049.881958, 90.000000, 90.000000, 0.000000 );
		CreateFurniture( houseid, 362, 2226.039062, -1110.713012, 1050.806030, 0.000000, -5.199999, 0.000000 );
	}
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Rotta Interior" ) ) {
		CreateFurniture( houseid, 11743, 2501.027099, -1707.707031, 1014.861999, 0.000000, 0.000000, -91.699996 );
		CreateFurniture( houseid, 2181, 2492.664062, -1704.439941, 1013.742004, 0.000000, 0.000000, 180.000000 );
		CreateFurniture( houseid, 1717, 2492.029052, -1694.394042, 1013.786987, 0.000000, 0.000000, -36.900001 );
		CreateFurniture( houseid, 1755, 2494.482910, -1695.970947, 1013.721984, 0.000000, 0.000000, -124.000000 );
		CreateFurniture( houseid, 1755, 2492.474121, -1696.670043, 1013.721984, 0.000000, 0.000000, 160.500000 );
	}
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Ascensor Interior" ) ) {
		CreateFurniture( houseid, 19786, 2325.875000, -1017.260986, 1051.161987, 0.000000, 0.000000, 0.000000 );
		CreateFurniture( houseid, 1743, 2325.341064, -1018.752990, 1049.219970, 0.000000, 0.000000, 0.000000 );
		CreateFurniture( houseid, 1828, 2325.969970, -1022.057983, 1049.189941, 0.000000, 0.000000, 90.000000 );
		CreateFurniture( houseid, 11720, 2324.851074, -1008.127014, 1053.727050, 0.000000, 0.000000, 0.000000 );
	}
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Colonel Interior" ) ) {
		CreateFurniture( houseid, 2100, 2810.426025, -1164.852050, 1024.578979, 0.000000, 0.000000, 0.000000 );
		CreateFurniture( houseid, 2297, 2812.813964, -1171.582031, 1024.578979, 0.000000, 0.000000, -135.000000 );
		CreateFurniture( houseid, 1704, 2810.127929, -1171.822021, 1024.548950, 0.000000, 0.000000, 72.099998 );
		CreateFurniture( houseid, 1745, 2817.600097, -1167.550048, 1028.151000, 0.000000, 0.000000, 180.000000 );
		CreateFurniture( houseid, 19319, 2817.147949, -1171.015991, 1030.425048, 0.000000, 45.000000, 180.000000 );
	}
	/*else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Godfather Interior" ) ) {
		CreateFurniture( houseid, 358, 150.524795, 1370.906127, 1083.410156, -78.500221, 37.299991, -99.299461 );
	}*/
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Recens Interior" ) ) {
		CreateFurniture( houseid, 2229, 2257.180908, -1221.848999, 1048.001953, 0.000000, 0.000000, 90.000000 );
		CreateFurniture( houseid, 2181, 2257.602050, -1224.232055, 1047.991943, 0.000000, 0.000000, 90.000000 );
		CreateFurniture( houseid, 19318, 2258.295898, -1219.160034, 1048.699951, -10.199999, 0.000000, 0.000000 );
		CreateFurniture( houseid, 357, 2262.698974, -1225.001953, 1048.322998, 0.000000, -90.000000, 0.000000 );
		CreateFurniture( houseid, 19832, 2262.360107, -1224.750976, 1048.021972, 0.000000, 0.000000, -24.799999 );
	}
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Novus Interior" ) ) {
		CreateFurniture( houseid, 1745, 2364.553955, -1122.925048, 1049.864013, 0.000000, 0.000000, 90.000000 );
		CreateFurniture( houseid, 2100, 2363.528076, -1129.816040, 1049.874023, 0.000000, 0.000000, 90.000000 );
		CreateFurniture( houseid, 1416, 2374.649902, -1132.967041, 1050.415039, 0.000000, 0.000000, -90.000000 );
		CreateFurniture( houseid, 372, 2374.791015, -1133.095947, 1050.974975, 90.000000, 90.000000, 0.000000 );
		CreateFurniture( houseid, 372, 2374.615966, -1133.433959, 1050.974975, 90.000000, 90.000000, -27.100000 );
	}
	else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Securuse Interior" ) ) {
		CreateFurniture( houseid, 1745, 2311.577880, -1139.357055, 1053.293945, 0.000000, 0.000000, 180.000000 );
		CreateFurniture( houseid, 2181, 2310.585937, -1135.288940, 1053.303955, 0.000000, 0.000000, 0.000000 );
		CreateFurniture( houseid, 1702, 2322.388916, -1141.819946, 1049.468994, 0.000000, 0.000000, 90.000000 );
		CreateFurniture( houseid, 1702, 2326.492919, -1139.828002, 1049.468994, 0.000000, 0.000000, -90.000000 );
		CreateFurniture( houseid, 1742, 2318.163085, -1140.253051, 1049.708984, 0.000000, 0.000000, 90.000000 );
		CreateFurniture( houseid, 1742, 2318.163085, -1141.673950, 1049.708984, 0.000000, 0.000000, 90.000000 );
		CreateFurniture( houseid, 2100, 2328.367919, -1137.057006, 1049.489013, 0.000000, 0.000000, 0.000000 );
	}
	// else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Lorem Interior" ) )
	// else if ( strmatch( g_houseInteriors[ interior_id ] [ E_NAME ], "Domus Interior" ) )
}
