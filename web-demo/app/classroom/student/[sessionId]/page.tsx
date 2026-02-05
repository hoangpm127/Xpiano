"use client";

import { useParams, useRouter } from "next/navigation";
import { useState, useEffect } from "react";
import { Video, Mic, MicOff, VideoOff, Phone, MessageSquare, Copy, Share2, Users, LogOut } from "lucide-react";
import useVideoChat from "@/hooks/useVideoChat";

interface UserAccount {
  username: string;
  role: string;
  name: string;
  avatar: string;
}

export default function StudentClassroomPage() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.sessionId as string;
  const [user, setUser] = useState<UserAccount | null>(null);
  
  // Check auth
  useEffect(() => {
    const userData = sessionStorage.getItem("xpiano-user");
    if (!userData) {
      router.push("/login");
      return;
    }
    setUser(JSON.parse(userData));
  }, [router]);

  const [messages, setMessages] = useState<Array<{ sender: string; text: string; time: string }>>([
    { sender: "system", text: "Chào mừng đến lớp học!", time: new Date().toLocaleTimeString() },
  ]);
  const [newMessage, setNewMessage] = useState("");
  const [showCopyAlert, setShowCopyAlert] = useState(false);

  const {
    myPeerId,
    partnerPeerId,
    connectionStatus,
    isMuted,
    isVideoOff,
    error,
    localVideoRef,
    remoteVideoRef,
    toggleMute,
    toggleVideo,
    disconnect,
  } = useVideoChat({
    role: "student",
    sessionId,
  });

  const handleSendMessage = () => {
    if (newMessage.trim()) {
      setMessages([
        ...messages,
        {
          sender: "student",
          text: newMessage,
          time: new Date().toLocaleTimeString("vi-VN", { hour: "2-digit", minute: "2-digit" }),
        },
      ]);
      setNewMessage("");
    }
  };

  const copySessionInfo = () => {
    const info = `Session ID: ${sessionId}\nStudent Peer ID: ${myPeerId}\nLink: ${window.location.origin}/classroom/teacher/${sessionId}`;
    navigator.clipboard.writeText(info);
    setShowCopyAlert(true);
    setTimeout(() => setShowCopyAlert(false), 3000);
  };

  const shareLink = () => {
    const url = `${window.location.origin}/classroom/teacher/${sessionId}`;
    if (navigator.share) {
      navigator.share({
        title: "Xpiano Classroom",
        text: `Tham gia lớp học! Session: ${sessionId}`,
        url,
      });
    } else {
      navigator.clipboard.writeText(url);
      setShowCopyAlert(true);
      setTimeout(() => setShowCopyAlert(false), 3000);
    }
  };

  const handleDisconnect = () => {
    disconnect();
    router.push("/classroom/lobby");
  };

  const handleLogout = () => {
    sessionStorage.removeItem("xpiano-user");
    disconnect();
    router.push("/login");
  };

  if (!user) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-white">Đang tải...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-900">
      {/* Header */}
      <div className="bg-gray-800 border-b border-gray-700 px-4 py-3">
        <div className="container mx-auto flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2">
              <div className={`w-3 h-3 rounded-full ${
                connectionStatus === "online" ? "bg-green-500 animate-pulse" :
                connectionStatus === "connecting" ? "bg-yellow-500 animate-pulse" :
                "bg-red-500"
              }`}></div>
              <span className="text-white font-semibold">
                {connectionStatus === "online" && partnerPeerId ? "🎓 Đang học với giáo viên" :
                 connectionStatus === "connecting" ? "⏳ Đang kết nối..." :
                 "⏸️ Đang chờ giáo viên"}
              </span>
            </div>
            <div className="text-gray-400 text-sm hidden md:block">
              Session: <span className="text-primary-400">{sessionId}</span>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <div className="text-gray-400 text-sm mr-4 hidden md:block">
              {user.avatar} {user.name}
            </div>
            <button
              onClick={handleLogout}
              className="text-gray-400 hover:text-white p-2 rounded transition"
              title="Đăng xuất"
            >
              <LogOut className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>

      {/* Copy Alert */}
      {showCopyAlert && (
        <div className="fixed top-20 left-1/2 transform -translate-x-1/2 bg-green-500 text-white px-6 py-3 rounded-lg shadow-xl z-50 animate-bounce">
          ✅ Đã copy thông tin!
        </div>
      )}

      {/* Error Alert */}
      {error && (
        <div className="fixed top-20 left-1/2 transform -translate-x-1/2 bg-red-500 text-white px-6 py-3 rounded-lg shadow-xl z-50 max-w-md">
          ❌ {error}
        </div>
      )}

      <div className="container mx-auto p-4">
        <div className="grid lg:grid-cols-3 gap-4 h-[calc(100vh-120px)]">
          {/* Main Video Area */}
          <div className="lg:col-span-2 space-y-4">
            {/* Teacher Video (Large) */}
            <div className="bg-gray-800 rounded-lg overflow-hidden aspect-video relative">
              <video
                ref={remoteVideoRef}
                autoPlay
                playsInline
                className="w-full h-full object-cover"
              />
              {!partnerPeerId && (
                <div className="absolute inset-0 flex flex-col items-center justify-center text-gray-500">
                  <Users className="w-16 h-16 mb-4 opacity-30" />
                  <div className="text-lg">Đang chờ giáo viên tham gia...</div>
                  <div className="text-sm mt-2">Share link cho giáo viên:</div>
                  <div className="text-xs text-primary-400 mt-1 font-mono">
                    /classroom/teacher/{sessionId}
                  </div>
                </div>
              )}
              <div className="absolute bottom-4 left-4 bg-black bg-opacity-60 px-3 py-1 rounded">
                <span className="text-white font-semibold">👨‍🏫 Giáo viên</span>
              </div>
              {partnerPeerId && (
                <div className="absolute top-4 right-4 bg-green-500 text-white px-3 py-1 rounded-full text-sm font-semibold">
                  🟢 Live
                </div>
              )}
            </div>

            {/* Student Video (Small) */}
            <div className="bg-gray-800 rounded-lg overflow-hidden aspect-video relative">
              <video
                ref={localVideoRef}
                autoPlay
                muted
                playsInline
                className="w-full h-full object-cover"
              />
              {isVideoOff && (
                <div className="absolute inset-0 flex items-center justify-center bg-gray-900 text-gray-500">
                  <VideoOff className="w-12 h-12" />
                </div>
              )}
              <div className="absolute bottom-4 left-4 bg-black bg-opacity-60 px-3 py-1 rounded">
                <span className="text-white font-semibold">🎓 Bạn (Học viên)</span>
              </div>
            </div>

            {/* My Peer ID Info */}
            <div className="bg-gray-800 rounded-lg p-4">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-gray-400 text-sm">Student Peer ID:</div>
                  <div className="text-white font-mono text-sm">{myPeerId || "Đang tạo..."}</div>
                </div>
                {partnerPeerId && (
                  <div>
                    <div className="text-gray-400 text-sm">Connected to:</div>
                    <div className="text-green-400 font-mono text-sm">{partnerPeerId}</div>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Right Sidebar */}
          <div className="space-y-4">
            {/* Chat */}
            <div className="bg-gray-800 rounded-lg h-[calc(100%-200px)] flex flex-col">
              <div className="p-4 border-b border-gray-700">
                <h3 className="text-white font-semibold flex items-center">
                  <MessageSquare className="w-5 h-5 mr-2" />
                  Chat với giáo viên
                </h3>
              </div>

              <div className="flex-1 overflow-y-auto p-4 space-y-3">
                {messages.map((msg, i) => (
                  <div
                    key={i}
                    className={`flex ${msg.sender === "student" ? "justify-end" : "justify-start"}`}
                  >
                    <div
                      className={`max-w-[80%] rounded-lg p-3 ${
                        msg.sender === "student"
                          ? "bg-primary-600 text-white"
                          : msg.sender === "system"
                          ? "bg-gray-700 text-gray-300 text-center w-full"
                          : "bg-gray-700 text-gray-200"
                      }`}
                    >
                      <p className="text-sm">{msg.text}</p>
                      <span className="text-xs opacity-70 mt-1 block">{msg.time}</span>
                    </div>
                  </div>
                ))}
              </div>

              <div className="p-4 border-t border-gray-700">
                <div className="flex gap-2">
                  <input
                    type="text"
                    value={newMessage}
                    onChange={(e) => setNewMessage(e.target.value)}
                    onKeyPress={(e) => e.key === "Enter" && handleSendMessage()}
                    placeholder="Nhập tin nhắn..."
                    className="flex-1 bg-gray-700 text-white rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                  <button
                    onClick={handleSendMessage}
                    className="bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700"
                  >
                    Gửi
                  </button>
                </div>
              </div>
            </div>

            {/* Controls */}
            <div className="bg-gray-800 rounded-lg p-4">
              <div className="flex justify-center gap-4">
                <button
                  onClick={toggleMute}
                  className={`p-4 rounded-full ${
                    isMuted ? "bg-red-600 hover:bg-red-700" : "bg-gray-700 hover:bg-gray-600"
                  }`}
                  title={isMuted ? "Unmute" : "Mute"}
                >
                  {isMuted ? <MicOff className="w-6 h-6 text-white" /> : <Mic className="w-6 h-6 text-white" />}
                </button>

                <button
                  onClick={toggleVideo}
                  className={`p-4 rounded-full ${
                    isVideoOff ? "bg-red-600 hover:bg-red-700" : "bg-gray-700 hover:bg-gray-600"
                  }`}
                  title={isVideoOff ? "Turn On Video" : "Turn Off Video"}
                >
                  {isVideoOff ? <VideoOff className="w-6 h-6 text-white" /> : <Video className="w-6 h-6 text-white" />}
                </button>

                <button
                  onClick={handleDisconnect}
                  className="p-4 rounded-full bg-red-600 hover:bg-red-700"
                  title="End Class"
                >
                  <Phone className="w-6 h-6 text-white" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
