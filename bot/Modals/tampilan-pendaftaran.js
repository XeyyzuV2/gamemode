/**
 * Modal Tampilan Pendaftaran
 * Memproses pendaftaran akun UCP baru
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

const { CommandInteraction, MessageEmbed } = require("discord.js");
const db = require("../utils/database");
const { validateUCPName, generateVerifyCode, sanitizeForLog } = require("../utils/validation");
const client = require("../bot-dc");
require("../Functions");

module.exports = {
    id: "tampilan-pendaftaran",

    /**
     * Handle modal submission
     * @param {CommandInteraction} interaction
     */
    run: async (interaction) => {
        try {
            const userId = interaction.user.id;
            const inputName = interaction.fields.getTextInputValue('reg-name');

            // Validasi nama UCP menggunakan utility function
            const validation = validateUCPName(inputName);
            if (!validation.valid) {
                return IntError(interaction, validation.error);
            }

            const ucpName = validation.value;
            const verifyCode = generateVerifyCode();

            // Cek apakah nama sudah digunakan (parameterized query)
            const existingName = await db.queryOne(
                'SELECT id FROM dataucp WHERE ucp = ?',
                [ucpName]
            );

            if (existingName) {
                return IntError(interaction,
                    "Maaf, nama akun ini sudah terdaftar.\n" +
                    "Silakan coba nama yang lain!"
                );
            }

            // Double check discord belum terdaftar
            const existingDiscord = await db.queryOne(
                'SELECT id FROM dataucp WHERE discord = ?',
                [userId]
            );

            if (existingDiscord) {
                return IntError(interaction,
                    "Akun Discord Anda sudah terdaftar.\n" +
                    "Tidak dapat membuat akun baru."
                );
            }

            // Insert akun baru (parameterized query - aman dari SQL Injection)
            await db.insert('dataucp', {
                ucp: ucpName,
                discord: userId,
                verifikasi: verifyCode,
                aktivasi: 0,
                katasandi: ''
            });

            // Buat embed untuk DM
            const msgEmbed = new MessageEmbed()
                .setAuthor({
                    name: `PENDAFTARAN AKUN UCP | ${client.config.NAMA_SERVER}`,
                    iconURL: client.config.ICON_URL
                })
                .setDescription(
                    `Selamat, **${ucpName}**! 🎉\n\n` +
                    `Akun UCP Anda berhasil didaftarkan!\n\n` +
                    `**📝 Nama UCP**\n\`${ucpName}\`\n\n` +
                    `**🔑 Kode Verifikasi**\n\`\`\`${verifyCode}\`\`\`\n\n` +
                    `**⏰ Waktu Pendaftaran**\n<t:${Math.floor(Date.now() / 1000)}:F>\n\n` +
                    `> ⚠️ Simpan kode verifikasi ini!\n` +
                    `> Gunakan di server SAMP untuk aktivasi akun.\n\n` +
                    `**${client.config.TANDA_PAGAR}**\n${client.config.MOTO_SERVER}`
                )
                .setColor("#00FF00")
                .setImage(client.config.ICON_URL1)
                .setFooter({ text: client.config.TEKS_BUATDM })
                .setTimestamp();

            // Kirim DM
            let dmSent = false;
            try {
                await interaction.user.send({ embeds: [msgEmbed] });
                dmSent = true;
            } catch (dmError) {
                console.warn(`[PENDAFTARAN] Gagal kirim DM ke ${interaction.user.tag}`);
            }

            // Log pendaftaran
            console.log(`[PENDAFTARAN] User: ${sanitizeForLog(interaction.user.tag)} | UCP: ${ucpName} | Code: ${verifyCode}`);

            // Reply sukses
            const successMsg = dmSent
                ? `> Silakan cek DM Anda untuk informasi lengkap!`
                : `> ⚠️ DM gagal terkirim. Kode Verifikasi: \`${verifyCode}\``;

            await IntSucces(interaction,
                `**DAFTAR UCP | ${client.config.NAMA_SERVER}**\n` +
                `:white_check_mark: **Berhasil!**\n\n` +
                `> Akun **${ucpName}** berhasil didaftarkan!\n` +
                successMsg + `\n\n` +
                `**${client.config.TANDA_PAGAR}**\n${client.config.MOTO_SERVER}`
            );

            // Tambah role dan ubah nickname
            try {
                const roleWarga = interaction.guild.roles.cache.get(client.config.ROLE_WARGA);
                if (roleWarga) {
                    await interaction.member.roles.add(roleWarga);
                    await interaction.member.setNickname(`WARGA | ${ucpName}`);
                }
            } catch (roleError) {
                console.warn(`[PENDAFTARAN] Gagal set role/nickname: ${roleError.message}`);
            }

        } catch (error) {
            console.error('[PENDAFTARAN] Error:', error);
            return IntError(interaction,
                "Terjadi kesalahan saat memproses pendaftaran.\n" +
                "Silakan coba lagi nanti."
            );
        }
    }
};
