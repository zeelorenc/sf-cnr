/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\business\business.pwn
 * Purpose: business system for sa-mp
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define MAX_BUSINESSES				( 250 )
#define MAX_DROPS 					( 5 )
#define MAX_BUSINESS_MEMBERS 		( 8 )
#define MAX_BIZ_VEH_MODELS 			( 18 )
#define MAX_BIZ_ACTORS			 	( 9 )

#define BUSINESS_WEED				( 0 )
#define BUSINESS_METH				( 1 )
#define BUSINESS_COKE 				( 2 )
#define BUSINESS_WEAPON 			( 3 )

#define MAX_WEED_AMOUNT				( 30 )
#define MAX_METH_AMOUNT 			( 20 )
#define MAX_COKE_AMOUNT 			( 10 )
#define MAX_WEAPON_AMOUNT 			( 10 )

#define PROGRESS_CRACKING_BIZ 		( 8 )

/* ** Macros ** */
#define UpdateBusinessTitle(%0) \
	 mysql_function_query(dbHandle,sprintf("SELECT f.`NAME` FROM `USERS` f LEFT JOIN `BUSINESSES` m ON m.`OWNER_ID`=f.`ID` WHERE m.`ID`=%d",%0),true,"OnUpdateBusinessTitle","i",%0)

#define IsValidBusiness(%0) \
	 ( 0 <= %0 < MAX_BUSINESSES && Iter_Contains( business, %0 ) )

/* ** Variables ** */
enum E_BUSINESS_DATA
{
	E_NAME[ 32 ],				E_COST,							E_WORLD,
	E_OWNER_ID,					E_INTERIOR_TYPE,				E_MEMBERS[ MAX_BUSINESS_MEMBERS ],

	E_SUPPLIES,					E_PRODUCT,						Text3D: E_PROD_LABEL,
	E_PROD_TIMESTAMP, 			E_BANK,							E_SECURITY_LEVEL,

	E_CAR_MODEL_ID,				E_HELI_MODEL_ID,				E_EXTRA_MEMBERS,
	bool: E_CAR_NOS,			bool: E_CAR_RIMS,				E_UPGRADES,

	bool: E_CRACKED, 			bool: E_BEING_CRACKED,  		E_CRACKED_TS,
	E_CRACKED_WAIT,				E_ROBBERY_ID,

	E_EXPORT_CP[ MAX_DROPS ],	E_EXPORT_ICON[ MAX_DROPS ],		E_EXPORT_INDEX[ MAX_DROPS ],
	E_EXPORT_VALUE,				E_EXPORT_CIRCLE[ MAX_DROPS ],	E_EXPORT_STARTED,
	E_EXPORT_CITY,				bool: E_EXPORTED[ MAX_DROPS ],	E_EXPORTED_AMOUNT,

	Float: E_X, 				Float: E_Y, 					Float: E_Z,
	E_ENTER_CP,					E_EXIT_CP,						E_VEHICLE_DECOR,
	Text3D: E_ENTER_LABEL, 		Text3D: E_EXIT_LABEL,
};

enum E_BUSINESS_INT_DATA
{
	E_NAME[ 8 ],

	Float: E_X, 				Float: E_Y, 				Float: E_Z,
	Float: E_PROD_X, 			Float: E_PROD_Y, 			Float: E_PROD_Z,

	E_COST_PRICE,				E_PRODUCTION_TIME, 			E_MAX_SUPPLIES,
	E_UPGRADE_COST,

	Float: E_SAFE_X, 			Float: E_SAFE_Y, 			Float: E_SAFE_Z,
	Float: E_SAFE_ROTATION
};

enum E_BUSINESS_VEHICLE_DATA
{
	E_ID, // used only for saving it in the database (change MAX_BIZ_VEH_MODEL on new entry)

	E_NAME[ 12 ],				E_MODEL,					E_BOOT_OPEN,

	E_OBJECT_MODEL,
	Float: E_O_X,				Float: E_O_Y,				Float: E_O_Z,
	Float: E_O_RX,				Float: E_O_RY,				Float: E_O_RZ,

	E_COST
};

/*enum E_SECURITY_LEVEL_DATA
{
	E_LEVEL[ 17 ],				Float: E_COST_MULTIPLIER,	E_BREAKIN_COOLDOWN
};*/

new
	g_businessInteriorData 			[ 4 ] [ E_BUSINESS_INT_DATA ] =
	{
		{ "Weed",	 -1719.1877, -1377.3049, 5874.8721, -1734.094, -1374.4567, 5874.1475, 10000, 6, MAX_WEED_AMOUNT, 2500000,  -1741.97705, -1380.14294, 5873.60009, -90.00000 }, // 12
		{ "Meth",	 2040.54810, 1011.41470, 1513.2777, 2029.2456, 1003.55200, 1510.2416, 18000, 8, MAX_METH_AMOUNT, 4000000,	2031.918945, 1000.044006, 1509.69104, 180.00000 }, // 16
		{ "Coke",  	 2566.50070, -1273.2887, 1143.7203, 2558.5261, -1290.6298, 1143.7242, 50000, 10, MAX_COKE_AMOUNT, 7500000,	2555.145019, -1314.12695, 1143.17395, 180.00000 }, // 20
		{ "Weapons", -6962.5542, -269.4713, 836.5154, -6969.2417, -248.1167, 836.5154, 125000, 24, MAX_WEAPON_AMOUNT, 16000000, -6942.84814, -246.391998, 836.989990, 90.000000 } // 48
	},
	g_businessCarModelData[ ] [ E_BUSINESS_VEHICLE_DATA ] =
	{
		{ -1, "Yosemite",	554, 0,  3800, 0.000000, -1.200000, 0.000000, 0.000000, 0.000000, 0.000000, 0 },
		{ 0,  "Buccaneer", 	518, 0,  1279, 0.000000, -2.250000, -0.07500, 21.60000, 0.000000, 0.000000, 500000 },
		{ 1,  "Dune", 		573, 0,     0, 0.000000, 0.0000000, 0.000000, 0.000000, 0.000000, 0.000000, 1000000 },
		{ 2,  "Sabre", 		475, 1,  1279, 0.000000, -2.175000, -0.07500, 24.30000, 0.000000, 0.000000, 2500000 },
		{ 3,  "Patriot", 	470, 1,  1279, 0.000000, -1.800000, 0.150000, 29.70000, 0.000000, 0.000000, 10000000 },
		{ 4,  "Buffalo", 	402, 1,  1279, 0.000000, -2.250000, 0.225000, 140.3999, 0.000000, 0.000000, 15000000 },
		{ 5,  "Elegy", 		562, 1,  1279, 0.000000, -1.875000, 0.075000, 21.60000, 0.000000, 0.000000, 18000000 },
		{ 6,  "Savanna", 	567, 1,  1279, 0.000000, -1.875000, 0.075000, 21.60000, 0.000000, 0.000000, 20000000 },
		{ 7,  "Sultan", 	560, 1,  1279, 0.000000, -1.875000, 0.150000, 29.70000, 0.000000, 0.000000, 25000000 },
		{ 8,  "Infernus", 	411, 0,     0, 0.000000, 0.0000000, 0.000000, 0.000000, 0.000000, 0.000000, 27500000 },
		{ 9,  "Turismo", 	451, 0, 18694, 0.000000, -2.475000, -1.95000, 0.000000, 0.000000, 180.0000, 30000000 },
		{ 10, "ChuffSec",	428, 0, 19601, -0.075000, 3.000001, -0.52499, -10.800000, 0.0000, 180.8998, 1337 }
	},
	g_businessAirModelData[ ] [ E_BUSINESS_VEHICLE_DATA ] =
	{
		{ -1, "Levetian", 	417, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0 },
		{ 11, "Raindance",	563, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5000000 },
		{ 12, "Sparrow",	469, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 12500000 },
		{ 13, "Shamal", 	519, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 17500000 },
		{ 14, "Dodo", 		593, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 20000000 },
		{ 15, "Maverick", 	487, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 25000000 },
		{ 16, "Rustler", 	476, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 30000000 },
		{ 17, "Seasparrow",	447, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1337 }
	},
	/*g_businessSecurityData[ 4 ] [ E_SECURITY_LEVEL_DATA ] =
	{
		{ ""COL_RED"NONE", 		0.0, 300 },
		{ ""COL_ORANGE"LOW", 	0.25, 14400 },
		{ ""COL_YELLOW"Medium", 0.75, 28800 },
		{ ""COL_GREEN"High", 	1.65, 43200 }
	},*/
	Float: g_roadBusinessExportData[ 3 ] [ 20 ] [ 3 ] =
	{
		// sf
		{
			{ -1955.7727, -859.1984, 31.6437 }, { -1821.7363, -175.0119, 8.97350 }, { -2052.4871, -42.96680, 34.9414 }, { -2474.6616, -128.5411, 25.2988 },
			{ -2755.9614, -130.8518, 6.41240 }, { -2796.0234, 772.94480, 50.2686 }, { -2471.4382, 786.22140, 35.1719 }, { -2438.4072, 1038.4346, 50.1885 },
			{ -2513.1267, 1217.6478, 36.9885 }, { -2141.8496, 1217.6788, 47.1079 }, { -2049.0244, 1108.5524, 53.1531 }, { -1822.6821, 1302.3539, 59.2771 },
			{ -1629.2491, 886.42290, 8.97560 }, { -1808.1614, 781.52560, 30.2879 }, { -1758.9180, 515.09530, 28.1970 }, { -2191.0745, 1031.4736, 79.8809 },
			{ -2495.9778, 322.49280, 30.3050 }, { -2496.6187, 153.75120, 7.07910 }, { -2278.0718, 0.8677000, 34.9636 }, { -1931.6978, 268.7024, 40.6186 }
		},

		// lv
		{
			{ 2213.5220, 1968.3105, 10.4767 }, { 2636.1663, 1070.0991, 10.5039 }, { 2524.9036, 918.76700, 10.5057 }, { 2452.5000, 697.58150, 11.1406 },
			{ 2493.1589, 1211.8390, 10.5000 }, { 2810.7197, 2021.3927, 10.5000 }, { 2825.9368, 2602.4082, 10.5000 }, { 2113.6406, 2416.5217, 49.2031 },
			{ 1747.8733, 2240.5823, 10.5000 }, { 1062.3818, 2071.9485, 10.5000 }, { 1165.3585, 1998.6810, 10.5000 }, { 1091.2410, 1890.5908, 10.5000 },
			{ 1461.9596, 972.89570, 9.81850 }, { 1696.4849, 918.22110, 10.4934 }, { 1920.3811, 959.92890, 10.4965 }, { 2490.7720, 2397.3308, 3.89006 },
			{ 423.12482, 2547.1460, 16.2824 }, { -141.1849, 1239.3811, 19.4340 }, { -106.3463, 1373.7528, 10.2663 }, { -830.0345, 1461.5646, 14.3749 }
		},

		// ls
		{
			{ 2473.6917, -1692.1799, 13.0918 }, { 2299.9851, -1796.2080, 13.1327 }, { 2185.0979, -1669.2697, 14.1983 }, { 2087.7139, -1569.9736, 12.7890 },
			{ 2352.3740, -1159.1722, 27.2014 }, { 1027.1260, -1364.0104, 13.4350 }, { 369.96310, -2043.9053, 7.54070 }, { 1449.2119, -1842.7052, 13.4189 },
			{ 1859.6608, -1855.0867, 13.4456 }, { 1924.1621, -2124.3977, 13.4511 }, { 2107.5293, -2416.4065, 13.4130 }, { 2174.3906, -2265.9956, 13.2424 },
			{ 2780.3481, -2494.4780, 13.5250 }, { 2457.3801, -1969.2207, 13.3801 }, { 1826.3085, -1125.9072, 23.8518 }, { 973.43920, -1257.8624, 16.6373 },
			{ 1344.5089, -1752.9572, 13.0808 }, { 1315.9122, -918.28160, 37.7431 }, { 995.74950, -921.07030, 41.8990 }, { 659.64170, -1417.0704, 13.5658 }
		}
	},
	Float: g_airBusinessExportData[ 3 ] [ 20 ] [ 3 ] =
	{
		// SF
		{
			//-1860.0874,801.0096,117.2762
			{ -2031.557617, -32.978599, 56.509998 }, { -2150.111572, -251.47599, 47.49000 }, { -2550.367431, 64.2822030, 25.639999 }, { -2786.211425, 784.576416, 59.41999 },
			{ -2632.868896, 1417.777709, 24.76000 }, { -1542.633800, 924.657800, 6.611400 }, { -1466.235473, 920.849975, 29.129999 }, { -1538.288696, 86.039398, 17.319999 },
			{ -1854.864379, -153.065704, 21.64999 }, { -2522.358642, -654.40240, 147.8999 }, { -2676.479248, 250.410903, 14.350000 }, { -2476.141357, 785.419372, 35.16999 },
			{ -1421.171142, -559.867370, 14.14000 }, { -1944.489624, -1035.7249, 53.34000 }, { -1983.709960, 751.809082, 85.919998 }, { -1870.065917, 970.645812, 49.79999 },
			{ -1864.599975, 807.597290, 112.54000 }, { -1778.899047, 574.798583, 234.8899 }, { -2232.311035, 133.423599, 57.900001 }, { -1766.309082, 1018.421386, 97.7099 }
		},

		// LV
		{
			{ 1529.842651, 1028.566040, 10.819999 }, { 2586.644042, 1120.391113, 16.729999 }, { 2644.996826, 1771.328125, 18.799999 }, { 2778.071289, 2595.210449, 10.81999 },
			{ 2555.316650, 2312.920410, 10.819999 }, { 2484.965087, 2342.515625, 10.819999 }, { 2388.430664, 2813.810058, 10.819999 }, { 923.603027, 2164.776367, 10.819999 },
			{ 1742.377441, 2216.271240, 10.819999 }, { 1141.489501, 1961.233642, 10.819999 }, { 697.5897820, 1983.606567, 8.6300000 }, { 431.901306, 2544.465820, 21.600000 },
			{ 1449.718750, 2370.324462, 10.819999 }, { 2046.728759, 2233.209716, 10.819999 }, { 1714.863769, 1795.094116, 10.819999 }, { 2301.520751, 1734.541748, 10.81999 },
			{ 2436.147949, 716.4329830, 10.819999 }, { 1902.672119, 950.4011230, 10.819999 }, { -164.004104, 1227.733764, 19.739999 }, { -823.314025, 1454.987060, 13.93999 }
		},

		// LS
		{
			{ 2491.046875, -1669.197143, 13.329999 }, { 2418.060302, -1232.265502, 24.43000 }, { 1211.151855, -1097.152343, 25.459999 }, { 666.427124, -1289.167236, 13.460000 },
			{ 1289.633911, -787.4636230, 96.449996 }, { 656.0767820, -1865.779418, 5.460000 }, { 369.996093, -2029.1451410, 7.6700000 }, { 708.949829, -1430.432617, 13.529999 },
			{ 1005.249572, -1349.099853, 13.340000 }, { 1480.326782, -1895.195922, 22.27000 }, { 1119.803833, -2037.035400, 78.209999 }, { 1657.912231, -1705.729614, 20.47999 },
			{ 1923.681030, -1679.990112, 13.539999 }, { 1700.012207, -2146.625732, 13.53999 }, { 1700.012207, -2146.625732, 13.539999 }, { 2746.048583, -2445.280273, 13.64000 },
			{ 1908.276855, -1319.675048, 14.189999 }, { 1286.067504, 181.42990100, 20.27000 }, { 2314.976318, -4.973299000, 32.529998 }, { 665.014404, -614.880187, 16.3299999 }
		}
	},
	g_businessData					[ MAX_BUSINESSES ] [ E_BUSINESS_DATA ],
	g_businessActors				[ MAX_BUSINESSES ] [ MAX_BIZ_ACTORS ],
	g_isBusinessVehicle 			[ MAX_VEHICLES ] = { -1, ... },
	g_businessVehicle 				[ MAX_BUSINESSES ] = { INVALID_VEHICLE_ID, ... },
	bool: g_businessVehicleUnlocked [ MAX_BUSINESSES ] [ MAX_BIZ_VEH_MODELS char ],
	Iterator: business 				< MAX_BUSINESSES >
	//g_BusinessUpdateTickCount		= 0
;

/* ** Hooks ** */
hook OnScriptInit( )
{
	mysql_function_query( dbHandle, "SELECT * FROM `BUSINESSES`", true, "OnBusinessLoad", "" );
	return 1;
}

hook OnServerUpdate( )
{
	/*new
		current_tickcount = GetTickCount( );

	if ( current_tickcount < g_BusinessUpdateTickCount ) {
		// incase the server update timer is faster than 960ms
		g_BusinessUpdateTickCount = current_tickcount + 950;
		return 1;
	}*/

	// Replenish product
	foreach ( new businessid : business ) if ( g_businessData[ businessid ] [ E_PROD_TIMESTAMP ] )
	{
		// reduce business production time by a second
		g_businessData[ businessid ] [ E_PROD_TIMESTAMP ] --;

		// if the production timestamp is less than 0 ... refuel
		if ( g_businessData[ businessid ] [ E_PROD_TIMESTAMP ] <= 0 )
		{
			// update the timestamps and switch stock for product
			g_businessData[ businessid ] [ E_PRODUCT ] += g_businessData[ businessid ] [ E_SUPPLIES ];
			g_businessData[ businessid ] [ E_PROD_TIMESTAMP ] = 0;
			g_businessData[ businessid ] [ E_SUPPLIES ] = 0;

			// alert any associates
			foreach ( new p : Player ) if ( IsBusinessAssociate( p, businessid ) )  {
				SendClientMessageFormatted( p, -1, ""COL_GREY"[BUSINESS]"COL_WHITE" Production has completed for "COL_GREY"%s"COL_WHITE".", g_businessData[ businessid ] [ E_NAME ] );
			}

			// update db
			UpdateBusinessData( businessid );
		}
		else if ( g_businessData[ businessid ] [ E_PROD_TIMESTAMP ] % 60 == 0 ) // every minute that passes, update in the sql
		{
			mysql_single_query( sprintf( "UPDATE `BUSINESSES` SET `PROD_TIMESTAMP` = %d WHERE `ID` = %d", g_businessData[ businessid ] [ E_PROD_TIMESTAMP ], businessid ) );
		}

		// update label anyway
		UpdateBusinessProductionLabel( businessid );
	}
	return 1;
}

hook OnVehicleDeath( vehicleid, killerid )
{
	if ( g_isBusinessVehicle[ vehicleid ] != -1 && Iter_Contains( business, g_isBusinessVehicle[ vehicleid ] ) )
	{
		new
			businessid = g_isBusinessVehicle[ vehicleid ], attackerid = g_VehicleLastAttacker[ vehicleid ],
			payout = floatround( float( g_businessData[ businessid ] [ E_EXPORT_VALUE ] * ( MAX_DROPS - g_businessData[ businessid ] [ E_EXPORTED_AMOUNT ] ) ) * ( p_Class[ killerid ] == CLASS_POLICE ? 0.3 : 0.25 ) )
		;

		if ( g_businessData[ businessid ] [ E_EXPORT_STARTED ] == 1 )
		{
			// printf("2.is associate %d, ticks %d", IsBusinessAssociate( attackerid, businessid ), g_iTime - g_VehicleLastAttacked[ vehicleid ] );
			if ( IsPlayerConnected( attackerid ) && ! IsBusinessAssociate( attackerid, businessid ) && ( g_iTime - g_VehicleLastAttacked[ vehicleid ] ) < 8 )
			{
				GivePlayerScore( attackerid, 2 );
				GivePlayerCash( attackerid, payout );
				if ( p_Class[ attackerid ] != CLASS_POLICE ) GivePlayerWantedLevel( attackerid, 6 ), GivePlayerExperience( attackerid, E_ROBBERY );
				else GivePlayerExperience( attackerid, E_POLICE );
				SendGlobalMessage( -1, ""COL_GREY"[BUSINESS]"COL_WHITE" %s(%d) has destroyed a business vehicle and earned "COL_GOLD"%s"COL_WHITE"!", ReturnPlayerName( attackerid ), attackerid, cash_format( payout ) );
			}
			else
			{
				if ( IsPlayerConnected( killerid ) ) {
					if ( IsBusinessAssociate( killerid, businessid ) ) SendGlobalMessage( -1, ""COL_GREY"[BUSINESS]"COL_WHITE" %s(%d)'s business vehicle with "COL_GOLD"%s"COL_WHITE" in inventory got destroyed!", ReturnPlayerName( killerid ), killerid, cash_format( g_businessData[ businessid ] [ E_EXPORT_VALUE ] * ( MAX_DROPS - g_businessData[ businessid ] [ E_EXPORTED_AMOUNT ] ) ) );
					else
					{
						GivePlayerScore( killerid, 2 );
						GivePlayerCash( killerid, payout );
						if ( p_Class[ killerid ] != CLASS_POLICE ) GivePlayerWantedLevel( killerid, 6 ), GivePlayerExperience( killerid, E_ROBBERY );
						else GivePlayerExperience( killerid, E_POLICE ), StockMarket_UpdateEarnings( E_STOCK_GOVERNMENT, payout, 0.05 );
						SendGlobalMessage( -1, ""COL_GREY"[BUSINESS]"COL_WHITE" %s(%d) has destroyed a business vehicle and earned "COL_GOLD"%s"COL_WHITE"!", ReturnPlayerName( killerid ), killerid, cash_format( payout ) );
					}
				}
			}

			// stop the mission
			StopBusinessExportMission( businessid );
		}
	}
	return 1;
}

hook OnPlayerAttemptBreakIn( playerid, houseid, businessid )
{
	new is_fbi = GetPlayerClass( playerid ) == CLASS_POLICE && p_inFBI{ playerid } && ! p_inArmy{ playerid } && ! p_inCIA{ playerid };
	new is_burglar = GetPlayerClass( playerid ) == CLASS_CIVILIAN && IsPlayerJob( playerid, JOB_BURGLAR );

	// prohibit non-cop,
	if ( ! ( ! is_fbi && is_burglar || ! is_burglar && is_fbi ) )
		return 0;

	if ( IsValidBusiness( businessid ) )
	{
		new current_time = GetServerTime( );
		new crackpw_cooldown = GetPVarInt( playerid, "crack_biz_cool" );

		if ( crackpw_cooldown > current_time ) {
			return SendError( playerid, "You are unable to attempt a house break-in for %d seconds.", crackpw_cooldown - current_time ), 0;
		}

		if ( g_iTime > g_businessData[ businessid ] [ E_CRACKED_TS ] && g_businessData[ businessid ] [ E_CRACKED ] ) g_businessData[ businessid ] [ E_CRACKED ] = false; // The Virus Is Disabled.

		if ( IsBusinessAssociate( playerid, businessid ) )
			return SendError( playerid, "You are an associate of this business, you cannot crack it." );

		if ( g_businessData[ businessid ] [ E_CRACKED_WAIT ] > g_iTime )
		    return SendError( playerid, "This house had its password recently had a cracker run through. Come back later." );

		if ( g_businessData[ businessid ] [ E_CRACKED ] || g_businessData[ businessid ] [ E_BEING_CRACKED ] )
		    return SendError( playerid, "This house is currently being cracked or is already cracked." );

		// alert
		foreach ( new ownerid : Player ) if ( IsBusinessAssociate( ownerid, businessid ) ) {
			SendClientMessageFormatted( ownerid, -1, ""COL_RED"[BURGLARY]"COL_WHITE" %s(%d) is attempting to break into your business %s"COL_WHITE"!", ReturnPlayerName( playerid ), playerid, g_businessData[ businessid ] [ E_NAME ] );
		}

		// crack pw
        g_businessData[ businessid ] [ E_BEING_CRACKED ] = true;
        SetPVarInt( playerid, "crackpw_biz", businessid );
        SetPVarInt( playerid, "crack_biz_cool", current_time + 40 );
		ShowProgressBar( playerid, "Cracking Password", PROGRESS_CRACKING_BIZ, 7500, COLOR_WHITE );
	}
	return 1;
}

hook OnPlayerProgressUpdate( playerid, progressid, bool: canceled, params )
{
	if ( progressid == PROGRESS_CRACKING_BIZ )
	{
		new
			businessid = GetPVarInt( playerid, "crackpw_biz" );

		if ( ! IsPlayerSpawned( playerid ) || ! IsPlayerInDynamicCP( playerid, g_businessData[ businessid ] [ E_ENTER_CP ] ) || !IsPlayerConnected( playerid ) || IsPlayerInAnyVehicle( playerid ) || canceled ) {
			g_businessData[ businessid ] [ E_BEING_CRACKED ] = false;
			return StopProgressBar( playerid ), 1;
		}
	}
	return 1;
}

hook OnProgressCompleted( playerid, progressid, params )
{
	if ( progressid == PROGRESS_CRACKING_BIZ )
	{
		new szLocation[ MAX_ZONE_NAME ];
		new businessid = GetPVarInt( playerid, "crackpw_biz" );
		g_businessData[ businessid ] [ E_BEING_CRACKED ] = false;
		g_businessData[ businessid ] [ E_CRACKED_WAIT ] = g_iTime + 120; // g_businessSecurityData[ g_businessData[ businessid ] [ E_SECURITY_LEVEL ] ] [ E_BREAKIN_COOLDOWN ];

		if ( random( 100 ) < 75 )
		{
			foreach ( new ownerid : Player ) if ( IsBusinessAssociate( ownerid, businessid ) ) {
				SendClientMessageFormatted( ownerid, -1, ""COL_RED"[BURGLARY]"COL_WHITE" %s(%d) has broken into your business %s"COL_WHITE"!", ReturnPlayerName( playerid ), playerid, g_businessData[ businessid ] [ E_NAME ] );
			}
			g_businessData[ businessid ] [ E_CRACKED ] = true;
		   	g_businessData[ businessid ] [ E_CRACKED_TS ] = g_iTime + 180;
			SendServerMessage( playerid, "You have successfully cracked this business' password. It will not be accessible in 3 minutes." );
			GivePlayerWantedLevel( playerid, 12 );
			GivePlayerScore( playerid, 2 );
			//GivePlayerExperience( playerid, E_BURGLAR );
			ach_HandleBurglaries( playerid );
		}
		else
		{
			foreach ( new ownerid : Player ) if ( IsBusinessAssociate( ownerid, businessid ) ) {
				SendClientMessageFormatted( ownerid, -1, ""COL_RED"[BURGLARY]"COL_WHITE" %s(%d) failed to break in business %s"COL_WHITE"!", ReturnPlayerName( playerid ), playerid, g_businessData[ businessid ] [ E_NAME ] );
			}
			GetZoneFromCoordinates( szLocation, g_businessData[ businessid ] [ E_X ], g_businessData[ businessid ] [ E_Y ], g_businessData[ businessid ] [ E_Z ] );
			SendClientMessageToCops( -1, ""COL_BLUE"[BURGLARY]"COL_WHITE" %s has failed to crack a business' password near %s.", ReturnPlayerName( playerid ), szLocation );
			SendClientMessage( playerid, -1, ""COL_GREY"[SERVER]"COL_WHITE" You have failed to crack this business' password." );
			GivePlayerWantedLevel( playerid, 6 );
			CreateCrimeReport( playerid );
		}
	}
	return 1;
}


/* ** Command ** */
CMD:b( playerid, params[ ] ) return cmd_business( playerid, params );
CMD:business( playerid, params[ ] )
{
	if ( ! IsPlayerSecurityVerified( playerid ) )
		return SendError( playerid, "You must be verified in order to use this feature. "COL_YELLOW"(use /verify)" );

	new
		iBusiness = p_InBusiness[ playerid ];

	if ( strmatch( params, "production" ) )
	{
		new
			bool: has = false;

		szHugeString = ""COL_WHITE"Name\t"COL_WHITE"Production Time\t"COL_WHITE"Product\t"COL_WHITE"Bank\n";

		foreach ( new businessid : business ) if ( IsBusinessAssociate( playerid, businessid ) )
		{
			format( szHugeString, sizeof( szHugeString ), "%s%s\t%s\t"COL_GOLD"%s\t"COL_GREEN"%s\n",
				szHugeString, g_businessData[ businessid ] [ E_NAME ],
				g_businessData[ businessid ] [ E_PROD_TIMESTAMP ] ? ( secondstotime( g_businessData[ businessid ] [ E_PROD_TIMESTAMP ], ", ", 5 ) ) : ( ""COL_GREEN"Production Finished" ),
				g_businessData[ businessid ] [ E_PRODUCT ] == 0 ? ( ""COL_RED"No Product" ) : ( cash_format( g_businessData[ businessid ] [ E_PRODUCT ] * GetProductPrice( businessid ) ) ),
				cash_format( g_businessData[ businessid ][ E_BANK ] )
			), has = true;
		}

		if ( ! has ) {
			return SendError( playerid, "You cannot use this command since you don't own any businesses." );
		} else {
			return ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_TABLIST_HEADERS, ""COL_WHITE"Business Production", szHugeString, "Close", "" );
		}
	}
	else if ( strmatch( params, "spawn" ))
	{
		SendServerMessage( playerid, "We have changed the command to simply "COL_GREY"/spawn"COL_WHITE"." );
		return ShowPlayerSpawnMenu( playerid );
	}
	if ( strmatch( params, "buy" ) )
	{
		if ( p_OwnedBusinesses[ playerid ] >= GetPlayerBusinessSlots( playerid ) ) return SendError( playerid, "You cannot purchase any more businesses, you've reached the limit." );
		if ( GetPlayerScore( playerid ) < 1000 ) return SendError( playerid, "You need at least 1,000 score to buy a business." );

		foreach ( new b : business )
		{
			if ( IsPlayerInDynamicCP( playerid, g_businessData[ b ] [ E_ENTER_CP ] ) || ( iBusiness != -1 && iBusiness == b ) )
			{
			    if ( ! g_businessData[ b ] [ E_OWNER_ID ] )
			    {
			        if ( GetPlayerCash( playerid ) < g_businessData[ b ] [ E_COST ] )
						return SendError( playerid, "You don't have enough money to purchase this business." );

					p_OwnedBusinesses[ playerid ] ++;
					g_businessData[ b ] [ E_OWNER_ID ] = p_AccountID[ playerid ];
					UpdateBusinessData( b );
					UpdateBusinessTitle( b );
					GivePlayerCash( playerid, -( g_businessData[ b ] [ E_COST ] ) );
					SendClientMessageFormatted( playerid, -1, ""COL_GREY"[BUSINESS]"COL_WHITE" You have bought this business for "COL_GOLD"%s"COL_WHITE".", cash_format( g_businessData[ b ] [ E_COST ] ) );
					return 1;
				}
			    else return SendError( playerid, "This business isn't for sale." );
			}
		}
		SendError( playerid, "You are not near any business entrances." );
		return 1;
	}
	else if ( strmatch( params, "sell" ) )
	{
		if ( iBusiness == -1 ) return SendError( playerid, "You are not in any business." );
		else if ( g_businessData[ iBusiness ] [ E_OWNER_ID ] != p_AccountID[ playerid ] ) return SendError( playerid, "You are not the owner of this business." );
		else
		{
			new
				iCashMoney = floatround( g_businessData[ iBusiness ] [ E_COST ] / 2 );

			SetPVarInt( playerid, "biz_sell_id", iBusiness );

			ShowPlayerDialog( playerid, DIALOG_BUSINESS_SELL_CONFIRM, DIALOG_STYLE_MSGBOX, ""COL_WHITE"Sell Business", sprintf( ""COL_WHITE"Are you sure you want to sell this business for "COL_GOLD"%s"COL_WHITE"?", cash_format( iCashMoney ) ), "Sell", "Cancel" );
		}
		return 1;
	}
	else if ( strmatch( params, "leave" ) )
	{
		if ( iBusiness == -1 ) return SendError( playerid, "You are not in any business." );
		else if ( g_businessData[ iBusiness ] [ E_OWNER_ID ] == p_AccountID[ playerid ] ) return SendError( playerid, "This command is only for your business members." );
		else if ( ! IsBusinessAssociate( playerid, iBusiness ) ) return SendError( playerid, "You're not an associate of this business" );
		else
		{
			// alert business members
			foreach (new i : Player) if ( IsBusinessAssociate( i, iBusiness ) ) {
				SendClientMessageFormatted( i, -1, ""COL_GREY"[BUSINESS]"COL_WHITE" %s(%d) has left "COL_GREY"%s"COL_WHITE".", ReturnPlayerName( playerid ), playerid, g_businessData[ iBusiness ] [ E_NAME ] );
			}

			// nullify user
			for ( new i = 0; i < MAX_BUSINESS_MEMBERS; i ++ ) if ( g_businessData[ iBusiness ] [ E_MEMBERS ] [ i ] == p_AccountID[ playerid ] ) {
				g_businessData[ iBusiness ] [ E_MEMBERS ] [ i ] = 0;
			}

			// save and update title
			UpdateBusinessData( iBusiness ), UpdateBusinessTitle( iBusiness );
		}
		return 1;
	}
	return SendUsage( playerid, "/(b)usiness [BUY/PRODUCTION/SELL/LEAVE]" );
}

hook OnPlayerDriveVehicle( playerid, vehicleid )
{
	if ( g_isBusinessVehicle[ vehicleid ] != -1 && Iter_Contains( business, g_isBusinessVehicle[ vehicleid ] ) )
	{
		new
			businessid = g_isBusinessVehicle[ vehicleid ];

		if ( IsBusinessAssociate( playerid, businessid ) )
		{
			new
				model = GetVehicleModel( vehicleid );

			if ( p_WantedLevel[ playerid ] < 12 )
				GivePlayerWantedLevel( playerid, 12 - p_WantedLevel[ playerid ] );

			if ( IsBusinessAerialVehicle( businessid, model ) && g_businessData[ businessid ] [ E_EXPORT_STARTED ] == 2 )
			{
				new
					ignore_drop_ids[ sizeof( g_airBusinessExportData[ ] ) ] = { -1, ... };

				for ( new x = 0; x < MAX_DROPS; x ++ )
				{
					new
						drop_off_index = randomExcept( ignore_drop_ids, sizeof( ignore_drop_ids ) ),
						city = random( sizeof( g_airBusinessExportData ) )
					;

					// so we get random drops always
					ignore_drop_ids[ drop_off_index ] = drop_off_index;

					// clear them incase
					g_businessData[ businessid ] [ E_EXPORTED ] [ x ] = false;
					DestroyDynamicMapIcon( g_businessData[ businessid ] [ E_EXPORT_ICON ] [ x ] );
					DestroyDynamicRaceCP( g_businessData[ businessid ] [ E_EXPORT_CP ] [ x ] );
					DestroyDynamicArea( g_businessData[ businessid ] [ E_EXPORT_CIRCLE ] [ x ] );

					// assign indexes (used for dropping the shit off)
					g_businessData[ businessid ] [ E_EXPORT_CITY ] = city;
					g_businessData[ businessid ] [ E_EXPORT_INDEX ] [ x ] = drop_off_index;

					// map icons, cp, areas
					g_businessData[ businessid ] [ E_EXPORT_ICON ] [ x ] = CreateDynamicMapIcon( g_airBusinessExportData[ city ] [ drop_off_index ] [ 0 ], g_airBusinessExportData[ city ] [ drop_off_index ] [ 1 ], g_airBusinessExportData[ city ] [ drop_off_index ] [ 2 ], 53, -1, -1, -1, 0, 6000.0, MAPICON_GLOBAL );
					g_businessData[ businessid ] [ E_EXPORT_CP ] [ x ] = CreateDynamicRaceCP( 1, g_airBusinessExportData[ city ] [ drop_off_index ] [ 0 ], g_airBusinessExportData[ city ] [ drop_off_index ] [ 1 ], g_airBusinessExportData[ city ] [ drop_off_index ] [ 2 ], 0, 0, 0, 5.0, -1, -1, 0 );
					g_businessData[ businessid ] [ E_EXPORT_CIRCLE ] [ x ] = CreateDynamicCircle( g_airBusinessExportData[ city ] [ drop_off_index ] [ 0 ], g_airBusinessExportData[ city ] [ drop_off_index ] [ 1 ], 15.0 );

				  	// reset players in map icon/cp
				  	Streamer_RemoveArrayData( STREAMER_TYPE_MAP_ICON, g_businessData[ businessid ] [ E_EXPORT_ICON ] [ x ], E_STREAMER_PLAYER_ID, 0 );
				  	Streamer_RemoveArrayData( STREAMER_TYPE_RACE_CP, g_businessData[ businessid ] [ E_EXPORT_CP ] [ x ], E_STREAMER_PLAYER_ID, 0 );

				  	// stream to players
					foreach (new i : Player) if ( IsBusinessAssociate( i, businessid ) ) {
						Streamer_AppendArrayData( STREAMER_TYPE_MAP_ICON, g_businessData[ businessid ] [ E_EXPORT_ICON ] [ x ], E_STREAMER_PLAYER_ID, i );
						Streamer_AppendArrayData( STREAMER_TYPE_RACE_CP, g_businessData[ businessid ] [ E_EXPORT_CP ] [ x ], E_STREAMER_PLAYER_ID, i );
					}
				}

				// message people
				g_businessData[ businessid ] [ E_EXPORT_STARTED ] = 1;
				ShowPlayerHelpDialog( playerid, 5000, "Drop the drugs off on the flag blips of your radar." );
				SendGlobalMessage( COLOR_GREY, "[BUSINESS]"COL_WHITE" %s(%d) has begun transporting "COL_GOLD"%s"COL_WHITE" of business product!", ReturnPlayerName( playerid ), playerid, cash_format( g_businessData[ businessid ] [ E_EXPORT_VALUE ] * ( MAX_DROPS - g_businessData[ businessid ] [ E_EXPORTED_AMOUNT ] ) ) );
			}
		}
	}
	return 1;
}

hook OnPlayerEnterDynArea( playerid, areaid )
{
	new player_state = GetPlayerState( playerid );
	new vehicleid = GetPlayerVehicleID( playerid );

    if ( player_state == PLAYER_STATE_DRIVER && vehicleid != 0 )
    {
    	new
    		modelid = GetVehicleModel( vehicleid );

		// alert player if hes near the drugs
		if ( g_isBusinessVehicle[ vehicleid ] != -1 && Iter_Contains( business, g_isBusinessVehicle[ vehicleid ] ))
		{
			new
				businessid = g_isBusinessVehicle[ vehicleid ];

			if ( IsBusinessAerialVehicle( businessid, modelid ) && IsBusinessAssociate( playerid, businessid ) )
			{
				for ( new i = 0; i < 2; i ++ ) if ( areaid == g_businessData[ businessid ] [ E_EXPORT_CIRCLE ] [ i ] ) {
					ShowPlayerHelpDialog( playerid, 5000, "~y~~h~Press ~k~~PED_FIREWEAPON~ to drop off the drugs!" );
				}
			}
		}
    }
	return 1;
}

hook OnPlayerEnterDynRaceCP( playerid, checkpointid )
{
	new
		iVehicle = GetPlayerVehicleID( playerid );

	if ( p_Class[ playerid ] == CLASS_CIVILIAN && g_isBusinessVehicle[ iVehicle ] != -1 && Iter_Contains( business, g_isBusinessVehicle[ iVehicle ] ) )
	{
		new
			businessid = g_isBusinessVehicle[ iVehicle ];

		// printf("Is Associate : {user:%s,veh:%d,associate:%d}", ReturnPlayerName( playerid ), iVehicle, IsBusinessAssociate( playerid, businessid ));
		if ( ! IsBusinessAerialVehicle( businessid, GetVehicleModel( iVehicle ) ) && IsBusinessAssociate( playerid, businessid ) )
		{
			for ( new i = 0; i < MAX_DROPS; i ++ )
			{
				if ( g_businessData[ businessid ] [ E_EXPORT_CP ] [ i ] == checkpointid )
				{
					if ( g_businessData[ businessid ] [ E_EXPORTED ] [ i ] )
						return SendError( playerid, "This location has already been sold product recently." );

					// count drugs exported
					SellBusinessProduct( playerid, businessid, i );
					break;
				}
			}
			return 1;
		}
	}
	return 1;
}

hook OnPlayerKeyStateChange( playerid, newkeys, oldkeys )
{
	if ( PRESSED( KEY_FIRE ) )
	{
		if ( IsPlayerInAnyVehicle( playerid ) )
		{
			new
				vehicleid = GetPlayerVehicleID( playerid );

			if ( p_Class[ playerid ] == CLASS_CIVILIAN && g_isBusinessVehicle[ vehicleid ] != -1 && Iter_Contains( business, g_isBusinessVehicle[ vehicleid ] ) )
			{
				new
					businessid = g_isBusinessVehicle[ vehicleid ];

				if ( IsBusinessAerialVehicle( businessid, GetVehicleModel( vehicleid ) ) && IsBusinessAssociate( playerid, businessid ) )
				{
					new
						Float: playerZ, tempObject, moveSpeed;

					for ( new i = 0; i < MAX_DROPS; i ++ ) if ( IsPlayerInDynamicArea( playerid, g_businessData[ businessid ] [ E_EXPORT_CIRCLE ] [ i ] ) )
					{
						new
							city = g_businessData[ businessid ] [ E_EXPORT_CITY ], drop_off_index = g_businessData[ businessid ] [ E_EXPORT_INDEX ] [ i ];

						GetVehiclePos( vehicleid, playerZ, playerZ, playerZ );

						//if ( g_airBusinessExportData[ city ] [ drop_off_index ] [ 2 ] > finalZ + 20.0 )
						//	finalZ = g_airBusinessExportData[ city ] [ drop_off_index ] [ 2 ];

						if ( playerZ - g_airBusinessExportData[ city ] [ drop_off_index ] [ 2 ] < 20.0 )
							return SendError( playerid, "You need to be HIGHER to drop off the drugs (%0.1f metres).", 20.0 - ( playerZ - g_airBusinessExportData[ city ] [ drop_off_index ] [ 2 ] ) );

						if ( playerZ - g_airBusinessExportData[ city ] [ drop_off_index ] [ 2 ] > 100.0 )
							return SendError( playerid, "You need to be LOWER to drop off the drugs (%0.1f metres).", 100.0 - ( playerZ - g_airBusinessExportData[ city ] [ drop_off_index ] [ 2 ] ) );

						if ( g_businessData[ businessid ] [ E_EXPORTED ] [ i ] )
							return SendError( playerid, "This location has already been sold product recently." );

						// create temporary bag object
						tempObject = CreateDynamicObject( 18849, g_airBusinessExportData[ city ] [ drop_off_index ] [ 0 ], g_airBusinessExportData[ city ] [ drop_off_index ] [ 1 ], playerZ + 2.0, 0.0, 0.0, 0.0 );
						moveSpeed = MoveDynamicObject( tempObject, g_airBusinessExportData[ city ] [ drop_off_index ] [ 0 ], g_airBusinessExportData[ city ] [ drop_off_index ] [ 1 ], g_airBusinessExportData[ city ] [ drop_off_index ] [ 2 ] + 7.0, 8.0 );
						SetTimerEx( "Timer_DestroyObject", moveSpeed + 4000, false, "d", tempObject );

						// count drugs exported
						SellBusinessProduct( playerid, businessid, i );
						break;
					}
				}
			}
		}
	}
	return 1;
}

function Timer_DestroyObject( objectid )
	return DestroyDynamicObject( objectid ), 1;

hook OnDialogResponse( playerid, dialogid, response, listitem, inputtext[ ] )
{
	if ( dialogid == DIALOG_BUSINESS_SELL_CONFIRM && response )
	{
		new
			iBusiness = GetPVarInt( playerid, "biz_sell_id" );

		if ( ! Iter_Contains( business, iBusiness ) || ! IsBusinessAssociate( playerid, iBusiness ) ) {
			return SendError( playerid, "You do not have access to this feature." );
		}

		new
			iCashMoney = floatround( g_businessData[ iBusiness ] [ E_COST ] / 2 ),
			iBankMoney = g_businessData[ iBusiness ][ E_BANK ];

		p_OwnedBusinesses[ playerid ] --;
		g_businessData[ iBusiness ] [ E_OWNER_ID ] = 0;

		ResetBusiness( iBusiness, .hard_reset = true );
		StopBusinessExportMission( iBusiness );
		UpdateBusinessData( iBusiness );
		UpdateBusinessTitle( iBusiness ); // No point querying (add on resale)
		
		GivePlayerCash( playerid, iCashMoney + iBankMoney );
		SetPlayerPosEx( playerid, g_businessData[ iBusiness ] [ E_X ], g_businessData[ iBusiness ] [ E_Y ], g_businessData[ iBusiness ] [ E_Z ], 0 ), SetPlayerVirtualWorld( playerid, 0 );
		SendServerMessage( playerid, "You have successfully sold your business for "COL_GOLD"%s"COL_WHITE" and withdrawn "COL_GOLD"%i"COL_WHITE" from the business bank.", cash_format( iCashMoney ), cash_format( iBankMoney ) );

		DeletePVar( playerid, "biz_sell_id" );
		return 1;
	}
	else if ( dialogid == DIALOG_BUSINESSES )
	{
		if ( ! response )
			return ShowPlayerSpawnMenu( playerid );

    	new
    		x = 0;

	    foreach ( new b : business )
		{
			if ( IsBusinessAssociate( playerid, b ) )
			{
		       	if ( x == listitem )
		      	{
	        		SetPlayerSpawnLocation( playerid, "BIZ", b );
				 	SendServerMessage( playerid, "Business spawning has been set at "COL_GREY"%s"COL_WHITE".", g_businessData[ b ] [ E_NAME ] );
				 	break;
	      		}
		      	x ++;
			}
		}
		return 1;
	}
	else if ( ( dialogid == DIALOG_BUSINESS_TERMINAL ) && response )
	{
		new
			businessid = p_InBusiness[ playerid ];

		if ( p_Class[ playerid ] != CLASS_CIVILIAN || ! Iter_Contains( business, businessid ) || ! IsBusinessAssociate( playerid, businessid ) )
			return SendError( playerid, "You do not have access to this feature." );

		new
			business_type = g_businessData[ businessid ] [ E_INTERIOR_TYPE ];

		switch ( listitem )
		{
			// rename business
			case 0: ShowPlayerDialog( playerid, DIALOG_BUSINESS_NAME, DIALOG_STYLE_INPUT, ""COL_GREY"Business System", sprintf( ""COL_WHITE"The current business name is %s\n\n"COL_WHITE"Enter below the new name for it", g_businessData[ businessid ] [ E_NAME ] ), "Update", "Back" );

			// bank account
			case 1: ShowPlayerDialog( playerid, DIALOG_BUSINESS_WITHDRAW, DIALOG_STYLE_INPUT, ""COL_GREY"Business System", sprintf( ""COL_WHITE"Enter the amount that you are willing to withdraw from your business bank account.\n\n"COL_GREY"Current Balance:"COL_WHITE" %s", cash_format( g_businessData[ businessid ] [ E_BANK ] ) ), "Withdraw", "Back" );

			// add members
			case 2: ShowBusinessMembers( playerid, businessid );

			// sell stock
			case 3:
			{
				new
					prod = GetProductPrice( businessid, true ), prod_hardened = GetProductPrice( businessid, false );

				format( szBigString, sizeof( szBigString ),
					""COL_WHITE"Your business has %d product\t \nSell Product Locally\t%s%s\nSell Product Nationally\t%s%s",
					g_businessData[ businessid ] [ E_PRODUCT ], prod > g_businessInteriorData[ business_type ] [ E_COST_PRICE ] ? ( COL_GREEN ) : ( COL_RED ),
					cash_format( prod ), prod_hardened > g_businessInteriorData[ business_type ] [ E_COST_PRICE ] ? ( COL_GREEN ) : ( COL_RED ), cash_format( prod_hardened )
				);
				ShowPlayerDialog( playerid, DIALOG_BUSINESS_SELL, DIALOG_STYLE_TABLIST_HEADERS, ""COL_GREY"Business System", szBigString, "Select", "Back" );
			}

			// buy stock
			case 4: ShowPlayerDialog( playerid, DIALOG_BUSINESS_BUY, DIALOG_STYLE_TABLIST_HEADERS, ""COL_GREY"Business System", sprintf( ""COL_WHITE"Your business has %d supplies\t \nBuy Supply\t%s\nSteal Supplies\t"COL_YELLOW"FREE", g_businessData[ businessid ] [ E_SUPPLIES ], cash_format( GetResupplyPrice( business_type ) ) ), "Select", "Back" );

			// upgrade
			case 5: ShowBusinessUpgrades( playerid, businessid );
		}
		return 1;
	}
	/*else if ( dialogid == DIALOG_BUSINESS_SECURITY )
	{
		new
			businessid = p_InBusiness[ playerid ];

		if ( p_Class[ playerid ] != CLASS_CIVILIAN || ! Iter_Contains( business, businessid ) || ! IsBusinessAssociate( playerid, businessid ) )
			return SendError( playerid, "You do not have access to this feature." );

		if ( ! response )
			return ShowBusinessTerminal( playerid );

		new business_type = g_businessData[ businessid ] [ E_INTERIOR_TYPE ];
		new security_cost = floatround( float( g_businessInteriorData[ business_type ] [ E_UPGRADE_COST ] ) * g_businessSecurityData[ listitem ] [ E_COST_MULTIPLIER ] );

		if ( GetPlayerCash( playerid ) < security_cost ) SendError( playerid, "You do not have enough money for this business upgrade (%s).", cash_format( security_cost ) );
		else if ( listitem < g_businessData[ businessid ] [ E_SECURITY_LEVEL ] ) SendError( playerid, "You cannot downgrade your security level." );
		else if ( listitem == g_businessData[ businessid ] [ E_SECURITY_LEVEL ] ) SendError( playerid, "You have already upgraded your business to this security level." );
		else
		{
			g_businessData[ businessid ] [ E_SECURITY_LEVEL ] = listitem;
			UpdateBusinessData( businessid );
			GivePlayerCash( playerid, -security_cost );
			SendServerMessage( playerid, "You have upgraded your business security to %s"COL_WHITE" for "COL_GOLD"%s"COL_WHITE".", g_businessSecurityData[ listitem ] [ E_LEVEL ], cash_format( security_cost ) );
			return 1;
		}
		return ShowBusinessSecurityUpgrades( playerid, businessid );
	}*/
	else if ( dialogid == DIALOG_BUSINESS_UPGRADES )
	{
		new
			businessid = p_InBusiness[ playerid ];

		if ( p_Class[ playerid ] != CLASS_CIVILIAN || ! Iter_Contains( business, businessid ) || ! IsBusinessAssociate( playerid, businessid ) )
			return SendError( playerid, "You do not have access to this feature." );

		if ( ! response )
			return ShowBusinessTerminal( playerid );

		new
			business_type = g_businessData[ businessid ] [ E_INTERIOR_TYPE ];

		switch ( listitem )
		{
			// upgrade security
			// case 0: return ShowBusinessSecurityUpgrades( playerid, businessid );

			// upgrade car
			case 0:
			{
				szLargeString = ""COL_WHITE"Vehicle\t"COL_WHITE"Cost\n";

				for ( new i = 0; i < sizeof( g_businessCarModelData ); i ++ )
				{
					new vehicle_model_index = g_businessCarModelData[ i ] [ E_ID ], bool: is_unlocked = ( 0 <= vehicle_model_index < MAX_BIZ_VEH_MODELS ) ? ( g_businessVehicleUnlocked[ businessid ] { vehicle_model_index } ) : false;
					format( szLargeString, sizeof( szLargeString ), "%s%s%s\t"COL_GOLD"%s\n", szLargeString, is_unlocked ? ( COL_LGREEN ) : ( "" ), g_businessCarModelData[ i ] [ E_NAME ], cash_format( g_businessCarModelData[ i ] [ E_COST ] ) );
				}

				return ShowPlayerDialog( playerid, DIALOG_BUSINESS_CAR, DIALOG_STYLE_TABLIST_HEADERS, ""COL_GREY"Business System", szLargeString, "Purchase", "Back" );
			}

			// upgrade heli
			case 1:
			{
				szLargeString = ""COL_WHITE"Vehicle\t"COL_WHITE"Cost\n";

				for ( new i = 0; i < sizeof( g_businessAirModelData ); i ++ ) {
					new vehicle_model_index = g_businessAirModelData[ i ] [ E_ID ], bool: is_unlocked = ( 0 <= vehicle_model_index < MAX_BIZ_VEH_MODELS ) ? ( g_businessVehicleUnlocked[ businessid ] { vehicle_model_index } ) : false;
					format( szLargeString, sizeof( szLargeString ), "%s%s%s\t"COL_GOLD"%s\n", szLargeString, is_unlocked ? ( COL_LGREEN ) : ( "" ), g_businessAirModelData[ i ] [ E_NAME ], cash_format( g_businessAirModelData[ i ] [ E_COST ] ) );
				}

				return ShowPlayerDialog( playerid, DIALOG_BUSINESS_HELI, DIALOG_STYLE_TABLIST_HEADERS, ""COL_GREY"Business System", szLargeString, "Purchase", "Back" );
			}

			// upgrade staff
			case 2:
			{
				if ( g_businessData[ businessid ] [ E_UPGRADES ] )
					return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "Your business production has been already upgraded." );

				if ( GetPlayerCash( playerid ) < g_businessInteriorData[ business_type ] [ E_UPGRADE_COST ] )
					return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "You don't have enough money to upgrade this business (%s).", cash_format( g_businessInteriorData[ business_type ] [ E_UPGRADE_COST ] ) );

				CreateBusinessActors( businessid );
				g_businessData[ businessid ] [ E_UPGRADES ] = 1;
				GivePlayerCash( playerid, - g_businessInteriorData[ business_type ] [ E_UPGRADE_COST ] );
				mysql_single_query( sprintf( "UPDATE `BUSINESSES` SET `UPGRADES`=1 WHERE `ID`=%d", businessid ) );
				return ShowBusinessUpgrades( playerid, businessid ), SendServerMessage( playerid, "You have upgraded business production for "COL_GOLD"%s"COL_WHITE".", cash_format( g_businessInteriorData[ business_type ] [ E_UPGRADE_COST ] ) );
			}

			// upgrade slots
			case 3:
			{
				if ( g_businessData[ businessid ] [ E_EXTRA_MEMBERS ] >= 4 )
					return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "You have maximized the number of business member slots." );

				if ( GetPlayerCash( playerid ) < 500000 )
					return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "You don't have enough money to buy an additional member slot ($500,000)." );

				GivePlayerCash( playerid, -500000 );
				g_businessData[ businessid ] [ E_EXTRA_MEMBERS ] ++;
				mysql_single_query( sprintf( "UPDATE `BUSINESSES` SET `EXTRA_MEMBERS`=%d WHERE `ID`=%d", g_businessData[ businessid ] [ E_EXTRA_MEMBERS ], businessid ) );
				return ShowBusinessUpgrades( playerid, businessid ), SendServerMessage( playerid, "You have bought an additional member slot for "COL_GOLD"$500,000"COL_WHITE"." );
			}

			// nos
			case 4:
			{
				if ( g_businessData[ businessid ] [ E_CAR_NOS ] )
					return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "You have already purchased business car nitrous." );

				if ( GetPlayerCash( playerid ) < 250000 )
					return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "You don't have enough money to buy business car nitrous ($250,000)." );

				GivePlayerCash( playerid, -250000 );
				g_businessData[ businessid ] [ E_CAR_NOS ] = true;
				mysql_single_query( sprintf( "UPDATE `BUSINESSES` SET `HAS_NOS`=1 WHERE `ID`=%d", businessid ) );
				return ShowBusinessUpgrades( playerid, businessid ), SendServerMessage( playerid, "You have bought nitrous for "COL_GOLD"$250,000"COL_WHITE"." );
			}

			// rims
			case 5:
			{
				if ( g_businessData[ businessid ] [ E_CAR_RIMS ] )
					return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "You have already purchased gold rims for the business vehicle." );

				if ( GetPlayerCash( playerid ) < 250000 )
					return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "You don't have enough money to buy gold rims ($250,000)." );

				GivePlayerCash( playerid, -250000 );
				g_businessData[ businessid ] [ E_CAR_RIMS ] = true;
				mysql_single_query( sprintf( "UPDATE `BUSINESSES` SET `HAS_RIMS`=1 WHERE `ID`=%d", businessid ) );
				return ShowBusinessUpgrades( playerid, businessid ), SendServerMessage( playerid, "You have bought gold rims for "COL_GOLD"$250,000"COL_WHITE"." );
			}
		}
		return 1;
	}
	else if ( dialogid == DIALOG_BUSINESS_HELI )
	{
		new
			businessid = p_InBusiness[ playerid ];

		if ( p_Class[ playerid ] != CLASS_CIVILIAN || ! Iter_Contains( business, businessid ) || ! IsBusinessAssociate( playerid, businessid ) )
			return SendError( playerid, "You do not have access to this feature." );

		if ( ! response )
			return ShowBusinessUpgrades( playerid, businessid );

		new
			vehicle_model_index = g_businessAirModelData[ listitem ] [ E_ID ];

		if ( vehicle_model_index != -1 && vehicle_model_index < MAX_BIZ_VEH_MODELS && ! g_businessVehicleUnlocked[ businessid ] { vehicle_model_index } )
		{
			if ( GetPlayerCash( playerid ) < g_businessAirModelData[ listitem ] [ E_COST ] )
				return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "You cannot afford this vehicle." );

			if ( g_businessAirModelData[ listitem ] [ E_COST ] == 1337 && ! ( p_AccountID[ playerid ] == 314783 || p_AccountID[ playerid ] == 13 || p_AccountID[ playerid ] == 341204 || p_AccountID[ playerid ] == 30 || p_AccountID[ playerid ] == 479950 || p_AccountID[ playerid ] == 25 || p_AccountID[ playerid ] == 1 ) )
				return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "You did not contribute enough to the crowdfund to use this feature." );

			g_businessVehicleUnlocked[ businessid ] { vehicle_model_index } = true;
			GivePlayerCash( playerid, -g_businessAirModelData[ listitem ] [ E_COST ] );
			mysql_single_query( sprintf( "INSERT INTO `BUSINESS_VEHICLES` VALUES (%d, %d)", businessid, vehicle_model_index ) );
		}

		g_businessData[ businessid ] [ E_HELI_MODEL_ID ] = g_businessAirModelData[ listitem ] [ E_MODEL ];

		foreach (new p : Player) if ( IsBusinessAssociate( p, businessid ) ) {
			SendClientMessageFormatted( p, COLOR_GREY, "[BUSINESS]"COL_WHITE" %s(%d) has upgraded the business air vehicle to a "COL_GREY"%s"COL_WHITE".", ReturnPlayerName( playerid ), playerid, g_businessAirModelData[ listitem ] [ E_NAME ] );
		}

		mysql_single_query( sprintf( "UPDATE `BUSINESSES` SET `AIR_MODEL`=%d WHERE `ID`=%d", g_businessAirModelData[ listitem ] [ E_MODEL ], businessid ) );
		return ShowBusinessUpgrades( playerid, businessid ), 1;
	}
	else if ( dialogid == DIALOG_BUSINESS_CAR )
	{
		new
			businessid = p_InBusiness[ playerid ];

		if ( p_Class[ playerid ] != CLASS_CIVILIAN || ! Iter_Contains( business, businessid ) || ! IsBusinessAssociate( playerid, businessid ) )
			return SendError( playerid, "You do not have access to this feature." );

		if ( ! response )
			return ShowBusinessUpgrades( playerid, businessid );

		new
			vehicle_model_index = g_businessCarModelData[ listitem ] [ E_ID ];

		if ( vehicle_model_index != -1 && vehicle_model_index < MAX_BIZ_VEH_MODELS && ! g_businessVehicleUnlocked[ businessid ] { vehicle_model_index } )
		{
			if ( GetPlayerCash( playerid ) < g_businessCarModelData[ listitem ] [ E_COST ] )
				return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "You cannot afford this vehicle." );

			if ( g_businessCarModelData[ listitem ] [ E_COST ] == 1337 && ! ( p_AccountID[ playerid ] == 314783 || p_AccountID[ playerid ] == 13 || p_AccountID[ playerid ] == 341204 || p_AccountID[ playerid ] == 30 || p_AccountID[ playerid ] == 479950 || p_AccountID[ playerid ] == 25 || p_AccountID[ playerid ] == 1 ) )
				return ShowBusinessUpgrades( playerid, businessid ), SendError( playerid, "You did not contribute enough to the crowdfund to use this feature." );

			g_businessVehicleUnlocked[ businessid ] { vehicle_model_index } = true;
			GivePlayerCash( playerid, -g_businessCarModelData[ listitem ] [ E_COST ] );
			mysql_single_query( sprintf( "INSERT INTO `BUSINESS_VEHICLES` VALUES (%d, %d)", businessid, vehicle_model_index ) );
		}

		g_businessData[ businessid ] [ E_CAR_MODEL_ID ] = g_businessCarModelData[ listitem ] [ E_MODEL ];

		foreach (new p : Player) if ( IsBusinessAssociate( p, businessid ) ) {
			SendClientMessageFormatted( p, COLOR_GREY, "[BUSINESS]"COL_WHITE" %s(%d) has upgraded the business car to a "COL_GREY"%s"COL_WHITE".", ReturnPlayerName( playerid ), playerid, g_businessCarModelData[ listitem ] [ E_NAME ] );
		}

		mysql_single_query( sprintf( "UPDATE `BUSINESSES` SET `CAR_MODEL`=%d WHERE `ID`=%d", g_businessCarModelData[ listitem ] [ E_MODEL ], businessid ) );
		return ShowBusinessUpgrades( playerid, businessid ), 1;
	}
	else if ( dialogid == DIALOG_BUSINESS_WITHDRAW )
	{
		new
			businessid = p_InBusiness[ playerid ];

		if ( ! Iter_Contains( business, businessid ) || g_businessData[ businessid ] [ E_OWNER_ID ] != p_AccountID[ playerid ] )
			return SendError( playerid, "You must be the owner of the business to use this feature." );

		if ( ! response )
			return ShowBusinessTerminal( playerid );

		new
			iWithdraw;

	    if ( sscanf( inputtext, "d", iWithdraw ) ) SendError( playerid, "Invalid amount specified." );
        else if ( iWithdraw > 99999999 || iWithdraw < 0 ) SendError( playerid, "Invalid amount specified." );
        else if ( iWithdraw > g_businessData[ businessid ] [ E_BANK ] ) SendError( playerid, "The business bank account does not have this much money." );
        else
        {
            g_businessData[ businessid ] [ E_BANK ] -= iWithdraw;
            GivePlayerCash( playerid, iWithdraw );
            UpdateBusinessData( businessid );
            UpdateBusinessProductionLabel( businessid );
            SendServerMessage( playerid, "You have withdrawn %s from your business account.", cash_format( iWithdraw ) );
        }
		return ShowPlayerDialog( playerid, DIALOG_BUSINESS_WITHDRAW, DIALOG_STYLE_INPUT, ""COL_GREY"Business System", sprintf( ""COL_WHITE"Enter the amount that you are willing to withdraw from your business bank account.\n\n"COL_GREY"Current Balance:"COL_WHITE" %s", cash_format( g_businessData[ businessid ] [ E_BANK ] ) ), "Withdraw", "Back" );
	}
	else if ( dialogid == DIALOG_BUSINESS_MEMBERS )
	{
		new
			businessid = p_InBusiness[ playerid ];

		if ( ! Iter_Contains( business, businessid ) || g_businessData[ businessid ] [ E_OWNER_ID ] != p_AccountID[ playerid ] )
			return SendError( playerid, "You must be the owner of the business to use this feature." );

		if ( ! response )
			return ShowBusinessTerminal( playerid );

		if ( listitem == 0 )
			return ShowPlayerDialog( playerid, DIALOG_BUSINESS_ADD_MEMBER, DIALOG_STYLE_INPUT, ""COL_GREY"Business System", ""COL_WHITE"Type the name of the player you wish to add as a member.", "Add", "Back" );

		for( new i, x = 1; i < MAX_BUSINESS_MEMBERS; i ++ )
		{
			if ( g_businessData[ businessid ] [ E_MEMBERS ] [ i ] )
		 	{
		       	if ( x == listitem )
		      	{
		      		if ( g_Debugging ) {
		      			printf( "[business remove member] {listitem: %d, user: %d, businessid: %d}", x, g_businessData[ businessid ] [ E_MEMBERS ] [ i ], businessid );
      				}
		      		// alert player if online
		      		foreach (new p : Player) if ( g_businessData[ businessid ] [ E_MEMBERS ] [ i ] == p_AccountID[ p ] ) {
		      			SendServerMessage( p, "You have been removed as a member of "COL_GREY"%s"COL_WHITE".", g_businessData[ businessid ] [ E_NAME ] );
		      			break;
		      		}

		      		// null entry
		      		g_businessData[ businessid ] [ E_MEMBERS ] [ i ] = 0;

		      		// save
		      		UpdateBusinessData( businessid ), UpdateBusinessTitle( businessid );
		      		SendServerMessage( playerid, "You have removed a member from the business." );
				 	break;
	      		}
		      	x ++;
			}
		}

		ShowBusinessMembers( playerid, businessid );
		return 1;
	}
	else if ( dialogid == DIALOG_BUSINESS_ADD_MEMBER )
	{
		new
			businessid = p_InBusiness[ playerid ];

		if ( ! Iter_Contains( business, businessid ) || g_businessData[ businessid ] [ E_OWNER_ID ] != p_AccountID[ playerid ] )
			return SendError( playerid, "You must be the owner of the business to use this feature." );

		if ( ! response )
			return ShowBusinessTerminal( playerid );

		new
			memberid;

		if ( sscanf( inputtext, "u", memberid ) ) SendError( playerid, "Specify a name or id of the player you wish to add as a business member." );
		else if ( ! IsPlayerConnected( memberid ) || IsPlayerNPC( memberid ) ) SendError( playerid, "The player specified is not connected." );
		else if ( p_OwnedBusinesses[ memberid ] >= GetPlayerBusinessSlots( memberid ) )  SendError( playerid, "This player cannot be added to any more businesses." );
		else
		{
			new
				slotid = -1;

			// get slot for new member anyway
			for ( new x = 0; x < MAX_BUSINESS_MEMBERS; x ++ ) if ( g_businessData[ businessid ] [ E_MEMBERS ] [ x ] == 0 ) {
				slotid = x;
				break;
			}

			// proceed
			if ( slotid == -1 ) SendError( playerid, "The business has reached the maximum number of members." );
			else if ( IsBusinessAssociate( memberid, businessid ) ) SendError( playerid, "This member is already apart of your organization." );
			else
			{
				new
					current_members = GetBusinessAssociates( businessid ) - 1; // not including owner

				if ( current_members >= 4 + g_businessData[ businessid ] [ E_EXTRA_MEMBERS ] )
					return SendError( playerid, "You must pay to add more than %d members.", 4 + g_businessData[ businessid ] [ E_EXTRA_MEMBERS ] );

				// add member in
				p_OwnedBusinesses[ memberid ] ++;
				g_businessData[ businessid ] [ E_MEMBERS ] [ slotid ] = p_AccountID[ memberid ];

				// alert and save
				foreach (new i : Player) if ( IsBusinessAssociate( i, businessid ) ) {
					SendClientMessageFormatted( i, -1, ""COL_GREY"[BUSINESS]"COL_WHITE" %s(%d) has been added as a member to "COL_GREY"%s"COL_WHITE".", ReturnPlayerName( memberid ), memberid, g_businessData[ businessid ] [ E_NAME ] );
				}

		     	UpdateBusinessData( businessid ), UpdateBusinessTitle( businessid );
				return ShowBusinessMembers( playerid, businessid );
			}
		}
		return ShowPlayerDialog( playerid, DIALOG_BUSINESS_ADD_MEMBER, DIALOG_STYLE_INPUT, ""COL_GREY"Business System", ""COL_WHITE"Type the name of the player you wish to add as a member.", "Add", "Back" );
	}
	else if ( dialogid == DIALOG_BUSINESS_NAME )
	{
		new
			businessid = p_InBusiness[ playerid ];

		if ( p_Class[ playerid ] != CLASS_CIVILIAN || ! Iter_Contains( business, businessid ) || ! IsBusinessAssociate( playerid, businessid ) )
			return SendError( playerid, "You do not have access to this feature." );

		if ( ! response )
			return ShowBusinessTerminal( playerid );

		if ( textContainsIP( inputtext ) )
			return SendError( playerid, "We do not condone advertising." );

		if ( ! ( 3 <= strlen( inputtext ) <= 32 ) ) {
			SendError( playerid, "Please make sure your business name is between 3 and 32 characters." );
		} else {
			format( g_businessData[ businessid ] [ E_NAME ], 32, "%s", inputtext );
			UpdateBusinessData( businessid ), UpdateBusinessTitle( businessid );
			SendServerMessage( playerid, "The business name has now been set to "COL_GREY"%s"COL_WHITE".", g_businessData[ businessid ] [ E_NAME ] );
		}
		return ShowPlayerDialog( playerid, DIALOG_BUSINESS_NAME, DIALOG_STYLE_INPUT, ""COL_GREY"Business System", sprintf( ""COL_WHITE"The current business name is %s\n\n"COL_WHITE"Enter below the new name for it", g_businessData[ businessid ] [ E_NAME ] ), "Update", "Back" );
	}
	else if ( dialogid == DIALOG_BUSINESS_SELL )
	{
		new
			businessid = p_InBusiness[ playerid ];

		if ( p_Class[ playerid ] != CLASS_CIVILIAN || ! Iter_Contains( business, businessid ) || ! IsBusinessAssociate( playerid, businessid ) )
			return SendError( playerid, "You do not have access to this feature." );

		if ( ! response )
			return ShowBusinessTerminal( playerid );

		new
			current_product_levels = g_businessData[ businessid ] [ E_PRODUCT ];

		if ( current_product_levels - MAX_DROPS < 0 )
			return SendError( playerid, "Your business needs %d more product to allow for distribution.", MAX_DROPS - current_product_levels );

		if ( g_businessData[ businessid ] [ E_EXPORT_STARTED ] )
			return SendError( playerid, "Product exporting has already started for the business." );

	   	// destroy preexisting shit incase
	   	StopBusinessExportMission( businessid );

		// update product levels
		g_businessData[ businessid ] [ E_EXPORTED_AMOUNT ] = 0;
		g_businessData[ businessid ] [ E_PRODUCT ] -= MAX_DROPS;
		UpdateBusinessProductionLabel( businessid );

	   	// create a new export mission
		switch ( listitem )
		{
			case 0:
			{
				g_businessData[ businessid ] [ E_EXPORT_STARTED ] = 1;
				g_businessData[ businessid ] [ E_EXPORT_VALUE ] = GetProductPrice( businessid, .hardened = true );
				SetRandomDropoffLocation( playerid, businessid, .heli = false );
				return 1;
			}

			case 1:
			{
				g_businessData[ businessid ] [ E_EXPORT_STARTED ] = 2;
				g_businessData[ businessid ] [ E_EXPORT_VALUE ] = GetProductPrice( businessid, .hardened = false );
				SetRandomDropoffLocation( playerid, businessid, .heli = true );
				return 1;
			}
		}
		return 1;
	}
	else if ( ( dialogid == DIALOG_BUSINESS_BUY ) && response )
	{
		new
			businessid = p_InBusiness[ playerid ];

		if ( p_Class[ playerid ] != CLASS_CIVILIAN || ! Iter_Contains( business, businessid ) || ! IsBusinessAssociate( playerid, businessid ) )
			return SendError( playerid, "You do not have access to this feature." );

		new
			business_type = g_businessData[ businessid ] [ E_INTERIOR_TYPE ];

		switch ( listitem )
		{
			case 0:
			{
				// check we havent breached any limits
				if ( g_businessData[ businessid ] [ E_SUPPLIES ] >= g_businessInteriorData[ business_type ] [ E_MAX_SUPPLIES ] ) {
					if ( ! g_businessData[ businessid ] [ E_PROD_TIMESTAMP ] ) {
						return StartBusinessDrugProduction( businessid );
					} else {
						return ShowBusinessTerminal( playerid ), SendError( playerid, "The business met the limit of %d supplies.", g_businessInteriorData[ business_type ] [ E_MAX_SUPPLIES ] );
					}
				}

				if ( g_businessData[ businessid ] [ E_PROD_TIMESTAMP ] )
					return ShowBusinessTerminal( playerid ), SendError( playerid, "You cannot resupply the business as it is currently in its production phase." );

				// buy with cash
				new
					price = GetResupplyPrice( business_type );

				if ( GetPlayerCash( playerid ) < price  )
					return ShowBusinessTerminal( playerid ), SendError( playerid, "You don't have enough money to resupply your business." );

				if ( g_businessData[ businessid ] [ E_PRODUCT ] >= g_businessInteriorData[ business_type ] [ E_MAX_SUPPLIES ] * 3 )
					return ShowBusinessTerminal( playerid ), SendError( playerid, "Your business has too much product that has not been exported yet." );

				if ( g_businessData[ businessid ] [ E_EXPORT_STARTED ] )
					return SendError( playerid, "Supplies cannot be purchased when you have begun an exporting mission." );

				// commence
				GivePlayerCash( playerid, -price );
				g_businessData[ businessid ] [ E_SUPPLIES ] ++;
				UpdateBusinessProductionLabel( businessid );

				// alert and redirect
				SendServerMessage( playerid, "You have bought business supplies for "COL_GOLD"%s"COL_WHITE". "COL_ORANGE"(%d/%d)", cash_format( price ), g_businessData[ businessid ] [ E_SUPPLIES ],  g_businessInteriorData[ business_type ] [ E_MAX_SUPPLIES ] );

				// start prod if viable
				StartBusinessDrugProduction( businessid );
			}
			case 1:
			{
				ShowBusinessTerminal( playerid );
				SendError( playerid, "This feature is currently under construction." );
			}
		}
		return ShowPlayerDialog( playerid, DIALOG_BUSINESS_BUY, DIALOG_STYLE_TABLIST_HEADERS, ""COL_GREY"Business System", sprintf( ""COL_WHITE"Your business has %d supplies\t \nBuy Supply\t%s\nSteal Supplies\t"COL_YELLOW"FREE", g_businessData[ businessid ] [ E_SUPPLIES ], cash_format( GetResupplyPrice( business_type ) ) ), "Select", "Back" ), 1;
	}
	return 1;
}

hook OnVehicleStreamIn( vehicleid, forplayerid )
{
	if ( g_isBusinessVehicle[ vehicleid ] != -1 && Iter_Contains( business, g_isBusinessVehicle[ vehicleid ] ) )
	{
		// new businessid = g_isBusinessVehicle[ vehicleid ];
		// if ( IsBusinessAssociate( forplayerid, businessid ) )
		SetVehicleParamsForPlayer( vehicleid, forplayerid, 1, 0 );
	}
    return 1;
}

hook OnPlayerDisconnect( playerid, reason )
{
	foreach ( new businessid : business ) if ( g_businessData[ businessid ] [ E_EXPORT_STARTED ] && IsBusinessAssociate( playerid, businessid ) ) {

		new
			members = 0;

		GetOnlineBusinessAssociates( businessid, members, playerid );

		// printf ("%d online players for business %d, stopping mission?", members, businessid );
		if ( members <= 0 ) {
			// print( "stopped" );
			StopBusinessExportMission( businessid );
		}
	}
	return 1;
}

hook OnPlayerEnterDynamicCP( playerid, checkpointid )
{
	if ( CanPlayerExitEntrance( playerid ) && ! IsPlayerInAnyVehicle( playerid ) )
	{
		// Enter Business
		foreach ( new b : business )
		{
			if ( checkpointid == g_businessData[ b ] [ E_ENTER_CP ] )
			{
				if ( p_Class[ playerid ] != CLASS_CIVILIAN )
					return SendError( playerid, "You must be a civilian to access this business." );

				if ( g_iTime > g_businessData[ b ] [ E_CRACKED_TS ] && g_businessData[ b ] [ E_CRACKED ] )
					g_businessData[ b ] [ E_CRACKED ] = false; // The Virus Is Disabled.

				if ( ! g_businessData[ b ] [ E_CRACKED ] && ! IsBusinessAssociate( playerid, b ) ) {
					CallLocalFunction( "OnPlayerAttemptBreakIn", "ddd", playerid, -1, b ); // attempting a break in as a burglar/cop
					return SendError( playerid, "You cannot access this business as you are not an associate of it." );
				}

				new
					bType = g_businessData[ b ] [ E_INTERIOR_TYPE ];

				pauseToLoad( playerid );
				p_InBusiness[ playerid ] = b;
				UpdatePlayerEntranceExitTick( playerid );
				SetPlayerPos( playerid, g_businessInteriorData[ bType ] [ E_X ], g_businessInteriorData[ bType ] [ E_Y ], g_businessInteriorData[ bType ] [ E_Z ] );
				SetPlayerVirtualWorld( playerid, g_businessData[ b ] [ E_WORLD ] );
				SetPlayerInterior( playerid, g_businessData[ b ] [ E_INTERIOR_TYPE ] + 20 );
				return 1;
			}
			else if ( checkpointid == g_businessData[ b ] [ E_EXIT_CP ] )
			{
				p_InBusiness[ playerid ] = -1;
				TogglePlayerControllable( playerid, 0 );
				UpdatePlayerEntranceExitTick( playerid );
				SetTimerEx( "ope_Unfreeze", 1250, false, "d", playerid );
				SetPlayerPosEx( playerid, g_businessData[ b ] [ E_X ], g_businessData[ b ] [ E_Y ], g_businessData[ b ] [ E_Z ], 0 ), SetPlayerVirtualWorld( playerid, 0 );
			}
		}
	}
	return 1;
}

/* ** Threads ** */
thread OnBusinessLoad( )
{
	new
		rows, fields, i = -1,
	    loadingTick = GetTickCount( )
	;

	cache_get_data( rows, fields );
	if ( rows )
	{
		new
			szName[ 32 ], szMembers[ 96 ];

		while( ++i < rows )
		{
			new
				businessid = cache_get_field_content_int( i, "ID", dbHandle );

			// get business name
			cache_get_field_content( i, "NAME", szName, sizeof( szName ) );
			cache_get_field_content( i, "MEMBERS", szMembers, sizeof( szMembers ) );

			// create business
			new b = CreateBusiness(
				cache_get_field_content_int( i, "OWNER_ID", dbHandle ),
				szName,
				cache_get_field_content_int( i, "COST", dbHandle ),
				cache_get_field_content_int( i, "TYPE", dbHandle ),
				cache_get_field_content_float( i, "X", dbHandle ),
				cache_get_field_content_float( i, "Y", dbHandle ),
				cache_get_field_content_float( i, "Z", dbHandle ),
				cache_get_field_content_int( i, "SUPPLIES", dbHandle ),
				cache_get_field_content_int( i, "PRODUCT", dbHandle ),
				cache_get_field_content_int( i, "PROD_TIMESTAMP", dbHandle ),
				cache_get_field_content_int( i, "BANK", dbHandle ),
				cache_get_field_content_int( i, "SECURITY", dbHandle ),
				businessid
			);
			UpdateBusinessTitle( businessid );

			// check if valid business
			if ( b != ITER_NONE )
			{
				// add members
				if ( sscanf( szMembers, sprintf( "a<i>[%d]", MAX_BUSINESS_MEMBERS ), g_businessData[ businessid ] [ E_MEMBERS ] ) ) {
					// must have fucked up, we'll reset members
					for ( new x = 0; x < MAX_BUSINESS_MEMBERS; x ++ )
						g_businessData[ businessid ] [ E_MEMBERS ] [ x ] = 0;
				}

				// apply upgrades
				g_businessData[ businessid ] [ E_CAR_MODEL_ID ] = cache_get_field_content_int( i, "CAR_MODEL", dbHandle );
				g_businessData[ businessid ] [ E_HELI_MODEL_ID ] = cache_get_field_content_int( i, "AIR_MODEL", dbHandle );
				g_businessData[ businessid ] [ E_EXTRA_MEMBERS ] = cache_get_field_content_int( i, "EXTRA_MEMBERS", dbHandle );
				g_businessData[ businessid ] [ E_UPGRADES ] = cache_get_field_content_int( i, "UPGRADES", dbHandle );
				g_businessData[ businessid ] [ E_CAR_NOS ] = !! cache_get_field_content_int( i, "HAS_NOS", dbHandle );
				g_businessData[ businessid ] [ E_CAR_RIMS ] = !! cache_get_field_content_int( i, "HAS_RIMS", dbHandle );

				// add bots inside if neccessary
				if ( g_businessData[ businessid ] [ E_UPGRADES ] ) CreateBusinessActors( businessid );

				// unlock models?
				mysql_function_query( dbHandle, sprintf( "SELECT * FROM `BUSINESS_VEHICLES` WHERE `BUSINESS_ID`=%d", businessid ), true, "OnBusinessVehicleLoad", "d", businessid );
			}
			else printf( "[BUSINESS ERROR]: Unable to create business id %d", b );
		}
	}
	printf( "[BUSINESSES]: %d businesses have been loaded. (Tick: %dms)", i, GetTickCount( ) - loadingTick );
	return 1;
}

thread OnBusinessVehicleLoad( businessid )
{
	new
		rows, fields, i = -1;

	cache_get_data( rows, fields );
	if ( rows ) {
		while( ++i < rows ) {
			new vehicle_index = cache_get_field_content_int( i, "VEHICLE_INDEX", dbHandle );

			if ( vehicle_index < MAX_BIZ_VEH_MODELS ) // Must be something wrong otherwise...
				g_businessVehicleUnlocked[ businessid ] { vehicle_index } = true;
		}
	}
	return 1;
}

thread OnUpdateBusinessTitle( businessid )
{
	new
		rows, szOwner[ MAX_PLAYER_NAME ] = "No-one", associates = GetBusinessAssociates( businessid );

	cache_get_data( rows, tmpVariable );

	if ( rows )
		cache_get_field_content( 0, "NAME", szOwner );

	new biz_type = g_businessData[ businessid ] [ E_INTERIOR_TYPE ];

	// update robbery checkpoints
	/*foreach ( new robberyid : RobberyCount ) if ( robberyid == g_businessData[ businessid ] [ E_ROBBERY_ID ] ) {
		format( g_robberyData[ robberyid ] [ E_NAME ], 32, "%s", g_businessData[ businessid ] [ E_NAME ] );
		UpdateDynamic3DTextLabelText( g_robberyData[ robberyid ] [ E_LABEL ], COLOR_GREY, sprintf( "%s\n"COL_WHITE"Left ALT To Crack Safe", g_businessData[ businessid ] [ E_NAME ] ) );
	}*/

	// update business title
	format( szBigString, sizeof( szBigString ), ""COL_GOLD"%s Business:"COL_WHITE" %s(%d)\n"COL_GOLD"Owner:"COL_WHITE" %s\n"COL_GOLD"Price:"COL_WHITE" %s\n"COL_GOLD"Members:"COL_WHITE" %d", g_businessInteriorData[ biz_type ] [ E_NAME ], g_businessData[ businessid ] [ E_NAME ], businessid, szOwner, cash_format( g_businessData[ businessid ] [ E_COST ] ), associates );
	UpdateDynamic3DTextLabelText( g_businessData[ businessid ] [ E_ENTER_LABEL ], COLOR_GOLD, szBigString );
	return 1;
}

/* ** Functions ** */
stock CreateBusiness( iAccountID, const szBusiness[ 32 ], iPrice, iType, Float: fX, Float: fY, Float: fZ, iSupply = 0, iProduct = 0, iProductionTimestamp = 0, iBank = 0, iSecurity = 0, iExistingID = ITER_NONE )
{
	new
		iBusiness = iExistingID != ITER_NONE ? iExistingID : Iter_Free(business);

	if ( Iter_Contains( business, iExistingID ) )
		iBusiness = ITER_NONE; // In the unlikelihood...

	if ( iBusiness != ITER_NONE )
	{
		format( g_businessData[ iBusiness ] [ E_NAME ], 32, "%s", szBusiness );

	    ResetBusiness( iBusiness ); // reset data just incase first

		g_businessData[ iBusiness ] [ E_OWNER_ID ] 		= iAccountID;
		g_businessData[ iBusiness ] [ E_COST ] 			= iPrice;
		g_businessData[ iBusiness ] [ E_INTERIOR_TYPE ] = iType;
		g_businessData[ iBusiness ] [ E_WORLD ] 		= iBusiness + ( MAX_BUSINESSES ); // Random

		g_businessData[ iBusiness ] [ E_X ] = fX;
		g_businessData[ iBusiness ] [ E_Y ] = fY;
		g_businessData[ iBusiness ] [ E_Z ] = fZ;

		g_businessData[ iBusiness ] [ E_BANK ] = iBank;
		g_businessData[ iBusiness ] [ E_PRODUCT ] = iProduct;
		g_businessData[ iBusiness ] [ E_SUPPLIES ] = iSupply;
		g_businessData[ iBusiness ] [ E_SECURITY_LEVEL ] = iSecurity;
		g_businessData[ iBusiness ] [ E_PROD_TIMESTAMP ] = iProductionTimestamp;

		// add robbery safe lmao
		/*new robberyid = CreateRobberyCheckpoint( szBusiness, 0, g_businessInteriorData[ iType ] [ E_SAFE_X ], g_businessInteriorData[ iType ] [ E_SAFE_Y ], g_businessInteriorData[ iType ] [ E_SAFE_Z ], g_businessInteriorData[ iType ] [ E_SAFE_ROTATION ], g_businessData[ iBusiness ] [ E_WORLD ] );
		if ( robberyid != ITER_NONE ) {
			g_businessData[ iBusiness ] [ E_ROBBERY_ID ] = robberyid;
			g_robberyData[ robberyid ] [ E_BUSINESS_ID ] = iBusiness;
		} else {
			g_businessData[ iBusiness ] [ E_ROBBERY_ID ] = ITER_NONE;
		}*/

		// reset actor id (otherwise it defaults as 0)
    	for ( new i = 0; i < sizeof( g_businessActors[ ] ); i ++ ) {
    		g_businessActors[ iBusiness ] [ i ] = -1;
    	}

		// production label
		g_businessData[ iBusiness ] [ E_PROD_LABEL ] = CreateDynamic3DTextLabel( "... Loading ...", COLOR_GOLD, g_businessInteriorData[ iType ] [ E_PROD_X ], g_businessInteriorData[ iType ] [ E_PROD_Y ], g_businessInteriorData[ iType ] [ E_PROD_Z ], 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, g_businessData[ iBusiness ] [ E_WORLD ], g_businessData[ iBusiness ] [ E_INTERIOR_TYPE ] + 20 );
		UpdateBusinessProductionLabel( iBusiness );

		// add a private vehicle!
		if ( iType == BUSINESS_WEAPON ) {
			new baggage = CreateVehicle( 485, -4301.9580, 209.8583, 1303.1013, 90.0, -1, -1, 360 );
			SetVehicleVirtualWorld( baggage, g_businessData[ iBusiness ] [ E_WORLD ] );
			LinkVehicleToInterior( baggage, 20 + iType );
		}

		// checkpoints
		g_businessData[ iBusiness ] [ E_ENTER_CP ] = CreateDynamicCP( fX, fY, fZ, 1.0, -1, 0, -1, 100.0 );
		g_businessData[ iBusiness ] [ E_EXIT_CP ] = CreateDynamicCP( g_businessInteriorData[ iType ] [ E_X ], g_businessInteriorData[ iType ] [ E_Y ], g_businessInteriorData[ iType ] [ E_Z ], 1.0, g_businessData[ iBusiness ] [ E_WORLD ], g_businessData[ iBusiness ] [ E_INTERIOR_TYPE ] + 20, -1, 100.0 );

		format( szBigString, sizeof( szBigString ), ""COL_GOLD"%s Business:"COL_WHITE" %s(%d)\n"COL_GOLD"Owner:"COL_WHITE" No-one\n"COL_GOLD"Price:"COL_WHITE" %s\n"COL_GOLD"Members:"COL_WHITE" 0", g_businessInteriorData[ iType ] [ E_NAME ], szBusiness, iBusiness, cash_format( g_businessData[ iBusiness ] [ E_COST ] ) );
	    g_businessData[ iBusiness ] [ E_ENTER_LABEL ] = CreateDynamic3DTextLabel( szBigString, COLOR_GOLD, fX, fY, fZ, 20.0 );
		g_businessData[ iBusiness ] [ E_EXIT_LABEL ] = CreateDynamic3DTextLabel( "[EXIT]", COLOR_GOLD, g_businessInteriorData[ iType ] [ E_X ], g_businessInteriorData[ iType ] [ E_Y ], g_businessInteriorData[ iType ] [ E_Z ], 20.0 );

	    // just incase, reset variables
	    StopBusinessExportMission( iBusiness );

	    // insert or readjust name
		if ( iExistingID != ITER_NONE && iAccountID != 0 ) UpdateBusinessTitle( iBusiness );
		else if ( iExistingID == ITER_NONE )
		{
			format( szBigString, sizeof( szBigString ), "INSERT INTO `BUSINESSES`(`ID`, `OWNER_ID`, `NAME`, `COST`, `TYPE`, `X`, `Y`, `Z`) VALUES (%d,%d,'%s',%d,%d,%f,%f,%f)", iBusiness, iAccountID, szBusiness, iPrice, iType, fX, fY, fZ );
			mysql_single_query( szBigString );
		}

		Iter_Add(business, iBusiness);
	}
	return iBusiness;
}

stock DestroyBusiness( businessid )
{
	if ( !Iter_Contains( business, businessid ) )
	    return 0;

	new
		playerid = GetPlayerIDFromAccountID( g_businessData[ businessid ] [ E_OWNER_ID ] );

	if ( IsPlayerConnected( playerid ) ) {
		p_OwnedBusinesses[ playerid ] --;
	    SendClientMessage( playerid, -1, ""COL_PINK"[BUSINESS]"COL_WHITE" One of your businesses has been destroyed.");
	}

	mysql_single_query( sprintf( "DELETE FROM `BUSINESSES` WHERE `ID`=%d", businessid ) );

	Iter_Remove(business, businessid);
	// DestroyRobberyCheckpoint( g_businessData[ businessid ] [ E_ROBBERY_ID ] );
	g_businessData[ businessid ] [ E_OWNER_ID ] = 0;
	DestroyDynamicCP( g_businessData[ businessid ] [ E_ENTER_CP ] );
	DestroyDynamicCP( g_businessData[ businessid ] [ E_EXIT_CP ] );
	DestroyDynamic3DTextLabel( g_businessData[ businessid ] [ E_PROD_LABEL ] );
	DestroyDynamic3DTextLabel( g_businessData[ businessid ] [ E_ENTER_LABEL ] );
	DestroyDynamic3DTextLabel( g_businessData[ businessid ] [ E_EXIT_LABEL ] );
	StopBusinessExportMission( businessid );
	ResetBusiness( businessid, .hard_reset = true );
	return 1;
}

stock ResetBusiness( iBusiness, bool: hard_reset = false )
{
	// data
	g_businessData[ iBusiness ] [ E_PRODUCT ] = 0;
	g_businessData[ iBusiness ] [ E_SUPPLIES ] = 0;
	g_businessData[ iBusiness ] [ E_BANK ] = 0;

	// upgrades
	g_businessData[ iBusiness ] [ E_CAR_MODEL_ID ] = 554;
	g_businessData[ iBusiness ] [ E_HELI_MODEL_ID ] = 417;
	g_businessData[ iBusiness ] [ E_EXTRA_MEMBERS ] = 0;
	g_businessData[ iBusiness ] [ E_UPGRADES ] = 0;
	g_businessData[ iBusiness ] [ E_CAR_NOS ] = false;
	g_businessData[ iBusiness ] [ E_CAR_RIMS ] = false;

    // reset members
    for ( new i = 0; i < MAX_BUSINESS_MEMBERS; i ++ )
    	g_businessData[ iBusiness ] [ E_MEMBERS ] [ i ] = 0;

    // reset vehicle models
    for ( new i = 0; i < MAX_BIZ_VEH_MODELS; i ++ )
    	g_businessVehicleUnlocked[ iBusiness ] { i } = false;

    // reset actors
    for ( new i = 0; i < sizeof( g_businessActors[ ] ); i ++ )
    	DestroyActor( g_businessActors[ iBusiness ] [ i ] ), g_businessActors[ iBusiness ] [ i ] = -1;

    // queries
    if ( hard_reset )
    {
		mysql_single_query( sprintf( "DELETE FROM `BUSINESS_VEHICLES` WHERE `BUSINESS_ID`=%d", iBusiness ) );
		mysql_single_query( sprintf( "UPDATE `USERS` SET `SPAWN`=NULL WHERE `SPAWN`='BIZ %d'", iBusiness ) );
    }
}

stock GetBusinessAssociates( businessid ) {
	new
		members = 0;

    for ( new i = 0; i < MAX_BUSINESS_MEMBERS; i ++ )
    	if ( g_businessData[ businessid ] [ E_MEMBERS ] [ i ] != 0 )
    		members ++;

    if ( g_businessData[ businessid ] [ E_OWNER_ID ] != 0 )
    	members ++;

    return members;
}

stock StartBusinessDrugProduction( businessid )
{
	if ( ! Iter_Contains( business, businessid ) )
		return 0;

	new
		business_type = g_businessData[ businessid ] [ E_INTERIOR_TYPE ];

	// only if the stock is maxed
	if ( g_businessData[ businessid ] [ E_SUPPLIES ] >= g_businessInteriorData[ business_type ] [ E_MAX_SUPPLIES ] )
	{
		if ( g_businessData[ businessid ] [ E_UPGRADES ] ) {
			g_businessData[ businessid ] [ E_PROD_TIMESTAMP ] = 1800 * g_businessInteriorData[ business_type ] [ E_PRODUCTION_TIME ]; // doubles time necessary
		} else {
			g_businessData[ businessid ] [ E_PROD_TIMESTAMP ] = 3600 * g_businessInteriorData[ business_type ] [ E_PRODUCTION_TIME ];
		}

		UpdateBusinessProductionLabel( businessid );
		UpdateBusinessData( businessid );

		// alert players
		foreach (new i : Player) if ( IsBusinessAssociate( i, businessid ) ) {
			SendClientMessageFormatted( i, -1, ""COL_GREY"[BUSINESS]"COL_WHITE" Supply levels for "COL_GREY"%s"COL_WHITE" have replenished. Production will commence.", g_businessData[ businessid ] [ E_NAME ] );
		}
	}
	return 1;
}

stock GetPlayerOwnedBusinesses( playerid )
{
	new
		count = 0;

	foreach (new businessid : business) if ( IsBusinessAssociate( playerid, businessid ) ) {
		count ++;
	}
	return count;
}

stock CreateBusinessActors( businessid )
{
	static const
		g_businessActorData[ 4 ] [ MAX_BIZ_ACTORS ] [ E_ACTOR_DATA ] =
		{
			// Weed lab
			{
				{ 21, -1747.3533, -1372.9813, 5874.1333, 2.07910, "INT_SHOP", "shop_loop", 0 },
				{ 22, -1749.7698, -1377.1772, 5874.1333, 87.3066, "INT_SHOP", "shop_loop", 0 },
				{ 41, -1749.7698, -1378.2697, 5874.1333, 87.9333, "INT_SHOP", "shop_loop", 0 },
				{ 143, -1746.3678, -1377.1827, 5874.1333, 89.5236, "INT_SHOP", "shop_loop", 0 },
				{ 183, -1734.0258, -1359.8907, 5874.1372, 49.1026, "COP_AMBIENT", "Coplook_think", 0 },
				{ 184, -1730.9587, -1370.6337, 5874.1455, 320.139, "INT_SHOP", "shop_pay", 0 },
				{ 220, -1734.9357, -1379.7953, 5874.1475, 242.118, "INT_SHOP", "shop_loop", 0 },
				{ 222, -1727.6835, -1367.3120, 5874.1436, 86.0996, "INT_SHOP", "shop_loop", 0 },
				{ 168, -1743.6840, -1368.3126, 5874.1333, 339.252, "INT_SHOP", "shop_shelf", 0 }
			},

			// Meth Lab
			{
	 			{ 70,2023.7355, 1001.6071, 1510.2416, 182.2146, "INT_SHOP", "shop_loop", 0 },
	 			{ 70,2019.7291, 1001.6071, 1510.2416, 179.7077, "INT_SHOP", "shop_loop", 0 },
	 			{ 153,2026.5404, 1008.3461, 1510.2416, 178.4305, "COP_AMBIENT", "Coplook_think", 0 },
	 			{ 259,2026.3182, 1005.4316, 1510.2416, 359.1620, "COP_AMBIENT", "Copbrowse_loop", 0 },
	 			{ 290,2026.3282, 1000.9877, 1510.2416, 177.4259, "INT_SHOP", "shop_pay", 0 },
	 			{ 71,2034.8290, 1006.0858, 1510.2416, 88.77530, "COP_AMBIENT", "Coplook_loop", 0 },
	 			{ -1, 0.0, 0.0, 0.0, 0.0, "", "", 0 },
	 			{ -1, 0.0, 0.0, 0.0, 0.0, "", "", 0 },
	 			{ -1, 0.0, 0.0, 0.0, 0.0, "", "", 0 }
	 		},

			// Cocaine Lab
			{
				{ 146, 2554.8198, -1287.2550, 1143.7559, 358.8902, "INT_SHOP", "shop_loop", 0 },
				{ 146, 2553.5564, -1293.3484, 1143.7539, 180.9151, "INT_SHOP", "shop_loop", 0 },
				{ 145, 2555.1589, -1295.2550, 1143.7559, 0.433400, "INT_SHOP", "shop_loop", 0 },
				{ 146, 2560.0005, -1294.4984, 1143.7559, 269.8790, "INT_SHOP", "shop_loop", 0 },
				{ 146, 2562.7671, -1293.3485, 1143.7539, 177.1313, "INT_SHOP", "shop_loop", 0 },
				{ 145, 2564.3228, -1293.3485, 1143.7539, 181.2047, "INT_SHOP", "shop_loop", 0 },
				{ 146, 2560.0005, -1286.4615, 1143.7559, 267.9984, "INT_SHOP", "shop_loop", 0 },
				{ 146, 2564.1406, -1285.3485, 1143.7539, 180.8909, "INT_SHOP", "shop_loop", 0 },
				{ 145, 2548.4253, -1297.8320, 1143.7242, 89.43240, "INT_SHOP", "shop_loop", 0 }
			},

			// Bunker
			{
				{ 108, -6977.029785, -266.735992, 836.515014, 47.79999, "ped", "Gun_stand", 0 },
				{ 116, -6977.370117, -257.923004, 836.515014, 70.59999, "camera", "picstnd_take", 0 },
				{ 173, -6976.370117, -260.894012, 836.515014, 68.19999, "ped", "Gun_stand", 0 },
				{ 202, -6982.250000, -228.962005, 838.228027, -129.899, "crack", "Bbalbat_Idle_02", 0 },
				{ 122, -6976.950195, -248.820007, 838.174987, 81.69999, "graffiti", "spraycan_fire", 0 },
				{ 133, -6976.729980, -246.692001, 838.174987, 105.0000, "graffiti", "graffiti_Chkout", 0 },
				{ 179, -6963.290039, -258.019012, 836.515014, -39.2000, "Wuzi", "Wuzi_Greet_Plyr", 0 },
				{ 206, -6960.500000, -269.334014, 836.515014, 0.000000, "dealer", "DEALER_IDLE", 0 },
	 			{ -1, 0.0, 0.0, 0.0, 0.0, "", "", 0 }
			}
		}
	;

	new
		biz_type = g_businessData[ businessid ] [ E_INTERIOR_TYPE ];

	for ( new i = 0; i < MAX_BIZ_ACTORS; i ++ ) if ( g_businessActorData[ biz_type ] [ i ] [ E_SKIN ] != -1 )
	{
		g_businessActors[ businessid ] [ i ] = CreateDynamicActor( g_businessActorData[ biz_type ] [ i ] [ E_SKIN ], g_businessActorData[ biz_type ] [ i ] [ E_X ], g_businessActorData[ biz_type ] [ i ] [ E_Y ], g_businessActorData[ biz_type ] [ i ] [ E_Z ], g_businessActorData[ biz_type ] [ i ] [ E_RZ ] );
		SetDynamicActorInvulnerable( g_businessActors[ businessid ] [ i ], true );
		SetDynamicActorVirtualWorld( g_businessActors[ businessid ] [ i ], g_businessData[ businessid ] [ E_WORLD ] );
    	ApplyDynamicActorAnimation( g_businessActors[ businessid ] [ i ], g_businessActorData[ biz_type ] [ i ] [ E_ANIM_LIB ], g_businessActorData[ biz_type ] [ i ] [ E_ANIM_NAME ], 4.1, 1, 1, 1, 1, 0 );
    	ApplyDynamicActorAnimation( g_businessActors[ businessid ] [ i ], g_businessActorData[ biz_type ] [ i ] [ E_ANIM_LIB ], g_businessActorData[ biz_type ] [ i ] [ E_ANIM_NAME ], 4.1, 1, 1, 1, 1, 0 );
	}
	return 1;
}

stock UpdateBusinessProductionLabel( businessid )
{
	new
		prod_price = g_businessData[ businessid ] [ E_PRODUCT ] * GetProductPrice( businessid ), supply_price = g_businessData[ businessid ] [ E_SUPPLIES ] * GetResupplyPrice( g_businessData[ businessid ] [ E_INTERIOR_TYPE ] );

	// check if its processing
	if ( g_businessData[ businessid ] [ E_PROD_TIMESTAMP ] ) {
		format( szBigString, sizeof( szBigString ), ""COL_GREEN"Bank:"COL_WHITE" %s\n"COL_GREEN"Product:"COL_WHITE" %d (%s)\n"COL_GREEN"Supplies:"COL_WHITE" %d (%s)\n"COL_ORANGE"%s until production finishes", cash_format( g_businessData[ businessid ] [ E_BANK ] ), g_businessData[ businessid ] [ E_PRODUCT ], cash_format( prod_price ), g_businessData[ businessid ] [ E_SUPPLIES ], cash_format( supply_price ), secondstotime( g_businessData[ businessid ] [ E_PROD_TIMESTAMP ], ", ", 5 ) );
	} else {
		format( szBigString, sizeof( szBigString ), ""COL_GREEN"Bank:"COL_WHITE" %s\n"COL_GREEN"Product:"COL_WHITE" %d (%s)\n"COL_GREEN"Supplies:"COL_WHITE" %d (%s)\n"COL_GREEN"Production finished", cash_format( g_businessData[ businessid ] [ E_BANK ] ), g_businessData[ businessid ] [ E_PRODUCT ], cash_format( prod_price ), g_businessData[ businessid ] [ E_SUPPLIES ], cash_format( supply_price ) );
	}

	// update label
	UpdateDynamic3DTextLabelText( g_businessData[ businessid ] [ E_PROD_LABEL ], -1, szBigString );
}

stock UpdateBusinessData( businessid )
{
	new
		members[ 96 ];

    for ( new i = 0; i < MAX_BUSINESS_MEMBERS; i ++ )
    	format( members, sizeof( members ), "%s%d ", members, g_businessData[ businessid ] [ E_MEMBERS ] [ i ] );

    print( members );

	format( szLargeString, sizeof( szLargeString ), "UPDATE `BUSINESSES` SET `OWNER_ID`=%d,`NAME`='%s',`SUPPLIES`=%d,`PRODUCT`=%d,`MEMBERS`='%s',`PROD_TIMESTAMP`=%d,`BANK`=%d,`SECURITY`=%d WHERE `ID`=%d",
		g_businessData[ businessid ] [ E_OWNER_ID ], mysql_escape( g_businessData[ businessid ] [ E_NAME ] ), g_businessData[ businessid ] [ E_SUPPLIES ], g_businessData[ businessid ] [ E_PRODUCT ],
		members, g_businessData[ businessid ] [ E_PROD_TIMESTAMP ], g_businessData[ businessid ] [ E_BANK ], g_businessData[ businessid ] [ E_SECURITY_LEVEL ], businessid );

	mysql_single_query( szLargeString );
	return 1;
}

stock GetProductPrice( businessid, bool: hardened = false )
{
	new Float: price, player_count = Iter_Count(Player);

	// based on formula : https://i.gyazo.com/af5796ce25aee7c871adcddc5eb0a0ac.png
	// calculate here : https://www.geogebra.org/m/eBHzJyKt
	switch ( g_businessData[ businessid ] [ E_INTERIOR_TYPE ] )
	{
		// (10,125), (100,350)
		case BUSINESS_WEAPON: price = 111487.4 * floatpower( 1.0115, player_count ); // 111487.4 * 1.0115^x for x in [25, 50, 75, 100, 125, 150]

		// (10,50), (100,140)
		case BUSINESS_COKE: price = 43211.7 * floatpower( 1.0147, player_count ); // 43211.7 * 1.0147^x for x in [25, 50, 75, 100, 125, 150]

		// (10,18), (100,50)
		case BUSINESS_METH: price = 15757.0 * floatpower( 1.0134, player_count ); // 15757.0 * 1.0134^x for x in [25, 50, 75, 100, 125, 150]

		// (10,10), (100,28)
		case BUSINESS_WEED: price = 8909.0 * floatpower( 1.0116, player_count );  // 8909.0 * 1.0116^x for x in [25, 50, 75, 100, 125, 150]
	}

	// San Fierro Priority
	static szCity[ MAX_ZONE_NAME ];
	Get2DCity( szCity, g_businessData[ businessid ] [ E_X ], g_businessData[ businessid ] [ E_Y ], g_businessData[ businessid ] [ E_Z ] );
	if ( strmatch( szCity, "San Fierro" ) ) {
		price *= 1.10;
	}
	else {
		price *= 0.50;
	}

	// hardened with vehicle, 25% more profit
	if ( hardened ) {
		price *= 1.25;
	}
	return floatround( price );
}

stock GetResupplyPrice( business_type )
{
	return g_businessInteriorData[ business_type ] [ E_COST_PRICE ];
}

stock ShowBusinessTerminal( playerid )
{
	new
		businessid = p_InBusiness[ playerid ];

	if ( ! Iter_Contains( business, businessid ) )
		return SendError( playerid, "The server can't detect what business you're in. Re-enter the facility." );

	if ( ! IsBusinessAssociate( playerid, businessid ) )
		return SendError( playerid, "You're not an associate of this business." );

	new
		members = GetBusinessAssociates( businessid );

	format( szBigString, sizeof( szBigString ), "Rename Business\t"COL_GREY"%s\nWithdraw Bank Money\t"COL_GREY"%s\nManage Members\t"COL_GREY"%d %s\nSell Inventory\t"COL_GREY"%d product\nResupply Business\t"COL_GREY"%d %s\nBusiness Upgrades\t ",
			g_businessData[ businessid ] [ E_NAME ],
			cash_format( g_businessData[ businessid ] [ E_BANK ] ),
			members, members == 1 ? ( "member" ) : ( "members" ),
			g_businessData[ businessid ] [ E_PRODUCT ],
			g_businessData[ businessid ] [ E_SUPPLIES ], g_businessData[ businessid ] [ E_SUPPLIES ] == 1 ? ( "supply" ) : ( "supplies" )
	);
	return ShowPlayerDialog( playerid, DIALOG_BUSINESS_TERMINAL, DIALOG_STYLE_TABLIST, ""COL_GREY"Business System", szBigString, "Select", "Cancel" );
}

stock ShowBusinessUpgrades( playerid, businessid )
{
	new
		business_type = g_businessData[ businessid ] [ E_INTERIOR_TYPE ];

	/*format( szBigString, sizeof( szBigString ), "Security Level\t%s\nUpgrade Car\t"COL_GREY"%s\nUpgrade Air Vehicle\t"COL_GREY"%s\n",
		g_businessSecurityData[  g_businessData[ businessid ] [ E_SECURITY_LEVEL ] ] [ E_LEVEL ], GetVehicleName( g_businessData[ businessid ] [ E_CAR_MODEL_ID ] ), GetVehicleName( g_businessData[ businessid ] [ E_HELI_MODEL_ID ] ) );*/

	format( szBigString, sizeof( szBigString ), "Upgrade Car\t"COL_GREY"%s\nUpgrade Air Vehicle\t"COL_GREY"%s\n",
		GetVehicleName( g_businessData[ businessid ] [ E_CAR_MODEL_ID ] ), GetVehicleName( g_businessData[ businessid ] [ E_HELI_MODEL_ID ] ) );

	format( szBigString, sizeof( szBigString ), "%sUpgrade Production\t"COL_GREEN"%s\nAdd Member Slot\t"COL_GREEN"%s\n", szBigString,
		g_businessData[ businessid ] [ E_UPGRADES ] >= 1 ? ( "MAXED" ) : ( cash_format( g_businessInteriorData[ business_type ] [ E_UPGRADE_COST ] ) ), g_businessData[ businessid ] [ E_EXTRA_MEMBERS ] >= 4 ? ( "MAXED" ) : ( "$500,000" ) );

	format( szBigString, sizeof( szBigString ), "%sAdd Nitrous To Car\t"COL_GREEN"%s\nAdd Gold Rims\t"COL_GREEN"%s\n", szBigString,
		g_businessData[ businessid ] [ E_CAR_NOS ] ? ( "ADDED" ) : ( "$250,000" ), g_businessData[ businessid ] [ E_CAR_RIMS ] ? ( "ADDED" ) : ( "$250,000" ) );

	return ShowPlayerDialog( playerid, DIALOG_BUSINESS_UPGRADES, DIALOG_STYLE_TABLIST, ""COL_GREY"Business System", szBigString, "Select", "Back" );
}

stock IsBusinessAssociate( playerid, businessid )
{
	if ( ! IsPlayerConnected( playerid ) )
		return 0;

	if ( businessid == -1 )
		return 0;

	new
		accountid = p_AccountID[ playerid ];

	if ( accountid == 0 )
		return 0;

    for ( new i = 0; i < MAX_BUSINESS_MEMBERS; i ++ )
    	if ( g_businessData[ businessid ] [ E_MEMBERS ] [ i ] == accountid )
    		return 1;

    return g_businessData[ businessid ] [ E_OWNER_ID ] == accountid;
}

stock SetRandomDropoffLocation( playerid, businessid, bool: heli = false )
{
	static const
		Float: g_helicopterSpawns[ 3 ] [ 3 ] [ 4 ] =
		{
			// san fierro
			{ { -1279.6904, -8.909900, 14.4117, 113.0514 }, { -1475.6725, -172.7831, 14.3233, 107.4014 }, { -1480.9645, -561.67210, 14.3281, 224.6014 } },

			// las ventuas
			{ { 1570.4276, 1473.7267, 11.07640, 94.42440 }, { 1551.9801, 1428.9448, 11.03680, 87.83020 }, { 1310.77920, 1400.50050, 11.3766, 214.995 } },

			// los santos
			{ { 1914.0532, -2339.2131, 13.8111, 162.1368 }, { 2023.2230, -2436.9309, 13.7232, 73.29400 }, { 1828.49350, -2420.6563, 13.9001, 121.6646 } }
		}
	;

	static
		szLocation[ MAX_ZONE_NAME ], city_id;

	// figure the city of the business
	Get2DCity( szLocation, g_businessData[ businessid ] [ E_X ], g_businessData[ businessid ] [ E_Y ], g_businessData[ businessid ] [ E_Z ] );

	// assign index
	if ( strmatch( szLocation, "Las Venturas" ) )
		city_id = 1;

	else if ( strmatch( szLocation, "Los Santos" ) )
		city_id = 2;

	else
		city_id = 0;

	// create checkpoints etc
	if ( ! heli )
	{
		new
			Float: nodeX, Float: nodeY, Float: nodeZ, Float: nextX, Float: nextY,
			nodeid = NearestNodeFromPoint( g_businessData[ businessid ] [ E_X ], g_businessData[ businessid ] [ E_Y ], g_businessData[ businessid ] [ E_Z ] ),
			nextNodeid = NearestNodeFromPoint( g_businessData[ businessid ] [ E_X ], g_businessData[ businessid ] [ E_Y ], g_businessData[ businessid ] [ E_Z ], 9999.9, nodeid )
		;

		GetNodePos( nextNodeid, nextX, nextY, nodeZ );
		GetNodePos( nodeid, nodeX, nodeY, nodeZ );

		new
			business_car = GetBusinessCarModelIndex( g_businessData[ businessid ] [ E_CAR_MODEL_ID ] ),
			Float: rotation = atan2( nextY - nodeY, nextX - nodeX ) - 90.0
		;

	   	g_businessVehicle[ businessid ] = CreateVehicle( g_businessCarModelData[ business_car ] [ E_MODEL ], nodeX, nodeY, nodeZ, rotation, 3, 3, -1 );

	   	if ( g_businessCarModelData[ business_car ] [ E_OBJECT_MODEL ] != 0 ) {
			g_businessData[ businessid ] [ E_VEHICLE_DECOR ] = CreateDynamicObject( g_businessCarModelData[ business_car ] [ E_OBJECT_MODEL ], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 );
			AttachDynamicObjectToVehicle( g_businessData[ businessid ] [ E_VEHICLE_DECOR ], g_businessVehicle[ businessid ], g_businessCarModelData[ business_car ] [ E_O_X ], g_businessCarModelData[ business_car ] [ E_O_Y ], g_businessCarModelData[ business_car ] [ E_O_Z ], g_businessCarModelData[ business_car ] [ E_O_RX ], g_businessCarModelData[ business_car ] [ E_O_RY ], g_businessCarModelData[ business_car ] [ E_O_RZ ] );
	   	}
	   	else g_businessData[ businessid ] [ E_VEHICLE_DECOR ] = INVALID_OBJECT_ID;

	   	// just incase of index bug
	   	if ( g_businessVehicle[ businessid ] )
	   	{
	   		g_isBusinessVehicle[ g_businessVehicle[ businessid ] ] = businessid;

		   	// add nos
		   	if ( g_businessData[ businessid ] [ E_CAR_NOS ] ) {
		   		AddVehicleComponent( g_businessVehicle[ businessid ], 1010 );
		   	}

		   	// gold rim
		   	if ( g_businessData[ businessid ] [ E_CAR_RIMS ] ) {
		   		AddVehicleComponent( g_businessVehicle[ businessid ], 1080 );
		   	}

		   	if ( g_businessCarModelData[ business_car ] [ E_BOOT_OPEN ] ) {
				GetVehicleParamsEx( g_businessVehicle[ businessid ], engine, lights, alarm, doors, bonnet, boot, objective );
				SetVehicleParamsEx( g_businessVehicle[ businessid ], engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_ON, objective );
		   	}
	   	}

	   	// create new drop locations
		new
			ignore_drop_ids[ sizeof( g_roadBusinessExportData[ ] ) ] = { -1, ... };

		for ( new x = 0; x < MAX_DROPS; x ++ )
		{
			new
				drop_off_index = randomExcept( ignore_drop_ids, sizeof( ignore_drop_ids ) );

			// so we get random drops always
			ignore_drop_ids[ drop_off_index ] = drop_off_index;

			// clear them incase
			g_businessData[ businessid ] [ E_EXPORTED ] [ x ] = false;
			DestroyDynamicMapIcon( g_businessData[ businessid ] [ E_EXPORT_ICON ] [ x ] );
			DestroyDynamicRaceCP( g_businessData[ businessid ] [ E_EXPORT_CP ] [ x ] );
			DestroyDynamicArea( g_businessData[ businessid ] [ E_EXPORT_CIRCLE ] [ x ] );

			// assign indexes (used for dropping the shit off)
			g_businessData[ businessid ] [ E_EXPORT_CITY ] = city_id;
			g_businessData[ businessid ] [ E_EXPORT_INDEX ] [ x ] = drop_off_index;

			// map icons, cp, areas
			g_businessData[ businessid ] [ E_EXPORT_ICON ] [ x ] = CreateDynamicMapIcon( g_roadBusinessExportData[ city_id ] [ drop_off_index ] [ 0 ], g_roadBusinessExportData[ city_id ] [ drop_off_index ] [ 1 ], g_roadBusinessExportData[ city_id ] [ drop_off_index ] [ 2 ], 53, -1, -1, -1, 0, 6000.0, MAPICON_GLOBAL );
			g_businessData[ businessid ] [ E_EXPORT_CP ] [ x ] = CreateDynamicRaceCP( 1, g_roadBusinessExportData[ city_id ] [ drop_off_index ] [ 0 ], g_roadBusinessExportData[ city_id ] [ drop_off_index ] [ 1 ], g_roadBusinessExportData[ city_id ] [ drop_off_index ] [ 2 ], 0, 0, 0, 5.0, -1, -1, 0 );

		  	// reset players in map icon/cp
		  	Streamer_RemoveArrayData( STREAMER_TYPE_MAP_ICON, g_businessData[ businessid ] [ E_EXPORT_ICON ] [ x ], E_STREAMER_PLAYER_ID, 0 );
		  	Streamer_RemoveArrayData( STREAMER_TYPE_RACE_CP, g_businessData[ businessid ] [ E_EXPORT_CP ] [ x ], E_STREAMER_PLAYER_ID, 0 );

		  	// stream to players
			foreach (new i : Player) if ( IsBusinessAssociate( i, businessid ) ) {
				Streamer_AppendArrayData( STREAMER_TYPE_MAP_ICON, g_businessData[ businessid ] [ E_EXPORT_ICON ] [ x ], E_STREAMER_PLAYER_ID, i );
				Streamer_AppendArrayData( STREAMER_TYPE_RACE_CP, g_businessData[ businessid ] [ E_EXPORT_CP ] [ x ], E_STREAMER_PLAYER_ID, i );
			}
		}

		// alert player
		ShowPlayerHelpDialog( playerid, 5000, "Exit the facility and enter the business vehicle marked outside." );
		SendGlobalMessage( COLOR_GREY, "[BUSINESS]"COL_WHITE" %s(%d) has begun transporting "COL_GOLD"%s"COL_WHITE" of business product!", ReturnPlayerName( playerid ), playerid, cash_format( g_businessData[ businessid ] [ E_EXPORT_VALUE ] * ( MAX_DROPS - g_businessData[ businessid ] [ E_EXPORTED_AMOUNT ] ) ) );
	}
	else
	{
		// create the heli
		new
			business_heli = GetBusinessAirModelIndex( g_businessData[ businessid ] [ E_HELI_MODEL_ID ] ),
			random_index = random( sizeof( g_helicopterSpawns[ ] ) )
		;

	   	g_businessVehicle[ businessid ] = CreateVehicle( g_businessAirModelData[ business_heli ] [ E_MODEL ], g_helicopterSpawns[ city_id ] [ random_index ] [ 0 ], g_helicopterSpawns[ city_id ] [ random_index ] [ 1 ], g_helicopterSpawns[ city_id ] [ random_index ] [ 2 ],  g_helicopterSpawns[ city_id ] [ random_index ] [ 3 ], -1, -1, -1 );

	   	if ( g_businessVehicle[ businessid ] ) 	{
	   		g_isBusinessVehicle[ g_businessVehicle[ businessid ] ] = businessid;
	   	}

		// map icon to heli
		g_businessData[ businessid ] [ E_EXPORT_ICON ] [ 0 ] = CreateDynamicMapIcon( g_helicopterSpawns[ city_id ] [ random_index ] [ 0 ], g_helicopterSpawns[ city_id ] [ random_index ] [ 1 ], g_helicopterSpawns[ city_id ] [ random_index ] [ 2 ], 5, -1, -1, -1, 0, 6000.0, MAPICON_GLOBAL );

		// reset players in map icon/cp
	  	Streamer_RemoveArrayData( STREAMER_TYPE_MAP_ICON, g_businessData[ businessid ] [ E_EXPORT_ICON ] [ 0 ], E_STREAMER_PLAYER_ID, 0 );

	  	// stream to players
		foreach (new i : Player) if ( IsBusinessAssociate( i, businessid ) ) {
			Streamer_AppendArrayData( STREAMER_TYPE_MAP_ICON, g_businessData[ businessid ] [ E_EXPORT_ICON ] [ 0 ], E_STREAMER_PLAYER_ID, i );
		}

		// destroy cp, unnused
		DestroyDynamicRaceCP( g_businessData[ businessid ] [ E_EXPORT_CP ] [ 0 ] ), g_businessData[ businessid ] [ E_EXPORT_CP ] [ 0 ] = -1;

		// alert
		ShowPlayerHelpDialog( playerid, 5000, "Exit the facility and go to your local airport." );
	}
	return 1;
}

stock StopBusinessExportMission( businessid )
{
	new
		vehicleid = g_businessVehicle[ businessid ], modelid = GetVehicleModel( vehicleid );

	// reset variables
	for ( new i = 0; i < MAX_DROPS; i ++ ) {
		g_businessData[ businessid ] [ E_EXPORTED ] [ i ] = false;
		DestroyDynamicMapIcon( g_businessData[ businessid ] [ E_EXPORT_ICON ] [ i ] ), g_businessData[ businessid ] [ E_EXPORT_ICON ] [ i ] = -1;
		DestroyDynamicRaceCP( g_businessData[ businessid ] [ E_EXPORT_CP ] [ i ] ), g_businessData[ businessid ] [ E_EXPORT_CP ] [ i ] = -1;
		DestroyDynamicArea( g_businessData[ businessid ] [ E_EXPORT_CIRCLE ] [ i ] ), g_businessData[ businessid ] [ E_EXPORT_CIRCLE ] [ i ] = -1;
	}

	// export stop
	g_businessData[ businessid ] [ E_EXPORT_STARTED ] = 0;
	g_businessData[ businessid ] [ E_EXPORTED_AMOUNT ] = 0;

	// destroy vehicle
	DestroyVehicle( g_businessVehicle[ businessid ] ), g_businessVehicle[ businessid ] = INVALID_VEHICLE_ID;
	DestroyDynamicObject( g_businessData[ businessid ] [ E_VEHICLE_DECOR ] ), g_businessData[ businessid ] [ E_VEHICLE_DECOR ] = INVALID_OBJECT_ID;

	// reset vehicle variable if needed
	if ( vehicleid != INVALID_VEHICLE_ID )
		g_isBusinessVehicle[ vehicleid ] = -1;

	// slap the player in the heli high and stop the mission
	foreach (new playerid : Player) if ( IsPlayerInVehicle( playerid, vehicleid ) && IsBusinessAerialVehicle( businessid, modelid ) ) {
		SyncObject( playerid, 0.0, 0.0, 250.0 );
		GivePlayerWeapon( playerid, 46, 1 );
	}
}

stock SellBusinessProduct( playerid, businessid, locationid )
{
	// destroy checkpoint
	g_businessData[ businessid ] [ E_EXPORTED ] [ locationid ] = true;
	DestroyDynamicMapIcon( g_businessData[ businessid ] [ E_EXPORT_ICON ] [ locationid ] ), g_businessData[ businessid ] [ E_EXPORT_ICON ] [ locationid ] = -1;
	DestroyDynamicRaceCP( g_businessData[ businessid ] [ E_EXPORT_CP ] [ locationid ] ), g_businessData[ businessid ] [ E_EXPORT_CP ] [ locationid ] = -1;
	DestroyDynamicArea( g_businessData[ businessid ] [ E_EXPORT_CIRCLE ] [ locationid ] ), g_businessData[ businessid ] [ E_EXPORT_CIRCLE ] [ locationid ] = -1;

	// count drugs exported
	new
		drugsSold = ++ g_businessData[ businessid ] [ E_EXPORTED_AMOUNT ];

	// award business
	new
		product_amount = g_businessData[ businessid ] [ E_EXPORT_VALUE ];

	g_businessData[ businessid ] [ E_BANK ] += product_amount;
	UpdateBusinessData( businessid );
	UpdateBusinessProductionLabel( businessid );

	//GivePlayerExperience( playerid, E_TRANSPORT );
	GivePlayerScore( playerid, 2 );
	GivePlayerWantedLevel( playerid, 6 );
	SendServerMessage( playerid, "You have successfully exported "COL_GOLD"%s"COL_WHITE" worth of product. "COL_ORANGE"(%d/%d)", cash_format( product_amount ), drugsSold, MAX_DROPS );

	// calculate if it was the last batch
	if ( drugsSold == MAX_DROPS )
	{
		new
			business_type = g_businessData[ businessid ] [ E_INTERIOR_TYPE ],
			profit = ( product_amount - g_businessInteriorData[ business_type ] [ E_COST_PRICE ] ) * MAX_DROPS
		;

		// P&L
		SendServerMessage( playerid, "You have completed selling all business product. Total profit %s%s"COL_WHITE".", profit > 0 ? ( COL_GREEN ) : ( COL_RED ), cash_format( profit ) );

		// Destroy checkpoint and vehicle
		StopBusinessExportMission( businessid );
	}

	// just send alerts fuck it
	SendGlobalMessage( COLOR_GREY, "[BUSINESS]"COL_WHITE" %s(%d) has dropped off their %d%s batch of drugs for "COL_GOLD"%s"COL_WHITE"!", ReturnPlayerName( playerid ), playerid, drugsSold, positionToString( drugsSold ), cash_format( product_amount ) );
}

stock ShowBusinessMembers( playerid, businessid )
{
	new
		szMembers[ 96 ] = "0";

	for ( new i = 0; i < MAX_BUSINESS_MEMBERS; i ++ ) if ( g_businessData[ businessid ] [ E_MEMBERS ] [ i ] ) {
		format( szMembers, sizeof( szMembers ), "%s,%d", szMembers, g_businessData[ businessid ] [ E_MEMBERS ] [ i ] );
	}

	format( szBigString, sizeof( szBigString ), "SELECT `ID`, `NAME` FROM `USERS` WHERE `ID` IN (%s) ORDER BY `ID`", szMembers );
	mysql_function_query( dbHandle, szBigString, true, "OnShowBusinessMembers", "dd", playerid, businessid );
	return 1;
}

function OnShowBusinessMembers( playerid, businessid )
{
	new
		rows, fields, member[ MAX_PLAYER_NAME ];

	cache_get_data( rows, fields );

	if ( rows )
	{
		szBigString = ""COL_GREY"Add a new member...\n";

    	for( new i = 0; i < rows; i++ )
		{
			// get member name
			cache_get_field_content( i, "NAME", member, sizeof( member ) );
			format( szBigString, sizeof( szBigString ), "%s%s\n", szBigString, member );
		}

		ShowPlayerDialog( playerid, DIALOG_BUSINESS_MEMBERS, DIALOG_STYLE_LIST, ""COL_GREY"Business System", szBigString, "Kick", "Back" );
	}
	else
	{
		SendServerMessage( playerid, "Couldn't find any members for the business, add one if you desire." );
		ShowPlayerDialog( playerid, DIALOG_BUSINESS_ADD_MEMBER, DIALOG_STYLE_INPUT, ""COL_GREY"Business System", ""COL_WHITE"Type the name of the player you wish to add as a member.", "Add", "Back" );
	}
}

stock GetBusinessCarModelIndex( modelid ) {
	new
		index = 0;

	for( new i = 0; i < sizeof( g_businessCarModelData ); i ++ ) if ( g_businessCarModelData[ i ] [ E_MODEL ] == modelid ) {
		index = i;
		break;
	}
	return index;
}

stock GetBusinessAirModelIndex( modelid ) {
	new
		index = 0;

	for( new i = 0; i < sizeof( g_businessAirModelData ); i ++ ) if ( g_businessAirModelData[ i ] [ E_MODEL ] == modelid ) {
		index = i;
		break;
	}
	return index;
}

stock IsBusinessAerialVehicle( businessid, vehicleid ) {
	return ( vehicleid == g_businessData[ businessid ] [ E_HELI_MODEL_ID ] );
}

/*stock ShowBusinessSecurityUpgrades( playerid, businessid )
{
	new business_type = g_businessData[ businessid ] [ E_INTERIOR_TYPE ], security_cost;
	new security[ 400 ] = ""COL_WHITE"Security Level\t"COL_WHITE"Protection\t"COL_WHITE"Price\n";

	format( security, sizeof( security ), "%s"COL_RED"NONE\t25%s Safe Security + 50%s chance of breaking in\t"COL_GOLD"$0\n", security, "%", "%" );

	security_cost = floatround( float( g_businessInteriorData[ business_type ] [ E_UPGRADE_COST ] ) * g_businessSecurityData[ 1 ] [ E_COST_MULTIPLIER ] );
	format( security, sizeof( security ), "%s"COL_ORANGE"LOW\t50%s Safe Security + 25%s chance of breaking in\t"COL_GOLD"%s\n", security, "%", "%", cash_format( security_cost ) );

	security_cost = floatround( float( g_businessInteriorData[ business_type ] [ E_UPGRADE_COST ] ) * g_businessSecurityData[ 2 ] [ E_COST_MULTIPLIER ] );
	format( security, sizeof( security ), "%s"COL_YELLOW"MEDIUM\t75%s Safe Security + 10.0%s chance of breaking in\t"COL_GOLD"%s\n", security, "%", "%", cash_format( security_cost ) );

	security_cost = floatround( float( g_businessInteriorData[ business_type ] [ E_UPGRADE_COST ] ) * g_businessSecurityData[ 3 ] [ E_COST_MULTIPLIER ] );
	format( security, sizeof( security ), "%s"COL_GREEN"HIGH\t100%s Safe Security + 0.0%s chance of breaking in\t"COL_GOLD"%s\n", security, "%", "%", cash_format( security_cost ) );
	return ShowPlayerDialog( playerid, DIALOG_BUSINESS_SECURITY, DIALOG_STYLE_TABLIST_HEADERS, ""COL_GREY"Business System", security, "Purchase", "Back" );
}*/

stock GetOnlineBusinessAssociates( businessid, &members = 0, playerid = -1 ) {
	foreach ( new i : Player ) if ( playerid != i && IsBusinessAssociate( i, businessid ) ) {
		members ++;
	}
}
