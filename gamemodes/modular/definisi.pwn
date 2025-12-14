/**
 * ============================================
 * DEFINISI DAN KONSTANTA SERVER
 * ============================================
 * File ini berisi semua konstanta dan definisi
 * yang digunakan di seluruh gamemode.
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

// ============================================
// INFORMASI SERVER
// ============================================
#define NamaServer      "MYSQL R41-4"
#define Versi           "2.0"
#define Bahasa          "Indonesia"
#define GM_NAME         "BASIC MYSQL"
#define WEB             "google.com"

// ============================================
// KONFIGURASI DATABASE MYSQL
// ============================================
#if defined MYSQL_LOCALHOST
    #define MYSQL_HOST      "127.0.0.1"
    #define MYSQL_USER      "root"
    #define MYSQL_PASS      ""
    #define MYSQL_DBSE      "ksamp"
#else
    #define MYSQL_HOST      "127.0.0.1"
    #define MYSQL_USER      "root"
    #define MYSQL_PASS      ""
    #define MYSQL_DBSE      "ksamp"
#endif

// ============================================
// SPAWN DEFAULT
// ============================================
#define DEFAULT_SPAWN_X         1682.6084
#define DEFAULT_SPAWN_Y         -2327.8940
#define DEFAULT_SPAWN_Z         13.5469
#define DEFAULT_SPAWN_ANGLE     3.4335
#define DEFAULT_SPAWN_SKIN      98
#define DEFAULT_SPAWN_INTERIOR  0
#define DEFAULT_SPAWN_VW        0

// ============================================
// BATAS SISTEM
// ============================================
#define MAX_CHARS               5           // Maksimal karakter per akun
#define MIN_PASSWORD_LENGTH     3           // Panjang password minimal
#define MAX_PASSWORD_LENGTH     64          // Panjang password maksimal
#define MAX_QUERY_LENGTH        512         // Panjang query maksimal

// ============================================
// WARNA CHAT
// ============================================
#define COLOR_WHITE         0xFFFFFFFF
#define COLOR_RED           0xFF0000FF
#define COLOR_GREEN         0x00FF00FF
#define COLOR_YELLOW        0xFFFF00FF
#define COLOR_BLUE          0x0000FFFF
#define COLOR_ORANGE        0xFFA500FF
#define COLOR_GREY          0xAFAFAFFF
#define COLOR_ERROR         0xFF6347FF
#define COLOR_SUCCESS       0x32CD32FF
#define COLOR_INFO          0x00BFFFFF

// ============================================
// MACROS
// ============================================
/**
 * Macro untuk membuat forward dan public function
 * Penggunaan: Fungsi:NamaCallback(params)
 */
#define Fungsi:%0(%1)   forward %0(%1); public %0(%1)

// ============================================
// BCRYPT CONFIGURATION
// ============================================
#if !defined BCRYPT_HASH_LENGTH
    #define BCRYPT_HASH_LENGTH  250
#endif

#if !defined BCRYPT_COST
    #define BCRYPT_COST         12
#endif

// ============================================
// UTILITY MACROS
// ============================================
/**
 * Cek apakah player valid dan terkoneksi
 */
#define IsValidPlayer(%0)   ((%0) >= 0 && (%0) < MAX_PLAYERS && IsPlayerConnected(%0))

/**
 * Kirim pesan error ke player
 */
#define SendErrorMessage(%0,%1) \
    SendClientMessage(%0, COLOR_ERROR, "{FF0000}[ERROR] {FFFFFF}"#%1)

/**
 * Kirim pesan sukses ke player
 */
#define SendSuccessMessage(%0,%1) \
    SendClientMessage(%0, COLOR_SUCCESS, "{00FF00}[SUCCESS] {FFFFFF}"#%1)

/**
 * Kirim pesan info ke player
 */
#define SendInfoMessage(%0,%1) \
    SendClientMessage(%0, COLOR_INFO, "{00BFFF}[INFO] {FFFFFF}"#%1)