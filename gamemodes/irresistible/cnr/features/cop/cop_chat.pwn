/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\cop\cop_chat.pwn
 * Purpose: chat system for police (team) ... includes a 10-code feature
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Variables ** */
enum E_TEN_CODES
{
	E_CODE[ 6 ], 		E_SUBJECT[ 50 ]
};

static stock
	g_coptenCodes[ ] [ E_TEN_CODES ] =
	{
		{ "10-10", "Fight in progress" }, 						{ "10-11", "Robbery" },
		{ "10-12", "Stand by" }, 								{ "10-13", "Weather - road report" },
		{ "10-14", "Prowler report" }, 							{ "10-15", "Traffic check" },
		{ "10-16", "Domestic disturbance" }, 					{ "10-17", "Meet complainant" },
		{ "10-18", "Quickly" },									{ "10-19", "Return to" },
		{ "10-20", "Location" }, 								{ "10-21", "By telephone, call" },
		{ "10-22", "Disregard" }, 								{ "10-23", "Arrived at scene" },
		{ "10-24", "Assignment completed" }, 					{ "10-25", "Report in person" },
		{ "10-26", "Detaining subject, expedite" },				{ "10-27", "Drivers license information" },
		{ "10-28", "Vehicle registration information" },		{ "10-29", "Check for wanted" },
		{ "10-30", "Unnecessary use of radio" }, 				{ "10-31", "Crime in progress" },
		{ "10-32", "Man with gun" }, 							{ "10-33", "Emergency" },
		{ "10-34", "Riot" },									{ "10-35", "Major crime alert" },
		{ "10-36", "Correct time" }, 							{ "10-37", "(Investigate) suspicious vehicle" },
		{ "10-38", "Stopping suspicious vehicle" }, 			{ "10-39", "Urgent - use light, siren" },
		{ "10-40", "Silent run - no light, siren" }, 			{ "10-41", "Beginning tour of duty" },
		{ "10-42", "Ending tour of duty" }, 					{ "10-43", "Information" },
		{ "10-44", "Permission to leave for" }, 				{ "10-45", "Kidnapping" },
		{ "10-46", "Assist motorist" }, 						{ "10-47", "Emergency road repairs at" },
		{ "10-48", "Traffic standard repair at" }, 				{ "10-49", "Traffic light out at" },
		{ "10-50", "Accident" }, 								{ "10-51", "Wrecker needed" },
		{ "10-52", "Ambulance needed" }, 						{ "10-53", "Road blocked at" },
		{ "10-54", "Livestock on highway" }, 					{ "10-55", "Suspected DUI" },
		{ "10-56", "Intoxicated pedestrian" }, 					{ "10-57", "Hit and run" },
		{ "10-58", "Direct traffic" }, 							{ "10-59", "Convoy or escort" },
		{ "10-60", "Squad in vicinity" }, 						{ "10-61", "Isolate self for message" },
		{ "10-62", "Reply to message" }, 						{ "10-63", "Prepare to make written copy" },
		{ "10-64", "Message for local delivery" }, 				{ "10-65", "Net message assignment" },
		{ "10-66", "Message cancellation" }, 					{ "10-67", "Clear for net message" },
		{ "10-68", "Dispatch information" }, 					{ "10-69", "Message received" },
		{ "10-70", "Fire" }, 									{ "10-71", "Advise nature of fire" },
		{ "10-72", "Report progress on fire" }, 				{ "10-73", "Smoke report" },
		{ "10-74", "Negative" }, 								{ "10-75", "In contact with" },
		{ "10-76", "Bribe" }, 									{ "10-77", "ETA" },
		{ "10-78", "Need assistance" }, 						{ "10-79", "Notify coroner" },
		{ "10-80", "Chase in progress" }, 						{ "10-81", "Drug Activity" },
		{ "10-82", "Reserve lodging" }, 						{ "10-83", "Suspect Hidden on Radar" },
		{ "10-84", "If meeting, advise ETA" }, 					{ "10-85", "Delayed due to" },
		{ "10-86", "Officer on duty" }, 						{ "10-87", "Pick up/distribute checks" },
		{ "10-88", "Present telephone number of" }, 			{ "10-89", "Bomb threat" },
		{ "10-90", "Bank alarm at" }, 							{ "10-91", "Pick up prisoner/subject" },
		{ "10-92", "Improperly parked vehicle" }, 				{ "10-93", "Blockade" },
		{ "10-94", "Drag racing" }, 							{ "10-95", "Prisoner/subject in custody" },
		{ "10-96", "Mental subject" }, 							{ "10-97", "Check signal" },
		{ "10-98", "Prison/jail break" }, 						{ "10-99", "Wanted/stolen indicated" },
		// Some bug, so I'll do this.
	    { "10-0", "Caution" }, 									{ "10-1", "Unable to copy" },
		{ "10-2", "Signal good" }, 								{ "10-3", "Stop transmitting" },
		{ "10-4", "Acknowledgment" }, 							{ "10-5", "Relay" },
		{ "10-6", "Busy, stand by unless urgent" },				{ "10-7", "Out of service" },
		{ "10-8", "In service" }, 								{ "10-9", "Repeat" }
	}
;

/* ** Hooks ** */
hook OnPlayerText( playerid, text[ ] )
{
	if ( text[ 0 ] == '!' && ! IsPlayerSettingToggled( playerid, SETTING_CHAT_PREFIXES ) )
	{
        if ( p_Class[ playerid ] == CLASS_POLICE && ! IsPlayerChatBanned ( playerid ) )
        {
            format( szBigString, 144, "%s", text );

            for ( new i = 0; i < sizeof( g_coptenCodes ); i++ ) if ( strfind( szBigString, g_coptenCodes[ i ] [ E_CODE ] ) != -1 ) {
                strreplace( szBigString, g_coptenCodes[ i ] [ E_CODE ], g_coptenCodes[ i ] [ E_SUBJECT ] );
            }

            SendClientMessageToCops( -1, ""COL_BLUE"<Police Radio> %s(%d):"COL_WHITE" %s", ReturnPlayerName( playerid ), playerid, szBigString[ 1 ] );

            foreach ( new i : Player ) if ( ( p_AdminLevel[ i ] >= 5 || IsPlayerUnderCover( i ) ) && p_ToggleCopChat{ i } == true ) {
                SendClientMessageFormatted( i, -1, ""COL_BLUE"<Police Radio> %s(%d):"COL_GREY" %s", ReturnPlayerName( playerid ), playerid, szBigString[ 1 ] );
            }
            return 0;
        }

        else if ( p_Class[ playerid ] == CLASS_CIVILIAN && p_GangID[ playerid ] != INVALID_GANG_ID )
        {
            SendClientMessageToGang( p_GangID[ playerid ], g_gangData[ p_GangID[ playerid ] ] [ E_COLOR ], "<Gang Chat> %s(%d):{FFFFFF} %s", ReturnPlayerName( playerid ), playerid, text[ 1 ] );
            return 0;
        }
    }
    return 1;
}

/* ** Commands ** */
CMD:t( playerid, params[ ] )
{
	new
	    msg[ 90 ]
	;

	if ( GetPlayerClass( playerid ) != CLASS_POLICE ) return SendError( playerid, "Only police can use this command!" );
    else if ( IsPlayerChatBanned( playerid ) ) return SendError( playerid, "You can not use this feature as you are chat banned." );
	else if ( sscanf( params, "s[90]", msg ) ) return SendUsage( playerid, "/t [MESSAGE]" );
    else
	{
		if ( p_Class[ playerid ] == CLASS_POLICE )
		{
			format( szBigString, 144, "%s", msg );

			for ( new i = 0; i < sizeof( g_coptenCodes ); i++ ) if ( strfind( szBigString, g_coptenCodes[ i ] [ E_CODE ] ) != -1 ) {
		        strreplace( szBigString, g_coptenCodes[ i ] [ E_CODE ], g_coptenCodes[ i ] [ E_SUBJECT ] );
			}

			SendClientMessageToCops( -1, ""COL_BLUE"<Police Radio> %s(%d):"COL_WHITE" %s", ReturnPlayerName( playerid ), playerid, szBigString );
		}
	}
	return 1;
}
