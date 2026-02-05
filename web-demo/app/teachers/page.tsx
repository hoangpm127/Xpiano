import { Star, Award, Clock, Video } from "lucide-react";
import Link from "next/link";

// Mock data
const teachers = [
  {
    id: 1,
    name: "Cô Hương",
    avatar: "https://i.pravatar.cc/150?img=1",
    experience: 8,
    rating: 4.9,
    reviews: 250,
    price: 250000,
    specialties: ["Người mới bắt đầu", "Classical", "Pop"],
    bio: "Tốt nghiệp Nhạc viện. Chuyên dạy người mới bắt đầu với phương pháp dễ hiểu.",
    totalStudents: 120,
    completedLessons: 1500,
    available: true
  },
  {
    id: 2,
    name: "Thầy Tuấn",
    avatar: "https://i.pravatar.cc/150?img=12",
    experience: 5,
    rating: 4.7,
    reviews: 180,
    price: 200000,
    specialties: ["Jazz", "Improvisation", "Intermediate"],
    bio: "Jazz pianist với 5 năm kinh nghiệm. Dạy học viên trung cấp muốn học jazz.",
    totalStudents: 85,
    completedLessons: 980,
    available: true
  },
  {
    id: 3,
    name: "Cô Linh",
    avatar: "https://i.pravatar.cc/150?img=5",
    experience: 10,
    rating: 5.0,
    reviews: 310,
    price: 300000,
    specialties: ["Advanced", "Concert prep", "Theory"],
    bio: "Giảng viên Nhạc viện Hà Nội. Chuyên đào tạo học viên thi đỗ Nhạc viện.",
    totalStudents: 150,
    completedLessons: 2300,
    available: false
  },
  {
    id: 4,
    name: "Thầy Minh",
    avatar: "https://i.pravatar.cc/150?img=13",
    experience: 6,
    rating: 4.8,
    reviews: 195,
    price: 220000,
    specialties: ["Trẻ em", "Cơ bản", "Fun learning"],
    bio: "Chuyên dạy trẻ em 5-12 tuổi. Phương pháp vui nhộn, giữ được hứng thú học.",
    totalStudents: 95,
    completedLessons: 1200,
    available: true
  },
  {
    id: 5,
    name: "Cô Mai",
    avatar: "https://i.pravatar.cc/150?img=9",
    experience: 7,
    rating: 4.9,
    reviews: 220,
    price: 240000,
    specialties: ["Pop", "K-pop", "Anime music"],
    bio: "Dạy các bài hát pop, K-pop hiện đại. Phù hợp học viên trẻ yêu nhạc đương đại.",
    totalStudents: 110,
    completedLessons: 1400,
    available: true
  },
  {
    id: 6,
    name: "Thầy Khoa",
    avatar: "https://i.pravatar.cc/150?img=14",
    experience: 12,
    rating: 5.0,
    reviews: 280,
    price: 350000,
    specialties: ["Professional", "Recording", "Songwriting"],
    bio: "Producer, musician. Dạy kỹ thuật chuyên nghiệp cho người muốn làm nghề.",
    totalStudents: 65,
    completedLessons: 1800,
    available: true
  },
];

export default function TeachersPage() {
  return (
    <main className="min-h-screen bg-gray-50 py-8">
      <div className="container mx-auto px-4">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-2">Giáo viên Piano</h1>
          <p className="text-gray-600">Tìm thấy {teachers.length} giáo viên phù hợp</p>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-8">
          <div className="grid md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium mb-2">Chuyên môn</label>
              <select className="w-full border rounded-lg px-4 py-2">
                <option>Tất cả</option>
                <option>Người mới bắt đầu</option>
                <option>Trung cấp</option>
                <option>Chuyên nghiệp</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Thể loại</label>
              <select className="w-full border rounded-lg px-4 py-2">
                <option>Tất cả</option>
                <option>Classical</option>
                <option>Jazz</option>
                <option>Pop</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Giá/buổi</label>
              <select className="w-full border rounded-lg px-4 py-2">
                <option>Tất cả</option>
                <option>Dưới 200k</option>
                <option>200k - 300k</option>
                <option>Trên 300k</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Sắp xếp</label>
              <select className="w-full border rounded-lg px-4 py-2">
                <option>Đánh giá cao nhất</option>
                <option>Giá thấp nhất</option>
                <option>Kinh nghiệm nhiều nhất</option>
              </select>
            </div>
          </div>
        </div>

        {/* Teacher List */}
        <div className="space-y-6">
          {teachers.map((teacher) => (
            <div key={teacher.id} className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition">
              <div className="p-6">
                <div className="flex flex-col md:flex-row gap-6">
                  {/* Avatar */}
                  <div className="relative flex-shrink-0">
                    <img 
                      src={teacher.avatar} 
                      alt={teacher.name}
                      className="w-32 h-32 rounded-full object-cover"
                    />
                    {teacher.available && (
                      <div className="absolute bottom-0 right-0 w-6 h-6 bg-green-500 border-4 border-white rounded-full"></div>
                    )}
                  </div>

                  {/* Info */}
                  <div className="flex-1">
                    <div className="flex items-start justify-between mb-3">
                      <div>
                        <h2 className="text-2xl font-bold mb-1">{teacher.name}</h2>
                        <div className="flex items-center gap-4 text-sm text-gray-600">
                          <div className="flex items-center">
                            <Award className="w-4 h-4 mr-1" />
                            {teacher.experience} năm kinh nghiệm
                          </div>
                          <div className="flex items-center">
                            <Star className="w-4 h-4 text-yellow-400 fill-current mr-1" />
                            {teacher.rating} ({teacher.reviews} đánh giá)
                          </div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-3xl font-bold text-primary-600">
                          {teacher.price.toLocaleString('vi-VN')}đ
                        </div>
                        <div className="text-sm text-gray-500">/ buổi (1 tiếng)</div>
                      </div>
                    </div>

                    <p className="text-gray-700 mb-4">{teacher.bio}</p>

                    {/* Specialties */}
                    <div className="flex flex-wrap gap-2 mb-4">
                      {teacher.specialties.map((specialty, i) => (
                        <span key={i} className="bg-primary-100 text-primary-700 px-3 py-1 rounded-full text-sm font-medium">
                          {specialty}
                        </span>
                      ))}
                    </div>

                    {/* Stats */}
                    <div className="flex gap-6 mb-4 text-sm">
                      <div>
                        <span className="font-semibold text-gray-900">{teacher.totalStudents}</span>
                        <span className="text-gray-600 ml-1">học viên</span>
                      </div>
                      <div>
                        <span className="font-semibold text-gray-900">{teacher.completedLessons}</span>
                        <span className="text-gray-600 ml-1">buổi học</span>
                      </div>
                      <div className="flex items-center">
                        <Video className="w-4 h-4 mr-1 text-gray-600" />
                        <span className="text-gray-600">Online qua Xpiano</span>
                      </div>
                    </div>

                    {/* Actions */}
                    <div className="flex gap-3">
                      <Link 
                        href={`/teachers/${teacher.id}`}
                        className="flex-1 md:flex-none bg-primary-600 text-white px-8 py-2 rounded-lg font-semibold hover:bg-primary-700 transition text-center"
                      >
                        Đặt lịch học
                      </Link>
                      <Link 
                        href={`/teachers/${teacher.id}`}
                        className="flex-1 md:flex-none border-2 border-primary-600 text-primary-600 px-8 py-2 rounded-lg font-semibold hover:bg-primary-50 transition text-center"
                      >
                        Xem profile
                      </Link>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Become Teacher CTA */}
        <div className="mt-16 bg-gradient-to-r from-primary-600 to-primary-800 rounded-lg shadow-xl p-8 text-white text-center">
          <h2 className="text-3xl font-bold mb-4">Bạn là giáo viên Piano?</h2>
          <p className="text-xl mb-6 text-primary-100">
            Tham gia Xpiano để tìm học viên và dạy online với công nghệ MIDI tiên tiến
          </p>
          <Link 
            href="#"
            className="inline-block bg-white text-primary-700 px-8 py-3 rounded-lg font-semibold hover:bg-primary-50 transition"
          >
            Đăng ký làm giáo viên
          </Link>
        </div>
      </div>
    </main>
  );
}
