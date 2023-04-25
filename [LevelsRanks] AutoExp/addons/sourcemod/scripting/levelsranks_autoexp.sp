#include <sourcemod>
#include <lvl_ranks>
#include <clientprefs>

#define PLUGIN_NAME "[LR] Module - AutoGiveXP"
#define PLUGIN_AUTHOR "[Pandora] - Guiyomee"

int g_iLevel,
    g_iXpGive;
float g_iXpTimer;

public Plugin myinfo = {name = PLUGIN_NAME, author = PLUGIN_AUTHOR, version = PLUGIN_VERSION};

public void OnPluginStart()
{
    if(LR_IsLoaded())
    {
        LR_OnCoreIsReady();
    }
    LoadTranslations("lr_module_giveexp.phrases");
    ConfigLoad();
}

public void LR_OnCoreIsReady()
{
    if(LR_GetSettingsValue(LR_TypeStatistics))
    {
        SetFailState(PLUGIN_NAME ... " : This module will work if [ lr_type_statistics 0 ]");
    }
}

void ConfigLoad()
{
    static char sPath[PLATFORM_MAX_PATH];
    if(!sPath[0]) BuildPath(Path_SM, sPath, sizeof(sPath), "configs/levels_ranks/autogivexp.ini");
    KeyValues hLR = new KeyValues("LR_AutoGiveXP");

    if(!hLR.ImportFromFile(sPath))
    {
        SetFailState(PLUGIN_NAME ... " : File is not found (%s)", sPath);
    }

    g_iLevel = hLR.GetNum("rank", 0);
    g_iXpGive = hLR.GetNum("value", 0);
    g_iXpTimer = hLR.GetFloat("timer", 300.0);

    CreateTimer(g_iXpTimer, GiveExp, _, TIMER_REPEAT);
    hLR.Close();
}

public Action GiveExp(Handle timer)
{
    char sText[64];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(g_iLevel >= LR_GetClientInfo(i, ST_RANK) && IsClientInGame(i))
        {
            FormatEx(sText, sizeof(sText), "%T", "GiveExp", i);
            LR_ChangeClientValue(i, g_iXpGive);
            PrintToChat(i, "%s %d XP", sText, g_iXpGive);
        }
    }

    return Plugin_Continue;
}
