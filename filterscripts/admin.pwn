#include <YSI\y_ini>

#define DIALOG_REGISTER 11
#define DIALOG_LOGIN 12
#define DIALOG_SUCCESS_1 13
#define DIALOG_SUCCESS_2 14

#define PATH "FDAdmin/Users/%s.ini"

#define COL_WHITE "{FFFFFF}"
#define COL_RED "{F81414}"
#define COL_GREEN "{00FF22}"
#define COL_LIGHTBLUE "{00CED1}"

enum pInfo
{
    pPass,
    pCash,
    pAdmin,
    pKills,
    pDeaths
}
new PlayerInfo[MAX_PLAYERS][pInfo];

forward LoadUser_data(playerid,name[],value[]);
public LoadUser_data(playerid,name[],value[])
{
	INI_Int("Password",PlayerInfo[playerid][pPass]);
	INI_Int("Cash",PlayerInfo[playerid][pCash]);
	INI_Int("Admin",PlayerInfo[playerid][pAdmin]);
	INI_Int("Kills",PlayerInfo[playerid][pKills]);
    INI_Int("Deaths",PlayerInfo[playerid][pDeaths]);
 	return 1;
}

stock UserPath(playerid)
{
	new string[128],playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid,playername,sizeof(playername));
	format(string,sizeof(string),PATH,playername);
	return string;
}

/*Credits to Dracoblue*/
stock udb_hash(buf[]) {
	new length=strlen(buf);
    new s1 = 1;
    new s2 = 0;
    new n;
    for (n=0; n<length; n++)
    {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    return (s2 << 16) + s1;
}

public OnPlayerConnect(playerid)
{
	if(fexist(UserPath(playerid)))
	{
		INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
  		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,""COL_WHITE"Login",""COL_WHITE"Type your password below to login.","Login","Quit");
	}
	else
	{
 		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT,""COL_WHITE"Registering...",""COL_WHITE"Type your password below to register a new account.","Register","Quit");
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch( dialogid )
    {
        case DIALOG_REGISTER:
        {
            if (!response) return Kick(playerid);
            if(response)
            {
                if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, ""COL_WHITE"Registering...",""COL_RED"You have entered an invalid password.\n"COL_WHITE"Type your password below to register a new account.","Register","Quit");
                new INI:File = INI_Open(UserPath(playerid));
                INI_SetTag(File,"data");
                INI_WriteInt(File,"Password",udb_hash(inputtext));
                INI_WriteInt(File,"Cash",0);
                INI_WriteInt(File,"Admin",0);
                INI_WriteInt(File,"Kills",0);
                INI_WriteInt(File,"Deaths",0);
                INI_Close(File);

                SetSpawnInfo(playerid, 0, 0, 1958.33, 1343.12, 15.36, 269.15, 0, 0, 0, 0, 0, 0);
                SpawnPlayer(playerid);
                ShowPlayerDialog(playerid, DIALOG_SUCCESS_1, DIALOG_STYLE_MSGBOX,""COL_WHITE"Success!",""COL_GREEN"Great! You are registered. Relog to save your stats!","Ok","");
                    new name[MAX_PLAYER_NAME], string[24+MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    format(string, sizeof(string), "%s has joined the server.", name);
    SendClientMessageToAll(0xC4C4C4FF, string);
			}
        }

        case DIALOG_LOGIN:
        {
            if ( !response ) return Kick ( playerid );
            if( response )
            {
                if(udb_hash(inputtext) == PlayerInfo[playerid][pPass])
                {
                    INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
                    GivePlayerMoney(playerid, PlayerInfo[playerid][pCash]);
					ShowPlayerDialog(playerid, DIALOG_SUCCESS_2, DIALOG_STYLE_MSGBOX,""COL_WHITE"Success!",""COL_GREEN"You have successfully logged in!","Ok","");
                        new name[MAX_PLAYER_NAME], string[24+MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    format(string, sizeof(string), "%s has joined the server.", name);
    SendClientMessageToAll(0xC4C4C4FF, string);
				}
                else
                {
                    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,""COL_WHITE"Login",""COL_RED"You have entered an incorrect password.\n"COL_WHITE"Type your password below to login.","Login","Quit");
                }
                return 0;
            }
        }
    }
    return 0;
}

public OnPlayerDisconnect(playerid, reason)
{
	new INI:File = INI_Open(UserPath(playerid));
	INI_SetTag(File,"data");
	INI_WriteInt(File,"Cash",GetPlayerMoney(playerid));
	INI_WriteInt(File,"Admin",PlayerInfo[playerid][pAdmin]);
	INI_WriteInt(File,"Kills",PlayerInfo[playerid][pKills]);
	INI_WriteInt(File,"Deaths",PlayerInfo[playerid][pDeaths]);
	INI_Close(File);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	PlayerInfo[killerid][pKills]++;
	PlayerInfo[playerid][pDeaths]++;
	return 1;
}
