/**
 * ============================================
 * PLAYER DATA ENUMERATION
 * ============================================
 * Enum untuk menyimpan semua data pemain
 * yang tersimpan di database.
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

enum E_PLAYER_DATA
{
    // ========== ACCOUNT INFO ==========
    p_ID,                           // ID dari tabel users
    bool:pLoggedIn,                 // Status login
    pUCP[MAX_PLAYER_NAME],          // Nama akun UCP
    pVerifyCode,                    // Kode verifikasi
    pPassword[BCRYPT_HASH_LENGTH],  // Password ter-hash
    
    // ========== CHARACTER INFO ==========
    pChar,                          // Slot karakter aktif
    pName[MAX_PLAYER_NAME],         // Nama karakter in-game
    
    // ========== STATS ==========
    Float:pHealth,                  // HP
    Float:pArmour,                  // Armor
    
    // ========== POSITION ==========
    Float:pPosX,                    // Koordinat X
    Float:pPosY,                    // Koordinat Y
    Float:pPosZ,                    // Koordinat Z
    Float:pAngle,                   // Sudut hadap
    pInterior,                      // Interior ID
    pVirtualWorld,                  // Virtual World ID
    
    // ========== APPEARANCE & PROGRESS ==========
    pSkin,                          // Skin ID
    pLevel,                         // Level pemain
    pMoney,                         // Uang
    pKills,                         // Total kills
    pDeaths                         // Total deaths
}

// Alias untuk backward compatibility
#define pInt        pInterior
#define pVW         pVirtualWorld