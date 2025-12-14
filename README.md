# 🎮 SA-MP Gamemode + Discord Bot

Gamemode SA-MP dengan sistem UCP (User Control Panel) terintegrasi dengan Discord Bot untuk pendaftaran akun.

## 📋 Daftar Isi

- [Fitur](#-fitur)
- [Persyaratan](#-persyaratan)
- [Instalasi](#-instalasi)
- [Konfigurasi](#-konfigurasi)
- [Struktur Proyek](#-struktur-proyek)
- [Database Schema](#-database-schema)
- [Penggunaan](#-penggunaan)
- [Kontribusi](#-kontribusi)

## ✨ Fitur

### Gamemode (SA-MP)
- 🔐 Sistem autentikasi UCP dengan bcrypt hashing
- 👥 Multi-karakter (5 karakter per akun)
- 💾 Penyimpanan data otomatis ke MySQL
- 🚗 Vehicle spawner dari file konfigurasi
- 📊 Sistem level dan statistik

### Discord Bot
- 🎫 Pendaftaran akun via Discord
- 🔑 Sistem verifikasi dengan kode OTP
- 🔄 Reset password
- 📱 Panel interaktif dengan tombol

## 📦 Persyaratan

### SA-MP Server
- SA-MP Server 0.3.7-R2+
- MySQL/MariaDB 10.4+
- Plugins:
  - mysql R41-4+
  - sscanf 2.13+
  - streamer
  - pawncmd
  - samp_bcrypt
  - crashdetect

### Discord Bot
- Node.js 16.9.0+
- NPM 7+

## 🚀 Instalasi

### 1. Clone Repository
```bash
git clone <repository-url>
cd GAMEMODE-SAMP
```

### 2. Setup Database
```bash
# Import SQL schema
mysql -u root -p ksamp < gamemodes/ksamp.sql
```

### 3. Konfigurasi Gamemode
Edit file `gamemodes/modular/definisi.pwn`:
```pawn
#define MYSQL_HOST      "127.0.0.1"
#define MYSQL_USER      "root"
#define MYSQL_PASS      "password"
#define MYSQL_DBSE      "ksamp"
```

### 4. Compile Gamemode
Gunakan pawno atau compiler Pawn untuk compile `gamemodes/new.pwn`

### 5. Setup Discord Bot
```bash
cd bot
npm install
```

### 6. Konfigurasi Bot
Edit file `bot/.env`:
```env
NAMA_SERVER = NamaServerAnda
TOKEN_BOT = token_bot_discord_anda
OWNER_ID = discord_id_anda
GUILD_ID = guild_id_discord_anda
ROLE_ADMIN = role_id_admin
ROLE_WARGA = role_id_warga
```

Edit file `bot/config.json`:
```json
{
    "mysql": {
        "host": "127.0.0.1",
        "user": "root",
        "password": "password",
        "database": "ksamp"
    }
}
```

### 7. Jalankan Bot
```bash
cd bot
node bot-dc.js
```

## ⚙️ Konfigurasi

### Server SA-MP (`server.cfg`)
```
hostname Basic Mysql R41-4
gamemode0 new
plugins crashdetect mysql sscanf streamer pawncmd samp_bcrypt
```

### Discord Bot (`.env`)
| Variable | Deskripsi |
|----------|-----------|
| `NAMA_SERVER` | Nama server untuk ditampilkan |
| `TOKEN_BOT` | Token Discord bot |
| `OWNER_ID` | Discord ID owner |
| `GUILD_ID` | ID server Discord |
| `ROLE_ADMIN` | ID role admin |
| `ROLE_WARGA` | ID role warga |
| `PREFIX_BOT` | Prefix command (default: !) |
| `SERVER_IP` | IP server SAMP |
| `SERVER_PORT` | Port server SAMP |

## 📁 Struktur Proyek

```
GAMEMODE SAMP/
├── bot/                        # Discord Bot
│   ├── Commands/              # Command handlers
│   ├── Core/                  # Core loader
│   ├── Events/                # Event handlers
│   ├── Modals/                # Modal handlers
│   ├── Tombol/                # Button handlers
│   ├── utils/                 # Utility modules
│   │   ├── database.js       # Database wrapper
│   │   └── validation.js     # Input validation
│   ├── bot-dc.js             # Entry point
│   ├── Functions.js          # Helper functions
│   └── config.json           # Konfigurasi
│
├── gamemodes/                  # SA-MP Gamemode
│   ├── modular/               # File modular
│   │   ├── core.pwn          # Core loader
│   │   ├── definisi.pwn      # Konstanta & definisi
│   │   ├── enum.pwn          # Enumerasi data
│   │   ├── enumvariable.pwn  # Variabel enum
│   │   ├── variabel.pwn      # Variabel global
│   │   ├── Fungsi.pwn        # Fungsi utama
│   │   └── dialog.pwn        # Dialog handlers
│   ├── new.pwn               # Entry point
│   └── ksamp.sql             # Database schema
│
├── include/                    # Include files
├── plugins/                    # SA-MP plugins
├── scriptfiles/               # Data files
│   └── vehicles/             # Vehicle spawn files
└── server.cfg                 # Server configuration
```

## 💾 Database Schema

### Tabel `dataucp`
Menyimpan data akun UCP.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| ucp | VARCHAR(32) | Nama akun UCP |
| verifikasi | INT | Kode verifikasi 5 digit |
| aktivasi | INT | Status aktivasi (0/1) |
| katasandi | VARCHAR(64) | Password (bcrypt hash) |
| discord | BIGINT | Discord user ID |

### Tabel `users`
Menyimpan data karakter.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(64) | Nama karakter |
| ucp | VARCHAR(64) | Nama akun UCP |
| health | FLOAT | Health |
| armour | FLOAT | Armour |
| posx/y/z | FLOAT | Posisi X/Y/Z |
| angel | FLOAT | Sudut hadap |
| interior | INT | Interior ID |
| virtualworld | INT | Virtual World ID |
| skin | INT | Skin ID |
| level | INT | Level pemain |
| money | INT | Uang |
| kills | INT | Total kills |
| deaths | INT | Total deaths |

## 🎯 Penggunaan

### Alur Pendaftaran
1. User klik tombol "Ambil Tiket" di Discord
2. Isi nama UCP di modal
3. Terima kode verifikasi via DM
4. Masuk ke server SAMP
5. Input kode verifikasi
6. Buat password baru
7. Login dan buat karakter

### Commands Discord
| Command | Description |
|---------|-------------|
| `!ping` | Cek latensi bot |
| `!menupanel` | Tampilkan panel pendaftaran (Admin) |
| `!sdbot` | Matikan bot (Owner) |

## 🔒 Keamanan

- ✅ Password di-hash dengan bcrypt (cost 12)
- ✅ SQL Injection prevention dengan parameterized queries
- ✅ Input validation pada semua form
- ✅ Rate limiting pada commands
- ✅ Error handling yang komprehensif

## 🤝 Kontribusi

1. Fork repository
2. Buat branch fitur (`git checkout -b fitur/FiturBaru`)
3. Commit perubahan (`git commit -m 'Tambah fitur baru'`)
4. Push ke branch (`git push origin fitur/FiturBaru`)
5. Buat Pull Request

## 📄 Lisensi

Lihat file [LICENSE](LICENSE) untuk detail.

---

**Dibuat dengan ❤️ oleh XeyyzuV2**
