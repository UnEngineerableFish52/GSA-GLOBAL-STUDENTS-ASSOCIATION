import { v4 as uuid } from 'uuid';
import { db } from '../utils/db.js';

export function chatSocket(io, socket) {
  const userId = socket.user.id;
  
  if (process.env.NODE_ENV !== 'production') {
    console.log(`User ${userId} connected to socket`);
  }

  // Join global chat room
  socket.join('global');
  
  // Send chat history
  socket.emit('history', db.messages.filter(m => m.room === 'global'));

  // Handle global chat messages
  socket.on('message', (data) => {
    const { text } = data;
    if (!text || typeof text !== 'string') return;
    
    const message = {
      id: uuid(),
      userId,
      text,
      room: 'global',
      timestamp: new Date().toISOString(),
    };
    
    db.messages.push(message);
    io.to('global').emit('message', message);
  });

  // Join a private chat room
  socket.on('join_private', (data) => {
    const { chatId } = data;
    if (!chatId) return;
    
    const chat = db.privateChats.get(chatId);
    if (!chat || !chat.members.includes(userId)) {
      socket.emit('error', { message: 'Cannot join this chat' });
      return;
    }
    
    socket.join(`private:${chatId}`);
    socket.emit('history', chat.messages);
  });

  // Handle private chat messages
  socket.on('private_message', (data) => {
    const { chatId, text } = data;
    if (!chatId || !text || typeof text !== 'string') return;
    
    const chat = db.privateChats.get(chatId);
    if (!chat || !chat.members.includes(userId)) {
      socket.emit('error', { message: 'Cannot send to this chat' });
      return;
    }
    
    const message = {
      id: uuid(),
      userId,
      text,
      timestamp: new Date().toISOString(),
    };
    
    chat.messages.push(message);
    io.to(`private:${chatId}`).emit('private_message', { chatId, message });
  });

  // Leave a private chat room
  socket.on('leave_private', (data) => {
    const { chatId } = data;
    if (!chatId) return;
    socket.leave(`private:${chatId}`);
  });

  socket.on('disconnect', () => {
    if (process.env.NODE_ENV !== 'production') {
      console.log(`User ${userId} disconnected`);
    }
  });
}
