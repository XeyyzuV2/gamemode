/**
 * ============================================
 * CORE LOADER
 * ============================================
 * File ini mengatur urutan loading semua
 * file modular dalam gamemode.
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

// ========== LIBRARY EKSTERNAL ==========
#include <samp_bcrypt>

// ========== MODULAR FILES ==========
// Urutan loading penting - jangan diubah!

// 1. Definisi dan konstanta
#include "./modular/definisi.pwn"

// 2. Enum data structures
#include "./modular/enum.pwn"

// 3. Variabel untuk enum
#include "./modular/enumvariable.pwn"

// 4. Variabel global lainnya
#include "./modular/variabel.pwn"

// 5. Fungsi-fungsi utama
#include "./modular/fungsi.pwn"

// 6. Dialog handlers
#include "./modular/dialog.pwn"

// ========== TAMBAHAN MODULAR ==========
// Tambahkan module baru di sini:
// #include "./modular/jobs.pwn"
// #include "./modular/vehicles.pwn"
// #include "./modular/houses.pwn"
