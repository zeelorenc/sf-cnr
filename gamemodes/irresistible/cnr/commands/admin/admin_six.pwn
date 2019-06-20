/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr/commands/admin/admin_six.pwn
 * Purpose: level six administrator commands (cnr)
 */

/* ** Commands ** */
CMD:e( playerid, params[ ] )
{
	new
	    msg[ 90 ]
	;

    if ( p_AdminLevel[ playerid ] < 6 ) return 0;
    else if ( sscanf( params, "s[90]", msg ) ) return SendUsage( playerid, "/e [MESSAGE]" );
	else if ( textContainsIP( msg ) ) return SendServerMessage( playerid, "Please do not advertise." );
    else
	{
		foreach(new executiveid : Player)
			if ( p_AdminLevel[ executiveid ] >= 6 )
				SendClientMessageFormatted( executiveid, -1, "{FF0000}<Executive Chat> %s(%d):"COL_GREY" %s", ReturnPlayerName( playerid ), playerid, msg );
	}
	return 1;
}

CMD:reloadeditor( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 6 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	SetServerRule( "reloadfs", "objecteditor" );
	SendClientMessage( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have successfully reloaded the object editor." );
	return 1;
}
CMD:createbusiness( playerid, params[ ] )
{
    new
		pID, cost, type;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "ddU(-1)", cost, type, pID ) ) return SendUsage( playerid, "/createhouse [COST] [TYPE] [PLAYER_ID (optional)]" );
	else if ( ! IsPlayerServerMaintainer( playerid ) && ! IsPlayerConnected( pID ) && cost < 50000 ) return SendError( playerid, "You must specify a player for business under $50,000." );
	else if ( cost < 100 ) return SendError( playerid, "The price must be located above 100 dollars." );
	else if ( ! ( 0 <= type <= 3 ) ) return SendError( playerid, "Invalid business type (Weed=0, Meth=1, Coke=2, Weapons=3)." );
	else
	{
		mysql_format(
			dbHandle, szBigString, sizeof( szBigString ),
			"SELECT * FROM `NOTES` WHERE (`NOTE` LIKE '{FFDC2E}%%Business%%') AND USER_ID=%d AND `DELETED` IS NULL LIMIT 0,1",
			IsPlayerConnected( pID ) ? GetPlayerAccountID( pID ) : 0
		);
		mysql_tquery( dbHandle, szBigString, "OnAdminCreateBusiness", "dddd", playerid, pID, cost, type );
	}
	return 1;
}

thread OnAdminCreateBusiness( playerid, targetid, cost, type )
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

		// proceed by creating the business
		if ( GetPlayerPos( playerid, X, Y, Z ) && ( iTmp = CreateBusiness( 0, "Business", cost, type, X, Y, Z ) != ITER_NONE ) ) {
			if ( IsPlayerConnected( targetid ) ) {
				SaveToAdminLogFormatted( playerid, iTmp, "created business (business id %d) for %s (acc id %d, note id %d)", iTmp, ReturnPlayerName( targetid  ), p_AccountID[ targetid  ], noteid );
				SendClientMessageFormatted( playerid, -1, ""COL_PINK"[BUSINESS]"COL_WHITE" You have created a business in the name of %s(%d).", ReturnPlayerName( targetid  ), targetid  );
				AddAdminLogLineFormatted( "%s(%d) has created a business for %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( targetid ), targetid );
			} else {
				SaveToAdminLogFormatted( playerid, iTmp, "created business (business id %d)", iTmp );
				SendClientMessageFormatted( playerid, -1, ""COL_PINK"[BUSINESS]"COL_WHITE" You have created a business." );
				AddAdminLogLineFormatted( "%s(%d) has created a business", ReturnPlayerName( playerid ), playerid );
			}
		} else {
			SendClientMessage( playerid, -1, ""COL_PINK"[BUSINESS]"COL_WHITE" Unable to create a business due to a unexpected error." );
		}
	}
	else
	{
		SendError( playerid, "This user does not have a V.I.P Business note." );
	}
	return 1;
}

CMD:destroybusiness( playerid, params[ ] )
{
	new
	    iBusiness;

	if ( p_AdminLevel[ playerid ] < 5 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", iBusiness ) ) return SendUsage( playerid, "/destroybusiness [BUSINESS_ID]" );
	else if ( iBusiness < 0 || iBusiness >= MAX_BUSINESSES ) return SendError( playerid, "Invalid Business ID." );
	else if ( !Iter_Contains( business, iBusiness ) ) return SendError( playerid, "Invalid Business ID." );
	else
	{
		SaveToAdminLog( playerid, iBusiness, "destroy business" );
		format( szBigString, sizeof( szBigString ), "[DG] [%s] %s | %d | %d\r\n", getCurrentDate( ), ReturnPlayerName( playerid ), g_businessData[ iBusiness ] [ E_OWNER_ID ], iBusiness );
	    AddFileLogLine( "log_business.txt", szBigString );
		AddAdminLogLineFormatted( "%s(%d) has deleted a business", ReturnPlayerName( playerid ), playerid );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[BUSINESS]"COL_WHITE" You have destroyed the business ID %d.", iBusiness );
	    DestroyBusiness( iBusiness );
	}
	return 1;
}

CMD:reloadeditor( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 6 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	SetServerRule( "reloadfs", "objecteditor" );
	SendClientMessage( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have successfully reloaded the object editor." );
	return 1;
}

CMD:createentrance( playerid, params[ ] )
{
    new
		Float: X, Float: Y, Float: Z,
		Float: toX, Float: toY, Float: toZ,
		ownerid, interior, world, customInterior, vipOnly, label[32]
	;

	if ( p_AdminLevel[ playerid ] < 6 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "ufffdddds[32]", ownerid, toX, toY, toZ, interior, world, customInterior, vipOnly, label ) ) return SendUsage( playerid, "/createentrance [OWNER] [TO_X] [TO_Y] [TO_Z] [INTERIOR] [WORLD] [CUSTOM_INTERIOR] [VIP_ONLY] [LABEL]" );
	else if ( !IsPlayerConnected( ownerid ) || IsPlayerNPC( ownerid ) ) return SendError( playerid, "Invalid Player ID." );
	else
	{
		AddAdminLogLineFormatted( "%s(%d) has created an entrance", ReturnPlayerName( playerid ), playerid );

		if ( GetPlayerPos( playerid, X, Y, Z ) ) {
			new
				entranceid = CreateEntrance( label, X, Y, Z, toX, toY, toZ, interior, world, customInterior > 0, vipOnly > 0 );

		    if ( entranceid == -1 )
				return SendClientMessage( playerid, -1, ""COL_PINK"[ENTRANCE]"COL_WHITE" Unable to create a entrance due to a unexpected error." );

			SaveToAdminLog( playerid, entranceid, "created entrance" );
			g_entranceData[ entranceid ] [ E_SAVED ] = true;

			format( szBigString, 256, "INSERT INTO `ENTRANCES` (`OWNER`, `LABEL`, `X`, `Y`, `Z`, `EX`, `EY`, `EZ`, `INTERIOR`, `WORLD`, `CUSTOM`, `VIP_ONLY`) VALUES ('%s','%s',%f,%f,%f,%f,%f,%f,%d,%d,%d,%d)", mysql_escape( ReturnPlayerName( ownerid ) ), mysql_escape( label ), X, Y, Z, toX, toY, toZ, interior, world, customInterior, vipOnly );
			mysql_single_query( szBigString );

	    	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ENTRANCE]"COL_WHITE" You have created a entrance using id %d.", entranceid );
		}
	}
	return 1;
}

CMD:destroyentrance( playerid, params[ ] )
{
	new
		Float: distance = FLOAT_INFINITY, confirm,
	    entranceid = GetClosestEntrance( playerid, distance );

	if ( p_AdminLevel[ playerid ] < 6 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", confirm ) ) return SendUsage( playerid, "/destroyentrance [ARE_YOU_SURE (0 or 1)]" );
	else if ( confirm < 1 ) return SendError( playerid, "Must confirm by typing a number above 0." );
	else if ( entranceid < 0 || entranceid > MAX_ENTERS ) return SendError( playerid, "Invalid entrance ID." );
	else if ( !Iter_Contains( entrances, entranceid ) ) return SendError( playerid, "Invalid entrance ID." );
	else if ( !g_entranceData[ entranceid ] [ E_SAVED ] ) return SendError( playerid, "Must be a saved entrance." );
	else if ( distance > 100.0 ) return SendError( playerid, "Must be within 10m of the nearest entrance." );
	else
	{
		// log deletions
		format( szBigString, sizeof( szBigString ), "[DE] [%s] %s | %f,%f,%f | %d\r\n", getCurrentDate( ), ReturnPlayerName( playerid ), g_entranceData[ entranceid ] [ E_EX ], g_entranceData[ entranceid ] [ E_EY ], g_entranceData[ entranceid ] [ E_EZ ], entranceid );
	    AddFileLogLine( "log_entrances.txt", szBigString );

	    // delete and log
		SaveToAdminLog( playerid, entranceid, "destroy entrance" );
		AddAdminLogLineFormatted( "%s(%d) has deleted an entrance", ReturnPlayerName( playerid ), playerid );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ENTRANCE]"COL_WHITE" You have destroyed entrance id %d", entranceid );
	    DestroyEntrance( entranceid );
	}
	return 1;
}

CMD:setgangleader( playerid, params[ ] )
{
	new
	    sqlid, pID;

	if ( p_AdminLevel[ playerid ] < 6 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "du", sqlid, pID ) ) return SendUsage( playerid, "/setgangleader [GANG_ID] [PLAYER_ID]" );
	//else if ( !Iter_Contains( gangs, gID ) ) return SendError( playerid, "Invalid Gang ID." );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	// else if ( p_GangID[ pID ] != gID ) return SendError( playerid, "This player isn't in this gang." );
	else
	{
		new
			gid = -1;

		foreach ( new g : gangs ) if ( g_gangData[ g ] [ E_SQL_ID ] == sqlid ) {
			gid = g;
			break;
		}

		if ( ! Iter_Contains( gangs, gid ) )
			return SendError( playerid, "Invalid Gang ID." );

        SetPlayerGang( pID, gid );
        g_gangData[ gid ] [ E_LEADER ] = p_AccountID[ pID ];

		SaveToAdminLogFormatted( playerid, gid, "setgangleader to %s (acc id %d)", ReturnPlayerName( pID ), p_AccountID[ pID ] );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[GANG]"COL_WHITE" %s(%d) is now the leader of %s.", ReturnPlayerName( pID ), pID, g_gangData[ gid ] [ E_NAME ] );
		SendClientMessageToGang( gid, g_gangData[ gid ] [ E_COLOR ], "[GANG]{FFFFFF} %s(%d) is the new gang leader, forcefully by %s.", ReturnPlayerName( pID ), pID, ReturnPlayerName( playerid ) );
        SaveGangData( gid );
	}
	return 1;
}

CMD:viewgangtalk( playerid, params[ ] )
{
	new
	    gID;

	if ( p_AdminLevel[ playerid ] < 6 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", gID ) )
	{
		if ( p_ViewingGangTalk[ playerid ] != -1 )
		{
			p_ViewingGangTalk[ playerid ] = -1;
			return SendServerMessage( playerid, "You have stopped viewing other gang messages." );
		}
		return SendUsage( playerid, "/viewgangtalk [GANG_ID]" );
	}
	else if ( gID < 0 || gID > MAX_GANGS ) return SendError( playerid, "Invalid Gang ID." );
	else if ( !Iter_Contains( gangs, gID ) ) return SendError( playerid, "Invalid Gang ID." );
	else
	{
		p_ViewingGangTalk[ playerid ] = gID;
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[GANG]"COL_WHITE" You are now viewing gang messages of %s.", g_gangData[ gID ] [ E_NAME ] );
	}
	return 1;
}

CMD:broadcast( playerid, params[ ] )
{
	new
		szURL[ 128 ]
	;

	if ( p_AdminLevel[ playerid ] < 6 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "s[128]", szURL ) ) return SendUsage( playerid, "/broadcast [MP3_URL]");
	else
	{
		new
			bStopped = strmatch( szURL, "stop" );

		foreach(new i : Player)
		{
			if ( !IsPlayerUsingRadio( i ) )
			{
				if ( bStopped )
				{
	   				StopAudioStreamForPlayer( i );
				}
	   			else
	   			{
	   				PlayAudioStreamForPlayer( i, szURL );
	   			}
			}
		}

		if ( bStopped )
		{
			SendClientMessage( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have stopped broadcasting your audio to players." );
		}
		else
		{
			SaveToAdminLogFormatted( playerid, 0, "broadcast %s", szURL );
			SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" Broadcasting "COL_GREY"%s"COL_WHITE".", szURL );
		}
	}
	return 1;
}

CMD:seteventhost( playerid, params[ ] )
{
	new
	    pID;

	if ( p_AdminLevel[ playerid ] < 5 && p_AccountID[ playerid ] != GetGVarInt( "eventhost" ) ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) SendUsage( playerid, "/seteventhost [PLAYER_ID]");
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( p_AdminLevel[ pID ] < 4 ) return SendError( playerid, "The user you specify must have an administration level 4 or above." );
	else
	{
		UpdateServerVariable( "eventhost", p_AccountID[ pID ], 0.0, "", GLOBAL_VARTYPE_INT );
		SaveToAdminLogFormatted( playerid, 0, "seteventhost to %s (acc id %d)", ReturnPlayerName( pID ), p_AccountID[ pID ] );

		if ( playerid != pID )
		{
			AddAdminLogLineFormatted( "%s(%d) has set %s(%d) as event host", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
			SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has designated %s(%d) as the event host!", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
		}
		else
		{
			AddAdminLogLineFormatted( "%s(%d) has set himself as event host", ReturnPlayerName( playerid ), playerid );
			SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has designated himself as the event host!", ReturnPlayerName( playerid ), playerid );
		}
	}
	return 1;
}

CMD:setlevel( playerid, params[ ] )
{
	new
	    pID,
	    iLevel
	;
	if ( !IsPlayerAdmin( playerid ) && p_AdminLevel[ playerid ] < 6 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "ud", pID, iLevel ) ) SendUsage( playerid, "/setlevel [PLAYER_ID] [LEVEL]");
	else if ( iLevel < 0 || iLevel > 6 ) return SendError( playerid, "Please specify an administration level between 0 and 6." );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else
	{
		if ( ! IsPlayerServerMaintainer( playerid ) && p_AdminLevel[ playerid ] >= 6 && iLevel > 5 )
			return SendError( playerid, "You maximum level you are able to promote a person to is 5." );

		// Log level
		mysql_single_query( sprintf( "INSERT INTO `ADMIN_LEVELS`(`USER_ID`,`EXEC_ID`,`LEVEL`) VALUES (%d,%d,%d)", p_AccountID[ pID ], p_AccountID[ playerid ], iLevel ) );

		// Set level
		p_AdminLevel[ pID ] = iLevel;
		AddAdminLogLineFormatted( "%s(%d) has set %s(%d)'s admin level to %d", ReturnPlayerName( playerid ), playerid,  ReturnPlayerName( pID ), pID, iLevel );
		SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]{FFFFFF} %s(%d) has set your admin level to %d!", ReturnPlayerName( playerid ), playerid, iLevel );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]{FFFFFF} You've set %s(%d)'s admin level to %d!", ReturnPlayerName( pID ), pID, iLevel );
	}
	return 1;
}

CMD:setleveloffline( playerid, params[ ] )
{
	new
		iLevel, szName[ 24 ];

	if ( !IsPlayerAdmin( playerid ) && p_AdminLevel[ playerid ] < 6 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "ds[24]", iLevel, szName ) ) SendUsage( playerid, "/setleveloffline [LEVEL] [PLAYER_NAME]");
	else if ( iLevel < 0 || iLevel > 6 ) return SendError( playerid, "Please specify an administration level between 0 and 6." );
	else
	{
		if ( ! IsPlayerServerMaintainer( playerid ) && p_AdminLevel[ playerid ] >= 6 && iLevel > 4 )
			return SendError( playerid, "You maximum level you are able to promote a person to is 4." );

		mysql_function_query( dbHandle, sprintf( "UPDATE `USERS` SET `ADMINLEVEL`=%d WHERE `NAME`='%s'", iLevel, mysql_escape( szName ) ), true, "OnPlayerUpdateAdminLevel", "iis", playerid, iLevel, szName );
	}
	return 1;
}

thread OnPlayerUpdateAdminLevel( playerid, level, name[ ] )
{
	if ( cache_affected_rows( ) )
	{
		// Log level
		format( szBigString, sizeof( szBigString ), "INSERT INTO `ADMIN_LEVELS`(`USER_ID`,`EXEC_ID`,`LEVEL`) VALUES ((SELECT `ID` FROM `USERS` WHERE `NAME`='%s'),%d,%d)", name, p_AccountID[ playerid ], level );
		mysql_single_query( szBigString );

		// Set level
		AddAdminLogLineFormatted( "%s(%d) has set %s's admin level to %d", ReturnPlayerName( playerid ), playerid, name, level );
	    return SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]{FFFFFF} You've set %s's admin level to %d!", name, level );
	}

	return SendError( playerid, "This user does not exist." );
}

CMD:svrstats( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 6 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	if ( strmatch( params, "version" ) )
		return SendServerMessage( playerid, "Current version is "COL_GREY"%s", GetServerVersion( ) ), 1;

	if ( strmatch( params, "ticks" ) )
		return SendServerMessage( playerid, "Current tick rate of server is: %d", GetServerTickRate( ) ), 1;

	if ( strmatch( params, "uptime" ) )
		return SendServerMessage( playerid, "Server online for "COL_GREY"%s", secondstotime( g_iTime - g_ServerUptime ) ), 1;

	return SendUsage( playerid, "/svrstats [VERSION/TICKS/UPTIME]" ), 1;
}

CMD:playaction( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 6 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	new
		pID, action;

	if ( sscanf(params, "ud", pID, action ) )
		return SendUsage( playerid, "/playaction [PLAYER_ID] [SPECIAL_ACTION]");

	SetPlayerSpecialAction( pID, action );
	return 1;
}

CMD:playanimation( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 6 && p_AccountID[ playerid ] != 819507 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	new pID;
	new szAnimation[ 2 ][ 64 ];
	new loop, lockx, locky, freeze, time, force_sync;

	if ( sscanf(params, "us[64]s[64]D(0)D(0)D(0)D(0)D(0)D(0)", pID, szAnimation[ 0 ], szAnimation[ 1 ], loop, lockx, locky, freeze, time, force_sync ) )
		return SendUsage( playerid, "/playanimation [PLAYER_ID] [LIBRARY] [ANIM_NAME] [LOOP (0)] [LOCK_X (0)] [LOCK_Y (0)] [FREEZE (0)] [TIME (0)] [FORCE_SYNC (0)]" );

	ApplyAnimation( pID, szAnimation[0], szAnimation[1], 4.1, loop, lockx, locky, freeze, time, force_sync );
	AddAdminLogLineFormatted( "%s(%d) played animation %s %s on %s(%d)", ReturnPlayerName( playerid ), playerid, szAnimation[0], szAnimation[1], ReturnPlayerName( pID ), pID );
	return 1;
}

CMD:updaterules( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 6 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	HTTP( 0, HTTP_GET, "files.sfcnr.com/en_rules.txt", "", "OnRulesHTTPResponse" );
	SendServerMessage( playerid, "Rules should be updated now." );
	return 1;
}

CMD:truncate( playerid, params[ ] )
{
	new
		bDebt,
		szName[ 24 ];

	if ( p_AdminLevel[ playerid ] < 6 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	if ( sscanf( params, "ds[24]", bDebt, szName ) )
		return SendUsage( playerid, "/truncate [DEBT (=1 OR 0)] [PLAYER_NAME]");

	if ( bDebt != 0 && bDebt != 1 )
		return SendError( playerid, "Debt value must be either 1 or 0." );

	mysql_function_query( dbHandle, sprintf( "UPDATE `USERS` SET `CASH`=%d,`BANKMONEY`=0 WHERE `NAME`='%s' AND `ADMINLEVEL` < %d", bDebt ? -250000 : 0, mysql_escape( szName ), p_AdminLevel[ playerid ] ), true, "OnPlayerTruncateUser", "isi", playerid, szName, bDebt );
	return 1;
}

thread OnPlayerTruncateUser( playerid, name[ ], debt )
{
	if ( cache_affected_rows( ) )
	{
	    AddFileLogLine( "log_admin.txt", sprintf( "[TRUNCATE] [%s] %s -> %s\r\n", getCurrentDate( ), ReturnPlayerName( playerid ), name ) );
		AddAdminLogLineFormatted( "%s(%d) has truncated %s's money", ReturnPlayerName( playerid ), playerid, name );

		if ( debt ) {
			SaveToAdminLogFormatted( playerid, 0, "truncate %s (with debt)", name );
	    	return SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]{FFFFFF} You've truncated %s and issued them a 250K debt.", name );
		} else {
			SaveToAdminLogFormatted( playerid, 0, "truncate %s", name );
	    	return SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]{FFFFFF} You've truncated %s.", name );
		}
	}
	return SendError( playerid, "This user does not exist." );
}

CMD:weather( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 5 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	new
		weatherid;

	if ( sscanf( params, "d", weatherid ) )
		return SendUsage( playerid, "/weather [WEATHER_ID]" );

	SetWorldWeather( weatherid );
	SaveToAdminLogFormatted( playerid, 0, "weather %d", weatherid );
	AddAdminLogLineFormatted( "%s(%d) has changed the weather to %d", ReturnPlayerName( playerid ), playerid, weatherid );
	SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has changed the weather to %d!", ReturnPlayerName( playerid ), playerid, weatherid );
	return 1;
}
