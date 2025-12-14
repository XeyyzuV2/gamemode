/**
 * Functions Module
 * Helper functions untuk Discord Bot embed messages
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

const { MessageEmbed } = require("discord.js");

// ============================================
// MESSAGE REPLY FUNCTIONS
// ============================================

/**
 * Send success message reply
 * @param {Message} message - Discord message object
 * @param {string} content - Message content
 * @returns {Promise<Message>}
 */
const MsgSucces = async (message, content) => {
    const embed = new MessageEmbed()
        .setDescription(content)
        .setColor("#00FF00");
    return message.reply({ embeds: [embed] });
};

/**
 * Send error message reply
 * @param {Message} message - Discord message object
 * @param {string} content - Error message content
 * @returns {Promise<Message>}
 */
const MsgError = async (message, content) => {
    const embed = new MessageEmbed()
        .setDescription(content)
        .setColor("#FF0000");
    return message.reply({ embeds: [embed] });
};

/**
 * Send usage/info message reply
 * @param {Message} message - Discord message object
 * @param {string} content - Usage information
 * @returns {Promise<Message>}
 */
const MsgUsage = async (message, content) => {
    const embed = new MessageEmbed()
        .setDescription(content)
        .setColor("#FFFF00");
    return message.reply({ embeds: [embed] });
};

// ============================================
// INTERACTION REPLY FUNCTIONS
// ============================================

/**
 * Send success interaction reply (ephemeral)
 * @param {Interaction} interaction - Discord interaction object
 * @param {string} content - Success message
 * @returns {Promise<void>}
 */
const IntSucces = async (interaction, content) => {
    try {
        const embed = new MessageEmbed()
            .setDescription(content)
            .setColor("#00FF00");

        // Check if already replied/deferred
        if (interaction.replied || interaction.deferred) {
            return await interaction.followUp({ embeds: [embed], ephemeral: true });
        }
        return await interaction.reply({ embeds: [embed], ephemeral: true });
    } catch (error) {
        console.error('[Functions] IntSucces error:', error.message);
    }
};

/**
 * Send error interaction reply (ephemeral)
 * @param {Interaction} interaction - Discord interaction object
 * @param {string} content - Error message
 * @returns {Promise<void>}
 */
const IntError = async (interaction, content) => {
    try {
        const embed = new MessageEmbed()
            .setDescription(content)
            .setColor("#FF0000");

        if (interaction.replied || interaction.deferred) {
            return await interaction.followUp({ embeds: [embed], ephemeral: true });
        }
        return await interaction.reply({ embeds: [embed], ephemeral: true });
    } catch (error) {
        console.error('[Functions] IntError error:', error.message);
    }
};

/**
 * Send usage/info interaction reply (ephemeral)
 * @param {Interaction} interaction - Discord interaction object
 * @param {string} content - Usage information
 * @returns {Promise<void>}
 */
const IntUsage = async (interaction, content) => {
    try {
        const embed = new MessageEmbed()
            .setDescription(content)
            .setColor("#FFFF00");

        if (interaction.replied || interaction.deferred) {
            return await interaction.followUp({ embeds: [embed], ephemeral: true });
        }
        return await interaction.reply({ embeds: [embed], ephemeral: true });
    } catch (error) {
        console.error('[Functions] IntUsage error:', error.message);
    }
};

/**
 * Send admin interaction reply (public)
 * @param {Interaction} interaction - Discord interaction object
 * @param {string} content - Admin message
 * @returns {Promise<void>}
 */
const IntAdmin = async (interaction, content) => {
    try {
        const embed = new MessageEmbed()
            .setDescription(content)
            .setColor("#800000");

        if (interaction.replied || interaction.deferred) {
            return await interaction.followUp({ embeds: [embed], ephemeral: false });
        }
        return await interaction.reply({ embeds: [embed], ephemeral: false });
    } catch (error) {
        console.error('[Functions] IntAdmin error:', error.message);
    }
};

/**
 * Send permission denied interaction reply
 * @param {Interaction} interaction - Discord interaction object
 * @returns {Promise<void>}
 */
const IntPerms = async (interaction) => {
    try {
        const embed = new MessageEmbed()
            .setDescription(`❌ Maaf! Anda tidak memiliki izin untuk menggunakan perintah ini!`)
            .setColor("#FF0000");

        if (interaction.replied || interaction.deferred) {
            return await interaction.followUp({ embeds: [embed], ephemeral: true });
        }
        return await interaction.reply({ embeds: [embed], ephemeral: true });
    } catch (error) {
        console.error('[Functions] IntPerms error:', error.message);
    }
};

// ============================================
// EXPORTS
// ============================================

// Export as module (proper way)
module.exports = {
    MsgSucces,
    MsgError,
    MsgUsage,
    IntSucces,
    IntError,
    IntUsage,
    IntAdmin,
    IntPerms
};

// Also set as globals for backward compatibility
// (akan dihapus di versi mendatang)
global.MsgSucces = MsgSucces;
global.MsgError = MsgError;
global.MsgUsage = MsgUsage;
global.IntSucces = IntSucces;
global.IntError = IntError;
global.IntUsage = IntUsage;
global.IntAdmin = IntAdmin;
global.IntPerms = IntPerms;