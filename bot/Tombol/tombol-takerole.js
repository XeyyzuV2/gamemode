/**
 * Tombol Take Role Handler
 * Memberikan role Warga kepada user yang sudah terdaftar
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

require("dotenv").config();
const { CommandInteraction } = require("discord.js");
const db = require("../utils/database");
const client = require("../bot-dc");
const { IntSucces, IntError } = require("../Functions");

module.exports = {
    id: "tombol-takerole",

    /**
     * Handle button interaction
     * @param {CommandInteraction} interaction
     */
    run: async (interaction) => {
        try {
            const userId = interaction.user.id;
            const roleId = process.env.ROLE_WARGA;

            // Validasi role ID
            if (!roleId) {
                console.error('[TAKEROLE] ROLE_WARGA tidak dikonfigurasi di .env');
                return interaction.reply({
                    content: `:x: **Kesalahan Konfigurasi**\nRole belum dikonfigurasi. Hubungi admin.`,
                    ephemeral: true
                });
            }

            // Cek apakah user terdaftar (parameterized query - aman dari SQL Injection)
            const userData = await db.queryOne(
                'SELECT id, ucp, aktivasi FROM dataucp WHERE discord = ?',
                [userId]
            );

            if (!userData) {
                return interaction.reply({
                    content: `:x: **Terjadi Kesalahan**\n` +
                        `Anda belum pernah mendaftar di server ini.\n` +
                        `Silakan ambil tiket terlebih dahulu!`,
                    ephemeral: true
                });
            }

            // Cek apakah role ada di server
            const role = interaction.guild.roles.cache.get(roleId);
            if (!role) {
                console.error(`[TAKEROLE] Role ${roleId} tidak ditemukan di server`);
                return interaction.reply({
                    content: `:x: **Kesalahan Konfigurasi**\nRole tidak ditemukan. Hubungi admin.`,
                    ephemeral: true
                });
            }

            // Cek apakah user sudah punya role
            if (interaction.member.roles.cache.has(roleId)) {
                return interaction.reply({
                    content: `ℹ️ Anda sudah memiliki role **${role.name}**!`,
                    ephemeral: true
                });
            }

            // Tambahkan role
            await interaction.member.roles.add(role);

            console.log(`[TAKEROLE] ${interaction.user.tag} mendapat role ${role.name}`);

            return interaction.reply({
                content: `**✅ PENGAMBILAN ROLE BERHASIL!**\n\n` +
                    `Akun Discord Anda berhasil diverifikasi sebagai pemain.\n` +
                    `Role: **${role.name}**\n\n` +
                    `> Mohon untuk tidak keluar dari Discord ini!`,
                ephemeral: true
            });

        } catch (error) {
            console.error('[TAKEROLE] Error:', error);

            if (error.code === 50013) {
                return interaction.reply({
                    content: `:x: **Kesalahan Permission**\nBot tidak memiliki izin untuk memberikan role.`,
                    ephemeral: true
                });
            }

            return interaction.reply({
                content: `:x: **Terjadi Kesalahan**\nSilakan coba lagi nanti.`,
                ephemeral: true
            });
        }
    }
};
