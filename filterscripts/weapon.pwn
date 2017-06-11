#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include "../include/gl_common.inc"

#define         DIALOG_WEAPON_MENU      1
#define         DIALOG_PISTOL_MENU      2
#define         DIALOG_SMG_MENU         4
#define         DIALOG_SHOTGUN_MENU     5
#define         DIALOG_RIFLES_MENU      6
#define         DIALOG_ASSAULT_MENU     7
#define         DIALOG_THROWN_MENU      8
#define         DIALOG_VEHICLE_MENU     9
#define         DIALOG_CAR_MENU         10

#define         COLOR_WHITE             0xFFFFFFFF
#define         COLOR_RED               0xFF0000FF
#define 		GELTONA 				0xFFFF00FF
#define 		BALTA 					0xFFFFFFFF
#define 		COLOR_GREY 				0xAFAFAFAA
#pragma tabsize 0

enum WeaponEnum
{
        weaponid,                       // Weapon ID
        weaponname[64],         // Weapon Name
        weaponprice[60],    // Weapon Price
        weaponammo          // Weapon Ammo
}

new Pistols[3][WeaponEnum] =
{
        {22, "Colt .45", 200, 99999},
        {23, "Silenced Colt .45", 600, 99999},
        {24, "Desert Eagle", 1200, 99999}
};

new MicroSMGs[3][WeaponEnum] =
{
        {28, "Micro UZI", 300, 99999},
        {42, "Tec-9", 300, 99999},
        {29, "MP5", 2000, 99999}
};

new Shotguns[3][WeaponEnum] =
{
        {25, "Shotgun", 600, 99999},
        {26, "Sawnoff Shotgun", 800, 99999},
        {27, "Combat Shotgun", 1000, 99999}
};

new Rifles[2][WeaponEnum] =
{
        {33, "County Rifle", 1000, 99999},
        {34, "Sniper Rifle", 5000, 99999}
};

new AssaultRifles[2][WeaponEnum] =
{
        {30, "AK47 Assault Rifle", 3500, 99999},
        {31, "M4 Assault Rifle", 4500, 99999}
};

new Thrown[2][WeaponEnum] =
{
        {30, "Grenades", 300, 99999},
        {31, "Remote Explosives", 2000, 99999}
};

CMD:buyweapons(playerid, params[])
{
    ShowPlayerDialog(playerid, DIALOG_WEAPON_MENU, DIALOG_STYLE_LIST, "Weapon Shop", "Kevlar Vest - $100\nPistols\nMicro SMGs\nShotguns\nRifles\nAssault Rifles\nThrown", "Select", "Cancel");
    return 1;
}

CMD:getmoney(playerid, params[])
{
    GivePlayerMoney(playerid, 30000);
    return 1;
}

//CMD:buycars(playerid, params[])
//{
//	ShowPlayerDialog(playerid, DIALOG_VEHICLE_MENU, DIALOG_STYLE_LIST, "Vehicle shop", "Cars\nBikes\nAircraft\nBoats\nRC Vehicles", "Select", "Cancel");
//	return 1;
//}

CMD:help(playerid, params[])
{
    SendClientMessage(playerid,BALTA,"This is the KZ-Crew fanserver help documentation.");
    SendClientMessage(playerid,BALTA,"In this documentation I will teach you some commands");
    SendClientMessage(playerid,BALTA,"For a vehicle do /v <name of vehicle>");
    SendClientMessage(playerid,BALTA,"That would look like /v infernus for an infernus");
    SendClientMessage(playerid,BALTA,"For 30K money do /getmoney");
    SendClientMessage(playerid,BALTA,"For a gun purchase dialog do /buyweapons");
    SendClientMessage(playerid,BALTA,"For teleporting to other places, use /tpsl = los santos");
    SendClientMessage(playerid,BALTA,"/tpsf for san fierro and /tplv for las venturas");
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_VEHICLE_MENU)
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	            case 0:
	                {
	                    new string[2048];
                    for(new x;x<sizeof(Pistols);x++)
                    {
                        format(string, sizeof(string), "%s%s - $%d\n", string, Pistols[x][weaponname], Pistols[x][weaponprice]);
                    }
                                    ShowPlayerDialog(playerid, DIALOG_CAR_MENU, DIALOG_STYLE_LIST, "Vehicle Shop - Cars", string, "Buy", "Back");
	                }
				}
			}
		}


    if(dialogid == DIALOG_WEAPON_MENU)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                                {
                                    if(GetPlayerMoney(playerid) >= 100)
                                    {
                                        GivePlayerMoney(playerid, -100);
                                        SetPlayerArmour(playerid, 100);
                                        SendClientMessage(playerid, COLOR_WHITE, "You have successfully purchased a Kevlar Vest for $100.");
                                        return 1;
                                        }
                                        else
                                        {
                                            SendClientMessage(playerid, COLOR_RED, "You do not have enough money to purchase this item.");
                                            return 0;
                                        }
                                }
                                case 1:
                                {
                                    new string[2048];
                    for(new x = 0;x<sizeof(Pistols);x++)
                    {
                        format(string, sizeof(string), "%s%s - $%d\n", string, Pistols[x][weaponname], Pistols[x][weaponprice]);
                    }
                                    ShowPlayerDialog(playerid, DIALOG_PISTOL_MENU, DIALOG_STYLE_LIST, "Weapon Shop - Pistols", string, "Buy", "Back");
                                }
                                case 2:
                                {
                                    new string[2048];
                    for(new x = 0;x<sizeof(MicroSMGs);x++)
                    {
                        format(string, sizeof(string), "%s%s - $%d\n", string, MicroSMGs[x][weaponname], MicroSMGs[x][weaponprice]);
                    }
                                    ShowPlayerDialog(playerid, DIALOG_SMG_MENU, DIALOG_STYLE_LIST, "Weapon Shop - Micro SMGs", string, "Buy", "Back");
                                }
                                case 3:
                                {
                                    new string[2048];
                    for(new x = 0;x<sizeof(Shotguns);x++)
                    {
                        format(string, sizeof(string), "%s%s - $%d\n", string, Shotguns[x][weaponname], Shotguns[x][weaponprice]);
                    }
                                    ShowPlayerDialog(playerid, DIALOG_SHOTGUN_MENU, DIALOG_STYLE_LIST, "Weapon Shop - Shotguns", string, "Buy", "Back");
                                }
                                case 4:
                                {
                                    new string[2048];
                    for(new x = 0;x<sizeof(Rifles);x++)
                    {
                        format(string, sizeof(string), "%s%s - $%d\n", string, Rifles[x][weaponname], Rifles[x][weaponprice]);
                    }
                                    ShowPlayerDialog(playerid, DIALOG_RIFLES_MENU, DIALOG_STYLE_LIST, "Weapon Shop - Rifles", string, "Buy", "Back");
                                }
                                case 5:
                                {
                                    new string[2048];
                    for(new x = 0;x<sizeof(AssaultRifles);x++)
                    {
                        format(string, sizeof(string), "%s%s - $%d\n", string, AssaultRifles[x][weaponname], AssaultRifles[x][weaponprice]);
                    }
                                    ShowPlayerDialog(playerid, DIALOG_ASSAULT_MENU, DIALOG_STYLE_LIST, "Weapon Shop - Assault Rifles", string, "Buy", "Back");
                                }
                                case 6:
                                {
                                    new string[2048];
                    for(new x = 0;x<sizeof(Thrown);x++)
                    {
                        format(string, sizeof(string), "%s%s - $%d\n", string, Thrown[x][weaponname], Thrown[x][weaponprice]);
                    }
                                    ShowPlayerDialog(playerid, DIALOG_ASSAULT_MENU, DIALOG_STYLE_LIST, "Weapon Shop - Thrown", string, "Buy", "Back");
                                }
                        }
                }
                return 0;
        }
    if(dialogid == DIALOG_PISTOL_MENU)
    {
        if(response)
        {
                        if(GetPlayerMoney(playerid) >= Pistols[listitem][weaponprice])
                        {
                        new string[128];
                        format(string, sizeof(string), "You have successfully purchased a %s for $%d.", Pistols[listitem][weaponname], Pistols[listitem][weaponprice]);
                                SendClientMessage(playerid, COLOR_WHITE, string);
                                GivePlayerMoney(playerid, -Pistols[listitem][weaponprice]);
                                GivePlayerWeapon(playerid, Pistols[listitem][weaponid], Pistols[listitem][weaponammo]);
                                return 1;
                        }
                        else
                        {
                        SendClientMessage(playerid, COLOR_RED, "You do not have enough money to purchase this item.");
                                return 1;
                        }
                }
                else
                {
                    ShowPlayerDialog(playerid, DIALOG_WEAPON_MENU, DIALOG_STYLE_LIST, "Weapon Shop", "Kevlar Vest - $100\nPistols\nMicro SMGs\nShotguns\nRifles\nAssault Rifles\nThrown", "Select", "Cancel");
                    return 1;
                }
        }
    if(dialogid == DIALOG_SMG_MENU)
    {
        if(response)
        {
                        if(GetPlayerMoney(playerid) >= MicroSMGs[listitem][weaponprice])
                        {
                        new string[128];
                        format(string, sizeof(string), "You have successfully purchased a %s for $%d.", MicroSMGs[listitem][weaponname], MicroSMGs[listitem][weaponprice]);
                                SendClientMessage(playerid, COLOR_WHITE, string);
                                GivePlayerMoney(playerid, -MicroSMGs[listitem][weaponprice]);
                                GivePlayerWeapon(playerid, MicroSMGs[listitem][weaponid], MicroSMGs[listitem][weaponammo]);
                                return 1;
                        }
                        else
                        {
                        SendClientMessage(playerid, COLOR_RED, "You do not have enough money to purchase this item.");
                                return 1;
                        }
                }
                else
                {
                    ShowPlayerDialog(playerid, DIALOG_WEAPON_MENU, DIALOG_STYLE_LIST, "Weapon Shop", "Kevlar Vest - $100\nPistols\nMicro SMGs\nShotguns\nRifles\nAssault Rifles\nThrown", "Select", "Cancel");
                    return 1;
                }
        }
    if(dialogid == DIALOG_SHOTGUN_MENU)
    {
        if(response)
        {
                        if(GetPlayerMoney(playerid) >= Shotguns[listitem][weaponprice])
                        {
                        new string[128];
                        format(string, sizeof(string), "You have successfully purchased a %s for $%d.", Shotguns[listitem][weaponname], Shotguns[listitem][weaponprice]);
                                SendClientMessage(playerid, COLOR_WHITE, string);
                                GivePlayerMoney(playerid, -Shotguns[listitem][weaponprice]);
                                GivePlayerWeapon(playerid, Shotguns[listitem][weaponid], Shotguns[listitem][weaponammo]);
                                return 1;
                        }
                        else
                        {
                        SendClientMessage(playerid, COLOR_RED, "You do not have enough money to purchase this item.");
                                return 1;
                        }
                }
                else
                {
                    ShowPlayerDialog(playerid, DIALOG_WEAPON_MENU, DIALOG_STYLE_LIST, "Weapon Shop", "Kevlar Vest - $100\nPistols\nMicro SMGs\nShotguns\nRifles\nAssault Rifles\nThrown", "Select", "Cancel");
                    return 1;
                }
        }
    if(dialogid == DIALOG_RIFLES_MENU)
    {
        if(response)
        {
                        if(GetPlayerMoney(playerid) >= Rifles[listitem][weaponprice])
                        {
                        new string[128];
                        format(string, sizeof(string), "You have successfully purchased a %s for $%d.", Rifles[listitem][weaponname], Rifles[listitem][weaponprice]);
                                SendClientMessage(playerid, COLOR_WHITE, string);
                                GivePlayerMoney(playerid, -Rifles[listitem][weaponprice]);
                                GivePlayerWeapon(playerid, Rifles[listitem][weaponid], Rifles[listitem][weaponammo]);
                                return 0;
                        }
                        else
                        {
                        SendClientMessage(playerid, COLOR_RED, "You do not have enough money to purchase this item.");
                                return 1;
                        }
                }
                else
                {
                    ShowPlayerDialog(playerid, DIALOG_WEAPON_MENU, DIALOG_STYLE_LIST, "Weapon Shop", "Kevlar Vest - $100\nPistols\nMicro SMGs\nShotguns\nRifles\nAssault Rifles\nThrown", "Select", "Cancel");
                    return 1;
                }
        }
    if(dialogid == DIALOG_ASSAULT_MENU)
    {
        if(response)
        {
                        if(GetPlayerMoney(playerid) >= AssaultRifles[listitem][weaponprice])
                        {
                        new string[128];
                        format(string, sizeof(string), "You have successfully purchased a %s for $%d.", AssaultRifles[listitem][weaponname], AssaultRifles[listitem][weaponprice]);
                                SendClientMessage(playerid, COLOR_WHITE, string);
                                GivePlayerMoney(playerid, -AssaultRifles[listitem][weaponprice]);
                                GivePlayerWeapon(playerid, AssaultRifles[listitem][weaponid], AssaultRifles[listitem][weaponammo]);
                                return 1;
                        }
                        else
                        {
                        SendClientMessage(playerid, COLOR_RED, "You do not have enough money to purchase this item.");
                                return 1;
                        }
                }
                else
                {
                    ShowPlayerDialog(playerid, DIALOG_WEAPON_MENU, DIALOG_STYLE_LIST, "Weapon Shop", "Kevlar Vest - $100\nPistols\nMicro SMGs\nShotguns\nRifles\nAssault Rifles\nThrown", "Select", "Cancel");
                    return 1;
                }
        }
    if(dialogid == DIALOG_THROWN_MENU)
    {
        if(response)
        {
                        if(GetPlayerMoney(playerid) >= Thrown[listitem][weaponprice])
                        {
                        new string[128];
                        format(string, sizeof(string), "You have successfully purchased a %s for $%d.", Thrown[listitem][weaponname], Thrown[listitem][weaponprice]);
                                SendClientMessage(playerid, COLOR_WHITE, string);
                                GivePlayerMoney(playerid, -Thrown[listitem][weaponprice]);
                                GivePlayerWeapon(playerid, Thrown[listitem][weaponid], Thrown[listitem][weaponammo]);
                                return 1;
                        }
                        else
                        {
                        SendClientMessage(playerid, COLOR_RED, "You do not have enough money to purchase this item.");
                                return 1;
                        }
                }
                else
                {
                    ShowPlayerDialog(playerid, DIALOG_WEAPON_MENU, DIALOG_STYLE_LIST, "Weapon Shop", "Kevlar Vest - $100\nPistols\nMicro SMGs\nShotguns\nRifles\nAssault Rifles\nThrown", "Select", "Cancel");
                    return 1;
                }
        }
    return 0;
}

