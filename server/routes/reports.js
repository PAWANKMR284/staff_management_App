const express = require('express');
const router = express.Router();
const db = require('../db');
const auth = require('../middleware/auth');

// --- GET ATTENDANCE TRENDS (Admin) ---
router.get('/attendance-trends', auth, async (req, res) => {
    if (req.user.role !== 'admin') return res.status(403).json({ message: 'Admin access required' });
    try {
        // Calculate attendance rate for the last 4 weeks
        const trends = [];
        const [totalStaff] = await db.query('SELECT COUNT(*) as count FROM users WHERE role = "staff"');
        const staffCount = totalStaff[0].count || 1;

        for (let i = 3; i >= 0; i--) {
            const [rows] = await db.query(
                `SELECT COUNT(*) as count FROM attendance
                 WHERE check_in >= DATE_SUB(CURDATE(), INTERVAL ? WEEK)
                 AND check_in < DATE_SUB(CURDATE(), INTERVAL ? WEEK)`,
                [i + 1, i]
            );

            // Percentage: (Total Check-ins / (Staff Count * 6 days)) * 100
            const percentage = Math.min(100, Math.round((rows[0].count / (staffCount * 6)) * 100));
            trends.push({ week: `W${4 - i}`, rate: percentage });
        }

        const [avgRows] = await db.query(
            'SELECT COUNT(*) as count FROM attendance WHERE MONTH(check_in) = MONTH(CURDATE())'
        );
        const avgPresent = Math.min(100, Math.round((avgRows[0].count / (staffCount * 26)) * 100));

        res.json({ trends, avgPresent });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
