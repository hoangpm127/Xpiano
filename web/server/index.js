const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
const server = http.createServer(app);

// CORS config
app.use(cors());
app.use(express.json());

// Socket.io with CORS
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// In-memory storage (production nên dùng Redis)
const onlineUsers = new Map(); // socketId -> { userId, role, peerId }
const userSockets = new Map(); // userId -> socketId

// Socket.io connection
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // User đăng nhập
  socket.on('user:online', ({ userId, role, peerId }) => {
    console.log(`User ${userId} (${role}) online with peer ID: ${peerId}`);
    
    onlineUsers.set(socket.id, { userId, role, peerId });
    userSockets.set(userId, socket.id);

    // Broadcast danh sách users online
    broadcastOnlineUsers();
  });

  // Teacher gọi Student
  socket.on('call:initiate', ({ targetUserId, callerInfo }) => {
    console.log(`Call from ${callerInfo.userId} to ${targetUserId}`);
    
    const targetSocketId = userSockets.get(targetUserId);
    if (targetSocketId) {
      io.to(targetSocketId).emit('call:incoming', {
        callerId: callerInfo.userId,
        callerName: callerInfo.name,
        callerRole: callerInfo.role,
        callerPeerId: callerInfo.peerId,
        sessionId: callerInfo.sessionId
      });
    } else {
      socket.emit('call:error', { message: 'User offline' });
    }
  });

  // Student Accept call
  socket.on('call:accept', ({ callerId, sessionId }) => {
    console.log(`Call accepted by ${onlineUsers.get(socket.id)?.userId}`);
    
    const callerSocketId = userSockets.get(callerId);
    if (callerSocketId) {
      io.to(callerSocketId).emit('call:accepted', {
        accepterId: onlineUsers.get(socket.id)?.userId,
        sessionId: sessionId
      });
    }
  });

  // Student Reject call
  socket.on('call:reject', ({ callerId }) => {
    console.log(`Call rejected by ${onlineUsers.get(socket.id)?.userId}`);
    
    const callerSocketId = userSockets.get(callerId);
    if (callerSocketId) {
      io.to(callerSocketId).emit('call:rejected', {
        rejecterId: onlineUsers.get(socket.id)?.userId
      });
    }
  });

  // End call
  socket.on('call:end', ({ targetUserId }) => {
    const targetSocketId = userSockets.get(targetUserId);
    if (targetSocketId) {
      io.to(targetSocketId).emit('call:ended');
    }
  });

  // Disconnect
  socket.on('disconnect', () => {
    const user = onlineUsers.get(socket.id);
    if (user) {
      console.log(`User ${user.userId} disconnected`);
      onlineUsers.delete(socket.id);
      userSockets.delete(user.userId);
      broadcastOnlineUsers();
    }
  });
});

// Broadcast online users
function broadcastOnlineUsers() {
  const users = Array.from(onlineUsers.values());
  io.emit('users:online', users);
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    onlineUsers: onlineUsers.size,
    timestamp: new Date().toISOString()
  });
});

const PORT = process.env.PORT || 3002;
server.listen(PORT, () => {
  console.log(`🚀 Xpiano Server running on http://localhost:${PORT}`);
  console.log(`📡 Socket.io ready for connections`);
});
