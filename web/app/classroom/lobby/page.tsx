"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Video, MessageSquare, User, LogOut, Phone } from "lucide-react";
import { useSocket } from "@/contexts/SocketContext";

interface UserAccount {
  username: string;
  role: "teacher" | "student";
  name: string;
  avatar: string;
}

export default function LobbyPage() {
  const router = useRouter();
  const { socket, onlineUsers } = useSocket();
  const [user, setUser] = useState<UserAccount | null>(null);
  const [showIncomingCall, setShowIncomingCall] = useState(false);
  const [incomingCallData, setIncomingCallData] = useState<any>(null);

  useEffect(() => {
    // Check if user is logged in
    const userData = sessionStorage.getItem("xpiano-user");
    if (!userData) {
      router.push("/login");
      return;
    }
    setUser(JSON.parse(userData));

    // Listen for incoming calls
    if (socket) {
      socket.on('call:incoming', (data) => {
        console.log('Incoming call from:', data);
        setIncomingCallData(data);
        setShowIncomingCall(true);
      });

      socket.on('call:accepted', (data) => {
        console.log('Call accepted by:', data);
        // Navigate to classroom
        const sessionId = data.sessionId;
        const currentUser = JSON.parse(sessionStorage.getItem("xpiano-user") || "{}");
        if (currentUser.role === "teacher") {
          router.push(`/classroom/teacher/${sessionId}`);
        } else {
          router.push(`/classroom/student/${sessionId}`);
        }
      });

      socket.on('call:rejected', () => {
        alert('😔 Cuộc gọi bị từ chối');
      });
    }

    return () => {
      if (socket) {
        socket.off('call:incoming');
        socket.off('call:accepted');
        socket.off('call:rejected');
      }
    };
  }, [router, socket]);

  const startVideoCall = () => {
    if (!user || !socket) return;
    
    // Fixed session ID
    const sessionId = "demo-session-001";
    
    // If teacher, initiate call to student
    if (user.role === "teacher") {
      const targetUserId = "student"; // Hardcoded student username
      
      socket.emit('call:initiate', {
        targetUserId,
        callerInfo: {
          userId: user.username,
          name: user.name,
          role: user.role,
          peerId: null, // Will be set in classroom
          sessionId
        }
      });

      alert('📞 Đang gọi học viên...');
    } else {
      // Student shouldn't call, only receive
      alert('⚠️ Chỉ giáo viên mới có thể gọi!');
    }
  };

  const acceptCall = () => {
    if (!socket || !incomingCallData) return;
    
    socket.emit('call:accept', {
      callerId: incomingCallData.callerId,
      sessionId: incomingCallData.sessionId
    });

    // Navigate to classroom
    setShowIncomingCall(false);
    router.push(`/classroom/student/${incomingCallData.sessionId}`);
  };

  const rejectCall = () => {
    if (!socket || !incomingCallData) return;
    
    socket.emit('call:reject', {
      callerId: incomingCallData.callerId
    });

    setShowIncomingCall(false);
    setIncomingCallData(null);
  };

  const logout = () => {
    sessionStorage.removeItem("xpiano-user");
    router.push("/login");
  };

  if (!user) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-white">Đang tải...</div>
      </div>
    );
  }

  const partner = user.role === "teacher" 
    ? { name: "Trần Thị Trò", avatar: "🎓", role: "Học viên" }
    : { name: "Nguyễn Văn Thầy", avatar: "👨‍🏫", role: "Giáo viên" };

  return (
    <main className="min-h-screen bg-gray-900">
      {/* Header */}
      <div className="bg-gray-800 border-b border-gray-700 px-4 py-4">
        <div className="container mx-auto flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="text-4xl">{user.avatar}</div>
            <div>
              <h2 className="text-white font-semibold text-lg">{user.name}</h2>
              <p className="text-gray-400 text-sm">
                {user.role === "teacher" ? "👨‍🏫 Giáo viên" : "🎓 Học viên"}
              </p>
            </div>
          </div>
          <button
            onClick={logout}
            className="text-gray-400 hover:text-white px-4 py-2 rounded-lg hover:bg-gray-700 transition flex items-center gap-2"
          >
            <LogOut className="w-4 h-4" />
            Đăng xuất
          </button>
        </div>
      </div>

      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          {/* Welcome */}
          <div className="text-center mb-12">
            <h1 className="text-4xl font-bold text-white mb-4">
              Xin chào, {user.name}! 👋
            </h1>
            <p className="text-gray-400 text-lg">
              Sẵn sàng cho buổi học hôm nay chưa?
            </p>
          </div>

          {/* Connected Partner */}
          <div className="bg-gray-800 rounded-xl p-6 mb-8 border-2 border-green-500/30">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="text-5xl">{partner.avatar}</div>
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="text-white font-semibold text-xl">{partner.name}</h3>
                    <span className="bg-green-500 text-white text-xs px-2 py-1 rounded-full">
                      ✓ Đã kết nối
                    </span>
                  </div>
                  <p className="text-gray-400">{partner.role}</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
                <span className="text-green-400 text-sm">Online</span>
              </div>
            </div>
          </div>

          {/* Action Cards */}
          <div className="grid md:grid-cols-2 gap-6 mb-8">
            {/* Video Call */}
            <button
              onClick={startVideoCall}
              disabled={user.role === "student"}
              className={`bg-gradient-to-br from-purple-600 to-purple-800 rounded-xl p-8 text-left transition-transform shadow-xl ${
                user.role === "teacher" 
                  ? "hover:scale-105 cursor-pointer" 
                  : "opacity-50 cursor-not-allowed"
              }`}
            >
              <div className="bg-white/20 w-16 h-16 rounded-xl flex items-center justify-center mb-4">
                <Video className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-white font-bold text-2xl mb-2">
                {user.role === "teacher" ? "📞 Gọi học viên" : "⏳ Đợi cuộc gọi"}
              </h3>
              <p className="text-white/80">
                {user.role === "teacher" 
                  ? `Gọi cho ${partner.name} để bắt đầu buổi học`
                  : "Giáo viên sẽ gọi khi sẵn sàng"}
              </p>
              <div className="mt-4 text-white/60 text-sm">
                ⚡ Kết nối P2P • HD Video • Real-time
              </div>
            </button>

            {/* Chat */}
            <div className="bg-gradient-to-br from-blue-600 to-blue-800 rounded-xl p-8 relative overflow-hidden">
              <div className="bg-white/20 w-16 h-16 rounded-xl flex items-center justify-center mb-4">
                <MessageSquare className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-white font-bold text-2xl mb-2">Chat</h3>
              <p className="text-white/80">
                Nhắn tin với {partner.name}
              </p>
              <div className="mt-4 text-white/60 text-sm">
                📱 Coming soon...
              </div>
              <div className="absolute top-4 right-4 bg-yellow-500 text-yellow-900 text-xs font-bold px-3 py-1 rounded-full">
                SOON
              </div>
            </div>
          </div>

          {/* Info */}
          <div className="bg-primary-900/30 border-2 border-primary-500/30 rounded-xl p-6">
            <h3 className="text-white font-semibold text-lg mb-3 flex items-center gap-2">
              <User className="w-5 h-5" />
              Thông tin tài khoản
            </h3>
            <div className="space-y-2 text-gray-300">
              <div className="flex justify-between">
                <span>Tên đăng nhập:</span>
                <span className="font-mono text-primary-400">{user.username}</span>
              </div>
              <div className="flex justify-between">
                <span>Vai trò:</span>
                <span className="font-semibold">
                  {user.role === "teacher" ? "👨‍🏫 Giáo viên" : "🎓 Học viên"}
                </span>
              </div>
              <div className="flex justify-between">
                <span>Đối tác:</span>
                <span className="font-semibold text-green-400">{partner.name}</span>
              </div>
              <div className="flex justify-between">
                <span>Session ID:</span>
                <span className="font-mono text-xs text-gray-400">demo-session-001</span>
              </div>
            </div>
          </div>

          {/* Tips */}
          <div className="mt-6 bg-gray-800/50 rounded-lg p-4 border border-gray-700">
            <p className="text-gray-400 text-sm text-center">
              💡 <strong>Tip:</strong> {user.role === "teacher" 
                ? "Click 'Gọi học viên' để bắt đầu. Học viên sẽ nhận được popup để accept."
                : "Đợi giáo viên gọi. Bạn sẽ thấy popup với nút Accept/Reject."}
            </p>
          </div>
        </div>
      </div>

      {/* Incoming Call Popup */}
      {showIncomingCall && incomingCallData && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4">
          <div className="bg-gray-800 rounded-2xl p-8 max-w-md w-full shadow-2xl border-2 border-green-500 animate-pulse">
            <div className="text-center">
              <div className="text-6xl mb-4">📞</div>
              <h2 className="text-white text-2xl font-bold mb-2">
                Cuộc gọi đến
              </h2>
              <p className="text-gray-300 text-lg mb-6">
                <span className="font-semibold text-green-400">
                  {incomingCallData.callerName}
                </span>
                {" "}đang gọi bạn...
              </p>
              
              <div className="flex gap-4">
                <button
                  onClick={rejectCall}
                  className="flex-1 bg-red-600 hover:bg-red-700 text-white py-4 rounded-xl font-semibold transition"
                >
                  ❌ Từ chối
                </button>
                <button
                  onClick={acceptCall}
                  className="flex-1 bg-green-600 hover:bg-green-700 text-white py-4 rounded-xl font-semibold transition"
                >
                  ✅ Chấp nhận
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </main>
  );
}
