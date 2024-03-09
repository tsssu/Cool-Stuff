/*
*	 @Nama: Login Reigster System
*	 @Author: Kirima
*	 @Version: 1.0
*
*	Copyright (c) 2024 Kirima
*
*	Permission is hereby granted, free of charge, to any person obtaining a copy
*	of this software and associated documentation files (the "Software"), to deal
*	in the Software without restriction, including without limitation the rights
*	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*	copies of the Software, and to permit persons to whom the Software is
*	furnished to do so, subject to the following conditions:
*
*	The above copyright notice and this permission notice shall be included in all
*	copies or substantial portions of the Software.
*/

// Main Include
#include <open.mp>
#include <samp_bcrypt>

// Redefine MAX_PLAYERS
#undef MAX_PLAYERS
#define MAX_PLAYERS 50

// Tell YSI we use NO HEAP allocation
#define YSI_NO_HEAP_MALLOC

// Core Include
#include <YSI_Coding\y_ebc>
#include <YSI_Coding\y_inline>

#include <YSI_Extra\y_inline_timers>
#include <YSI_Extra\y_inline_bcrypt>

#include <YSI_Server\y_colors>
#include <YSI_Visual\y_dialog>

// Login Register Config
const MAX_LOGIN_ATTEMPT 			= 3;
const MINIMUM_PASSWORD_REQUIREMENT 	= 5;

// Database Handle
final DB:accountDB 					= DB_Open("my.db");

// Global Variable
new bool:Account_g_sLoggedIn[MAX_PLAYERS];

// Forwards
forward OnAccountRegistered(playerid);
forward OnAccountLoggedIn(playerid);
forward OnAccountLogout(playerid);

// Get & Sets
bool:IsPlayerAccountLoggedIn(playerid)
{
	return (IsPlayerConnected(playerid) && Account_g_sLoggedIn[playerid]);
}

// Main Function
CheckPlayerAccount(playerid)
{
	if (IsPlayerAccountLoggedIn(playerid))
	{
		return 0;
	}

	new 
		string:playerName[MAX_PLAYER_NAME + 1],
		DBResult:result;

	GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
	result = DB_ExecuteQuery(accountDB, "SELECT id FROM accounts WHERE name = '%q'", playerName);

	if (DB_GetRowCount(result))
	{
		ShowPlayerLoginScreen(playerid);
	}
	else
	{
		ShowPlayerRegisterScreen(playerid);
	}
	DB_FreeResultSet(result);
	return 1;
}

void:HandleInvalidPassword(playerid, attempt)
{
	if (attempt >= MAX_LOGIN_ATTEMPT)
	{
		Kick(playerid);
		return;
	}

	SendClientMessage(playerid, X11_RED, "ERROR:"WHITE" Password yang anda masukkan salah (%d/%d)", attempt, MAX_LOGIN_ATTEMPT);
	ShowPlayerLoginScreen(playerid, attempt ++);
}

void:ShowPlayerLoginScreen(playerid, attempt = 0)
{
	if (IsPlayerAccountLoggedIn(playerid))
	{
		return;
	}

	inline OnLoginResponded(response, listitem, string:inputtext[])
	{
		#pragma unused listitem
		if (!response)
		{
			Kick(playerid);
			return;
		}

		if (IsNull(inputtext))
		{
			HandleInvalidPassword(playerid, attempt);
			return;
		}

		inline OnPasswordChecked(success)
		{
			if (!success)
			{
				HandleInvalidPassword(playerid, attempt);
				return;
			}

			SetSpawnInfo(playerid, NO_TEAM, 1, 0.0, 0.0, 2.5, 90.0, WEAPON_DEAGLE, 999999, WEAPON_AK47, 999999, WEAPON_FIST, 0);
			TogglePlayerSpectating(playerid, false);

			CallRemoteFunction(#OnAccountLoggedIn, "i", playerid);
			Account_g_sLoggedIn[playerid] = true;
		}

		new
			string:hash[BCRYPT_HASH_LENGTH],
			string:playerName[MAX_PLAYER_NAME + 1],
			DBResult:result;

		GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
		result = DB_ExecuteQuery(accountDB, "SELECT password FROM accounts WHERE name = '%q'", playerName);

		DB_GetFieldString(result, 0, hash);

		BCrypt_CheckInline(inputtext, hash, EBC(playerid, using inline OnPasswordChecked));
		MemSet(hash); // reset hash password immediately.
	}

	Dialog_ShowCallback(playerid, using inline OnLoginResponded, DIALOG_STYLE_PASSWORD, "{FFFFFF}Player Login", "Please type the password below to login", "Okay", "Exit");
}

void:ShowPlayerRegisterScreen(playerid)
{
	if (IsPlayerAccountLoggedIn(playerid))
	{
		return;
	}

	inline OnRegisterResponded(response, listitem, string:inputtext[])
	{
		#pragma unused listitem
		if (!response)
		{
			Kick(playerid);
			return;
		}

		if (strlen(inputtext) < MINIMUM_PASSWORD_REQUIREMENT)
		{
			SendClientMessage(playerid, X11_RED, "ERROR:"WHITE" Password yang anda masukkan kurang dari %d karakter", MINIMUM_PASSWORD_REQUIREMENT);
			ShowPlayerRegisterScreen(playerid);
			return;
		}

		inline OnPasswordHashed(string:hash[])
		{
			new 
				string:playerName[MAX_PLAYER_NAME + 1];

			GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);	
			DB_FreeResultSet(DB_ExecuteQuery(accountDB, "INSERT INTO accounts (name, password) VALUES ('%q', '%s')", playerName, hash));
		
			CallRemoteFunction(#OnAccountRegistered, "i", playerid);
		}

		BCrypt_HashInline(inputtext, BCRYPT_COST, EBC(playerid, using inline OnPasswordHashed));
	}

	Dialog_ShowCallback(playerid, using inline OnRegisterResponded, DIALOG_STYLE_PASSWORD, "{FFFFFF}Player Register", "Please type the password below to register", "Okay", "Exit");
}

// Globals
public OnGameModeInit()
{
	if (accountDB == DB:0)
	{
		print("Error: Database tidak bisa dikoneksikan");
		return 0;
	}

	DB_FreeResultSet(DB_ExecuteQuery(accountDB,
		"CREATE TABLE IF NOT EXISTS accounts ("\
		"    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,"\
		"    name VARCHAR(24) NOT NULL,"\
		"    password VARCHAR(60) NOT NULL"\
		")"
	));

	print("Sukses mengkoneksikan database my.db");
	return 1;
}

public OnGameModeExit()
{
	if (accountDB != DB:0)
	{
		DB_Close(accountDB);
	}
	return 1;
}

main()
{
	printf("Hello World");
}

public OnPlayerConnect(playerid)
{
	inline PrepareCheck()
	{
		// Setup camera disini
		CheckPlayerAccount(playerid);
		return 1;
	}

	TogglePlayerSpectating(playerid, true);
	Timer_CreateCallback(using inline PrepareCheck, 800, 1);
	return 1;
}

public OnAccountLoggedIn(playerid)
{
	SendClientMessage(playerid, X11_BLUE, "SERVER:"WHITE" Berhasil login kedalam server!");
	return 1;
}

public OnAccountRegistered(playerid)
{
	SendClientMessage(playerid, X11_BLUE, "SERVER:"WHITE" Akun anda berhasil dibuat!");
	ShowPlayerLoginScreen(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	CallRemoteFunction(#OnAccountLogout, "i", playerid);
	Account_g_sLoggedIn[playerid] = false;
	return 1;
}
