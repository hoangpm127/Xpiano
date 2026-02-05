"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Video, Users, BookOpen, Clock } from "lucide-react";

export default function ClassroomPage() {
  const router = useRouter();
  const [sessionId, setSessionId] = useState("");

  const createNewSession = () => {
    const newSessionId = Math.random().toString(36).substring(2, 10);
    router.push(`/classroom/student/${newSessionId}`);
  };

  const joinAsStudent = () => {
    if (sessionId.trim()) {
      router.push(`/classroom/student/${sessionId}`);
    }
  };

  const joinAsTeacher = () => {
    if (sessionId.trim()) {
      router.push(`/classroom/teacher/${sessionId}`);
    }
  };

  return (
    <main className="min-h-screen bg-gray-50 py-8">
      <div className="container mx-auto px-4">
        <div className="max-w-4xl mx-auto">
          {/* Header */}
          <div className="text-center mb-12">
            <h1 className="text-4xl font-bold mb-4">🎓 Lớp học Video Call</h1>
            <p className="text-gray-600 text-lg">
              Kết nối thầy và trò qua video call real-time
            </p>
          </div>

          {/* Quick Start */}
          <div className="bg-gradient-to-br from-primary-600 to-primary-800 rounded-2xl p-8 text-white mb-8 shadow-xl">
            <h2 className="text-2xl font-bold mb-4">🚀 Quick Start</h2>
            <p className="mb-6">Tạo phòng học mới ngay lập tức</p>
            <button
              onClick={createNewSession}
              className="bg-white text-primary-700 px-8 py-4 rounded-lg font-semibold text-lg hover:bg-gray-100 transition shadow-lg"
            >
              ✨ Tạo lớp học mới (Student)
            </button>
          </div>

          {/* Join Existing Session */}
          <div className="grid md:grid-cols-2 gap-6 mb-8">
            {/* Student Join */}
            <div className="bg-white rounded-xl shadow-md p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="bg-blue-100 p-3 rounded-lg">
                  <Users className="w-6 h-6 text-blue-600" />
                </div>
                <h3 className="text-xl font-bold">Tham gia như Học viên</h3>
              </div>
              <p className="text-gray-600 mb-4 text-sm">
                Nhập Session ID mà giáo viên đã gửi cho bạn
              </p>
              <input
                type="text"
                value={sessionId}
                onChange={(e) => setSessionId(e.target.value)}
                placeholder="Nhập Session ID..."
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg mb-4 focus:outline-none focus:border-primary-500"
              />
              <button
                onClick={joinAsStudent}
                disabled={!sessionId.trim()}
                className="w-full bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Tham gia (Student)
              </button>
            </div>

            {/* Teacher Join */}
            <div className="bg-white rounded-xl shadow-md p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="bg-purple-100 p-3 rounded-lg">
                  <BookOpen className="w-6 h-6 text-purple-600" />
                </div>
                <h3 className="text-xl font-bold">Tham gia như Giáo viên</h3>
              </div>
              <p className="text-gray-600 mb-4 text-sm">
                Nhập Session ID để vào lớp học của học viên
              </p>
              <input
                type="text"
                value={sessionId}
                onChange={(e) => setSessionId(e.target.value)}
                placeholder="Nhập Session ID..."
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg mb-4 focus:outline-none focus:border-primary-500"
              />
              <button
                onClick={joinAsTeacher}
                disabled={!sessionId.trim()}
                className="w-full bg-purple-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-purple-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Tham gia (Teacher)
              </button>
            </div>
          </div>

          {/* Features */}
          <div className="bg-white rounded-xl shadow-md p-8 mb-8">
            <h3 className="text-2xl font-bold mb-6">✨ Tính năng</h3>
            <div className="grid md:grid-cols-3 gap-6">
              <div className="text-center">
                <div className="bg-green-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-3">
                  <Video className="w-8 h-8 text-green-600" />
                </div>
                <h4 className="font-semibold mb-2">Video HD</h4>
                <p className="text-sm text-gray-600">
                  Chất lượng video 720p, âm thanh rõ nét
                </p>
              </div>
              <div className="text-center">
                <div className="bg-yellow-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-3">
                  <Users className="w-8 h-8 text-yellow-600" />
                </div>
                <h4 className="font-semibold mb-2">P2P Connection</h4>
                <p className="text-sm text-gray-600">
                  Kết nối trực tiếp, độ trễ thấp
                </p>
              </div>
              <div className="text-center">
                <div className="bg-red-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-3">
                  <Clock className="w-8 h-8 text-red-600" />
                </div>
                <h4 className="font-semibold mb-2">Real-time</h4>
                <p className="text-sm text-gray-600">
                  Tương tác ngay lập tức, không delay
                </p>
              </div>
            </div>
          </div>

          {/* Instructions */}
          <div className="bg-primary-50 border-2 border-primary-200 rounded-xl p-6">
            <h3 className="text-xl font-bold mb-4 text-primary-900">📖 Hướng dẫn</h3>
            <ol className="space-y-3 text-gray-700">
              <li className="flex items-start gap-3">
                <span className="bg-primary-600 text-white w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold">
                  1
                </span>
                <span>
                  <strong>Học viên:</strong> Click "Tạo lớp học mới" → Copy Session ID hiển thị trên màn hình
                </span>
              </li>
              <li className="flex items-start gap-3">
                <span className="bg-primary-600 text-white w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold">
                  2
                </span>
                <span>
                  <strong>Học viên:</strong> Gửi Session ID cho giáo viên (qua Zalo, Messenger...)
                </span>
              </li>
              <li className="flex items-start gap-3">
                <span className="bg-primary-600 text-white w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold">
                  3
                </span>
                <span>
                  <strong>Giáo viên:</strong> Nhập Session ID vào ô "Tham gia như Giáo viên" → Click "Tham gia"
                </span>
              </li>
              <li className="flex items-start gap-3">
                <span className="bg-primary-600 text-white w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold">
                  4
                </span>
                <span>
                  <strong>Cả 2:</strong> Cho phép truy cập Camera & Mic → Tự động kết nối sau vài giây
                </span>
              </li>
              <li className="flex items-start gap-3">
                <span className="bg-primary-600 text-white w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold">
                  5
                </span>
                <span>
                  <strong>Tips:</strong> Dùng nút 🔇 Mute/Unmute nếu test 2 thiết bị gần nhau (tránh hú)
                </span>
              </li>
            </ol>
          </div>

          {/* Back to Home */}
          <div className="text-center mt-8">
            <Link
              href="/"
              className="text-primary-600 hover:text-primary-700 font-semibold"
            >
              ← Về trang chủ
            </Link>
          </div>
        </div>
      </div>
    </main>
  );
}
