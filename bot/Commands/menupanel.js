const { Client, CommandInteraction, MessageEmbed, MessageButton, MessageActionRow } = require("discord.js");

// Mendefinisikan modul untuk di ekspor
module.exports = {
    // Nama command
    name: "menupanel",
    // Permissions yang dibutuhkan oleh pengguna
    UserPerms: [],
    // Deskripsi command
    description: "Menampilkan Panel Pendaftaran Akun",
    /**
     * Fungsi yang akan dijalankan ketika command ini dipanggil
     * @param {Client} client - Client dari Discord.js
     * @param {CommandInteraction} interaction - Interaksi command dari pengguna
     * @param {String[]} args - Argumen tambahan yang mungkin diberikan
     */
    run: async (client, interaction, args) => {

        const allowedRoleId = client.config.ROLE_ADMIN;  // Ganti dengan ID role yang diizinkan

        // Memeriksa apakah pengguna memiliki role yang diizinkan
        const memberRoles = interaction.member.roles;
        if (!memberRoles.cache.has(allowedRoleId)) {
            return interaction.reply({ content: "Anda tidak memiliki izin untuk menjalankan perintah ini.", ephemeral: true });
        }
        
        // Mengambil ID role dari file .env
        const roleId = client.config.ROLE_WARGA;
        // Membuat embed pesan untuk ditampilkan di Discord
        const msgEmbed = new MessageEmbed()
            .setAuthor({ name: `Panel Akun ${client.config.NAMA_SERVER}`, iconURL: client.config.ICON_URL }) // Mengatur penulis embed dengan nama server dan ikon URL
            .setColor("#800000") // Mengatur warna embed
            .setDescription(`:information_source: Ucapan selamat datang di channel ini\n\n\
             『 🎫Ambil Tiket 』:information_source:\n\
             Penjelasan Tentang pengambilan tiket (pendaftaran akun UCP)\n\n\
             『 🎟Cek Tiket 』:information_source:\n\
             Penjelasan tentang informasi tiket\n\n\
             『 😕Lupa kata sandi 』:information_source:\n\
             (????)\n\n\
             『 🔰Reff Role 』:information_source:\n\
             untuk mengambil role <@&${roleId}>, makanya jangan jadi kutu loncat biar gak ilang tu role <@&${roleId}>!`)
            .setFooter({ text: `${client.config.TEKS_BUATDM}` }) // Mengatur footer embed dengan teks khusus
            .setTimestamp(); // Menambahkan timestamp saat embed dikirim

        // Membuat baris aksi yang berisi tombol-tombol
        const Buttons = new MessageActionRow()
            .addComponents(
                new MessageButton()
                    .setCustomId("tombol-pendaftaran")
                    .setLabel("Ambil Ticket")
                    .setStyle("PRIMARY")
                    .setEmoji("🎫"), // Tombol untuk mengambil tiket

                new MessageButton()
                    .setCustomId("tombol-kirimulang")
                    .setLabel("Cek Ticket")
                    .setStyle("PRIMARY")
                    .setEmoji("🎟"), // Tombol untuk mengecek tiket

                new MessageButton()
                    .setCustomId("tombol-reset")
                    .setLabel("Lupa kata sandi")
                    .setStyle("DANGER")
                    .setEmoji("😕"), // Tombol untuk mengatur ulang kata sandi

                new MessageButton()
                    .setCustomId("tombol-takerole")
                    .setLabel("Reff Role")
                    .setStyle("SECONDARY")
                    .setEmoji("🔰") // Tombol untuk mengambil role
            );

        // Mengirim pesan embed beserta tombol-tombolnya sebagai balasan interaksi
        interaction.reply({ embeds: [msgEmbed], components: [Buttons] });
    },
};
