import express from 'express';
import { authRequired } from '../middleware/auth.js';
import { requireVerified } from '../middleware/permissions.js';
import { db } from '../utils/db.js';

const router = express.Router();

// List all exams
router.get('/', authRequired, (req, res) => {
  const exams = Array.from(db.exams.values()).map(e => ({
    id: e.id,
    title: e.title,
    grade: e.grade,
    questionCount: e.questions.length,
  }));
  res.json(exams);
});

// Get exam details (without answers)
router.get('/:id', authRequired, requireVerified, (req, res) => {
  const exam = db.exams.get(req.params.id);
  if (!exam) {
    return res.status(404).json({ error: 'Exam not found' });
  }
  const examData = {
    id: exam.id,
    title: exam.title,
    grade: exam.grade,
    questions: exam.questions.map(q => ({
      id: q.id,
      text: q.text,
      options: q.options,
      type: q.type,
    })),
  };
  res.json(examData);
});

// Submit exam answers and get auto-graded results
router.post('/:id/submit', authRequired, requireVerified, (req, res) => {
  const { answers } = req.body;
  if (!answers || typeof answers !== 'object') {
    return res.status(400).json({ error: 'Answers object required' });
  }
  const exam = db.exams.get(req.params.id);
  if (!exam) {
    return res.status(404).json({ error: 'Exam not found' });
  }

  let correct = 0;
  const results = exam.questions.map(q => {
    const userAnswer = answers[q.id];
    const isCorrect = userAnswer === q.answer;
    if (isCorrect) correct++;
    return {
      questionId: q.id,
      correct: isCorrect,
      userAnswer,
      correctAnswer: q.answer,
    };
  });

  const score = Math.round((correct / exam.questions.length) * 100);
  res.json({
    score,
    correct,
    total: exam.questions.length,
    results,
  });
});

export default router;
