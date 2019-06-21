/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc, Stev
 * Module: cnr/commands/admin/_admin.pwn
 * Purpose: encloses all admin related commands
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define ADMIN_COMMAND_REJECT        "You don't have an appropriate administration level to use this command."
#define ADMIN_COMMAND_TIME          4

/* ** Variables ** */
enum E_COMMAND_DATA
{
    E_LEVEL,		E_COMMAND[ 64 ],		E_DESCRIPTION[ 144 ]
};

/* ** Admin Ban Codes ** */
enum E_BAN_CODE
{
	E_CODE[ 4 ], 		E_DATA[ 21 ]
};

static stock
    g_commandData                   [ ] [ E_COMMAND_DATA ] =
    {
    	/* ** Level 1 Commands ** */
        { 1, "/viewdeathmsg",		"Viewing a player death message" },
        { 1, "/arepair",			"Fixing a vehicle" },
        { 1, "/aka",				"Player name changes (also known as)" },
        { 1, "/pinfo",				"Related information about a player" },
        { 1, "/reports",			"Showing the last 8 reports" },
        { 1, "/questions",			"Showing the last 8 questions" },
        { 1, "/respawnalluv",		"Respawning all unused vehicles" },
        { 1, "/aod",				"Admin on Duty mode" },
        { 1, "/asay",				"Speak as a Admin." },
        { 1, "/frules",				"Forcing player to view the rules" },
        { 1, "/fpc",				"Forcing player to view player colors" },
        { 1, "/freeze",				"Freezing a player" },
        { 1, "/unfreeze",			"Unfreezing a player" },
        { 1, "/awep",				"Showing player current weapons" },
        { 1, "/alog",				"Shows administration log textdraw" },
        { 1, "/stopask",			"Blocking/unblocking a player from using /ask" },
        { 1, "/ans",				"Answering a question" },
        { 1, "/respond",			"Responding to a report" },
        { 1, "/aspawn",				"Spawning a player" },
        { 1, "/warn",				"Warning a player" },
        { 1, "/setskin",			"Setting a player s speific skin ID" },
        { 1, "/stopreport",			"Blocking/unblocking a player from using /report" },
        { 1, "/getstats",			"Gettings the stats of a player" },
        { 1, "/a",					"Admin chat" },
        { 1, "/adminmanual",		"Reading the admin manual" },
        { 1, "/slap",				"Slaping a player (default offset = 10)" },
        { 1, "/jail",				"Jailing a player" },
        { 1, "/unjail",				"Unjailing a player" },
        { 1, "/spec",				"Spectating a player" },
        { 1, "/specoff",			"Turning specation mode off" },
        { 1, "/goto",				"Teleporting to a player" },
        { 1, "/mutelist",			"Showing a list of muted players" },

        /* ** Level 2 Commands ** */
		{ 2, "/slay", 				"Slaying a player" },
		{ 2, "/viewnotes", 			"Viewing a players V.I.P notes" },
		{ 2, "/suspend", 			"Suspending a player" },
		{ 2, "/arenas", 			"Showing a dialog of arenas for events" },
		{ 2, "/explode", 			"Exploding a player" },
		{ 2, "/vrespawn", 			"Respawning a vehicle ID" },
		{ 2, "/vdestroy", 			"Destroying a admin vehicle" },
		{ 2, "/mute", 				"Muting a player" },
		{ 2, "/unmute", 			"Unmuting a player" },
		{ 2, "/kick", 				"Kicking a player from the server" },
		{ 2, "/smlog", 				"Cash transaction log from a player" },
		{ 2, "/iclog", 				"IC transaction log from a player" },

		/* ** Level 3 Commands ** */
		{ 3, "/chatban", 			"Bans a player from using all forms of chat" },
		{ 3, "/unchatban", 			"Unbans a player from using all forms of chat" },
		{ 3, "/banlog", 			"Finding ban information about a player" },
		{ 3, "/resetwep", 			"Resetting weapons from a player" },
		{ 3, "/getip", 				"Getting IP of a player" },
		{ 3, "/geolocate", 			"Geographical location of a player" },
		{ 3, "/copwarn", 			"Cop warn a player" },
		{ 3, "/armywarn", 			"Army warn a player" },
		{ 3, "/rcopwarn", 			"Removing a cop warning" },
		{ 3, "/rarmywarn", 			"Removing a army warning" },
		{ 3, "/forcecoptutorial", 	"Forcing a player to view the cop tutorial" },
		{ 3, "/ann", 				"Creates a global annoucement" },
		{ 3, "/announce", 			"Creates a global annoucement" },
		{ 3, "/aheal", 				"Healing a player" },
		{ 3, "/healall", 			"Healing everyone" },
		{ 3, "/vadminstats", 		"Viewing vehicle stats" },
		{ 3, "/vadminpark", 		"Parking a vehicle" },
		{ 3, "/givewep", 			"Giving a player a weapon" },
		{ 3, "/giveweapon", 		"Giving a player a weapon" },
		{ 3, "/cc", 				"Clearing the main chat" },
		{ 3, "/clearchat", 			"Clearing the main chat" },
		{ 3, "/vc", 				"Creating an admin vehicle (short)" },
		{ 3, "/vdestroy", 			"Destroying an admin vehicle" },
		{ 3, "/vbring", 			"Bring a vehicle ID to you" },
		{ 3, "/vgoto", 				"Teleport to a vehicle ID" },
		{ 3, "/venter", 			"Enter a vehicle ID" },
		{ 3, "/vforce", 			"Forcing a player to enter vehicle ID" },
		{ 3, "/hgoto", 				"Teleport to a house" },
		{ 3, "/bgoto", 				"Teleport to a business" },
		{ 3, "/cd", 				"Countdown (short)" },
		{ 3, "/countdown", 			"Countdown" },
		{ 3, "/pingimmune", 		"Making a player immune from ping kicker" },
		{ 3, "/ban", 				"Banning a player" },
		{ 3, "/forceac",			"Force a player to use CAC while playing the server" },
		{ 3, "/bring", 				"Bring a player to you" },

		/* ** Level 4 Commands ** */
		{ 4, "/destroyallav", 		"Destroys all admin spawned vehicles" },
		{ 4, "/event", 				"Set's your world to 69" },
		{ 4, "/setworld", 			"Sets your virtual world" },
		{ 4, "/setinterior", 		"Sets your interior ID" },
		{ 4, "/uncopban", 			"Unbanning a player from cop class" },
		{ 4, "/unarmyban", 			"Unbanning a player from army class" },
		{ 4, "/motd", 				"Sets a Message Of The Day" },
		{ 4, "/resetwepall", 		"Resets all player weapons" },
		{ 4, "/giveweaponall", 		"Gives all players a weapon" },
		{ 4, "/circleall", 			"Teleports all players around in a circle of you (used for events)" },
		{ 4, "/vcreate", 			"Creating a admin vehicle" },
		{ 4, "/gotopos", 			"Teleport to a specifc location X Y Z" },
		{ 4, "/addnote", 			"Attach a note to a player" },
		{ 4, "/removenote", 		"Removing a player note" },

		/* ** Level 5 Commands ** */
		{ 5, "/armorall",			"Giving everyone armour" },
		{ 5, "/givearmour",			"Giving a player an armour set" },
		{ 5, "/givearmor",			"Giving a player an armour set" },
		{ 5, "/check", 				"Checking a players serial" },
		{ 5, "/c", 					"Council chat" },
		{ 5, "/creategarage", 		"Creating a garage" },
		{ 5, "/destroygarage", 		"Deletes a garage" },
		{ 5, "/connectsong", 		"Changes the conneciton song" },
		{ 5, "/discordurl", 		"Updating the discord invite URL" },
		{ 5, "/creategate", 		"Creating a gate" },
		{ 5, "/editgate", 			"Editing a gate" },
		{ 5, "/acunban", 			"Unbanning a player from AC" },
		{ 5, "/safeisbugged", 		"Debug command for robbery safes" },
		{ 5, "/replenishsafe", 		"Fixes bugged robbery safes" },
		{ 5, "/autovehrespawn", 	"Setting auto respawn for vehicles" },
		{ 5, "/megaban", 			"The Mega Ban" },
		{ 5, "/achangename", 		"Change a players name" },
		{ 5, "/unbanip", 			"Unbanning a IP address" },
		{ 5, "/unban", 				"Unban a player from the server" },
		{ 5, "/unforceac", 			"Unforce a player from using CAC" },
		{ 5, "/doublexp", 			"Enable/disable double XP" },
		{ 5, "/toggleviewpm", 		"Toggle to view private messages" },
		{ 5, "/respawnallv", 		"Respawning all server vehicles" },
		{ 5, "/reconnectchuff", 	"Reconnecting the ChuffSec NPC" },
		{ 5, "/createbribe", 		"Creates a bribe" },
		{ 5, "/destroybribe", 		"Deletes a bribe " },
		{ 5, "/createcar", 			"Create owned vehicle" },
		{ 5, "/destroycar", 		"Deletes owned vehicle" },
		{ 5, "/stripcarmods", 		"Removing all vehicle modifications" },
		{ 5, "/createhouse", 		"Creating a house" },
		{ 5, "/destroyhouse", 		"Deleting a house" },
		{ 5, "/hadminsell", 		"Selling a house (as admin)" },
		{ 5, "/createbusiness", 	"Creates a business" },
		{ 5, "/destroybusiness", 	"Deletes a business" },
		{ 5, "/seteventhost",		"Setting event host to player" },
		{ 5, "/weather",			"Settings world weather" },
		{ 5, "/viewpolicechat", 	"Viewing the police radio/chat" },
		{ 5, "/viewpbchat", 		"Viewing all paintball lobbies chats" },

		/* ** Level 6 Commands ** */
		{ 6, "/reloadeditor",		"Reloads object editer script" },
		{ 6, "/createentrance",		"Creates a entrance" },
		{ 6, "/destroyentrance",	"Deleting a entrance" },
		{ 6, "/setgangleader",		"Settings a player into a gang leader" },
		{ 6, "/viewgangtalk",		"Viewing gang chat" },
		{ 6, "/broadcast",			"Broadcasting a music stream" },
		{ 6, "/setlevel",			"Setting a players admin level " },
		{ 6, "/setleveloffline",	"Setting a players admin level offline" },
		{ 6, "/svrstats",			"Show server statistics" },
		{ 6, "/playaction",			"Playing a action" },
		{ 6, "/playanimation",		"Playing an animation" },
		{ 6, "/updaterules",		"Updating the server rules" },
		{ 6, "/truncate",			"Truncating a account" }
    },
    g_banCodes 						[ ] [ E_BAN_CODE ] =
	{
		{ "AH",  "Armor Hacking" },
		{ "HH",  "Health Hacking" },
		{ "VHH", "Vehicle Health Hacks" },
		{ "NR",  "No Reload" },
		{ "IA",  "Infinite Ammo" },
		{ "FH",  "Fly Hacks" },
		{ "BE",  "Ban Evasion" },
		{ "AB",  "Air Brake" },
		{ "TP",  "Teleport Hacks" },
		{ "WH",  "Weapon Hack" },
		{ "SH",  "Speed Hacks" },
		{ "UA",  "Unlimited Ammo" },
		{ "RF",  "Rapid Fire" },
		{ "AIM", "Aimbot" },
		{ "ADV", "Advertising" }
	}
;

/* ** Commands ** */
CMD:acommands( playerid, params[ ] ) return cmd_acmds( playerid, params );
CMD:acmds( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 1 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	szNormalString[ 0 ] = '\0';

	for (new iPos = 1; iPos != 7; iPos ++)
	{
		format( szNormalString, sizeof( szNormalString ), "%sAdmin Level %d Commands\n", szNormalString, iPos );
	}

	ShowPlayerDialog( playerid, DIALOG_ADMIN_CMDS, DIALOG_STYLE_LIST, ""COL_PINK"Admin Commands", szNormalString, "Select", "Cancel" );
    return 1;
}

/* ** Functions ** */
stock adhereBanCodes( string[ ], maxlength = sizeof( string ) )
{
    for( new i; i < sizeof( g_banCodes ); i++ )
    {
    	if ( strfind( string, g_banCodes[ i ] [ E_CODE ], false ) != -1 )
    	{
			strreplace( string, g_banCodes[ i ] [ E_CODE ], g_banCodes[ i ] [ E_DATA ], false, 0, -1, maxlength );
		}
	}
	return 1;
}


/* ** Hooks ** */
hook OnDialogResponse( playerid, dialogid, response, listitem, inputtext[ ] )
{
	if ( dialogid == DIALOG_ADMIN_CMDS && response )
	{
		szHugeString[ 0 ] = '\0';

		new
			level = ( listitem + 1 );

		if ( p_AdminLevel[ playerid ] < level )
			return SendError( playerid, "You don't have permission to view these admin commands." ), cmd_acmds( playerid, "" );

		for ( new iLine = 0; iLine < sizeof( g_commandData ); iLine ++ ) if ( g_commandData[ iLine ][ E_LEVEL ] == level )
		{
			format( szHugeString, sizeof( szHugeString ), "%s"COL_GREY"%s\t"COL_WHITE"%s\n",
			szHugeString,
			g_commandData[ iLine ][ E_COMMAND ],
			g_commandData[ iLine ][ E_DESCRIPTION ]);
		}

		ShowPlayerDialog( playerid, DIALOG_ADMIN_CMDS_BACK, DIALOG_STYLE_TABLIST, sprintf( ""COL_PINK"Admin Level %d Commands", level ), szHugeString, "Back", "" );
		return 1;
	}

	else if ( dialogid == DIALOG_ADMIN_CMDS_BACK && response )
	{
		return cmd_acmds( playerid, "" ), 1;
	}

	return 1;
}

/* ** Modules ** */
#include "irresistible\cnr\commands\admin\admin_one.pwn"
#include "irresistible\cnr\commands\admin\admin_two.pwn"
#include "irresistible\cnr\commands\admin\admin_three.pwn"
#include "irresistible\cnr\commands\admin\admin_four.pwn"
#include "irresistible\cnr\commands\admin\admin_five.pwn"
#include "irresistible\cnr\commands\admin\admin_six.pwn"
#include "irresistible\cnr\commands\admin\admin_rcon.pwn"
