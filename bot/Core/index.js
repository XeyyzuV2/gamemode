/**
 * ============================================
 * CORE LOADER - DISCORD BOT
 * ============================================
 * Memuat semua commands, events, buttons, dan modals.
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

const { glob } = require("glob");
const { promisify } = require("util");
const { Collection } = require("discord.js");
const path = require("path");

const globPromise = promisify(glob);

/**
 * Load semua handlers
 * @param {Client} client - Discord client
 */
module.exports = async (client) => {
    // Inisialisasi collections
    client.commands = new Collection();
    client.buttons = new Collection();
    client.modals = new Collection();

    const basePath = process.cwd();

    console.log(' ');
    console.log('============================================');
    console.log('  Loading Bot Components...');
    console.log('============================================');

    // ========== LOAD COMMANDS ==========
    try {
        const commandFiles = await globPromise(`${basePath}/Commands/**/*.js`);
        let commandCount = 0;

        for (const filePath of commandFiles) {
            try {
                // Clear cache untuk hot reload
                delete require.cache[require.resolve(filePath)];

                const file = require(filePath);

                if (file.name) {
                    const directory = path.basename(path.dirname(filePath));
                    client.commands.set(file.name, { directory, ...file });
                    commandCount++;
                    console.log(`  [COMMAND] ${file.name}`);
                }
            } catch (error) {
                console.error(`  [ERROR] Gagal load command: ${filePath}`);
                console.error(`          ${error.message}`);
            }
        }

        console.log(`  Total Commands: ${commandCount}`);
    } catch (error) {
        console.error('[ERROR] Gagal load commands:', error.message);
    }

    console.log('--------------------------------------------');

    // ========== LOAD EVENTS ==========
    try {
        const eventFiles = await globPromise(`${basePath}/Events/*.js`);
        let eventCount = 0;

        for (const filePath of eventFiles) {
            try {
                delete require.cache[require.resolve(filePath)];
                require(filePath);
                eventCount++;
                console.log(`  [EVENT] ${path.basename(filePath, '.js')}`);
            } catch (error) {
                console.error(`  [ERROR] Gagal load event: ${filePath}`);
                console.error(`          ${error.message}`);
            }
        }

        console.log(`  Total Events: ${eventCount}`);
    } catch (error) {
        console.error('[ERROR] Gagal load events:', error.message);
    }

    console.log('--------------------------------------------');

    // ========== LOAD BUTTONS ==========
    try {
        const buttonFiles = await globPromise(`${basePath}/Tombol/**/*.js`);
        let buttonCount = 0;

        for (const filePath of buttonFiles) {
            try {
                delete require.cache[require.resolve(filePath)];
                const file = require(filePath);

                if (file.id) {
                    client.buttons.set(file.id, file);
                    buttonCount++;
                    console.log(`  [BUTTON] ${file.id}`);
                }
            } catch (error) {
                console.error(`  [ERROR] Gagal load button: ${filePath}`);
                console.error(`          ${error.message}`);
            }
        }

        console.log(`  Total Buttons: ${buttonCount}`);
    } catch (error) {
        console.error('[ERROR] Gagal load buttons:', error.message);
    }

    console.log('--------------------------------------------');

    // ========== LOAD MODALS ==========
    try {
        const modalFiles = await globPromise(`${basePath}/Modals/*.js`);
        let modalCount = 0;

        for (const filePath of modalFiles) {
            try {
                delete require.cache[require.resolve(filePath)];
                const file = require(filePath);

                if (file.id) {
                    client.modals.set(file.id, file);
                    modalCount++;
                    console.log(`  [MODAL] ${file.id}`);
                }
            } catch (error) {
                console.error(`  [ERROR] Gagal load modal: ${filePath}`);
                console.error(`          ${error.message}`);
            }
        }

        console.log(`  Total Modals: ${modalCount}`);
    } catch (error) {
        console.error('[ERROR] Gagal load modals:', error.message);
    }

    console.log('============================================');
    console.log('  Bot Components Loaded Successfully!');
    console.log('============================================');
    console.log(' ');
};
