import Link from "next/link";
import { Piano, Users, Video, TrendingUp, Star, Clock } from "lucide-react";

export default function Home() {
  return (
    <main className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-primary-600 to-primary-800 text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto text-center">
            <h1 className="text-5xl md:text-6xl font-bold mb-6">
              Học đàn Piano<br />
              <span className="text-primary-200">không cần mua đàn</span>
            </h1>
            <p className="text-xl md:text-2xl mb-8 text-primary-100">
              Thuê đàn ship tận nhà • Học online real-time • Giáo viên chuyên nghiệp
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link 
                href="/pianos"
                className="bg-white text-primary-700 px-8 py-4 rounded-lg font-semibold text-lg hover:bg-primary-50 transition"
              >
                Thuê đàn ngay
              </Link>
              <Link 
                href="/teachers"
                className="bg-primary-700 text-white px-8 py-4 rounded-lg font-semibold text-lg hover:bg-primary-800 transition border-2 border-white"
              >
                Tìm giáo viên
              </Link>
            </div>
            
            {/* Stats */}
            <div className="grid grid-cols-3 gap-8 mt-16 max-w-2xl mx-auto">
              <div>
                <div className="text-4xl font-bold">500+</div>
                <div className="text-primary-200">Học viên</div>
              </div>
              <div>
                <div className="text-4xl font-bold">50+</div>
                <div className="text-primary-200">Giáo viên</div>
              </div>
              <div>
                <div className="text-4xl font-bold">4.9⭐</div>
                <div className="text-primary-200">Đánh giá</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-gray-50">
        <div className="container mx-auto px-4">
          <h2 className="text-4xl font-bold text-center mb-4">Tại sao chọn Xpiano?</h2>
          <p className="text-xl text-gray-600 text-center mb-12">
            Giải pháp toàn diện cho người muốn học đàn
          </p>
          
          <div className="grid md:grid-cols-3 gap-8 max-w-6xl mx-auto">
            <div className="bg-white p-8 rounded-xl shadow-md hover:shadow-xl transition">
              <div className="bg-primary-100 w-16 h-16 rounded-lg flex items-center justify-center mb-4">
                <Piano className="w-8 h-8 text-primary-600" />
              </div>
              <h3 className="text-2xl font-bold mb-3">Thuê đàn linh hoạt</h3>
              <p className="text-gray-600 leading-relaxed">
                Đàn Yamaha, Roland, Casio ship tận nhà. Thuê theo tháng, không cam kết dài hạn. Từ 450k/tháng.
              </p>
            </div>

            <div className="bg-white p-8 rounded-xl shadow-md hover:shadow-xl transition">
              <div className="bg-primary-100 w-16 h-16 rounded-lg flex items-center justify-center mb-4">
                <Video className="w-8 h-8 text-primary-600" />
              </div>
              <h3 className="text-2xl font-bold mb-3">Học online real-time</h3>
              <p className="text-gray-600 leading-relaxed">
                Kết nối đàn với app qua MIDI. Giáo viên thấy từng phím bạn bấm. Feedback tức thì như học offline.
              </p>
            </div>

            <div className="bg-white p-8 rounded-xl shadow-md hover:shadow-xl transition">
              <div className="bg-primary-100 w-16 h-16 rounded-lg flex items-center justify-center mb-4">
                <Users className="w-8 h-8 text-primary-600" />
              </div>
              <h3 className="text-2xl font-bold mb-3">Giáo viên chuyên môn</h3>
              <p className="text-gray-600 leading-relaxed">
                50+ giáo viên 5-15 năm kinh nghiệm. Chọn theo phong cách, lịch và mức giá phù hợp.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-20">
        <div className="container mx-auto px-4">
          <h2 className="text-4xl font-bold text-center mb-4">Cách hoạt động</h2>
          <p className="text-xl text-gray-600 text-center mb-12">
            Chỉ 3 bước đơn giản để bắt đầu
          </p>

          <div className="max-w-4xl mx-auto">
            <div className="flex flex-col md:flex-row items-center gap-8 mb-12">
              <div className="bg-primary-600 text-white rounded-full w-16 h-16 flex items-center justify-center text-2xl font-bold flex-shrink-0">
                1
              </div>
              <div className="flex-1">
                <h3 className="text-2xl font-bold mb-2">Chọn đàn & Đặt thuê</h3>
                <p className="text-gray-600">
                  Browse danh sách đàn có sẵn gần bạn. Chọn thời gian thuê (1/3/6 tháng). Thanh toán online qua VNPay/Momo.
                </p>
              </div>
              <div className="hidden md:block w-32 h-1 bg-primary-200"></div>
            </div>

            <div className="flex flex-col md:flex-row items-center gap-8 mb-12">
              <div className="bg-primary-600 text-white rounded-full w-16 h-16 flex items-center justify-center text-2xl font-bold flex-shrink-0">
                2
              </div>
              <div className="flex-1">
                <h3 className="text-2xl font-bold mb-2">Nhận đàn & Kết nối</h3>
                <p className="text-gray-600">
                  Đàn được ship tận nhà trong 24h. Cắm cáp MIDI-USB vào laptop/phone. App tự động nhận diện trong 5 giây.
                </p>
              </div>
              <div className="hidden md:block w-32 h-1 bg-primary-200"></div>
            </div>

            <div className="flex flex-col md:flex-row items-center gap-8">
              <div className="bg-primary-600 text-white rounded-full w-16 h-16 flex items-center justify-center text-2xl font-bold flex-shrink-0">
                3
              </div>
              <div className="flex-1">
                <h3 className="text-2xl font-bold mb-2">Học với giáo viên</h3>
                <p className="text-gray-600">
                  Book lịch học với giáo viên. Video call + MIDI streaming real-time. Giáo viên thấy chính xác bạn chơi như thế nào.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-20 bg-gray-50">
        <div className="container mx-auto px-4">
          <h2 className="text-4xl font-bold text-center mb-12">Học viên nói gì về Xpiano</h2>
          
          <div className="grid md:grid-cols-3 gap-8 max-w-6xl mx-auto">
            <div className="bg-white p-6 rounded-xl shadow-md">
              <div className="flex items-center mb-4">
                <div className="flex text-yellow-400">
                  {[...Array(5)].map((_, i) => (
                    <Star key={i} className="w-5 h-5 fill-current" />
                  ))}
                </div>
              </div>
              <p className="text-gray-700 mb-4">
                "Mình vừa thuê đàn vừa học luôn trên app. Tiện lắm, không phải đi lại. Cô dạy rất tận tâm!"
              </p>
              <div className="flex items-center">
                <div className="w-10 h-10 bg-primary-200 rounded-full flex items-center justify-center font-bold text-primary-700">
                  M
                </div>
                <div className="ml-3">
                  <div className="font-semibold">Minh Anh</div>
                  <div className="text-sm text-gray-500">Học viên 3 tháng</div>
                </div>
              </div>
            </div>

            <div className="bg-white p-6 rounded-xl shadow-md">
              <div className="flex items-center mb-4">
                <div className="flex text-yellow-400">
                  {[...Array(5)].map((_, i) => (
                    <Star key={i} className="w-5 h-5 fill-current" />
                  ))}
                </div>
              </div>
              <p className="text-gray-700 mb-4">
                "Con trai mình rất thích học trên Xpiano. Thầy dạy dễ hiểu, em tiến bộ nhanh. Giá cả hợp lý."
              </p>
              <div className="flex items-center">
                <div className="w-10 h-10 bg-primary-200 rounded-full flex items-center justify-center font-bold text-primary-700">
                  H
                </div>
                <div className="ml-3">
                  <div className="font-semibold">Chị Hương</div>
                  <div className="text-sm text-gray-500">Phụ huynh</div>
                </div>
              </div>
            </div>

            <div className="bg-white p-6 rounded-xl shadow-md">
              <div className="flex items-center mb-4">
                <div className="flex text-yellow-400">
                  {[...Array(5)].map((_, i) => (
                    <Star key={i} className="w-5 h-5 fill-current" />
                  ))}
                </div>
              </div>
              <p className="text-gray-700 mb-4">
                "Tuyệt vời! Mình làm việc bận, học online tiện hơn nhiều. MIDI feedback real-time rất hay."
              </p>
              <div className="flex items-center">
                <div className="w-10 h-10 bg-primary-200 rounded-full flex items-center justify-center font-bold text-primary-700">
                  T
                </div>
                <div className="ml-3">
                  <div className="font-semibold">Tuấn</div>
                  <div className="text-sm text-gray-500">Học viên 6 tháng</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-primary-600 text-white">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-4xl md:text-5xl font-bold mb-6">
            Sẵn sàng bắt đầu chưa?
          </h2>
          <p className="text-xl mb-8 text-primary-100">
            Tham gia cùng 500+ học viên đang học đàn trên Xpiano
          </p>
          <Link 
            href="/pianos"
            className="inline-block bg-white text-primary-700 px-10 py-4 rounded-lg font-semibold text-lg hover:bg-primary-50 transition"
          >
            Bắt đầu ngay - Miễn phí
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-300 py-12">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <h3 className="text-white text-xl font-bold mb-4">Xpiano</h3>
              <p className="text-sm">
                Nền tảng học đàn & cho thuê piano đầu tiên tại Việt Nam
              </p>
            </div>
            <div>
              <h4 className="text-white font-semibold mb-4">Sản phẩm</h4>
              <ul className="space-y-2 text-sm">
                <li><Link href="/pianos" className="hover:text-white">Thuê đàn</Link></li>
                <li><Link href="/teachers" className="hover:text-white">Tìm giáo viên</Link></li>
                <li><Link href="#" className="hover:text-white">Giá cả</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="text-white font-semibold mb-4">Công ty</h4>
              <ul className="space-y-2 text-sm">
                <li><Link href="#" className="hover:text-white">Về chúng tôi</Link></li>
                <li><Link href="#" className="hover:text-white">Blog</Link></li>
                <li><Link href="#" className="hover:text-white">Careers</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="text-white font-semibold mb-4">Liên hệ</h4>
              <ul className="space-y-2 text-sm">
                <li>Email: hello@xpiano.vn</li>
                <li>Hotline: 1900 xxxx</li>
                <li>Địa chỉ: Hà Nội, Việt Nam</li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-800 mt-8 pt-8 text-center text-sm">
            <p>&copy; 2026 Xpiano. All rights reserved. Made with ❤️ in Vietnam</p>
          </div>
        </div>
      </footer>
    </main>
  );
}
