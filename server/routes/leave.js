const express = require('express');
const router = express.Router();
const db = require('../db');

// --- APPLY FOR LEAVE (Staff) ---
router.post('/apply', async (req, res) => {
    const { user_id, leave_type, start_date, end_date, reason } = req.body;

    try {
        await db.query(
            'INSERT INTO leaves (user_id, leave_type, start_date, end_date, reason, status) VALUES (?, ?, ?, ?, ?, "pending")',
            [user_id, leave_type, start_date, end_date, reason]
        );
        res.status(201).json({ message: 'Leave request submitted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- GET MY LEAVES (Staff) ---
router.get('/my-leaves/:userId', async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT * FROM leaves WHERE user_id = ? ORDER BY start_date DESC',
            [req.params.userId]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- GET ALL PENDING LEAVES (Admin) ---
router.get('/admin/pending', async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT l.*, u.full_name FROM leaves l JOIN users u ON l.user_id = u.id WHERE l.status = "pending" ORDER BY l.start_date ASC'
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- UPDATE LEAVE STATUS (Admin) ---
router.put('/update-status', async (req, res) => {
    const { leave_id, status } = req.body; // status: 'approved' or 'rejected'

    try {
        await db.query('UPDATE leaves SET status = ? WHERE id = ?', [status, leave_id]);
        res.json({ message: `Leave ${status} successfully` });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
