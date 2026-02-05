import { MapPin, Star, TrendingUp } from "lucide-react";
import Link from "next/link";

// Mock data
const pianos = [
  {
    id: 1,
    brand: "Yamaha",
    model: "P-45",
    image: "https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=600&h=400&fit=crop",
    price: 500000,
    location: "Cầu Giấy, Hà Nội",
    distance: "2.3 km",
    rating: 4.8,
    reviews: 127,
    features: ["88 phím", "MIDI USB", "10 âm thanh"],
    available: true
  },
  {
    id: 2,
    brand: "Casio",
    model: "CDP-S110",
    image: "https://images.unsplash.com/photo-1552422535-c45813c61732?w=600&h=400&fit=crop",
    price: 450000,
    location: "Đống Đa, Hà Nội",
    distance: "3.7 km",
    rating: 4.7,
    reviews: 89,
    features: ["88 phím", "Bluetooth", "64 âm thanh"],
    available: true
  },
  {
    id: 3,
    brand: "Roland",
    model: "FP-10",
    image: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&h=400&fit=crop",
    price: 650000,
    location: "Ba Đình, Hà Nội",
    distance: "4.1 km",
    rating: 4.9,
    reviews: 156,
    features: ["88 phím", "Bluetooth", "Loa tích hợp"],
    available: true
  },
  {
    id: 4,
    brand: "Yamaha",
    model: "P-125",
    image: "https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=600&h=400&fit=crop",
    price: 700000,
    location: "Hoàn Kiếm, Hà Nội",
    distance: "5.2 km",
    rating: 4.9,
    reviews: 201,
    features: ["88 phím", "MIDI USB", "24 âm thanh"],
    available: false
  },
  {
    id: 5,
    brand: "Casio",
    model: "PX-S1100",
    image: "https://images.unsplash.com/photo-1564186763535-ebb21ef5277f?w=600&h=400&fit=crop",
    price: 800000,
    location: "Tây Hồ, Hà Nội",
    distance: "6.8 km",
    rating: 4.8,
    reviews: 143,
    features: ["88 phím", "Bluetooth", "Cảm ứng lực"],
    available: true
  },
  {
    id: 6,
    brand: "Roland",
    model: "FP-30X",
    image: "https://images.unsplash.com/photo-1603992617591-c2e5e11dcf97?w=600&h=400&fit=crop",
    price: 900000,
    location: "Hai Bà Trưng, Hà Nội",
    distance: "3.9 km",
    rating: 5.0,
    reviews: 98,
    features: ["88 phím", "Bluetooth", "Premium sound"],
    available: true
  },
];

export default function PianosPage() {
  return (
    <main className="min-h-screen bg-gray-50 py-8">
      <div className="container mx-auto px-4">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-2">Thuê đàn Piano</h1>
          <p className="text-gray-600">Tìm thấy {pianos.length} đàn gần bạn</p>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-8">
          <div className="grid md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium mb-2">Thương hiệu</label>
              <select className="w-full border rounded-lg px-4 py-2">
                <option>Tất cả</option>
                <option>Yamaha</option>
                <option>Casio</option>
                <option>Roland</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Giá/tháng</label>
              <select className="w-full border rounded-lg px-4 py-2">
                <option>Tất cả</option>
                <option>Dưới 500k</option>
                <option>500k - 700k</option>
                <option>Trên 700k</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Khu vực</label>
              <select className="w-full border rounded-lg px-4 py-2">
                <option>Hà Nội</option>
                <option>TP. HCM</option>
                <option>Đà Nẵng</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Sắp xếp</label>
              <select className="w-full border rounded-lg px-4 py-2">
                <option>Gần nhất</option>
                <option>Giá thấp nhất</option>
                <option>Đánh giá cao nhất</option>
              </select>
            </div>
          </div>
        </div>

        {/* Piano Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {pianos.map((piano) => (
            <div key={piano.id} className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition">
              <div className="relative">
                <img 
                  src={piano.image} 
                  alt={`${piano.brand} ${piano.model}`}
                  className="w-full h-48 object-cover"
                />
                {!piano.available && (
                  <div className="absolute top-0 left-0 right-0 bottom-0 bg-black bg-opacity-50 flex items-center justify-center">
                    <span className="bg-red-500 text-white px-4 py-2 rounded-lg font-semibold">
                      Đang được thuê
                    </span>
                  </div>
                )}
                {piano.available && (
                  <div className="absolute top-3 right-3 bg-green-500 text-white px-3 py-1 rounded-full text-sm font-semibold">
                    Có sẵn
                  </div>
                )}
              </div>

              <div className="p-5">
                <div className="flex items-start justify-between mb-2">
                  <div>
                    <h3 className="text-xl font-bold">{piano.brand} {piano.model}</h3>
                    <div className="flex items-center text-sm text-gray-600 mt-1">
                      <MapPin className="w-4 h-4 mr-1" />
                      {piano.location} • {piano.distance}
                    </div>
                  </div>
                  <div className="flex items-center">
                    <Star className="w-4 h-4 text-yellow-400 fill-current" />
                    <span className="ml-1 font-semibold">{piano.rating}</span>
                    <span className="text-gray-500 text-sm ml-1">({piano.reviews})</span>
                  </div>
                </div>

                <div className="flex flex-wrap gap-2 my-3">
                  {piano.features.map((feature, i) => (
                    <span key={i} className="bg-gray-100 text-gray-700 px-3 py-1 rounded-full text-sm">
                      {feature}
                    </span>
                  ))}
                </div>

                <div className="flex items-center justify-between mt-4 pt-4 border-t">
                  <div>
                    <div className="text-2xl font-bold text-primary-600">
                      {piano.price.toLocaleString('vi-VN')}đ
                    </div>
                    <div className="text-sm text-gray-500">/ tháng</div>
                  </div>
                  <Link 
                    href={`/pianos/${piano.id}`}
                    className={`px-6 py-2 rounded-lg font-semibold transition ${
                      piano.available 
                        ? 'bg-primary-600 text-white hover:bg-primary-700' 
                        : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                    }`}
                  >
                    {piano.available ? 'Đặt thuê' : 'Hết hàng'}
                  </Link>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Benefits */}
        <div className="mt-16 bg-white rounded-lg shadow-md p-8">
          <h2 className="text-2xl font-bold mb-6 text-center">Tại sao nên thuê đàn qua Xpiano?</h2>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="bg-primary-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <TrendingUp className="w-8 h-8 text-primary-600" />
              </div>
              <h3 className="font-bold mb-2">Giá cả hợp lý</h3>
              <p className="text-gray-600 text-sm">
                Rẻ hơn 80% so với mua đàn mới. Phù hợp người mới bắt đầu.
              </p>
            </div>
            <div className="text-center">
              <div className="bg-primary-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <MapPin className="w-8 h-8 text-primary-600" />
              </div>
              <h3 className="font-bold mb-2">Ship tận nhà 24h</h3>
              <p className="text-gray-600 text-sm">
                Giao hàng nhanh trong nội thành Hà Nội. Đóng gói cẩn thận.
              </p>
            </div>
            <div className="text-center">
              <div className="bg-primary-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <Star className="w-8 h-8 text-primary-600" />
              </div>
              <h3 className="font-bold mb-2">Bảo hiểm toàn diện</h3>
              <p className="text-gray-600 text-sm">
                Mọi rủi ro trong quá trình sử dụng đều được bảo hiểm.
              </p>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
