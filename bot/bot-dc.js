/**
 * ============================================
 * DISCORD BOT - MAIN ENTRY POINT
 * ============================================
 * Bot Discord untuk sistem UCP SAMP Server.
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

const { Client, Collection, WebhookClient, Intents } = require("discord.js");
const discordModals = require("discord-modals");
require("dotenv").config();

// ========== DATABASE ==========
require("./utils/database");

// ========== CLIENT SETUP ==========
const client = new Client({
  intents: [
    Intents.FLAGS.GUILDS,
    Intents.FLAGS.GUILD_MESSAGES,
    Intents.FLAGS.GUILD_MEMBERS,
    Intents.FLAGS.DIRECT_MESSAGES,
    Intents.FLAGS.MESSAGE_CONTENT
  ],
  partials: ['CHANNEL', 'MESSAGE']
});

module.exports = client;

// ========== LOAD HANDLERS ==========
require("./Core")(client);
discordModals(client);

// ========== COLLECTIONS ==========
client.commands = new Collection();
client.buttons = new Collection();
client.modals = new Collection();
client.config = process.env;

// ========== ERROR HANDLING ==========

/**
 * Setup error webhook jika dikonfigurasi
 */
let errorWebhook = null;
if (process.env.OWNER_ID && process.env.TOKEN_BOT) {
  try {
    errorWebhook = new WebhookClient({
      id: process.env.OWNER_ID,
      token: process.env.TOKEN_BOT
    });
  } catch (e) {
    console.warn('[BOT] Webhook error logging tidak tersedia');
  }
}

/**
 * Log error ke console dan webhook
 * @param {string} type - Tipe error
 * @param {Error} error - Error object
 */
const logError = (type, error) => {
  const timestamp = new Date().toISOString();
  console.error(`[${timestamp}] [${type}]`, error);

  if (errorWebhook) {
    const errorMsg = error.stack || error.message || String(error);
    errorWebhook.send(`\`\`\`js\n[${type}] ${errorMsg.substring(0, 1900)}\`\`\``).catch(() => { });
  }
};

// Global error handlers
process.on('unhandledRejection', (error) => logError('UNHANDLED_REJECTION', error));
process.on('uncaughtException', (error) => logError('UNCAUGHT_EXCEPTION', error));
process.on('uncaughtExceptionMonitor', (error) => logError('EXCEPTION_MONITOR', error));

// ========== GRACEFUL SHUTDOWN ==========

/**
 * Handle graceful shutdown
 * @param {string} signal - Signal yang diterima
 */
const gracefulShutdown = async (signal) => {
  console.log(`\n[BOT] Menerima ${signal}, melakukan shutdown...`);

  try {
    // Destroy client
    await client.destroy();
    console.log('[BOT] Client disconnected.');

    // Exit
    process.exit(0);
  } catch (error) {
    console.error('[BOT] Error saat shutdown:', error);
    process.exit(1);
  }
};

process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));

// ========== SHUTDOWN COMMAND ==========
client.on('messageCreate', async message => {
  if (message.author.bot) return;

  // Command untuk mematikan bot (hanya owner)
  if (message.content === `${client.config.PREFIX_BOT}sdbot`) {
    // Cek apakah sender adalah owner
    if (message.author.id !== client.config.OWNER_ID) {
      return message.reply('❌ Anda tidak memiliki izin untuk mematikan bot.');
    }

    await message.channel.send('🔄 Mematikan bot...');
    gracefulShutdown('SHUTDOWN_COMMAND');
  }
});

// ========== LOGIN ==========
console.log('[BOT] Memulai login...');

client.login(client.config.TOKEN_BOT)
  .then(() => {
    console.log('[BOT] Login berhasil!');
  })
  .catch(error => {
    console.error('[BOT] FATAL: Gagal login!');
    console.error(error.message);
    process.exit(1);
  });
