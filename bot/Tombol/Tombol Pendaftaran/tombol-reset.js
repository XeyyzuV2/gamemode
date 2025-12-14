/**
 * Tombol Reset Password Handler
 * Reset password akun UCP dan kirim kode pemulihan
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

const { CommandInteraction, MessageEmbed } = require("discord.js");
const db = require("../../utils/database");
const client = require("../../bot-dc");
const { IntSucces, IntError } = require("../../Functions");

module.exports = {
    id: "tombol-reset",

    /**
     * Handle button interaction
     * @param {CommandInteraction} interaction
     */
    run: async (interaction) => {
        try {
            const userId = interaction.user.id;

            // Cek apakah user terdaftar (parameterized query)
            const userData = await db.queryOne(
                'SELECT * FROM dataucp WHERE discord = ?',
                [userId]
            );

            if (!userData) {
                return IntError(interaction,
                    `:x: **Terjadi Kesalahan**\n` +
                    `Anda belum pernah mengambil tiket di server ini.\n` +
                    `Silahkan daftarkan akun Anda terlebih dahulu.\n\n` +
                    `**${client.config.TANDA_PAGAR}**\n${client.config.MOTO_SERVER}`
                );
            }

            // Reset password di database (parameterized query)
            await db.query(
                'UPDATE dataucp SET katasandi = ?, aktivasi = 0 WHERE discord = ?',
                ['', userId]
            );

            // Buat embed pemulihan
            const msgEmbed = new MessageEmbed()
                .setAuthor({
                    name: `Pemulihan Akun | ${client.config.NAMA_SERVER}`,
                    iconURL: client.config.ICON_URL
                })
                .setDescription(
                    `⚠️ **Peringatan!**\n\n` +
                    `Anda telah meminta reset password.\n` +
                    `Jika ini bukan permintaan Anda, abaikan pesan ini!\n\n` +
                    `**📝 Nama UCP**\n\`${userData.ucp}\`\n\n` +
                    `**🔑 Kode Pemulihan**\n\`\`\`${userData.verifikasi}\`\`\`\n\n` +
                    `> Masuk ke server SAMP dan gunakan kode ini untuk membuat password baru!\n\n` +
                    `**${client.config.TANDA_PAGAR}**\n${client.config.MOTO_SERVER}`
                )
                .setColor("#FFA500")
                .setFooter({ text: `🤖 Bot ${client.config.NAMA_SERVER}` })
                .setTimestamp();

            // Kirim sebagai ephemeral reply (hanya user yang bisa lihat)
            await interaction.reply({
                embeds: [msgEmbed],
                ephemeral: true
            });

            console.log(`[RESET] User ${interaction.user.tag} reset password untuk UCP: ${userData.ucp}`);

        } catch (error) {
            console.error('[RESET] Error:', error);
            return IntError(interaction,
                "Terjadi kesalahan sistem. Silakan coba lagi nanti.");
        }
    },
};
