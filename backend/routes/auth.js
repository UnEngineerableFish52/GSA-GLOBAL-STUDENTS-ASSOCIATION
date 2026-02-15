import express from 'express';
import jwt from 'jsonwebtoken';
import { createAnonUser } from '../utils/db.js';

const router = express.Router();

router.post('/anonymous', (req, res) => {
  const user = createAnonUser();
  const token = jwt.sign({ id: user.id, verified: user.verified }, process.env.JWT_SECRET, { expiresIn: '7d' });
  res.json({ token, user });
});

export default router;
