#include <amxmodx>
#include <reapi>

// Plugin Information
#define PLUGIN "[ReAPI] Round System"
#define VERSION "1.0"
#define AUTHOR "Multipower"

// Defines (You can set it according to your server)
#define TASK_CHANGE 004		// TASK Change (Don't edit)
#define MAX_ROUND 30		// How many rounds should a game have?
#define TEAM_SWAP_ROUND 15	// In which round should you change teams?
#define CHAT_TAG "[DPCS]"	// Chat tag

// Round System Vars
new round
new skor_t
new skor_ct

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("reapi_round",VERSION,FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
	
	register_event("TextMsg", "restart_round", "a", "2=#Game_will_restart_in")
	register_event("HLTV", "round_start", "a", "1=0", "2=0")
	register_event("SendAudio", "CT_Win", "a", "2&%!MRAD_ctwin")
	register_event("SendAudio", "T_Win", "a", "2&%!MRAD_terwin")
	
	RegisterHookChain(RG_RoundEnd, "round_end", .post=true)
	
}

public client_putinserver(id)
{
	set_task(1.0, "ShowHud", id, _, _, "b") // When the user is connected, it makes the hud appear on the screen.
}

public client_disconnected(id)
{
	remove_task(id)
}

public restart_round() // It resets all round data when the server is restarted.
{
	round = 0 
	skor_ct = 0
	skor_t = 0
}

public round_start() // When the round starts, it appears round information in the chat.
{
	round++

	new map[32]
	get_mapname(map, 31)
	client_print_color(0,0, "^4%s ^3Round: ^4%d ^3/^4 %d", CHAT_TAG, round, MAX_ROUND)
}

public round_end() // Changes the map when MAX_ROUND is reached. Changes teams when TEAM_SWAP_ROUND is reached.
{
	new nextmap[32]
	get_cvar_string("amx_nextmap", nextmap, 31)
	
	if(round == MAX_ROUND)
	{
		client_print_color(0,0, "^4%s^3 %s ^4Aciliyor.", CHAT_TAG, nextmap)
		client_print_color(0,0, "^4%s^3 %s ^4Aciliyor.", CHAT_TAG, nextmap)	
		client_print_color(0,0, "^4%s^3 %s ^4Aciliyor.", CHAT_TAG, nextmap)	
		client_print_color(0,0, "^4%s^3 %s ^4Aciliyor.", CHAT_TAG, nextmap)	
		client_print_color(0,0, "^4%s^3 %s ^4Aciliyor.", CHAT_TAG, nextmap)
		set_task(4.0, "change_map")
	}
	
	if(round == TEAM_SWAP_ROUND)
	{
		set_task(1.0, "change_teams", TASK_CHANGE)
	}
	
}

public change_map() // Changes map
{
	new smap[32]
	get_cvar_string("amx_nextmap", smap, 31)

	server_cmd("changelevel %s", smap)
}
	
public change_teams() // Swaps teams
{
	new players[32], num
	get_players(players, num)
	
	new player
	for(new i = 0; i < num; i++)
	{
		player = players[i]
		
		if(get_member(player, m_iTeam) == TEAM_TERRORIST)
		{
			rg_set_user_team(player, TEAM_CT)
		}
		else if(get_member(player, m_iTeam) == TEAM_CT)
		{
			rg_set_user_team(player, TEAM_TERRORIST)
		}
		client_print_color(0,0, "^4%s^3 Teams Swapping.", CHAT_TAG)		
		client_print_color(0,0, "^4%s^3 Teams Swapping.", CHAT_TAG)		
		client_print_color(0,0, "^4%s^3 Teams Swapping.", CHAT_TAG)
		client_print_color(0,0, "^4%s^3 Teams Swapping.", CHAT_TAG)
		skor_t = 0
		skor_ct = 0
	}
	remove_task(TASK_CHANGE)
}

public T_Win() // Gets the terrorists' score information
{
	skor_t++
}

public CT_Win() // Gets the CTs' score information
{
	skor_ct++
}

public ShowHud() // Shows hud on player's screen
{
	set_dhudmessage(255, 255, 255, -1.0, 0.0, 0, 6.0, 1.0)
	show_dhudmessage(0, "|CT:%d| (%d / %d) |T:%d|", skor_ct, round, MAX_ROUND, skor_t)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
