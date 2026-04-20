import express from 'express';
import { v4 as uuid } from 'uuid';
import { authRequired } from '../middleware/auth.js';
import { requireVerified } from '../middleware/permissions.js';
import { db } from '../utils/db.js';

const router = express.Router();

// List all questions
router.get('/', authRequired, (req, res) => {
  const questions = Array.from(db.questions.values()).map(q => ({
    id: q.id,
    text: q.text,
    userId: q.userId,
    createdAt: q.createdAt,
    replies: q.replies.length,
  }));
  res.json(questions);
});

// Create a question
router.post('/', authRequired, requireVerified, (req, res) => {
  const { text } = req.body;
  if (!text || typeof text !== 'string') {
    return res.status(400).json({ error: 'Text required' });
  }
  const id = uuid();
  const question = {
    id,
    text,
    userId: req.user.id,
    createdAt: new Date().toISOString(),
    replies: [],
  };
  db.questions.set(id, question);
  res.status(201).json(question);
});

// Get a specific question with replies
router.get('/:id', authRequired, (req, res) => {
  const question = db.questions.get(req.params.id);
  if (!question) {
    return res.status(404).json({ error: 'Question not found' });
  }
  res.json(question);
});

// Reply to a question
router.post('/:id/reply', authRequired, requireVerified, (req, res) => {
  const { text } = req.body;
  if (!text || typeof text !== 'string') {
    return res.status(400).json({ error: 'Text required' });
  }
  const question = db.questions.get(req.params.id);
  if (!question) {
    return res.status(404).json({ error: 'Question not found' });
  }
  const reply = {
    id: uuid(),
    text,
    userId: req.user.id,
    createdAt: new Date().toISOString(),
  };
  question.replies.push(reply);
  res.status(201).json(reply);
});

export default router;
