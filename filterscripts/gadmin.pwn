/*
 * Gadmin.pwn
 * Version: 2.5.3 (last updated 15 October, 2016)
 * By Gammix
 */

// ** SCRIPT TYPE **

#define FILTERSCRIPT

// ** A_SAMP **

#include <a_samp>

// ** PRE-INCLUSION LIBRARY SETTINGS **

#undef MAX_PLAYERS
#define MAX_PLAYERS (200)

//#define CONNECTION_TYPE_MYSQL
//4#define ENABLE_CONSOLE_MESSAGES

#define INI_MAX_INSTANCES (1)
#define INI_FILE_TIMEOUT (0)

#pragma dynamic (10000)

// ** INCLUDES **

#include <spectate>
#include <easydb>
//#include <ban>
#include <dini2>
#include <izcmd>
#include <timestamptodate>
#include <easydialog>

// ** PLUGINS **

#include <sscanf2>
#include <streamer>

// ** FIXEX **

#if !defined IsValidVehicle
	native IsValidVehicle(vehicleid);
#endif

// ** MACROS **

#define PASSWORD_SALT "__+#_#+@+@D326jhoiekJIA7hsdgtt>>.:@>P(#O#Q?A@!!~~I33##LDG)#*#Y%&$(U$HHRJSGSDH3a245364RY$$$$stdfha5y4"

#define DIRECTORY "GAdmin/"

#define MIN_PASSWORD_LENGTH (5)
#define MAX_PASSWORD_LENGTH (45)

#define MIN_ANSWER_LENGTH (5)
#define MAX_ANSWER_LENGTH (45)

#define MAX_REPORTS (20)

#if !defined FLOAT_INFINITY
    #define FLOAT_INFINITY (Float:0x7F800000)
#endif

// ** COLORS **

#define COLOR_WHITE (0xFFFFFFFF)
#define COL_WHITE "{FFFFFF}"

#define COLOR_TOMATO (0xFF6347FF)
#define COL_TOMATO "{FF6347}"

#define COLOR_LIGHT_BLUE (0x1495CEFF)
#define COL_LIGHT_BLUE "{1495CE}"

#define COLOR_YELLOW (0xFFDD00FF)
#define COL_YELLOW "{FFDD00}"

#define COLOR_ORANGE (0xFF9900FF)
#define COL_ORANGE "{FF9900}"

#define COLOR_GREEN (0x00FF00FF)
#define COL_GREEN "{00FF00}"

#define COLOR_DARK_GREEN (0x33AA33FF)
#define COL_DARK_GREEN "{33AA33}"

#define COLOR_SAMP_BLUE (0xA9C4E4FF)
#define COL_SAMP_BLUE "{A9C4E4}"

#define COLOR_CYAN (0x00FFFFFF)
#define COL_CYAN "{00FFFF}"

#define COLOR_CORAL (0x993333FF)
#define COL_CORAL "{993333}"

#define COLOR_GREY (0x808080FF)
#define COL_GREY "{808080}"

#define COLOR_THISTLE (0xD8BFD8FF)
#define COL_THISTLE "{D8BFD8}"

#define COLOR_PINK (0xCC99FFFF)
#define COL_PINK "{CC99FF}"

#define COLOR_HOT_PINK (0xFF99FFFF)
#define COL_HOT_PINK "{FF99FF}"

// ** VARIABLES **

enum E_SETTINGS
{
			E_SETTINGS_MAX_WARNINGS,
			E_SETTINGS_MAX_LOGIN_ATTEMPTS,
			E_SETTINGS_MAX_ANSWER_ATTEMPTS,
	bool:   E_SETTINGS_ANTI_SPAM,
	bool:   E_SETTINGS_ANTI_ADVERT,
	bool:   E_SETTINGS_ANTI_CAPS,
	        E_SETTINGS_MAX_PING,
 	bool:	E_SETTINGS_BLACKLIST,
  	bool:	E_SETTINGS_READ_CMD,
	bool:	E_SETTINGS_READ_PM,
 	bool:	E_SETTINGS_AKA,
 			E_SETTINGS_MAX_ACCOUNTS,
	bool:   E_SETTINGS_ADMIN_CMD,
	bool:   E_SETTINGS_GUEST_LOGIN,
	        E_SETTINGS_MAX_ADMIN_LEVEL,
            E_SETTINGS_MAX_VIP_LEVEL
};
new g_Settings[E_SETTINGS];

enum E_REPORT
{
	bool:   E_REPORT_VALID,
			E_REPORT_AGAINST_ID,
			E_REPORT_AGAINST_NAME[MAX_PLAYER_NAME],
			E_REPORT_FROM_ID,
			E_REPORT_FROM_NAME[MAX_PLAYER_NAME],
			E_REPORT_TIMESTAMP,
			E_REPORT_REASON[65],
	bool:   E_REPORT_CHECKED
};
new g_Report[MAX_REPORTS][E_REPORT];
new bool: g_ReportChecked[MAX_PLAYERS][MAX_REPORTS];

enum E_ACCOUNT
{
			E_ACCOUNT_SQLID,
			E_ACCOUNT_PASSWORD[64],
			E_ACCOUNT_SECURITY_QUESTION,
			E_ACCOUNT_SECURITY_ANSWER[64],
			E_ACCOUNT_KILLS,
			E_ACCOUNT_DEATHS,
			E_ACCOUNT_MONEY,
			E_ACCOUNT_SCORE,
			E_ACCOUNT_REGISTER_TIMESTAMP,
			E_ACCOUNT_LAST_LOGIN_TIMESTAMP,
			E_ACCOUNT_ADMIN_LEVEL,
			E_ACCOUNT_VIP_LEVEL,
			E_ACCOUNT_MINUTES_PLAYED,
	bool:	E_ACCOUNT_AUTO_LOGIN,
	bool:	E_ACCOUNT_READ_PM,
	bool:	E_ACCOUNT_READ_CMD,
			E_ACCOUNT_JAIL_TIMELEFT,
  			E_ACCOUNT_MUTE_TIMELEFT
};
new p_Account[MAX_PLAYERS][E_ACCOUNT];

enum E_PDATA
{
		   	E_PDATA_WARNINGS,
	       	E_PDATA_ATTEMPTS,
 	bool:	E_PDATA_ONDUTY,
	       	E_PDATA_VEHICLE_ID,
	       	E_PDATA_LAST_PM_ID,
	bool:  	E_PDATA_NO_PM,
	bool:  	E_PDATA_GODMODE,
	bool:  	E_PDATA_GODCARMODE,
			E_PDATA_UPDATE_TIMER,
			E_PDATA_MAX_PING_WARNINGS,
			E_PDATA_MAX_PING_TICKCONT,
			E_PDATA_LAST_TEXT_TICKCOUNT,
	Text3D: E_PDATA_VIP_LABEL
};
new p_Data[MAX_PLAYERS][E_PDATA];

// ** CONTSTANTS **

new const VEHICLE_NAMES[212][] =
{
	{"Landstalker"}, {"Bravura"}, {"Buffalo"}, {"Linerunner"}, {"Perrenial"}, {"Sentinel"}, {"Dumper"},
	{"Firetruck"}, {"Trashmaster"}, {"Stretch"}, {"Manana"}, {"Infernus"}, {"Voodoo"}, {"Pony"}, {"Mule"},
	{"Cheetah"}, {"Ambulance"}, {"Leviathan"}, {"Moonbeam"}, {"Esperanto"}, {"Taxi"}, {"Washington"},
	{"Bobcat"}, {"Mr Whoopee"}, {"BF Injection"}, {"Hunter"}, {"Premier"}, {"Enforcer"}, {"Securicar"},
	{"Banshee"}, {"Predator"}, {"Bus"}, {"Rhino"}, {"Barracks"}, {"Hotknife"}, {"Trailer 1"}, {"Previon"},
	{"Coach"}, {"Cabbie"}, {"Stallion"}, {"Rumpo"}, {"RC Bandit"}, {"Romero"}, {"Packer"}, {"Monster"},
	{"Admiral"}, {"Squalo"}, {"Seasparrow"}, {"Pizzaboy"}, {"Tram"}, {"Trailer 2"}, {"Turismo"},
	{"Speeder"}, {"Reefer"}, {"Tropic"}, {"Flatbed"}, {"Yankee"}, {"Caddy"}, {"Solair"}, {"Berkley's RC Van"},
	{"Skimmer"}, {"PCJ-600"}, {"Faggio"}, {"Freeway"}, {"RC Baron"}, {"RC Raider"}, {"Glendale"}, {"Oceanic"},
	{"Sanchez"}, {"Sparrow"}, {"Patriot"}, {"Quad"}, {"Coastguard"}, {"Dinghy"}, {"Hermes"}, {"Sabre"},
	{"Rustler"}, {"ZR-350"}, {"Walton"}, {"Regina"}, {"Comet"}, {"BMX"}, {"Burrito"}, {"Camper"}, {"Marquis"},
	{"Baggage"}, {"Dozer"}, {"Maverick"}, {"News Chopper"}, {"Rancher"}, {"FBI Rancher"}, {"Virgo"}, {"Greenwood"},
	{"Jetmax"}, {"Hotring"}, {"Sandking"}, {"Blista Compact"}, {"Police Maverick"}, {"Boxville"}, {"Benson"},
	{"Mesa"}, {"RC Goblin"}, {"Hotring Racer A"}, {"Hotring Racer B"}, {"Bloodring Banger"}, {"Rancher"},
	{"Super GT"}, {"Elegant"}, {"Journey"}, {"Bike"}, {"Mountain Bike"}, {"Beagle"}, {"Cropdust"}, {"Stunt"},
	{"Tanker"}, {"Roadtrain"}, {"Nebula"}, {"Majestic"}, {"Buccaneer"}, {"Shamal"}, {"Hydra"}, {"FCR-900"},
	{"NRG-500"}, {"HPV1000"}, {"Cement Truck"}, {"Tow Truck"}, {"Fortune"}, {"Cadrona"}, {"FBI Truck"},
	{"Willard"}, {"Forklift"}, {"Tractor"}, {"Combine"}, {"Feltzer"}, {"Remington"}, {"Slamvan"},
	{"Blade"}, {"Freight"}, {"Streak"}, {"Vortex"}, {"Vincent"}, {"Bullet"}, {"Clover"}, {"Sadler"},
	{"Firetruck LA"}, {"Hustler"}, {"Intruder"}, {"Primo"}, {"Cargobob"}, {"Tampa"}, {"Sunrise"}, {"Merit"},
	{"Utility"}, {"Nevada"}, {"Yosemite"}, {"Windsor"}, {"Monster A"}, {"Monster B"}, {"Uranus"}, {"Jester"},
	{"Sultan"}, {"Stratum"}, {"Elegy"}, {"Raindance"}, {"RC Tiger"}, {"Flash"}, {"Tahoma"}, {"Savanna"},
	{"Bandito"}, {"Freight Flat"}, {"Streak Carriage"}, {"Kart"}, {"Mower"}, {"Duneride"}, {"Sweeper"},
	{"Broadway"}, {"Tornado"}, {"AT-400"}, {"DFT-30"}, {"Huntley"}, {"Stafford"}, {"BF-400"}, {"Newsvan"},
	{"Tug"}, {"Trailer 3"}, {"Emperor"}, {"Wayfarer"}, {"Euros"}, {"Hotdog"}, {"Club"}, {"Freight Carriage"},
	{"Trailer 3"}, {"Andromada"}, {"Dodo"}, {"RC Cam"}, {"Launch"}, {"Police Car (LSPD)"}, {"Police Car (SFPD)"},
	{"Police Car (LVPD)"}, {"Police Ranger"}, {"Picador"}, {"S.W.A.T. Van"}, {"Alpha"}, {"Phoenix"}, {"Glendale"},
	{"Sadler"}, {"Luggage Trailer A"}, {"Luggage Trailer B"}, {"Stair Trailer"}, {"Boxville"}, {"Farm Plow"}, {"Utility Trailer"}
};

// ** FUNCTIONS **

ReturnPlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	return name;
}

ReturnPlayerIp(playerid)
{
	new ip[18];
	GetPlayerIp(playerid, ip, 18);
	return ip;
}

ip2long(const ip[])
{
  	new len = strlen(ip);
	if(! (len > 0 && len < 17))
    {
        return 0;
    }

	new count = 0;
    for (new i; i < len; i++)
    {
     	if(ip[i] == '.')
		{
			count++;
		}
	}
	if (! (count == 3))
	{
	    return 0;
	}

 	new address = strval(ip) << 24;
    count = strfind(ip, ".", false, 0) + 1;

	address += strval(ip[count]) << 16;
	count = strfind(ip, ".", false, count) + 1;

	address += strval(ip[count]) << 8;
	count = strfind(ip, ".", false, count) + 1;

	address += strval(ip[count]);
	return address;
}

IpMatch(ip1[], ip2[], rangetype = 26)
{
   	new ip = ip2long(ip1);
    new subnet = ip2long(ip2);

    new mask = -1 << (32 - rangetype);
    subnet &= mask;

    return bool:((ip & mask) == subnet);
}

IsNumeric(str[])
{
	new ch, i;
	while ((ch = str[i++])) if (!('0' <= ch <= '9'))
		return false;

	return true;
}

QuickSort_Pair(array[][2], bool:desc, left, right)
{
	#define PAIR_FIST (0)
	#define PAIR_SECOND (1)

	new
		tempLeft = left,
		tempRight = right,
		pivot = array[(left + right) / 2][PAIR_FIST],
		tempVar
	;

	while (tempLeft <= tempRight)
	{
	    if (desc)
	    {
			while (array[tempLeft][PAIR_FIST] > pivot)
				tempLeft++;

			while (array[tempRight][PAIR_FIST] < pivot)
				tempRight--;
		}
	    else
	    {
			while (array[tempLeft][PAIR_FIST] < pivot)
				tempLeft++;

			while (array[tempRight][PAIR_FIST] > pivot)
				tempRight--;
		}

		if (tempLeft <= tempRight)
		{
			tempVar = array[tempLeft][PAIR_FIST];
		 	array[tempLeft][PAIR_FIST] = array[tempRight][PAIR_FIST];
		 	array[tempRight][PAIR_FIST] = tempVar;

			tempVar = array[tempLeft][PAIR_SECOND];
			array[tempLeft][PAIR_SECOND] = array[tempRight][PAIR_SECOND];
			array[tempRight][PAIR_SECOND] = tempVar;

			tempLeft++;
			tempRight--;
		}
	}

	if (left < tempRight)
		QuickSort_Pair(array, desc, left, tempRight);

	if (tempLeft < right)
		QuickSort_Pair(array, desc, tempLeft, right);

	#undef PAIR_FIST
	#undef PAIR_SECOND
}

GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid))
		GetVehicleZAngle(GetPlayerVehicleID(playerid), a);

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

ReturnDate(timestamp)
{
	new year, month, day, unused;
	TimestampToDate(timestamp, year, month, day, unused, unused, unused, 0);

	static monthname[15];
	switch (month)
	{
	    case 1: monthname = "January";
	    case 2: monthname = "February";
	    case 3: monthname = "March";
	    case 4: monthname = "April";
	    case 5: monthname = "May";
	    case 6: monthname = "June";
	    case 7: monthname = "July";
	    case 8: monthname = "August";
	    case 9: monthname = "September";
	    case 10: monthname = "October";
	    case 11: monthname = "November";
	    case 12: monthname = "December";
	}

	new date[30];
	format(date, sizeof (date), "%i %s, %i", day, monthname, year);
	return date;
}

ReturnTimelapse(start, till)
{
	new seconds = till - start;

	const MINUTE = 60;
	const HOUR = 60 * MINUTE;
	const DAY = 24 * HOUR;
	const MONTH = 30 * DAY;

    new time[32];
	if (seconds == 1)
		format(time, sizeof (time), "A seconds ago");
	if (seconds < (1 * MINUTE))
		format(time, sizeof (time), "%i seconds ago", seconds);
	else if (seconds < (2 * MINUTE))
		format(time, sizeof (time), "A minute ago");
	else if (seconds < (45 * MINUTE))
		format(time, sizeof (time), "%i minutes ago", (seconds / MINUTE));
	else if (seconds < (90 * MINUTE))
		format(time, sizeof (time), "An hour ago");
	else if (seconds < (24 * HOUR))
		format(time, sizeof (time), "%i hours ago", (seconds / HOUR));
	else if (seconds < (48 * HOUR))
		format(time, sizeof (time), "Yesterday");
	else if (seconds < (30 * DAY))
		format(time, sizeof (time), "%i days ago", (seconds / DAY));
	else if (seconds < (12 * MONTH))
    {
   		new months = floatround(seconds / DAY / 30);
      	if (months <= 1)
			format(time, sizeof (time), "One month ago");
      	else
			format(time, sizeof (time), "%i months ago", months);
    }
    else
    {
      	new years = floatround(seconds / DAY / 365);
      	if (years <= 1)
			format(time, sizeof (time), "One year ago");
      	else
			format(time, sizeof (time), "%i years ago", years);
    }
	return time;
}

ReturnQuestion(id)
{
    new File:h = fopen(DIRECTORY "questions.ini", io_read);

    new ret[65];
	new count;
	while (fread(h, ret))
	{
		if (id == count)
		    break;

		count++;
	}

	fclose(h);

	return ret;
}

// ** CALLBACKS **

public OnFilterScriptInit()
{
	if (!dini_Exists(DIRECTORY))
 	{
	 	print("[GAdmin] - ERROR: Couldn't find directory '"DIRECTORY"' in scriptfiles folder.");
		return 0;
	}

	if (!dini_Exists(DIRECTORY "config.ini"))
	{
     	dini_IntSet(DIRECTORY "config.ini", "MaxWarnings", 5);
     	dini_IntSet(DIRECTORY "config.ini", "MaxLoginAttempts", 3);
     	dini_IntSet(DIRECTORY "config.ini", "MaxAnswerAttempts", 3);
     	dini_BoolSet(DIRECTORY "config.ini", "AntiSpam", true);
     	dini_BoolSet(DIRECTORY "config.ini", "AntiAdvert", true);
     	dini_BoolSet(DIRECTORY "config.ini", "AntiCaps", false);
     	dini_IntSet(DIRECTORY "config.ini", "MaxPing", 700);
     	dini_BoolSet(DIRECTORY "config.ini", "Blacklist", true);
     	dini_BoolSet(DIRECTORY "config.ini", "ReadCMD", false);
     	dini_BoolSet(DIRECTORY "config.ini", "ReadPM", true);
     	dini_BoolSet(DIRECTORY "config.ini", "AKA", true);
     	dini_IntSet(DIRECTORY "config.ini", "MaxAccounts", 3);
     	dini_BoolSet(DIRECTORY "config.ini", "AdminCMD", true);
     	dini_BoolSet(DIRECTORY "config.ini", "GuestLogin", true);
     	dini_IntSet(DIRECTORY "config.ini", "MaxAdminLevel", 5);
     	dini_IntSet(DIRECTORY "config.ini", "MaxVipLevel", 3);

     	dini_Timeout(DIRECTORY "config.ini");

		g_Settings[E_SETTINGS_MAX_WARNINGS] = 5;
		g_Settings[E_SETTINGS_MAX_LOGIN_ATTEMPTS] = 3;
		g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS] = 3;
		g_Settings[E_SETTINGS_ANTI_SPAM] = true;
		g_Settings[E_SETTINGS_ANTI_ADVERT] = true;
		g_Settings[E_SETTINGS_ANTI_CAPS] = false;
		g_Settings[E_SETTINGS_MAX_PING] = 700;
		g_Settings[E_SETTINGS_BLACKLIST] = true;
		g_Settings[E_SETTINGS_READ_CMD] = false;
		g_Settings[E_SETTINGS_READ_PM] = true;
		g_Settings[E_SETTINGS_AKA] = true;
		g_Settings[E_SETTINGS_MAX_ACCOUNTS] = 3;
		g_Settings[E_SETTINGS_ADMIN_CMD] = true;
		g_Settings[E_SETTINGS_GUEST_LOGIN] = true;
		g_Settings[E_SETTINGS_MAX_ADMIN_LEVEL] = 5;
		g_Settings[E_SETTINGS_MAX_VIP_LEVEL] = 3;
	}
	else
	{
		g_Settings[E_SETTINGS_MAX_WARNINGS] = dini_Int(DIRECTORY "config.ini", "MaxWarnings");
		g_Settings[E_SETTINGS_MAX_LOGIN_ATTEMPTS] = dini_Int(DIRECTORY "config.ini", "MaxLoginAttempts");
		g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS] = dini_Int(DIRECTORY "config.ini", "MaxAnswerAttempts");
		g_Settings[E_SETTINGS_ANTI_SPAM] = dini_Bool(DIRECTORY "config.ini", "AntiSpam");
		g_Settings[E_SETTINGS_ANTI_ADVERT] = dini_Bool(DIRECTORY "config.ini", "AntiAdvert");
		g_Settings[E_SETTINGS_ANTI_CAPS] = dini_Bool(DIRECTORY "config.ini", "AntiCaps");
		g_Settings[E_SETTINGS_MAX_PING] = dini_Int(DIRECTORY "config.ini", "MaxPing");
		g_Settings[E_SETTINGS_BLACKLIST] = dini_Bool(DIRECTORY "config.ini", "Blacklist");
		g_Settings[E_SETTINGS_READ_CMD] = dini_Bool(DIRECTORY "config.ini", "ReadCMD");
		g_Settings[E_SETTINGS_READ_PM] = dini_Bool(DIRECTORY "config.ini", "ReadPM");
		g_Settings[E_SETTINGS_AKA] = dini_Bool(DIRECTORY "config.ini", "AKA");
		g_Settings[E_SETTINGS_MAX_ACCOUNTS] = dini_Int(DIRECTORY "config.ini", "MaxAccounts");
		g_Settings[E_SETTINGS_ADMIN_CMD] = dini_Bool(DIRECTORY "config.ini", "AdminCMD");
		g_Settings[E_SETTINGS_GUEST_LOGIN] = dini_Bool(DIRECTORY "config.ini", "GuestLogin");
		g_Settings[E_SETTINGS_MAX_ADMIN_LEVEL] = dini_Int(DIRECTORY "config.ini", "MaxAdminLevel");
		g_Settings[E_SETTINGS_MAX_VIP_LEVEL] = dini_Int(DIRECTORY "config.ini", "MaxVipLevel");

     	dini_Timeout(DIRECTORY "config.ini");
	}

	if (!dini_Exists(DIRECTORY "database.ini"))
	{
     	dini_Set(DIRECTORY "database.ini", "Database", DIRECTORY "SA-MP.db");
     	dini_Set(DIRECTORY "database.ini", "Hostname", "");
     	dini_Set(DIRECTORY "database.ini", "Username", "");
     	dini_Set(DIRECTORY "database.ini", "Password", "");
     	dini_IntSet(DIRECTORY "database.ini", "Port", 0);

     	dini_Timeout(DIRECTORY "database.ini");

     	DB::Init(DIRECTORY "SA-MP.db");
     	Ban_Init(DIRECTORY "SA-MP.db");
	}
	else
	{
     	DB::Init(dini_Get(DIRECTORY "database.ini", "Database"), dini_Get(DIRECTORY "database.ini", "Hostname"), dini_Get(DIRECTORY "database.ini", "Username"), dini_Get(DIRECTORY "database.ini", "Password"), dini_Int(DIRECTORY "database.ini", "Port"));
     	Ban_Init(dini_Get(DIRECTORY "database.ini", "Database"), dini_Get(DIRECTORY "database.ini", "Hostname"), dini_Get(DIRECTORY "database.ini", "Username"), dini_Get(DIRECTORY "database.ini", "Password"), dini_Int(DIRECTORY "database.ini", "Port"));

     	dini_Timeout(DIRECTORY "database.ini");
	}

	static string[1000];
	if (!dini_Exists(DIRECTORY "adminspawns.ini"))
	{
	    string[0] = EOS;
	    strcat(string, "1435.8024,2662.3647,11.3926,1.1650\r\n");
		strcat(string, "1457.4762,2773.4868,10.8203,272.2754\r\n");
		strcat(string, "2101.4192,2678.7874,10.8130,92.0607\r\n");
		strcat(string, "1951.1090,2660.3877,10.8203,180.8461\r\n");
		strcat(string, "1666.6949,2604.9861,10.8203,179.8495\r\n");
		strcat(string, "1860.9672,1030.2910,10.8203,271.6988\r\n");
		strcat(string, "1673.2345,1316.1067,10.8203,177.7294\r\n");
		strcat(string, "1412.6187,2000.0596,14.7396,271.3568");

		new File:h = fopen(DIRECTORY "adminspawns.ini", io_write);
		fwrite(h, string);
		fclose(h);
	}

	if (!dini_Exists(DIRECTORY "questions.ini"))
	{
	    string[0] = EOS;
	    strcat(string, "What was your childhood nickname?\r\n");
		strcat(string, "What is the name of your favorite childhood friend?\r\n");
		strcat(string, "In what city or town did your mother and father meet?\r\n");
		strcat(string, "What is the middle name of your oldest child?\r\n");
		strcat(string, "What is your favorite team?\r\n");
		strcat(string, "What is your favorite movie?\r\n");
		strcat(string, "What is the first name of the boy or girl that you first kissed?\r\n");
		strcat(string, "What was the make and model of your first car?\r\n");
		strcat(string, "What was the name of the hospital where you were born?\r\n");
		strcat(string, "Who is your childhood sports hero?\r\n");
		strcat(string, "In what town was your first job?\r\n");
		strcat(string, "What was the name of the company where you had your first job?\r\n");
		strcat(string, "What school did you attend for sixth grade?\r\n");
		strcat(string, "What was the last name of your third grade teacher?");

		new File:h = fopen(DIRECTORY "questions.ini", io_write);
		fwrite(h, string);
		fclose(h);
	}

	DB::VerifyTable("Users", "ID", false,
	                    "Name", STRING,
	                    "Password", STRING,
						"Ip", STRING,
						"SecurityQuestion", INTEGER,
						"SecurityAnswer", STRING,
	                    "Kills", INTEGER,
	                    "Deaths", INTEGER,
	                    "Money", INTEGER,
	                    "Score", INTEGER,
	                    "RegisterTimeStamp", INTEGER,
	                    "LastLoginTimeStamp", INTEGER,
	                    "AdminLevel", INTEGER,
	                    "VipLevel", INTEGER,
	                    "MinutesPlayed", INTEGER,
	                    "AutoLogin", INTEGER,
	                    "ReadPM", INTEGER,
	                    "ReadCMD", INTEGER,
						"JailTimeLeft", INTEGER,
						"MuteTimeLeft", INTEGER,
						"LastNameChange", INTEGER);

    print("\n==================| GAdmin |==================\n");
	print("\tGAdmin filterscript loaded.\n");
	print("\t      Version: 2.5\n");
	print("\t  (c) 2015 <MIT> \"Gammix\"");
	print("\n===============================================\n");

	return 1;
}

public OnFilterScriptExit()
{
	DB::Exit();
	Ban_Exit();

	dini_IntSet(DIRECTORY "config.ini", "MaxWarnings", g_Settings[E_SETTINGS_MAX_WARNINGS]);
	dini_IntSet(DIRECTORY "config.ini", "MaxLoginAttempts", g_Settings[E_SETTINGS_MAX_LOGIN_ATTEMPTS]);
	dini_IntSet(DIRECTORY "config.ini", "MaxAnswerAttempts", g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS]);
	dini_BoolSet(DIRECTORY "config.ini", "AntiSpam", g_Settings[E_SETTINGS_ANTI_SPAM]);
	dini_BoolSet(DIRECTORY "config.ini", "AntiAdvert", g_Settings[E_SETTINGS_ANTI_ADVERT]);
	dini_BoolSet(DIRECTORY "config.ini", "AntiCaps", g_Settings[E_SETTINGS_ANTI_CAPS]);
	dini_IntSet(DIRECTORY "config.ini", "MaxPing", g_Settings[E_SETTINGS_MAX_PING]);
	dini_BoolSet(DIRECTORY "config.ini", "Blacklist", g_Settings[E_SETTINGS_BLACKLIST]);
	dini_BoolSet(DIRECTORY "config.ini", "ReadCMD", g_Settings[E_SETTINGS_READ_CMD]);
	dini_BoolSet(DIRECTORY "config.ini", "ReadPM", g_Settings[E_SETTINGS_READ_PM]);
	dini_BoolSet(DIRECTORY "config.ini", "AKA", g_Settings[E_SETTINGS_AKA]);
	dini_IntSet(DIRECTORY "config.ini", "MaxAccounts", g_Settings[E_SETTINGS_MAX_ACCOUNTS]);
	dini_BoolSet(DIRECTORY "config.ini", "AdminCMD", g_Settings[E_SETTINGS_ADMIN_CMD]);
	dini_BoolSet(DIRECTORY "config.ini", "GuestLogin", g_Settings[E_SETTINGS_GUEST_LOGIN]);
	dini_IntSet(DIRECTORY "config.ini", "MaxAdminLevel", g_Settings[E_SETTINGS_MAX_ADMIN_LEVEL]);
	dini_IntSet(DIRECTORY "config.ini", "MaxVipLevel", g_Settings[E_SETTINGS_MAX_VIP_LEVEL]);

	dini_Timeout(DIRECTORY "database.ini");

	return 1;
}

public OnBannedPlayerConnect(playerid, banid)
{
	if (!g_Settings[E_SETTINGS_BLACKLIST])
	{
	    SendClientMessage(playerid, COLOR_TOMATO, "Blacklist is disabled at the moment, stay unnoticed and play peacfully and fair.");
	    return 0;
	}

    new name[MAX_PLAYER_NAME], ip[18], reason[65], admin[MAX_PLAYER_NAME], bandate[35], expiredate[35], rangeban[3];
	GetBanData(banid, "Name", STRING, name);
	GetBanData(banid, "Ip", STRING, ip);
	GetBanData(banid, "Reason", STRING, reason);
	GetBanData(banid, "Admin", STRING, admin);
	GetBanData(banid, "BanDate", STRING, bandate);
	GetBanData(banid, "ExpireDate", STRING, expiredate);
	GetBanData(banid, "RangeBan", STRING, rangeban);

	static string[500];
	format(string, sizeof (string),
		"USERNAME\t%s\n\
		IP.\t%s\n\
		REASON\t%s\n\
		ADMIN\t%s\n\
		BAN DATE\t%s\n\
		EXPIRE DATE\t%s\n\
		RANGE BAN\t%s",
			name, ip, reason, admin, bandate, expiredate, rangeban);
	Dialog_Show(playerid, 0, DIALOG_STYLE_TABLIST, "You are banned on this server...", string, "Close", "");
	return 1;
}

public OnPlayerConnect(playerid)
{
	SetPVarInt(playerid, "gadmin_LoginStatus", 0);
	p_Data[playerid][E_PDATA_WARNINGS] = 0;
	p_Data[playerid][E_PDATA_ATTEMPTS] = 0;
	p_Data[playerid][E_PDATA_ONDUTY] = false;
	p_Data[playerid][E_PDATA_VEHICLE_ID] = INVALID_VEHICLE_ID;
	p_Data[playerid][E_PDATA_LAST_PM_ID] = INVALID_PLAYER_ID;
	p_Data[playerid][E_PDATA_NO_PM] = false;
	p_Data[playerid][E_PDATA_GODMODE] = false;
	p_Data[playerid][E_PDATA_GODCARMODE] = false;
	p_Data[playerid][E_PDATA_MAX_PING_WARNINGS] = 0;
	p_Data[playerid][E_PDATA_MAX_PING_TICKCONT] = 0;
	p_Data[playerid][E_PDATA_LAST_TEXT_TICKCOUNT] = 0;

 	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	static string[150];
	format(string, sizeof (string), "** %s[%i] has joined the server.", name, playerid);
	SendClientMessageToAll(COLOR_GREY, string);

	new ip[18];
	GetPlayerIp(playerid, ip, sizeof (ip));

	if (g_Settings[E_SETTINGS_AKA] || g_Settings[E_SETTINGS_MAX_ACCOUNTS] > 0)
	{
		DB::Fetch("Users");

		new count;
		new aka[5][MAX_PLAYER_NAME];

		new rowip[18];
		new rowname[MAX_PLAYER_NAME];

		new bool:oldaccount;

		do
		{
		    fetch_string("Ip", rowip);
		    if (IpMatch(rowip, ip))
		    {
		        if (count < sizeof (aka))
					fetch_string("Name", aka[count]);

				if (!oldaccount)
				{
					if (count < g_Settings[E_SETTINGS_MAX_ACCOUNTS])
					{
					    fetch_string("Name", rowname);
					    if (!strcmp(name, rowname))
					        oldaccount = true;
					}
				}

		        count++;
		    }
		}
		while (fetch_next_row());

		fetcher_close();

		if (g_Settings[E_SETTINGS_AKA])
   		{
        	format(string, sizeof (string), "[AKA.] %s is associated with %s", name, aka[0]);
        	for (new i = 1, j = ((count > sizeof (aka)) ? (sizeof (aka)) : (count)); i < j; i++)
        	{
        	    if (i == (j - 1))
        	    {
        	        if (count > sizeof (aka))
        	    		format(string, sizeof (string), "%s, %s and ......%i more account(s)", string, aka[i], count);
					else
        	    		format(string, sizeof (string), "%s and %s", string, aka[i]);
        	    }
				else
					format(string, sizeof (string), "%s, %s", string, aka[i]);
			}

			for (new i, j = GetPlayerPoolSize(); i <= j; i++)
			{
			    if (IsPlayerConnected(i) && p_Account[i][E_ACCOUNT_ADMIN_LEVEL] > 1)
   		        	SendClientMessage(playerid, COLOR_GREY, string);
			}
		}

		if (g_Settings[E_SETTINGS_MAX_ACCOUNTS] > 0)
		{
		    if (count > g_Settings[E_SETTINGS_MAX_ACCOUNTS])
		    {
		        if (!oldaccount)
		        {
			        format(string, sizeof (string), "%s[%i] has been auto kicked from the server.", name, playerid);
			        SendClientMessageToAll(COLOR_CORAL, string);
			        format(string, sizeof (string), "Reason: Multi accounting [Limit is of %i max accounts]", g_Settings[E_SETTINGS_MAX_ACCOUNTS]);
			        SendClientMessageToAll(COLOR_CORAL, string);

					return Kick(playerid);
				}
		    }
		}
	}

    return SetTimerEx("OnPlayerFullyConnect", 0001, false, "i", playerid);
}

forward OnPlayerFullyConnect(playerid);
public  OnPlayerFullyConnect(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	static string[500];

	DB::Fetch("Users", _, _, _, "`Name` = '%q'", name);
	if (fetch_rows_count() > 0)
	{
	    p_Account[playerid][E_ACCOUNT_SQLID] = fetch_row_id();
	    fetch_string("Password", p_Account[playerid][E_ACCOUNT_PASSWORD], 64);
	    p_Account[playerid][E_ACCOUNT_SECURITY_QUESTION] = fetch_int("SecurityQuestion");
	    fetch_string("SecurityAnswer", p_Account[playerid][E_ACCOUNT_SECURITY_ANSWER], 64);
	    p_Account[playerid][E_ACCOUNT_KILLS] = fetch_int("Kills");
	    p_Account[playerid][E_ACCOUNT_DEATHS] = fetch_int("Deaths");
	    p_Account[playerid][E_ACCOUNT_MONEY] = fetch_int("Money");
	    p_Account[playerid][E_ACCOUNT_SCORE] = fetch_int("Score");
	    p_Account[playerid][E_ACCOUNT_REGISTER_TIMESTAMP] = fetch_int("RegisterTimeStamp");
	    p_Account[playerid][E_ACCOUNT_LAST_LOGIN_TIMESTAMP] = fetch_int("LastLoginTimeStamp");
	    p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] = fetch_int("AdminLevel");
	    p_Account[playerid][E_ACCOUNT_VIP_LEVEL] = fetch_int("VipLevel");
	    p_Account[playerid][E_ACCOUNT_MINUTES_PLAYED] = fetch_int("MinutesPlayed");
	    p_Account[playerid][E_ACCOUNT_AUTO_LOGIN] = bool:fetch_int("AutoLogin");
	    p_Account[playerid][E_ACCOUNT_READ_PM] = bool:fetch_int("ReadPM");
	    p_Account[playerid][E_ACCOUNT_READ_CMD] = bool:fetch_int("ReadCMD");
		p_Account[playerid][E_ACCOUNT_JAIL_TIMELEFT] = fetch_int("JailTimerLeft");
		p_Account[playerid][E_ACCOUNT_MUTE_TIMELEFT] = fetch_int("MuteTimeLeft");

		new ip[18];
		GetPlayerName(playerid, ip, sizeof (ip));

		new rowip[18];
		fetch_string("Ip", rowip);
	    if (p_Account[playerid][E_ACCOUNT_AUTO_LOGIN] && IpMatch(ip, rowip))
	    {
	        dialog_DIALOG_LOGIN(playerid, 1, 0, "", true);
	    }
		else
	    {
			SendClientMessage(playerid, COLOR_LIGHT_BLUE, " ");
			format(string, sizeof (string), "Username: %s || Status: Registred || Account id: %i || Last login: %s || Today's date: %s", name, p_Account[playerid][E_ACCOUNT_SQLID], ReturnDate(p_Account[playerid][E_ACCOUNT_LAST_LOGIN_TIMESTAMP]), ReturnDate(gettime()));
			SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

			PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);

		    format(string, sizeof (string), ""COL_WHITE"Welcome back "COL_DARK_GREEN"%s"COL_WHITE". Please insert in your password to access your account or Click 'Forgot' to answer your security question.", name);
		    Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login account...", string, "Login", "Forgot");
		}
	}
	else
	{
	    p_Account[playerid][E_ACCOUNT_SQLID] = -1;
	    p_Account[playerid][E_ACCOUNT_PASSWORD][0] = EOS;
	    p_Account[playerid][E_ACCOUNT_SECURITY_QUESTION] = 0;
	    p_Account[playerid][E_ACCOUNT_SECURITY_ANSWER][0] = EOS;
	    p_Account[playerid][E_ACCOUNT_KILLS] = 0;
	    p_Account[playerid][E_ACCOUNT_DEATHS] = 0;
	    p_Account[playerid][E_ACCOUNT_MONEY] = 0;
	    p_Account[playerid][E_ACCOUNT_SCORE] = 0;
	    p_Account[playerid][E_ACCOUNT_REGISTER_TIMESTAMP] = gettime();
	    p_Account[playerid][E_ACCOUNT_LAST_LOGIN_TIMESTAMP] = gettime();
	    p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] = 0;
	    p_Account[playerid][E_ACCOUNT_VIP_LEVEL] = 0;
	    p_Account[playerid][E_ACCOUNT_MINUTES_PLAYED] = 0;
	    p_Account[playerid][E_ACCOUNT_AUTO_LOGIN] = true;
	    p_Account[playerid][E_ACCOUNT_READ_PM] = true;
	    p_Account[playerid][E_ACCOUNT_READ_CMD] = false;

		SendClientMessage(playerid, COLOR_LIGHT_BLUE, " ");
		format(string, sizeof (string), "Username: %s || Status: Not Registred || Today's date: %s", name, ReturnDate(gettime()));
		SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

		PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);

		if (g_Settings[E_SETTINGS_GUEST_LOGIN])
		{
		    format(string, sizeof (string), ""COL_WHITE"Hello "COL_TOMATO"%s"COL_WHITE". Please insert a complicated password to register a new account or Click 'Guest' to join with a temporary account.", name);
		    Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register account...", string, "Continue", "Guest");
		}
		else
		{
		    format(string, sizeof (string), ""COL_WHITE"Hello "COL_TOMATO"%s"COL_WHITE". Please insert a complicated password to register a new account or Click 'Quit' to exit game to desktop.", name);
		    Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register account...", string, "Continue", "Quit");
		}
	}

	p_Data[playerid][E_PDATA_UPDATE_TIMER] = SetTimerEx("OnPlayerTick", 1000, true, "i", playerid);
	return 1;
}

// ** LOGIN AND REGISTER DIALOG **

Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[], bool:redirect)
{
	if (redirect == true)
	    goto REDIRECT;

 	static string[500];

	if (!response)
	{
	    p_Data[playerid][E_PDATA_ATTEMPTS] = 0;

		format(string, sizeof (string), ""COL_WHITE"This happens, that's why we had a simple security question system for you to easily recover your password now.\nPlease answer the security question to reset your password. [You have "COL_CORAL"%i/%i tries"COL_WHITE" left]\n\n"COL_LIGHT_BLUE"%s", p_Data[playerid][E_PDATA_ATTEMPTS], g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS], ReturnQuestion(p_Account[playerid][E_ACCOUNT_SECURITY_QUESTION]));
	    return Dialog_Show(playerid, DIALOG_FORGOT_PASSWORD, DIALOG_STYLE_INPUT, "Forgotten password ?", string, "Answer", "Quit");
	}

	static password[64];
	SHA256_PassHash(inputtext, PASSWORD_SALT, password, sizeof (password));

	if (strcmp(p_Account[playerid][E_ACCOUNT_PASSWORD], password))
	{
	    p_Data[playerid][E_PDATA_ATTEMPTS]++;

	    format(string, sizeof (string), "Error: Incorrect password (%i/%i attempts failed).", p_Data[playerid][E_PDATA_ATTEMPTS], g_Settings[E_SETTINGS_MAX_LOGIN_ATTEMPTS]);
	    SendClientMessage(playerid, COLOR_TOMATO, string);

	    if (p_Data[playerid][E_PDATA_ATTEMPTS] >= g_Settings[E_SETTINGS_MAX_LOGIN_ATTEMPTS])
	    {
	        format(string, sizeof (string), "%s[%i] has been auto kicked from the server.", ReturnPlayerName(playerid), playerid);
	        SendClientMessageToAll(COLOR_CORAL, string);
	        format(string, sizeof (string), "Reason: Failed login attempts (%i/%i)", g_Settings[E_SETTINGS_MAX_LOGIN_ATTEMPTS], g_Settings[E_SETTINGS_MAX_LOGIN_ATTEMPTS]);
	        SendClientMessageToAll(COLOR_CORAL, string);

			return Kick(playerid);
		}

	    format(string, sizeof (string), ""COL_WHITE"Welcome back "COL_DARK_GREEN"%s"COL_WHITE". Please insert in your password to access your account or Click 'Forgot' to answer your security question.", ReturnPlayerName(playerid));
	    Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Login account...", string, "Login", "Forgot");
	    return 1;
	}

REDIRECT:

	SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________");
	SendClientMessage(playerid, COLOR_GREEN, " ");
	if (redirect)
		format(string, sizeof (string), "You have successfully auto logged-in! Your admin level is %i and vip level is %i.", p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL], p_Account[playerid][E_ACCOUNT_VIP_LEVEL]);
	else
		format(string, sizeof (string), "You have successfully logged-in! Your admin level is %i and vip level is %i.", p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL], p_Account[playerid][E_ACCOUNT_VIP_LEVEL]);
	SendClientMessage(playerid, COLOR_GREEN, string);
	SendClientMessage(playerid, COLOR_GREEN, " ");
	SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________");

 	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, p_Account[playerid][E_ACCOUNT_MONEY]);
	SetPlayerScore(playerid, p_Account[playerid][E_ACCOUNT_SCORE]);

 	DB::Update("Users", p_Account[playerid][E_ACCOUNT_SQLID], 1,
 	                "Ip", STRING, ReturnPlayerIp(playerid),
					"LastLoginTimeStamp", INTEGER, gettime());

    SetPVarInt(playerid, "gadmin_LoginStatus", 1);
    CallRemoteFunction("OnPlayerLogin", "ii", playerid, 0);

  	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	if (p_Account[playerid][E_ACCOUNT_VIP_LEVEL] > 0)
	{
	    format(string, sizeof (string), "** Warn welcome to our VIP. Level %i member %s.", p_Account[playerid][E_ACCOUNT_VIP_LEVEL], ReturnPlayerName(playerid));
	    SendClientMessageToAll(COLOR_YELLOW, string);
	    
		p_Data[playerid][E_PDATA_VIP_LABEL] = CreateDynamic3DTextLabel("VIP. Player", COLOR_YELLOW, 0.0, 0.0, 3.5, 100.0, playerid);
	}
	
	return 1;
}

Dialog:DIALOG_FORGOT_PASSWORD(playerid, response, listitem, inputtext[])
{
	if (!response)
	    return Kick(playerid);

    new answer[64];
	SHA256_PassHash(inputtext, PASSWORD_SALT, answer, sizeof (answer));

	if (strcmp(p_Account[playerid][E_ACCOUNT_SECURITY_ANSWER], answer))
	{
	    p_Data[playerid][E_PDATA_ATTEMPTS]++;

	    static string[500];
	    format(string, sizeof (string), "Error: Incorrect answer, you are left with %i/%i attempts.", p_Data[playerid][E_PDATA_ATTEMPTS], g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS]);
	    SendClientMessage(playerid, COLOR_TOMATO, string);

	    if (p_Data[playerid][E_PDATA_ATTEMPTS] >= g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS])
	    {
	        format(string, sizeof (string), "%s[%i] has been auto kicked from the server.", ReturnPlayerName(playerid), playerid);
	        SendClientMessageToAll(COLOR_CORAL, string);
	        format(string, sizeof (string), "Reason: Failed recovery attempts (%i/%i)", g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS], g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS]);
	        SendClientMessageToAll(COLOR_CORAL, string);

			return Kick(playerid);
		}

		format(string, sizeof (string), ""COL_WHITE"This happens, that's why we had a simple security question system for you to easily recover your password now.\nPlease answer the security question to reset your password. [You have "COL_CORAL"%i/%i tries"COL_WHITE" left]\n\n"COL_LIGHT_BLUE"%s", p_Data[playerid][E_PDATA_ATTEMPTS], g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS], ReturnQuestion(p_Account[playerid][E_ACCOUNT_SECURITY_QUESTION]));
	    Dialog_Show(playerid, DIALOG_FORGOT_PASSWORD, DIALOG_STYLE_INPUT, "Forgotten password ?", string, "Answer", "Quit");
	    return 1;
	}

	Dialog_Show(playerid, DIALOG_RESET_PASSWORD, DIALOG_STYLE_PASSWORD, "Reset Password...", "You successfully recovered your account by answering the security question. Please insert in a new complicated password which you will remeber next time.", "Reset", "");
	return 1;
}

Dialog:DIALOG_RESET_PASSWORD(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
	    SendClientMessage(playerid, COLOR_WHITE, "Please insert a new password for your account.");
	    return Dialog_Show(playerid, DIALOG_RESET_PASSWORD, DIALOG_STYLE_PASSWORD, "Reset Password...", "You successfully recovered your account by answering the security question. Please insert in a new complicated password which you will remeber next time.", "Reset", "");
	}

    if (!inputtext[0] || inputtext[0] == ' ')
	{
	    SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid password length, cannot be empty.");
	   	return Dialog_Show(playerid, DIALOG_RESET_PASSWORD, DIALOG_STYLE_PASSWORD, "Reset Password...", "You successfully recovered your account by answering the security question. Please insert in a new complicated password which you will remeber next time.", "Reset", "");
	}

	new len = strlen(inputtext);
	if (len > MAX_PASSWORD_LENGTH || len < MIN_PASSWORD_LENGTH)
	{
	    static string[500];
	    format(string, sizeof (string), "Error: Invalid password length, must be between %i - %i chars.", MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH);
	    SendClientMessage(playerid, COLOR_TOMATO, string);

	    return Dialog_Show(playerid, DIALOG_RESET_PASSWORD, DIALOG_STYLE_PASSWORD, "Reset Password...", "You successfully recovered your account by answering the security question. Please insert in a new complicated password which you will remeber next time.", "Reset", "");
	}

	SHA256_PassHash(inputtext, PASSWORD_SALT, p_Account[playerid][E_ACCOUNT_PASSWORD], 64);

 	DB::Update("Users", p_Account[playerid][E_ACCOUNT_SQLID], 1,
		"Password", STRING, p_Account[playerid][E_ACCOUNT_PASSWORD]);

	SendClientMessage(playerid, COLOR_GREEN, "Password reset completed, you will be automatically logged in...");
    dialog_DIALOG_LOGIN(playerid, 1, 0, "", true);

	return 1;
}

Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
	    if (g_Settings[E_SETTINGS_GUEST_LOGIN])
	    {
    		SetPVarInt(playerid, "gadmin_LoginStatus", 2);
   	 		CallRemoteFunction("OnPlayerLogin", "ii", playerid, 1);

	        new name[MAX_PLAYER_NAME + 6];
	        GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	        strins(name, "guest_", 0);

	        if (strlen(name) + 6 > MAX_PLAYER_NAME)
	       		strdel(name, (MAX_PLAYER_NAME - (6 + 1)), (MAX_PLAYER_NAME - 1));

			SetPlayerName(playerid, name);

			static string[150];
			SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________");
			SendClientMessage(playerid, COLOR_GREEN, " ");
			format(string, sizeof (string), "You have joined as a guest! Your admin level is %i and vip level is %i.", p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL], p_Account[playerid][E_ACCOUNT_VIP_LEVEL]);
 			SendClientMessage(playerid, COLOR_GREEN, string);
			SendClientMessage(playerid, COLOR_GREEN, " ");
			SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________");

		 	ResetPlayerMoney(playerid);
			SetPlayerScore(playerid, 0);
		 	return 1;
	    }
	    else
	    	return Kick(playerid);
	}

	if (!inputtext[0] || inputtext[0] == ' ')
	{
	    SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid password length, cannot be empty.");

	    static string[500];
	    if (g_Settings[E_SETTINGS_GUEST_LOGIN])
		{
		    format(string, sizeof (string), ""COL_WHITE"Hello "COL_TOMATO"%s"COL_WHITE". Please insert a complicated password to register a new account or Click 'Guest' to join with a temporary account.", ReturnPlayerName(playerid));
		    Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register account...", string, "Continue", "Guest");
		}
		else
		{
		    format(string, sizeof (string), ""COL_WHITE"Hello "COL_TOMATO"%s"COL_WHITE". Please insert a complicated password to register a new account or Click 'Quit' to exit game to desktop.", ReturnPlayerName(playerid));
		    Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register account...", string, "Continue", "Quit");
		}
		return 1;
	}

	new len = strlen(inputtext);
	if (len > MAX_PASSWORD_LENGTH || len < MIN_PASSWORD_LENGTH)
	{
	    static string[500];
	    format(string, sizeof (string), "Error: Invalid password length, must be between %i - %i chars.", MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH);
	    SendClientMessage(playerid, COLOR_TOMATO, string);

	    if (g_Settings[E_SETTINGS_GUEST_LOGIN])
		{
		    format(string, sizeof (string), ""COL_WHITE"Hello "COL_TOMATO"%s"COL_WHITE". Please insert a complicated password to register a new account or Click 'Guest' to join with a temporary account.", ReturnPlayerName(playerid));
		    Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register account...", string, "Continue", "Guest");
		}
		else
		{
		    format(string, sizeof (string), ""COL_WHITE"Hello "COL_TOMATO"%s"COL_WHITE". Please insert a complicated password to register a new account or Click 'Quit' to exit game to desktop.", ReturnPlayerName(playerid));
		    Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register account...", string, "Continue", "Quit");
		}
		return 1;
	}

	SHA256_PassHash(inputtext, PASSWORD_SALT, p_Account[playerid][E_ACCOUNT_PASSWORD], 64);

	new File:h = fopen(DIRECTORY "questions.ini", io_read);

	new line[100];
	new info[15 * sizeof (line)];
	new count;
	while (fread(h, line))
	{
	    strcat(info, line);
	    strcat(info, "\n");

	    if (++count > 15)
	        break;
	}

	fclose(h);

	PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);
	Dialog_Show(playerid, DIALOG_SEC_QUESTION, DIALOG_STYLE_LIST, "[1/2] Select your security question:", info, "Continue", "");

	return 1;
}

Dialog:DIALOG_SEC_QUESTION(playerid, response, listitem, inputext[])
{
	if (!response)
	{
		new File:h = fopen(DIRECTORY "questions.ini", io_read);

		new line[100];
		new info[15 * sizeof (line)];
		new count;
		while (fread(h, line))
		{
		    strcat(info, line);
		    strcat(info, "\n");

		    if (++count > 15)
		        break;
		}

		fclose(h);

		return Dialog_Show(playerid, DIALOG_SEC_QUESTION, DIALOG_STYLE_LIST, "[1/2] Select your security question:", info, "Continue", "");
	}

	p_Account[playerid][E_ACCOUNT_SECURITY_QUESTION] = listitem;

	static string[500];
 	format(string, sizeof (string), ""COL_WHITE"Insert the answer for your selected question:\n"COL_LIGHT_BLUE"%s", ReturnQuestion(p_Account[playerid][E_ACCOUNT_SECURITY_QUESTION]));
  	Dialog_Show(playerid, DIALOG_SEC_ANSWER, DIALOG_STYLE_PASSWORD, "[2/2] Set your security answer:", string, "Finish", "Back");
	return 1;
}

Dialog:DIALOG_SEC_ANSWER(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		new File:h = fopen(DIRECTORY "questions.ini", io_read);

		new line[100];
	    new info[15 * sizeof (line)];
		new count;
		while (fread(h, line))
		{
		    strcat(info, line);
		    strcat(info, "\n");

		    if (++count > 15)
		        break;
		}

		fclose(h);

		return Dialog_Show(playerid, DIALOG_SEC_QUESTION, DIALOG_STYLE_LIST, "[1/2] Select your security question:", info, "Continue", "");
	}

	if (!inputtext[0] || inputtext[0] == ' ')
	{
	    SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid answer length, cannot be empty.");

	    static string[500];
	 	format(string, sizeof (string), ""COL_WHITE"Insert the answer for your selected question:\n"COL_LIGHT_BLUE"%s", ReturnQuestion(p_Account[playerid][E_ACCOUNT_SECURITY_QUESTION]));
	  	Dialog_Show(playerid, DIALOG_SEC_ANSWER, DIALOG_STYLE_PASSWORD, "[2/2] Set your security answer:", string, "Finish", "Back");
		return 1;
	}

	new len = strlen(inputtext);
	if (len > MAX_ANSWER_LENGTH || len < MIN_ANSWER_LENGTH)
	{
	    static string[500];
	    format(string, sizeof (string), "Error: Invalid answer length, must be between %i - %i chars.", MIN_ANSWER_LENGTH, MAX_ANSWER_LENGTH);
	    SendClientMessage(playerid, COLOR_TOMATO, string);

	 	format(string, sizeof (string), ""COL_WHITE"Insert the answer for your selected question:\n"COL_LIGHT_BLUE"%s", ReturnQuestion(p_Account[playerid][E_ACCOUNT_SECURITY_QUESTION]));
	  	Dialog_Show(playerid, DIALOG_SEC_ANSWER, DIALOG_STYLE_PASSWORD, "[2/2] Set your security answer:", string, "Finish", "Back");
		return 1;
	}

	SHA256_PassHash(inputtext, PASSWORD_SALT, p_Account[playerid][E_ACCOUNT_SECURITY_ANSWER], 64);

 	DB::CreateRow("Users",
 	                "Name", STRING, ReturnPlayerName(playerid),
 	                "Password", STRING, p_Account[playerid][E_ACCOUNT_PASSWORD],
 	                "SecurityQuestion", INTEGER, p_Account[playerid][E_ACCOUNT_SECURITY_QUESTION],
 	                "SecurityAnswer", STRING, p_Account[playerid][E_ACCOUNT_SECURITY_ANSWER],
 	                "Ip", STRING, ReturnPlayerIp(playerid),
 	                "Kills", INTEGER, p_Account[playerid][E_ACCOUNT_KILLS],
 	                "Deaths", INTEGER, p_Account[playerid][E_ACCOUNT_DEATHS],
 	                "Money", INTEGER, p_Account[playerid][E_ACCOUNT_MONEY],
 	                "Score", INTEGER, p_Account[playerid][E_ACCOUNT_SCORE],
	 				"RegisterTimeStamp", INTEGER, p_Account[playerid][E_ACCOUNT_REGISTER_TIMESTAMP],
					"LastLoginTimeStamp", INTEGER, p_Account[playerid][E_ACCOUNT_LAST_LOGIN_TIMESTAMP],
					"AdminLevel", INTEGER, p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL],
					"VipLevel", INTEGER, p_Account[playerid][E_ACCOUNT_VIP_LEVEL],
					"MinutesPlayed", INTEGER, p_Account[playerid][E_ACCOUNT_MINUTES_PLAYED],
					"AutoLogin", INTEGER, _:p_Account[playerid][E_ACCOUNT_AUTO_LOGIN],
					"ReadPM", INTEGER, _:p_Account[playerid][E_ACCOUNT_READ_PM],
					"ReadCMD", INTEGER, _:p_Account[playerid][E_ACCOUNT_READ_CMD]);

 	DB::Fetch("Users", _, _, _, "`Name` = '%q'", ReturnPlayerName(playerid));
	p_Account[playerid][E_ACCOUNT_SQLID] = fetch_row_id();
 	fetcher_close();

	static string[150];
	SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________");
	SendClientMessage(playerid, COLOR_GREEN, " ");
	format(string, sizeof (string), "You have successfully registered this account! Your admin level is %i and vip level is %i.", p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL], p_Account[playerid][E_ACCOUNT_VIP_LEVEL]);
 	SendClientMessage(playerid, COLOR_GREEN, string);
	SendClientMessage(playerid, COLOR_GREEN, " ");
	SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________");

  	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

    SetPVarInt(playerid, "gadmin_LoginStatus", 1);
    CallRemoteFunction("OnPlayerLogin", "ii", playerid, 0);
    CallRemoteFunction("OnPlayerRegister", "i", playerid);
	return 1;
}

// ** CALLBACKS 2 **

public OnPlayerDisconnect(playerid, reason)
{
    KillTimer(p_Data[playerid][E_PDATA_UPDATE_TIMER]);

    DB::Update("Users", p_Account[playerid][E_ACCOUNT_SQLID], 1,
 	                "Kills", INTEGER, p_Account[playerid][E_ACCOUNT_KILLS],
 	                "Deaths", INTEGER, p_Account[playerid][E_ACCOUNT_DEATHS],
 	                "Money", INTEGER, p_Account[playerid][E_ACCOUNT_MONEY],
 	                "Score", INTEGER, p_Account[playerid][E_ACCOUNT_SCORE],
	 				"RegisterTimeStamp", INTEGER, gettime(),
					"LastLoginTimeStamp", INTEGER, gettime(),
					"AdminLevel", INTEGER, p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL],
					"VipLevel", INTEGER, p_Account[playerid][E_ACCOUNT_VIP_LEVEL],
					"MinutesPlayed", INTEGER, p_Account[playerid][E_ACCOUNT_MINUTES_PLAYED],
					"AutoLogin", INTEGER, _:p_Account[playerid][E_ACCOUNT_AUTO_LOGIN],
					"ReadPM", INTEGER, _:p_Account[playerid][E_ACCOUNT_READ_PM],
					"ReadCMD", INTEGER, _:p_Account[playerid][E_ACCOUNT_READ_CMD]);

	DestroyDynamic3DTextLabel(p_Data[playerid][E_PDATA_VIP_LABEL]);

    static string[150];
    switch (reason)
	{
		case 0: format(string, sizeof (string), "** %s[%i] has left the server. [Crashed]", ReturnPlayerName(playerid), playerid);
		case 1: format(string, sizeof (string), "** %s[%i] has left the server. [Quit]", ReturnPlayerName(playerid), playerid);
		case 2: format(string, sizeof (string), "** %s[%i] has left the server. [Kicked/Banned]", ReturnPlayerName(playerid), playerid);
	}
	SendClientMessageToAll(COLOR_GREY, string);

	return 1;
}

forward OnPlayerTick(playerid);
public  OnPlayerTick(playerid)
{
	static string[150];

	if (GetPlayerState(playerid) == PLAYER_STATE_SPAWNED)
	{
	    if (p_Account[playerid][E_ACCOUNT_JAIL_TIMELEFT] > 0)
	 	{
			format(string, sizeof (string), "~n~~n~~n~~r~Unjail in %i seconds", p_Account[playerid][E_ACCOUNT_JAIL_TIMELEFT]);
			GameTextForPlayer(playerid, string, 2000, 3);

			p_Account[playerid][E_ACCOUNT_JAIL_TIMELEFT]--;
		   	if (p_Account[playerid][E_ACCOUNT_JAIL_TIMELEFT] == 0)
			{
				format(string, sizeof (string), "%s[%i] has been released from jail [completed his/her time].", ReturnPlayerName(playerid), playerid);
				SendClientMessageToAll(COLOR_LIGHT_BLUE, string);

				GameTextForPlayer(playerid, "~n~~n~~n~~r~Unjailed!", 5000, 3);

				SpawnPlayer(playerid);
		  	}
		}
	}

	if (p_Account[playerid][E_ACCOUNT_MUTE_TIMELEFT] > 0)
	{
		p_Account[playerid][E_ACCOUNT_MUTE_TIMELEFT]--;

		if (p_Account[playerid][E_ACCOUNT_MUTE_TIMELEFT] == 0)
		{
			format(string, sizeof (string), "%s[%i] has been auto unmuted [completed his/her time].", ReturnPlayerName(playerid), playerid);
			SendClientMessageToAll(COLOR_LIGHT_BLUE, string);

			GameTextForPlayer(playerid, "~n~~n~~n~~r~Unmuted!", 5000, 3);
	  	}
	}
}

public OnPlayerRequestSpawn(playerid)
{
	if (GetPVarInt(playerid, "gadmin_LoginStatus") == 0)
	{
		GameTextForPlayer(playerid, "~r~You must login before spawn", 5000, 3);
	    return 0;
	}

	return 1;
}

public OnPlayerSpawn(playerid)
{
	static string[150];

	if (p_Account[playerid][E_ACCOUNT_MUTE_TIMELEFT] > 0)
    {
		format(string, sizeof (string), "Your mute time will end in %i minutes...", floatround(p_Account[playerid][E_ACCOUNT_MUTE_TIMELEFT] / 20.0));
		SendClientMessage(playerid, COLOR_WHITE, string);
	}

	if (p_Account[playerid][E_ACCOUNT_JAIL_TIMELEFT] > 0)
    {
		SetPlayerHealth(playerid, FLOAT_INFINITY);
		SetPlayerArmour(playerid, 0.0);
		SetPlayerInterior(playerid, 3);
		SetPlayerPos(playerid, 197.6661, 173.8179, 1003.0234);
		SetCameraBehindPlayer(playerid);

        SendClientMessage(playerid, COLOR_WHITE, " ");
		SendClientMessage(playerid, COLOR_GREEN, "- In Jail Spawn -");
		format(string, sizeof (string), "Your jail time will end in %i minutes...", floatround(p_Account[playerid][E_ACCOUNT_JAIL_TIMELEFT] / 20.0));
		SendClientMessage(playerid, COLOR_WHITE, string);
        SendClientMessage(playerid, COLOR_WHITE, " ");
		return 0;
	}

	if (p_Data[playerid][E_PDATA_ONDUTY])
    {
        SendClientMessage(playerid, COLOR_WHITE, " ");
        SendClientMessage(playerid, COLOR_GREEN, "- On Duty Spawn -");
        SendClientMessage(playerid, COLOR_WHITE, "You are currently "COL_GREEN"On Admin duty"COL_WHITE". To switch it off, type /offduty.");
        SendClientMessage(playerid, COLOR_WHITE, "For commands list for your respective level, type /acmds.");
        SendClientMessage(playerid, COLOR_WHITE, " ");

        new File:h = fopen(DIRECTORY "adminspawns.ini", io_read);

        new line[100];
		new count;
		while (fread(h, line))
        	count++;

		fseek(h, 0, seek_start);

		new randline = random(count);

	RANDOM_SPAWN:
        count = 0;
        while (fread(h, line))
        {
            if (randline == count)
            {
                new Float:x, Float:y, Float:z, Float:a, in;
				if (sscanf(line, "p<,>fffF(0.0)I(0)", x, y, z, a, in))
				    goto RANDOM_SPAWN;

				SetPlayerPos(playerid, x, y, z);
    			SetPlayerFacingAngle(playerid, a);
    			SetPlayerInterior(playerid, in);
			}
			count++;
        }

        fclose(h);

	    SetPlayerSkin(playerid, 217);
	    SetPlayerColor(playerid, COLOR_PINK);
	    SetPlayerTeam(playerid, 100);
	    ResetPlayerWeapons(playerid);
	    GivePlayerWeapon(playerid, 38, 10000);

	    if (! p_Data[playerid][E_PDATA_GODMODE])
	    	p_Data[playerid][E_PDATA_GODMODE] = true;
	    	
	    if (! p_Data[playerid][E_PDATA_GODCARMODE])
	    	p_Data[playerid][E_PDATA_GODCARMODE] = true;

	    SetPlayerHealth(playerid, FLOAT_INFINITY);
	    SetVehicleHealth(GetPlayerVehicleID(playerid), FLOAT_INFINITY);

	    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
        return 1;
	}

	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if (hittype == BULLET_HIT_TYPE_VEHICLE)
    {
        if (!p_Data[playerid][E_PDATA_ONDUTY])
        {
	        for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	        {
	        	if (IsPlayerConnected(i) && p_Data[i][E_PDATA_ONDUTY] && GetPlayerVehicleID(i) == hitid && GetPlayerVehicleSeat(i) == 0)
        		{
					GameTextForPlayer(playerid, "~r~Don't hit admin vehicles", 5000, 3);
	          		return 0;
		        }
			}
		}
    }

    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if (!ispassenger)
	{
	    if (p_Data[playerid][E_PDATA_GODCARMODE])
	    	SetVehicleHealth(vehicleid, FLOAT_INFINITY);

		if (!p_Data[playerid][E_PDATA_ONDUTY])
        {
	        for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	        {
	        	if (IsPlayerConnected(i) && p_Data[i][E_PDATA_ONDUTY] && GetPlayerVehicleID(i) == vehicleid && GetPlayerVehicleSeat(i) == 0)
        		{
	        	    new Float:x, Float:y, Float:z;
					GetPlayerPos(playerid, x, y, z);
					SetPlayerPos(playerid, x, y, z + 1.0);

		        	GameTextForPlayer(playerid, "~r~Don't jack admin vehicles", 3000, 3);
	          		return 0;
	        	}
		 	}
		}
	}

    return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
    if (p_Data[playerid][E_PDATA_GODCARMODE])
	{
	    SetVehicleHealth(vehicleid, FLOAT_INFINITY);
    	UpdateVehicleDamageStatus(vehicleid, 0, 0, 0, 0);
	}

	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (newstate == PLAYER_STATE_DRIVER)
	{
	    if (p_Data[playerid][E_PDATA_GODCARMODE])
		{
		    new vehicleid = GetPlayerVehicleID(playerid);
	    	RepairVehicle(vehicleid);
	    	UpdateVehicleDamageStatus(vehicleid, 0, 0, 0, 0);
	    	SetVehicleHealth(vehicleid, FLOAT_INFINITY);
		}
	}
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{
	if (!p_Data[playerid][E_PDATA_ONDUTY])
 	{
	    if (p_Data[damagedid][E_PDATA_ONDUTY])
		{
	    	GameTextForPlayer(playerid, "~r~Don't attack admins!", 3000, 3);
	    	return 0;
    	}
	}

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    p_Account[playerid][E_ACCOUNT_DEATHS]++;

	if (killerid != INVALID_PLAYER_ID)
    	p_Account[killerid][E_ACCOUNT_KILLS]++;

	return 1;
}

public OnPlayerUpdate(playerid)
{
	static string[150];

	if (g_Settings[E_SETTINGS_MAX_PING] > 0)
	{
	    if (GetPlayerPing(playerid) > g_Settings[E_SETTINGS_MAX_PING])
	    {
	        if ((GetTickCount() - p_Data[playerid][E_PDATA_MAX_PING_TICKCONT]) >= 3500)
	        {
		        p_Data[playerid][E_PDATA_MAX_PING_WARNINGS]++;
		        if (p_Data[playerid][E_PDATA_MAX_PING_WARNINGS] == g_Settings[E_SETTINGS_MAX_WARNINGS])
		        {
		            p_Data[playerid][E_PDATA_MAX_PING_TICKCONT] = GetTickCount();

				    format(string, sizeof (string), "%s[%i] has been auto kicked from the server.", ReturnPlayerName(playerid), playerid);
				    SendClientMessageToAll(COLOR_CORAL, string);
				    format(string, sizeof (string), "Reason: High ping [%i/%i]", GetPlayerPing(playerid), g_Settings[E_SETTINGS_MAX_PING]);
			     	SendClientMessageToAll(COLOR_CORAL, string);

					return Kick(playerid);
		        }

				format(string, sizeof (string), "High ping warning [%i/%i] (you will be kicked if reached max warnings %i/%i)", GetPlayerPing(playerid), g_Settings[E_SETTINGS_MAX_PING], p_Data[playerid][E_PDATA_MAX_PING_WARNINGS], g_Settings[E_SETTINGS_MAX_WARNINGS]);
    			SendClientMessageToAll(COLOR_CORAL, string);
			}
	    }
	}
	
	if (p_Data[playerid][E_PDATA_GODCARMODE])
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if (vehicleid != INVALID_VEHICLE_ID)
	    {
	        if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	        {
	            new Float: health;
	            GetVehicleHealth(vehicleid, health);
	            if (health < 999.0)
	            	SetVehicleHealth(vehicleid, FLOAT_INFINITY);
	        }
	    }
	}
	return 1;
}

bool:IsAdvertisement(text[])
{
    new message[128], extract[2], element[4][4], count_1, count_2, temp, bool:number_next = false, bool:next_number = false, bool:advert = false;
    strcat(message, text, sizeof(message));

    for(new i = 0, j = strlen(message); i < j; i ++)
    {
        switch(message[i])
        {
            case '0'..'9':
            {
                if(next_number)
                {
                    continue;
                }

                number_next = false;

                strmid(extract, message[i], 0, 1);
                strcat(element[count_1], extract);

                count_2 ++;

                if(count_2 == 3 || message[i + 1] == EOS)
                {
                    strmid(extract, message[i + 1], 0, 1);

                    if(IsNumeric(extract))
                    {
                        element[0][0] = EOS;
                        element[1][0] = EOS;
                        element[2][0] = EOS;
                        element[3][0] = EOS;

                        count_1 = 0;
                        count_2 = 0;

                        next_number = true;
                        continue;
                    }

                    temp = strval(element[count_1]);

                    if(count_1 == 0)
                    {
                        if(temp <= 255)
                        {
                            count_1 ++;
                            count_2 = 0;
                        }
                        else
                        {
                            element[count_1][0] = EOS;

                            count_2 = 0;

                            next_number = true;
                        }
                    }
                    else
                    {
                        if(temp <= 255)
                        {
                            count_1 ++;
                            count_2 = 0;
                        }
                        else
                        {
                            element[0][0] = EOS;
                            element[1][0] = EOS;
                            element[2][0] = EOS;
                            element[3][0] = EOS;

                            count_1 = 0;
                            count_2 = 0;

                            next_number = true;
                        }
                    }
                }

                if(count_1 == 4)
                {
                    advert = true;
                    break;
                }
            }
            default:
            {
                next_number = false;

                if(number_next)
                {
                    continue;
                }

                if(!isnull(element[count_1]))
                {
                    temp = strval(element[count_1]);

                    if(count_1 == 0)
                    {
                        if(temp <= 255)
                        {
                            count_1 ++;
                            count_2 = 0;

                            number_next = true;
                        }
                        else
                        {
                            element[count_1][0] = EOS;

                            count_2 = 0;
                        }
                    }
                    else
                    {
                        if(temp <= 255)
                        {
                            count_1 ++;
                            count_2 = 0;

                            number_next = true;
                        }
                        else
                        {
                            element[0][0] = EOS;
                            element[1][0] = EOS;
                            element[2][0] = EOS;
                            element[3][0] = EOS;

                            count_1 = 0;
                            count_2 = 0;
                        }
                    }

                    if(count_1 == 4)
                    {
                        advert = true;
                        break;
                    }
                }
            }
        }
    }
    return advert;
}

public OnPlayerText(playerid, text[])
{
    if (g_Settings[E_SETTINGS_ANTI_SPAM])
	{
		if ((GetTickCount() - p_Data[playerid][E_PDATA_LAST_TEXT_TICKCOUNT]) < 500)
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: You shall wait few milli-secs because this counts as a spam in chat.");
	}
	p_Data[playerid][E_PDATA_LAST_TEXT_TICKCOUNT] = GetTickCount();

    if (g_Settings[E_SETTINGS_ANTI_CAPS])
	{
	    new i;
		while (text[++i])
		{
			if ('A' <= text[i] <= 'Z')
				text[i] |= 0x20;
		}
	}

	static string[150];

	if (g_Settings[E_SETTINGS_ANTI_ADVERT])
	{
		if (IsAdvertisement(text))
		{
			if (p_Data[playerid][E_PDATA_WARNINGS] >= g_Settings[E_SETTINGS_MAX_WARNINGS])
			{
			 	format(string, sizeof (string), "%s[%i] has been auto kicked from the server.", ReturnPlayerName(playerid), playerid);
			 	SendClientMessageToAll(COLOR_CORAL, string);
			 	format(string, sizeof (string), "Reason: Reached maximum warnings limit [%i/%i]", g_Settings[E_SETTINGS_MAX_WARNINGS], g_Settings[E_SETTINGS_MAX_WARNINGS]);
			 	SendClientMessageToAll(COLOR_CORAL, string);

			 	Kick(playerid);
			 	return 0;
			}

		 	format(string, sizeof (string), "%s[%i] has been auto warned by server.", ReturnPlayerName(playerid), playerid);
		 	SendClientMessageToAll(COLOR_YELLOW, string);
		 	SendClientMessageToAll(COLOR_YELLOW, "Reason: Advertising");
		 	return 0;
		}
	}

	if (text[0] == '!')
	{
	    if (IsPlayerAdmin(playerid) || p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] >= 1)
		{
			format(string, sizeof (string), "[AdminChat] %s[%i]: %s", ReturnPlayerName(playerid), playerid, text[1]);
			for (new i, j = GetPlayerPoolSize(); i <= j; i++)
			{
			    if (IsPlayerConnected(i) && p_Account[i][E_ACCOUNT_ADMIN_LEVEL] >= 1)
					SendClientMessage(i, COLOR_HOT_PINK, string);
		    }
			return 0;
		}
	}
	else if (text[0] == '@')
	{
		if (IsPlayerAdmin(playerid) || p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] >= 4)
		{
			format(string, sizeof (string), "[Level4Chat] %s[%i]: %s", ReturnPlayerName(playerid), playerid, text[1]);
			for (new i, j = GetPlayerPoolSize(); i <= j; i++)
			{
			    if (IsPlayerConnected(i) && p_Account[i][E_ACCOUNT_ADMIN_LEVEL] >= 4)
					SendClientMessage(i, COLOR_HOT_PINK, string);
		    }
		    return 0;
		}
	}
	else if (text[0] == '#')
	{
		if (IsPlayerAdmin(playerid) || p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] >= 5)
		{
			format(string, sizeof (string), "[Level5Chat] %s[%i]: %s", ReturnPlayerName(playerid), playerid, text[1]);
			for (new i, j = GetPlayerPoolSize(); i <= j; i++)
			{
			    if (IsPlayerConnected(i) && p_Account[i][E_ACCOUNT_ADMIN_LEVEL] >= 5)
					SendClientMessage(i, COLOR_HOT_PINK, string);
		    }
		    return 0;
		}
	}

	if (p_Data[playerid][E_PDATA_ONDUTY])
	{
		format(string, sizeof (string), "Admin %s[%i]: %s", ReturnPlayerName(playerid), playerid, text);
		SendClientMessageToAll(COLOR_PINK, string);
		return 0;
	}
	else if (p_Account[playerid][E_ACCOUNT_VIP_LEVEL] > 0)
	{
		format(string, sizeof (string), ""COL_CYAN"[VIP] {%06x}%s[%i]: "COL_WHITE"%s", GetPlayerColor(playerid) >>> 8, ReturnPlayerName(playerid), playerid, text);
		SendClientMessageToAll(GetPlayerColor(playerid), string);
		return 0;
	}

	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if (p_Account[playerid][E_ACCOUNT_MUTE_TIMELEFT] > 0)
	{
	    SendClientMessage(playerid, COLOR_TOMATO, "Error: You are muted from chat.");
	    return 0;
	}
	else if (p_Account[playerid][E_ACCOUNT_JAIL_TIMELEFT] > 0)
	{
	    SendClientMessage(playerid, COLOR_TOMATO, "Error: You are in jail.");
	    return 0;
	}

	static string[150];
	if (g_Settings[E_SETTINGS_READ_CMD])
	{
	    format(string, sizeof (string), "** %s[%i] uses %s", ReturnPlayerName(playerid), playerid, cmdtext);
        for (new i, j = GetPlayerPoolSize(); i <= j; i++)
		{
		    if (!IsPlayerConnected(i))
				continue;

			if (i == playerid)
				continue;

			if (p_Account[i][E_ACCOUNT_ADMIN_LEVEL] < 3)
				continue;

			if (p_Account[i][E_ACCOUNT_ADMIN_LEVEL] < p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
				continue;

			if (!p_Account[i][E_ACCOUNT_READ_CMD])
			    continue;

   		   	SendClientMessage(i, COLOR_GREY, string);
		}
	}

	return 1;
}

// ** COMMANDS **

CMD:gcmds(playerid)
{
	static info[(6 * 500)];
	info[0] = EOS;

	strcat(info, COL_DARK_GREEN "•> Player commands\n");
 	strcat(info, COL_WHITE "• /admins, /vips, /dnd, /pm, /reply, /time, /changename, /changepass, /autologin, /report, /stats\n");
 	strcat(info, COL_WHITE "• /id, /richlist, /scorelist\n");
 	strcat(info, "\n");

	if (IsPlayerAdmin(playerid) || p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] >= 1)
	{
	    strcat(info, COL_LIGHT_BLUE "•> Admin level 1 - Operator\n");
	    strcat(info, COL_WHITE "• /spec, /specoff, /weaps, /warn, /resetwarns, /kick, /ip, /spawn, /goto, /move, /asay,\n");
	    strcat(info, "• /adminarea, /asaym, /reports, /repair, /addnos, /flip, /god, /godcar\n");
	    strcat(info, ""COL_THISTLE"** Admin chat: "COL_GREEN"! "COL_THISTLE"(e.g. \"!hello admins\")\n");
	    strcat(info, "\n");
	}
	if (IsPlayerAdmin(playerid) || p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] >= 2)
	{
	    strcat(info, COL_LIGHT_BLUE "•> Admin level 2 - Moderator\n");
	    strcat(info, COL_WHITE "• /clearchat, /ann, /ann2, /screen, /jetpack, /aka, /aweaps, /eject, /car, /givecar, /akill, /jail,\n");
	    strcat(info, "• /unjail, /jailed, /mute, /unmute, /muted, /sethealth, /setarmour, /setskin, /setinterior, /setworld,\n");
	    strcat(info, "• /slap, /explode, /disarm, /ban, /searchban, /unban, /get\n");
	    strcat(info, "\n");
	}
	if (IsPlayerAdmin(playerid) || p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] >= 3)
	{
	    strcat(info, COL_LIGHT_BLUE "•> Admin level 3 - Administrator\n");
	    strcat(info, COL_WHITE "• /force, /setstyle, /freeze, /unfreeze, /giveweapon, /setcolor, /setcash, /givecash, /setscore,\n");
	    strcat(info, "• /unjail, /jailed, /mute, /unmute, /muted, /sethealth, /setarmour, /setskin, /setinterior, /setworld,\n");
	    strcat(info, "• /givescore, /setkills, /setdeaths, /spawncar, /destroycar, /spawncars\n");
	    strcat(info, "\n");
	}
	if (IsPlayerAdmin(playerid) || p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] >= 4)
	{
	    strcat(info, COL_LIGHT_BLUE "•> Admin level 4 - Manager\n");
	    strcat(info, COL_WHITE "• /rban, /fakedeath, /fakechat, /clearwindow, /muteall, /unmuteall, /giveallcash, /giveallscore, /setttime\n");
	    strcat(info, "• /setweather, /giveallweapon, /object, /destroyobject, /editobject, /adminspawns, /questions, /freezeall, /unfreezeall\n");
	    strcat(info, ""COL_THISTLE"** Admin levle 4 chat: "COL_GREEN"@ "COL_THISTLE"(e.g. \"@hello level 4 admins\")\n");
	    strcat(info, "\n");
	}
	if (IsPlayerAdmin(playerid) || p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] >= 5)
	{
	    strcat(info, COL_LIGHT_BLUE "•> Admin level 5 - Owner/RCON\n");
	    strcat(info, COL_WHITE "• /restart, /setlevel, /setvip, /settings\n");
	    strcat(info, ""COL_THISTLE"** Admin levle 5 chat: "COL_GREEN"# "COL_THISTLE"(e.g. \"#hello level 5 admins\")\n");
	    strcat(info, "\n");
	}

	Dialog_Show(playerid, 0, DIALOG_STYLE_MSGBOX, "Admin commands", info, "Ok", "");

	return 1;
}

// ** PLAYER COMMANDS **

CMD:admins(playerid)
{
	if (!g_Settings[E_SETTINGS_ADMIN_CMD])
        return SendClientMessage(playerid, COLOR_TOMATO, "Error: The command has been disabled at the moment.");

	static levelname[5][25];
	levelname[0] = "Operator";
	levelname[1] = "Moderator";
	levelname[2] = "Administrator";
	levelname[3] = "Manager";
	levelname[4] = "Owner/RCON";

	static status[3][30];
	status[0] = COL_GREY "Not logged in" COL_LIGHT_BLUE;
	status[1] = COL_HOT_PINK "On duty" COL_LIGHT_BLUE;
	status[2] = "Off duty";

	static dnd[2][15];
	dnd[0] = "Off";
	dnd[1] = COL_TOMATO "On";

	new count;
	static string[150];

	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if (IsPlayerConnected(i))
        {
			if (p_Account[i][E_ACCOUNT_ADMIN_LEVEL] >= 1 || IsPlayerAdmin(i))
			{
			    if (count == 0)
			    {
			        SendClientMessage(playerid, COLOR_LIGHT_BLUE, " ");
					SendClientMessage(playerid, COLOR_LIGHT_BLUE, "- Online staff members -");
				}

				count++;
				format(string, sizeof (string), "%i. %s[%i] | Level %i - %s | Status: %s | DND. Mode: %s", count, ReturnPlayerName(i), i, p_Account[i][E_ACCOUNT_ADMIN_LEVEL], levelname[(p_Account[i][E_ACCOUNT_ADMIN_LEVEL] > 5) ? (4) : (p_Account[i][E_ACCOUNT_ADMIN_LEVEL] - 1)], status[((GetPVarInt(playerid, "gadmin_LoginStatus") == 0) ? (0) : ((p_Data[i][E_PDATA_ONDUTY]) ? (1) : (2)))], dnd[_:p_Data[i][E_PDATA_NO_PM]]);
				SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
			}
		}
	}

    if (count == 0)
        SendClientMessage(playerid, COLOR_TOMATO, "Error: No staff online.");
	return 1;
}

CMD:vips(playerid)
{
	static dnd[2][15];
	dnd[0] = "Off";
	dnd[1] = COL_TOMATO "On";

	new count;
	static string[150];

	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if (IsPlayerConnected(i))
        {
			if (p_Account[i][E_ACCOUNT_VIP_LEVEL] >= 1)
			{
			    if (count == 0)
			    {
			        SendClientMessage(playerid, COLOR_LIGHT_BLUE, " ");
					SendClientMessage(playerid, COLOR_LIGHT_BLUE, "- Online vip members -");
				}

				count++;
				format(string, sizeof (string), "%i. %s[%i] | Level %i | DND. Mode: %s", count, ReturnPlayerName(i), i, p_Account[i][E_ACCOUNT_VIP_LEVEL], dnd[_:p_Data[i][E_PDATA_NO_PM]]);
				SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
			}
		}
	}

    if (count == 0)
        SendClientMessage(playerid, COLOR_TOMATO, "Error: No Vip player online.");
	return 1;
}

CMD:dnd(playerid)
{
	if (!p_Data[playerid][E_PDATA_NO_PM])
		SendClientMessage(playerid, COLOR_TOMATO, "DND. Mode Activated (you won't recieve PM.s anymore).");
	else
		SendClientMessage(playerid, COLOR_GREEN, "DND. Mode Deactivated (you will recieve PM.s from now).");

	p_Data[playerid][E_PDATA_NO_PM] = (!p_Data[playerid][E_PDATA_NO_PM]);
	return 1;
}
CMD:nopm(playerid)
	return cmd_dnd(playerid);

CMD:pm(playerid, params[])
{
	new targetid = INVALID_PLAYER_ID, text[128];
	if (sscanf(params, "uS[128]", targetid, text))
	{
	    if (targetid == INVALID_PLAYER_ID)
			return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /pm [player] [*message]");
	}

	if (targetid == playerid)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the command on yourself.");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Data[targetid][E_PDATA_NO_PM])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player has DND. mode activated.");

	static string[250];

	if (p_Data[playerid][E_PDATA_LAST_PM_ID] != targetid)
	{
 		format(string, sizeof (string), "You are now messaging %s[%i].", ReturnPlayerName(targetid), targetid);
	    SendClientMessage(playerid, COLOR_YELLOW, string);
	}
	p_Data[playerid][E_PDATA_LAST_PM_ID] = targetid;

	if (p_Data[targetid][E_PDATA_LAST_PM_ID] != playerid)
	{
 		format(string, sizeof (string), "You are now messaging %s[%i].", ReturnPlayerName(playerid), playerid);
	    SendClientMessage(targetid, COLOR_YELLOW, string);
	}
	p_Data[targetid][E_PDATA_LAST_PM_ID] = playerid;

	if (!text[0])
	{
	    format(string, sizeof (string), ""COL_WHITE"Write your message to "COL_LIGHT_BLUE"%s[%i] "COL_WHITE"(admin level %i | vip level %i)", ReturnPlayerName(targetid), targetid, p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL], p_Account[targetid][E_ACCOUNT_VIP_LEVEL]);
		return Dialog_Show(playerid, DIALOG_PRIVATE_MESSAGE, DIALOG_STYLE_INPUT, "Private messaging...", string, "Send", "Cancel");
	}

	PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
	PlayerPlaySound(targetid, 1085, 0.0, 0.0, 0.0);

	format(string, sizeof (string), "[PM] %s[%i]: %s", ReturnPlayerName(targetid), targetid, text);
	SendClientMessage(playerid, COLOR_YELLOW, string);
	format(string, sizeof (string), "[PM] You: %s", text);
	SendClientMessage(targetid, COLOR_YELLOW, string);

	if (g_Settings[E_SETTINGS_READ_PM])
	{
	    format(string, sizeof (string), "** [PM] %s[%i] to %s[%i]: %s", ReturnPlayerName(playerid), playerid, ReturnPlayerName(targetid), targetid, text);
        for (new i, j = GetPlayerPoolSize(); i <= j; i++)
		{
		    if (!IsPlayerConnected(i))
				continue;

			if (i == playerid || i == targetid)
				continue;

			if (p_Account[i][E_ACCOUNT_ADMIN_LEVEL] < 3)
				continue;

			if (p_Account[i][E_ACCOUNT_ADMIN_LEVEL] < p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
				continue;

			if (!p_Account[i][E_ACCOUNT_READ_PM])
			    continue;

   		   	SendClientMessage(i, COLOR_GREY, string);
		}
	}
	return 1;
}

CMD:reply(playerid, params[])
{
	new text[128];
	if (sscanf(params, "s[128]", text))
	{
		SendClientMessage(playerid, COLOR_GREY, "Tip: You can also quick reply by /reply [*message].");
	}

	new targetid = p_Data[playerid][E_PDATA_LAST_PM_ID];

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is no more connected.");

	if (p_Data[targetid][E_PDATA_NO_PM])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is having DND. mode activated now.");

	static string[250];

	if (!text[0])
	{
	    format(string, sizeof (string), ""COL_WHITE"Write your message to "COL_LIGHT_BLUE"%s[%i] "COL_WHITE"(admin level %i | vip level %i)", ReturnPlayerName(targetid), targetid, p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL], p_Account[targetid][E_ACCOUNT_VIP_LEVEL]);
		return Dialog_Show(playerid, DIALOG_PRIVATE_MESSAGE, DIALOG_STYLE_INPUT, "Private messaging...", string, "Send", "Cancel");
	}

	PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
	PlayerPlaySound(targetid, 1085, 0.0, 0.0, 0.0);

	format(string, sizeof (string), "[PM] %s[%i]: %s", ReturnPlayerName(targetid), targetid, text);
	SendClientMessage(playerid, COLOR_YELLOW, string);
	format(string, sizeof (string), "[PM] You: %s", text);
	SendClientMessage(targetid, COLOR_YELLOW, string);

	if (g_Settings[E_SETTINGS_READ_PM])
	{
	    format(string, sizeof (string), "** [PM] %s[%i] to %s[%i]: %s", ReturnPlayerName(playerid), playerid, ReturnPlayerName(targetid), targetid, text);
        for (new i, j = GetPlayerPoolSize(); i <= j; i++)
		{
		    if (!IsPlayerConnected(i))
				continue;

			if (i == playerid || i == targetid)
				continue;

			if (p_Account[i][E_ACCOUNT_ADMIN_LEVEL] < 3)
				continue;

			if (p_Account[i][E_ACCOUNT_ADMIN_LEVEL] < p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
				continue;

			if (!p_Account[i][E_ACCOUNT_READ_PM])
			    continue;

   		   	SendClientMessage(i, COLOR_GREY, string);
		}
	}
	return 1;
}

Dialog:DIALOG_PRIVATE_MESSAGE(playerid, response, listitem, inputext[])
{
	if (response)
	{
		static string[250];

		new targetid = p_Data[targetid][E_PDATA_LAST_PM_ID];

		new text[128];
		if (sscanf(inputext, "s[128]", text))
			SendClientMessage(playerid, COLOR_TOMATO, "Error: Message cannot be empty.");
		else
		{
		    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
			PlayerPlaySound(targetid, 1085, 0.0, 0.0, 0.0);

			format(string, sizeof (string), "[PM] %s[%i]: %s", ReturnPlayerName(targetid), targetid, text);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			format(string, sizeof (string), "[PM] You: %s", text);
			SendClientMessage(targetid, COLOR_YELLOW, string);

			if (g_Settings[E_SETTINGS_READ_PM])
			{
			    format(string, sizeof (string), "** [PM] %s[%i] to %s[%i]: %s", ReturnPlayerName(playerid), playerid, ReturnPlayerName(targetid), targetid, text);
		        for (new i, j = GetPlayerPoolSize(); i <= j; i++)
				{
				    if (!IsPlayerConnected(i))
						continue;

					if (i == playerid || i == targetid)
						continue;

					if (p_Account[i][E_ACCOUNT_ADMIN_LEVEL] < 3)
						continue;

					if (p_Account[i][E_ACCOUNT_ADMIN_LEVEL] < p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
						continue;

					if (!p_Account[i][E_ACCOUNT_READ_PM])
					    continue;

		   		   	SendClientMessage(i, COLOR_GREY, string);
				}
			}
		}

		format(string, sizeof (string), ""COL_WHITE"Write your message to "COL_LIGHT_BLUE"%s[%i] "COL_WHITE"(admin level %i | vip level %i)", ReturnPlayerName(targetid), targetid, p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL], p_Account[targetid][E_ACCOUNT_VIP_LEVEL]);
		return Dialog_Show(playerid, DIALOG_PRIVATE_MESSAGE, DIALOG_STYLE_INPUT, "Private messaging...", string, "Send", "Cancel");
	}
	return 1;
}

CMD:time(playerid, params[])
{
	new hour, minute, second;
	gettime(hour, minute, second);
	#pragma unused second

	static string[150];
	format(string, sizeof (string), "[SERVER TIME] %i:%i", hour, minute);
	SendClientMessage(playerid, COLOR_WHITE, string);

	format(string, sizeof (string), "~w~~h~%i:%i", hour, minute);
	GameTextForPlayer(playerid, string, 5000, 1);
	return 1;
}

CMD:changename(playerid, params[])
{
	if (GetPVarInt(playerid, "gadmin_LoginStatus") != 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only registered users can use this command.");

	new name[MAX_PLAYER_NAME];
    if (sscanf(params, "s[24]", name))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /changename [newname]");

	new len = strlen(name);
	if (len < 4 || len > MAX_PLAYER_NAME)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Username length must be between 4 - 24.");

	if (!strcmp(name, ReturnPlayerName(playerid)))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You already have that username.");

	DB::Fetch("Users", _, _, _, "`Name` = '%q'", name);
	if (fetch_rows_count() > 0)
	{
	    fetcher_close();
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The username is already taken, choose another one.");
	}
 	fetcher_close();

	static string[150];
	
    DB::Fetch("Users", _, _, _, "`Name` = '%q'", ReturnPlayerName(playerid));
	if (gettime() < fetch_int("LastNameChange"))
	{
	    fetcher_close();
	    
	    format(string, sizeof (string), "Error: You have to wait %i minutes before chaning name again.", ((fetch_int("LastNameChange") - gettime()) / 60));
		return SendClientMessage(playerid, COLOR_TOMATO, string);
	}
 	fetcher_close();

	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    DB::Update("Users", p_Account[playerid][E_ACCOUNT_SQLID], 1,
 	                "Name", STRING, name,
				 	"LastNameChange", INTEGER, (gettime() + (60 * 1000)));

	format(string, sizeof (string), "Success! Username changed to %s [Old name: %s].", name, ReturnPlayerName(playerid));
	SendClientMessage(playerid, COLOR_GREEN, string);
	GameTextForPlayer(playerid, "~g~Username changed", 5000, 1);

	SetPlayerName(playerid, name);
	return 1;
}

CMD:changepass(playerid, params[])
{
	if (GetPVarInt(playerid, "gadmin_LoginStatus") != 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only registered users can use this command.");

	static string[150];

	new pass[MAX_PASSWORD_LENGTH];
	format(string, sizeof (string), "s[%i]", MAX_PASSWORD_LENGTH);
    if (sscanf(params, string, pass))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /changepass [newpass]");

	new len = strlen(pass);
	if (len < MIN_PASSWORD_LENGTH || len > MAX_PASSWORD_LENGTH)
	{
		format(string, sizeof (string), "Error: Password length must be between %i - %i.", MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH);
		return SendClientMessage(playerid, COLOR_TOMATO, string);
	}

    SHA256_PassHash(pass, PASSWORD_SALT, p_Account[playerid][E_ACCOUNT_PASSWORD], 64);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    DB::Update("Users", p_Account[playerid][E_ACCOUNT_SQLID], 1,
 	                "Password", STRING, p_Account[playerid][E_ACCOUNT_PASSWORD]);

	new password[MAX_PASSWORD_LENGTH];
	for (new i; i < len; i++)
		password[i] = '*';

	format(string, sizeof (string), "PASSWORD CHANGED TO '%s'.", password);
	SendClientMessage(playerid, COLOR_GREEN, string);
	GameTextForPlayer(playerid, "~g~Password changed", 5000, 1);
	return 1;
}

CMD:autologin(playerid)
{
	if (GetPVarInt(playerid, "gadmin_LoginStatus") != 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only registered users can use this command.");

	Dialog_Show(playerid, DIALOG_AUTOLOGIN, DIALOG_STYLE_MSGBOX, "Toggle automatic login?", ""COL_WHITE"Auto login will detect your IP. and if it matches, then you won't be shown any login dialog and will be loggen in.", "Enable", "Disable");
	return 1;
}

Dialog:DIALOG_AUTOLOGIN(playerid, response, listitem, inputtext[])
{
	if (response)
		SendClientMessage(playerid, COLOR_GREEN, "Auto-Login Activated.");
	else
		SendClientMessage(playerid, COLOR_TOMATO, "Auto-Login Deactivated.");

 	p_Account[playerid][E_ACCOUNT_AUTO_LOGIN] = bool:response;
	return 1;
}

CMD:report(playerid, params[])
{
	new targetid, reason[65];
	if (sscanf(params, "us[100]", targetid, reason))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /report [player] [reason]");

	if (strlen(reason) < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Reason cannot be empty.");

	if (targetid == playerid)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot report yourself.");
	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is no more connected.");

	new hour, minute, second;
	gettime(hour, minute, second);

	static string[150];
	format(string, sizeof (string), "Report: %s[%i] has reported against %s[%i], type /reports to check it.", ReturnPlayerName(playerid), playerid, ReturnPlayerName(targetid), targetid);
	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if (!IsPlayerConnected(i))
			continue;

		if (p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] > 0 || IsPlayerAdmin(i))
			SendClientMessage(i, COLOR_CORAL, string);
	}

	for (new i = (MAX_REPORTS - 1); i >= 1; i--)
	{
	    g_Report[i][E_REPORT_VALID] = g_Report[i - 1][E_REPORT_VALID];
	    g_Report[i][E_REPORT_AGAINST_ID] = g_Report[i - 1][E_REPORT_AGAINST_ID];
	    format(g_Report[i][E_REPORT_AGAINST_NAME], MAX_PLAYER_NAME, g_Report[i - 1][E_REPORT_AGAINST_NAME]);
	    g_Report[i][E_REPORT_FROM_ID] = g_Report[i - 1][E_REPORT_FROM_ID];
	    format(g_Report[i][E_REPORT_FROM_NAME], MAX_PLAYER_NAME, g_Report[i - 1][E_REPORT_FROM_NAME]);
	    g_Report[i][E_REPORT_TIMESTAMP] = g_Report[i - 1][E_REPORT_TIMESTAMP];
	    format(g_Report[i][E_REPORT_REASON], 65, g_Report[i - 1][E_REPORT_REASON]);
	    g_Report[i][E_REPORT_CHECKED] = g_Report[i - 1][E_REPORT_CHECKED];
	}

	g_Report[0][E_REPORT_VALID] = true;
	g_Report[0][E_REPORT_AGAINST_ID] = targetid;
	GetPlayerName(targetid, g_Report[0][E_REPORT_AGAINST_NAME], MAX_PLAYER_NAME);
	g_Report[0][E_REPORT_FROM_ID] = playerid;
	GetPlayerName(playerid, g_Report[0][E_REPORT_FROM_NAME], MAX_PLAYER_NAME);
	g_Report[0][E_REPORT_TIMESTAMP] = gettime();
 	format(g_Report[0][E_REPORT_REASON], 65, reason);
	g_Report[0][E_REPORT_CHECKED] = false;
 	
 	for (new x; x < MAX_PLAYERS; x++)
	    	g_ReportChecked[x][0] = g_ReportChecked[x][0];

	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	format(string, sizeof (string), "Your report has been sent to online admins [Against: %s].", ReturnPlayerName(targetid));
	SendClientMessage(playerid, COLOR_DARK_GREEN, string);
	return 1;
}

CMD:stats(playerid, params[])
{
	new targetid;
	if (sscanf(params, "u", targetid))
	{
  		targetid = playerid;
		SendClientMessage(playerid, COLOR_GREY, "Tip: You can also view other players stats by /stats [player]");
	}

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is no more connected.");

	static string[150];

	DB::Fetch("Users", _, _, _, "`Name` = '%q'", ReturnPlayerName(targetid));
	new rowid = fetch_row_id();
	new registeron = fetch_int("RegisterTimeStamp");
	new lastlogin = fetch_int("LastLoginTimeStamp");
	fetcher_close();

	SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________");
	SendClientMessage(playerid, COLOR_GREEN, " ");
	format(string, sizeof (string), "%s[%i]'s stats: (AccountId: %i)", ReturnPlayerName(targetid), targetid, rowid);
	SendClientMessage(playerid, COLOR_GREEN, string);

	new Float:ratio = ((p_Account[targetid][E_ACCOUNT_DEATHS] < 0) ? (0.0) : (floatdiv(p_Account[targetid][E_ACCOUNT_KILLS], p_Account[targetid][E_ACCOUNT_DEATHS])));

	static levelname[6][25];
	levelname[0] = "None";
	levelname[1] = "Operator";
	levelname[2] = "Moderator";
	levelname[3] = "Administrator";
	levelname[4] = "Manager";
	levelname[5] = "Owner/RCON";

	static dnd[2][30];
	dnd[0] = "Off";
	dnd[1] = COL_TOMATO "On" COL_GREEN;

	format(string, sizeof (string), "Score: %i || Money: $%i || Kills: %i || Deaths: %i || Ratio: %0.2f || DND. Mode: %s || Admin Level: %i - %s || Vip Level: %i",
		GetPlayerScore(targetid), GetPlayerMoney(targetid), p_Account[targetid][E_ACCOUNT_KILLS], p_Account[targetid][E_ACCOUNT_DEATHS], ratio, dnd[_:p_Data[targetid][E_PDATA_NO_PM]], p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL], levelname[((p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > 5) ? (5) : (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL]))], p_Account[targetid][E_ACCOUNT_VIP_LEVEL]);
	SendClientMessage(playerid, COLOR_GREEN, string);

	format(string, sizeof (string), "Time Played: %i minutes || Registeration Date: %s || Last Seen: %s",
		p_Account[targetid][E_ACCOUNT_MINUTES_PLAYED], ReturnDate(registeron), ReturnDate(lastlogin));
	SendClientMessage(playerid, COLOR_GREEN, string);

	SendClientMessage(playerid, COLOR_GREEN, " ");
	SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________");
	return 1;
}

CMD:id(playerid, params[])
{
	new name[MAX_PLAYER_NAME];
	if (sscanf(params, "s[24]", name))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /id [name]");

	static string[150];

	SendClientMessage(playerid, COLOR_LIGHT_BLUE, " ");
	format(string, sizeof(string), "- Search result for '%s' -", name);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

	new count;
	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    if (IsPlayerConnected(i))
	    {
		    if (strfind(ReturnPlayerName(i), name, true) != -1)
		    {
				format(string, sizeof (string), "%i. %s[%i]", ++count, ReturnPlayerName(i), i);
				SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
			}
		}
	}

	if (! count)
		return SendClientMessage(playerid, COLOR_LIGHT_BLUE, "No match found.");
	return 1;
}
CMD:getid(playerid, params[])
{
	return cmd_id(playerid, params);
}

CMD:richlist(playerid)
{
	new array[MAX_PLAYERS][2];
	new count;
	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    if (IsPlayerConnected(i))
	    {
		    array[count][0] = GetPlayerMoney(i);
		    array[count][1] = i;
		    count++;
		}
	}

	QuickSort_Pair(array, true, 0, count);

	static string[150];

	SendClientMessage(playerid, COLOR_LIGHT_BLUE, " ");
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "- Top 5 richest players -");
	for (new i, j = ((count > 5) ? (5) : (count)); i < j; i++)
	{
		format(string, sizeof (string), "%i. %s[%i] - $%i", (i + 1), ReturnPlayerName(array[i][1]), array[i][1], array[i][0]);
		SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	}
	return 1;
}

CMD:scorelist(playerid)
{
	new array[MAX_PLAYERS][2];
	new count;
	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    if (IsPlayerConnected(i))
	    {
		    array[count][0] = GetPlayerScore(i);
		    array[count][1] = i;
		    count++;
		}
	}

	QuickSort_Pair(array, true, 0, count);

	static string[150];

	SendClientMessage(playerid, COLOR_LIGHT_BLUE, " ");
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "- Top 5 richest players in score -");
	for (new i, j = ((count > 5) ? (5) : (count)); i < j; i++)
	{
		format(string, sizeof (string), "%i. %s[%i] - %i score", (i + 1), ReturnPlayerName(array[i][1]), array[i][1], array[i][0]);
		SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	}
	return 1;
}

CMD:kill(playerid)
{
	if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || GetPlayerState(playerid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot perform this command when spectating or not spawned.");

	if (IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You must be on foot to use this command.");

	SetPlayerHealth(playerid, 0.0);
	SendClientMessage(playerid, COLOR_TOMATO, "You commited sucide!");
	return 1;
}

// ** LEVEL 1+ COMMANDS **

CMD:spec(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

    new targetid;
    if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /spec [player]");

	if (targetid == playerid)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the command on yourself.");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

    if (GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
		TogglePlayerSpectating(playerid, true);
	PlayerSpectatePlayer(playerid, targetid);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "Spectate: You are now spectating %s[%i].", ReturnPlayerName(targetid), targetid);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "Spectate: To turn off spectate mode, type /specoff.");
	return 1;
}

CMD:specoff(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	if (GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot perform this command when you aren't spectating.");

	TogglePlayerSpectating(playerid, false);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "Spectate: You are no longer spectating.");
	return 1;
}

CMD:weaps(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

    new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /weaps [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	static string[150];
	format(string, sizeof (string), "%s[%i]'s weapons:", ReturnPlayerName(targetid), targetid);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

	new w, a;
	new count;
	new name[35];
	string[0] = EOS;
	for (new i; i < 14; i++)
	{
		GetPlayerWeaponData(targetid, i, w, a);
		if (w > 0 && a > 0)
		{
		    GetWeaponName(w, name, sizeof (name));
		    if (string[0])
		   		format(string, sizeof (string), "%s, %s (%i)", string, name, a);
			else
				format(string, sizeof (string), "%s (%i)", name, a);

		    count++;
			if (count >= 5)
			{
				SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

			    count = 0;
				string[0] = EOS;
			}
		}
	}
	return 1;
}

CMD:warn(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	new targetid, reason[65];
    if (sscanf(params, "uS(No reason specified)[65]", targetid, reason))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /warn [player] [reason]");

	if (targetid == playerid)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the command on yourself.");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	p_Data[targetid][E_PDATA_WARNINGS]++;
	PlayerPlaySound(targetid, 5203, 0.0, 0.0, 0.0);

	static string[300];
	if (p_Data[targetid][E_PDATA_WARNINGS] >= g_Settings[E_SETTINGS_MAX_WARNINGS])
	{
	 	format(string, sizeof (string), "%s[%i] has been auto kicked from the server.", ReturnPlayerName(targetid), targetid);
	 	SendClientMessageToAll(COLOR_CORAL, string);
	 	format(string, sizeof (string), "Reason: Reached maximum warnings limit [%i/%i]", g_Settings[E_SETTINGS_MAX_WARNINGS], g_Settings[E_SETTINGS_MAX_WARNINGS]);
	 	SendClientMessageToAll(COLOR_CORAL, string);

	 	Kick(targetid);
	}

 	format(string, sizeof (string), "%s[%i] has been warned by admin %s[%i].", ReturnPlayerName(targetid), targetid, ReturnPlayerName(playerid), playerid);
 	SendClientMessageToAll(COLOR_YELLOW, string);
 	format(string, sizeof (string), "Reason: %s", reason);
 	SendClientMessageToAll(COLOR_YELLOW, string);

	format(string, sizeof (string), ""COL_WHITE"You have been issued a warning from an admin [you are left with "COL_TOMATO"%i/%i "COL_WHITE"warnings].\n"COL_TOMATO"Reason: "COL_WHITE"%s\n"COL_TOMATO"Admin: "COL_WHITE"%s[%i]", p_Data[targetid][E_PDATA_WARNINGS], g_Settings[E_SETTINGS_MAX_WARNINGS], reason, ReturnPlayerName(playerid), playerid);
	Dialog_Show(targetid, 0, DIALOG_STYLE_MSGBOX, "Warning issued...", string, "Ok", "");
	return 1;
}

CMD:resetwarns(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	new targetid;
    if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /resetwarns [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	p_Data[targetid][E_PDATA_WARNINGS] = 0;

	static string[300];
 	format(string, sizeof (string), "Admin %s[%i] has reset your warnings count to 0.", ReturnPlayerName(playerid), playerid);
 	SendClientMessage(targetid, COLOR_YELLOW, string);
 	format(string, sizeof (string), "You have set %s[%i]'s warnings count to 0.", ReturnPlayerName(targetid), targetid);
 	SendClientMessage(playerid, COLOR_YELLOW, string);
	return 1;
}

CMD:kick(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	new targetid, reason[65];
    if (sscanf(params, "uS(No reason specified)[65]", targetid, reason))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /kick [player] [reason]");

	if (targetid == playerid)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the command on yourself.");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	PlayerPlaySound(targetid, 5454, 0.0, 0.0, 0.0);

	static string[300];
 	format(string, sizeof (string), "%s[%i] has been kicked by admin %s[%i].", ReturnPlayerName(targetid), targetid, ReturnPlayerName(playerid), playerid);
 	SendClientMessageToAll(COLOR_CORAL, string);
 	format(string, sizeof (string), "Reason: %s", reason);
 	SendClientMessageToAll(COLOR_CORAL, string);

	format(string, sizeof (string), ""COL_WHITE"You have been issued a kick from an admin [if you think this was missuse of power, report on our forums].\n"COL_TOMATO"Reason: "COL_WHITE"%s\n"COL_TOMATO"Admin: "COL_WHITE"%s[%i]", reason, ReturnPlayerName(playerid), playerid);
	Dialog_Show(targetid, 0, DIALOG_STYLE_MSGBOX, "Kick issued...", string, "Ok", "");

	Kick(targetid);
	return 1;
}

CMD:ip(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /ip [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	static string[150];
	format(string, sizeof (string), "%s's IP: %s", ReturnPlayerName(targetid), ReturnPlayerIp(targetid));
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:spawn(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /spawn [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	SpawnPlayer(targetid);

	if (targetid == playerid)
	    return 1;

	static string[300];
 	format(string, sizeof (string), "Admin %s[%i] has re-spawned you back.", ReturnPlayerName(playerid), playerid);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have re-spawned %s[%i].", ReturnPlayerName(targetid), targetid);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:goto(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /goto [player]");

	if (targetid == playerid)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the command on yourself.");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	SetPlayerInterior(playerid, GetPlayerInterior(targetid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));

	new Float:x, Float:y, Float:z;
	GetPlayerPos(targetid, x, y, z);
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
		SetVehiclePos(vehicleid, x, (y + 2.5), z);
		LinkVehicleToInterior(vehicleid, GetPlayerInterior(targetid));
		SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(targetid));
	}
	else
		SetPlayerPos(playerid, x, (y + 2.0), z);

	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has teleported to you.", ReturnPlayerName(playerid), playerid);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have teleported to %s[%i].", ReturnPlayerName(targetid), targetid);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:move(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	new targetid, direction[5], Float:distance;
	if (sscanf(params, "us[5]F(5.0)", targetid, direction, distance))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /move [player] [up/down/left/right] [*distance]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	new Float:x, Float:y, Float:z;
	GetPlayerPos(targetid, x, y, z);
	if (!strcmp(direction, "up"))
	    SetPlayerPos(targetid, x, y, (z + distance));
	else if (!strcmp(direction, "down"))
	    SetPlayerPos(targetid, x, y, (z - distance));
	else if (!strcmp(direction, "left"))
	    SetPlayerPos(targetid, (z - distance), y, z);
	else if (!strcmp(direction, "right"))
	    SetPlayerPos(targetid, (z + distance), y, z);
	else
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid direction.");

	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
		return 1;

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has moved you [direction: %s].", ReturnPlayerName(playerid), playerid, direction);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have moved %s[%i] [direction: %s].", ReturnPlayerName(targetid), targetid, direction);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:asay(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	new text[128];
	if (sscanf(params, "s[128]", text))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /asay [text]");

	static string[150];
	format(string, sizeof (string), "Admin %s[%i]: %s", ReturnPlayerName(playerid), playerid, text);
	SendClientMessageToAll(COLOR_PINK, string);
	return 1;
}

CMD:adminarea(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || GetPlayerState(playerid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot perform this command when spectating or not spawned.");

	SetPlayerPos(playerid, 377.0, 170.0, 1008.0);
	SetPlayerFacingAngle(playerid, 90.0);
	SetPlayerInterior(playerid, 3);
	SetPlayerVirtualWorld(playerid, 0);

	GameTextForPlayer(playerid, "~b~Admin Area", 5000, 3);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "You have teleported to admin area.");
    return 1;
}

CMD:god(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	if (!p_Data[playerid][E_PDATA_GODMODE])
	{
	    SetPlayerHealth(playerid, FLOAT_INFINITY);
	    GameTextForPlayer(playerid, "~g~Godmode on", 5000, 3);
	}
	else
	{
	    SetPlayerHealth(playerid, 100.0);
	    GameTextForPlayer(playerid, "~r~Godmode off", 5000, 3);
	}
	p_Data[playerid][E_PDATA_GODMODE] = !p_Data[playerid][E_PDATA_GODMODE];
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	return 1;
}

CMD:godcar(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	if (!p_Data[playerid][E_PDATA_GODCARMODE])
	{
	    SetVehicleHealth(GetPlayerVehicleID(playerid), FLOAT_INFINITY);
	    RepairVehicle(GetPlayerVehicleID(playerid));
	    GameTextForPlayer(playerid, "~g~Godmode car on", 5000, 3);
	}
	else
	{
	    SetVehicleHealth(GetPlayerVehicleID(playerid), 1000.0);
	    GameTextForPlayer(playerid, "~g~Godmode car off", 5000, 3);
	}
	p_Data[playerid][E_PDATA_GODCARMODE] = !p_Data[playerid][E_PDATA_GODCARMODE];
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	return 1;
}

CMD:onduty(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || GetPlayerState(playerid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot perform this command when spectating or not spawned.");

	if (p_Data[playerid][E_PDATA_ONDUTY])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You are already on admin duty, try /offduty.");

    p_Data[playerid][E_PDATA_ONDUTY] = true;
    SpawnPlayer(playerid);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "Admin %s[%i] is now On-Admin duty.", ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}

CMD:offduty(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	if (!p_Data[playerid][E_PDATA_ONDUTY])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You are already on admin duty, try /onduty.");

    p_Data[playerid][E_PDATA_ONDUTY] = false;
    SpawnPlayer(playerid);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "You are Off-Admin duty, type /onduty to switch it on anytime.");

	static string[150];
	format(string, sizeof (string), "Admin %s[%i] is now Off-Admin duty.", ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}

CMD:reports(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

	static info[150 * (MAX_REPORTS+1)];
	info[0] = EOS;
	for (new i; i < MAX_REPORTS; i++)
	{
	    if (g_Report[i][E_REPORT_VALID])
	    {
		    if (g_ReportChecked[playerid][i])
				format(info, sizeof (info), "%s("COL_GREEN"Read"COL_WHITE") %s reported against %s | %s\n", info, g_Report[i][E_REPORT_AGAINST_NAME], g_Report[i][E_REPORT_FROM_NAME], ReturnTimelapse(g_Report[i][E_REPORT_TIMESTAMP], gettime()));
			else
				format(info, sizeof (info), "%s("COL_ORANGE"Unread"COL_WHITE") %s reported against %s | %s\n", info, g_Report[i][E_REPORT_AGAINST_NAME], g_Report[i][E_REPORT_FROM_NAME], ReturnTimelapse(g_Report[i][E_REPORT_TIMESTAMP], gettime()));
	    }
	}
	
	if (!info[0])
        return SendClientMessage(playerid, COLOR_TOMATO, "Error: No reports found in log.");

	Dialog_Show(playerid, DIALOG_REPORTS_LIST, DIALOG_STYLE_LIST, "Reports list", info, "Select", "Cancel");
	return 1;
}

Dialog:DIALOG_REPORTS_LIST(playerid, response, listitem, inputtext[])
{
	if (response)
	{
	    static string[500];
	    format(string, sizeof (string), COL_WHITE "This report was filed %s...\n\nReport From: "COL_TOMATO"%s "COL_WHITE"(id: %i)\nReport Against: "COL_TOMATO"%s "COL_WHITE"(id: %i)\n\nReason: %s\n\n"COL_GREY"Type 'kick <reason>' to kick %s for the reason you'll write.\nType 'warn <reason>' to warn %s for the reason you'll write.\nType 'spectate' to spectate %s.\nType 'clear' to remove the report form log.",
			ReturnTimelapse(g_Report[listitem][E_REPORT_TIMESTAMP], gettime()), g_Report[listitem][E_REPORT_FROM_NAME], g_Report[listitem][E_REPORT_FROM_ID], g_Report[listitem][E_REPORT_AGAINST_NAME], g_Report[listitem][E_REPORT_AGAINST_ID], g_Report[listitem][E_REPORT_REASON], g_Report[listitem][E_REPORT_AGAINST_NAME], g_Report[listitem][E_REPORT_AGAINST_NAME], g_Report[listitem][E_REPORT_AGAINST_NAME], g_Report[listitem][E_REPORT_AGAINST_NAME]);
	    Dialog_Show(playerid, DIALOG_REPORT, DIALOG_STYLE_INPUT, "Report id #%i", string, "Take Action", "Back");

        if (g_Report[listitem][E_REPORT_CHECKED])
		{
		    g_Report[listitem][E_REPORT_CHECKED] = true;
		    g_ReportChecked[playerid][listitem] = true;
		    
		    format(string, sizeof (string), "Your report is now being checked by admin %s[%i].", ReturnPlayerName(playerid), playerid);
		    SendClientMessage(g_Report[listitem][E_REPORT_FROM_ID], COLOR_DARK_GREEN, string);
		}

	    SetPVarInt(playerid, "DialogListitem", listitem);
	}
	return 1;
}

Dialog:DIALOG_REPORT(playerid, response, listitem, inputtext[])
{
	if (response)
	{
	    new action[20], reason[65];
	    if (!sscanf(inputtext, "s[20]S(No reason specified)[65]", action, reason))
	    {
	        if (!strcmp(action, "kick", true))
	        {
	            if (!reason[0])
		        {
					SendClientMessage(playerid, COLOR_TOMATO, "Error: No reason specified. Reason cannot be empty, please specify one.");
					return dialog_DIALOG_REPORTS_LIST(playerid, 1, GetPVarInt(playerid, "DialogListitem"), "");
				}
				
				if (g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID] == playerid)
		        {
					SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the action on yourself.");
					return dialog_DIALOG_REPORTS_LIST(playerid, 1, GetPVarInt(playerid, "DialogListitem"), "");
				}

				if (!IsPlayerConnected(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]))
				{
					SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");
					return dialog_DIALOG_REPORTS_LIST(playerid, 1, GetPVarInt(playerid, "DialogListitem"), "");
				}

				if (p_Account[g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
				{
					SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this action on higher admin level player.");
					return dialog_DIALOG_REPORTS_LIST(playerid, 1, GetPVarInt(playerid, "DialogListitem"), "");
				}
				
				PlayerPlaySound(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID], 5454, 0.0, 0.0, 0.0);

				static string[300];
			 	format(string, sizeof (string), "%s[%i] has been kicked by admin %s[%i].", g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_NAME], g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID], ReturnPlayerName(playerid), playerid);
			 	SendClientMessageToAll(COLOR_CORAL, string);
			 	format(string, sizeof (string), "Reason: %s", reason);
			 	SendClientMessageToAll(COLOR_CORAL, string);

				format(string, sizeof (string), ""COL_WHITE"You have been issued a kick from an admin [if you think this was missuse of power, report on our forums].\n"COL_TOMATO"Reason: "COL_WHITE"%s\n"COL_TOMATO"Admin: "COL_WHITE"%s[%i]", reason, ReturnPlayerName(playerid), playerid);
				Dialog_Show(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID], 0, DIALOG_STYLE_MSGBOX, "Kick issued...", string, "Ok", "");

				Kick(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]);
			}
	        else if (!strcmp(action, "warn", true))
	        {
	            if (!reason[0])
		        {
					SendClientMessage(playerid, COLOR_TOMATO, "Error: No reason specified. Reason cannot be empty, please specify one.");
					return cmd_reports(playerid);
				}

				if (g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID] == playerid)
		        {
					SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the action on yourself.");
					return dialog_DIALOG_REPORTS_LIST(playerid, 1, GetPVarInt(playerid, "DialogListitem"), "");
				}

				if (!IsPlayerConnected(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]))
				{
					SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");
					return dialog_DIALOG_REPORTS_LIST(playerid, 1, GetPVarInt(playerid, "DialogListitem"), "");
				}

				if (p_Account[g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
				{
					SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this action on higher admin level player.");
					return dialog_DIALOG_REPORTS_LIST(playerid, 1, GetPVarInt(playerid, "DialogListitem"), "");
				}
				
				p_Data[g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]][E_PDATA_WARNINGS]++;
				PlayerPlaySound(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID], 5203, 0.0, 0.0, 0.0);

				static string[300];
				if (p_Data[g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]][E_PDATA_WARNINGS] >= g_Settings[E_SETTINGS_MAX_WARNINGS])
				{
				 	format(string, sizeof (string), "%s[%i] has been auto kicked from the server.", ReturnPlayerName(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]), g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]);
				 	SendClientMessageToAll(COLOR_CORAL, string);
				 	format(string, sizeof (string), "Reason: Reached maximum warnings limit [%i/%i]", g_Settings[E_SETTINGS_MAX_WARNINGS], g_Settings[E_SETTINGS_MAX_WARNINGS]);
				 	SendClientMessageToAll(COLOR_CORAL, string);

				 	Kick(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]);
				}

			 	format(string, sizeof (string), "%s[%i] has been warned by admin %s[%i].", ReturnPlayerName(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]), g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID], ReturnPlayerName(playerid), playerid);
			 	SendClientMessageToAll(COLOR_YELLOW, string);
			 	format(string, sizeof (string), "Reason: %s", reason);
			 	SendClientMessageToAll(COLOR_YELLOW, string);

				format(string, sizeof (string), ""COL_WHITE"You have been issued a warning from an admin [you are left with "COL_TOMATO"%i/%i "COL_WHITE"warnings].\n"COL_TOMATO"Reason: "COL_WHITE"%s\n"COL_TOMATO"Admin: "COL_WHITE"%s[%i]", p_Data[g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]][E_PDATA_WARNINGS], g_Settings[E_SETTINGS_MAX_WARNINGS], reason, ReturnPlayerName(playerid), playerid);
				Dialog_Show(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID], 0, DIALOG_STYLE_MSGBOX, "Warning issued...", string, "Ok", "");
	        }
	        else if (!strcmp(action, "spectate", true))
	        {
				if (g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID] == playerid)
		        {
					SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the action on yourself.");
					return dialog_DIALOG_REPORTS_LIST(playerid, 1, GetPVarInt(playerid, "DialogListitem"), "");
				}

				if (!IsPlayerConnected(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]))
				{
					SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");
					return dialog_DIALOG_REPORTS_LIST(playerid, 1, GetPVarInt(playerid, "DialogListitem"), "");
				}
				
				if (GetPlayerState(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]) == PLAYER_STATE_SPECTATING || GetPlayerState(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]) == PLAYER_STATE_WASTED)
				{
					SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");
					return dialog_DIALOG_REPORTS_LIST(playerid, 1, GetPVarInt(playerid, "DialogListitem"), "");
				}

	            if (GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
					TogglePlayerSpectating(playerid, true);
				PlayerSpectatePlayer(playerid, g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]);
				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

				static string[150];
				format(string, sizeof (string), "Spectate: You are now spectating %s[%i].", ReturnPlayerName(g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]), g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_ID]);
				SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
				SendClientMessage(playerid, COLOR_LIGHT_BLUE, "Spectate: To turn off spectate mode, type /specoff.");
	        }
	        else if (!strcmp(action, "clear", true))
	        {
			    g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_VALID] = false;
		        
		        static string[150];
			    format(string, sizeof (string), "You have cleared report id #%i [Against: %s | From %s].", GetPVarInt(playerid, "DialogListitem"), g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_AGAINST_NAME], g_Report[GetPVarInt(playerid, "DialogListitem")][E_REPORT_FROM_NAME]);
				SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
				
		        DeletePVar(playerid, "DialogListitem");
	        }
	    }
	    else
	    {
	        if (!action[0])
	        {
				SendClientMessage(playerid, COLOR_TOMATO, "Error: No action specified. Type in your action in the inputbox.");
				return cmd_reports(playerid);
			}
	    }
	}
	else
	{
		cmd_reports(playerid);
	}

	DeletePVar(playerid, "DialogListitem");
	return 1;
}

CMD:repair(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

    new targetid;
    if (!sscanf(params, "u", targetid))
    {
		if (!IsPlayerConnected(targetid))
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

		new vehicleid = GetPlayerVehicleID(targetid);
		if (vehicleid == INVALID_VEHICLE_ID)
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player is not in any vehicle.");

		RepairVehicle(vehicleid);

		GameTextForPlayer(targetid, "~g~Vehicle repaired", 5000, 3);
		PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		PlayerPlaySound(targetid, 1133, 0.0, 0.0, 0.0);

	    static string[150];
		format(string, sizeof (string), "You have repaired %s[%i]'s vehicle.", ReturnPlayerName(targetid), targetid);
		SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
		format(string, sizeof (string), "Admin %s[%i] has repaired your vehicle.", ReturnPlayerName(playerid), playerid);
		SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
    }
    else
    {
		new vehicleid = GetPlayerVehicleID(targetid);
		if (vehicleid == INVALID_VEHICLE_ID)
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: You are not in any vehicle.");

		RepairVehicle(vehicleid);

		GameTextForPlayer(playerid, "~g~Vehicle repaired", 5000, 3);
		PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

		SendClientMessage(playerid, COLOR_LIGHT_BLUE, "You have repaired your vehicle.");
		SendClientMessage(playerid, COLOR_GREY, "Tip: You can use this command on other player's vehicle by /repair [player].");
    }

    return 1;
}

CMD:addnos(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

    new targetid;
    if (!sscanf(params, "u", targetid))
    {
		if (!IsPlayerConnected(targetid))
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

		new vehicleid = GetPlayerVehicleID(targetid);
		if (vehicleid == INVALID_VEHICLE_ID)
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player is not in any vehicle.");

		switch (GetVehicleModel(vehicleid))
		{
			case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
				return SendClientMessage(playerid, COLOR_TOMATO, "Error: Vehicle model does not support nitros.");
		}

		AddVehicleComponent(vehicleid, 1010);

		GameTextForPlayer(targetid, "~g~Nitros added", 5000, 3);
		PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		PlayerPlaySound(targetid, 1133, 0.0, 0.0, 0.0);

		static string[150];
		format(string, sizeof (string), "You have added nitros(10x) to %s[%i]'s vehicle.", ReturnPlayerName(targetid), targetid);
		SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
		format(string, sizeof (string), "Admin %s[%i] has added nitros(10x) to your vehicle.", ReturnPlayerName(playerid), playerid);
		SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
    }
    else
    {
		new vehicleid = GetPlayerVehicleID(targetid);
		if (vehicleid == INVALID_VEHICLE_ID)
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: You are not in any vehicle.");

		switch (GetVehicleModel(vehicleid))
		{
			case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
				return SendClientMessage(playerid, COLOR_TOMATO, "Error: Vehicle model does not support nitros.");
		}

		AddVehicleComponent(vehicleid, 1010);

		GameTextForPlayer(playerid, "~g~Nitros added", 5000, 3);
		PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

		SendClientMessage(playerid, COLOR_LIGHT_BLUE, "You have added nitros(10x) to your vehicle.");
		SendClientMessage(playerid, COLOR_GREY, "Tip: You can use this command on other player's vehicle by /addnos [player].");
    }

    return 1;
}

CMD:flip(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 1 and above have access to this command.");

    new targetid;
    if (!sscanf(params, "u", targetid))
    {
		if (!IsPlayerConnected(targetid))
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

		new vehicleid = GetPlayerVehicleID(targetid);
		if (vehicleid == INVALID_VEHICLE_ID)
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player is not in any vehicle.");

		new Float:angle;
		GetVehicleZAngle(vehicleid, angle);
		SetVehicleZAngle(vehicleid, angle);

		GameTextForPlayer(targetid, "~g~Vehicle fliped", 5000, 3);
		PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		PlayerPlaySound(targetid, 1133, 0.0, 0.0, 0.0);

		static string[150];
		format(string, sizeof (string), "You have fliped %s[%i]'s vehicle.", ReturnPlayerName(targetid), targetid);
		SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
		format(string, sizeof (string), "Admin %s[%i] has fliped your vehicle.", ReturnPlayerName(playerid), playerid);
		SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
    }
    else
    {
		new vehicleid = GetPlayerVehicleID(targetid);
		if (vehicleid == INVALID_VEHICLE_ID)
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: You are not in any vehicle.");

		new Float:angle;
		GetVehicleZAngle(vehicleid, angle);
		SetVehicleZAngle(vehicleid, angle);

		GameTextForPlayer(playerid, "~g~Vehicle fliped", 5000, 3);
		PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

		SendClientMessage(playerid, COLOR_LIGHT_BLUE, "You have fliped your vehicle.");
		SendClientMessage(playerid, COLOR_GREY, "Tip: You can use this command on other player's vehicle by /flip [player].");
    }

    return 1;
}

// ** LEVEL 2+ COMMANDS **

CMD:clearchat(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	for (new i; i < 500; i++)
		SendClientMessageToAll(COLOR_WHITE, " ");

	static string[150];
	format(string, sizeof (string), "%s[%i] has cleared the chat window.", ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:ann(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new text[50];
	if (sscanf(params, "s[50]", text))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /ann [text]");

	GameTextForAll(text, 5000, 3);
	return 1;
}

CMD:ann2(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new style, expiretime, text[50];
	if (sscanf(params, "iis[50]", style, expiretime, text))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /ann2 [style] [expiretime] [text]");

	GameTextForAll(text, expiretime, style);
	return 1;
}

CMD:screen(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid, text[50];
	if (sscanf(params, "us[50]", targetid, text))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /screen [player] [message]");

	if (targetid == playerid)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the command on yourself.");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	GameTextForPlayer(targetid, text, 10000, 3);

	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	new buf[150];
	format(buf, sizeof(buf), "Admin %s[%i] has sent you a screen message.", ReturnPlayerName(playerid), playerid);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, buf);
	format(buf, sizeof(buf), "You have sent %s[%i] a scren message.", ReturnPlayerName(targetid), targetid);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, buf);
	return 1;
}

CMD:jetpack(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || GetPlayerState(playerid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot perform this command when spectating or not spawned.");

	new targetid;
	if (!sscanf(params, "u", targetid))
	{
		if (!IsPlayerConnected(targetid))
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
		PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

		static string[150];
	 	format(string, sizeof (string), "Admin %s[%i] has given you a jetpack.", ReturnPlayerName(playerid), playerid);
	 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
	 	format(string, sizeof (string), "You have given %s[%i] a jetpack.", ReturnPlayerName(targetid), targetid);
	 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
		return 1;
	}
	else
	{
		SetPlayerSpecialAction(targetid, SPECIAL_ACTION_USEJETPACK);
		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

		SendClientMessage(playerid, COLOR_LIGHT_BLUE, "You have spawned a jetpack.");
		SendClientMessage(playerid, COLOR_GREY, "Tip: You can use this command on other player's vehicle by /jetpack [player].");
	}

	return 1;
}

CMD:aka(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

    if (!g_Settings[E_SETTINGS_AKA])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: AKA. system is disabled at the moment.");

	new username[MAX_PLAYER_NAME];
	if (sscanf(params, "s[24]", username))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /aka [username]");

	new ip[18];

    DB::Fetch("Users", _, _, _, "`Name` = '%q'", username);
    if (fetch_rows_count() == 0)
    {
        SendClientMessage(playerid, COLOR_TOMATO, "Error: Username not registered.");
        fetcher_close();
        return 1;
    }
	fetch_string("Ip", ip);
	fetcher_close();

	new count;
	new aka[5][MAX_PLAYER_NAME];

	new rowip[18];

	DB::Fetch("Users");
	do
	{
 		fetch_string("Ip", rowip);
   		if (IpMatch(rowip, ip))
	    {
     		if (count < sizeof (aka))
				fetch_string("Name", aka[count]);

			count++;
   		}
	}
	while (fetch_next_row());
	fetcher_close();

   	static string[150];
	if (count <= 1)
	{
	  	format(string, sizeof (string), "Error: There is no other account associated with %s's ip [ip: %s].", username, ip);
	  	SendClientMessage(playerid, COLOR_TOMATO, string);
	  	return 1;
	}

  	format(string, sizeof (string), "Search result for %s's AKA: [ip: %s]", username, ip);
  	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
  	format(string, sizeof (string), "%s", aka[0]);
  	for (new i = 1, j = ((count > sizeof (aka)) ? (sizeof (aka)) : (count)); i < j; i++)
  	{
   		if (i == (j - 1))
	    {
     		if (count > sizeof (aka))
        	   	format(string, sizeof (string), "%s, %s and ......%i more account(s)", string, aka[i], count);
			else
 				format(string, sizeof (string), "%s and %s", string, aka[i]);
	    }
		else
			format(string, sizeof (string), "%s, %s", string, aka[i]);
	}
  	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:aweaps(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || GetPlayerState(playerid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot perform this command when spectating or not spawned.");

	ResetPlayerWeapons(playerid);
    GivePlayerWeapon(playerid, 9, 10000);
    GivePlayerWeapon(playerid, 32, 10000);
    GivePlayerWeapon(playerid, 16, 10000);
    GivePlayerWeapon(playerid, 24, 10000);
    GivePlayerWeapon(playerid, 26, 10000);
    GivePlayerWeapon(playerid, 29, 10000);
    GivePlayerWeapon(playerid, 31, 10000);
    GivePlayerWeapon(playerid, 34, 10000);
    GivePlayerWeapon(playerid, 38, 10000);

	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	GameTextForPlayer(playerid, "~b~Admin weapons!", 5000, 3);
  	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "You have spawned admin weapons.");
    return 1;
}

CMD:eject(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid;
    if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /eject [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	if (!IsPlayerInAnyVehicle(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player is not in any vehicle.");

	new Float:x, Float:y, Float:z;
	GetPlayerPos(targetid, x, y, z);
	SetPlayerPos(targetid, x, y, z + 1.0);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
	format(string, sizeof (string), "Admin %s[%i] has ejected you from the vehicle.", ReturnPlayerName(playerid), playerid);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
	format(string, sizeof (string), "You have ejected %s[%i] from his vehicle.", ReturnPlayerName(targetid), targetid);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:car(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || GetPlayerState(playerid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot perform this command when spectating or not spawned.");

    new vehicle[32], color1, color2;
	if (sscanf(params, "s[32]I(-1)I(-1)", vehicle, color1, color2))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /car [vehicle] [*color1] [*color2]");

	new model;
	if (IsNumeric(vehicle))
		model = strval(vehicle);
	else
	{
		for (new i, j = sizeof (VEHICLE_NAMES); i < j; i++)
		{
			if (strfind(VEHICLE_NAMES[i], vehicle, true) != -1)
			{
				model = (i + 400);
				break;
			}
		}
	}

	if (model < 400 || model > 611)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid vehicle model id/name.");

	if (IsValidVehicle(p_Data[playerid][E_PDATA_VEHICLE_ID]))
		DestroyVehicle(p_Data[playerid][E_PDATA_VEHICLE_ID]);

	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

	if (IsPlayerInAnyVehicle(playerid))
		SetPlayerPos(playerid, x, y, (z + 1.0));

    GetXYInFrontOfPlayer(playerid, x, y, 3.0);
	p_Data[playerid][E_PDATA_VEHICLE_ID] = CreateVehicle(model, x, y, z, a, color1, color2, -1);
    SetVehicleVirtualWorld(p_Data[playerid][E_PDATA_VEHICLE_ID], GetPlayerVirtualWorld(playerid));
    LinkVehicleToInterior(p_Data[playerid][E_PDATA_VEHICLE_ID], GetPlayerInterior(playerid));
    PutPlayerInVehicle(playerid, p_Data[playerid][E_PDATA_VEHICLE_ID], 0);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "You have spawned a %s (model: %i | color1: %i | color2: %i).", VEHICLE_NAMES[(model - 400)], model, color1, color2);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:givecar(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

    new targetid, vehicle[32], color1, color2;
	if (sscanf(params, "us[32]I(-1)I(-1)", targetid, vehicle, color1, color2))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /givecar [player] [vehicle] [*color1] [*color2]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

	new model;
	if (IsNumeric(vehicle))
		model = strval(vehicle);
	else
	{
		for (new i, j = sizeof (VEHICLE_NAMES); i < j; i++)
		{
			if (strfind(VEHICLE_NAMES[i], vehicle, true) != -1)
			{
				model = (i + 400);
				break;
			}
		}
	}

	if (model < 400 || model > 611)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid vehicle model id/name.");

	if (IsValidVehicle(p_Data[targetid][E_PDATA_VEHICLE_ID]))
		DestroyVehicle(p_Data[targetid][E_PDATA_VEHICLE_ID]);

	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(targetid, x, y, z);
    GetPlayerFacingAngle(targetid, a);

	if (IsPlayerInAnyVehicle(targetid))
		SetPlayerPos(targetid, x, y, (z + 1.0));

    GetXYInFrontOfPlayer(targetid, x, y, 3.0);
	p_Data[targetid][E_PDATA_VEHICLE_ID] = CreateVehicle(model, x, y, z, a, color1, color2, -1);
    SetVehicleVirtualWorld(p_Data[targetid][E_PDATA_VEHICLE_ID], GetPlayerVirtualWorld(targetid));
    LinkVehicleToInterior(p_Data[targetid][E_PDATA_VEHICLE_ID], GetPlayerInterior(targetid));
    PutPlayerInVehicle(targetid, p_Data[targetid][E_PDATA_VEHICLE_ID], 0);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "Admin %s[%i] has given you a %s (model: %i | color1: %i | color2: %i).", ReturnPlayerName(playerid), playerid, VEHICLE_NAMES[(model - 400)], model, color1, color2);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
	format(string, sizeof (string), "You have given %s[%i] a %s (model: %i | color1: %i | color2: %i).", ReturnPlayerName(targetid), targetid, VEHICLE_NAMES[(model - 400)], model, color1, color2);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:akill(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid, reason[65];
    if (sscanf(params, "uS(No reason specified)[65]", targetid, reason))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /akill [player] [reason]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

    SetPlayerHealth(targetid, 0.0);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "%s[%i] was sent to death by admin %s[%i].", ReturnPlayerName(targetid), targetid, ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	format(string, sizeof (string), "[Reason: %s]", reason);
	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:jail(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid, minutes, reason[65];
    if (sscanf(params, "uI(2)S(No reason specified)[65]", targetid, minutes, reason))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /jail [player] [minutes] [reason]");

	if (targetid == playerid)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the command on yourself.");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	if (minutes < 1 || minutes > 10)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The jail time must be between 1 - 10 minutes.");

	if (p_Account[targetid][E_ACCOUNT_JAIL_TIMELEFT] > 0)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player is already in jail.");

    p_Account[targetid][E_ACCOUNT_JAIL_TIMELEFT] = (minutes * 60);
	SpawnPlayer(targetid);
	GameTextForPlayer(targetid, "~r~Jailed", 5000, 3);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "%s[%i] is sent to jail for %i minutes by admin %s[%i].", ReturnPlayerName(targetid), targetid, minutes, ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_ORANGE, string);
	format(string, sizeof (string), "[Reason: %s]", reason);
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}

CMD:unjail(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid;
    if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /unjail [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_JAIL_TIMELEFT] <= 0)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player is not in jail.");

    p_Account[targetid][E_ACCOUNT_JAIL_TIMELEFT] = 0;
	SpawnPlayer(targetid);
	GameTextForPlayer(targetid, "~g~Unjailed", 5000, 3);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "%s[%i] has been unjailed by admin %s[%i].", ReturnPlayerName(targetid), targetid, ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:jailed(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new count;

    static info[MAX_PLAYERS * 150];
    info = "S.No.\tName\tTimeleft\n";
    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    {
		if (IsPlayerConnected(i) && p_Account[i][E_ACCOUNT_JAIL_TIMELEFT] > 0)
		{
			count++;
			format(info, sizeof (info), "%s#%i\t%s[%i]\t%i seconds...\n", info, count, ReturnPlayerName(i), i, p_Account[i][E_ACCOUNT_JAIL_TIMELEFT]);
		}
    }

    if (count <= 0)
        return SendClientMessage(playerid, COLOR_TOMATO, "Error: No one is in jail.");

    Dialog_Show(playerid, DIALOG_JAILED, DIALOG_STYLE_TABLIST_HEADERS, "Jailed players", info, "Unjail", "Cancel");
	return 1;
}

Dialog:DIALOG_JAILED(playerid, response, listitem, inputtext[])
{
	if (response)
	{
	    new count, targetid = INVALID_PLAYER_ID;
	    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	    {
			if (IsPlayerConnected(i))
			{
				if (count == listitem && p_Account[i][E_ACCOUNT_JAIL_TIMELEFT] > 0)
				{
				    targetid = i;
					break;
	    		}
				count++;
			}
		}

		if (targetid == INVALID_PLAYER_ID)
		{
		    SendClientMessage(playerid, COLOR_TOMATO, "Error: The selected player left in the tick.");
		    cmd_muted(playerid);
		    return 1;
		}

		static string[100];
		format(string, sizeof (string), ""COL_WHITE"Are you sure you want to unjail "COL_SAMP_BLUE"%s[%i]"COL_WHITE"?", ReturnPlayerName(targetid), targetid);
		Dialog_Show(playerid, DIALOG_CONFIRM_UNJAIL, DIALOG_STYLE_MSGBOX, "Unjail confirmation:", string, "Yes", "No");

		SetPVarInt(playerid, "DialogExtraid", targetid);
	}
	return 1;
}

Dialog:DIALOG_CONFIRM_UNJAIL(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
	    cmd_muted(playerid);
	}
	else
	{
	    p_Account[GetPVarInt(playerid, "DialogExtraid")][E_ACCOUNT_JAIL_TIMELEFT] = 0;
		PlayerPlaySound(GetPVarInt(playerid, "DialogExtraid"), 1057, 0.0, 0.0, 0.0);
		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

		static string[150];
		format(string, sizeof (string), "%s[%i] has been unjailed by admin %s[%i].", ReturnPlayerName(GetPVarInt(playerid, "DialogExtraid")), GetPVarInt(playerid, "DialogExtraid"), ReturnPlayerName(playerid), playerid);
		SendClientMessageToAll(COLOR_LIGHT_BLUE, string);

		DeletePVar(playerid, "DialogExtraid");
	}
	return 1;
}

CMD:mute(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid, minutes, reason[65];
    if (sscanf(params, "uI(2)S(No reason specified)[65]", targetid, minutes, reason))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /mute [player] [minutes] [reason]");

	if (targetid == playerid)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the command on yourself.");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	if (minutes < 1 || minutes > 10)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The jail time must be between 1 - 10 minutes.");

	if (p_Account[targetid][E_ACCOUNT_MUTE_TIMELEFT] > 0)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player is already muted.");

    p_Account[targetid][E_ACCOUNT_MUTE_TIMELEFT] = (minutes * 60);
	GameTextForPlayer(targetid, "~r~Muted", 5000, 3);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "%s[%i] has been muted for %i minutes by admin %s[%i].", ReturnPlayerName(targetid), targetid, minutes, ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_ORANGE, string);
	format(string, sizeof (string), "[Reason: %s]", reason);
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}

CMD:unmute(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid;
    if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /unjail [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_MUTE_TIMELEFT] <= 0)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player is not in muted.");

    p_Account[targetid][E_ACCOUNT_MUTE_TIMELEFT] = 0;
	GameTextForPlayer(targetid, "~g~Unmuted", 5000, 3);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "%s[%i] has been unmuted by admin %s[%i].", ReturnPlayerName(targetid), targetid, ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:muted(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new count;

    static info[MAX_PLAYERS * 150];
    info = "S.No.\tName\tTimeleft\n";
    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    {
		if (IsPlayerConnected(i) && p_Account[i][E_ACCOUNT_MUTE_TIMELEFT] > 0)
		{
			count++;
			format(info, sizeof (info), "%s#%i\t%s[%i]\t%i seconds...\n", info, count, ReturnPlayerName(i), i, p_Account[i][E_ACCOUNT_MUTE_TIMELEFT]);
		}
    }

    if (count <= 0)
        return SendClientMessage(playerid, COLOR_TOMATO, "Error: No one is muted.");

    Dialog_Show(playerid, DIALOG_MUTED, DIALOG_STYLE_TABLIST_HEADERS, "Muted players", info, "Unmute", "Cancel");
	return 1;
}

Dialog:DIALOG_MUTED(playerid, response, listitem, inputtext[])
{
	if (response)
	{
	    new count, targetid = INVALID_PLAYER_ID;
	    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	    {
			if (IsPlayerConnected(i) && p_Account[i][E_ACCOUNT_MUTE_TIMELEFT] > 0)
			{
				if (count == listitem)
				{
				    targetid = i;
					break;
	    		}
				count++;
			}
		}

		if (targetid == INVALID_PLAYER_ID)
		{
		    SendClientMessage(playerid, COLOR_TOMATO, "Error: The selected player left in the tick.");
		    cmd_muted(playerid);
		    return 1;
		}

		static string[100];
		format(string, sizeof (string), ""COL_WHITE"Are you sure you want to unmute "COL_SAMP_BLUE"%s[%i]"COL_WHITE"?", ReturnPlayerName(targetid), targetid);
		Dialog_Show(playerid, DIALOG_CONFIRM_UNMUTE, DIALOG_STYLE_MSGBOX, "Unmute confirmation:", string, "Yes", "No");

		SetPVarInt(playerid, "DialogExtraid", targetid);
	}
	return 1;
}

Dialog:DIALOG_CONFIRM_UNMUTE(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
	    cmd_muted(playerid);
	}
	else
	{
	    p_Account[GetPVarInt(playerid, "DialogExtraid")][E_ACCOUNT_MUTE_TIMELEFT] = 0;
		PlayerPlaySound(GetPVarInt(playerid, "DialogExtraid"), 1057, 0.0, 0.0, 0.0);
		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

		static string[150];
		format(string, sizeof (string), "%s[%i] has been unmuted by admin %s[%i].", ReturnPlayerName(GetPVarInt(playerid, "DialogExtraid")), GetPVarInt(playerid, "DialogExtraid"), ReturnPlayerName(playerid), playerid);
		SendClientMessageToAll(COLOR_LIGHT_BLUE, string);

		DeletePVar(playerid, "DialogExtraid");
	}
	return 1;
}

CMD:sethealth(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid, Float:val;
	if (sscanf(params, "uF(100)", targetid, val))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /sethealth [player] [*amount]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

	if (p_Data[playerid][E_PDATA_GODMODE])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is on godmode.");

    SetPlayerHealth(targetid, val);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
	format(string, sizeof (string), "Admin %s[%i] has set your health to %0.2f%%.", ReturnPlayerName(playerid), playerid, val);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
	format(string, sizeof (string), "You have set %s[%i]'s health to %0.2f%%.", ReturnPlayerName(targetid), targetid, val);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:setarmour(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid, Float:val;
	if (sscanf(params, "uF(100)", targetid, val))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setarmour [player] [*amount]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

    SetPlayerArmour(targetid, val);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
	format(string, sizeof (string), "Admin %s[%i] has set your armour to %0.2f%%.", ReturnPlayerName(playerid), playerid, val);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
	format(string, sizeof (string), "You have set %s[%i]'s armour to %0.2f%%.", ReturnPlayerName(targetid), targetid, val);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:setskin(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid, val;
	if (sscanf(params, "ui", targetid, val))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setskin [player] [skinid]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

	if (val < 0 || val == 74 || val > 311)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid skin id, must be b/w 0 - 311 (exception: 74).");

    SetPlayerSkin(targetid, val);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
	format(string, sizeof (string), "Admin %s[%i] has set your skin to id %i", ReturnPlayerName(playerid), playerid, val);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
	format(string, sizeof (string), "You have set %s[%i]'s skin to id %i.", ReturnPlayerName(targetid), targetid, val);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:setinterior(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid, val;
	if (sscanf(params, "ui", targetid, val))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setinterior [player] [id]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

    SetPlayerInterior(targetid, val);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
	format(string, sizeof (string), "Admin %s[%i] has set your interior to id %i.", ReturnPlayerName(playerid), playerid, val);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
	format(string, sizeof (string), "You have set %s[%i]'s interior to id %i.", ReturnPlayerName(targetid), targetid, val);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:setworld(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid, val;
	if (sscanf(params, "ui", targetid, val))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setworld [player] [id]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

    SetPlayerVirtualWorld(targetid, val);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
	format(string, sizeof (string), "Admin %s[%i] has set your virtual world to id %i.", ReturnPlayerName(playerid), playerid, val);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
	format(string, sizeof (string), "You have set %s[%i]'s virtual world to id %i.", ReturnPlayerName(targetid), targetid, val);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:slap(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /slap [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

    new Float:x, Float:y, Float:z;
	GetPlayerPos(targetid, x, y, z);
	SetPlayerPos(targetid, x, y, (z + 5.0));
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
	format(string, sizeof (string), "You have slapped %s[%i].", ReturnPlayerName(targetid), targetid);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:explode(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /explode [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

    new Float:x, Float:y, Float:z;
	GetPlayerPos(targetid, x, y, z);
	CreateExplosion(x, y, z, 7, 1.00);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
	format(string, sizeof (string), "You have exploded %s[%i].", ReturnPlayerName(targetid), targetid);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:disarm(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /disarm [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

    ResetPlayerWeapons(targetid);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
	format(string, sizeof (string), "Admin %s[%i] has disarmed you.", ReturnPlayerName(playerid), playerid);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
	format(string, sizeof (string), "You have disarmed %s[%i].", ReturnPlayerName(targetid), targetid);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:ban(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new match[24], days, reason[65];
	if (sscanf(params, "s[24]is[65]", match, days, reason))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /ban [username/ip] [days] [reason]");

	if (days < 0 || days > 365)
	    return SendClientMessage(playerid, COLOR_TOMATO, "Error: Number of days must be between 1 - 365 (0 = permanent ban).");

	static name[MAX_PLAYER_NAME], ip[18];
	name[0] = EOS;
	ip[0] = EOS;

	new targetid = INVALID_PLAYER_ID;

	DB::Fetch("Users", _, _, _, "`Name` = '%q' OR `Ip` = '%q'", match, match);
	if (fetch_rows_count() > 0)
	{
	    fetch_string(name, "Name");
	    fetch_string(ip, "Ip");
	    if (p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < fetch_int("AdminLevel"))
	    {
	        fetcher_close();
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");
		}
	}
	else
	{
	    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	    {
	        if (IsPlayerConnected(i))
	        {
	            GetPlayerName(i, name, MAX_PLAYER_NAME);
	            GetPlayerName(i, ip, MAX_PLAYER_NAME);
				if (!strcmp(name, match) || !strcmp(ip, match))
				{
                    targetid = i;
				    break;
				}
	        }
	    }

	    if (!name[0])
	        return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player not found in database nor online.");
	}
	fetcher_close();

	new expiredate = (gettime() + (((days * 24) * 60) * 60));

	static string[300];
	if (days == 0)
	{
 		format(string, sizeof (string), "'%s' has been banned by admin %s[%i].", name, ReturnPlayerName(playerid), playerid);
		SendClientMessageToAll(COLOR_CORAL, string);
	 	format(string, sizeof (string), "Reason: %s", reason);
	 	SendClientMessageToAll(COLOR_CORAL, string);

	 	if (targetid != INVALID_PLAYER_ID)
	 	{
			PlayerPlaySound(targetid, 5454, 0.0, 0.0, 0.0);

			format(string, sizeof (string), ""COL_WHITE"You have been issued a ban from an admin [if you think this was missuse of power, report on our forums].\n"COL_TOMATO"Reason: "COL_WHITE"%s\n"COL_TOMATO"Admin: "COL_WHITE"%s[%i]\n"COL_WHITE"Today's date: "COL_TOMATO"%s\n"COL_WHITE"Expire date: "COL_WHITE"Null (Permanent ban)", reason, ReturnPlayerName(playerid), playerid, ReturnDate(gettime()));
			Dialog_Show(targetid, 0, DIALOG_STYLE_MSGBOX, "Banned from server...", string, "Ok", "");
		}
	}
	else
	{
	 	format(string, sizeof (string), "'%s' has been banned by admin %s[%i] for %i days [expire on: %s].", ReturnPlayerName(targetid), targetid, ReturnPlayerName(playerid), playerid, days, ReturnDate(expiredate));
		SendClientMessageToAll(COLOR_CORAL, string);
	 	format(string, sizeof (string), "Reason: %s", reason);
	 	SendClientMessageToAll(COLOR_CORAL, string);

	 	if (targetid != INVALID_PLAYER_ID)
	 	{
			PlayerPlaySound(targetid, 5454, 0.0, 0.0, 0.0);

			format(string, sizeof (string), ""COL_WHITE"You have been issued a ban from an admin [if you think this was missuse of power, report on our forums].\n"COL_TOMATO"Reason: "COL_WHITE"%s\n"COL_TOMATO"Admin: "COL_WHITE"%s[%i]\n"COL_WHITE"Today's date: "COL_TOMATO"%s\n"COL_WHITE"Expire date: "COL_WHITE"%s", reason, ReturnPlayerName(playerid), playerid, ReturnDate(gettime()), ReturnDate(expiredate));
			Dialog_Show(targetid, 0, DIALOG_STYLE_MSGBOX, "Banned from server...", string, "Ok", "");
		}
	}

	if (targetid != INVALID_PLAYER_ID)
	 	BanEx(INVALID_PLAYER_ID, reason, name, ip, 0, expiredate);
	else
	 	BanEx(targetid, reason, .range = 0, .expiredate = expiredate);

	new banid = GetBanId(match, match);
	SetBanData(banid, "Name", STRING, name);
	SetBanData(banid, "Ip", STRING, ip);
	SetBanData(banid, "Admin", STRING, ReturnPlayerName(playerid));
	SetBanData(banid, "BanDate", STRING, ReturnDate(gettime()));
	if (days == 0)
		SetBanData(banid, "ExpireDate", STRING, "Null (Permanent ban)");
	else
		SetBanData(banid, "ExpireDate", STRING, ReturnDate(expiredate));
	SetBanData(banid, "RangeBan", STRING, "No");

	return 1;
}

CMD:searchban(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new match[24];
	if (sscanf(params, "s[24]", match))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /searchban [username/ip]");

	new banid = GetBanId(match, match);
	if (banid == -1)
	    return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player not found in ban database.");

	new name[MAX_PLAYER_NAME], ip[18], reason[65], admin[MAX_PLAYER_NAME], bandate[35], expiredate[35], rangeban[3];
	GetBanData(banid, "Name", STRING, name);
	GetBanData(banid, "Ip", STRING, ip);
	GetBanData(banid, "Reason", STRING, reason);
	GetBanData(banid, "Admin", STRING, admin);
	GetBanData(banid, "BanDate", STRING, bandate);
	GetBanData(banid, "ExpireDate", STRING, expiredate);
	GetBanData(banid, "RangeBan", STRING, rangeban);

	static string[500];
	format(string, sizeof (string), "Property\tValue\nUSERNAME\t%s\nIP.\n%s\nREASON\t%s\nADMIN\t%s\nBAN DATE\t%s\nEXPIRE DATE\t%s\nRANGE BAN\t%s", name, ip, reason, admin, bandate, expiredate, rangeban);
	Dialog_Show(playerid, 0, DIALOG_STYLE_TABLIST, "/Searchban result", string, "Close", "");

	return 1;
}

CMD:unban(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new match[24];
	if (sscanf(params, "s[24]", match))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /unban [username/ip]");

	new banid = GetBanId(match, match);
	if (banid == -1)
	    return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player not found in ban database.");

	UnBan(banid);

	static string[500];
	format(string, sizeof (string), "'%s' has been unbanned by admin %s[%i].", ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_CORAL, string);

	return 1;
}

CMD:get(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 2 and above have access to this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /get [player]");

	if (targetid == playerid)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You can't use the command on yourself.");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is either spectating or not spawned.");

	SetPlayerInterior(targetid, GetPlayerInterior(playerid));
	SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if (GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
	{
	    new vehicleid = GetPlayerVehicleID(targetid);
		SetVehiclePos(vehicleid, x, (y + 2.5), z);
		LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
		SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
	}
	else
		SetPlayerPos(targetid, x, (y + 2.0), z);

	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has teleported you to his/her position.", ReturnPlayerName(playerid), playerid);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have teleported %s[%i] to your position.", ReturnPlayerName(targetid), targetid);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

// ** LEVEL 3+ COMMANDS **

CMD:force(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /force [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	if (GetPlayerState(targetid) == PLAYER_STATE_SPECTATING)
	{
		TogglePlayerSpectating(targetid, false);
		ForceClassSelection(targetid);
		SetPlayerHealth(targetid, 0.0);
	}
	else if (GetPlayerState(targetid) == PLAYER_STATE_WASTED)
	{
		ForceClassSelection(targetid);
 	}
	else
	{
		ForceClassSelection(targetid);
		SetPlayerHealth(targetid, 0.0);
	}
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has forced you to class selection screen.", ReturnPlayerName(playerid), playerid);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have forced %s[%i] to class selection screen.", ReturnPlayerName(targetid), targetid);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:setstyle(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid, styleid;
	if (sscanf(params, "ui", targetid, styleid))
	{
		SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setstyle [player] [styleid]");
		SendClientMessage(playerid, COLOR_WHITE, "Styles: [0]Normal, [1]Boxing, [2]Kungfu, [3]Kneehead, [4]Grabkick, [5]Elbow");
		return 1;
	}

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (styleid > 5 || styleid < 0)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Fighting style must be between 0 - 5.");

	static stylename[15];
	switch(styleid)
	{
	    case 0:
	    {
	        SetPlayerFightingStyle(targetid, 4);
	        stylename = "Normal";
	    }

	    case 1:
	    {
	        SetPlayerFightingStyle(targetid, 5);
	        stylename = "Boxing";
	    }

	    case 2:
	    {
	        SetPlayerFightingStyle(targetid, 6);
	        stylename = "Kung Fu";
	    }

	    case 3:
	    {
	        SetPlayerFightingStyle(targetid, 7);
	        stylename = "Kneehead";
	    }

	    case 4:
	    {
	        SetPlayerFightingStyle(targetid, 15);
	        stylename = "Grabkick";
	    }

	    case 5:
	    {
	        SetPlayerFightingStyle(targetid, 16);
	        stylename = "Elbow";
	    }
	}
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has set your fighting style to %s.", ReturnPlayerName(playerid), playerid, stylename);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have set %s[%i]'s fighting style to %s.", ReturnPlayerName(targetid), targetid, stylename);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:freeze(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid;
    if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /freeze [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

    TogglePlayerControllable(targetid, false);
	GameTextForPlayer(targetid, "~r~Frozen", 5000, 3);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
	format(string, sizeof (string), "%s[%i] has been frozen by admin %s[%i].", ReturnPlayerName(targetid), targetid, ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}

CMD:unfreeze(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid;
    if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /unfreeze [player]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

    TogglePlayerControllable(targetid, true);
	GameTextForPlayer(targetid, "~r~Unforzed", 5000, 3);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
	format(string, sizeof (string), "%s[%i] has been unfrozen by admin %s[%i].", ReturnPlayerName(targetid), targetid, ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}

CMD:giveweapon(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid, weapon[32], ammo;
	if (sscanf(params, "us[32]I(250)", targetid, weapon, ammo))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /giveweapon [player] [weapon] [*ammo]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	new weaponid;
	static weaponname[35];
	if (IsNumeric(weapon))
	{
		weaponid = strval(weapon);
		GetWeaponName(weaponid, weaponname, sizeof (weaponname));
	}
	else
	{
		for (new i; i <= 46; i++)
		{
			switch(i)
			{
				case 0, 19, 20, 21, 44, 45:
					continue;

				default:
				{
					GetWeaponName(i, weaponname, sizeof (weaponname));
					if (strfind(weapon, weaponname, true) != -1)
					{
					    weaponid = i;
						break;
					}
				}
			}
		}
	}

	if (weaponid < 1 || weaponid > 46)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid weapon id/name.");

	GivePlayerWeapon(targetid, weaponid, ammo);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has given you a %s with %i ammo.", ReturnPlayerName(playerid), playerid, weaponname, ammo);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have given %s[%i] a %s with %i ammo.", ReturnPlayerName(targetid), targetid, weaponname, ammo);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:setcolor(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid, color;
	if (sscanf(params, "ui", targetid, color))
	{
		SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setcolor [player] [color]");
		SendClientMessage(playerid, COLOR_WHITE, "Colors: [0]Black, [1]White, [2]Red, [3]Orange, [4]Yellow, [5]Green, [6]Blue, [7]Purple, [8]Brown, [9]Pink");
		return 1;
	}

	if (color > 9 || color < 0)
	{
		SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid color id.");
		SendClientMessage(playerid, COLOR_WHITE, "Colors: [0]Black, [1]White, [2]Red, [3]Orange, [4]Yellow, [5]Green, [6]Blue, [7]Purple, [8]Brown, [9]Pink");
		return 1;
	}

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	static colorname[15];
	switch(color)
	{
	    case 0: SetPlayerColor(playerid, 0x000000FF), colorname = "Black";
    	case 1: SetPlayerColor(playerid, 0xFFFFFFFF), colorname = "White";
     	case 2: SetPlayerColor(playerid, 0xFF0000FF), colorname = "Red";
      	case 3: SetPlayerColor(playerid, 0xFF9933FF), colorname = "Orange";
      	case 4: SetPlayerColor(playerid, 0xFFFF66FF), colorname = "Yellow";
    	case 5: SetPlayerColor(playerid, 0x00CC00FF), colorname = "Green";
       	case 6: SetPlayerColor(playerid, 0x1E90FFFF), colorname = "Blue";
      	case 7: SetPlayerColor(playerid, 0x6600FFFF), colorname = "Purple";
       	case 8: SetPlayerColor(playerid, 0x663300FF), colorname = "Brown";
       	case 9: SetPlayerColor(playerid, 0xCC99FFFF), colorname = "Pink";
	}
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	if (targetid == playerid)
	    return 1;

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has set your color to %s.", ReturnPlayerName(playerid), playerid, colorname);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have set %s[%i]'s color to %s.", ReturnPlayerName(targetid), targetid, colorname);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:setcash(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid, amount;
	if (sscanf(params, "ui", targetid, amount))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setcash [player] [amount]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	ResetPlayerMoney(targetid);
	GivePlayerMoney(targetid, amount);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has set your money to $%i.", ReturnPlayerName(playerid), playerid, amount);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have set %s[%i]'s money to $%i.", ReturnPlayerName(targetid), targetid, amount);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:givecash(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid, amount;
	if (sscanf(params, "ui", targetid, amount))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /givecash [player] [amount]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	GivePlayerMoney(targetid, amount);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has given you $%i.", ReturnPlayerName(playerid), playerid, amount);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have given %s[%i] $%i.", ReturnPlayerName(targetid), targetid, amount);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:setscore(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid, amount;
	if (sscanf(params, "ui", targetid, amount))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setscore [player] [amount]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	SetPlayerScore(targetid, amount);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has set your score to $%i.", ReturnPlayerName(playerid), playerid, amount);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have set %s[%i]'s score to $%i.", ReturnPlayerName(targetid), targetid, amount);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:givescore(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid, amount;
	if (sscanf(params, "ui", targetid, amount))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /givescore [player] [amount]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	SetPlayerScore(targetid, (GetPlayerScore(targetid) + amount));
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has given you %i score.", ReturnPlayerName(playerid), playerid, amount);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have given %s[%i] %i score.", ReturnPlayerName(targetid), targetid, amount);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:setkills(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid, amount;
	if (sscanf(params, "ui", targetid, amount))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setkills [player] [amount]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	p_Account[targetid][E_ACCOUNT_KILLS] = amount;
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has set your kills to %i.", ReturnPlayerName(playerid), playerid, amount);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have set %s[%i]'s kills to %i.", ReturnPlayerName(targetid), targetid, amount);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:setdeaths(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new targetid, amount;
	if (sscanf(params, "ui", targetid, amount))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setdeaths [player] [amount]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	p_Account[targetid][E_ACCOUNT_DEATHS] = amount;
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has set your deaths to %i.", ReturnPlayerName(playerid), playerid, amount);
 	SendClientMessage(targetid, COLOR_LIGHT_BLUE, string);
 	format(string, sizeof (string), "You have set %s[%i]'s deaths to %i.", ReturnPlayerName(targetid), targetid, amount);
 	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:spawncar(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new vehicleid;
	if (sscanf(params, "i", vehicleid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /spawncar [vehicleid]");

	if (!IsValidVehicle(vehicleid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid vehicle id.");

	SetVehicleToRespawn(vehicleid);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "You have respawned vehicle id %i.", vehicleid);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:destroycar(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new vehicleid;
	if (sscanf(params, "i", vehicleid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /destroycar [vehicleid]");

	if (!IsValidVehicle(vehicleid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid vehicle id.");

	DestroyVehicle(vehicleid);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "You have destroyed vehicle id %i.", vehicleid);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:spawncars(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	new playerpool = GetPlayerPoolSize();
	for (new i, j = GetVehiclePoolSize(); i <= j; i++)
	{
	    if (!IsValidVehicle(i))
	        continue;

	    for (new x; x <= playerpool; x++)
	    {
	        if (GetPlayerVehicleID(x) == i)
	        	break;
        }

		SetVehicleToRespawn(i);
	}

	for (new i; i <= playerpool; i++)
	{
	    if (!IsPlayerConnected(i))
	        continue;

		PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
	}

	static string[150];
	format(string, sizeof (string), "Admin %s[%i] has respawned all unused vehicles.", ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:readpm(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	if (!g_Settings[E_SETTINGS_READ_PM])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The feature has been disabled at the moment.");

	if (!p_Account[playerid][E_ACCOUNT_READ_PM])
		GameTextForPlayer(playerid, "~g~Read PM. on", 5000, 3);
	else
		GameTextForPlayer(playerid, "~r~Read PM. off", 5000, 3);

	p_Account[playerid][E_ACCOUNT_READ_PM] = (!p_Account[playerid][E_ACCOUNT_READ_PM]);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	return 1;
}

CMD:readcmd(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 3 and above have access to this command.");

	if (!g_Settings[E_SETTINGS_READ_CMD])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The feature has been disabled at the moment.");

	if (!p_Account[playerid][E_ACCOUNT_READ_CMD])
		GameTextForPlayer(playerid, "~g~Read CMD. on", 5000, 3);
	else
		GameTextForPlayer(playerid, "~r~Read CMD. off", 5000, 3);

	p_Account[playerid][E_ACCOUNT_READ_CMD] = (!p_Account[playerid][E_ACCOUNT_READ_CMD]);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	return 1;
}

// ** LEVEL 4+ COMMANDS **

CMD:rban(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	new match[24], days, reason[65];
	if (sscanf(params, "s[24]is[65]", match, days, reason))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /rban [username/ip] [days] [reason]");

	if (days < 0 || days > 365)
	    return SendClientMessage(playerid, COLOR_TOMATO, "Error: Number of days must be between 1 - 365 (0 = permanent range ban).");

	static name[MAX_PLAYER_NAME], ip[18];
	name[0] = EOS;
	ip[0] = EOS;

	new targetid = INVALID_PLAYER_ID;

	DB::Fetch("Users", _, _, _, "`Name` = '%q' OR `Ip` = '%q'", match, match);
	if (fetch_rows_count() > 0)
	{
	    fetch_string(name, "Name");
	    fetch_string(ip, "Ip");
	    if (p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < fetch_int("AdminLevel"))
	    {
	        fetcher_close();
			return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");
		}
	}
	else
	{
	    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	    {
	        if (IsPlayerConnected(i))
	        {
	            GetPlayerName(i, name, MAX_PLAYER_NAME);
	            GetPlayerName(i, ip, MAX_PLAYER_NAME);
				if (!strcmp(name, match) || !strcmp(ip, match))
				{
                    targetid = i;
				    break;
				}
	        }
	    }

	    if (!name[0])
	        return SendClientMessage(playerid, COLOR_TOMATO, "Error: Player not found in database nor online.");
	}
	fetcher_close();

	new expiredate = (gettime() + (((days * 24) * 60) * 60));

	static string[300];
	if (days == 0)
	{
 		format(string, sizeof (string), "'%s' has been range banned by admin %s[%i].", name, ReturnPlayerName(playerid), playerid);
		SendClientMessageToAll(COLOR_CORAL, string);
	 	format(string, sizeof (string), "Reason: %s", reason);
	 	SendClientMessageToAll(COLOR_CORAL, string);

	 	if (targetid != INVALID_PLAYER_ID)
	 	{
			PlayerPlaySound(targetid, 5454, 0.0, 0.0, 0.0);

			format(string, sizeof (string), ""COL_WHITE"You have been issued a range ban from an admin [if you think this was missuse of power, report on our forums].\n"COL_TOMATO"Reason: "COL_WHITE"%s\n"COL_TOMATO"Admin: "COL_WHITE"%s[%i]\n"COL_WHITE"Today's date: "COL_TOMATO"%s\n"COL_WHITE"Expire date: "COL_WHITE"Null (Permanent ban)", reason, ReturnPlayerName(playerid), playerid, ReturnDate(gettime()));
			Dialog_Show(targetid, 0, DIALOG_STYLE_MSGBOX, "Banned from server...", string, "Ok", "");
		}
	}
	else
	{
	 	format(string, sizeof (string), "'%s' has been range banned by admin %s[%i] for %i days [expire on: %s].", ReturnPlayerName(targetid), targetid, ReturnPlayerName(playerid), playerid, days, ReturnDate(expiredate));
		SendClientMessageToAll(COLOR_CORAL, string);
	 	format(string, sizeof (string), "Reason: %s", reason);
	 	SendClientMessageToAll(COLOR_CORAL, string);

	 	if (targetid != INVALID_PLAYER_ID)
	 	{
			PlayerPlaySound(targetid, 5454, 0.0, 0.0, 0.0);

			format(string, sizeof (string), ""COL_WHITE"You have been issued a range ban from an admin [if you think this was missuse of power, report on our forums].\n"COL_TOMATO"Reason: "COL_WHITE"%s\n"COL_TOMATO"Admin: "COL_WHITE"%s[%i]\n"COL_WHITE"Today's date: "COL_TOMATO"%s\n"COL_WHITE"Expire date: "COL_WHITE"%s", reason, ReturnPlayerName(playerid), playerid, ReturnDate(gettime()), ReturnDate(expiredate));
			Dialog_Show(targetid, 0, DIALOG_STYLE_MSGBOX, "Banned from server...", string, "Ok", "");
		}
	}

	if (targetid != INVALID_PLAYER_ID)
	 	BanEx(INVALID_PLAYER_ID, reason, name, ip, 0, expiredate);
	else
	 	BanEx(targetid, reason, .range = 0, .expiredate = expiredate);

	new banid = GetBanId(match, match);
	SetBanData(banid, "Name", STRING, name);
	SetBanData(banid, "Ip", STRING, ip);
	SetBanData(banid, "Admin", STRING, ReturnPlayerName(playerid));
	SetBanData(banid, "BanDate", STRING, ReturnDate(gettime()));
	if (days == 0)
		SetBanData(banid, "ExpireDate", STRING, "Null (Permanent ban)");
	else
		SetBanData(banid, "ExpireDate", STRING, ReturnDate(expiredate));
	SetBanData(banid, "RangeBan", STRING, "Yes");

	return 1;
}

CMD:fakedeath(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	new targetid, killerid, weaponid;
	if (sscanf(params, "uui", targetid, killerid, weaponid))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /fakedeath [player] [killer] [weapon]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (!IsPlayerConnected(killerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The killer is not connected.");

	if (weaponid < 0 || weaponid > 51)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid weapon id.");

	SendDeathMessage(killerid, targetid, weaponid);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static weaponname[35];
	GetWeaponName(weaponid, weaponname, sizeof(weaponname));

	static string[150];
	format(string, sizeof (string), "Fake death sent [Player: %s | Killer: %s | Weapon: %s].", ReturnPlayerName(targetid), ReturnPlayerName(killerid), weaponname);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:fakechat(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	new targetid, text[128];
	if (sscanf(params, "us[128]", targetid, text))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /fakechat [player] [text]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	OnPlayerText(targetid, text);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "Fake chat sent [Player: %s | Text: %s].", ReturnPlayerName(targetid), text);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:cleardwindow(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	for (new i; i < 10; i++)
		SendDeathMessage(6000, 5005, 255);

	static string[150];
	format(string, sizeof (string), "%s[%i] has cleared the death window.", ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:muteall(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	new minutes;
	if (sscanf(params, "I(10)", minutes))
		SendClientMessage(playerid, COLOR_GREY, "Tip: You can also specify the minutes by /muteall [minutes]. (default minutes are 10)");

	for (new i; i < MAX_PLAYERS; i++)
	{
		PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);

        if (i == playerid)
            continue;

        if (p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < p_Account[i][E_ACCOUNT_ADMIN_LEVEL])
            continue;

		p_Account[i][E_ACCOUNT_MUTE_TIMELEFT] = (minutes * 60 * 1000);
	}

	static string[150];
	format(string, sizeof (string), "%s[%i] has muted all players for %i minutes.", ReturnPlayerName(playerid), playerid, minutes);
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}

CMD:unmuteall(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	for (new i; i < MAX_PLAYERS; i++)
	{
		PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
		p_Account[i][E_ACCOUNT_MUTE_TIMELEFT] = 0;
	}

	static string[150];
	format(string, sizeof (string), "%s[%i] has unmuted all players.", ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}

CMD:freezeall(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	for (new i; i < MAX_PLAYERS; i++)
	{
		PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);

        if (i == playerid)
            continue;

        if (p_Data[playerid][E_PDATA_ONDUTY])
            continue;

		TogglePlayerControllable(i, false);
	}

	static string[150];
	format(string, sizeof (string), "%s[%i] has frozen all players.", ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}

CMD:unfreezeall(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	for (new i; i < MAX_PLAYERS; i++)
	{
		PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
		TogglePlayerControllable(i, true);
	}

	static string[150];
	format(string, sizeof (string), "%s[%i] has unfreezed all players.", ReturnPlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}

CMD:giveallcash(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	new amount;
	if (sscanf(params, "i", amount))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /giveallcash [amount]");

	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
		GivePlayerMoney(i, amount);
	}

	static string[150];
	format(string, sizeof (string), "%s[%i] has given all players %i money.", ReturnPlayerName(playerid), playerid, amount);
	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:giveallscore(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	new amount;
	if (sscanf(params, "i", amount))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /giveallscore [amount]");

	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    if (!IsPlayerConnected(i))
			continue;

        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
		SetPlayerScore(i, (GetPlayerScore(i) + amount));
	}

	static string[150];
	format(string, sizeof (string), "%s[%i] has given all players %i score.", ReturnPlayerName(playerid), playerid, amount);
	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:settime(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	new id;
	if (sscanf(params, "i", id))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /settime [id]");

	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    if (!IsPlayerConnected(i))
			continue;

        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
		SetPlayerTime(i, id, 0);
	}

	static string[150];
	format(string, sizeof (string), "%s[%i] has set all time to %i.", ReturnPlayerName(playerid), playerid, id);
	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:setweather(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	new id;
	if (sscanf(params, "i", id))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setweather [id]");

	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    if (!IsPlayerConnected(i))
			continue;

        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
		SetPlayerWeather(i, id);
	}

	static string[150];
	format(string, sizeof (string), "%s[%i] has set all weather to %i.", ReturnPlayerName(playerid), playerid, id);
	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:giveallweapon(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	new weapon[32], ammo;
	if (sscanf(params, "s[32]I(250)", weapon, ammo))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /giveallweapon [weapon] [ammo]");

	new weaponid;
	static weaponname[35];
	if (IsNumeric(weapon))
	{
		weaponid = strval(weapon);
		GetWeaponName(weaponid, weaponname, sizeof (weaponname));
	}
	else
	{
		for (new i; i <= 46; i++)
		{
			switch(i)
			{
				case 0, 19, 20, 21, 44, 45:
					continue;

				default:
				{
					GetWeaponName(i, weaponname, sizeof (weaponname));
					if (strfind(weapon, weaponname, true) != -1)
					{
					    weaponid = i;
						break;
					}
				}
			}
		}
	}

	if (weaponid < 1 || weaponid > 46)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid weapon id/name.");

	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    if (!IsPlayerConnected(i))
			continue;

        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
		GivePlayerWeapon(i, weaponid, ammo);
	}

	static string[150];
 	format(string, sizeof (string), "Admin %s[%i] has given a %s with %i ammo to all players.", ReturnPlayerName(playerid), playerid, weaponname, ammo);
 	SendClientMessageToAll(COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:object(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || GetPlayerState(playerid) == PLAYER_STATE_WASTED)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot perform this command when spectating or not spawned.");

	new model;
	if (sscanf(params, "i", model))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /object [model]");

	if (0 > model > 20000)
		return SendClientMessage(playerid, COLOR_TOMATO, "The specified model is invalid.");

	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);
	GetXYInFrontOfPlayer(playerid, x, y, 2.0);
	new object = CreateObject(model, x, y, z, 0, 0, a);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "Object created (model: %i | id: %i).", model, object);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	SendClientMessage(playerid, COLOR_GREY, "Tip: You can edit the object via /editobject and destroy it via /destroyobject.");
	return 1;
}

CMD:destroyobject(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	new object;
	if (sscanf(params, "i", object))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /destroyobject [object]");

	if (!IsValidObject(object))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid object id.");

	DestroyObject(object);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "Object id %i destroyed.", object);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:editobject(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

	new object;
	if (sscanf(params, "i", object))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /editobject [object]");

	if (!IsValidObject(object))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Invalid object id.");

	EditObject(playerid, object);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

	static string[150];
	format(string, sizeof (string), "Editing object id %i...", object);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);
	return 1;
}

CMD:adminspawns(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

    new File:h = fopen(DIRECTORY "adminspawns.ini", io_read);
    static line[100];

	static info[(100 * 100)];
	info[0] = EOS;

	new Float:x, Float:y, Float:z, Float:a, in;
	new count;

    while (fread(h, line))
    {
		if (sscanf(line, "p<,>fffF(0.0)I(0)", x, y, z, a, in))
			continue;

		count++;
		format(info, sizeof (info), "%s#%02i\t%0.2f, %0.2f, %0.2f, %0.2f\tInterior: %02i\t%0.2f meters away...\n", info, count, x, y, z, a, in, GetPlayerDistanceFromPoint(playerid, x, y, z));
   	}
	fclose(h);

	strcat(info, COL_GREEN "ADD NEW SPAWNPOINT\n");
	strcat(info, COL_TOMATO "DELETE EXISTING SPAWNPOINT");

	Dialog_Show(playerid, DIALOG_ADMIN_SPAWNS, DIALOG_STYLE_LIST, "Admin spawns", info, "Select", "Cancel");
	return 1;
}

Dialog:DIALOG_ADMIN_SPAWNS(playerid, response, listitem, inputtext[])
{
	if (response)
	{
	    new File:h = fopen(DIRECTORY "adminspawns.ini", io_read);
	    static line[100];

		new Float:x, Float:y, Float:z, Float:a, in;
		new count;

	    while (fread(h, line))
	    {
			if (sscanf(line, "p<,>fffF(0.0)I(0)", x, y, z, a, in))
				continue;

			if (count == listitem)
			{
			    SetPlayerPos(playerid, x, y, z);
			    SetPlayerFacingAngle(playerid, a);
			    SetPlayerInterior(playerid, in);

			    fclose(h);
			    return 1;
			}
			count++;
	   	}
		fclose(h);

		if (listitem == count)
		{
		    GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, a);
			in = GetPlayerInterior(playerid);

			static string[100];
			format(string, sizeof (string), "%f,%f,%f,%f,%i\r\n", x, y, z, a, in);

			h = fopen(DIRECTORY "adminspawns.ini", io_append);
			fwrite(h, string);
			fclose(h);

			SendClientMessage(playerid, COLOR_LIGHT_BLUE, "New admin spawn has been added.");

			cmd_adminspawns(playerid);
		}
		else
		{
		    h = fopen(DIRECTORY "adminspawns.ini", io_read);

			static info[(100 * 100)];
			info[0] = EOS;
			count = 0;

		    while (fread(h, line))
		    {
				if (sscanf(line, "p<,>fffF(0.0)I(0)", x, y, z, a, in))
					continue;

				count++;
				format(info, sizeof (info), "%s#%02i\t%0.2f, %0.2f, %0.2f, %0.2f\tInterior: %02i\t%0.2f meters away...\n", info, count, x, y, z, a, in, GetPlayerDistanceFromPoint(playerid, x, y, z));
		   	}
			fclose(h);

			Dialog_Show(playerid, DIALOG_REMOVE_SPAWN, DIALOG_STYLE_LIST, "Select an admin spawn to remove", info, "Remove", "Back");
		}
	}
	return 1;
}

Dialog:DIALOG_REMOVE_SPAWN(playerid, response, listitem, inputtext[])
{
	if (response)
	{
	    new File:h = fopen(DIRECTORY "adminspawns.ini", io_read);
	    static line[100];
	    static data[(100 * 100)];
	    data[0] = EOS;

		new Float:x, Float:y, Float:z, Float:a, in;
		new count;

	    while (count < 100 && fread(h, line))
	    {
			if (sscanf(line, "p<,>fffF(0.0)I(0)", x, y, z, a, in))
				continue;

			if ((count++) == listitem)
				continue;

		    strcat(data, line);
	   	}
		fclose(h);

	    h = fopen(DIRECTORY "adminspawns.ini", io_write);
	   	fwrite(h, data);
		fclose(h);

		SendClientMessage(playerid, COLOR_LIGHT_BLUE, "That admin spawn place was successfully removed.");
	}

	cmd_adminspawns(playerid);
	return 1;
}

CMD:questions(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 4 and above have access to this command.");

    new File:h = fopen(DIRECTORY "questions.ini", io_read);
    static line[100];

	static info[(100 * 100)];
	info[0] = EOS;

	new count;

    while (fread(h, line))
    {
		count++;
		format(info, sizeof (info), "%s#%02i\t%s\n", info, count, line);
   	}
	fclose(h);

	strcat(info, COL_GREEN "ADD NEW QUESTION\n");
	strcat(info, COL_TOMATO "DELETE EXISTING QUESTION");

	Dialog_Show(playerid, DIALOG_SEC_QUESTIONS, DIALOG_STYLE_LIST, "Security questions list", info, "Select", "Cancel");
	return 1;
}

Dialog:DIALOG_SEC_QUESTIONS(playerid, response, listitem, inputtext[])
{
	if (response)
	{
	    new File:h = fopen(DIRECTORY "questions.ini", io_read);
	    static line[100];

		new count;

	    while (fread(h, line))
	    {
			if (count == listitem)
			{
			    fclose(h);
			    return 1;
			}

			count++;
	   	}
		fclose(h);

		if (listitem == count)
		{
		    Dialog_Show(playerid, DIALOG_ADD_SEC_QUES, DIALOG_STYLE_INPUT, "Add new security question", ""COL_WHITE"Insert a question you want to add in security questions list.\n(security questions are used when a user forgets his/her password)", "Add", "Back");
		}
		else
		{
		    h = fopen(DIRECTORY "questions.ini", io_read);

			static info[(100 * 100)];
			info[0] = EOS;
			count = 0;

		    while (fread(h, line))
		    {
				count++;
				format(info, sizeof (info), "%s#%02i\t%s\n", info, count, line);
		   	}
			fclose(h);

			Dialog_Show(playerid, DIALOG_REMOVE_SEC_QUES, DIALOG_STYLE_LIST, "Select a security question to remove", info, "Remove", "Back");
		}
	}
	return 1;
}

Dialog:DIALOG_ADD_SEC_QUES(playerid, response, listitem, inputtext[])
{
	if (response)
	{
	    new question[128 + 4];
		if (sscanf(inputtext, "s[128]", question))
		{
		    SendClientMessage(playerid, COLOR_TOMATO, "Error: Security question cannot be empty.");
		    return Dialog_Show(playerid, DIALOG_ADD_SEC_QUES, DIALOG_STYLE_INPUT, "Add new security question", ""COL_WHITE"Insert a question you want to add in security questions list.\n(security questions are used when a user forgets his/her password)", "Add", "Back");
		}

		strcat(question, "\r\n");

	    new File:h = fopen(DIRECTORY "questions.ini", io_append);
		fwrite(h, question);
		fclose(h);

		SendClientMessage(playerid, COLOR_LIGHT_BLUE, "A new security question was successfully added.");
	}

	cmd_questions(playerid);
	return 1;
}

Dialog:DIALOG_REMOVE_SEC_QUES(playerid, response, listitem, inputtext[])
{
	if (response)
	{
	    new File:h = fopen(DIRECTORY "questions.ini", io_read);
	    static line[100];
	    static data[(100 * 100)];
	    data[0] = EOS;

		new count;

	    while (count < sizeof (line) && fread(h, line))
	    {
			if ((count++) == listitem)
				continue;

		    strcat(data, line);
	   	}
		fclose(h);

	    h = fopen(DIRECTORY "questions.ini", io_write);
	   	fwrite(h, data);
		fclose(h);

		DB::Fetch("Users", _, _, _, "`SecurityQuestion` = %i", listitem);
		do
		{
		    DB::Update("Users", fetch_row_id(), 1,
		        "SecurityQuestion", INTEGER, -1,
				"SecurityAnswer", STRING, "");
		}
		while (fetch_next_row());
		fetcher_close();

		SendClientMessage(playerid, COLOR_LIGHT_BLUE, "Security question was successfully removed.");
	}

	cmd_questions(playerid);
	return 1;
}

// ** LEVEL 5+ COMMANDS **

CMD:restart(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 5)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 5 and above have access to this command.");

	new time;
	if (sscanf(params, "I(0)", time))
		SendClientMessage(playerid, COLOR_GREY, "Tip: You can also set a specific time interval for resart to happen by /restart [*seconds]");

	if (time < 0)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Restart time cannot be negative.");

	static string[150];
	if (time > 0)
	{
	    SendClientMessageToAll(COLOR_TOMATO, "_______________________________________________");
	    SendClientMessageToAll(COLOR_TOMATO, " ");
		format(string, sizeof (string), "Admin %s[%i] has set the gamemode to reboot. The restart will occur in %i seconds.", ReturnPlayerName(playerid), playerid, time);
		SendClientMessageToAll(COLOR_TOMATO, string);
	    SendClientMessageToAll(COLOR_TOMATO, " ");
	    SendClientMessageToAll(COLOR_TOMATO, "_______________________________________________");

	    SetTimer("OnServerRequestRestart", (time * 1000), false);
	}
	else
	{
	    SendClientMessageToAll(COLOR_TOMATO, "_______________________________________________");
	    SendClientMessageToAll(COLOR_TOMATO, " ");
		format(string, sizeof (string), "Admin %s[%i] has restarted the gamemode, please wait while the server startsup again.", ReturnPlayerName(playerid), playerid);
		SendClientMessageToAll(COLOR_TOMATO, string);
	    SendClientMessageToAll(COLOR_TOMATO, " ");
	    SendClientMessageToAll(COLOR_TOMATO, "_______________________________________________");

	    SendRconCommand("gmx");
	}
	return 1;
}

forward OnServerRequestRestart();
public 	OnServerRequestRestart()
{
	SendRconCommand("gmx");
}

CMD:setlevel(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 5)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 5 and above have access to this command.");

	new targetid, level;
	if (sscanf(params, "ui", targetid, level))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setlevel [player] [level]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	static string[150];
	if (level < 0 || level > g_Settings[E_SETTINGS_MAX_ADMIN_LEVEL])
	{
	    if (g_Settings[E_SETTINGS_MAX_ADMIN_LEVEL] <= 2)
	    {
		    format(string, sizeof (string), "Error: Admin level must be between 0(remove admin), 1 and %i(owner level).", g_Settings[E_SETTINGS_MAX_ADMIN_LEVEL]);
			return SendClientMessage(playerid, COLOR_TOMATO, string);
	    }

	    format(string, sizeof (string), "Error: Admin level must be between 0(remove admin), 1 - %i and %i(owner level).", (g_Settings[E_SETTINGS_MAX_ADMIN_LEVEL] - 1), g_Settings[E_SETTINGS_MAX_ADMIN_LEVEL]);
		return SendClientMessage(playerid, COLOR_TOMATO, string);
	}

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] == level)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is already has that admin level.");

    if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] < level)
    {
        GameTextForPlayer(targetid, "~g~Promoted", 5000, 1);

		SendClientMessageToAll(COLOR_ORANGE, "_______________________________________________");
	    SendClientMessageToAll(COLOR_ORANGE, " ");
		format(string, sizeof (string), "Admin %s[%i] has set %s[%i]'s admin level to %i. Congratulations %s for his/her admin level promotion [previous level: %i].", ReturnPlayerName(playerid), playerid, ReturnPlayerName(targetid), targetid, level, ReturnPlayerName(targetid), p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL]);
		SendClientMessageToAll(COLOR_ORANGE, string);
	    SendClientMessageToAll(COLOR_ORANGE, " ");
	    SendClientMessageToAll(COLOR_ORANGE, "_______________________________________________");
    }
    else if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > level)
    {
        GameTextForPlayer(targetid, "~r~Demoted", 5000, 1);

		SendClientMessageToAll(COLOR_ORANGE, "_______________________________________________");
	    SendClientMessageToAll(COLOR_ORANGE, " ");
		format(string, sizeof (string), "Admin %s[%i] has set %s[%i]'s admin level to %i. %s has been demoted from level %i to %i.", ReturnPlayerName(playerid), playerid, ReturnPlayerName(targetid), targetid, level, ReturnPlayerName(targetid), p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL], level);
		SendClientMessageToAll(COLOR_ORANGE, string);
	    SendClientMessageToAll(COLOR_ORANGE, " ");
	    SendClientMessageToAll(COLOR_ORANGE, "_______________________________________________");
    }

	p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] = level;
    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if (IsPlayerConnected(i))
        	PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
	}

	return 1;
}

CMD:setvip(playerid, params[])
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 5)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 5 and above have access to this command.");

	new targetid, level;
	if (sscanf(params, "ui", targetid, level))
		return SendClientMessage(playerid, COLOR_THISTLE, "Usage: /setvip [player] [level]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is not connected.");

	if (p_Account[targetid][E_ACCOUNT_ADMIN_LEVEL] > p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL])
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: You cannot use this command on higher admin level player.");

	static string[150];
	if (level < 0 || level > g_Settings[E_SETTINGS_MAX_VIP_LEVEL])
	{
	    if (g_Settings[E_SETTINGS_MAX_VIP_LEVEL] <= 2)
	    {
		    format(string, sizeof (string), "Error: Vip level must be between 0(remove vip), 1 or %i.", g_Settings[E_SETTINGS_MAX_VIP_LEVEL]);
			return SendClientMessage(playerid, COLOR_TOMATO, string);
	    }

	    format(string, sizeof (string), "Error: Vip level must be between 0(remove vip) or 1 - %i.", g_Settings[E_SETTINGS_MAX_VIP_LEVEL]);
		return SendClientMessage(playerid, COLOR_TOMATO, string);
	}

	if (p_Account[targetid][E_ACCOUNT_VIP_LEVEL] == level)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: The player is already has that vip level.");

    if (p_Account[targetid][E_ACCOUNT_VIP_LEVEL] < level)
    {
        GameTextForPlayer(targetid, "~g~Premium", 5000, 1);

		SendClientMessageToAll(COLOR_ORANGE, "_______________________________________________");
	    SendClientMessageToAll(COLOR_ORANGE, " ");
		format(string, sizeof (string), "Admin %s[%i] has set %s[%i]'s vip level to %i. Congratulations %s for his/her vip level promotion [previous level: %i].", ReturnPlayerName(playerid), playerid, ReturnPlayerName(targetid), targetid, level, ReturnPlayerName(targetid), p_Account[targetid][E_ACCOUNT_VIP_LEVEL]);
		SendClientMessageToAll(COLOR_ORANGE, string);
	    SendClientMessageToAll(COLOR_ORANGE, " ");
	    SendClientMessageToAll(COLOR_ORANGE, "_______________________________________________");
    }
    else if (p_Account[targetid][E_ACCOUNT_VIP_LEVEL] > level)
    {
        GameTextForPlayer(targetid, "~r~Premium Demotion!", 5000, 1);

		SendClientMessageToAll(COLOR_ORANGE, "_______________________________________________");
	    SendClientMessageToAll(COLOR_ORANGE, " ");
		format(string, sizeof (string), "Admin %s[%i] has set %s[%i]'s vip level to %i. %s has been demoted from level %i to %i.", ReturnPlayerName(playerid), playerid, ReturnPlayerName(targetid), targetid, level, ReturnPlayerName(targetid), p_Account[targetid][E_ACCOUNT_VIP_LEVEL], level);
		SendClientMessageToAll(COLOR_ORANGE, string);
	    SendClientMessageToAll(COLOR_ORANGE, " ");
	    SendClientMessageToAll(COLOR_ORANGE, "_______________________________________________");
    }
    
    DestroyDynamic3DTextLabel(p_Data[playerid][E_PDATA_VIP_LABEL]);
    if (level > 0)
    {
		p_Data[playerid][E_PDATA_VIP_LABEL] = CreateDynamic3DTextLabel("VIP. Player", COLOR_YELLOW, 0.0, 0.0, 3.5, 100.0, playerid);
    }

	p_Account[targetid][E_ACCOUNT_VIP_LEVEL] = level;
    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if (IsPlayerConnected(i))
        	PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
	}

	return 1;
}

CMD:settings(playerid)
{
	if (!IsPlayerAdmin(playerid) && p_Account[playerid][E_ACCOUNT_ADMIN_LEVEL] < 5)
		return SendClientMessage(playerid, COLOR_TOMATO, "Error: Only admin level 5 and above have access to this command.");

	static info[sizeof (g_Settings) * 150];
	info = "Setting\tStatus\tInfo. (Brief)\n";

	format(info, sizeof (info),
		"%s\
		Max. Warnings\t"COL_THISTLE"%i\t"COL_GREY"Players warned more than the defined number will be auto kicked.\n\
		Max. Login Attempts\t"COL_THISTLE"%i\t"COL_GREY"The login attempts limit after which a player will be auto kicked.\n\
		Max. Answer Attempts\t"COL_THISTLE"%i\t"COL_GREY"The security answer attempts limit after which a player will be auto kicked.\n",
		    info,
			g_Settings[E_SETTINGS_MAX_WARNINGS],
			g_Settings[E_SETTINGS_MAX_LOGIN_ATTEMPTS],
			g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS]);

	if (g_Settings[E_SETTINGS_ANTI_SPAM])
		strcat(info, "Toggle Anti Spam\t"COL_GREEN"Activated\t"COL_GREY"Player won't be able to send messages to a large number of recipients quickly than a human!\n");
	else
		strcat(info, "Toggle Anti Spam\t"COL_TOMATO"Deactivated\t"COL_GREY"Player won't be able to send messages to a large number of recipients quickly than a human!\n");

	if (g_Settings[E_SETTINGS_ANTI_ADVERT])
		strcat(info, "Toggle Anti Advertisement\t"COL_GREEN"Activated\t"COL_GREY"Player won't be able to type any IP. address in chat.\n");
	else
		strcat(info, "Toggle Anti Advertisement\t"COL_TOMATO"Deactivated\t"COL_GREY"Player won't be able to type any IP. address in chat.\n");

	if (g_Settings[E_SETTINGS_ANTI_CAPS])
		strcat(info, "Toggle Anti Capslock\t"COL_GREEN"Activated\t"COL_GREY"Player won't be able to write chat in capital letters.\n");
	else
		strcat(info, "Toggle Anti Capslock\t"COL_TOMATO"Deactivated\t"COL_GREY"Player won't be able to write chat in capital letters.\n");

	format(info, sizeof (info),
		"%sMax. Ping\t"COL_THISTLE"%i\t"COL_GREY"Players having a higher ping than the defined limit will be auto kicked.\n",
		    info, g_Settings[E_SETTINGS_MAX_PING]);

	if (g_Settings[E_SETTINGS_BLACKLIST])
		strcat(info, "Toggle Blacklist\t"COL_GREEN"Activated\t"COL_GREY"Disabling the blacklist will allow all the banned players to join the server temporarily.\n");
	else
		strcat(info, "Toggle Blacklist\t"COL_TOMATO"Deactivated\t"COL_GREY"Disabling the blacklist will allow all the banned players to join the server temporarily.\n");

	if (g_Settings[E_SETTINGS_READ_CMD])
		strcat(info, "Toggle Read Commands\t"COL_GREEN"Activated\t"COL_GREY"Allows admin to see what commands are players using.\n");
	else
		strcat(info, "Toggle Read Commands\t"COL_TOMATO"Deactivated\t"COL_GREY"Allows admin to see what commands are players using.\n");

	if (g_Settings[E_SETTINGS_READ_PM])
		strcat(info, "Toggle Read Private Messages\t"COL_GREEN"Activated\t"COL_GREY"Allows admin to see private conversations between players.\n");
	else
		strcat(info, "Toggle Read Private Messages\t"COL_TOMATO"Deactivated\t"COL_GREY"Allows admin to see private conversations between players.\n");

	if (g_Settings[E_SETTINGS_AKA])
		strcat(info, "Toggle AKA. System\t"COL_GREEN"Activated\t"COL_GREY"AKA.(also known as) system allows admins to check player's multi accounts.\n");
	else
		strcat(info, "Toggle AKA. System\t"COL_TOMATO"Deactivated\t"COL_GREY"AKA.(also known as) system allows admins to check player's multi accounts.\n");

	format(info, sizeof (info),
		"%sMax. Accounts\t"COL_THISTLE"%i\t"COL_GREY"The maximum number of accounts a single IP. can register.\n",
		    info, g_Settings[E_SETTINGS_MAX_ACCOUNTS]);

	if (g_Settings[E_SETTINGS_ADMIN_CMD])
		strcat(info, "Toggle '/admins' Command\t"COL_GREEN"Activated\t"COL_GREY"Enabling will let players see online staff list in /admins.\n");
	else
		strcat(info, "Toggle '/admins' Command\t"COL_TOMATO"Deactivated\t"COL_GREY"Enabling will let players see online staff list in /admins.\n");

	if (g_Settings[E_SETTINGS_GUEST_LOGIN])
		strcat(info, "Toggle Guest Login\t"COL_GREEN"Activated\t"COL_GREY"Allow users to join as a guest (no login/register).\n");
	else
		strcat(info, "Toggle Guest Login\t"COL_TOMATO"Deactivated\t"COL_GREY"Allow users to join as a guest (no login/register).\n");

	format(info, sizeof (info),
		"%s\
		Max. Admin Level\t"COL_THISTLE"%i\t"COL_GREY"Maximum admin level a player can have.\n\
		Max. Vip Level\t"COL_THISTLE"%i\t"COL_GREY"Maximum vip level a player can have.",
		    info,
			g_Settings[E_SETTINGS_MAX_ADMIN_LEVEL],
			g_Settings[E_SETTINGS_MAX_VIP_LEVEL]);

	Dialog_Show(playerid, DIALOG_SETTINGS, DIALOG_STYLE_TABLIST_HEADERS, "GAdmin settings", info, "Edit", "Cancel");

	return 1;
}

Dialog:DIALOG_SETTINGS(playerid, response, listitem, inputext[])
{
	if (response)
	{
 		SetPVarInt(playerid, "DialogListitem", listitem);

	    switch (listitem)
	    {
			case 0:
				Dialog_Show(playerid, DIALOG_MODIFY_LIMIT, DIALOG_STYLE_INPUT, "Modify settings", ""COL_WHITE"Insert the limit you want to set for "COL_TOMATO"Max. Warnings", "Set", "Back");

			case 1:
				Dialog_Show(playerid, DIALOG_MODIFY_LIMIT, DIALOG_STYLE_INPUT, "Modify settings", ""COL_WHITE"Insert the limit you want to set for "COL_TOMATO"Max. Login Attempts", "Set", "Back");

			case 2:
				Dialog_Show(playerid, DIALOG_MODIFY_LIMIT, DIALOG_STYLE_INPUT, "Modify settings", ""COL_WHITE"Insert the limit you want to set for "COL_TOMATO"Max. Answer Attempts", "Set", "Back");

			case 3:
				Dialog_Show(playerid, DIALOG_MODIFY_TOGGLE, DIALOG_STYLE_MSGBOX, "Modify settings", ""COL_WHITE"Set the toggle for feature "COL_TOMATO"Anti Spam", "Enable", "Disable");

			case 4:
				Dialog_Show(playerid, DIALOG_MODIFY_TOGGLE, DIALOG_STYLE_MSGBOX, "Modify settings", ""COL_WHITE"Set the toggle for feature "COL_TOMATO"Anti Advertisement", "Enable", "Disable");

	    	case 5:
				Dialog_Show(playerid, DIALOG_MODIFY_TOGGLE, DIALOG_STYLE_MSGBOX, "Modify settings", ""COL_WHITE"Set the toggle for feature "COL_TOMATO"Anti Capslock", "Enable", "Disable");

			case 6:
				Dialog_Show(playerid, DIALOG_MODIFY_LIMIT, DIALOG_STYLE_INPUT, "Modify settings", ""COL_WHITE"Insert the limit you want to set for "COL_TOMATO"Max. Ping", "Set", "Back");

	    	case 7:
				Dialog_Show(playerid, DIALOG_MODIFY_TOGGLE, DIALOG_STYLE_MSGBOX, "Modify settings", ""COL_WHITE"Set the toggle for feature "COL_TOMATO"Blacklist", "Enable", "Disable");

	    	case 8:
				Dialog_Show(playerid, DIALOG_MODIFY_TOGGLE, DIALOG_STYLE_MSGBOX, "Modify settings", ""COL_WHITE"Set the toggle for feature "COL_TOMATO"Read Commands", "Enable", "Disable");

	    	case 9:
				Dialog_Show(playerid, DIALOG_MODIFY_TOGGLE, DIALOG_STYLE_MSGBOX, "Modify settings", ""COL_WHITE"Set the toggle for feature "COL_TOMATO"Read Private Messages", "Enable", "Disable");

	    	case 10:
				Dialog_Show(playerid, DIALOG_MODIFY_TOGGLE, DIALOG_STYLE_MSGBOX, "Modify settings", ""COL_WHITE"Set the toggle for feature "COL_TOMATO"AKA. System", "Enable", "Disable");

			case 11:
				Dialog_Show(playerid, DIALOG_MODIFY_LIMIT, DIALOG_STYLE_INPUT, "Modify settings", ""COL_WHITE"Insert the limit you want to set for "COL_TOMATO"Max. Accounts", "Set", "Back");

	    	case 12:
				Dialog_Show(playerid, DIALOG_MODIFY_TOGGLE, DIALOG_STYLE_MSGBOX, "Modify settings", ""COL_WHITE"Set the toggle for feature "COL_TOMATO"'/admin' Command", "Enable", "Disable");

	    	case 13:
				Dialog_Show(playerid, DIALOG_MODIFY_TOGGLE, DIALOG_STYLE_MSGBOX, "Modify settings", ""COL_WHITE"Set the toggle for feature "COL_TOMATO"Guest Login", "Enable", "Disable");

			case 14:
				Dialog_Show(playerid, DIALOG_MODIFY_LIMIT, DIALOG_STYLE_INPUT, "Modify settings", ""COL_WHITE"Insert the limit you want to set for "COL_TOMATO"Max. Admin Level", "Set", "Back");

			case 15:
				Dialog_Show(playerid, DIALOG_MODIFY_LIMIT, DIALOG_STYLE_INPUT, "Modify settings", ""COL_WHITE"Insert the limit you want to set for "COL_TOMATO"Max. Vip Level", "Set", "Back");
		}
	}
	return 1;
}

Dialog:DIALOG_MODIFY_LIMIT(playerid, response, listitem, inputtext[])
{
	if (response)
	{
		new limit;
		if (sscanf(inputtext, "i", limit))
		{
		    SendClientMessage(playerid, COLOR_TOMATO, "Error: Limit must be positive or 0.");
		    return dialog_DIALOG_SETTINGS(playerid, 1, GetPVarInt(playerid, "DialogListitem"), "");
		}

		static string[150];
		switch (GetPVarInt(playerid, "DialogListitem"))
		{
		    case 0:
		    {
		        format(string, sizeof (string), "[SETTINGS] Max. Warnings changed to %i [previous: %i].", limit, g_Settings[E_SETTINGS_MAX_WARNINGS]);
		        SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

		        g_Settings[E_SETTINGS_MAX_WARNINGS] = limit;
		    }

		    case 1:
		    {
		        format(string, sizeof (string), "[SETTINGS] Max. Login Attempts changed to %i [previous: %i].", limit, g_Settings[E_SETTINGS_MAX_LOGIN_ATTEMPTS]);
		        SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

		        g_Settings[E_SETTINGS_MAX_LOGIN_ATTEMPTS] = limit;
		    }

		    case 2:
		    {
		        format(string, sizeof (string), "[SETTINGS] Max. Answer Attempts changed to %i [previous: %i].", limit, g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS]);
		        SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

		        g_Settings[E_SETTINGS_MAX_ANSWER_ATTEMPTS] = limit;
		    }

		    case 6:
		    {
		        format(string, sizeof (string), "[SETTINGS] Max. Ping changed to %i [previous: %i].", limit, g_Settings[E_SETTINGS_MAX_PING]);
		        SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

		        g_Settings[E_SETTINGS_MAX_PING] = limit;
		    }

		    case 11:
		    {
		        format(string, sizeof (string), "[SETTINGS] Max. Accounts changed to %i [previous: %i].", limit, g_Settings[E_SETTINGS_MAX_ACCOUNTS]);
		        SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

		        g_Settings[E_SETTINGS_MAX_ACCOUNTS] = limit;
		    }

		    case 14:
		    {
		        format(string, sizeof (string), "[SETTINGS] Max. Admin Level changed to %i [previous: %i].", limit, g_Settings[E_SETTINGS_MAX_ADMIN_LEVEL]);
		        SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

		        g_Settings[E_SETTINGS_MAX_ADMIN_LEVEL] = limit;
		    }

		    case 15:
		    {
		        format(string, sizeof (string), "[SETTINGS] Max. Vip Level changed to %i [previous: %i].", limit, g_Settings[E_SETTINGS_MAX_VIP_LEVEL]);
		        SendClientMessage(playerid, COLOR_LIGHT_BLUE, string);

		        g_Settings[E_SETTINGS_MAX_VIP_LEVEL] = limit;
		    }
		}
	}

	DeletePVar(playerid, "DialogListitem");
	return cmd_settings(playerid);
}

Dialog:DIALOG_MODIFY_TOGGLE(playerid, response, listitem, inputtext[])
{
	switch (GetPVarInt(playerid, "DialogListitem"))
	{
	    case 3:
	    {
	        if (response)
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Anti Spam has been Activated.");
			else
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Anti Spam has been Deactivated.");

	        g_Settings[E_SETTINGS_ANTI_SPAM] = bool:response;
	    }

	    case 4:
	    {
	        if (response)
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Anti Advertisement has been Activated.");
			else
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Anti Advertisement has been Deactivated.");

	        g_Settings[E_SETTINGS_ANTI_ADVERT] = bool:response;
	    }

	    case 5:
	    {
	        if (response)
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Anti Capslock has been Activated.");
			else
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Anti Capslock has been Deactivated.");

	        g_Settings[E_SETTINGS_ANTI_CAPS] = bool:response;
	    }

	    case 7:
	    {
	        if (response)
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Blacklist has been Activated.");
			else
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Blacklist has been Deactivated.");

	        g_Settings[E_SETTINGS_BLACKLIST] = bool:response;

	        if (response)
	        {
	            for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	            {
	                if (IsPlayerConnected(i))
	                {
	                    if (GetBanId(ReturnPlayerName(i), ReturnPlayerIp(i)) != -1)
	                    {
	                        Kick(i);
	                    }
	                }
	            }
	        }
	    }

	    case 8:
	    {
	        if (response)
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Read Commands has been Activated.");
			else
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Read Commands has been Deactivated.");

	        g_Settings[E_SETTINGS_READ_CMD] = bool:response;
	    }

	    case 9:
	    {
	        if (response)
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Read Private Messages has been Activated.");
			else
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Read Private Messages has been Deactivated.");

	        g_Settings[E_SETTINGS_READ_PM] = bool:response;
	    }

	    case 10:
	    {
	        if (response)
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] AKA. System has been Activated.");
			else
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] AKA. System has been Deactivated.");

	        g_Settings[E_SETTINGS_AKA] = bool:response;
	    }

	    case 12:
	    {
	        if (response)
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] '/admin' Commands has been Activated.");
			else
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] '/admin' Commands has been Deactivated.");

	        g_Settings[E_SETTINGS_ADMIN_CMD] = bool:response;
	    }

	    case 13:
	    {
	        if (response)
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Guest Login has been Activated.");
			else
	        	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[SETTINGS] Guest Login has been Deactivated.");

	        g_Settings[E_SETTINGS_GUEST_LOGIN] = bool:response;
	    }
	}

	DeletePVar(playerid, "DialogListitem");
	return cmd_settings(playerid);
}
