import express from 'express';
import { v4 as uuid } from 'uuid';
import { authRequired } from '../middleware/auth.js';
import { requireVerified } from '../middleware/permissions.js';
import { db } from '../utils/db.js';

const router = express.Router();

// List all private chats for the current user
router.get('/', authRequired, (req, res) => {
  const userChats = Array.from(db.privateChats.values())
    .filter(chat => chat.members.includes(req.user.id))
    .map(chat => ({
      id: chat.id,
      name: chat.name,
      members: chat.members,
      createdAt: chat.createdAt,
      messageCount: chat.messages.length,
    }));
  res.json(userChats);
});

// Create a new private chat
router.post('/', authRequired, requireVerified, (req, res) => {
  const { name, members } = req.body;
  if (!name || typeof name !== 'string') {
    return res.status(400).json({ error: 'Chat name required' });
  }
  if (!Array.isArray(members) || members.length === 0) {
    return res.status(400).json({ error: 'Members array required' });
  }
  
  // Ensure current user is in members
  const allMembers = [...new Set([req.user.id, ...members])];
  
  const id = uuid();
  const chat = {
    id,
    name,
    members: allMembers,
    createdAt: new Date().toISOString(),
    messages: [],
  };
  db.privateChats.set(id, chat);
  res.status(201).json(chat);
});

// Get messages from a specific private chat
router.get('/:id/messages', authRequired, (req, res) => {
  const chat = db.privateChats.get(req.params.id);
  if (!chat) {
    return res.status(404).json({ error: 'Chat not found' });
  }
  if (!chat.members.includes(req.user.id)) {
    return res.status(403).json({ error: 'Not a member of this chat' });
  }
  res.json({ messages: chat.messages });
});

// Join an existing private chat
router.post('/:id/join', authRequired, requireVerified, (req, res) => {
  const chat = db.privateChats.get(req.params.id);
  if (!chat) {
    return res.status(404).json({ error: 'Chat not found' });
  }
  if (chat.members.includes(req.user.id)) {
    return res.status(400).json({ error: 'Already a member' });
  }
  chat.members.push(req.user.id);
  res.json(chat);
});

export default router;
