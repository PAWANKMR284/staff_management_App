const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');

// --- REGISTER API ---
router.post('/register', async (req, res) => {
    const { full_name, email, password, role, basic_salary } = req.body;

    try {
        // Check if user exists
        const [existing] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (existing.length > 0) return res.status(400).json({ message: 'Email already exists' });

        // Hash Password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Save User
        await db.query(
            'INSERT INTO users (full_name, email, password, role, basic_salary) VALUES (?, ?, ?, ?, ?)',
            [full_name, email, hashedPassword, role || 'staff', basic_salary || 30000]
        );

        res.status(201).json({ message: 'User registered successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- LOGIN API ---
router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        // Find User
        const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) return res.status(400).json({ message: 'User not found' });

        const user = users[0];

        // Check Password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

        // Create JWT Token
        const token = jwt.sign(
            { id: user.id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        res.json({
            token,
            user: {
                id: user.id,
                full_name: user.full_name,
                email: user.email,
                role: user.role
            }
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- GET TEAM STATS ---
router.get('/stats', async (req, res) => {
    try {
        const [all] = await db.query('SELECT COUNT(*) as total FROM users');
        const [staff] = await db.query('SELECT COUNT(*) as total FROM users WHERE role = "staff"');
        const [admin] = await db.query('SELECT COUNT(*) as total FROM users WHERE role = "admin"');

        res.json({
            total: all[0].total,
            staff: staff[0].total,
            admin: admin[0].total
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- GET ALL MEMBERS ---
router.get('/members', async (req, res) => {
    try {
        const [members] = await db.query('SELECT id, full_name, email, role, join_date FROM users ORDER BY join_date DESC');
        res.json(members);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
