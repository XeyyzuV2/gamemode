/**
 * Tombol Kirim Ulang Handler
 * Mengirim ulang informasi akun UCP ke DM user
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

const { CommandInteraction, MessageEmbed } = require("discord.js");
const db = require("../../utils/database");
const client = require("../../bot-dc");
require("../../Functions");

module.exports = {
    id: "tombol-kirimulang",

    /**
     * Handle button interaction
     * @param {CommandInteraction} interaction
     */
    run: async (interaction) => {
        try {
            const userId = interaction.user.id;

            // Query dengan parameterized query (aman dari SQL Injection)
            const userData = await db.queryOne(
                'SELECT * FROM dataucp WHERE discord = ?',
                [userId]
            );

            if (!userData) {
                return IntError(interaction,
                    `:x: **Terjadi Kesalahan**\n` +
                    `Anda belum pernah mengambil tiket di server ini.\n` +
                    `Silahkan daftarkan akun Anda dengan cara ambil tiket.\n\n` +
                    `**${client.config.TANDA_PAGAR}**\n${client.config.MOTO_SERVER}`
                );
            }

            // Format status
            const getStatus = (status) => {
                return status === 1 ? '✅ Terverifikasi' : '⏳ Belum Terverifikasi';
            };

            // Buat embed dengan informasi akun
            const msgEmbed = new MessageEmbed()
                .setAuthor({
                    name: `Cek Akun | ${client.config.NAMA_SERVER}`,
                    iconURL: client.config.ICON_URL
                })
                .setDescription(
                    `:white_check_mark: **Berhasil!**\n` +
                    `Berikut adalah detail dari akun UCP Anda:\n\n` +
                    `**📝 Nama UCP**\n\`${userData.ucp}\`\n\n` +
                    `**🔑 Kode Verifikasi**\n\`${userData.verifikasi}\`\n\n` +
                    `**👤 Pemilik Akun**\n` +
                    `User ID: \`${userId}\`\n` +
                    `Username: \`${interaction.user.tag}\`\n\n` +
                    `**📊 Status**\n${getStatus(userData.aktivasi)}\n\n` +
                    `> ⚠️ **Catatan**: Jangan beritahukan informasi ini kepada siapapun!`
                )
                .setColor("#00FF00")
                .setFooter({ text: `🤖 Bot ${client.config.NAMA_SERVER}` })
                .setTimestamp();

            // Coba kirim DM
            try {
                await interaction.user.send({ embeds: [msgEmbed] });

                return IntSucces(interaction,
                    `**Cek Akun | ${client.config.NAMA_SERVER}**\n` +
                    `:white_check_mark: Berhasil!\n\n` +
                    `> Kami telah mengirimkan informasi akun ke DM Anda!\n\n` +
                    `**${client.config.TANDA_PAGAR}**\n${client.config.MOTO_SERVER}`
                );
            } catch (dmError) {
                // Gagal kirim DM
                return interaction.reply({
                    content: "```\n" +
                        "❌ Tidak dapat mengirim DM!\n\n" +
                        "Cara mengaktifkan DM:\n" +
                        "1. Buka Pengaturan Discord\n" +
                        "2. Pilih Privacy & Safety\n" +
                        "3. Aktifkan 'Allow direct messages from server members'\n" +
                        "```",
                    ephemeral: true
                });
            }

        } catch (error) {
            console.error('[KIRIM ULANG] Error:', error);
            return IntError(interaction,
                "Terjadi kesalahan sistem. Silakan coba lagi nanti.");
        }
    },
};
