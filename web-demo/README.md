# Xpiano Web Demo

Nền tảng học đàn & cho thuê Piano đầu tiên tại Việt Nam - Web Demo Version

## 🚀 Quick Start

### 1. Cài đặt dependencies

```bash
npm install
```

### 2. Chạy development server

```bash
npm run dev
```

### 3. Mở browser

Truy cập [http://localhost:3000](http://localhost:3000)

## 📁 Cấu trúc project

```
web-demo/
├── app/                      # Next.js 14 App Router
│   ├── page.tsx             # Landing page
│   ├── pianos/              # Trang thuê đàn
│   ├── teachers/            # Trang giáo viên
│   ├── demo-classroom/      # Demo lớp học online
│   ├── layout.tsx           # Root layout
│   └── globals.css          # Global styles
├── components/              # Reusable components
│   └── Navbar.tsx           # Navigation bar
├── lib/                     # Utility functions
│   └── utils.ts
├── public/                  # Static assets
└── package.json
```

## ✨ Features (Demo)

### ✅ Đã có trong demo:
- **Landing Page:** Hero section, features, testimonials
- **Piano Marketplace:** Browse, filter, sort danh sách đàn
- **Teacher Marketplace:** Danh sách giáo viên với profile
- **Demo Classroom:** Giao diện lớp học online với:
  - Video call simulation
  - MIDI keyboard visualization
  - Real-time chat
  - Controls (mic, camera, hang up)

### 🚧 Chưa có (cần implement thật):
- Authentication (login/signup)
- Backend API integration
- Payment gateway (VNPay/Momo)
- Real WebRTC video call
- Real Web MIDI API connection
- Database (PostgreSQL/Supabase)
- Booking system
- Admin dashboard

## 🎨 Design System

### Colors
- **Primary:** Blue (#0ea5e9 - sky-500)
- **Text:** Gray (#1f2937 - gray-800)
- **Background:** White/Gray-50

### Typography
- **Font:** Inter (system font)
- **Headings:** Bold, various sizes
- **Body:** Regular, 16px

## 🔧 Tech Stack

- **Framework:** Next.js 14 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **Icons:** Lucide React
- **Image:** Unsplash (placeholder)
- **Avatar:** Pravatar (placeholder)

## 📦 Scripts

```bash
# Development
npm run dev       # Start dev server (port 3000)

# Production
npm run build     # Build for production
npm run start     # Start production server

# Code quality
npm run lint      # Run ESLint
```

## 🌐 Pages

### 1. Home (`/`)
- Hero section với CTA buttons
- Feature showcase (3 cột)
- How it works (3 bước)
- Testimonials (3 reviews)
- Footer

### 2. Pianos (`/pianos`)
- Piano list với filter/sort
- 6 pianos mẫu
- Click vào card → navigate to `/pianos/[id]` (chưa implement)

### 3. Teachers (`/teachers`)
- Teacher list với profile cards
- 6 giáo viên mẫu
- Stats: experience, reviews, rating
- CTA: Book lesson

### 4. Demo Classroom (`/demo-classroom`)
- Live session simulation
- Video grid layout
- MIDI keyboard interactive
- Real-time chat
- Controls bar

## 🎯 Next Steps (Để làm thật)

### Phase 1: Infrastructure
1. Setup Supabase (PostgreSQL + Auth)
2. Create database schema
3. Setup API routes (`/app/api/`)
4. Implement authentication (NextAuth.js)

### Phase 2: Backend
5. Piano CRUD API
6. Teacher CRUD API
7. Booking system API
8. Payment integration (VNPay/Momo)
9. File upload (Cloudflare R2)

### Phase 3: Frontend
10. Connect forms to real API
11. Implement Web MIDI API
12. Implement WebRTC (simple-peer / mediasoup)
13. Add loading states, error handling
14. Add animations (framer-motion)

### Phase 4: Polish
15. SEO optimization (metadata)
16. Performance optimization (images, code splitting)
17. Add tests (Jest + React Testing Library)
18. Deploy to Vercel

## 🐛 Known Issues (Demo)

- Images load từ Unsplash (placeholder) → Cần upload ảnh thật
- Avatars từ Pravatar → Cần upload avatar thật
- Click vào piano/teacher detail → 404 (chưa có page)
- MIDI keyboard chỉ là demo UI (không connect device thật)
- Video call chỉ là static image (không có WebRTC)
- Chat không persist (refresh mất data)

## 💡 Tips

### Customize colors
Edit `tailwind.config.ts`:
```ts
theme: {
  extend: {
    colors: {
      primary: { ... } // Thay đổi màu chủ đạo
    }
  }
}
```

### Add new page
1. Create `app/new-page/page.tsx`
2. Add navigation link in `components/Navbar.tsx`

### Mock more data
Edit data arrays trong các page files (pianos, teachers)

## 📞 Support

- GitHub: [github.com/xpiano/web-demo]
- Email: dev@xpiano.vn

---

**Made with ❤️ by Xpiano Team**  
Demo version 0.1.0 - Jan 2026
