require('dotenv').config();
const express = require('express');
const cors = require('cors');
const HMS = require('@100mslive/server-sdk');

const app = express();
app.use(cors());
app.use(express.json());

// Initialize 100ms SDK with credentials from .env
const hms = new HMS.SDK(process.env.HMS_ACCESS_KEY, process.env.HMS_SECRET);

// Endpoint for Trainer to create a 100ms Room on Approval
app.post('/create-room', async (req, res) => {
    try {
        const room = await hms.rooms.create({
            name: `session-${Date.now()}`,
            description: 'Trainer Session',
            region: 'in', // adjust based on your location
        });
        res.json({ roomId: room.id });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Endpoint for peers to get their Auth Token before joining
app.get('/token', async (req, res) => {
    const { roomId, userId, role } = req.query;
    try {
        const token = await hms.auth.getAuthToken({ roomId, userId, role });
        res.json({ token });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`100ms Token Server running on port ${PORT}`));