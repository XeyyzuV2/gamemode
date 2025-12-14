/**
 * Validation Utility Module
 * Centralized input validation untuk Discord Bot
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

/**
 * Validate UCP account name
 * @param {string} name - Nama akun untuk divalidasi
 * @returns {Object} { valid: boolean, error: string|null }
 */
const validateUCPName = (name) => {
    if (!name || typeof name !== 'string') {
        return { valid: false, error: 'Nama tidak boleh kosong' };
    }

    const trimmed = name.trim();

    if (trimmed.length < 4) {
        return { valid: false, error: 'Nama minimal 4 karakter' };
    }

    if (trimmed.length > 24) {
        return { valid: false, error: 'Nama maksimal 24 karakter' };
    }

    if (trimmed.includes('_')) {
        return { valid: false, error: 'Nama tidak boleh mengandung simbol "_"' };
    }

    if (trimmed.includes(' ')) {
        return { valid: false, error: 'Nama tidak boleh mengandung spasi' };
    }

    if (!/^[a-zA-Z]+$/.test(trimmed)) {
        return { valid: false, error: 'Nama hanya boleh berisi huruf (tanpa angka/simbol)' };
    }

    return { valid: true, error: null, value: trimmed };
};

/**
 * Validate Discord User ID
 * @param {string} userId - Discord user ID
 * @returns {boolean}
 */
const isValidDiscordId = (userId) => {
    return /^\d{17,19}$/.test(userId);
};

/**
 * Sanitize string untuk logging (prevent log injection)
 * @param {string} input - Input string
 * @returns {string} Sanitized string
 */
const sanitizeForLog = (input) => {
    if (typeof input !== 'string') return String(input);
    return input.replace(/[\r\n]/g, ' ').substring(0, 100);
};

/**
 * Generate random verification code
 * @returns {number} 5-digit code
 */
const generateVerifyCode = () => {
    return Math.floor(10000 + Math.random() * 90000);
};

module.exports = {
    validateUCPName,
    isValidDiscordId,
    sanitizeForLog,
    generateVerifyCode
};
