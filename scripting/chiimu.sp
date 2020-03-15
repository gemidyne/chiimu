#pragma semicolon 1

#include <sourcemod>

#pragma newdecls required

#define PLUGIN_VERSION "1.0.0"

#define NAMES_CAPACITY 256
#define NAMES_LINE_CAPACITY 64

int g_iLoadedNamesCount = 0;
char g_sNames[NAMES_CAPACITY][NAMES_LINE_CAPACITY];

Handle g_hRedTeamName = INVALID_HANDLE;
Handle g_hBlueTeamName = INVALID_HANDLE;

public Plugin myinfo = 
{
	name = "Chiimu",
	author = "Gemidyne Softworks",
	description = "Changes team names on map start to a random string defined in a txt file",
	version = PLUGIN_VERSION,
	url = "https://www.gemidyne.com/"
}

public void OnPluginStart()
{
    g_hRedTeamName = FindConVar("mp_tournament_redteamname");
    g_hBlueTeamName = FindConVar("mp_tournament_blueteamname");
    
    if (g_hRedTeamName == INVALID_HANDLE || g_hBlueTeamName == INVALID_HANDLE)
    {
        SetFailState("Unable to find mp_tournament_redteamname or mp_tournament_blueteamname ConVars");
    }

	LoadNames();
}

public void OnMapStart()
{
	SetRedTeamName();
	SetBlueTeamName();
}

stock void LoadNames()
{
	char path[128];
	BuildPath(Path_SM, path, sizeof(path), "data/chiimu/names.txt");

	Handle file = OpenFile(manifestPath, "r");

	if (file == INVALID_HANDLE)
	{
        SetFailState("Unable to find a names.txt in data/chiimu/names.txt");
	}

	char line[NAMES_LINE_CAPACITY];

	while (ReadFileLine(file, line, sizeof(line)))
	{
		if (g_iLoadedNamesCount >= NAMES_CAPACITY)
		{
			LogError("Unable to load any more names - hit names limit");
			break;
		}

		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		g_sNames[g_iLoadedNamesCount] = line;
		g_iLoadedNamesCount++;
	}

	CloseHandle(file);

	if (g_iLoadedNamesCount <= 1)
	{
        SetFailState("More than one team name must be defined in data/chiimu/names.txt");
	}
}

stock SetRedTeamName()
{
	char current[NAMES_LINE_CAPACITY];
	GetConVarString(g_hRedTeamName, current, NAMES_LINE_CAPACITY);

	char newName[NAMES_LINE_CAPACITY];

	do
	{
		int idx = GetRandomInt(0, g_iLoadedNamesCount);

		strcopy(newName, NAMES_LINE_CAPACITY, g_sNames[idx]);
	}
	while (StrEqual(newName, current, false));

	SetConVarString(g_hRedTeamName, newName, true, true);
}

stock SetBlueTeamName()
{
	char current[NAMES_LINE_CAPACITY];
	GetConVarString(g_hBlueTeamName, current, NAMES_LINE_CAPACITY);

	char redTeamName[NAMES_LINE_CAPACITY];
	GetConVarString(g_hRedTeamName, redTeamName, NAMES_LINE_CAPACITY);

	char newName[NAMES_LINE_CAPACITY];

	do
	{
		int idx = GetRandomInt(0, g_iLoadedNamesCount);

		strcopy(newName, NAMES_LINE_CAPACITY, g_sNames[idx]);
	}
	while (StrEqual(newName, current, false) || StrEqual(newName, redTeamName, false));

	SetConVarString(g_hBlueTeamName, newName, true, true);
}