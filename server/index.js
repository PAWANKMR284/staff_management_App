const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
require('dotenv').config();
const db = require('./db');

const app = express();

// --- SECURITY: Rate Limiting ---
// 1. General limiter for all requests (100 per 15 mins)
const generalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    message: { message: 'Too many requests, please try again later.' }
});

// 2. Strict limiter for Auth (Login/Signup) - 5 attempts per 15 mins
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 5,
    message: { message: 'Too many login attempts. Please wait 15 minutes.' },
    standardHeaders: true,
    legacyHeaders: false,
});

// Middleware
app.use(cors());
app.use(express.json());
app.use('/api/', generalLimiter); // Apply to all API calls
app.use('/api/auth/login', authLimiter); // Extra strict for login
app.use('/api/auth/register', authLimiter); // Extra strict for signup

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/leave', require('./routes/leave'));
app.use('/api/attendance', require('./routes/attendance'));
app.use('/api/payroll', require('./routes/payroll'));
app.use('/api/reports', require('./routes/reports'));

// Basic Route for testing
app.get('/', (req, res) => {
    res.send('ShiftMark Server is running...');
});

// Test Database Connection Route
app.get('/test-db', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT 1 + 1 AS result');
        res.json({ message: 'Database Connected Successfully!', result: rows });
    } catch (err) {
        res.status(500).json({ error: 'Database Connection Failed', details: err.message });
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
