/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cities.inc
 * Purpose: definitions of spawn & cities
 */

/* ** Configuration ** */
#define ENABLE_CITY_LV 				true
#define ENABLE_CITY_LS 				true

/* ** Definitions ** */
#define MAX_CITIES 					3

#define CITY_SF 					0
#define CITY_LV						1
#define CITY_LS						2
#define CITY_DESERTS 				3
#define CITY_COUNTRY				4

/* ** Macros ** */
#define ResetSpawnLocation(%0)		SetPlayerSpawnLocation(%0, "")

/* ** Variables ** */

enum E_RANDOM_SPAWNS
{
	Float:RANDOM_SPAWN_X,
	Float:RANDOM_SPAWN_Y,
	Float:RANDOM_SPAWN_Z,
	Float:RANDOM_SPAWN_A,
	RANDOM_SPAWN_INTERIOR,
	RANDOM_SPAWN_WORLD
};

new const
	g_SanFierroSpawns[ ] [ E_RANDOM_SPAWNS ] =
	{
		{ -1757.4670, 961.8670, 24.8828, 181.7833,  0, 0 }, // financial
		{ -1953.8724, 300.1801, 41.0471, 133.1765, 	0, 0 }, // wang cars
		{ -2020.3107, -96.6103, 35.1641, 331.9525,  0, 0 }, // driving school
		{ -2519.0496, -30.7666, 25.6172, 319.5007,  0, 0 }, // hashbury
		{ -2759.6978, 375.4238, 4.5230,  270.5632,  0, 0 }, // city hall
		{ -1501.3506, 914.5378, 7.1875,  90.5807,   0, 0 }, // bank
		{ -2626.2156, 1398.626, 7.1016,  204.5252,  0, 0 }, // jizzy
		{ -2238.6428, 113.4054, 35.3203, 243.0862,  0, 0 }, // pawn shop
		{ -1983.5684, 129.8655, 27.6875, 74.4550, 	0, 0 }, // train station
		{ -2587.4861, 212.0579, 9.0733,  9.073300,  0, 0 }, // ammunation
		{ -2026.3287, 67.1439, 28.6916, 270.0000, 	0, 0 }, // fireman
		{ -2658.0764, 634.333, 14.4531, 180.0000, 	0, 0 }, // hospital
		{ -1939.5635, 561.4606, 35.1686, 358.4566, 0, 0 }, // downtown
		{ -2442.6489, 742.1188, 35.0156, 178.6477, 0, 0 }, // supa save
		{ -1981.8663, 1119.8961, 53.1285, 271.1959, 0, 0 } // church
	},

	g_LasVenturasSpawns[ ] [ E_RANDOM_SPAWNS ] =
	{
		{ 2170.4834, 1714.3723, 11.0469, 137.5881, 	0, 0 },
		{ 2000.1403, 1564.7941, 15.3672, 236.5212,  0, 0 },
		{ 2417.5991, 1136.6140, 10.8125, 225.6512,  0, 0 },
		{ 2484.6160, 1528.7273, 10.8954, 323.0129, 	0, 0 },
		{ 2464.4070, 2033.2441, 11.0625, 47.88940,  0, 0 },
		{ 2451.2332, 2347.0044, 12.1635, 112.7286,  0, 0 },
		{ 1480.3296, 2250.1125, 11.0291, 279.2149, 	0, 0 },
		{ 2143.3252, 2840.4441, 10.8203, 139.9116, 	0, 0 },
		{ 1744.56240, 2079.43, 10.8203, 172.1325, 	0, 0 },
		{ 1615.62490, 1840.19, 10.9696, 0.000000, 	0, 0 }
	},

	g_LosSantosSpawns 				[ ] [ E_RANDOM_SPAWNS ] =
	{
		{ 810.63520, -1340.0682, 13.5386, 37.33070, 0, 0 },
		{ 1124.6071, -1427.5155, 15.7969, 350.9336, 0, 0 },
		{ 585.81520, -1247.9160, 17.9521, 335.6035, 0, 0 },
		{ 2025.2626, -1423.2682, 16.9922, 135.4516, 0, 0 },
		{ 2509.2468, -1679.2029, 13.5469, 50.24740, 0, 0 },
		{ 1457.1467, -1011.7307, 26.8438, 51.79910, 0, 0 },
		{ 2017.8206, -1279.4851, 23.9820, 47.38920, 0, 0 },
		{ 1935.7644, -1794.6068, 13.5469, 295.5515, 0, 0 },
		{ 1371.4569, -1090.6387, 24.5459, 92.84640, 0, 0 },
		{ 2298.4055, -1500.3264, 25.3047, 199.6940, 0, 0 },
		{ 1178.0417, -1323.6000, 14.1005, 285.5701, 0, 0 },
		{ 1757.44350, -1456.7, 13.5469, 282.4133, 	0, 0 }
	},

	g_ArmySpawns 					[ MAX_CITIES ] [ E_RANDOM_SPAWNS ] =
	{
		{ -1401.8173, 493.496, 18.2294, 0.000000, 	0, 0 },
		{ 199.572200, 1920.97, 17.6406, 180.0000, 	0, 0 },
		{ 1229.35670, -2611.4, 19.7344, 264.2092, 	0, 0 }
	},

	g_CIASpawns 					[ MAX_CITIES ] [ E_RANDOM_SPAWNS ] =
	{
		{ -2455.4487, 503.92360, 30.078, 270.000, 0, 0 },
		{ 940.813400, 1733.6327, 8.8516, 270.000, 0, 0 },
		{ 1518.82930, -1452.430, 14.203, 0.00000, 0, 0 }
	},

	g_PoliceSpawns					[ MAX_CITIES ] [ E_RANDOM_SPAWNS ] =
	{
		{ -1606.3693, 674.1749, -5.2422, 0.0000, 0, 0 },
		{ 2295.62960, 2468.796, 10.8203, 90.000, 0, 0 },
		{ 1528.58340, -1677.49, 5.89060, 270.00, 0, 0 }
	}
;

new
	p_SpawningKey 					[ MAX_PLAYERS ] [ 4 ],
	p_SpawningIndex 				[ MAX_PLAYERS ]
;

/* ** Functions ** */
stock SetPlayerSpawnLocation( playerid, spawn_key[ 4 ], spawn_index = 0 )
{
	// set sql, null if key is null
	if ( spawn_key[ 0 ] == '\0' ) {
		mysql_single_query( sprintf( "UPDATE `USERS` SET `SPAWN`=NULL WHERE `ID`=%d", GetPlayerAccountID( playerid ) ) );
	} else {
		mysql_single_query( sprintf( "UPDATE `USERS` SET `SPAWN`='%s %d' WHERE `ID`=%d", spawn_key, spawn_index, GetPlayerAccountID( playerid ) ) );
	}

	// variable update
	strcpy( p_SpawningKey[ playerid ], spawn_key );
	p_SpawningIndex[ playerid ] = spawn_index;
	return 1;
}

stock returnCityName( city )
{
	static
		string[ 13 ];

	switch( city )
	{
		case CITY_SF: string = "San Fierro";
		case CITY_LV: string = "Las Venturas";
		case CITY_LS: string = "Los Santos";
		default: string = "Random City";
	}
	return string;
}
