/**
 * ============================================
 * DIALOG HANDLERS
 * ============================================
 * Handler untuk semua dialog responses.
 * Menggunakan easyDialog library.
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

// ============================================
// DIALOG: REGISTRASI PASSWORD
// ============================================

/**
 * Handler untuk dialog registrasi password baru
 */
Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[])
{
    if(!response) 
    {
        SendClientMessage(playerid, COLOR_INFO, "[INFO] Anda membatalkan pendaftaran.");
        KickEx(playerid);
        return 1;
    }
    
    // Validasi panjang password
    new len = strlen(inputtext);
    
    if(len < MIN_PASSWORD_LENGTH)
    {
        Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, 
            "Registrasi", 
            "{FFFFFF}Buat kata sandi untuk akun Anda:\n\n"
            "{FF0000}Password minimal 3 karakter!", 
            "Daftar", "Batal");
        return 1;
    }
    
    if(len > MAX_PASSWORD_LENGTH)
    {
        Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, 
            "Registrasi", 
            "{FFFFFF}Buat kata sandi untuk akun Anda:\n\n"
            "{FF0000}Password maksimal 64 karakter!", 
            "Daftar", "Batal");
        return 1;
    }
    
    // Hash password menggunakan bcrypt
    bcrypt_hash(playerid, "EnkripsiKataSandi", inputtext, BCRYPT_COST);
    
    SendClientMessage(playerid, COLOR_INFO, "[INFO] Memproses pendaftaran...");
    
    // Lanjut ke login
    Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, 
        "Login", 
        "{00FF00}Password berhasil dibuat!\n\n"
        "{FFFFFF}Silahkan masuk dengan kata sandi Anda:", 
        "Masuk", "Batal");
    
    return 1;
}

// ============================================
// DIALOG: LOGIN
// ============================================

/**
 * Handler untuk dialog login
 */
Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[])
{
    if(!response) 
    {
        SendClientMessage(playerid, COLOR_INFO, "[INFO] Anda membatalkan login.");
        KickEx(playerid);
        return 1;
    }
    
    // Validasi input
    if(strlen(inputtext) < MIN_PASSWORD_LENGTH)
    {
        Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, 
            "Login", 
            "{FFFFFF}Silahkan masukkan kata sandi Anda:\n\n"
            "{FF0000}Password minimal 3 karakter!", 
            "Masuk", "Keluar");
        return 1;
    }
    
    // Verifikasi dengan bcrypt
    SendClientMessage(playerid, COLOR_INFO, "[INFO] Memverifikasi password...");
    bcrypt_verify(playerid, "OnPassswordVerify", inputtext, pInfo[playerid][pPassword]);
    
    return 1;
}

// ============================================
// DIALOG: VERIFIKASI KODE
// ============================================

/**
 * Handler untuk dialog verifikasi kode dari Discord
 */
Dialog:DIALOG_VERIFIKASI(playerid, response, listitem, inputtext[])
{
    if(!response)
    {
        SendClientMessage(playerid, COLOR_INFO, "[INFO] Anda membatalkan verifikasi.");
        KickEx(playerid);
        return 1;
    }
    
    // Validasi input harus angka
    if(!isNumeric(inputtext))
    {
        new str[300];
        format(str, sizeof(str), 
            "{FFFFFF}Halo, {FFFF00}%s{FFFFFF}!\n\n"
            "Masukkan kode verifikasi dari Discord.\n\n"
            "{FF0000}Kode verifikasi hanya berisi angka!",
            pInfo[playerid][pUCP]);
        
        Dialog_Show(playerid, DIALOG_VERIFIKASI, DIALOG_STYLE_PASSWORD, 
            "Kode Verifikasi", str, "Input", "Keluar");
        return 1;
    }
    
    // Cek kode
    if(strval(inputtext) != pInfo[playerid][pVerifyCode])
    {
        new str[300];
        format(str, sizeof(str), 
            "{FFFFFF}Halo, {FFFF00}%s{FFFFFF}!\n\n"
            "Masukkan kode verifikasi dari Discord.\n\n"
            "{FF0000}Kode verifikasi salah! Cek DM Discord Anda.",
            pInfo[playerid][pUCP]);
        
        Dialog_Show(playerid, DIALOG_VERIFIKASI, DIALOG_STYLE_PASSWORD, 
            "Kode Verifikasi", str, "Input", "Keluar");
        return 1;
    }
    
    // Kode benar - lanjut buat password
    SendClientMessage(playerid, COLOR_SUCCESS, "[AKUN] Kode verifikasi benar!");
    
    new str[400];
    format(str, sizeof(str), 
        "{00FF00}Kode verifikasi berhasil!\n\n"
        "{FFFFFF}Akun UCP: {FFFF00}%s\n"
        "{FFFFFF}Status: {00FF00}Terverifikasi\n\n"
        "{FFFFFF}Silakan buat kata sandi untuk melanjutkan.",
        pInfo[playerid][pUCP]);
    
    Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, 
        "Buat Password", str, "Buat", "Keluar");
    
    return 1;
}

// ============================================
// DIALOG: DAFTAR KARAKTER
// ============================================

/**
 * Handler untuk dialog pilih karakter
 */
Dialog:DIALOG_ClIST(playerid, response, listitem, inputtext[])
{
    if(!response)
    {
        SendClientMessage(playerid, COLOR_INFO, "[INFO] Anda keluar dari pemilihan karakter.");
        KickEx(playerid);
        return 1;
    }
    
    // Cek apakah slot kosong (buat karakter baru)
    if(PlayerChar[playerid][listitem][0] == EOS)
    {
        Dialog_Show(playerid, DIALOG_BUATCHAR, DIALOG_STYLE_INPUT, 
            "Buat Karakter Baru", 
            "{FFFFFF}Masukkan nama karakter dengan format:\n"
            "{FFFF00}Nama_Lengkap\n\n"
            "{AAAAAA}Contoh: Budi_Santoso, Rina_Wijaya\n\n"
            "{FFFFFF}Gunakan nama orang Indonesia yang realistis.", 
            "Buat", "Batal");
        return 1;
    }
    
    // Pilih karakter yang sudah ada
    pInfo[playerid][pChar] = listitem;
    SetPlayerName(playerid, PlayerChar[playerid][listitem]);
    
    SendClientMessage(playerid, COLOR_INFO, "[INFO] Memuat data karakter...");
    
    new query[200];
    format(query, sizeof(query), 
        "SELECT * FROM `users` WHERE `name` = '%s' LIMIT 1", 
        PlayerChar[playerid][pInfo[playerid][pChar]]);
    mysql_tquery(handle, query, "LOAD_CHAR", "d", playerid);
    
    return 1;
}

// ============================================
// DIALOG: BUAT KARAKTER
// ============================================

/**
 * Handler untuk dialog pembuatan karakter baru
 */
Dialog:DIALOG_BUATCHAR(playerid, response, listitem, inputtext[])
{
    if(!response)
    {
        // Kembali ke daftar karakter
        ShowCharacterList(playerid);
        return 1;
    }
    
    // Validasi panjang nama
    new len = strlen(inputtext);
    
    if(len < 1 || len > 24)
    {
        Dialog_Show(playerid, DIALOG_BUATCHAR, DIALOG_STYLE_INPUT, 
            "Buat Karakter Baru", 
            "{FFFFFF}Masukkan nama karakter dengan format:\n"
            "{FFFF00}Nama_Lengkap\n\n"
            "{FF0000}Nama harus 1-24 karakter!", 
            "Buat", "Batal");
        return 1;
    }
    
    // Validasi format nama
    if(!IsValidCharacterName(inputtext))
    {
        Dialog_Show(playerid, DIALOG_BUATCHAR, DIALOG_STYLE_INPUT, 
            "Buat Karakter Baru", 
            "{FFFFFF}Masukkan nama karakter dengan format:\n"
            "{FFFF00}Nama_Lengkap\n\n"
            "{FF0000}Format salah! Gunakan format: Nama_Lengkap\n"
            "{FF0000}Huruf setelah underscore harus kapital.", 
            "Buat", "Batal");
        return 1;
    }
    
    // Cek apakah nama sudah dipakai
    SendClientMessage(playerid, COLOR_INFO, "[INFO] Memeriksa ketersediaan nama...");
    
    new query[200];
    mysql_format(handle, query, sizeof(query), 
        "SELECT * FROM `users` WHERE `name` = '%s'", inputtext);
    mysql_tquery(handle, query, "MemasukanDataPemain", "ds", playerid, inputtext);
    
    return 1;
}

// ============================================
// DIALOG: AKUN TIDAK TERDAFTAR
// ============================================

/**
 * Dialog placeholder untuk akun tidak terdaftar
 */
Dialog:DIALOG_NONE_UCP(playerid, response, listitem, inputtext[])
{
    // Kick setelah close dialog
    KickEx(playerid);
    return 1;
}