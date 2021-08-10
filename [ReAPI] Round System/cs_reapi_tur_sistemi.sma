#include <amxmodx>
#include <reapi>

// Eklenti bilgileri.
#define PLUGIN "[ReAPI] Tur Sistemi"
#define VERSION "1.0"
#define AUTHOR "Multipower"

// Bazi sabitler (Sunucunuza gore degisebilirsiniz).
#define TASK_DEGISIM 004
#define MAX_ROUND 30
#define TEAM_SWAP_ROUND 15
#define CHAT_TAG "[DPCS]"

// Bilgiler
new tur
new skor_t
new skor_ct

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("tur_sistemi",AUTHOR,FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
	
	register_event("TextMsg", "isinma", "a", "2=#Game_will_restart_in")
	register_event("HLTV", "tur_basi", "a", "1=0", "2=0")
	register_event("SendAudio", "CT_Win", "a", "2&%!MRAD_ctwin")
	register_event("SendAudio", "T_Win", "a", "2&%!MRAD_terwin")
	
	RegisterHookChain(RG_RoundEnd, "tur_sonu", .post=true)
	
}

public client_putinserver(id)
{
	set_task(1.0, "HudGoster", id, _, _, "b") // Oyuncu baglaninca bilgi hudunu gosterir.
}

public client_disconnected(id)
{
	remove_task(id)
}

public isinma() // Restart atilinca round bilgilerini sifirlar.
{
	tur = 0
	skor_ct = 0
	skor_t = 0
}

public tur_basi() // Tur basi tur bilgilerini chatte gosterir.
{
	tur++

	new map[32]
	get_mapname(map, 31)
	client_print_color(0,0, "^4%s ^3Tur: ^4%d ^3/^4 %d", CHAT_TAG, tur, MAX_ROUND)
}

public tur_sonu() // MAX_ROUND degerine gelince harita degisir, TEAM_SWAP_ROUND degerine gelince takimlari degisir.
{
	new gelecekmap[32]
	get_cvar_string("amx_nextmap", gelecekmap, 31)
	
	if(tur == MAX_ROUND)
	{
		client_print_color(0,0, "^4%s^3 %s ^4Aciliyor.", CHAT_TAG, gelecekmap)
		client_print_color(0,0, "^4%s^3 %s ^4Aciliyor.", CHAT_TAG, gelecekmap)	
		client_print_color(0,0, "^4%s^3 %s ^4Aciliyor.", CHAT_TAG, gelecekmap)	
		client_print_color(0,0, "^4%s^3 %s ^4Aciliyor.", CHAT_TAG, gelecekmap)	
		client_print_color(0,0, "^4%s^3 %s ^4Aciliyor.", CHAT_TAG, gelecekmap)
		set_task(4.0, "haritadegis")
	}
	
	if(tur == TEAM_SWAP_ROUND)
	{
		set_task(1.0, "takimlari_degis", TASK_DEGISIM)
	}
	
}

public haritadegis() // Haritayi degisir.
{
	new smap[32]
	get_cvar_string("amx_nextmap", smap, 31)

	server_cmd("changelevel %s", smap)
}
	
public takimlari_degis() // Takimlari degisir.
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
		client_print_color(0,0, "^4%s^3 Takimlar Degistiriliyor.", CHAT_TAG)		
		client_print_color(0,0, "^4%s^3 Takimlar Degistiriliyor.", CHAT_TAG)		
		client_print_color(0,0, "^4%s^3 Takimlar Degistiriliyor.", CHAT_TAG)
		client_print_color(0,0, "^4%s^3 Takimlar Degistiriliyor.", CHAT_TAG)
		skor_t = 0
		skor_ct = 0
	}
	remove_task(TASK_DEGISIM)
}

public T_Win() // Terorist skorunu ceker.
{
	skor_t++
}

public CT_Win() // CT skorunu ceker.
{
	skor_ct++
}

public HudGoster() // Ekranda tur bilgilerini gosterir.
{
	set_dhudmessage(255, 255, 255, -1.0, 0.0, 0, 6.0, 1.0)
	show_dhudmessage(0, "| CT:%d | (%d / %d) | T:%d |", skor_ct, tur, MAX_ROUND, skor_t)
}
