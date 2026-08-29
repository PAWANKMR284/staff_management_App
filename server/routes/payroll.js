const express = require('express');
const router = express.Router();
const db = require('../db');

// --- CALCULATE PAYROLL FOR ALL (Admin) ---
router.get('/calculate/:month/:year', async (req, res) => {
    const { month, year } = req.params;

    try {
        const [users] = await db.query('SELECT id, full_name, basic_salary FROM users WHERE role = "staff"');

        const payrolls = [];

        for (const user of users) {
            // Count present days
            const [attendance] = await db.query(
                'SELECT COUNT(*) as days FROM attendance WHERE user_id = ? AND MONTH(check_in) = ? AND YEAR(check_in) = ?',
                [user.id, month, year]
            );

            // Count approved leaves (unpaid for this simple logic)
            const [leaves] = await db.query(
                'SELECT COUNT(*) as days FROM leaves WHERE user_id = ? AND status = "approved" AND MONTH(start_date) = ?',
                [user.id, month]
            );

            const presentDays = attendance[0].days;
            const leaveDays = leaves[0].days;

            // Simple Calculation: Basic / 30 * presentDays
            const perDay = user.basic_salary / 30;
            const netSalary = perDay * presentDays;

            payrolls.push({
                user_id: user.id,
                full_name: user.full_name,
                basic: user.basic_salary,
                present: presentDays,
                leaves: leaveDays,
                net_salary: Math.round(netSalary),
                month,
                year
            });
        }

        res.json(payrolls);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- SAVE/APPROVE PAYROLL (Admin) ---
router.post('/approve', async (req, res) => {
    const { payrolls } = req.body;

    try {
        for (const p of payrolls) {
            await db.query(
                'INSERT INTO payroll (user_id, month, year, basic_salary, net_salary, status) VALUES (?, ?, ?, ?, ?, "paid") ON DUPLICATE KEY UPDATE net_salary = VALUES(net_salary), basic_salary = VALUES(basic_salary), status = "paid"',
                [p.user_id, parseInt(p.month), parseInt(p.year), p.basic, p.net_salary]
            );
        }
        res.json({ message: 'Success: All payslips generated and updated!' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- GET MY PAYSLIP (Staff) ---
router.get('/my-payslip/:userId/:month/:year', async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT * FROM payroll WHERE user_id = ? AND month = ? AND year = ?',
            [req.params.userId, parseInt(req.params.month), parseInt(req.params.year)]
        );
        res.json(rows[0] || null);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
