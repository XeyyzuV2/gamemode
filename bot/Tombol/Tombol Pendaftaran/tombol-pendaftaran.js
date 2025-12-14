/**
 * Tombol Pendaftaran Handler
 * Menampilkan modal untuk pendaftaran akun UCP baru
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

const { CommandInteraction, Client } = require("discord.js");
const { Modal, TextInputComponent, showModal } = require("discord-modals");
const ms = require("ms");
const db = require("../../utils/database");
const { isValidDiscordId } = require("../../utils/validation");
require("../../Functions");

const MINIMUM_ACCOUNT_AGE = ms("0 days"); // Umur akun minimum

module.exports = {
    id: "tombol-pendaftaran",

    /**
     * Handle button interaction
     * @param {CommandInteraction} interaction
     * @param {Client} client
     */
    run: async (interaction, client) => {
        try {
            const userId = interaction.user.id;
            const accountCreatedAt = new Date(interaction.user.createdAt).getTime();
            const accountAge = Date.now() - accountCreatedAt;

            // Validasi umur akun
            if (accountAge < MINIMUM_ACCOUNT_AGE) {
                return IntError(interaction,
                    "Umur akun Discord Anda tidak mencukupi untuk mendaftar di server ini!");
            }

            // Cek apakah sudah terdaftar (menggunakan parameterized query)
            const existingUser = await db.queryOne(
                'SELECT id, ucp FROM dataucp WHERE discord = ?',
                [userId]
            );

            if (existingUser) {
                return IntError(interaction,
                    `**Pendaftaran Akun | ${client.config.NAMA_SERVER}**\n` +
                    `:x: Terjadi Kesalahan!\n\n` +
                    `> Akun Discord ini sudah terdaftar dengan UCP: **${existingUser.ucp}**\n` +
                    `> Tidak dapat mengambil tiket lagi.\n\n` +
                    `**${client.config.TANDA_PAGAR}**\n${client.config.MOTO_SERVER}`
                );
            }

            // Tampilkan modal pendaftaran
            const modalRegister = new Modal()
                .setCustomId("tampilan-pendaftaran")
                .setTitle("Pendaftaran Akun UCP")
                .addComponents(
                    new TextInputComponent()
                        .setCustomId("reg-name")
                        .setLabel("Isi Nama UCP Anda Di Bawah Ini")
                        .setMinLength(4)
                        .setMaxLength(24)
                        .setStyle("SHORT")
                        .setPlaceholder("Nama User Control Panel Anda (huruf saja)")
                        .setRequired(true)
                );

            showModal(modalRegister, {
                client: client,
                interaction: interaction
            });

        } catch (error) {
            console.error('[PENDAFTARAN] Error:', error);
            return IntError(interaction,
                "Terjadi kesalahan sistem. Silakan coba lagi nanti.");
        }
    },
};
