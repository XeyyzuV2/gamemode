/**
 * ============================================
 * GLOBAL VARIABLES
 * ============================================
 * Variabel global yang digunakan di gamemode.
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

// ========== DATABASE ==========
new MySQL:handle;                   // MySQL connection handle

// ========== VEHICLES ==========
new total_vehicles_from_files = 0;  // Total vehicle yang diload dari file

// ========== CHARACTER SYSTEM ==========
new PlayerChar[MAX_PLAYERS][MAX_CHARS][MAX_PLAYER_NAME + 1];  // Daftar karakter per player