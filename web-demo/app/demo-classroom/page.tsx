"use client";

import { useState } from "react";
import { Video, Mic, MicOff, VideoOff, Phone, MessageSquare, Music } from "lucide-react";

export default function DemoClassroomPage() {
  const [isMicOn, setIsMicOn] = useState(true);
  const [isVideoOn, setIsVideoOn] = useState(true);
  const [messages, setMessages] = useState([
    { sender: "teacher", text: "Chào em! Chúng ta bắt đầu buổi học nhé", time: "19:58" },
    { sender: "student", text: "Dạ vâng ạ!", time: "19:58" },
  ]);
  const [newMessage, setNewMessage] = useState("");

  // MIDI visualization demo
  const pianoKeys = Array.from({ length: 12 }, (_, i) => i);
  const [activeKeys, setActiveKeys] = useState<number[]>([]);

  const handleSendMessage = () => {
    if (newMessage.trim()) {
      setMessages([...messages, { 
        sender: "student", 
        text: newMessage, 
        time: new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })
      }]);
      setNewMessage("");
    }
  };

  const simulateMIDI = (keyIndex: number) => {
    setActiveKeys([keyIndex]);
    setTimeout(() => setActiveKeys([]), 300);
  };

  return (
    <main className="min-h-screen bg-gray-900">
      {/* Header */}
      <div className="bg-gray-800 border-b border-gray-700 px-4 py-3">
        <div className="container mx-auto flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 bg-red-500 rounded-full animate-pulse"></div>
              <span className="text-white font-semibold">Live Session</span>
            </div>
            <div className="text-gray-400 text-sm">
              Buổi học với Cô Hương • 45:32
            </div>
          </div>
          <div className="text-gray-400 text-sm">
            Connection: <span className="text-green-400">Excellent</span>
          </div>
        </div>
      </div>

      <div className="container mx-auto p-4">
        <div className="grid lg:grid-cols-3 gap-4 h-[calc(100vh-120px)]">
          {/* Main Video Area */}
          <div className="lg:col-span-2 space-y-4">
            {/* Teacher Video (Large) */}
            <div className="bg-gray-800 rounded-lg overflow-hidden aspect-video relative">
              <img 
                src="https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=800&h=450&fit=crop"
                alt="Teacher"
                className="w-full h-full object-cover"
              />
              <div className="absolute bottom-4 left-4 bg-black bg-opacity-60 px-3 py-1 rounded">
                <span className="text-white font-semibold">Cô Hương (Giáo viên)</span>
              </div>
              <div className="absolute top-4 right-4 bg-green-500 text-white px-3 py-1 rounded-full text-sm font-semibold">
                HD Quality
              </div>
            </div>

            {/* MIDI Visualization */}
            <div className="bg-gray-800 rounded-lg p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-white font-semibold flex items-center">
                  <Music className="w-5 h-5 mr-2" />
                  MIDI Input - Student Piano
                </h3>
                <div className="flex items-center gap-2">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <span className="text-green-400 text-sm">Connected</span>
                </div>
              </div>
              
              {/* Piano Keys Visualization */}
              <div className="flex gap-1 justify-center mb-4">
                {pianoKeys.map((key) => {
                  const isBlack = [1, 3, 6, 8, 10].includes(key);
                  return (
                    <div 
                      key={key}
                      onClick={() => simulateMIDI(key)}
                      className={`cursor-pointer transition-all ${
                        isBlack 
                          ? 'w-8 h-24 bg-gray-900 hover:bg-gray-700' 
                          : 'w-12 h-32 bg-white hover:bg-gray-200'
                      } ${
                        activeKeys.includes(key) 
                          ? 'bg-primary-500 scale-95' 
                          : ''
                      } rounded-b border-2 border-gray-600`}
                    ></div>
                  );
                })}
              </div>

              {/* MIDI Info */}
              <div className="grid grid-cols-3 gap-4 text-sm">
                <div className="bg-gray-700 rounded p-3">
                  <div className="text-gray-400">Last Note</div>
                  <div className="text-white font-bold text-lg">C4 (60)</div>
                </div>
                <div className="bg-gray-700 rounded p-3">
                  <div className="text-gray-400">Velocity</div>
                  <div className="text-white font-bold text-lg">80</div>
                </div>
                <div className="bg-gray-700 rounded p-3">
                  <div className="text-gray-400">Latency</div>
                  <div className="text-green-400 font-bold text-lg">45ms</div>
                </div>
              </div>

              <div className="mt-4 text-center">
                <button 
                  onClick={() => {
                    simulateMIDI(4);
                    setTimeout(() => simulateMIDI(7), 200);
                    setTimeout(() => simulateMIDI(11), 400);
                  }}
                  className="text-primary-400 hover:text-primary-300 text-sm underline"
                >
                  Click vào phím hoặc bấm đây để test MIDI
                </button>
              </div>
            </div>

            {/* Student Video (Small) */}
            <div className="bg-gray-800 rounded-lg overflow-hidden aspect-video relative">
              <img 
                src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=225&fit=crop"
                alt="Student"
                className="w-full h-full object-cover"
              />
              <div className="absolute bottom-4 left-4 bg-black bg-opacity-60 px-3 py-1 rounded">
                <span className="text-white font-semibold">Bạn (Học viên)</span>
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
                  Chat
                </h3>
              </div>
              
              <div className="flex-1 overflow-y-auto p-4 space-y-3">
                {messages.map((msg, i) => (
                  <div key={i} className={`flex ${msg.sender === 'student' ? 'justify-end' : 'justify-start'}`}>
                    <div className={`max-w-[80%] rounded-lg p-3 ${
                      msg.sender === 'student' 
                        ? 'bg-primary-600 text-white' 
                        : 'bg-gray-700 text-gray-200'
                    }`}>
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
                    onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
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
                  onClick={() => setIsMicOn(!isMicOn)}
                  className={`p-4 rounded-full ${
                    isMicOn ? 'bg-gray-700 hover:bg-gray-600' : 'bg-red-600 hover:bg-red-700'
                  }`}
                >
                  {isMicOn ? (
                    <Mic className="w-6 h-6 text-white" />
                  ) : (
                    <MicOff className="w-6 h-6 text-white" />
                  )}
                </button>
                
                <button 
                  onClick={() => setIsVideoOn(!isVideoOn)}
                  className={`p-4 rounded-full ${
                    isVideoOn ? 'bg-gray-700 hover:bg-gray-600' : 'bg-red-600 hover:bg-red-700'
                  }`}
                >
                  {isVideoOn ? (
                    <Video className="w-6 h-6 text-white" />
                  ) : (
                    <VideoOff className="w-6 h-6 text-white" />
                  )}
                </button>
                
                <button className="p-4 rounded-full bg-red-600 hover:bg-red-700">
                  <Phone className="w-6 h-6 text-white" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Demo Notice */}
      <div className="fixed top-20 left-1/2 transform -translate-x-1/2 bg-yellow-500 text-gray-900 px-6 py-3 rounded-lg shadow-xl z-50">
        <p className="font-semibold">
          🎬 Đây là giao diện demo - Không có video/audio thật
        </p>
      </div>
    </main>
  );
}
