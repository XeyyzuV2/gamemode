/**
 * Database Utility Module
 * Promise-based MySQL wrapper dengan parameterized queries
 * untuk mencegah SQL Injection
 * 
 * @author XeyyzuV2
 * @version 2.0.0
 */

const mysql = require('mysql');
const config = require('../config.json');

// Create connection pool
const pool = mysql.createPool({
    ...config.mysql,
    waitForConnections: true,
    queueLimit: 0
});

// Test connection on startup
pool.getConnection((err, connection) => {
    if (err) {
        console.error('[DATABASE] ❌ Gagal terhubung ke MySQL:', err.message);
        return;
    }
    console.log('[DATABASE] ✅ MySQL berhasil terhubung!');
    connection.release();
});

/**
 * Execute a parameterized query safely
 * @param {string} sql - SQL query dengan ? placeholders
 * @param {Array} params - Parameter untuk di-substitute
 * @returns {Promise<Array>} Query results
 * @example
 * // Safe query
 * const users = await query('SELECT * FROM users WHERE id = ?', [userId]);
 */
const query = (sql, params = []) => {
    return new Promise((resolve, reject) => {
        pool.query(sql, params, (error, results) => {
            if (error) {
                console.error('[DATABASE] Query Error:', error.message);
                reject(error);
            } else {
                resolve(results);
            }
        });
    });
};

/**
 * Get a single row from query result
 * @param {string} sql - SQL query
 * @param {Array} params - Parameters
 * @returns {Promise<Object|null>} Single row or null
 */
const queryOne = async (sql, params = []) => {
    const results = await query(sql, params);
    return results.length > 0 ? results[0] : null;
};

/**
 * Check if record exists
 * @param {string} table - Table name
 * @param {string} column - Column to check
 * @param {any} value - Value to find
 * @returns {Promise<boolean>}
 */
const exists = async (table, column, value) => {
    const sql = `SELECT 1 FROM ?? WHERE ?? = ? LIMIT 1`;
    const results = await query(sql, [table, column, value]);
    return results.length > 0;
};

/**
 * Insert a record
 * @param {string} table - Table name
 * @param {Object} data - Key-value pairs to insert
 * @returns {Promise<number>} Insert ID
 */
const insert = async (table, data) => {
    const sql = `INSERT INTO ?? SET ?`;
    const result = await query(sql, [table, data]);
    return result.insertId;
};

/**
 * Update records
 * @param {string} table - Table name
 * @param {Object} data - Data to update
 * @param {Object} where - WHERE conditions
 * @returns {Promise<number>} Affected rows
 */
const update = async (table, data, where) => {
    const whereKeys = Object.keys(where);
    const whereClause = whereKeys.map(k => `?? = ?`).join(' AND ');
    const whereParams = whereKeys.flatMap(k => [k, where[k]]);

    const sql = `UPDATE ?? SET ? WHERE ${whereClause}`;
    const result = await query(sql, [table, data, ...whereParams]);
    return result.affectedRows;
};

module.exports = {
    pool,
    query,
    queryOne,
    exists,
    insert,
    update
};
