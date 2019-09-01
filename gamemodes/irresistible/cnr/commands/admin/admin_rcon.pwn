/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr/commands/admin/admin_rcon.pwn
 * Purpose: level rcon administrator commands (cnr)
 */

/* ** Commands ** */
CMD:resetgangrespect( playerid, params[ ] )
{
	if ( ! IsPlayerAdmin( playerid ) )
		return 0;

	// reset preloaded and database
	foreach ( new g : gangs ) {
		g_gangData[ g ] [ E_RESPECT ] = 0;
	}

	mysql_single_query( "UPDATE `GANGS` SET `RESPECT` = 0" );
	SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has reset all gang respect!", ReturnPlayerName( playerid ), playerid );
	return 1;
}

CMD:hitmanbudget( playerid, params[ ] )
{
	if ( ! IsPlayerAdmin( playerid ) )
		return 0;

	new
		amount;

	if ( sscanf( params, "d", amount ) )
		return SendUsage( playerid, "/hitmanbudget [AMOUNT]" );

	UpdateServerVariable( "hitman_budget", GetGVarInt( "hitman_budget" ) + amount, 0.0, "", GLOBAL_VARTYPE_INT );
	SendServerMessage( playerid, "Hitman budget now currently at %s.", cash_format( GetGVarInt( "hitman_budget" ) ) );
	return 1;
}

CMD:explosiverounds( playerid, params[ ] )
{
	if ( ! IsPlayerAdmin( playerid ) )
		return 0;

	new
		targetid, rounds;

	if ( sscanf( params, "ud", targetid, rounds ) )
		return SendUsage( playerid, "/explosiverounds [PLAYER_ID] [ROUNDS]" );

	p_ExplosiveBullets[ targetid ] += rounds;
	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]{FFFFFF} You've given %s(%d) %d explosive rounds.", ReturnPlayerName( targetid ), targetid, rounds );
	ShowPlayerHelpDialog( targetid, 1500, "You have %d explosive bullets remaining.", p_ExplosiveBullets[ targetid ] );
	return 1;
}

/*CMD:furnishhomes( playerid, params[ ] ) {
	if ( ! IsPlayerAdmin( playerid ) ) return 0;
	for ( new i = 0; i < MAX_HOUSES; i ++ ) if ( g_houseData[ i ] [ E_CREATED ] ) {
		new interior = GetInteriorType( i );
		if ( interior != -1 ) FillHomeWithFurniture( i, interior );
		else SendServerMessage( playerid, "House ID %d has an invalid inteiror", i );
	}
	SendServerMessage( playerid, "All houses have been furnished." );
	return 1;
}

stock GetInteriorType( houseid ) {
	for ( new i = 0; i < sizeof( g_houseInteriors ); i ++ ) {
		if ( IsPointToPoint( 2.0, g_houseInteriors[ i ] [ E_EX ], g_houseInteriors[ i ] [ E_EY ], g_houseInteriors[ i ] [ E_EZ ], g_houseData[ houseid ] [ E_TX ], g_houseData[ houseid ] [ E_TY ], g_houseData[ houseid ] [ E_TZ ] ) )
			return i;
	}
	return -1;
}*/

CMD:updatepool( playerid, params[ ] )
{
	new
		poolid, pool, win, gamble;

	if ( ! IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "ddD(0)D(0)", poolid, pool, win, gamble ) ) return SendError( playerid, "/updatepool [POOL_ID] [POOL_INCREMENT] [TOTAL_WON] [TOTAL_GAMBLED]" );
	else if ( !Iter_Contains( CasinoPool, poolid ) ) return SendError( playerid, "This Pool ID does not exist!" );
	else
	{
		UpdateCasinoPoolData( poolid, pool, win, gamble );
		SendServerMessage( playerid, "You have updated pool id %d", poolid );
	}
	return 1;
}

CMD:destroygang( playerid, params[ ] )
{
	new
	    gID
	;

	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "d", gID ) ) return SendUsage( playerid, "/destroygang [GANG_ID]" );
	else if ( gID < 0 || gID > MAX_GANGS ) return SendError( playerid, "Invalid gang ID." );
	else if ( !Iter_Contains( gangs, gID ) ) return SendError( playerid, "Invalid gang ID." );
	else
	{
		AddAdminLogLineFormatted( "%s(%d) has deleted a gang", ReturnPlayerName( playerid ), playerid );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[GANG]"COL_WHITE" You have destroyed \"%s\" which was the ID of %d.", g_gangData[ gID ] [ E_NAME ], gID );
	    DestroyGang( gID, false );
	}
	return 1;
}

CMD:time( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) )
		return 0;

	new
		timeid;

	if ( sscanf( params, "d", timeid ) )
		return SendUsage( playerid, "/time [SECONDS]" );

	SetWorldClock( timeid );
	return 1;
}

CMD:playsound( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) )
		return 0;

	new
		pID,
		sound;

	if ( sscanf( params, "ud", pID, sound ) )
		return SendUsage( playerid, "/playsound [PLAYER_ID] [SOUND]" );

	PlayerPlaySound( pID, sound, 0.0, 0.0, 0.0 );
	return 1;
}

CMD:addgpci( playerid, params[ ] )
{
	new
	    pID;

	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "u", pID ) ) SendUsage( playerid, "/addgpci [PLAYER_ID]");
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else
	{
		new
			playerserial[ 45 ];

		gpci( pID, playerserial, sizeof( playerserial ) );
	  	AddFileLogLine( "gpci.txt", sprintf( "USER : %s , GPCI : %s\r\n", ReturnPlayerName( pID ), playerserial ) );
	}
	return 1;
}

CMD:vipdiscount( playerid, params[ ] )
{
	new Float: percent;
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "f", percent ) ) return SendUsage( playerid, "/vipdiscount [PERCENTAGE]" );
	// else if ( percent < 50.0 || percent > 100.0 ) return SendError( playerid, "The percentage must be over 50 and less than 100." );
	else
	{
	    SendServerMessage( playerid, "V.I.P discount percentage set to %f! (old = %f)", percent, GetGVarFloat( "vip_discount" ) );
		UpdateServerVariable( "vip_discount", 0, ( 1 - ( percent / 100 ) ), "", GLOBAL_VARTYPE_FLOAT );
    }
	return 1;
}

CMD:vipbonus( playerid, params[ ] )
{
	new Float: percent;
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "f", percent ) ) return SendUsage( playerid, "/vipbonus [PERCENTAGE]" );
	else if ( percent < 0.0 || percent > 100.0 ) return SendError( playerid, "The percentage must be over 0 and less than 100." );
	else
	{
	    SendServerMessage( playerid, "V.I.P bonus percentage set to %f! (old = %f)", percent, GetGVarFloat( "vip_bonus" ) );
		UpdateServerVariable( "vip_bonus", 0, ( percent / 100 ), "", GLOBAL_VARTYPE_FLOAT );
    }
	return 1;
}

CMD:blockip( playerid, params[ ] )
{
	new address[16], timems;
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if (sscanf(params, "ds[16]", timems, address)) SendUsage(playerid, "/blockip [TIME_MS] [IP_ADDRESS]");
	else
	{
		SendClientMessageFormatted( playerid, -1, ""COL_GREY"[BLOCKED]"COL_WHITE" IP %s has been blocked (%d timems).", address, timems );
		BlockIpAddress( address, timems );
	}
	return 1;
}

CMD:unblockip( playerid, params[ ] )
{
	new address[16];
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if (sscanf(params, "s[16]", address)) SendUsage(playerid, "/unblockip [IP_ADDRESS]");
	else
	{
		SendClientMessageFormatted( playerid, -1, ""COL_GREY"[BLOCKED]"COL_WHITE" IP %s has been unblocked.", address );
 		UnBlockIpAddress( address );
	}
	return 1;
}

CMD:svrquery( playerid, params[ ] )
{
	new
		szQuery[ 144 ];

	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "s[144]", szQuery ) ) return SendUsage( playerid, "/svrquery [QUERY]" );
	else if ( p_AccountID[ playerid ] != 1 ) return SendError( playerid, "No." );
	else
	{
		SendServerMessage( playerid, "%s", szQuery );
  		mysql_function_query( dbHandle, szQuery, true, "OnQueryServerViaRCON", "i", playerid );
	}
	return 1;
}

thread OnQueryServerViaRCON( playerid )
{
	new
		rows, fields, affected = cache_affected_rows( );

    cache_get_data( rows, fields );
	SendClientMessageFormatted( playerid, COLOR_YELLOW, "Query Sent. (Rows: %d, Fields: %d, Affected: %d)", rows, fields, affected );
	return 1;
}

CMD:addcomponent( playerid, params[ ] )
{
	new
		componentid;

	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "d", componentid ) ) return SendUsage( playerid, "/addcomponent [COMPONENT_ID]" );
	else if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You need to be in a vehicle." );
	else
	{
		new vehicleid = GetPlayerVehicleID( playerid );
     	AddVehicleComponent( vehicleid, componentid );
     	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" Added componentid id %d to this vehicle.", componentid );
	}
	return 1;
}

CMD:driveby( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	g_Driveby = !g_Driveby;
	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have %s driveby.", g_Driveby == false ? ("enabled") : ("disabled"));
	return 1;
}

CMD:bullets( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	g_ExplosiveBullets = !g_ExplosiveBullets;
	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have %s explosive bullets.", g_ExplosiveBullets == false ? ("enabled") : ("disabled"));
	return 1;
}

CMD:debug( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	g_Debugging = !g_Debugging;
	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have %s debugging.", g_Debugging == true ? ("enabled") : ("disabled"));
	return 1;
}

CMD:vippm( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	g_VipPrivateMsging = !g_VipPrivateMsging;
	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have %s vip only messaging.", g_VipPrivateMsging == true ? ("enabled") : ("disabled"));
	return 1;
}

CMD:logcmd( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	g_CommandLogging = !g_CommandLogging;
	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You are %s commands.", g_CommandLogging == true ? ("logging") : ("not logging"));
	return 1;
}

CMD:logdialog( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	g_DialogLogging = !g_DialogLogging;
	SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You are %s dialogs.", g_DialogLogging == true ? ("logging") : ("not logging"));
	return 1;
}

CMD:settaxrate( playerid, params[ ] )
{
	new Float: rate;
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "f", rate ) ) return SendUsage( playerid, "/settaxrate [PERCENTAGE]" );
	else if ( rate < 0 || rate > 10.0 ) return SendError( playerid, "The rate must be over 0 and less than 10." );
	else
	{
	    SendServerMessage( playerid, "You have changed the tax rate from "COL_GREY"%0.2f"COL_WHITE" to "COL_GREY"%0.2f"COL_WHITE".", GetGVarFloat( "taxrate" ), rate );
		UpdateServerVariable( "taxrate", 0, rate, "", GLOBAL_VARTYPE_FLOAT );
    }
	return 1;
}

CMD:settaxtime( playerid, params[ ] )
{
	new time;
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "d", time ) ) return SendUsage( playerid, "/settaxrate [TIMESTAMP]" );
	else
	{
		if ( time < g_iTime ) {
	    	SendServerMessage( playerid, "Tax time updated. Players to be taxed A.S.A.P.", secondstotime( time - g_iTime ) );
		} else {
	    	SendServerMessage( playerid, "Tax time updated. %s until tax.", secondstotime( time - g_iTime ) );
		}
		UpdateServerVariable( "taxtime", time, 0.0, "", GLOBAL_VARTYPE_INT );
    }
	return 1;
}

CMD:givewanted( playerid, params[ ] )
{
	new
	    pID, wantedlvl
	;
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "ud", pID, wantedlvl ) ) SendUsage( playerid, "/givewanted [PLAYER_ID] [WANTED_LVL]" );
	else if ( !IsPlayerConnected( pID ) ) SendError( playerid, "Invalid Player ID." );
	else
	{
        AddAdminLogLineFormatted( "%s(%d) has gave %s(%d) %d wanted level", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, wantedlvl );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have modified %s(%d)'s wanted level by %d.", ReturnPlayerName( pID ), pID, wantedlvl );
        SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" Your wanted level has been modified by %s(%d).", ReturnPlayerName( playerid ), playerid );
		GivePlayerWantedLevel( pID, wantedlvl );
	}
	return 1;
}

CMD:givescore( playerid, params[ ] )
{
	new
	    pID, score
	;
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "ud", pID, score ) ) SendUsage( playerid, "/givescore [PLAYER_ID] [SCORE]" );
	else if ( !IsPlayerConnected( pID ) ) SendError( playerid, "Invalid Player ID." );
	else
	{
        AddAdminLogLineFormatted( "%s(%d) has given %s(%d)'s %d score", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, score );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have given %s(%d) %d score!", ReturnPlayerName( pID ), pID, score );
        SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have been given %d score from %s(%d)!", score, ReturnPlayerName( playerid ), playerid );
		SetPlayerScore( pID, GetPlayerScore( pID ) + score );
	}
	return 1;
}

CMD:ping( playerid, params[ ] )
{
	new ping;

	if ( !IsPlayerAdmin( playerid ) ) return 0;
	else if ( sscanf( params, "d", ping ) ) return SendUsage( playerid, "/ping [PING]" );
	else if ( ping < 200 ) return SendError( playerid, "The ping cannot be under 200." );
	else
	{
	    g_PingLimit = ping;
		AddAdminLogLineFormatted( "%s(%d) set the ping limit to %d", ReturnPlayerName( playerid ), playerid, ping );
		SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) set the ping limit to %d", ReturnPlayerName( playerid ), playerid, ping );
	}
	return 1;
}

CMD:givexp( playerid, params [ ] )
{
	new
	    pID,
	    level,
	    xp
	;
	if ( !IsPlayerAdmin( playerid ) || ! IsPlayerLeadMaintainer( playerid ) ) return 0;
	else if ( sscanf( params, "udd", pID, level, xp ) ) SendUsage( playerid, "/givexp [PLAYER_ID] [LEVEL_ID] [XP_AMOUNT]" );
	else if ( !IsPlayerConnected( pID ) ) SendError( playerid, "Invalid Player ID." );
	else
	{
		if ( ! GivePlayerExperience( pID, E_LEVELS: level, xp, .with_dilation = false ) ) {
			return SendError( playerid, "You have specified an invalid level." );
		}
        AddAdminLogLineFormatted( "%s(%d) has given %s(%d) %d XP", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, xp );
	    SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]{FFFFFF} %s(%d) has given you %d XP.", ReturnPlayerName( playerid ), playerid, xp );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]{FFFFFF} You've given %s(%d) %d XP.", ReturnPlayerName( pID ), pID, xp );
	}
	return 1;
}

CMD:givesxp( playerid, params [ ] )
{
	new
	    pID,
	    ip
	;
	if ( !IsPlayerAdmin( playerid ) || ! IsPlayerLeadMaintainer( playerid ) ) return 0;
	else if ( sscanf( params, "ud", pID, ip ) ) SendUsage( playerid, "/givesxp [PLAYER_ID] [IP_AMOUNT]" );
	else if ( !IsPlayerConnected( pID ) ) SendError( playerid, "Invalid Player ID." );
	else
	{
	    GivePlayerSeasonalXP( pID, ip );
        //AddAdminLogLineFormatted( "%s(%d) has given %s(%d) %d IP", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, ip );
	   	//SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]{FFFFFF} %s(%d) has given you %d IP.", ReturnPlayerName( playerid ), playerid, ip );
	    //SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]{FFFFFF} You've given %s(%d) %d IP.", ReturnPlayerName( pID ), pID, ip );
	}
	return 1;
}

CMD:givecoins( playerid, params [ ] )
{
	new
	    sendtoid,
	    Float: coins
	;
	if ( !IsPlayerAdmin( playerid ) || ! IsPlayerLeadMaintainer( playerid ) ) return 0;
	else if ( sscanf( params, "uf", sendtoid, coins ) ) SendUsage( playerid, "/givecoins [PLAYER_ID] [COINS]" );
	else if ( !IsPlayerConnected( sendtoid ) ) SendError( playerid, "Invalid Player ID." );
	else
	{
		GivePlayerIrresistibleCoins( sendtoid, coins );
        AddAdminLogLineFormatted( "%s(%d) has given %s(%d) %0.2f IC", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( sendtoid ), sendtoid, coins );
	    SendClientMessageFormatted( sendtoid, -1, ""COL_PINK"[ADMIN]{FFFFFF} %s(%d) has given you %0.2f IC.", ReturnPlayerName( playerid ), playerid, coins );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]{FFFFFF} You've given %s(%d) %0.2f IC.", ReturnPlayerName( sendtoid ), sendtoid, coins );
	}
	return 1;
}

CMD:givecash( playerid, params [ ] )
{
	new
	    pID,
	    cash
	;
	if ( !IsPlayerAdmin( playerid ) || ! IsPlayerLeadMaintainer( playerid ) ) return 0;
	else if ( sscanf( params, "ud", pID, cash ) ) SendUsage( playerid, "/givecash [PLAYER_ID] [CASH]" );
	else if ( !IsPlayerConnected( pID ) ) SendError( playerid, "Invalid Player ID." );
	else
	{
	    GivePlayerCash( pID, cash );
		AddAdminLogLineFormatted( "%s(%d) has given %s(%d) %d dollars", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, cash );
	    SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]{FFFFFF} %s(%d) has given you "COL_GOLD"%s", ReturnPlayerName( playerid ), playerid, cash_format( cash ) );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]{FFFFFF} You've given %s(%d) "COL_GOLD"%s", ReturnPlayerName( pID ), pID, cash_format( cash ) );
	}
	return 1;
}

CMD:setviplevel( playerid, params[ ] )
{
	new
	    pID,
	    level
	;

	if ( !IsPlayerAdmin( playerid ) || ! IsPlayerLeadMaintainer( playerid ) ) return 0;
    else if ( sscanf( params, "ud", pID, level ) ) return SendUsage( playerid, "/setviplevel [PLAYER_ID] [VIP_LEVEL]" );
	else if ( !IsPlayerConnected( pID ) ) SendError( playerid, "Invalid Player ID." );
	else if ( p_PlayerLogged{ pID } == false ) return SendError( playerid, "This player is not logged in." );
	else if ( level > VIP_DIAMOND || level < 0 ) return SendError( playerid, "Specify a level between 0 - 5 please!" );
    else
    {
	    SetPlayerVipLevel( pID, level );
        SendClientMessageFormatted( playerid, -1, ""COL_GOLD"[VIP LEVEL]"COL_WHITE" You have set %s(%d)'s VIP package to %s.", ReturnPlayerName( pID ), pID, VIPToString( level ) );
		SendClientMessageFormatted( pID, -1, ""COL_GOLD"[VIP LEVEL]"COL_WHITE" Your VIP package has been set to %s by %s(%d)", VIPToString( level ), ReturnPlayerName( playerid ), playerid );
    }
	return 1;
}

CMD:extendvip( playerid, params[ ] )
{
	new
	    pID,
	    days
	;

	if ( !IsPlayerAdmin( playerid ) ) return 0;
    else if ( sscanf( params, "ud", pID, days ) ) return SendUsage( playerid, "/extendvip [PLAYER_ID] [DAYS]" );
	else if ( !IsPlayerConnected( pID ) ) SendError( playerid, "Invalid Player ID." );
	else if ( p_VIPLevel[ pID ] < VIP_REGULAR ) return SendError( playerid, "This player doesn't have a V.I.P level." );
	else if ( days < -365 || days > 365 ) return SendError( playerid, "Extension can only vary from -365 to 365 days." );
	else
	{
	    p_VIPExpiretime[ pID ] += ( days ) * 86400;
	    if ( days >= 0 )
	    {
			SendClientMessageFormatted( pID, -1, ""COL_GOLD"[VIP EXTENSION]"COL_WHITE" You have had your V.I.P extended for "COL_GREEN"%d days"COL_WHITE" by %s(%d).", days, ReturnPlayerName( playerid ), playerid );
			SendClientMessageFormatted( playerid, -1, ""COL_GOLD"[VIP EXTENSION]"COL_WHITE" You have extended %s(%d)'s V.I.P for "COL_GREEN"%d days"COL_WHITE".", ReturnPlayerName( pID ), pID, days );
		}
		else
		{
            days = days * -1; // conversion to whole number
			SendClientMessageFormatted( pID, -1, ""COL_GOLD"[VIP EXTENSION]"COL_WHITE" You have had your V.I.P decremented for "COL_RED"%d days"COL_WHITE" by %s(%d).", days, ReturnPlayerName( playerid ), playerid );
			SendClientMessageFormatted( playerid, -1, ""COL_GOLD"[VIP EXTENSION]"COL_WHITE" You have decremented %s(%d)'s V.I.P for "COL_RED"%d days"COL_WHITE".", ReturnPlayerName( pID ), pID, days );
		}
    }
	return 1;
}

CMD:kickall( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) ) return 0;
	SetServerRule( "password", "updating" );
	SendClientMessageToAll( -1, ""COL_PINK"[ADMIN]"COL_WHITE" Everyone has been kicked from the server due to a server update." );
	for ( new i = 0; i < MAX_PLAYERS; i++ ) if ( IsPlayerConnected( i ) && ! IsPlayerNPC( i ) && ! IsPlayerServerMaintainer( i ) ) {
		Kick( i );
	}
	return 1;
}
