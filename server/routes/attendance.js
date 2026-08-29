const express = require('express');
const router = express.Router();
const db = require('../db');

// --- CHECK-IN API ---
router.post('/check-in', async (req, res) => {
    const { user_id, latitude, longitude, type } = req.body;
    const now = new Date();

    try {
        // Check if already checked in today
        const [existing] = await db.query(
            'SELECT * FROM attendance WHERE user_id = ? AND DATE(check_in) = CURDATE()',
            [user_id]
        );
        if (existing.length > 0) return res.status(400).json({ message: 'Already checked in today' });

        // Determine status (On Time if before 9:15 AM)
        const isLate = now.getHours() > 9 || (now.getHours() === 9 && now.getMinutes() > 15);
        const status = isLate ? 'late' : 'on_time';

        await db.query(
            'INSERT INTO attendance (user_id, check_in, latitude, longitude, type, status) VALUES (?, NOW(), ?, ?, ?, ?)',
            [user_id, latitude, longitude, type || 'office', status]
        );

        res.status(201).json({ message: 'Check-in successful', status });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- CHECK-OUT API ---
router.post('/check-out', async (req, res) => {
    const { user_id } = req.body;

    try {
        const [record] = await db.query(
            'SELECT id FROM attendance WHERE user_id = ? AND DATE(check_in) = CURDATE() AND check_out IS NULL',
            [user_id]
        );

        if (record.length === 0) return res.status(400).json({ message: 'No active check-in found for today' });

        await db.query('UPDATE attendance SET check_out = NOW() WHERE id = ?', [record[0].id]);
        res.json({ message: 'Check-out successful' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- GET TODAY'S STATUS ---
router.get('/status/:userId', async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT * FROM attendance WHERE user_id = ? AND DATE(check_in) = CURDATE()',
            [req.params.userId]
        );
        res.json(rows[0] || null);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
