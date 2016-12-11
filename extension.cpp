#include <sourcemod_version.h>
#include "extension.h"

IGameConfig *g_pGameConf = NULL;
IMemoryUtils *memutils = NULL;

Cleaner g_Cleaner;
SMEXT_LINK(&g_Cleaner);

CDetour *g_pDetour = 0;
CDetour *g_pPrintf = 0;

char ** g_szStrings;
int g_iStrings = 0;

#if SOURCE_ENGINE >= SE_LEFT4DEAD2
DETOUR_DECL_MEMBER4(Detour_LogDirect, LoggingResponse_t, LoggingChannelID_t, channelID, LoggingSeverity_t, severity, Color, color, const tchar *, pMessage)
{
	for(int i=0;i<g_iStrings;++i)
		if(strstr(pMessage, g_szStrings[i])!=0)
			return LR_CONTINUE;
	return DETOUR_MEMBER_CALL(Detour_LogDirect)(channelID, severity, color, pMessage);
}
#else
DETOUR_DECL_STATIC2(Detour_DefSpew, SpewRetval_t, SpewType_t, channel, char *, text)
{
	for(int i=0;i<g_iStrings;++i)
		if(strstr(text, g_szStrings[i])!=0)
			return SPEW_CONTINUE;
	return DETOUR_STATIC_CALL(Detour_DefSpew)(channel, text);
}
#endif

bool Cleaner::SDK_OnLoad(char *error, size_t maxlength, bool late)
{
	SM_GET_IFACE(MEMORYUTILS, memutils);
	CDetourManager::Init(g_pSM->GetScriptingEngine(), 0);

	char szPath[256];
	g_pSM->BuildPath(Path_SM, szPath, sizeof(szPath), "configs/cleaner.cfg");
	FILE * file = fopen(szPath, "r");

	if(file==NULL)
	{
		snprintf(error, maxlength, "Could not read configs/cleaner.cfg.");
		return false;
	}

	int lines = 0;
	char str[255];
	while(!feof(file))
	{
		fgets(str, 255, file);
		++lines;
	}

	rewind(file);

	int len;
	g_szStrings = (char**)malloc(lines*sizeof(char**));
	while(!feof(file))
	{
		g_szStrings[g_iStrings] = (char*)malloc(256*sizeof(char*));
		fgets(g_szStrings[g_iStrings], 255, file);
		len = strlen(g_szStrings[g_iStrings]);
		if(g_szStrings[g_iStrings][len-1]=='\r' || g_szStrings[g_iStrings][len-1]=='\n')
				g_szStrings[g_iStrings][len-1]=0;
		if(g_szStrings[g_iStrings][len-2]=='\r')
				g_szStrings[g_iStrings][len-2]=0;
		++g_iStrings;
	}
	fclose(file);

#if SOURCE_ENGINE >= SE_LEFT4DEAD2
	char ConfigError[128];
	if(!gameconfs->LoadGameConfigFile("cleaner", &g_pGameConf, ConfigError, sizeof(ConfigError)))
	{
		if (error)
		{
			snprintf(error, maxlength, "cleaner.txt error : %s", ConfigError);
		}
		return false;
	}
	
#ifdef PLATFORM_WINDOWS
	HMODULE tier0 = GetModuleHandle("tier0.dll");
	char sig[256];
	size_t size = UTIL_StringToSignature(g_pGameConf->GetKeyValue("ServerConsolePrintSig_windows"), sig, sizeof(sig)));
	void * fn = memutils->FindPattern(tier0, sig, size);
#elif defined PLATFORM_LINUX
	void * tier0 = dlopen("libtier0.so", RTLD_NOW);
	void * fn = memutils->ResolveSymbol(tier0, g_pGameConf->GetKeyValue("ServerConsolePrintSig_linux"));
#elif defined PLATFORM_APPLE
	void * tier0 = dlopen("libtier0.dylib", RTLD_NOW);
	void * fn = memutils->ResolveSymbol(tier0, g_pGameConf->GetKeyValue("ServerConsolePrintSig_mac"));
#endif
	if(!fn)
	{
		snprintf(error, maxlength, "Failed to find signature. Please contact the author.");
		return false;
	}
#endif

#if SOURCE_ENGINE == SE_CSGO
#ifdef PLATFORM_LINUX
	int offset = 0;
	if (!g_pGameConf->GetOffset("ServerConsolePrint", &offset))
	{
		snprintf(error, maxlength, "Failed to get ServerConsolePrint offset.");
		return false;
	}

	fn = (void *)((intptr_t)fn + offset);
#endif
#endif

#if SOURCE_ENGINE >= SE_LEFT4DEAD2
	g_pDetour = DETOUR_CREATE_MEMBER(Detour_LogDirect, fn);
#else
	g_pDetour = DETOUR_CREATE_STATIC(Detour_DefSpew, (gpointer)GetSpewOutputFunc());
#endif
	
	if (g_pDetour == NULL)
	{
		snprintf(error, maxlength, "Failed to initialize the detours. Please contact the author.");
		return false;
	}

	g_pDetour->EnableDetour();

	return true;
}

void Cleaner::SDK_OnUnload()
{
	if(g_pDetour)
		g_pDetour->Destroy();

	delete [] g_szStrings;
#if SOURCE_ENGINE >= SE_LEFT4DEAD2
	gameconfs->CloseGameConfigFile(g_pGameConf);
#endif
}

void Cleaner::SDK_OnAllLoaded()
{
}
