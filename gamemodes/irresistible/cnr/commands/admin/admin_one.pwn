/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr/commands/admin/admin_one.pwn
 * Purpose: level one administrator commands (cnr)
 */

/* ** Commands ** */
CMD:viewdeathmsg( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 1 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	new targetid;

	if ( sscanf( params, "u", targetid ) ) return SendUsage( playerid, "/viewdeathmsg [PLAYER_ID]" );
	else if ( ! IsPlayerConnected( targetid ) || IsPlayerNPC( targetid ) ) return SendError( playerid, "Invalid Player ID." );
	else
	{
		if ( ! strlen( p_DeathMessage[ targetid ] ) ) {
			SendError( playerid, "This player does not have an active death message." );
		} else {
			SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d)'s death message is: "COL_GREY"%s", ReturnPlayerName( targetid ), targetid, p_DeathMessage[ targetid ] );
		}
	}
	return 1;
}

CMD:arepair( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 1 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

 	if ( !IsPlayerInEvent( playerid ) )
 		return SendError( playerid, "You cannot use this command since you're not in an event world." );

	new
		iVehicle = GetPlayerVehicleID( playerid );

	if ( IsValidVehicle( iVehicle ) )
	{
		if ( !g_adminSpawnedCar{ iVehicle } )
			return SendError( playerid, "This is not an admin spawned vehicle." );

	 	RepairVehicle( iVehicle );
		PlayerPlaySound( playerid, 1133, 0.0, 0.0, 5.0 );

 		AddAdminLogLineFormatted( "%s(%d) has repaired their vehicle", ReturnPlayerName( playerid ), playerid );
		return SendClientMessage( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have repaired this vehicle." );
	}
	return SendError( playerid, "You are not in any vehicle." );
}

CMD:aka( playerid, params[ ] )
{
	new
		pID
	;

	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/aka [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else
	{
		format( szNormalString, 96, "SELECT `NAME`,`TIME` FROM `NAME_CHANGES` WHERE `USER_ID`=%d ORDER BY `TIME` DESC", p_AccountID[ pID ] );
		mysql_function_query( dbHandle, szNormalString, true, "readnamechanges", "dd", playerid, pID );
	}
	return 1;
}

CMD:pinfo( playerid, params[ ] )
{
	new
		pID
	;
	if ( p_AdminLevel[ playerid ] < 1 && !IsPlayerUnderCover( playerid ) ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/pinfo [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else
	{
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d): "COL_GREY"%0.2f%s packetloss, %d FPS, %d ping, from %s, SA-MP AC %s", ReturnPlayerName( pID ), pID, NetStats_PacketLossPercent( pID ), "%%", GetPlayerFPS( pID ), GetPlayerPing( pID ), GetPlayerCountryName( pID ), IsPlayerUsingSampAC( pID ) ? ( COL_GREEN # "ENABLED" ) : ( COL_RED # "DISABLED" ) );
	}
	return 1;
}

CMD:reports( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );

	szLargeString = ""COL_GREY"Date\t"COL_GREY"Reported By\t"COL_GREY"Reported\t"COL_GREY"Message\n";

	if ( !strlen( szReportsLog[ 7 ] ) )
		return SendError( playerid, "There is no reports at the moment." );

	for (new i = 0; i < 8; i ++)
	{
		format( szLargeString, sizeof( szLargeString ), "%s%s\n", szLargeString, szReportsLog[ i ] );
	}

	ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Report Log", szLargeString, "Okay", "" );
	return 1;
}

CMD:questions( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );

	szLargeString = ""COL_GREY"Date\t"COL_GREY"Player\t"COL_GREY"Question\n";

	if ( !strlen( szQuestionsLog[ 7 ] ) )
		return SendError( playerid, "There is no questions at the moment." );

	for (new i = 0; i < 8; i ++)
	{
		format( szLargeString, sizeof( szLargeString ), "%s%s\n", szLargeString, szQuestionsLog[ i ] );
	}

	ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Question Log", szLargeString, "Okay", "" );
	return 1;
}

CMD:respawnalluv( playerid, params[ ] )
{
 	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else
	{
	    for( new i = 0; i < MAX_VEHICLES; i++ ) if ( IsValidVehicle( i ) )
	    {
	    	#if defined __cnr__chuffsec
	    	if ( g_secureTruckVehicle == i ) continue;
	    	#endif

	    	// keep trailers
	    	if ( IsTrailerVehicle( GetVehicleModel( i ) ) )
	    		continue;

	    	new
	    		occupierid = IsVehicleOccupied( i, .include_vehicle_interior = true );

	    	// skip npcs
	    	if ( IsPlayerNPC( occupierid ) )
	    		continue;

	    	// unoccupied vehicles
			if ( occupierid == -1 )
				SetVehicleToRespawn( i );
		}
		AddAdminLogLineFormatted( "%s(%d) has respawned all unoccupied vehicles", ReturnPlayerName( playerid ), playerid );
		SendServerMessage( playerid, "You have respawned all unoccupied vehicles." );
	}
	return 1;
}

CMD:aod( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
 	if ( !p_AdminOnDuty{ playerid } )
	{
		TextDrawShowForPlayer( playerid, g_AdminOnDutyTD );
	    Delete3DTextLabel( p_AdminLabel[ playerid ] );
	    p_AdminLabel[ playerid ] = Create3DTextLabel( "Admin on Duty!", COLOR_PINK, 0.0, 0.0, 0.0, 15.0, 0 );
	    Attach3DTextLabelToPlayer( p_AdminLabel[ playerid ], playerid, 0.0, 0.0, 0.5 );
	    SetPlayerHealth( playerid, INVALID_PLAYER_ID );
	    DisableRemoteVehicleCollisions( playerid, 1 );
	    p_AdminOnDuty{ playerid } = true;
	    SendClientMessage( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have enabled administration mode." );
	}
	else
	{
		TextDrawHideForPlayer( playerid, g_AdminOnDutyTD );
	    Delete3DTextLabel( p_AdminLabel[ playerid ] );
	    p_AdminLabel[ playerid ] = Text3D: INVALID_3DTEXT_ID;
	    p_AdminOnDuty{ playerid } = false;
	    SetPlayerHealth( playerid, 100 );
	    DisableRemoteVehicleCollisions( playerid, 0 );
	    SendClientMessage( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have disabled administration mode." );
	}
	SendClientMessageFormattedToAll( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) is now %s-duty.", ReturnPlayerName( playerid ), playerid, p_AdminOnDuty{ playerid } == true ? ( "on" ) : ( "off" ) );
	SetPlayerColorToTeam( playerid );
	return 1;
}

CMD:asay( playerid, params[ ] )
{
	new
	    string[ 100 ]
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "s[100]", string ) ) return SendUsage( playerid, "/asay [MESSAGE]" );
	else
	{
		AddAdminLogLineFormatted( "%s(%d) has used /asay", ReturnPlayerName( playerid ), playerid );
        SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s", string );
	}
	return 1;
}

CMD:frules( playerid, params[ ] )
{
	new
		pID
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/frules [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( !IsPlayerSpawned( pID ) ) return SendError( playerid, "This player isn't spawned." );
	else
	{
		ShowPlayerRules( pID );
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have shown %s(%d) the /rules", ReturnPlayerName( pID ), pID );
		AddAdminLogLineFormatted( "%s(%d) has shown the rules to %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
	}
	return 1;
}

CMD:fpc( playerid, params[ ] )
{
	new
		pID
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/fpc [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( !IsPlayerSpawned( pID ) ) return SendError( playerid, "This player isn't spawned." );
	else
	{
		cmd_pc( pID, "" );
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have shown %s(%d) the player colors (/pc)", ReturnPlayerName( pID ), pID );
		AddAdminLogLineFormatted( "%s(%d) has shown the player colors to %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
	}
	return 1;
}

CMD:freeze( playerid, params[ ] )
{
	new
		pID
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/freeze [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( !IsPlayerSpawned( pID ) ) return SendError( playerid, "This player isn't spawned." );
	else
	{
	    AddAdminLogLineFormatted( "%s(%d) has frozen %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
		SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have been frozen by %s(%d)!", ReturnPlayerName( playerid ), playerid );
	   	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have frozen %s(%d)!", ReturnPlayerName( pID ), pID );
	   	TogglePlayerControllable( pID, 0 );
	}
	return 1;
}


CMD:unfreeze( playerid, params[ ] )
{
	new
		pID
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/unfreeze [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( !IsPlayerSpawned( pID ) ) return SendError( playerid, "This player isn't spawned." );
	else
	{
	    AddAdminLogLineFormatted( "%s(%d) has unfrozen %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
		SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have been unfrozen by %s(%d)!", ReturnPlayerName( playerid ), playerid );
	   	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have unfrozen %s(%d)!", ReturnPlayerName( pID ), pID );
	   	TogglePlayerControllable( pID, 1 );
	}
	return 1;
}

CMD:awep( playerid, params[ ] )
{
	static
		iAmmo,
		pID
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/awep [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( !IsPlayerSpawned( pID ) ) return SendError( playerid, "This player isn't spawned." );
	else
	{
        szLargeString[ 0 ] = '\0';
        SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You are now viewing "COL_GREY"%s(%d){FFFFFF}'s weapons.", ReturnPlayerName( pID ), pID );
		for(new i; i < MAX_WEAPONS; i++)
		{
		    if ( IsWeaponInAnySlot( pID, i ) )
		    {
				GetPlayerWeaponData( pID, GetWeaponSlot( i ), iAmmo, iAmmo );
				if ( iAmmo > 0x7FFF || iAmmo < -100 ) iAmmo = 0x7FFF;
				if ( iAmmo == 0 || i == 0 ) continue;

		        format( szLargeString, sizeof( szLargeString ), "%s%s(%d)\n", szLargeString, ReturnWeaponName( i ), iAmmo );
		        ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_LIST, "{FFFFFF}Weapon Data", szLargeString, "Okay", "" );
		    }
		}
	}
	return 1;
}

CMD:alog( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 1 && !IsPlayerUnderCover( playerid ) ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else
	{
        if ( p_AdminLog{ playerid } )
        {
            p_AdminLog{ playerid } = false;
	    	TextDrawHideForPlayer( playerid, g_AdminLogTD );
	    	SendServerMessage( playerid, "You have un-toggled the administration log." );
		}
		else
		{
            p_AdminLog{ playerid } = true;
	    	TextDrawShowForPlayer( playerid, g_AdminLogTD );
	    	SendServerMessage( playerid, "You have toggled the administration log." );
		}
	}
	return 1;
}

CMD:stopask( playerid, params[ ] )
{
    new
		pID
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "u", pID ) ) SendUsage(playerid, "/stopask [PLAYER_ID]");
    else if ( !IsPlayerConnected(pID) ) return SendError(playerid, "Invalid Player ID.");
    else if ( pID == playerid ) return SendError( playerid, "You cannot apply this to yourself." );
    else if ( p_AdminLevel[ pID ] > p_AdminLevel[ playerid ] ) return SendError( playerid, "This player has a higher administration level than you." );
    else
    {
        p_CantUseAsk{ pID } = ( p_CantUseAsk{ pID } == true ? false : true );
		AddAdminLogLineFormatted( "%s(%d) has been %s from using /ask by %s(%d)", ReturnPlayerName( pID ), pID, p_CantUseAsk{ pID } == true ? ( "blocked" ) : ( "unblocked" ), ReturnPlayerName( playerid ), playerid );
        SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have %s %s(%d) from using the ask command.", p_CantUseAsk{ pID } == true ? ( "blocked" ) : ( "unblocked" ), ReturnPlayerName( pID ), pID );
    }
    return 1;
}

CMD:ans( playerid, params[ ] )
{
	new
		pID, msg[ 90 ], iTime = g_iTime
	;

	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "us[90]", pID, msg ) ) return SendUsage( playerid, "/ans [PLAYER_ID] [ANSWER]" );
    else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
    else if ( pID == playerid ) return SendError( playerid, "You cannot answer yourself." );
    else if ( iTime < p_AnswerDelay[ pID ] ) return SendError( playerid, "Please wait another %d seconds to answer this person.", p_AnswerDelay[ pID ] - iTime );
	else
	{
		SendClientMessageToAdmins( -1, ""COL_PINK"[ANSWER]"COL_GREY" (%s >> %s):"COL_WHITE" %s", ReturnPlayerName( playerid ), ReturnPlayerName( pID ), msg );
		AddAdminLogLineFormatted( "%s(%d) has answered %s(%d)'s question", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
        SendClientMessageFormatted( pID, -1, "{FE5700}[ANSWER] From %s(%d):{FFFFFF} %s", ReturnPlayerName( playerid ), playerid, msg );
        p_AnswerDelay[ pID ] = iTime + 4;
        Beep( pID ), Beep( playerid );
	}
	return 1;
}

CMD:respond( playerid, params[ ] )
{
	new
		pID;

	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/respond [PLAYER_ID]" );
    else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
    else if ( pID == playerid ) return SendError( playerid, "You cannot respond to yourself." );
    else if ( g_iTime < p_RespondDelay[ pID ] ) return SendError( playerid, "Please wait another %d seconds to respond to this person.", p_RespondDelay[ pID ] - g_iTime );
	else
	{
		AddAdminLogLineFormatted( "%s(%d) is responding to %s(%d)'s report", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
		SendClientMessageToAdmins( -1, ""COL_PINK"[REPORT]"COL_GREY" %s(%d) responded to %s(%d)'s report!", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
        SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_GREY" %s(%d) is now looking into your report. Please wait!", ReturnPlayerName( playerid ), playerid );
        p_RespondDelay[ pID ] = g_iTime + 4;
        Beep( pID ), Beep( playerid );
	}
	return 1;
}

CMD:aspawn( playerid, params[ ] )
{
	new
		pID
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/aspawn [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( p_PlayerLogged{ pID } == false ) return SendError( playerid, "This player is not logged in." );
	else
	{
		SyncObject( pID );
		SpawnPlayer( pID );
		AddAdminLogLineFormatted( "%s(%d) has spawned %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
        SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have spawned %s(%d)!", ReturnPlayerName( pID ), pID );
		SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have been spawned by %s(%d)!", ReturnPlayerName( playerid ), playerid );
	}
	return 1;
}

CMD:warn( playerid, params[ ] )
{
	new
	    pID,
	    reason[ 32 ]
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "uS(No Reason)[32]", pID, reason ) ) return SendUsage( playerid, "/warn [PLAYER_ID] [REASON]" );
    else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
    else if ( pID == playerid ) return SendError( playerid, "You can't warn your self." );
	else if ( p_AdminLevel[ playerid ] < p_AdminLevel[ pID ] ) return SendError( playerid, "This player has a higher administration level than you." );
	else
	{
		if ( p_AdminCommandPause[ pID ] > g_iTime )
			return SendError( playerid, "You must wait %d seconds before using this admin command on the player.", p_AdminCommandPause[ pID ] - g_iTime );

		p_AdminCommandPause[ pID ] = g_iTime + ADMIN_COMMAND_TIME;

	    p_Warns[ pID ] ++;
		GameTextForPlayer( pID, "~r~WARNED!", 4000, 4 );
	    AddAdminLogLineFormatted( "%s(%d) has warned %s(%d) [%d/3]", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, p_Warns[ pID ] );
        SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has been warned by %s(%d) "COL_GREEN"[REASON: %s]", ReturnPlayerName( pID ), pID, ReturnPlayerName( playerid ), playerid, reason );
		if ( p_Warns[ pID ] >= 3 )
	    {
	        p_Warns[ pID ] = 0;
	        SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has been kicked from the server. "COL_GREEN"[REASON: Excessive Warns]", ReturnPlayerName( pID ), pID );
	        KickPlayerTimed( pID );
	        return 1;
	    }
 	}
	return 1;
}

CMD:setskin( playerid, params[ ] )
{
    new
		pID,
		skin
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "ud", pID, skin ) ) SendUsage(playerid, "/setskin [PLAYER_ID] [SKIN_ID]");
    else if ( !IsPlayerConnected(pID) ) return SendError(playerid, "Invalid Player ID.");
    else if ( p_AdminLevel[ pID ] > p_AdminLevel[ playerid ] ) return SendError( playerid, "This player has a higher administration level than you." );
	else if ( !IsValidSkin( skin ) ) return SendError( playerid, "Invalid Skin ID." );
	else
	{
	    if ( GetPlayerState( pID ) == PLAYER_STATE_ENTER_VEHICLE_DRIVER || GetPlayerState( pID ) == PLAYER_STATE_ENTER_VEHICLE_PASSENGER ) return SendError( playerid, "You cannot set your skin if you're entering a vehicle." );
	    if ( GetPlayerState( pID ) == PLAYER_STATE_EXIT_VEHICLE ) return SendError( playerid, "You cannot set your skin if you're exiting a vehicle." );
		if ( GetPlayerAnimationIndex( pID ) == 1660 ) return SendError( playerid, "The player specified is currently using a vending machine." );
	    AddAdminLogLineFormatted( "%s(%d) has changed %s(%d)'s skin id to %d", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, skin );
	  	SyncObject( pID );
        SetPlayerSkin( pID, skin );
	    if ( pID != playerid ) {
		    SendClientMessageFormatted( pID, COLOR_PINK, "[ADMIN]"COL_WHITE" %s(%d) has changed your skin ID to %d.", ReturnPlayerName( playerid ), playerid, skin );
		    SendClientMessageFormatted( playerid, COLOR_PINK, "[ADMIN]"COL_WHITE" You have changed %s(%d)'s skin to ID %d.", ReturnPlayerName( pID ), pID, skin );
		}
		else SendClientMessageFormatted( playerid, COLOR_PINK, "[ADMIN]"COL_WHITE" You have changed your skin to ID %d.", skin );

	}
	return 1;
}

CMD:stopreport( playerid, params[ ] )
{
    new
		pID
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "u", pID ) ) SendUsage(playerid, "/stopreport [PLAYER_ID]");
    else if ( !IsPlayerConnected(pID) ) return SendError(playerid, "Invalid Player ID.");
    else if ( pID == playerid ) return SendError( playerid, "You cannot apply this to yourself." );
    else if ( p_AdminLevel[ pID ] > p_AdminLevel[ playerid ] ) return SendError( playerid, "This player has a higher administration level than you." );
    else
    {
		p_CantUseReport{ pID } = ( p_CantUseReport{ pID } == true ? false : true );
        AddAdminLogLineFormatted( "%s(%d) has been %s from using /report by %s(%d)", ReturnPlayerName( pID ), pID, p_CantUseReport{ pID } == true ? ( "blocked" ) : ( "unblocked" ), ReturnPlayerName( playerid ), playerid );
        SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have %s %s(%d) from using the report command.", p_CantUseReport{ pID } == true ? ( "blocked" ) : ( "unblocked" ), ReturnPlayerName( pID ), pID );
	}
    return 1;
}

CMD:getstats( playerid, params[ ] )
{
    new
		pID
	;

	if ( p_AdminLevel[ playerid ] < 1 && !IsPlayerUnderCover( playerid ) ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "u", pID ) ) SendUsage(playerid, "/getstats [PLAYER_ID]");
    else if ( !IsPlayerConnected(pID) ) return SendError(playerid, "Invalid Player ID.");
	else if ( !p_PlayerLogged{ pID } ) return SendError( playerid, "This player is not logged in." );
	else
	{
	    p_ViewingStats[ playerid ] = pID;
		ShowPlayerDialog( playerid, DIALOG_STATS, DIALOG_STYLE_LIST, "{FFFFFF}Statistics", "General Statistics\nGame Statistics\nItem Statistics\nStreak Statistics\nWeapon Statistics\nAchievements", "Okay", "Cancel" );
	}
   	return 1;
}

CMD:a( playerid, params[ ] )
{
	new
	    msg[ 90 ]
	;

    if ( p_AdminLevel[ playerid ] < 1 ) return 0;
    else if ( sscanf( params, "s[90]", msg ) ) return SendUsage( playerid, "/a [MESSAGE]" );
	else if ( textContainsIP( msg ) ) return SendServerMessage( playerid, "Please do not advertise." );
    else
	{
		SendClientMessageToAdmins( -1, ""COL_PINK"<Admin Chat> %s(%d):"COL_GREY" %s", ReturnPlayerName( playerid ), playerid, msg );
	}
	return 1;
}

CMD:adminmanual( playerid, params[ ] )
{
    if ( p_AdminLevel[ playerid ] < 1 )
    	return 0;

	AddAdminLogLineFormatted( "%s(%d) used /adminmanual", ReturnPlayerName( playerid ), playerid );
    SendClientMessageToAdmins( -1, ""COL_PINK"[ADMIN]"COL_GREY" Read the admin manual on the forum or you might be demoted (%s)!", "Help and Information > Administration Manual" );
	return 1;
}

CMD:slap( playerid, params[ ] )
{
    new
		pID,
		Float: offset,
		Float: X,
		Float: Y,
		Float: Z
	;

	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "uF(10.0)", pID, offset ) ) return SendUsage(playerid, "/slap [PLAYER_ID] [OFFSET (= 10.0)]");
    else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError(playerid, "Invalid Player ID.");
    else if ( p_AdminLevel[ pID ] > p_AdminLevel[ playerid ] ) return SendError(playerid, "You cannot use this command on admins higher than your level.");
    else
	{
        AddAdminLogLineFormatted( "%s(%d) has slapped %s(%d) %0.1f units", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, offset );
        SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have slapped %s(%d) %0.1f units", ReturnPlayerName( pID ), pID, offset );
        GetPlayerPos( pID, X, Y, Z );
        SetPlayerPos( pID, X, Y, Z + offset );
    }
    return 1;
}

CMD:jail( playerid, params [ ] )
{
    new
	    pID,
		Seconds,
		reason[ 50 ]
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "udS(No Reason)[50]", pID, Seconds, reason ) ) return SendUsage( playerid, "/jail [PLAYER_ID] [SECONDS] [REASON]");
	else if ( Seconds > 20000 || Seconds < 1 ) return SendError( playerid, "You're misleading the seconds limit ( 0 - 20000 )");
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else
	{
		if ( p_AdminCommandPause[ pID ] > g_iTime )
			return SendError( playerid, "You must wait %d seconds before using this admin command on the player.", p_AdminCommandPause[ pID ] - g_iTime );

		p_AdminCommandPause[ pID ] = g_iTime + ADMIN_COMMAND_TIME;
	    AddAdminLogLineFormatted( "%s(%d) has jailed %s(%d) for %d seconds", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, Seconds );
        JailPlayer( pID, Seconds, 1 );
	    if ( Seconds > 60 ) ShowPlayerRules( pID ); // force rules
	    SendGlobalMessage( -1, ""COL_GOLD"[JAIL]{FFFFFF} %s(%d) has been sent to jail for %d seconds by %s "COL_GREEN"[REASON: %s]", ReturnPlayerName( pID ), pID, Seconds, ReturnPlayerName( playerid ), reason );
	}
	return 1;
}

CMD:unjail( playerid, params [ ] )
{
    new
	    pID
	;
	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/unjail [PLAYER_ID]");
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( !IsPlayerJailed( pID ) ) return SendError( playerid, "This player is not jailed." );
	else
	{
	   	CallLocalFunction( "OnPlayerUnjailed", "dd", pID, 3 );
	    AddAdminLogLineFormatted( "%s(%d) has unjailed %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
	    SendGlobalMessage( -1, ""COL_GOLD"[JAIL]{FFFFFF} %s(%d) has been unjailed by %s(%d).", ReturnPlayerName( pID ), pID, ReturnPlayerName( playerid ), playerid );
	}
	return 1;
}

CMD:spec( playerid, params[ ] )
{
	new
		pID
	;

	if ( p_AdminLevel[ playerid ] < 1 && !IsPlayerUnderCover( playerid ) ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "u", pID ) ) SendUsage(playerid, "/spec [PLAYER_ID]");
    else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError(playerid, "Invalid Player ID.");
    else if ( pID == playerid ) return SendError(playerid, "You cannot spectate yourself.");
    else
    {
        if ( p_Spectating{ playerid } == true )
        {
			if ( IsPlayerConnected( p_whomSpectating[ playerid ] ) ) {
            	p_beingSpectated[ p_whomSpectating[ playerid ] ] = false;
            	p_whomSpectating[ playerid ] = INVALID_PLAYER_ID;
			}
        }

        for( new i; i < sizeof( p_SpectateWeapons[ ] ); i++ )
        {
        	GetPlayerWeaponData( playerid, i, p_SpectateWeapons[ playerid ] [ i ] [ 0 ], p_SpectateWeapons[ playerid ] [ i ] [ 1 ] );
        	if ( p_SpectateWeapons[ playerid ] [ i ] [ 1 ] > 10000 ) p_SpectateWeapons[ playerid ] [ i ] [ 1 ] = 15000;
        }

        SetPlayerInterior( playerid, GetPlayerInterior( pID ) );
        SetPlayerVirtualWorld( playerid, GetPlayerVirtualWorld( pID ) );

  		if ( !IsPlayerUnderCover( playerid ) ) {
			AddAdminLogLineFormatted( "%s(%d) is spectating %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
		}

        p_Spectating{ playerid } = true;
        p_whomSpectating[ playerid ] = pID;
        p_beingSpectated[ pID ] = true;
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You are now spectating %s(%d).", ReturnPlayerName( pID ), pID );
		if ( IsPlayerInAnyVehicle( pID ) )
		{
			TogglePlayerSpectating(playerid, 1),
			PlayerSpectateVehicle( playerid, GetPlayerVehicleID( pID ) );
		}
		else
		{
			TogglePlayerSpectating( playerid, 1 ),
			PlayerSpectatePlayer( playerid, pID );
		}
    }
    return 1;
}

CMD:specoff( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 1 && !IsPlayerUnderCover( playerid ) ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    if ( p_Spectating{ playerid } == true )
	{
		TogglePlayerSpectating( playerid, 0 );
		if ( IsPlayerConnected( p_whomSpectating[ playerid ] ) ) {
       		p_beingSpectated[ p_whomSpectating[ playerid ] ] = false;
           	p_whomSpectating[ playerid ] = INVALID_PLAYER_ID;
		}
		p_AlcatrazSpec[ playerid ] = g_iTime + 10;
		p_Spectating{ playerid } = false;
		SendServerMessage( playerid, "Spectation has been closed." );
	}
	else SendError(playerid, "You're not spectating!");
	return 1;
}

CMD:goto( playerid, params[ ] )
{
    new
		pID,
		Float: X,
		Float: Y,
		Float: Z
	;

	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/goto [PLAYER_ID]" );
    else if ( ! IsPlayerConnected( pID ) ) return SendError( playerid, "Invalid Player ID." );
    else if ( pID == playerid ) return SendError( playerid, "You cannot go to yourself." );
    else if ( p_Spectating{ pID } ) return SendError( playerid, "You cannot go to this player right now." );
    else
    {
        GetPlayerPos( pID, X, Y, Z );
		SetPlayerPosition( playerid, X, Y + 2, Z, GetPlayerInterior( pID ), GetPlayerVirtualWorld( pID ) );
        AddAdminLogLineFormatted( "%s(%d) has teleported to %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
        if ( p_InHouse[ playerid ] != -1 ) p_InHouse[ playerid ] = -1;
        if ( p_InGarage[ playerid ] != -1 ) p_InGarage[ playerid ] = -1;
        if ( p_inPaintBall{ playerid } ) LeavePlayerPaintball( playerid );
    }
    return 1;
}

CMD:mutelist( playerid, params[ ] )
{
	new
		count = 0;

	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );

	szNormalString[ 0 ] = '\0';
	foreach( new i : Player )
	{
		if ( p_Muted{ i } && g_iTime < p_MutedTime[ i ] )
		{
			format( szNormalString, sizeof( szNormalString ), "%s"COL_WHITE"%s(%d)\t"COL_GREY"%s\n",
				szNormalString,
				ReturnPlayerName( i ), i,
				secondstotime( p_MutedTime[ i ] - g_iTime )
			);

			count ++;
		}
	}
	if ( count == 0 )
		return SendError( playerid, "There are no muted players online." );
	else
		return ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_TABLIST, ""COL_WHITE"Muted List", szNormalString, "Close", "" ), 1;
}

CMD:chatbanlist( playerid, params[ ] )
{
	new
		count = 0;

	if ( p_AdminLevel[ playerid ] < 1 ) return SendError( playerid, ADMIN_COMMAND_REJECT );

	szNormalString[ 0 ] = '\0';
	foreach( new i : Player )
	{
		if ( p_ChatBanned{ i } )
		{
			format( szNormalString, sizeof( szNormalString ), "%s"COL_WHITE"%s(%d)\t"COL_GREY"By %s for '%s'\n",
				szNormalString,
				ReturnPlayerName( i ), i,
				p_ChatBannedBy[ playerid ],
				p_ChatBanReason[ playerid ]
			);

			count ++;
		}
	}
	if ( count == 0 )
		return SendError( playerid, "There are no chat banned players online." );
	else
		return ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_TABLIST, ""COL_WHITE"Chat Ban List", szNormalString, "Close", "" ), 1;
}
