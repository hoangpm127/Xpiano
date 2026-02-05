# 🎹 Xpiano Backend - Setup Guide

## 📋 Prerequisites

- Node.js 18+ & npm
- PostgreSQL 16+ with PostGIS extension
- Redis 7+
- Git

---

## 🚀 Quick Start

### 1. Clone & Install

```bash
cd d:\Xpiano\backend
npm install
```

### 2. Setup PostgreSQL với PostGIS

**Option A: Docker (Recommended)**
```bash
docker run -d \
  --name xpiano-db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=xpiano \
  -e POSTGRES_DB=xpiano \
  -v xpiano-data:/var/lib/postgresql/data \
  postgis/postgis:16-3.4
```

**Option B: Local PostgreSQL**
```sql
-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### 3. Setup Redis

**Docker:**
```bash
docker run -d \
  --name xpiano-redis \
  -p 6379:6379 \
  redis:7-alpine
```

### 4. Environment Variables

```bash
cp .env.example .env
# Edit .env với thông tin database của bạn
```

### 5. Run Migrations

```bash
# Generate Prisma Client
npm run prisma:generate

# Run SQL schema
psql -U postgres -d xpiano -f ../database/schema.sql

# Or use Prisma migrations (alternative)
npx prisma migrate dev --name init
```

### 6. Start Development Server

```bash
npm run start:dev
```

Server sẽ chạy tại: **http://localhost:3000**  
API Docs (Swagger): **http://localhost:3000/api/docs**

---

## 📁 Project Structure

```
backend/
├── src/
│   ├── main.ts                 # Entry point
│   ├── app.module.ts           # Root module
│   ├── prisma/                 # Prisma service
│   ├── auth/                   # Authentication
│   └── modules/
│       ├── orders/            # ✅ Orders + Smart Dispatch
│       ├── commission/        # ✅ Commission processor
│       ├── wallet/            # ✅ Wallet management
│       ├── affiliate/         # 🔲 TODO
│       ├── classroom/         # 🔲 TODO
│       ├── warehouses/        # 🔲 TODO
│       ├── pianos/            # 🔲 TODO
│       └── users/             # 🔲 TODO
├── prisma/
│   └── schema.prisma          # Database schema
├── database/
│   └── schema.sql             # PostGIS SQL
└── package.json

✅ = Implemented
🔲 = TODO
```

---

## 🧪 Testing

### Test Smart Dispatch API

```bash
curl -X POST http://localhost:3000/api/v1/orders/find-nearest \
  -H "Content-Type: application/json" \
  -d '{
    "lat": 21.0285,
    "lng": 105.8542,
    "pianoType": "88",
    "radiusKm": 50
  }'
```

Expected response:
```json
[
  {
    "id": "...",
    "name": "Piano Store Hà Nội",
    "distanceKm": 2.35,
    "estimatedDeliveryHours": 1,
    "availablePianos": [...]
  }
]
```

### Test Commission Queue

1. Create order với referrerId
2. Payment callback → `status: "success"`
3. Check Bull Queue dashboard: http://localhost:3000/admin/queues (TODO: implement)
4. Verify commission records in database
5. Check wallet balance

---

## 🔐 Authentication (TODO)

```typescript
// auth/strategies/jwt.strategy.ts
// auth/guards/jwt-auth.guard.ts
```

---

## 📊 Database Queries

### Check PostGIS

```sql
SELECT PostGIS_Version();
```

### Find nearest warehouses (raw SQL)

```sql
SELECT 
  w.name,
  ST_Distance(
    ST_SetSRID(ST_MakePoint(w.lng, w.lat), 4326)::geography,
    ST_SetSRID(ST_MakePoint(105.8542, 21.0285), 4326)::geography
  ) / 1000 as distance_km
FROM warehouses w
ORDER BY distance_km ASC
LIMIT 5;
```

### Check commission processing

```sql
SELECT 
  c.tier,
  c.commission_amount,
  u.full_name as affiliate_name,
  o.order_number
FROM commissions c
JOIN users u ON c.affiliate_id = u.id
JOIN orders o ON c.order_id = o.id
ORDER BY c.created_at DESC
LIMIT 10;
```

---

## 🐛 Troubleshooting

### PostGIS not found
```bash
# Install PostGIS extension
sudo apt-get install postgresql-16-postgis-3
# or
brew install postgis
```

### Redis connection failed
```bash
# Check Redis is running
docker ps | grep redis
# or
redis-cli ping
```

### Prisma Client out of sync
```bash
npm run prisma:generate
```

---

## 📝 Next Steps

- [ ] Implement Auth module (JWT, Google, Zalo)
- [ ] Implement Affiliate module
- [ ] Implement Classroom module (WebRTC)
- [ ] Add payment gateway (VNPay, Momo)
- [ ] Setup Bull dashboard
- [ ] Add unit tests
- [ ] Setup CI/CD

---

## 📚 Resources

- [NestJS Docs](https://docs.nestjs.com/)
- [Prisma Docs](https://www.prisma.io/docs/)
- [PostGIS Docs](https://postgis.net/documentation/)
- [Bull Docs](https://github.com/OptimalBits/bull)
