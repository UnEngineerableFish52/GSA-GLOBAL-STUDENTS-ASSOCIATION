import { v4 as uuid } from 'uuid';

export const db = {
  users: new Map(),
  questions: new Map(),
  privateChats: new Map(),
  exams: new Map(),
  messages: [],
};

export function seed() {
  const examId = 'exam1';
  db.exams.set(examId, {
    id: examId,
    title: 'Math Basics',
    grade: 8,
    questions: [
      { id: 'q1', text: '2 + 2 = ?', options: ['3', '4', '5'], answer: '4', type: 'mcq' },
      { id: 'q2', text: '5 is prime?', options: ['True', 'False'], answer: 'True', type: 'tf' }
    ],
  });
}

export function createAnonUser() {
  const id = uuid();
  const user = { id, verified: false };
  db.users.set(id, user);
  return user;
}