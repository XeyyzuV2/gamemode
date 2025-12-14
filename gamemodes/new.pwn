/**
 * ============================================
 * GAMEMODE UTAMA - SA-MP SERVER
 * ============================================
 * Entry point untuk gamemode.
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 * @website google.com
 */

// ========== CORE INCLUDES ==========
#include <a_samp>
#include <a_mysql>
#include "../include/gl_common.inc"
#include <crashdetect>

// ========== LIBRARY TAMBAHAN ==========
#include <easyDialog>
#include <sscanf2>
#include <Pawn.CMD>

// ========== YSI LIBRARIES ==========
#include <YSI_Data\y_bit>
#include <YSI_Data\y_iterate>
#include <YSI_Coding\y_hooks>

// ========== KONFIGURASI ==========
#define MYSQL_LOCALHOST

// ========== MODULAR CORE ==========
#include "modular/core.pwn"

// ============================================
// CALLBACKS
// ============================================

/**
 * Callback: Gamemode dimulai
 */
public OnGameModeInit()
{
    // Setup koneksi database
    MySQL_SetupConnection();
    
    print(" ");
    print("============================================");
    print("  Loading Vehicles...");
    print("============================================");
    
    // ========== SPECIAL VEHICLES ==========
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/trains.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/pilots.txt");
    
    // ========== LAS VENTURAS ==========
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_gen.txt");
    
    // ========== SAN FIERRO ==========
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_gen.txt");
    
    // ========== LOS SANTOS ==========
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_inner.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_outer.txt");
    
    // ========== AREA LAINNYA ==========
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/whetstone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/bone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/flint.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/tierra.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/red_county.txt");
    
    print("============================================");
    printf("  Total Vehicles Loaded: %d", total_vehicles_from_files);
    print("============================================");
    print(" ");
    
    return 1;
}

/**
 * Callback: Gamemode berakhir
 */
public OnGameModeExit()
{
    // Tutup koneksi database
    mysql_close(handle);
    
    print("[SERVER] Gamemode berhasil dihentikan.");
    return 1;
}

/**
 * Callback: Pemain terhubung ke server
 */
public OnPlayerConnect(playerid)
{
    // Reset semua data pemain
    ResetPlayerData(playerid);
    
    // Pesan selamat datang
    SendClientMessage(playerid, COLOR_WHITE, " ");
    SendClientMessage(playerid, COLOR_SUCCESS, "============================================");
    SendClientMessage(playerid, COLOR_WHITE, "  Selamat datang di server!");
    SendClientMessage(playerid, COLOR_WHITE, "  Silakan pilih kelas untuk melanjutkan.");
    SendClientMessage(playerid, COLOR_SUCCESS, "============================================");
    SendClientMessage(playerid, COLOR_WHITE, " ");
    
    return 1;
}

/**
 * Callback: Pemain memilih kelas spawn
 */
public OnPlayerRequestClass(playerid, classid)
{
    // Cek apakah sudah login
    if(!pInfo[playerid][pLoggedIn])
    {
        // Ambil nama UCP
        GetPlayerName(playerid, pInfo[playerid][pUCP], MAX_PLAYER_NAME);
        
        // Query ke database
        new query[200];
        mysql_format(handle, query, sizeof(query), 
            "SELECT * FROM `dataucp` WHERE `ucp` = '%e' LIMIT 1", 
            pInfo[playerid][pUCP]);
        mysql_pquery(handle, query, "OnUserCheck", "d", playerid);
    }
    
    return 1;
}

/**
 * Callback: Pemain mencoba spawn
 */
public OnPlayerRequestSpawn(playerid)
{
    // Cegah spawn jika belum login
    if(!pInfo[playerid][pLoggedIn])
    {
        SendClientMessage(playerid, COLOR_ERROR, "[ERROR] Anda harus login terlebih dahulu!");
        return 0;
    }
    
    return 1;
}

/**
 * Callback: Pemain disconnect
 */
public OnPlayerDisconnect(playerid, reason)
{
    // Simpan data pemain
    if(pInfo[playerid][pLoggedIn])
    {
        SaveUserStats(playerid);
    }
    
    // Reset nama ke UCP (untuk tracking)
    if(pInfo[playerid][pUCP][0] != EOS)
    {
        SetPlayerName(playerid, pInfo[playerid][pUCP]);
    }
    
    // Log disconnect
    new reasonText[20];
    switch(reason)
    {
        case 0: reasonText = "Timeout";
        case 1: reasonText = "Quit";
        case 2: reasonText = "Kick/Ban";
        default: reasonText = "Unknown";
    }
    printf("[DISCONNECT] %s (%d) - Reason: %s", pInfo[playerid][pName], playerid, reasonText);
    
    return 1;
}

/**
 * Callback: Pemain meninggal
 */
public OnPlayerDeath(playerid, killerid, reason)
{
    // Tambah death count
    pInfo[playerid][pDeaths]++;
    
    // Jika ada yang membunuh
    if(killerid != INVALID_PLAYER_ID && IsPlayerConnected(killerid))
    {
        // Tambah kill count
        pInfo[killerid][pKills]++;
        
        // Reward untuk killer
        GivePlayerMoney(killerid, 500);
        pInfo[killerid][pMoney] += 500;
        
        // Pesan kill
        new msg[128];
        format(msg, sizeof(msg), 
            "[KILL] Anda membunuh %s (+$500)", 
            pInfo[playerid][pName]);
        SendClientMessage(killerid, COLOR_SUCCESS, msg);
        
        // Level up check (setiap 5 kills)
        if(pInfo[killerid][pKills] % 5 == 0)
        {
            pInfo[killerid][pLevel]++;
            format(msg, sizeof(msg), 
                "[LEVEL UP] Anda naik ke level %d!", 
                pInfo[killerid][pLevel]);
            SendClientMessage(killerid, COLOR_SUCCESS, msg);
            PlayerPlaySound(killerid, 1057, 0.0, 0.0, 0.0);
        }
    }
    
    return 1;
}

/**
 * Callback: Pemain spawn
 */
public OnPlayerSpawn(playerid)
{
    // Set player ke posisi terakhir jika sudah pernah main
    if(pInfo[playerid][pLoggedIn])
    {
        SetPlayerInterior(playerid, pInfo[playerid][pInterior]);
        SetPlayerVirtualWorld(playerid, pInfo[playerid][pVirtualWorld]);
    }
    
    return 1;
}
