import express from 'express';
import http from 'http';
import { Server as SocketIOServer } from 'socket.io';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import authRoutes from './routes/auth.js';
import questionRoutes from './routes/questions.js';
import examRoutes from './routes/exams.js';
import privateRoutes from './routes/privateChats.js';
import { authSocketMiddleware } from './middleware/auth.js';
import { chatSocket } from './socket/chatSocket.js';
import { seed } from './utils/db.js';

dotenv.config();
seed();

const app = express();
const PORT = process.env.PORT || 3000;
const SOCKET_PORT = process.env.SOCKET_PORT || PORT;

const allowedOrigins = (process.env.ALLOWED_ORIGINS || '').split(',').filter(Boolean);
app.use(cors({ origin: allowedOrigins.length ? allowedOrigins : '*', credentials: true }));
app.use(helmet());
app.use(express.json());
app.use(morgan('dev'));

app.get('/api/health', (_, res) => res.json({ status: 'ok' }));
app.use('/api/auth', authRoutes);
app.use('/api/questions', questionRoutes);
app.use('/api/exams', examRoutes);
app.use('/api/private-chats', privateRoutes);

const httpServer = http.createServer(app);
const io = new SocketIOServer(httpServer, {
  cors: { origin: allowedOrigins.length ? allowedOrigins : '*', credentials: true },
});

io.use(authSocketMiddleware);
io.on('connection', (socket) => chatSocket(io, socket));

httpServer.listen(SOCKET_PORT, () => {
  console.log(`API/Socket running on ${SOCKET_PORT}`);
});