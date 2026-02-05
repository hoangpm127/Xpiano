"use client";

import Link from "next/link";
import { useState } from "react";
import { Menu, X, Piano } from "lucide-react";

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <nav className="bg-white shadow-md sticky top-0 z-50">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <Link href="/" className="flex items-center space-x-2">
            <Piano className="w-8 h-8 text-primary-600" />
            <span className="text-2xl font-bold text-gray-900">Xpiano</span>
          </Link>

          {/* Desktop Menu */}
          <div className="hidden md:flex items-center space-x-8">
            <Link href="/pianos" className="text-gray-700 hover:text-primary-600 font-medium">
              Thuê đàn
            </Link>
            <Link href="/teachers" className="text-gray-700 hover:text-primary-600 font-medium">
              Tìm giáo viên
            </Link>
            <Link href="#" className="text-gray-700 hover:text-primary-600 font-medium">
              Về chúng tôi
            </Link>
            <Link 
              href="/login" 
              className="bg-primary-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-primary-700 transition"
            >
              Đăng nhập
            </Link>
          </div>

          {/* Mobile Menu Button */}
          <button
            className="md:hidden"
            onClick={() => setIsOpen(!isOpen)}
          >
            {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>

        {/* Mobile Menu */}
        {isOpen && (
          <div className="md:hidden py-4 border-t">
            <div className="flex flex-col space-y-4">
              <Link href="/pianos" className="text-gray-700 hover:text-primary-600 font-medium">
                Thuê đàn
              </Link>
              <Link href="/teachers" className="text-gray-700 hover:text-primary-600 font-medium">
                Tìm giáo viên
              </Link>
              <Link href="#" className="text-gray-700 hover:text-primary-600 font-medium">
                Về chúng tôi
              </Link>
              <Link 
                href="/login" 
                className="bg-primary-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-primary-700 transition text-center"
              >
                Đăng nhập
              </Link>
            </div>
          </div>
        )}
      </div>
    </nav>
  );
}
