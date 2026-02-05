"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { User, Key, LogIn } from "lucide-react";
import { useSocket } from "@/contexts/SocketContext";

// Demo accounts (hardcoded)
const DEMO_ACCOUNTS = {
  teacher: {
    username: "teacher",
    password: "123",
    role: "teacher",
    name: "Nguyễn Văn Thầy",
    avatar: "👨‍🏫",
  },
  student: {
    username: "student",
    password: "123",
    role: "student",
    name: "Trần Thị Trò",
    avatar: "🎓",
  },
};

export default function LoginPage() {
  const router = useRouter();
  const { socket } = useSocket();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleLogin = () => {
    setError("");

    // Check credentials
    const account = DEMO_ACCOUNTS[username as keyof typeof DEMO_ACCOUNTS];
    
    if (!account || account.password !== password) {
      setError("❌ Sai tên đăng nhập hoặc mật khẩu!");
      return;
    }

    // Save to sessionStorage
    sessionStorage.setItem("xpiano-user", JSON.stringify(account));

    // Emit to Socket.io
    if (socket) {
      socket.emit('user:online', {
        userId: account.username,
        role: account.role,
        peerId: null // Sẽ update sau khi PeerJS connect
      });
    }

    // Redirect to classroom
    router.push("/classroom/lobby");
  };

  const quickLogin = (role: "teacher" | "student") => {
    const account = DEMO_ACCOUNTS[role];
    sessionStorage.setItem("xpiano-user", JSON.stringify(account));
    
    // Emit to Socket.io
    if (socket) {
      socket.emit('user:online', {
        userId: account.username,
        role: account.role,
        peerId: null
      });
    }
    
    router.push("/classroom/lobby");
  };

  return (
    <main className="min-h-screen bg-gradient-to-br from-primary-600 via-purple-600 to-pink-600 flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        {/* Logo */}
        <div className="text-center mb-8">
          <h1 className="text-5xl font-bold text-white mb-2">🎹 Xpiano</h1>
          <p className="text-white/80 text-lg">Đăng nhập để vào lớp học</p>
        </div>

        {/* Login Form */}
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <h2 className="text-2xl font-bold mb-6 text-gray-800">Đăng nhập</h2>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-4">
              {error}
            </div>
          )}

          <div className="space-y-4">
            <div>
              <label className="block text-gray-700 font-medium mb-2">
                <User className="w-4 h-4 inline mr-2" />
                Tên đăng nhập
              </label>
              <input
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                onKeyPress={(e) => e.key === "Enter" && handleLogin()}
                placeholder="teacher hoặc student"
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-primary-500"
              />
            </div>

            <div>
              <label className="block text-gray-700 font-medium mb-2">
                <Key className="w-4 h-4 inline mr-2" />
                Mật khẩu
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                onKeyPress={(e) => e.key === "Enter" && handleLogin()}
                placeholder="123"
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-primary-500"
              />
            </div>

            <button
              onClick={handleLogin}
              className="w-full bg-primary-600 text-white py-3 rounded-lg font-semibold hover:bg-primary-700 transition flex items-center justify-center gap-2"
            >
              <LogIn className="w-5 h-5" />
              Đăng nhập
            </button>
          </div>

          {/* Divider */}
          <div className="relative my-6">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-300"></div>
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-4 bg-white text-gray-500">hoặc đăng nhập nhanh</span>
            </div>
          </div>

          {/* Quick Login */}
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => quickLogin("teacher")}
              className="bg-purple-50 border-2 border-purple-200 text-purple-700 py-3 rounded-lg font-semibold hover:bg-purple-100 transition"
            >
              👨‍🏫 Giáo viên
            </button>
            <button
              onClick={() => quickLogin("student")}
              className="bg-blue-50 border-2 border-blue-200 text-blue-700 py-3 rounded-lg font-semibold hover:bg-blue-100 transition"
            >
              🎓 Học viên
            </button>
          </div>

          {/* Demo Info */}
          <div className="mt-6 bg-gray-50 rounded-lg p-4 text-sm">
            <p className="font-semibold text-gray-700 mb-2">📝 Tài khoản demo:</p>
            <div className="space-y-1 text-gray-600">
              <div>👨‍🏫 Teacher: <code className="bg-white px-2 py-0.5 rounded">teacher / 123</code></div>
              <div>🎓 Student: <code className="bg-white px-2 py-0.5 rounded">student / 123</code></div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center mt-6 text-white/80 text-sm">
          <p>Tài khoản đã được kết nối sẵn để test video call & chat</p>
        </div>
      </div>
    </main>
  );
}
