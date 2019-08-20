/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\gangs\gvehicles.pwn
 * Purpose: gang vehicles (requires a gang facility to spawn the vehicles) for gangs
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define MAX_GANG_VEHICLES			( 10 )

#define DIALOG_GANG_VEHICLE_MENU 	2399
#define DIALOG_GANG_VEHICLE_SPAWN 	2400
#define DIALOG_GANG_VEHICLE_SELL 	2401
#define DIALOG_GANG_VD_BUY 			2402
#define DIALOG_GANG_VD_OPTIONS		2403
#define DIALOG_GANG_VD_CATEGORY		2404

#define PREVIEW_MODEL_GVEHICLE 		( 6 )

/* ** Macros ** */
#define IsValidGangVehicle(%0,%1) \
	( 0 <= %1 < MAX_GANG_VEHICLES && Iter_Contains( gangvehicles[%0], %1 ) )

/* ** Constants ** */
static const GANG_VEHICLE_PRICE_FACTOR = 4;
static const GANG_VEHICLE_SPAWN_COOLDOWN = 180;

/* ** Variables ** */
enum E_GANG_VEHICLE_DATA
{
	E_SQL_ID,			E_VEHICLE_ID,			E_ACTIVATION_TIME,

	E_COLOR[ 2 ],		E_MODEL,				E_PAINTJOB
};

new g_gangVehicleData				[ MAX_GANGS ] [ MAX_GANG_VEHICLES ] [ E_GANG_VEHICLE_DATA ];
new g_gangVehicleModifications		[ MAX_GANGS ] [ MAX_GANG_VEHICLES ] [ MAX_CAR_MODS ];
new Iterator: gangvehicles 			[ MAX_GANGS ] < MAX_GANG_VEHICLES >;
new bool: g_gangVehicle 			[ MAX_VEHICLES char ];

/* ** Hooks ** */
hook OnScriptInit( )
{
	Iter_Init( gangvehicles ); // reset the gang vehicles iterator
	return 1;
}

hook OnDialogResponse( playerid, dialogid, response, listitem, inputtext[ ] )
{
	new
		current_time = GetServerTime( );

	if ( dialogid == DIALOG_GANG_VEHICLE_MENU && response )
	{
		new gangid = GetPVarInt( playerid, "gang_vehicle_gang" );
		new facilityid = GetPVarInt( playerid, "gang_vehicle_facility" );

		if ( ! IsValidGangID ( gangid ) || ! Facility_IsValid( facilityid ) ) {
			return SendError( playerid, "There was an error processing gang vehicles, please try again." );
		}

		switch ( listitem )
		{
			// spawn vehicle
			case 0:
			{
				if ( ! Iter_Count( gangvehicles[ gangid ] ) ) {
					SendError( playerid, "This gang does not have any vehicles purchased." );
					return ShowPlayerGangVehicleMenu( playerid, facilityid );
				}

				return GangVehicles_ShowSpawnList( playerid, gangid );
			}

			// buy vehicle
			case 1: ShowBuyableVehiclesList( playerid, DIALOG_GANG_VD_CATEGORY, "Back" );

			// sell vehicle
			case 2:
			{
				if ( ! Iter_Count( gangvehicles[ gangid ] ) ) {
					SendError( playerid, "This gang does not have any vehicles purchased." );
					return ShowPlayerGangVehicleMenu( playerid, facilityid );
				}

				if ( ! IsPlayerGangLeader( playerid, gangid ) ) {
					SendError( playerid, "You are not the leader of this gang." );
					return ShowPlayerGangVehicleMenu( playerid, facilityid );
				}

				szBigString = ""COL_WHITE"Vehicle\t"COL_WHITE"Sell Price\n";

				foreach ( new slotid : gangvehicles[ gangid ] )
				{
					new
						sell_price = ( GetBuyableVehiclePrice( g_gangVehicleData[ gangid ] [ slotid ] [ E_MODEL ] ) * GANG_VEHICLE_PRICE_FACTOR ) / 2;

					format( szBigString, sizeof( szBigString ), "%s%s\t"COL_GOLD"%s\n", szBigString, GetVehicleName( g_gangVehicleData[ gangid ] [ slotid ] [ E_MODEL ] ), cash_format( sell_price ) );
				}
				return ShowPlayerDialog( playerid, DIALOG_GANG_VEHICLE_SELL, DIALOG_STYLE_TABLIST_HEADERS, ""COL_WHITE"Gang Vehicles - Sell", szBigString, "Sell", "Back" );
			}
		}
		return 1;
	}
	else if ( dialogid == DIALOG_GANG_VEHICLE_SELL )
	{
		new gangid = GetPVarInt( playerid, "gang_vehicle_gang" );
		new facilityid = GetPVarInt( playerid, "gang_vehicle_facility" );

		if ( ! IsValidGangID ( gangid ) || ! Facility_IsValid( facilityid ) ) {
			return SendError( playerid, "There was an error processing gang vehicles, please try again." );
		}

		if ( ! response ) {
			return ShowPlayerGangVehicleMenu( playerid, facilityid );
		}

		new
			x = 0;

		foreach ( new slotid : gangvehicles[ gangid ] )
		{
			if ( x == listitem )
			{
				if ( ! IsPlayerGangLeader( playerid, gangid ) ) {
					return SendError( playerid, "You are not the leader of this gang." );
				}

				new
					sell_price = ( GetBuyableVehiclePrice( g_gangVehicleData[ gangid ] [ slotid ] [ E_MODEL ] ) * GANG_VEHICLE_PRICE_FACTOR ) / 2;

				GiveGangCash( gangid, sell_price );
				SendServerMessage( playerid, "You have sold %s's %s for "COL_GOLD"%s"COL_WHITE".", g_gangData[ gangid ] [ E_NAME ], GetVehicleName( g_gangVehicleData[ gangid ] [ slotid ] [ E_MODEL ] ), cash_format( sell_price ) );

				DestroyGangVehicle( gangid, slotid );
				ShowPlayerGangVehicleMenu( playerid, facilityid );
				break;
			}
			x ++;
		}
		return 1;
	}
	else if ( dialogid == DIALOG_GANG_VD_BUY )
	{
		if ( response )
		{
			new
				type_id = GetPVarInt( playerid, "vehicle_preview" );

			for ( new id = 0, x = 0; id < sizeof( g_BuyableVehicleData ); id ++ )
			{
				if ( g_BuyableVehicleData[ id ] [ E_TYPE ] == type_id )
				{
			       	if ( x == listitem )
			      	{
			      		SetPVarInt( playerid, "buying_vehicle", id );
			      		ShowPlayerDialog( playerid, DIALOG_GANG_VD_OPTIONS, DIALOG_STYLE_LIST, "{FFFFFF}Gang Vehicles - Purchase", "Purchase This Vehicle\nPreview Vehicle", "Select", "Back" );
			      		return 1;
					}
			      	x++;
				}
			}
		}
		return ShowBuyableVehiclesList( playerid, DIALOG_GANG_VD_CATEGORY, "Back" );
	}
	else if ( dialogid == DIALOG_GANG_VD_OPTIONS )
	{
		new gangid = GetPVarInt( playerid, "gang_vehicle_gang" );
		new facilityid = GetPVarInt( playerid, "gang_vehicle_facility" );

		if ( ! IsValidGangID ( gangid ) || ! Facility_IsValid( facilityid ) ) {
			return SendError( playerid, "There was an error processing gang vehicles, please try again." );
		}

		if ( ! response ) {
			return GangVehicles_ShowBuyableList( playerid, GetPVarInt( playerid, "vehicle_preview" ) );
		}

		switch ( listitem )
		{
			// bought the vehicle
			case 0:
			{
				if ( ! IsPlayerGangLeader( playerid, gangid ) ) {
					ShowPlayerDialog( playerid, DIALOG_GANG_VD_OPTIONS, DIALOG_STYLE_LIST, "{FFFFFF}Gang Vehicles - Purchase", "Purchase This Vehicle\nPreview Vehicle", "Select", "Back" );
					return SendError( playerid, "You are not the leader of this gang." );
				}

				new
					num_vehicles = Iter_Count( gangvehicles[ gangid ] );

				if ( num_vehicles >= MAX_GANG_VEHICLES ) {
					ShowPlayerDialog( playerid, DIALOG_GANG_VD_OPTIONS, DIALOG_STYLE_LIST, "{FFFFFF}Gang Vehicles - Purchase", "Purchase This Vehicle\nPreview Vehicle", "Select", "Back" );
					return SendError( playerid, "Your gang has reached the gang vehicle limit of %d.", MAX_GANG_VEHICLES );
				}

				new
					data_id = GetPVarInt( playerid, "buying_vehicle" );

				// VIP Check
				if ( g_BuyableVehicleData[ data_id ] [ E_VIP ] )
				{
					if ( p_VIPLevel[ playerid ] < VIP_REGULAR ) {
						ShowPlayerDialog( playerid, DIALOG_GANG_VD_OPTIONS, DIALOG_STYLE_LIST, "{FFFFFF}Gang Vehicles - Purchase", "Purchase This Vehicle\nPreview Vehicle", "Select", "Back" );
						return SendError( playerid, "You are not a V.I.P, to become one visit "COL_GREY"donate.sfcnr.com" );
					}

					if ( ( ( p_VIPExpiretime[ playerid ] - g_iTime ) / 86400 ) < 3 ) {
						ShowPlayerDialog( playerid, DIALOG_GANG_VD_OPTIONS, DIALOG_STYLE_LIST, "{FFFFFF}Gang Vehicles - Purchase", "Purchase This Vehicle\nPreview Vehicle", "Select", "Back" );
						return SendError( playerid, "You need more than 3 days of V.I.P in order to complete this." );
					}
				}

				new
					final_price = g_BuyableVehicleData[ data_id ] [ E_PRICE ] * GANG_VEHICLE_PRICE_FACTOR;

				// Money check
				if ( GetGangCash( gangid ) < final_price ) {
					ShowPlayerDialog( playerid, DIALOG_GANG_VD_OPTIONS, DIALOG_STYLE_LIST, "{FFFFFF}Gang Vehicles - Purchase", "Purchase This Vehicle\nPreview Vehicle", "Select", "Back" );
					return SendError( playerid, "Your gang does not have enough money for this vehicle (%s).", cash_format( final_price ) );
				}

				new
					slotid = CreateGangVehicle( gangid, g_BuyableVehicleData[ data_id ] [ E_MODEL ] );

				if ( slotid == ITER_NONE ) {
					ShowPlayerDialog( playerid, DIALOG_GANG_VD_OPTIONS, DIALOG_STYLE_LIST, "{FFFFFF}Gang Vehicles - Purchase", "Purchase This Vehicle\nPreview Vehicle", "Select", "Back" );
					return SendError( playerid, "Your gang has reached the gang vehicle limit of %d.", MAX_GANG_VEHICLES );
				}

				GiveGangCash( gangid, -final_price );
				StockMarket_UpdateEarnings( E_STOCK_VEHICLE_DEALERSHIP, final_price, 0.01 );

				printf( "[gang vehicle] %s(%d) bought %s for %s", ReturnPlayerName( playerid ), GetPlayerAccountID( playerid ), g_BuyableVehicleData[ data_id ] [ E_NAME ], g_gangData[ gangid ] [ E_NAME ] );
				SendServerMessage( playerid, "You have bought an "COL_GREY"%s"COL_WHITE" for "COL_GOLD"%s"COL_WHITE"!", g_BuyableVehicleData[ data_id ] [ E_NAME ], cash_format( final_price ) );
				SendServerMessage( playerid, "You can spawn this vehicle using the mechanic at any gang facility.", g_BuyableVehicleData[ data_id ] [ E_NAME ], cash_format( final_price ) );
				return ShowPlayerGangVehicleMenu( playerid, facilityid );
			}

			// preview
			case 1:
			{
				return ShowPlayerModelPreview( playerid, PREVIEW_MODEL_GVEHICLE, "Gang Vehicle Preview", g_BuyableVehicleData[ GetPVarInt( playerid, "buying_vehicle" ) ] [ E_MODEL ] );
			}
		}
		return 1;
	}
	else if ( dialogid == DIALOG_GANG_VD_CATEGORY )
	{
		new gangid = GetPVarInt( playerid, "gang_vehicle_gang" );
		new facilityid = GetPVarInt( playerid, "gang_vehicle_facility" );

		if ( ! IsValidGangID ( gangid ) || ! Facility_IsValid( facilityid ) ) {
			return SendError( playerid, "There was an error processing gang vehicles, please try again." );
		}

		if ( ! response ) {
			return ShowPlayerGangVehicleMenu( playerid, facilityid );
		}

		return GangVehicles_ShowBuyableList( playerid, listitem + 1 );
	}
	else if ( dialogid == DIALOG_GANG_VEHICLE_SPAWN )
	{
		new gangid = GetPVarInt( playerid, "gang_vehicle_gang" );
		new facilityid = GetPVarInt( playerid, "gang_vehicle_facility" );

		if ( ! IsValidGangID ( gangid ) || ! Facility_IsValid( facilityid ) ) {
			return SendError( playerid, "There was an error processing gang vehicles, please try again." );
		}

		if ( ! response ) {
			return ShowPlayerGangVehicleMenu( playerid, facilityid );
		}

		new
			x = 0;

		foreach ( new slotid : gangvehicles[ gangid ] )
		{
			if ( x == listitem )
			{
				if ( g_gangVehicleData[ gangid ] [ slotid ] [ E_ACTIVATION_TIME ] > current_time ) {
					GangVehicles_ShowSpawnList( playerid, gangid );
					return SendError( playerid, "This vehicle cannot be spawned for another %s.", secondstotime( g_gangVehicleData[ gangid ] [ slotid ] [ E_ACTIVATION_TIME ] - current_time ) );
				}

				new
					occupierid = IsVehicleOccupied( g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ] );

				if ( occupierid != -1 ) {
					GangVehicles_ShowSpawnList( playerid, gangid );
					return SendError( playerid, "This vehicle cannot be spawned right now as it is occupied by %s(%d).", ReturnPlayerName( occupierid ), occupierid );
				}

				new Float: facility_x, Float: facility_y, Float: facility_z, Float: rotation;
				GetGangFacilityPos( facilityid, facility_x, facility_y, facility_z );

				// find nearest dock
	        	if ( IsBoatVehicle( g_gangVehicleData[ gangid ] [ slotid ] [ E_MODEL ] ) ) {
					GetClosestBoatPort( facility_x, facility_y, facility_z, facility_x, facility_y, facility_z );
	        	}

	        	// spawn air vehicles in the sky
	        	else if ( IsAirVehicle( g_gangVehicleData[ gangid ] [ slotid ] [ E_MODEL ] ) ) {
					facility_z += 300.0;
				}

				// spawn vehicles at the closest road
		        else {
					new Float: nodeX, Float: nodeY, Float: nodeZ, Float: nextX, Float: nextY;
					new nodeid = NearestNodeFromPoint( facility_x, facility_y, facility_z );
					new nextNodeid = NearestNodeFromPoint( facility_x, facility_y, facility_z, 9999.9, nodeid );

					GetNodePos( nextNodeid, nextX, nextY, nodeZ );
					GetNodePos( nodeid, nodeX, nodeY, nodeZ );

					rotation = atan2( nextY - nodeY, nextX - nodeX ) - 90.0;

				   	facility_x = nodeX, facility_y = nodeY, facility_z = nodeZ;
		        }

		        new
		        	vehicleid = SpawnGangVehicle( gangid, slotid, facility_x, facility_y, facility_z + 2.0, rotation );

		        if ( vehicleid ) {
			        SetPlayerInterior( playerid, 0 );
			        SetPlayerVirtualWorld( playerid, 0 );
					PutPlayerInVehicle( playerid, vehicleid, 0 );
		        } else {
		        	SendError( playerid, "Could not spawn gang vehicle due to an unexpected error." );
		        }
				break;
			}
			x ++;
		}
		return 1;
	}
	return 1;
}

hook OnGangLoad( gangid )
{
	mysql_tquery( dbHandle, sprintf( "SELECT * FROM `GANG_VEHICLES` WHERE `GANG_ID` = %d ", GetGangSqlID( gangid ) ), "GangVehicles_LoadVehicles", "d", gangid );
	return 1;
}

hook OnGangUnload( gangid, bool: deleted )
{
	foreach ( new slotid : gangvehicles[ gangid ] ) {
		RemoveGangVehicle( gangid, slotid );
		Iter_SafeRemove( gangvehicles[ gangid ], slotid, slotid );
	}
	return 1;
}

hook OnPlayerEndModelPreview( playerid, handleid )
{
	if ( handleid == PREVIEW_MODEL_GVEHICLE )
	{
		SendServerMessage( playerid, "You have finished looking at the gang vehicle preview." );
		ShowPlayerDialog( playerid, DIALOG_GANG_VD_OPTIONS, DIALOG_STYLE_LIST, "{FFFFFF}Gang Vehicles - Purchase", "Purchase This Vehicle\nPreview Vehicle", "Select", "Back" );
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return 1;
}

hook OnEnterExitModShop( playerid, enterexit, interiorid )
{
	if ( enterexit == 0 )
	{
		new
		    vehicleid = GetPlayerVehicleID( playerid );

	    if ( IsValidVehicle( vehicleid ) )
	    {
			if ( g_gangVehicle{ vehicleid } )
			{
				new
					gangid, slotid;

				GetGangVehicleData( vehicleid, gangid, slotid );

			    if ( IsValidGangID( gangid ) && IsValidGangVehicle( gangid, slotid ) && IsPlayerGangLeader( playerid, gangid ) )
			    {
		        	new
			        	szMods[ MAX_CAR_MODS * 10 ];

			    	// save vehicle mods to variable
					for ( new i = 0; i < MAX_CAR_MODS; i ++ )
					{
						// check if valid mod
				    	if ( ( g_gangVehicleModifications[ gangid ] [ slotid ] [ i ] = GetVehicleComponentInSlot( vehicleid, i ) ) < 1000 ) {
				    		g_gangVehicleModifications[ gangid ] [ slotid ] [ i ] = 0;
				    	}

				    	// save as a sql delimited string
						format( szMods, sizeof( szMods ), "%s%d.", szMods, g_gangVehicleModifications[ gangid ] [ slotid ] [ i ] );
					}

					// update sql
					mysql_format( dbHandle, szBigString, sizeof( szBigString ), "UPDATE `GANG_VEHICLES` SET `MODS`='%e' WHERE `ID`=%d", szMods, g_gangVehicleData[ gangid ] [ slotid ] [ E_SQL_ID ] );
					mysql_single_query( szBigString );
					print( szBigString );
			    }
			}
		}
	}
	return 1;
}

hook OnVehicleSpawn( vehicleid )
{
	if ( g_gangVehicle{ vehicleid } )
	{
		new
			gangid, slotid;

		GetGangVehicleData( vehicleid, gangid, slotid );

	    if ( IsValidGangID( gangid ) && IsValidGangVehicle( gangid, slotid ) ) {
	    	RemoveGangVehicle( gangid, slotid );
	    }
	}
	return 1;
}

hook OnVehiclePaintjob( playerid, vehicleid, paintjobid )
{
	if ( g_gangVehicle{ vehicleid } )
	{
		new
			gangid, slotid;

		GetGangVehicleData( vehicleid, gangid, slotid );

	    if ( IsValidGangID( gangid ) && IsValidGangVehicle( gangid, slotid ) && IsPlayerGangLeader( playerid, gangid ) )
	    {
	        g_gangVehicleData[ gangid ] [ slotid ] [ E_PAINTJOB ] = paintjobid;
	        mysql_single_query( sprintf( "UPDATE `GANG_VEHICLES` SET `PAINTJOB` = %d WHERE `ID` = %d", paintjobid, g_gangVehicleData[ gangid ] [ slotid ] [ E_SQL_ID ] ) );
	    }
	}
	return 1;
}

hook OnVehicleRespray( playerid, vehicleid, color1, color2 )
{
    if ( g_gangVehicle{ vehicleid } )
    {
		new
			gangid, slotid;

		GetGangVehicleData( vehicleid, gangid, slotid );

	    if ( IsValidGangID( gangid ) && IsValidGangVehicle( gangid, slotid ) && IsPlayerGangLeader( playerid, gangid ) )
	    {
			g_gangVehicleData[ gangid ] [ slotid ] [ E_COLOR ] [ 0 ] = color1;
	        g_gangVehicleData[ gangid ] [ slotid ] [ E_COLOR ] [ 1 ] = color2;
	        mysql_single_query( sprintf( "UPDATE `GANG_VEHICLES` SET `COLOR1` = %d, `COLOR2` = %d WHERE `ID` = %d", color1, color2, g_gangVehicleData[ gangid ] [ slotid ] [ E_SQL_ID ] ) );
		}
    }
	return 1;
}

hook OnPlayerDriveVehicle( playerid, vehicleid )
{
    if ( g_gangVehicle{ vehicleid } )
    {
		new
			gangid, slotid;

		GetGangVehicleData( vehicleid, gangid, slotid );

	    if ( IsValidGangID( gangid ) && IsValidGangVehicle( gangid, slotid ) )
	    {
	    	new
	    		player_gang = GetPlayerGang( playerid );

	    	if ( player_gang == gangid )
	    	{
				SendClientMessageFormatted( playerid, g_gangData[ gangid ] [ E_COLOR ], "[GANG VEHICLE]"COL_WHITE" Welcome to %s's vehicle.", g_gangData[ gangid ] [ E_NAME ] );
				Beep( playerid );
	    	}
	    	else if ( ! IsPlayerAdminOnDuty( playerid ) )
	    	{
				SyncObject( playerid, 1 ); // Just sets the players position where the vehicle is.
				SendError( playerid, "This vehicle is restricted to gang members of %s.", g_gangData[ gangid ] [ E_NAME ] );
	    	}
	    }
	}
	return 1;
}

/* ** SQL Threads ** */
thread GangVehicles_LoadVehicles( gangid )
{
	new
		rows = cache_get_row_count( );

	if ( rows )
	{
		static
			paintjob[ 90 ];

		for ( new row = 0; row < rows; row ++ )
		{
			new slotid = CreateGangVehicle(
				gangid,
				cache_get_field_content_int( row, "MODEL_ID" ),
				cache_get_field_content_int( row, "COLOR1" ),
				cache_get_field_content_int( row, "COLOR2" ),
				cache_get_field_content_int( row, "PAINTJOB" ),
				cache_get_field_content_int( row, "ID" )
			);

			// load the paintjobs in
			if ( slotid != ITER_NONE ) {
				cache_get_field_content( row, "MODS", paintjob );
				sscanf( paintjob, "p<.>e<ddddddddddddddd>", g_gangVehicleModifications[ gangid ] [ slotid ] );
			}
		}
	}
	return 1;
}

thread GangVehicles_InsertVehicle( gangid, slotid ) {
	g_gangVehicleData[ gangid ] [ slotid ] [ E_SQL_ID ] = cache_insert_id( );
	return 1;
}

/* ** Functions ** */
stock CreateGangVehicle( gangid, modelid, color1 = -1, color2 = -1, paintjob = 3, sql_id = -1 )
{
	new
		slotid = Iter_Free( gangvehicles[ gangid ] );

	if ( slotid != ITER_NONE )
	{
		g_gangVehicleData[ gangid ] [ slotid ] [ E_ACTIVATION_TIME ] = 0;
		g_gangVehicleData[ gangid ] [ slotid ] [ E_COLOR ] [ 0 ] = color1;
		g_gangVehicleData[ gangid ] [ slotid ] [ E_COLOR ] [ 1 ] = color2;
		g_gangVehicleData[ gangid ] [ slotid ] [ E_PAINTJOB ] = paintjob;
		g_gangVehicleData[ gangid ] [ slotid ] [ E_MODEL ] = modelid;
		g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ] = -1;

		// insert if not exists
		if ( sql_id != -1 ) {
			g_gangVehicleData[ gangid ] [ slotid ] [ E_SQL_ID ] = sql_id;
		} else {
			mysql_format( dbHandle, szBigString, sizeof( szBigString ), "INSERT INTO `GANG_VEHICLES` (`GANG_ID`,`MODEL_ID`,`COLOR1`,`COLOR2`,`PAINTJOB`,`MODS`) VALUES (%d,%d,%d,%d,%d,'0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.')", GetGangSqlID( gangid ), modelid, color1, color2, paintjob );
			mysql_tquery( dbHandle, szBigString, "GangVehicles_InsertVehicle", "dd", gangid, slotid );
		}

		ResetGangVehicleMods( gangid, slotid );
		Iter_Add( gangvehicles[ gangid ], slotid );
	}
	return slotid;
}

stock DestroyGangVehicle( gangid, slotid )
{
	if ( Iter_Contains( gangvehicles[ gangid ], slotid ) ) {
		RemoveGangVehicle( gangid, slotid );
		mysql_single_query( sprintf( "DELETE FROM `GANG_VEHICLES` WHERE `ID` = %d", g_gangVehicleData[ gangid ] [ slotid ] [ E_SQL_ID ] ) );
		Iter_Remove( gangvehicles[ gangid ], slotid );
	}
	return 0;
}

stock RemoveGangVehicle( gangid, slotid )
{
	if ( Iter_Contains( gangvehicles[ gangid ], slotid ) ) {
		if ( g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ] != -1 ) {
			g_gangVehicle{ g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ] } = false;
		}
		DestroyVehicle( g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ] );
		g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ] = -1;
	}
	return 0;
}

stock SpawnGangVehicle( gangid, slotid, Float: X, Float: Y, Float: Z, Float: RZ )
{
	new
		vehicleid = 0;

	if ( Iter_Contains( gangvehicles[ gangid ], slotid ) )
	{
		// reset special data
	    ResetVehicleMethlabData( g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ], true );

		// make sure vehicle does not exist
		RemoveGangVehicle( gangid, slotid );

		// create vehicle
		if ( IsValidVehicle( ( vehicleid = CreateVehicle( g_gangVehicleData[ gangid ] [ slotid ] [ E_MODEL ], X, Y, Z, RZ, g_gangVehicleData[ gangid ] [ slotid ] [ E_COLOR ] [ 0 ], g_gangVehicleData[ gangid ] [ slotid ] [ E_COLOR ] [ 1 ], GANG_VEHICLE_SPAWN_COOLDOWN, .addsiren = 1 ) ) ) )
		{
			// set vehicle id
			g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ] = vehicleid;
			g_gangVehicleData[ gangid ] [ slotid ] [ E_ACTIVATION_TIME ] = GetServerTime( ) + GANG_VEHICLE_SPAWN_COOLDOWN;
			g_gangVehicle{ vehicleid } = true;

			// restore data
			SetVehicleNumberPlate( g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ], g_gangData[ gangid ] [ E_NAME ] );
			ChangeVehiclePaintjob( g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ], g_gangVehicleData[ gangid ] [ slotid ] [ E_PAINTJOB ] );

			// restore car mods
			for ( new i = 0; i < MAX_CAR_MODS; i ++ )  {
			    if ( g_gangVehicleModifications[ gangid ] [ slotid ] [ i ] >= 1000 && g_gangVehicleModifications[ gangid ] [ slotid ] [ i ] < 1193 ) {
			        if ( CarMod_IsLegalCarMod( GetVehicleModel( g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ] ), g_gangVehicleModifications[ gangid ] [ slotid ] [ i ] ) ) {
			            AddVehicleComponent( g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ], g_gangVehicleModifications[ gangid ] [ slotid ] [ i ] );
			        } else {
					    g_gangVehicleModifications[ gangid ] [ slotid ] [ i ] = 0;
			        }
			    }
			}
			return vehicleid;
		}
	}
	return 0;
}

stock ResetGangVehicleMods( gangid, slotid, fordestroy=1 )
{
	if ( ! IsValidGangVehicle( gangid, slotid ) )
		return;

	for ( new i = 0; i < MAX_CAR_MODS; i++ )
	{
		if ( ! fordestroy && IsValidVehicle( g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ] ) ) {
	        if ( CarMod_IsLegalCarMod( GetVehicleModel( g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ] ), g_gangVehicleModifications[ gangid ] [ slotid ] [ i ] ) ) {
	            RemoveVehicleComponent( g_gangVehicleData[ gangid ] [ slotid ] [ E_VEHICLE_ID ], g_gangVehicleModifications[ gangid ] [ slotid ] [ i ] );
	        }
		}
		g_gangVehicleModifications[ gangid ] [ slotid ] [ i ] = 0;
	}

	format( szNormalString, sizeof( szNormalString ), "UPDATE `GANG_VEHICLES` SET `MODS`='0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.' WHERE `ID`=%d", g_gangVehicleData[ gangid ] [ slotid ] [ E_SQL_ID ] );
	mysql_single_query( szNormalString );
}

stock ShowPlayerGangVehicleMenu( playerid, facilityid )
{
	SetPVarInt( playerid, "gang_vehicle_facility", facilityid );
	SetPVarInt( playerid, "gang_vehicle_gang", GetGangIDFromFacilityID( facilityid ) );
	ShowPlayerDialog( playerid, DIALOG_GANG_VEHICLE_MENU, DIALOG_STYLE_LIST, ""COL_WHITE"Gang Vehicles", "Spawn Gang Vehicle\nBuy Gang Vehicle\nSell Gang Vehicle", "Select", "Close" );
	return 1;
}

static stock GangVehicles_ShowBuyableList( playerid, type_id )
{
	static
		buyable_vehicles[ 1400 ], i;

	for ( i = 0, buyable_vehicles = ""COL_WHITE"Vehicle\t"COL_WHITE"Price ($)\n"; i < sizeof( g_BuyableVehicleData ); i ++ ) if ( g_BuyableVehicleData[ i ] [ E_TYPE ] == type_id ) {
		format( buyable_vehicles, sizeof( buyable_vehicles ), "%s%s%s\t"COL_GREEN"%s\n", buyable_vehicles, g_BuyableVehicleData[ i ] [ E_VIP ] ? ( COL_GOLD ) : ( COL_WHITE ), g_BuyableVehicleData[ i ] [ E_NAME ], cash_format( g_BuyableVehicleData[ i ] [ E_PRICE ] * GANG_VEHICLE_PRICE_FACTOR ) );
	}

	SetPVarInt( playerid, "vehicle_preview", type_id );
	return ShowPlayerDialog( playerid, DIALOG_GANG_VD_BUY, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Vehicle Dealership", buyable_vehicles, "Select", "Back" );
}

stock GetGangVehicleData( vehicleid, &gangid, &slotid ) {
	foreach ( new g : gangs ) {
		foreach ( new v : gangvehicles[ g ] ) if ( g_gangVehicleData[ g ] [ v ] [ E_VEHICLE_ID ] == vehicleid ) {
			gangid = g;
			slotid = v;
			break;
		}
	}
}

static stock GangVehicles_ShowSpawnList( playerid, gangid ) {
	new
		current_time = GetServerTime( );

	szLargeString = ""COL_WHITE"Vehicle\t"COL_WHITE"Availablity\n";

	foreach ( new slotid : gangvehicles[ gangid ] )
	{
		format( szLargeString, sizeof( szLargeString ), "%s%s\t%s\n", szLargeString,
			GetVehicleName( g_gangVehicleData[ gangid ] [ slotid ] [ E_MODEL ] ),
			g_gangVehicleData[ gangid ] [ slotid ] [ E_ACTIVATION_TIME ] > current_time ? ( secondstotime( g_gangVehicleData[ gangid ] [ slotid ] [ E_ACTIVATION_TIME ] - current_time ) ) : ( COL_GREEN # "Available" )
		);
	}
	return ShowPlayerDialog( playerid, DIALOG_GANG_VEHICLE_SPAWN, DIALOG_STYLE_TABLIST_HEADERS, ""COL_WHITE"Gang Vehicles - Spawn", szLargeString, "Select", "Close" );
}
/* ** Migrations ** */
/*
	CREATE TABLE IF NOT EXISTS `GANG_VEHICLES` (
		`ID` int(11) auto_increment primary key,
		`GANG_ID` int(11),
		`MODEL_ID` int(11),
		`COLOR1` int(4),
		`COLOR2` int(4),
		`PAINTJOB` tinyint(2),
		`MODS` varchar(90),
		FOREIGN KEY (GANG_ID) REFERENCES GANGS (ID) ON DELETE CASCADE
	);
 */
