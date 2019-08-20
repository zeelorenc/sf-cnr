	/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr/commands/admin/admin_five.pwn
 * Purpose: level five administrator commands (cnr)
 */

/* ** Commands ** */
CMD:givearmour( playerid, params[ ] )
{
    new pID;
    if ( p_AdminLevel[ playerid] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT);
    else if (sscanf (params, "u", pID ) ) SendUsage(playerid, "/givearmour [PLAYER_ID]");
    else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
    else if ( IsPlayerJailed( pID ) ) return SendError( playerid, "This player is jailed, you cannot do this." );
    else if ( IsPlayerAdminOnDuty( pID ) ) return SendError( playerid, "This player is an admin on duty, you cannot do this." );
    else
    {
        SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) gave you armour.", ReturnPlayerName( playerid ), playerid );
        SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have given armour to %s(%d).", ReturnPlayerName( pID ), pID );
        AddAdminLogLineFormatted( "%s(%d) has given armour to %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
        SetPlayerArmour( pID, 100.0 );
    }
    return 1;
}

CMD:armorall( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 5 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	new world = GetPlayerVirtualWorld( playerid );
	AddAdminLogLineFormatted( "%s(%d) has given armor to everybody in their world", ReturnPlayerName( playerid ), playerid );
	foreach ( new i : Player ) {
	    if ( !p_Jailed{ i } && world == GetPlayerVirtualWorld( i ) ) SetPlayerArmour( i, 100.0 );
	}
	SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" Everyone has been given armor by %s(%d) in their world!", ReturnPlayerName( playerid ), playerid );
	return 1;
}

CMD:viewpolicechat( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 5 && !IsPlayerUnderCover( playerid ) ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	p_ToggleCopChat{ playerid } = !p_ToggleCopChat{ playerid };

	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have %s viewing police.", p_ToggleCopChat{ playerid } == true ? ("toggled") : ("un-toggled") );
    if ( !IsPlayerUnderCover( playerid ) ) {
		AddAdminLogLineFormatted( "%s(%d) has %s viewing police chat", ReturnPlayerName( playerid ), playerid, p_ToggleCopChat{ playerid } == true ? ("toggled") : ("un-toggled") );
    }
	return 1;
}

CMD:viewpbchat( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 5 && !IsPlayerUnderCover( playerid ) ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	p_TogglePBChat{ playerid } = !p_TogglePBChat{ playerid };

	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have %s viewing paint-ball chat.", p_TogglePBChat{ playerid } == true ? ("toggled") : ("un-toggled") );
    if ( !IsPlayerUnderCover( playerid ) ) {
		AddAdminLogLineFormatted( "%s(%d) has %s viewing paintball chat", ReturnPlayerName( playerid ), playerid, p_TogglePBChat{ playerid } == true ? ("toggled") : ("un-toggled") );
    }
	return 1;
}

CMD:check( playerid, params[ ] )
{
	new
		pID
	;

    if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/check [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else
	{
		new
			playerserial[ 45 ];

		gpci( pID, playerserial, sizeof( playerserial ) ); // playerserial

		format( szNormalString, sizeof( szNormalString ), "SELECT `NAME`,`IP`,`COUNTRY` FROM `BANS` WHERE `SERIAL`='%s' LIMIT 32", mysql_escape( playerserial ) );
		mysql_function_query( dbHandle, szNormalString, true, "readgpcibans", "dd", playerid, pID );
	}
	return 1;
}

thread readgpcibans( playerid, searchid )
{
	new
	    rows, fields
	;
    cache_get_data( rows, fields );

    if ( rows )
    {
    	new
    		szName[ MAX_PLAYER_NAME ],
    		szIP[ 16 ],
    		szCountry[ 3 ]
    	;

    	szLargeString = ""COL_GREY"Username\t"COL_GREY"IP Address\t"COL_GREY"Country (XX)\n";

    	for( new i = 0; i < rows; i++ )
		{
			cache_get_field_content( i, "COUNTRY", szCountry );
			cache_get_field_content( i, "NAME", szName );
			cache_get_field_content( i, "IP", szIP );

			if ( isnull( szCountry ) )
				szCountry = "-";

			format( szLargeString, sizeof( szLargeString ), "%s%s\t%s\t%s\n", szLargeString, szName, szIP, szCountry );
		}

		ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_TABLIST_HEADERS, sprintf( "{FFFFFF}Serial check on %s(%d)", ReturnPlayerName( searchid ), searchid ), szLargeString, "Okay", "" );
		return 1;
	}
	SendError( playerid, "This user looks clean!" );
	return 1;
}

CMD:c( playerid, params[ ] )
{
	new
	    msg[ 90 ]
	;

    if ( p_AdminLevel[ playerid ] < 5 ) return 0;
    else if ( sscanf( params, "s[90]", msg ) ) return SendUsage( playerid, "/c [MESSAGE]" );
	else if ( textContainsIP( msg ) ) return SendServerMessage( playerid, "Please do not advertise." );
    else
	{
		foreach(new councilid : Player)
			if ( p_AdminLevel[ councilid ] >= 5 || IsPlayerUnderCover( councilid ) )
				SendClientMessageFormatted( councilid, -1, "{00CCFF}<Council Chat> %s(%d):"COL_GREY" %s", ReturnPlayerName( playerid ), playerid, msg );
	}
	return 1;
}

CMD:creategarage( playerid, params[ ] )
{
    new
		pID, cost;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "dU(-1)", cost, pID ) ) return SendUsage( playerid, "/creategarage [COST] [PLAYER_ID (optional)]" );
	else if ( ! IsPlayerServerMaintainer( playerid ) && ! IsPlayerConnected( pID ) && cost < 50000 ) return SendError( playerid, "You must specify a player for garages under $50,000." );
	else if ( cost < 100 ) return SendError( playerid, "The price must be located above 100 dollars." );
	else
	{
		mysql_format(
			dbHandle, szBigString, sizeof( szBigString ),
			"SELECT * FROM `NOTES` WHERE (`NOTE` LIKE '{FFDC2E}V.I.P Garage%%' ) AND USER_ID=%d AND `DELETED` IS NULL LIMIT 0,1",
			IsPlayerConnected( pID ) ? GetPlayerAccountID( pID ) : 0
		);
		mysql_tquery( dbHandle, szBigString, "OnAdminCreateGarage", "ddd", playerid, pID, cost );
	}
	return 1;
}

thread OnAdminCreateGarage( playerid, targetid, cost )
{
	new
		num_rows = cache_get_row_count( );

	// if there is a note or the player is a maintainer
	if ( IsPlayerServerMaintainer( playerid ) || num_rows || cost >= 50000 )
	{
		new
			noteid = -1; // incase the lead maintainer makes it anyway

		// remove the note if there is one
		if ( num_rows )
		{
			// get the first note
			noteid = cache_get_field_content_int( 0, "ID", dbHandle );

			// remove the note
			SaveToAdminLog( playerid, noteid, "consumed player's note" );
			mysql_single_query( sprintf( "UPDATE `NOTES` SET `DELETED`=%d WHERE `ID`=%d", GetPlayerAccountID( playerid ), noteid ) );
		}

		static
			Float: X, Float: Y, Float: Z, Float: Angle, iVehicle, iTmp;

		// proceed by creating the garage
		if ( !( iVehicle = GetPlayerVehicleID( playerid ) ) ) return SendError( playerid, "You are not in any vehicle." );
		if ( GetVehiclePos( iVehicle, X, Y, Z ) && GetVehicleZAngle( iVehicle, Angle ) && ( iTmp = CreateGarage( 0, cost, 0, X, Y, Z, Angle ) != -1 ) ) {
			if ( IsPlayerConnected( targetid ) ) {
				SaveToAdminLogFormatted( playerid, iTmp, "created garage (garage id %d) for %s (acc id %d, note id %d)", iTmp, ReturnPlayerName( targetid  ), p_AccountID[ targetid  ], noteid );
				SendClientMessageFormatted( playerid, -1, ""COL_PINK"[GARAGE]"COL_WHITE" You have created a garage in the name of %s(%d).", ReturnPlayerName( targetid  ), targetid  );
				AddAdminLogLineFormatted( "%s(%d) has created a garage for %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( targetid ), targetid );
			} else {
				SaveToAdminLogFormatted( playerid, iTmp, "created garage (garage id %d)", iTmp );
				SendClientMessageFormatted( playerid, -1, ""COL_PINK"[GARAGE]"COL_WHITE" You have created a garage." );
				AddAdminLogLineFormatted( "%s(%d) has created a house", ReturnPlayerName( playerid ), playerid );
			}
		} else {
			SendClientMessage( playerid, -1, ""COL_PINK"[GARAGE]"COL_WHITE" Unable to create a garage due to a unexpected error." );
		}
	}
	else
	{
		SendError( playerid, "This user does not have a V.I.P Garage note." );
	}
	return 1;
}

CMD:destroygarage( playerid, params[ ] )
{
	new
	    iGarage
	;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", iGarage ) ) return SendUsage( playerid, "/destroygarage [GARAGE_ID]" );
	else if ( iGarage < 0 || iGarage >= MAX_GARAGES ) return SendError( playerid, "Invalid Garage ID." );
	else if ( !Iter_Contains( garages, iGarage ) ) return SendError( playerid, "Invalid Garage ID." );
	else
	{
		SaveToAdminLog( playerid, iGarage, "destroy garage" );
		format( szBigString, sizeof( szBigString ), "[DG] [%s] %s | %d | %d\r\n", getCurrentDate( ), ReturnPlayerName( playerid ), g_garageData[ iGarage ] [ E_OWNER_ID ], iGarage );
	    AddFileLogLine( "log_garages.txt", szBigString );
		AddAdminLogLineFormatted( "%s(%d) has deleted a garage", ReturnPlayerName( playerid ), playerid );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[GARAGE]"COL_WHITE" You have destroyed the garage ID %d.", iGarage );
	    DestroyGarage( iGarage );
	}
	return 1;
}

CMD:connectsong( playerid, params[ ] )
{
	new
		szURL[ 128 ];

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "s[128]", szURL ) ) return SendUsage( playerid, "/connectsong [SONG_URL]" );
	else
	{
		SaveToAdminLogFormatted( playerid, 0, "updated connection song to %s", szURL );
		SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has set the connection song to: "COL_GREY"%s", ReturnPlayerName( playerid ), playerid, szURL );
		UpdateServerVariable( "connectsong", 0, 0.0, szURL, GLOBAL_VARTYPE_STRING );
	}
	return 1;
}

CMD:discordurl( playerid, params[ ] )
{
	new
		szURL[ 128 ];

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "s[128]", szURL ) ) return SendUsage( playerid, "/discordurl [DISCORD_URL]" );
	else
	{
		SaveToAdminLogFormatted( playerid, 0, "updated discord url to %s", szURL );
		SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has set the discord url to: "COL_GREY"%s", ReturnPlayerName( playerid ), playerid, szURL );
		UpdateServerVariable( "discordurl", 0, 0.0, szURL, GLOBAL_VARTYPE_STRING );
	}
	return 1;
}

CMD:creategate( playerid, params[ ] )
{
	new
		pID, password[ 8 ], model, Float: speed, Float: range,
		Float: X, Float: Y, Float: Z
	;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "udffs[8]", pID, model, speed, range, password ) ) return SendUsage( playerid, "/creategate [PLAYER_ID] [MODEL_ID] [SPEED] [RANGE] [PASSWORD]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( model < 0 || model > 20000 ) return SendError( playerid, "Invalid Object Model." );
	else if ( speed < 1.0 || speed > 100.0 ) return SendError( playerid, "Please specify a speed between 1.0 and 100.0." );
	else if ( range < 2.5 || speed > 500.0 ) return SendError( playerid, "Please specify a range between 2.5 and 500.0." );
	else if ( strlen( password ) > 4 ) return SendError( playerid, "Password length can be only a maximum of four characters." );
	else
	{
		GetXYInFrontOfPlayer( playerid, X, Y, Z, 5.0 );
		new iTmp = CreateGate( pID, password, model, speed, range, X, Y, Z, 0.0, 0.0, 0.0 );
	    if ( iTmp != -1 ) {
			SaveToAdminLog( playerid, iTmp, "created gate" );
	    	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[GATE]"COL_WHITE" You have created a gate taking place of ID: %d", iTmp );
	    }
		else SendClientMessage( playerid, -1, ""COL_PINK"[GATE]"COL_WHITE" Unable to create a gate due to a unexpected error." );
	}
	return 1;
}

CMD:editgate( playerid, params[ ] )
{
	new
		gID;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", gID ) ) return SendUsage( playerid, "/editgate [GATE_ID]" );
	else if ( ! Gate_Exists( gID ) ) return SendError( playerid, "Invalid Gate ID" );
	else
	{
		SetPlayerEditGate( playerid, gID );
		SaveToAdminLog( playerid, gID, "editing gate" );
	}
	return 1;
}

CMD:acunban( playerid, params[ ] )
{
	new
		address[ 16 ];

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf(params, "s[16]", address ) ) SendUsage( playerid, "/acunban [IP_ADDRESS]" );
	else if ( !textContainsIP( params ) ) return SendError( playerid, "This is not an IP address." );
	else
	{
 		UnBlockIpAddress( address );
		SetServerRule( "unbanip", address );
		SetServerRule( "reloadbans", "" );
		SaveToAdminLogFormatted( playerid, 0, "acunban %s", address );
	 	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[AC UNBAN]{FFFFFF} You've unbanned %s from the anti-cheat.", address );
	 	AddAdminLogLineFormatted( "%s(%d) has un-banned %s", ReturnPlayerName( playerid ), playerid, address );
	}
	return 1;
}

CMD:safeisbugged( playerid, params[ ] )
{
 	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	new
        Float: distance = 99999.99,
		robberyid = getClosestRobberySafe( playerid, distance )
	;

	if ( robberyid != INVALID_OBJECT_ID )
	{
		SendClientMessage( playerid, COLOR_GOLD, "___ SAFE DATA ___");
		SendClientMessageFormatted( playerid, -1, "OPEN : %d | ROBBED : %d | C4 : %d | DRILL : %d | DRILL PLACER : %d | DRILL EFFECT : %d",
			g_robberyData[ robberyid ] [ E_OPEN ], g_robberyData[ robberyid ] [ E_ROBBED ], g_robberyData[ robberyid ] [ E_C4 ],
			g_robberyData[ robberyid ] [ E_DRILL ], g_robberyData[ robberyid ] [ E_DRILL_PLACER ], g_robberyData[ robberyid ] [ E_DRILL_EFFECT ] );

		SendClientMessageFormatted( playerid, -1, "REPLENISH : %d | RAW TIMESTAMP : %d | CURRENT TIME: %d | ID : %d | NAME : %s",
			g_robberyData[ robberyid ] [ E_ROB_TIME ] - g_iTime, g_robberyData[ robberyid ] [ E_ROB_TIME ], g_iTime, robberyid, g_robberyData[ robberyid ] [ E_NAME ] );
	}
	else return SendError( playerid, "You're not near any safe." );
	return 1;
}

CMD:replenishsafe( playerid, params[ ] )
{
	new
		rID;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", rID ) ) return SendUsage( playerid, "/replenishsafe [SAFE_ID]" );
	else if (!Iter_Contains(RobberyCount, rID)) return SendError( playerid, "This is an invalid Safe ID." );
	else
	{
		printf( "[GM:ADMIN] %s has replenished %d! (Success: %d)", ReturnPlayerName( playerid ), rID, setSafeReplenished( rID ) );

		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You've replenished Safe ID %d: "COL_GREY"%s"COL_WHITE".", rID, g_robberyData[ rID ] [ E_NAME ] );
	}
	return 1;
}

CMD:autovehrespawn( playerid, params[ ] )
{
	#if defined _vsync_included
	    #pragma unused rl_AutoVehicleRespawner
		SendError( playerid, "This feature is disabled as protection for car warping is enabled (VehicleSync)." );
	#else
		new tick;
		if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
		else if ( sscanf( params, "d", tick ) ) return SendUsage( playerid, "/autovehrespawn [MILLISECONDS (0 = DISABLE)]" );
		else if ( tick != 0 && tick < 2500 ) return SendError( playerid, "The respawn tick cannot be less than 2500ms." );
		else
		{
	        if ( tick == 0 ) {
				KillTimer( rl_AutoVehicleRespawner );
				rl_AutoVehicleRespawner = 0xFF;
				SendServerMessage( playerid, "Auto vehicle spawner disabled." );
				return 1;
			}

			KillTimer( rl_AutoVehicleRespawner );
			rl_AutoVehicleRespawner = SetTimer( "autoVehicleSpawn", tick, true );

			SaveToAdminLogFormatted( playerid, 0, "autovehrespawn %d", tick );
	        SendClientMessageFormatted( playerid, COLOR_WHITE, ""COL_GREY"[SERVER]"COL_WHITE" The auto vehicle spawner has been set to %dms.", tick );
		}
	#endif
	return 1;
}

function autoVehicleSpawn( )
{
    for( new i; i < MAX_VEHICLES; i++ ) if ( IsValidVehicle( i ) )
   	{
		if ( IsVehicleOccupied( i, .include_vehicle_interior = true ) == -1 )
		{
			if ( g_buyableVehicle{ i } == true )
				RespawnBuyableVehicle( i );
			else
				SetVehicleToRespawn( i );
    	}
	}
	return 1;
}

/*CMD:megaban( playerid, params [ ] )
{
    new
	    pID,
		reason[ 50 ]
	;
	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "uS(No Reason)[50]", pID, reason ) ) SendUsage( playerid, "/megaban [PLAYER_ID] [REASON]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	//else if ( pID == playerid ) return SendError( playerid, "You cannot ban yourself." );
    //else if ( p_AdminLevel[ playerid ] < p_AdminLevel[ pID ] ) return SendError( playerid, "This player has a higher administration level than you." );
	else
	{
		SaveToAdminLogFormatted( playerid, 0, "megaban %s (reason: %s)", ReturnPlayerName( pID ), reason );
        AddAdminLogLineFormatted( "%s(%d) has mega-banned %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
	    SendGlobalMessage( -1, ""COL_PINK"[ADMIN]{FFFFFF} %s has mega-banned %s(%d) "COL_GREEN"[REASON: %s]", ReturnPlayerName( playerid ), ReturnPlayerName( pID ), pID, reason );
		BanPlayerISP( pID );
	}
	return 1;
}*/

CMD:achangename( playerid, params[ ] )
{
	new
	    pID,
	    nName[ 24 ],
	    szQuery[ 100 ]
	;
	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "us[24]", pID, nName ) ) return SendUsage( playerid, "/achangename [PLAYER_ID] [NEW_NAME]" );
	else if ( !IsPlayerConnected( pID ) ) SendError( playerid, "Invalid Player ID." );
	else if ( !isValidPlayerName( nName ) ) return SendError( playerid, "Invalid Name Character." );
	else if ( p_OwnedHouses[ pID ] > 0 || NovicHotel_GetPlayerApartments( pID ) > 0 ) return SendError( playerid, "This player has a house and/or apartment." ), SendError( pID, ""COL_ORANGE"In order to change your name, you must sell your houses and/or apartment.");
	else
	{
	    format( szQuery, sizeof( szQuery ), "SELECT `NAME` FROM `USERS` WHERE `NAME` = '%s'", mysql_escape( nName ) );
	  	mysql_function_query( dbHandle, szQuery, true, "OnAdminChangePlayerName", "dds", playerid, pID, nName );
	}
	return 1;
}

thread OnAdminChangePlayerName( playerid, pID, nName[ ] )
{
	new
	    rows, fields
	;
	cache_get_data( rows, fields );

	if ( !rows )
	{
	 	mysql_single_query( sprintf( "UPDATE `USERS` SET `NAME` = '%s' WHERE `NAME` = '%s'", mysql_escape( nName ), mysql_escape( ReturnPlayerName( pID ) ) ) );
	 	mysql_single_query( sprintf( "INSERT INTO `NAME_CHANGES`(`USER_ID`,`ADMIN_ID`,`NAME`) VALUES (%d,%d,'%s')", p_AccountID[ pID ], p_AccountID[ playerid ], mysql_escape( ReturnPlayerName( pID ) ) ) );

		SaveToAdminLogFormatted( playerid, 0, "changename %s to %s", ReturnPlayerName( pID ), nName );
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have changed %s(%d)'s name to %s!", ReturnPlayerName( pID ), pID, nName );
		SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" Your name has been changed to %s by %s(%d)!", nName, ReturnPlayerName( playerid ), playerid );
        AddAdminLogLineFormatted( "%s(%d) has changed %s(%d)'s name to %s", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, nName );

		SetPlayerName( pID, nName );

    	// Update New Things
    	foreach(new g : garages)
    		if ( g_garageData[ g ] [ E_OWNER_ID ] == p_AccountID[ playerid ] )
    			UpdateGarageTitle( g );
	}
	else SendError( playerid, "This name is taken already." );
	return 1;
}

CMD:unbanip( playerid, params[ ] )
{
	new
		address[16],
		Query[70]
	;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if (sscanf(params, "s[16]", address)) SendUsage(playerid, "/unbanip [IP_ADDRESS]");
	else
	{
		format( Query, sizeof( Query ), "SELECT `IP` FROM `BANS` WHERE `IP` = '%s'", mysql_escape( address ) );
		mysql_function_query( dbHandle, Query, true, "OnPlayerUnbanIP", "dds", playerid, 0, address );
	}
	return 1;
}

thread OnPlayerUnbanIP( playerid, irc, address[ ] )
{
	new
	    rows, fields
	;
	cache_get_data( rows, fields );
	if ( rows )
	{
    	if ( !irc )
    	{
			SaveToAdminLogFormatted( playerid, 0, "unbanip %s", address );
    		AddAdminLogLineFormatted( "%s(%d) has un-banned IP %s", ReturnPlayerName( playerid ), playerid, address );
	 		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]{FFFFFF} IP %s has been un-banned from the server.", address );
		}
		else
		{
    		DCC_SendChannelMessageFormatted( discordLogChan, "**[DISCORD LOG]** IP %s has been un-banned from the server.", address );
		}
		format( szNormalString, sizeof( szNormalString ), "DELETE FROM `BANS` WHERE `IP` = '%s'", mysql_escape( address ) );
		mysql_single_query( szNormalString );
	}
	else {
		if ( !irc ) SendError(playerid, "This IP Address is not recognised!");
	}
	return 1;
}

CMD:unban( playerid, params[ ] )
{
	new
		player[24],
		Query[70]
	;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "s[24]", player ) ) SendUsage( playerid, "/unban [NAME]" );
	else
	{
		format( Query, sizeof( Query ), "SELECT `NAME` FROM `BANS` WHERE `NAME` = '%s'", mysql_escape( player ) );
		mysql_function_query( dbHandle, Query, true, "OnPlayerUnbanPlayer", "dds", playerid, 0, player );
	}
	return 1;
}

thread OnPlayerUnbanPlayer( playerid, irc, player[ ] )
{
	new
	    rows, fields
	;
	cache_get_data( rows, fields );
	if ( rows )
	{
   	 	if ( !irc ) AddAdminLogLineFormatted( "%s(%d) has un-banned %s", ReturnPlayerName( playerid ), playerid, player );
		else
		{
			format(szNormalString, sizeof(szNormalString),"**[DISCORD LOG]** %s has been un-banned from the server.", player);
    		DCC_SendChannelMessage( discordLogChan, szNormalString );
		}
		format(szNormalString, sizeof(szNormalString), "DELETE FROM `BANS` WHERE `NAME` = '%s'", mysql_escape( player ) );
		mysql_single_query( szNormalString );

		SaveToAdminLogFormatted( playerid, 0, "unban %s", player );
	 	SendClientMessageToAllFormatted(-1, ""COL_PINK"[ADMIN]{FFFFFF} \"%s\" has been un-banned from the server.", player);
	}
	else {
		if ( !irc ) SendError(playerid, "This player is not recognised!");
	}
	return 1;
}

CMD:doublexp( playerid, params[ ] )
{
	//g_doubleXP
	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );

	UpdateServerVariable( "doublexp", IsDoubleXP( ) ? 0 : 1, 0.0, "", GLOBAL_VARTYPE_INT );

	if ( IsDoubleXP( ) )
	{
		TextDrawShowForAll( g_DoubleXPTD );
		GameTextForAll( "~w~DOUBLE ~y~~h~XP~g~~h~~h~ ACTIVATED!", 6000, 3 );
	}
	else
	{
		TextDrawHideForAll( g_DoubleXPTD );
		GameTextForAll( "~w~DOUBLE ~y~~h~XP~r~~h~~h~ DEACTIVATED!", 6000, 3 );
	}

	SaveToAdminLogFormatted( playerid, 0, "doublexp %s", IsDoubleXP( ) ? ("toggled") : ("un-toggled") );
    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have %s double XP!", IsDoubleXP( ) ? ("toggled") : ("un-toggled") );
	AddAdminLogLineFormatted( "%s(%d) has %s double xp", ReturnPlayerName( playerid ), playerid, IsDoubleXP( ) ? ("toggled") : ("un-toggled") );
	return 1;
}

CMD:toggleviewpm( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 5 && !IsPlayerUnderCover( playerid ) ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    p_ToggledViewPM{ playerid } = !p_ToggledViewPM{ playerid };
    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have %s viewing peoples private messages.", p_ToggledViewPM{ playerid } == true ? ("toggled") : ("un-toggled") );
    if ( !IsPlayerUnderCover( playerid ) ) {
		AddAdminLogLineFormatted( "%s(%d) has %s viewing pm's", ReturnPlayerName( playerid ), playerid, p_ToggledViewPM{ playerid } == true ? ("toggled") : ("un-toggled") );
    }
 	return 1;
}

CMD:respawnallv( playerid, params[ ] )
{
 	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else
	{
	    for( new i; i < MAX_VEHICLES; i++ ) if ( IsValidVehicle( i ) ) {
	    	#if defined __cnr__chuffsec
	    	if ( g_secureTruckVehicle == i ) continue;
	    	#endif
			SetVehicleToRespawn( i );
		}
		AddAdminLogLineFormatted( "%s(%d) has respawned all vehicles", ReturnPlayerName( playerid ), playerid );
		SendServerMessage( playerid, "You have respawned all vehicles." );
	}
	return 1;
}

#if defined __cnr__chuffsec
CMD:reconnectchuff( playerid, params[ ] )
{
 	if ( p_AdminLevel[ playerid ] < 5 )
 		return SendError( playerid, ADMIN_COMMAND_REJECT );

 	new
 		chuffsecid = GetSecurityDriverPlayer( );

 	if ( chuffsecid != INVALID_PLAYER_ID ) {
 		Kick( chuffsecid );
 	} else {
		ConnectNPC( SECURE_TRUCK_DRIVER_NAME, "secureguard" );
 	}

	AddAdminLogLineFormatted( "%s(%d) has attempted to reconnect %s", ReturnPlayerName( playerid ), playerid, SECURE_TRUCK_DRIVER_NAME );
	SendServerMessage( playerid, "You are now attempting to reconnect %s.", SECURE_TRUCK_DRIVER_NAME );
	return 1;
}
#endif

#if defined __cnr__features__bribes
CMD:createbribe( playerid, params[ ] )
{
    new
		Float: X, Float: Y, Float: Z
	;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else
	{
		GetPlayerPos( playerid, X, Y, Z );
	    new iTmp = CreateBribe( X, Y, Z );
		AddAdminLogLineFormatted( "%s(%d) has created a bribe", ReturnPlayerName( playerid ), playerid );
	    if ( iTmp != -1 ) {
			SaveToAdminLog( playerid, iTmp, "created bribe" );
	    	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[BRIBE]"COL_WHITE" You have created a bribe taking place of ID: %d.", iTmp );
	    }
		else SendClientMessage( playerid, -1, ""COL_PINK"[BRIBE]"COL_WHITE" Unable to create a bribe due to a unexpected error." );
	}
	return 1;
}
#endif

#if defined __cnr__features__bribes
CMD:destroybribe( playerid, params[ ] )
{
	new
	    bID
	;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", bID ) ) return SendUsage( playerid, "/destroybribe [BRIBE_ID]" );
	else if ( bID < 0 || bID > MAX_BRIBES ) return SendError( playerid, "Invalid Bribe ID." );
	else if ( ! Bribe_IsValid( bID ) ) return SendError( playerid, "Invalid Bribe ID." );
	else
	{
		SaveToAdminLog( playerid, bID, "destroyed bribe" );
		AddAdminLogLineFormatted( "%s(%d) has deleted a bribe", ReturnPlayerName( playerid ), playerid );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[BRIBE]"COL_WHITE" You have destroyed a bribe pickup which was the ID of %d.", bID);
	    DestroyBribe( bID );
	}
	return 1;
}
#endif

CMD:createcar( playerid, params[ ] )
{
    new
		vName[ 24 ], pID, iModel;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "us[24]", pID, vName ) ) return SendUsage( playerid, "/createcar [PLAYER_ID] [VEHICLE_NAME]" );
	else if ( !IsPlayerConnected( pID ) ) SendError( playerid, "Invalid Player ID." );
	else if ( p_OwnedVehicles[ pID ] >= GetPlayerVehicleSlots( pID ) ) return SendError( playerid, "This player has too many vehicles." );
	else
	{
	    if ( ( iModel = GetVehicleModelFromName( vName ) ) != -1 ) {
			mysql_format(
				dbHandle, szBigString, sizeof( szBigString ),
				"SELECT * FROM `NOTES` WHERE (`NOTE` LIKE '{FFDC2E}V.I.P Vehicle%%' ) AND USER_ID=%d AND `DELETED` IS NULL LIMIT 0,1",
				GetPlayerAccountID( pID )
			);
			mysql_tquery( dbHandle, szBigString, "OnAdminCreateVehicle", "ddd", playerid, pID, iModel );
	    }
		else SendError( playerid, "Invalid Vehicle Model." );
	}
	return 1;
}

thread OnAdminCreateVehicle( playerid, targetid, modelid )
{
	new
		num_rows = cache_get_row_count( );

	// if there is a note or the player is a maintainer
	if ( IsPlayerServerMaintainer( playerid ) || num_rows )
	{
		new
			noteid = -1; // incase the lead maintainer makes it anyway

		// remove the note if there is one
		if ( num_rows )
		{
			// get the first note
			noteid = cache_get_field_content_int( 0, "ID", dbHandle );

			// remove the note
			SaveToAdminLog( playerid, noteid, "consumed player's note" );
			mysql_single_query( sprintf( "UPDATE `NOTES` SET `DELETED`=%d WHERE `ID`=%d", GetPlayerAccountID( playerid ), noteid ) );
		}

		static
			Float: X, Float: Y, Float: Z, Float: Angle, iTmp;

		// proceed by creating the vehicle
		GetPlayerPos( playerid, X, Y, Z );
		GetPlayerFacingAngle( playerid, Angle );

		if ( ( iTmp = CreateBuyableVehicle( targetid, modelid, 0, 0, X, Y, Z, Angle, 1337 ) ) != -1 ) {
			SaveToAdminLogFormatted( playerid, iTmp, "created car (model id %d) for %s (acc id %d, note id %d)", modelid, ReturnPlayerName( targetid  ), p_AccountID[ targetid  ], noteid );
			SendClientMessageFormatted( playerid, -1, ""COL_PINK"[VEHICLE]"COL_WHITE" You have created a vehicle in the name of %s(%d).", ReturnPlayerName( targetid  ), targetid  );
			AddAdminLogLineFormatted( "%s(%d) has created a vehicle for %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( targetid  ), targetid  );
			PutPlayerInVehicle( playerid, g_vehicleData[ targetid  ] [ iTmp ] [ E_VEHICLE_ID ], 0 );
		} else {
			SendClientMessage( playerid, -1, ""COL_PINK"[VEHICLE]"COL_WHITE" Unable to create a vehicle due to a unexpected error." );
		}
	}
	else
	{
		SendError( playerid, "This user does not have a V.I.P Vehicle note." );
	}
	return 1;
}

CMD:destroycar( playerid, params[ ] )
{
	new
	   	ownerid, slotid
	;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You must be in a vehicle to use this command." );
	else
	{
		new v = getVehicleSlotFromID( GetPlayerVehicleID( playerid ), ownerid, slotid );

		if ( v == -1 ) return SendError( playerid, "This vehicle doesn't look like it can be destroyed. (0xAA)" );
		if ( g_vehicleData[ ownerid ] [ slotid ] [ E_CREATED ] == false ) return SendError( playerid, "This vehicle doesn't look like it can be destroyed. (0xAF)" );

		SaveToAdminLogFormatted( playerid, slotid, "destroycar (model id %d) for %s (acc id %d)", g_vehicleData[ slotid ] [ slotid ] [ E_MODEL ], ReturnPlayerName( ownerid ), p_AccountID[ ownerid ] );
		AddAdminLogLineFormatted( "%s(%d) has deleted a car", ReturnPlayerName( playerid ), playerid );
		format( szBigString, sizeof( szBigString ), "[DC] [%s] %s | %s | %s\r\n", getCurrentDate( ), ReturnPlayerName( playerid ), ReturnPlayerName( ownerid ), GetVehicleName( GetVehicleModel( g_vehicleData[ ownerid ] [ slotid ] [ E_VEHICLE_ID ] ) ) );
        AddFileLogLine( "log_destroycar.txt", szBigString );

		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[VEHICLE]"COL_WHITE" You have destroyed a "COL_GREY"%s"COL_WHITE" owned by "COL_GREY"%s"COL_WHITE".", GetVehicleName( GetVehicleModel( g_vehicleData[ ownerid ] [ slotid ] [ E_VEHICLE_ID ] ) ), ReturnPlayerName( ownerid ) );
	   	DestroyBuyableVehicle( ownerid, slotid );
	}
	return 1;
}

CMD:stripcarmods( playerid, params[ ] )
{
	new
	   	ownerid, slotid
	;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You must be in a vehicle to use this command." );
	else
	{
		new v = getVehicleSlotFromID( GetPlayerVehicleID( playerid ), ownerid, slotid );

		if ( v == -1 ) return SendError( playerid, "This vehicle doesn't look like it can be stripped of its components. (0xAA)" );
		if ( g_vehicleData[ ownerid ] [ slotid ] [ E_CREATED ] == false ) return SendError( playerid, "This vehicle doesn't look like it can be destroyed. (0xAF)" );

		SaveToAdminLogFormatted( playerid, slotid, "stripcarmods on %s (acc id %d, model id %d)", ReturnPlayerName( ownerid ), p_AccountID[ ownerid ], g_vehicleData[ ownerid ] [ slotid ] [ E_MODEL ] );
		AddAdminLogLineFormatted( "%s(%d) has deleted a car's mods", ReturnPlayerName( playerid ), playerid );
		format( szBigString, sizeof( szBigString ), "[DC_MODS] [%s] %s | %s | %s\r\n", getCurrentDate( ), ReturnPlayerName( playerid ), ReturnPlayerName( ownerid ), GetVehicleName( GetVehicleModel( g_vehicleData[ ownerid ] [ slotid ] [ E_VEHICLE_ID ] ) ) );
        AddFileLogLine( "log_destroycar.txt", szBigString );

		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[VEHICLE]"COL_WHITE" You have removed the mods of %s's "COL_GREY"%s"COL_WHITE".", ReturnPlayerName( ownerid ), GetVehicleName( GetVehicleModel( g_vehicleData[ ownerid ] [ slotid ] [ E_VEHICLE_ID ] ) ) );
		DestroyVehicleCustomComponents( ownerid, slotid, .destroy_db = true );
	}
	return 1;
}

CMD:replacecar( playerid, params[ ] )
{
	new
		vName[ 24 ], iModel;

	if ( sscanf( params, "s[24]", vName ) ) return SendUsage(playerid, "/replacecar [VEHICLE_NAME]");

	if ( p_AdminLevel[ playerid ] < 5 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	if ( !IsPlayerInAnyVehicle( playerid ) )
	    return SendError( playerid, "You are not in any vehicle." );

	if ( g_buyableVehicle{ GetPlayerVehicleID( playerid ) } == false )
		return SendError( playerid, "This vehicle isn't a buyable vehicle." );
	if ( ( iModel = GetVehicleModelFromName( vName ) ) != -1 ) {

	new
		oldmodel, ownerid, slotid, vehicleid = GetPlayerVehicleID( playerid ),
		v = getVehicleSlotFromID( vehicleid, ownerid, slotid ),
		Float: X, Float: Y, Float: Z, Float: Angle
	;

	if ( v == -1 ) return SendError( playerid, "This vehicle doesn't look like it can be replaced. (0xAA)" );
	if ( g_vehicleData[ ownerid ] [ slotid ] [ E_CREATED ] == false ) return SendError( playerid, "This vehicle doesn't look like it can be replaced. (0xAF)" );

	GetVehiclePos( vehicleid, X, Y, Z );
	GetVehicleZAngle( vehicleid, Angle );

	oldmodel = GetVehicleModel( vehicleid );

	g_vehicleData[ ownerid ] [ slotid ] [ E_MODEL ] = iModel;

	PutPlayerInVehicle( playerid, RespawnBuyableVehicle( vehicleid, playerid ), 0 );
	SaveVehicleData( ownerid, slotid );

	SendClientMessage( playerid, -1, ""COL_GREY"[VEHICLE]"COL_WHITE" You have replaced model of this vehicle via administration." );
	SaveToAdminLogFormatted( playerid, slotid, "replaced car on %s (acc id %d, model id %d)", ReturnPlayerName( ownerid ), p_AccountID[ ownerid ], g_vehicleData[ ownerid ] [ slotid ] [ E_MODEL ] );
	AddAdminLogLineFormatted( "%s(%d) changed %s(%d)'s vehicle from %s to %s", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( ownerid ), ownerid, GetVehicleName( oldmodel ), GetVehicleName( iModel ) );
	}
	else
	{
		SendError( playerid, "Invalid Vehicle Model." );
	}
	return 1;
}

CMD:createhouse( playerid, params[ ] )
{
    new
		pID, cost;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "dU(-1)", cost, pID ) ) return SendUsage( playerid, "/createhouse [COST] [PLAYER_ID (optional)]" );
	else if ( ! IsPlayerServerMaintainer( playerid ) && ! IsPlayerConnected( pID ) && cost < 50000 ) return SendError( playerid, "You must specify a player for homes under $50,000." );
	else if ( cost < 100 ) return SendError( playerid, "The price must be located above 100 dollars." );
	else
	{
		mysql_format(
			dbHandle, szBigString, sizeof( szBigString ),
			"SELECT * FROM `NOTES` WHERE (`NOTE` LIKE '{FFDC2E}V.I.P House%%' ) AND USER_ID=%d AND `DELETED` IS NULL LIMIT 0,1",
			IsPlayerConnected( pID ) ? GetPlayerAccountID( pID ) : 0
		);
		mysql_tquery( dbHandle, szBigString, "OnAdminCreateHouse", "ddd", playerid, pID, cost );
	}
	return 1;
}

thread OnAdminCreateHouse( playerid, targetid, cost )
{
	new
		num_rows = cache_get_row_count( );

	// if there is a note or the player is a maintainer
	if ( IsPlayerServerMaintainer( playerid ) || num_rows || cost >= 50000 )
	{
		new
			noteid = -1; // incase the lead maintainer makes it anyway

		// remove the note if there is one
		if ( num_rows )
		{
			// get the first note
			noteid = cache_get_field_content_int( 0, "ID", dbHandle );

			// remove the note
			SaveToAdminLog( playerid, noteid, "consumed player's note" );
			mysql_single_query( sprintf( "UPDATE `NOTES` SET `DELETED`=%d WHERE `ID`=%d", GetPlayerAccountID( playerid ), noteid ) );
		}

		static
			Float: X, Float: Y, Float: Z, iTmp;

		// proceed by creating the house
		if ( GetPlayerPos( playerid, X, Y, Z ) && ( iTmp = CreateHouse( "Home", cost, X, Y, Z ) ) != -1 ) {
			if ( IsPlayerConnected( targetid ) ) {
				SaveToAdminLogFormatted( playerid, iTmp, "created house (house id %d) for %s (acc id %d, note id %d)", iTmp, ReturnPlayerName( targetid  ), p_AccountID[ targetid  ], noteid );
				SendClientMessageFormatted( playerid, -1, ""COL_PINK"[HOUSE]"COL_WHITE" You have created a house in the name of %s(%d).", ReturnPlayerName( targetid  ), targetid  );
				AddAdminLogLineFormatted( "%s(%d) has created a house for %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( targetid ), targetid );
			} else {
				SaveToAdminLogFormatted( playerid, iTmp, "created house (house id %d)", iTmp );
				SendClientMessageFormatted( playerid, -1, ""COL_PINK"[HOUSE]"COL_WHITE" You have created a house." );
				AddAdminLogLineFormatted( "%s(%d) has created a house", ReturnPlayerName( playerid ), playerid );
			}
		} else {
			SendClientMessage( playerid, -1, ""COL_PINK"[HOUSE]"COL_WHITE" Unable to create a house due to a unexpected error." );
		}
	}
	else
	{
		SendError( playerid, "This user does not have a V.I.P House note." );
	}
	return 1;
}

CMD:destroyhouse( playerid, params[ ] )
{
	new
	    hID
	;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", hID ) ) return SendUsage( playerid, "/destroyhouse [HOUSE_ID]" );
	else if ( hID < 0 || hID > MAX_HOUSES ) return SendError( playerid, "Invalid house ID." );
	else if ( ! Iter_Contains( houses, hID ) ) return SendError( playerid, "Invalid house ID." );
	else
	{
		SaveToAdminLog( playerid, hID, "destroy house" );
		format( szBigString, sizeof( szBigString ), "[DH] [%s] %s | %s | %d\r\n", getCurrentDate( ), ReturnPlayerName( playerid ), g_houseData[ hID ][ E_OWNER ], hID );
	    AddFileLogLine( "log_houses.txt", szBigString );
		AddAdminLogLineFormatted( "%s(%d) has deleted a house", ReturnPlayerName( playerid ), playerid );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[HOUSE]"COL_WHITE" You have destroyed \"%s\" which was the ID of %d.", g_houseData[ hID ] [ E_HOUSE_NAME ], hID );
	    DestroyHouse( hID );
	}
	return 1;
}

CMD:hadminsell( playerid, params[ ] )
{
	new
	    hID
	;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", hID ) ) return SendUsage( playerid, "/hadminsell [HOUSE_ID]" );
	else if ( hID < 0 || hID > MAX_HOUSES ) return SendError( playerid, "Invalid house ID." );
	else if ( ! Iter_Contains( houses, hID ) ) return SendError( playerid, "Invalid house ID." );
	else if ( strmatch( g_houseData[ hID ] [ E_OWNER ], "No-one" ) ) return SendError( playerid, "This house is not owned by anyone." );
	else
	{
	    SetHouseForAuction( hID );
		SaveToAdminLog( playerid, hID, "hadminsell" );
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[HOUSE]"COL_WHITE" You made "COL_GREY"House ID %d"COL_WHITE" go for sale.", hID );
	}
	return 1;
}

CMD:unforceac( playerid, params[ ] )
{
    new
		player[ MAX_PLAYER_NAME ],
		Query[ 70 ];

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "s[24]", player ) ) SendUsage( playerid, "/unforceac [PLAYER_NAME]" );
	else
	{
		new pID = GetPlayerIDFromName( player );

		mysql_format( dbHandle, Query, sizeof( Query ), "SELECT `NAME` FROM `USERS` WHERE `NAME` = '%e'", player );

		if ( ! IsPlayerConnected( pID ) )
		{
			mysql_tquery( dbHandle, Query, "OnPlayerUnforceAC", "dsdd", playerid, player, -1, true );
		}
		else
		{
			mysql_tquery( dbHandle, Query, "OnPlayerUnforceAC", "dsdd", playerid, player, pID, false );
		}
	}
    return 1;
}

thread OnPlayerUnforceAC( playerid, player[ ], pID, bool:offline )
{
	new
		Query[ 70 ], rows = cache_get_row_count( );

	if ( !rows ) return SendError( playerid, "The database does not contain the username you are attempting to remove from forced ac." );

	if ( offline )
	{

		AddAdminLogLineFormatted( "%s(%d) has removed forced ac on %s (offline)", ReturnPlayerName( playerid ), playerid, player );

		mysql_format( dbHandle, Query, sizeof( Query ), "UPDATE `USERS` SET `FORCE_AC`=0 WHERE `NAME`='%e'", player );
		mysql_single_query( Query );

		SaveToAdminLogFormatted( playerid, 0, "Offline Unforced %s", player );
		SendClientMessageToAllFormatted( -1, ""COL_PINK"[ADMIN]{FFFFFF} \"%s\" (offline) has been unforced to use the AC on the server.", player );

	}
	else
	{

		AddAdminLogLineFormatted( "%s(%d) has removed forced ac on %s", ReturnPlayerName( playerid ), playerid, player );
		mysql_format( dbHandle, Query, sizeof( Query ), "UPDATE `USERS` SET `FORCE_AC`=0 WHERE `NAME`='%e'", ReturnPlayerName( pID ) );
		mysql_single_query( Query );

		SaveToAdminLogFormatted( playerid, 0, "Unforced %s", player );
		SendClientMessageToAllFormatted( -1, ""COL_PINK"[ADMIN]{FFFFFF} \"%s\" has been unforced to use the AC on the server.", player );
		p_forcedAnticheat[ pID ] = 0;

	}
	return 1;
}

CMD:giveboombox( playerid, params[ ] )
{
	new
		pID;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/giveboombox [PLAYER_ID]" );
	else if ( ! IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( GetPlayerBoombox( pID ) ) return SendError( playerid, "Player already has boombox in his inventory." );
	else
	{
		SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) gave you boombox.", ReturnPlayerName( playerid ), playerid );
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have given boombox to %s(%d).", ReturnPlayerName( pID ), pID );
		AddAdminLogLineFormatted( "%s(%d) has given boombox to %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
		SetPlayerBoombox( pID, true );
	}
	return 1;
}

CMD:removeboombox( playerid, params[ ] )
{
	new
		pID;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/removeboombox [PLAYER_ID]" );
	else if ( ! IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( ! GetPlayerBoombox( pID ) ) return SendError( playerid, "Player doesn't have boombox in his inventory." );
	else
	{
		SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has removed your boombox.", ReturnPlayerName( playerid ), playerid );
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have removed boombox from %s(%d).", ReturnPlayerName( pID ), pID );
		AddAdminLogLineFormatted( "%s(%d) has removed boombox from %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
		SetPlayerBoombox( pID, false );
	}
	return 1;
}