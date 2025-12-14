/**
 * ============================================
 * FUNGSI UTAMA GAMEMODE
 * ============================================
 * Berisi semua fungsi utama untuk sistem
 * autentikasi, karakter, dan database.
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

// ============================================
// MAIN ENTRY POINT
// ============================================
main()
{
    new szCmd[64];

    format(szCmd, sizeof(szCmd), "hostname %s", NamaServer);
    SendRconCommand(szCmd);
    
    format(szCmd, sizeof(szCmd), "gamemodetext %s(%s)", GM_NAME, Versi);
    SendRconCommand(szCmd);
    
    format(szCmd, sizeof(szCmd), "language %s", Bahasa);
    SendRconCommand(szCmd);
    
    format(szCmd, sizeof(szCmd), "weburl %s", WEB);
    SendRconCommand(szCmd);
    
    print(" ");
    print("============================================");
    printf("  %s v%s", NamaServer, Versi);
    print("  Gamemode berhasil dimuat!");
    print("============================================");
    print(" ");
}

// ============================================
// DATABASE FUNCTIONS
// ============================================

/**
 * Setup koneksi MySQL dengan retry mechanism
 * @param ttl Jumlah percobaan (default: 3)
 * @return 1 jika sukses
 */
stock MySQL_SetupConnection(ttl = 3)
{
    print("[MySQL] Menghubungkan ke database...");
    
    handle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DBSE);
    
    if(mysql_errno(handle) != 0)
    {
        if(ttl > 1)
        {
            print("[MySQL] Koneksi gagal, mencoba lagi...");
            printf("[MySQL] Sisa percobaan: %d", ttl - 1);
            return MySQL_SetupConnection(ttl - 1);
        }
        else
        {
            print("[MySQL] FATAL: Koneksi database gagal!");
            print("[MySQL] Periksa kredensial MySQL Anda.");
            print("[MySQL] Mematikan server...");
            return SendRconCommand("exit");
        }
    }
    
    printf("[MySQL] Koneksi berhasil! Handle: %d", _:handle);
    return 1;
}

// ============================================
// PLAYER DATA FUNCTIONS
// ============================================

/**
 * Reset semua data pemain ke default
 * Dipanggil saat OnPlayerConnect
 * @param playerid ID pemain
 */
stock ResetPlayerData(playerid)
{
    // Account
    pInfo[playerid][p_ID] = 0;
    pInfo[playerid][pLoggedIn] = false;
    pInfo[playerid][pVerifyCode] = 0;
    pInfo[playerid][pUCP][0] = EOS;
    pInfo[playerid][pPassword][0] = EOS;
    
    // Character
    pInfo[playerid][pChar] = 0;
    pInfo[playerid][pName][0] = EOS;
    
    // Stats
    pInfo[playerid][pHealth] = 100.0;
    pInfo[playerid][pArmour] = 0.0;
    pInfo[playerid][pLevel] = 0;
    pInfo[playerid][pMoney] = 0;
    pInfo[playerid][pKills] = 0;
    pInfo[playerid][pDeaths] = 0;
    
    // Position
    pInfo[playerid][pPosX] = DEFAULT_SPAWN_X;
    pInfo[playerid][pPosY] = DEFAULT_SPAWN_Y;
    pInfo[playerid][pPosZ] = DEFAULT_SPAWN_Z;
    pInfo[playerid][pAngle] = DEFAULT_SPAWN_ANGLE;
    pInfo[playerid][pInterior] = DEFAULT_SPAWN_INTERIOR;
    pInfo[playerid][pVirtualWorld] = DEFAULT_SPAWN_VW;
    pInfo[playerid][pSkin] = DEFAULT_SPAWN_SKIN;
    
    // Reset character list
    for(new i = 0; i < MAX_CHARS; i++)
    {
        PlayerChar[playerid][i][0] = EOS;
    }
}

// Alias untuk backward compatibility
#define resertenum ResetPlayerData

/**
 * Simpan data pemain ke database
 * @param playerid ID pemain
 * @return 1 jika sukses
 */
Fungsi:SaveUserStats(playerid)
{
    if(!pInfo[playerid][pLoggedIn]) 
        return 0;
    
    if(pInfo[playerid][p_ID] < 1)
        return 0;
    
    // Ambil data terkini
    GetPlayerHealth(playerid, pInfo[playerid][pHealth]);
    GetPlayerArmour(playerid, pInfo[playerid][pArmour]);
    GetPlayerPos(playerid, pInfo[playerid][pPosX], pInfo[playerid][pPosY], pInfo[playerid][pPosZ]);
    GetPlayerFacingAngle(playerid, pInfo[playerid][pAngle]);
    pInfo[playerid][pMoney] = GetPlayerMoney(playerid);
    pInfo[playerid][pInterior] = GetPlayerInterior(playerid);
    pInfo[playerid][pVirtualWorld] = GetPlayerVirtualWorld(playerid);
    pInfo[playerid][pSkin] = GetPlayerSkin(playerid);
    
    // Query dengan local variable (bukan global)
    new query[MAX_QUERY_LENGTH];
    mysql_format(handle, query, sizeof(query), 
        "UPDATE users SET \
        health = '%f', armour = '%f', \
        posx = '%f', posy = '%f', posz = '%f', angel = '%f', \
        interior = '%d', virtualworld = '%d', skin = '%d', \
        level = '%d', money = '%d', kills = '%d', deaths = '%d' \
        WHERE id = '%d'",
        pInfo[playerid][pHealth], pInfo[playerid][pArmour],
        pInfo[playerid][pPosX], pInfo[playerid][pPosY], pInfo[playerid][pPosZ], pInfo[playerid][pAngle],
        pInfo[playerid][pInterior], pInfo[playerid][pVirtualWorld], pInfo[playerid][pSkin],
        pInfo[playerid][pLevel], pInfo[playerid][pMoney], pInfo[playerid][pKills], pInfo[playerid][pDeaths],
        pInfo[playerid][p_ID]
    );
    
    mysql_pquery(handle, query);
    return 1;
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

/**
 * Mendapatkan nama pemain
 * @param playerid ID pemain
 * @return Nama pemain
 */
stock GetName(playerid)
{
    GetPlayerName(playerid, pInfo[playerid][pName], MAX_PLAYER_NAME);
    return pInfo[playerid][pName];
}

/**
 * Kick pemain dengan delay (mencegah kick sebelum pesan terkirim)
 * @param playerid ID pemain
 * @param time Delay dalam ms (default: 500)
 */
stock KickEx(playerid, time = 500)
{
    SetTimerEx("OnDelayedKick", time, false, "i", playerid);
    return 1;
}

Fungsi:OnDelayedKick(playerid)
{
    if(IsPlayerConnected(playerid))
        Kick(playerid);
    return 1;
}

/**
 * Validasi format nama karakter
 * @param name Nama untuk dicek
 * @return 1 jika valid, 0 jika tidak
 */
stock IsValidCharacterName(const name[])
{
    new len = strlen(name);
    
    // Panjang harus 1-24 karakter
    if(len < 1 || len > 24)
        return 0;
    
    new hasUnderscore = 0;
    
    for(new i = 0; i < len; i++)
    {
        // Cek underscore
        if(name[i] == '_')
        {
            // Underscore harus diikuti huruf kapital
            if(i + 1 < len && name[i + 1] >= 'A' && name[i + 1] <= 'Z')
            {
                hasUnderscore = 1;
                continue;
            }
            return 0;
        }
        
        // Tidak boleh ada karakter kotak
        if(name[i] == '[' || name[i] == ']')
            return 0;
    }
    
    return hasUnderscore;
}

// Alias lama
#define CekSimbol IsValidCharacterName

// ============================================
// AUTHENTICATION CALLBACKS
// ============================================

/**
 * Callback: Cek akun UCP di database
 */
Fungsi:OnUserCheck(playerid)
{
    new rows;
    cache_get_row_count(rows);
    
    if(rows == 0)
    {
        // Akun tidak ditemukan
        Dialog_Show(playerid, DIALOG_NONE_UCP, DIALOG_STYLE_MSGBOX, 
            "Akun Tidak Terdaftar", 
            "Silakan daftarkan diri Anda di UCP terlebih dahulu.\n\n"
            "Gunakan Discord bot untuk mendaftar.", 
            "Tutup", "");
        KickEx(playerid);
        return 1;
    }
    
    new aktivasi;
    cache_get_value_name_int(0, "aktivasi", aktivasi);
    
    if(aktivasi == 1)
    {
        // Akun sudah aktif - minta login
        cache_get_value_name(0, "katasandi", pInfo[playerid][pPassword], BCRYPT_HASH_LENGTH);
        
        Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, 
            "Login", 
            "{FFFFFF}Selamat datang kembali!\n\n"
            "Silahkan masukkan kata sandi Anda:", 
            "Masuk", "Keluar");
    }
    else
    {
        // Akun belum aktif - butuh verifikasi
        cache_get_value_name_int(0, "verifikasi", pInfo[playerid][pVerifyCode]);
        
        new str[300];
        format(str, sizeof(str), 
            "{FFFFFF}Halo, {FFFF00}%s{FFFFFF}!\n\n"
            "Kami membutuhkan kode verifikasi untuk mengaktifkan akun Anda.\n"
            "Silakan cek Direct Message di Discord untuk kode tersebut.\n\n"
            "{FF0000}Kode verifikasi berisi 5 digit angka.",
            pInfo[playerid][pUCP]);
        
        Dialog_Show(playerid, DIALOG_VERIFIKASI, DIALOG_STYLE_PASSWORD, 
            "Kode Verifikasi", str, "Input", "Keluar");
    }
    
    return 1;
}

/**
 * Callback: Verifikasi password
 */
Fungsi:OnPassswordVerify(playerid, bool:success)
{
    if(success)
    {
        // Password benar - load karakter
        CheckPemainChar(playerid);
    }
    else
    {
        // Password salah
        Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, 
            "Login", 
            "{FFFFFF}Silahkan masukkan kata sandi Anda:\n\n"
            "{FF0000}Kata sandi salah! Coba lagi.", 
            "Masuk", "Keluar");
    }
    return 1;
}

/**
 * Callback: Enkripsi password baru
 */
Fungsi:EnkripsiKataSandi(playerid, hashid)
{
    new hash[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(hash, sizeof(hash));
    
    pInfo[playerid][pPassword] = hash;
    
    new query[MAX_QUERY_LENGTH];
    mysql_format(handle, query, sizeof(query), 
        "UPDATE dataucp SET katasandi = '%s', aktivasi = 1 WHERE ucp = '%e'", 
        pInfo[playerid][pPassword], pInfo[playerid][pUCP]);
    mysql_pquery(handle, query);
    
    SendClientMessage(playerid, COLOR_SUCCESS, "[AKUN] Password berhasil disimpan!");
    return 1;
}

// ============================================
// CHARACTER SYSTEM
// ============================================

/**
 * Ambil daftar karakter pemain
 */
Fungsi:CheckPemainChar(playerid)
{
    new query[200];
    format(query, sizeof(query), 
        "SELECT `name`, `level` FROM `users` WHERE `ucp`='%s' LIMIT %d", 
        pInfo[playerid][pUCP], MAX_CHARS);
    mysql_tquery(handle, query, "LoadChar", "d", playerid);
    return 1;
}

/**
 * Callback: Load daftar karakter
 */
Fungsi:LoadChar(playerid)
{
    // Reset daftar karakter
    for(new i = 0; i < MAX_CHARS; i++)
    {
        PlayerChar[playerid][i][0] = EOS;
    }
    
    // Load dari cache
    new rows = cache_num_rows();
    for(new i = 0; i < rows && i < MAX_CHARS; i++)
    {
        cache_get_value_name(i, "name", PlayerChar[playerid][i]);
    }
    
    ShowCharacterList(playerid);
    return 1;
}

/**
 * Tampilkan dialog daftar karakter
 */
stock ShowCharacterList(playerid)
{
    new list[256], temp[48], count = 0;
    
    for(new i = 0; i < MAX_CHARS; i++)
    {
        if(PlayerChar[playerid][i][0] != EOS)
        {
            format(temp, sizeof(temp), "%s\n", PlayerChar[playerid][i]);
            strcat(list, temp);
            count++;
        }
    }
    
    // Tambah opsi buat karakter baru jika masih bisa
    if(count < MAX_CHARS)
    {
        strcat(list, "{00FF00}+ Buat Karakter Baru{FFFFFF}");
    }
    
    Dialog_Show(playerid, DIALOG_ClIST, DIALOG_STYLE_LIST, 
        "Pilih Karakter", list, "Pilih", "Keluar");
    return 1;
}

/**
 * Callback: Cek dan buat karakter baru
 */
Fungsi:MemasukanDataPemain(playerid, name[])
{
    new count = cache_num_rows();
    
    if(count > 0)
    {
        // Nama sudah ada
        Dialog_Show(playerid, DIALOG_BUATCHAR, DIALOG_STYLE_INPUT, 
            "Pembuatan Karakter", 
            "{FFFFFF}Masukkan nama karakter dengan format:\n"
            "{FFFF00}Nama_Lengkap {FFFFFF}(contoh: Budi_Santoso)\n\n"
            "{FF0000}Nama tersebut sudah digunakan!", 
            "Buat", "Batal");
        return 1;
    }
    
    // Buat karakter baru
    new query[256];
    mysql_format(handle, query, sizeof(query), 
        "INSERT INTO `users` (`name`, `ucp`) VALUES ('%s', '%s')", 
        name, pInfo[playerid][pUCP]);
    
    new Cache:result = mysql_query(handle, query);
    pInfo[playerid][p_ID] = cache_insert_id();
    cache_delete(result);
    
    // Set nama
    format(pInfo[playerid][pName], MAX_PLAYER_NAME, name);
    SetPlayerName(playerid, name);
    
    // Spawn pemain
    pInfo[playerid][pLoggedIn] = true;
    
    SendClientMessage(playerid, COLOR_SUCCESS, " ");
    SendClientMessage(playerid, COLOR_SUCCESS, "============================================");
    SendClientMessage(playerid, COLOR_SUCCESS, "  Karakter berhasil dibuat!");
    SendClientMessage(playerid, COLOR_SUCCESS, "  Selamat bermain!");
    SendClientMessage(playerid, COLOR_SUCCESS, "============================================");
    SendClientMessage(playerid, COLOR_SUCCESS, " ");
    
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    
    SetSpawnInfo(playerid, 0, DEFAULT_SPAWN_SKIN, 
        DEFAULT_SPAWN_X, DEFAULT_SPAWN_Y, DEFAULT_SPAWN_Z, DEFAULT_SPAWN_ANGLE, 
        0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    
    return 1;
}

/**
 * Callback: Load data karakter
 */
Fungsi:LOAD_CHAR(playerid)
{
    // Validasi ID
    cache_get_value_name_int(0, "id", pInfo[playerid][p_ID]);
    
    if(pInfo[playerid][p_ID] < 1)
    {
        SendClientMessage(playerid, COLOR_ERROR, "[ERROR] Data karakter tidak ditemukan!");
        KickEx(playerid);
        return 1;
    }
    
    // Load semua data
    cache_get_value_name_float(0, "health", pInfo[playerid][pHealth]);
    cache_get_value_name_float(0, "armour", pInfo[playerid][pArmour]);
    cache_get_value_name_float(0, "posx", pInfo[playerid][pPosX]);
    cache_get_value_name_float(0, "posy", pInfo[playerid][pPosY]);
    cache_get_value_name_float(0, "posz", pInfo[playerid][pPosZ]);
    cache_get_value_name_float(0, "angel", pInfo[playerid][pAngle]);
    cache_get_value_name_int(0, "interior", pInfo[playerid][pInterior]);
    cache_get_value_name_int(0, "virtualworld", pInfo[playerid][pVirtualWorld]);
    cache_get_value_name_int(0, "skin", pInfo[playerid][pSkin]);
    cache_get_value_name_int(0, "level", pInfo[playerid][pLevel]);
    cache_get_value_name_int(0, "money", pInfo[playerid][pMoney]);
    cache_get_value_name_int(0, "kills", pInfo[playerid][pKills]);
    cache_get_value_name_int(0, "deaths", pInfo[playerid][pDeaths]);
    
    // Set login status
    pInfo[playerid][pLoggedIn] = true;
    
    // Pesan selamat datang
    SendClientMessage(playerid, COLOR_SUCCESS, " ");
    SendClientMessage(playerid, COLOR_SUCCESS, "============================================");
    SendClientMessage(playerid, -1, "  Selamat datang kembali!");
    SendClientMessage(playerid, -1, "  Karakter Anda berhasil dimuat.");
    SendClientMessage(playerid, COLOR_SUCCESS, "============================================");
    SendClientMessage(playerid, COLOR_SUCCESS, " ");
    
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    
    // Set stats
    SetPlayerHealth(playerid, pInfo[playerid][pHealth]);
    SetPlayerArmour(playerid, pInfo[playerid][pArmour]);
    GivePlayerMoney(playerid, pInfo[playerid][pMoney]);
    
    // Spawn
    SetSpawnInfo(playerid, -1, pInfo[playerid][pSkin], 
        pInfo[playerid][pPosX], pInfo[playerid][pPosY], pInfo[playerid][pPosZ], pInfo[playerid][pAngle], 
        -1, -1, -1, -1, -1, -1);
    SpawnPlayer(playerid);
    
    SetPlayerInterior(playerid, pInfo[playerid][pInterior]);
    SetPlayerVirtualWorld(playerid, pInfo[playerid][pVirtualWorld]);
    
    return 1;
}

/**
 * Callback: User login (legacy - untuk kompatibilitas)
 */
Fungsi:OnUserLogin(playerid)
{
    new rows;
    cache_get_row_count(rows);
    
    if(rows == 0)
    {
        Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, 
            "Login", 
            "{FFFFFF}Silahkan masukkan kata sandi Anda:\n\n"
            "{FF0000}Kata sandi salah!", 
            "Masuk", "Keluar");
    }
    else
    {
        CheckPemainChar(playerid);
    }
    return 1;
}
