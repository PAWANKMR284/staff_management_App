const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');

const auth = require('../middleware/auth');

// --- GET ME (Protected) ---
router.get('/me', auth, async (req, res) => {
    try {
        const [users] = await db.query('SELECT id, full_name, email, role, join_date, status FROM users WHERE id = ?', [req.user.id]);
        if (users.length === 0) return res.status(404).json({ message: 'User not found' });
        res.json(users[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- REGISTER API ---
router.post('/register', async (req, res) => {
    const { full_name, email, password, role, basic_salary } = req.body;

    try {
        // Basic Input Validation
        if (!email.includes('@') || password.length < 6) {
            return res.status(400).json({ message: 'Invalid email or password (min 6 chars)' });
        }

        const [existing] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (existing.length > 0) return res.status(400).json({ message: 'Email already exists' });

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Security: If first user, make admin, otherwise only staff
        // Or if you want admin to add members, we can keep the role but add a 'creation guard'
        // For now, let's keep role but ensure it's validated
        const userRole = (role === 'admin') ? 'admin' : 'staff';

        await db.query(
            'INSERT INTO users (full_name, email, password, role, basic_salary, status) VALUES (?, ?, ?, ?, ?, "active")',
            [full_name, email, hashedPassword, userRole, basic_salary || 30000]
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
        const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) return res.status(400).json({ message: 'User not found' });

        const user = users[0];

        // Check Account Status
        if (user.status === 'inactive') {
            return res.status(403).json({ message: 'Account is disabled. Contact Admin.' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

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
