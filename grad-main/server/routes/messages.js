const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken } = require('../middleware/auth');

// Get messages for a specific user
router.get('/:userId', authenticateToken, async (req, res) => {
    try {
        const userId = req.params.userId;
        
        const query = `
            SELECT m.*, u.name as sender_name 
            FROM messages m
            LEFT JOIN users u ON m.sender_id = u.id
            WHERE (m.sender_id = ? OR m.receiver_id = ?)
            ORDER BY m.timestamp ASC
        `;
        
        const [messages] = await db.query(query, [userId, userId]);
        
        res.json(messages);
    } catch (error) {
        console.error('Error fetching messages:', error);
        res.status(500).json({ message: 'Error fetching messages' });
    }
});

// Send a new message
router.post('/send', authenticateToken, async (req, res) => {
    try {
        const { sender_id, receiver_id, content, is_admin, sender_name } = req.body;
        
        const query = `
            INSERT INTO messages (sender_id, receiver_id, content, is_admin, timestamp)
            VALUES (?, ?, ?, ?, NOW())
        `;
        
        const [result] = await db.query(query, [sender_id, receiver_id, content, is_admin]);
        
        const newMessage = {
            message_id: result.insertId,
            sender_id,
            receiver_id,
            content,
            is_admin,
            sender_name,
            timestamp: new Date(),
            is_read: 0
        };
        
        res.json(newMessage);
    } catch (error) {
        console.error('Error sending message:', error);
        res.status(500).json({ message: 'Error sending message' });
    }
});

// Mark messages as read
router.post('/mark-read', authenticateToken, async (req, res) => {
    try {
        const { user_id, sender_id } = req.body;
        
        const query = `
            UPDATE messages 
            SET is_read = 1 
            WHERE receiver_id = ? AND sender_id = ? AND is_read = 0
        `;
        
        await db.query(query, [user_id, sender_id]);
        
        res.json({ message: 'Messages marked as read' });
    } catch (error) {
        console.error('Error marking messages as read:', error);
        res.status(500).json({ message: 'Error marking messages as read' });
    }
});

// Delete a message
router.delete('/:messageId', authenticateToken, async (req, res) => {
    try {
        const messageId = req.params.messageId;
        
        const query = 'DELETE FROM messages WHERE message_id = ?';
        await db.query(query, [messageId]);
        
        res.json({ message: 'Message deleted successfully' });
    } catch (error) {
        console.error('Error deleting message:', error);
        res.status(500).json({ message: 'Error deleting message' });
    }
});

// Get unread message count
router.get('/unread-count/:userId', authenticateToken, async (req, res) => {
    try {
        const userId = req.params.userId;
        
        const query = `
            SELECT COUNT(*) as count 
            FROM messages 
            WHERE receiver_id = ? AND is_read = 0
        `;
        
        const [result] = await db.query(query, [userId]);
        
        res.json({ count: result[0].count });
    } catch (error) {
        console.error('Error getting unread count:', error);
        res.status(500).json({ message: 'Error getting unread count' });
    }
});

module.exports = router; 