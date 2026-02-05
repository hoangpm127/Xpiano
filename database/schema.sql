-- ============================================
-- XPIANO MVP - DATABASE SCHEMA
-- Version: 1.0
-- Date: February 5, 2026
-- PostgreSQL 16
-- ============================================

-- Enable PostGIS for geolocation
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. USERS TABLE (với Affiliate Hierarchy)
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Basic Info
    phone VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    
    -- Role: student, teacher, partner, admin
    role VARCHAR(20) NOT NULL DEFAULT 'student' 
        CHECK (role IN ('student', 'teacher', 'partner', 'admin')),
    
    -- Affiliate Hierarchy (F1, F2 tracking)
    referrer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    referral_code VARCHAR(20) UNIQUE, -- xpiano.com/[referral_code]
    affiliate_tier INTEGER DEFAULT 0, -- Số tầng từ root
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- Index cho tìm kiếm referrer nhanh
CREATE INDEX idx_users_referrer ON users(referrer_id);
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_role ON users(role);

-- ============================================
-- 2. WALLETS TABLE (Ví hoa hồng)
-- ============================================
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Balance
    balance DECIMAL(15, 2) DEFAULT 0.00,
    pending_balance DECIMAL(15, 2) DEFAULT 0.00, -- Chờ xác nhận
    total_earned DECIMAL(15, 2) DEFAULT 0.00,    -- Tổng đã kiếm được
    total_withdrawn DECIMAL(15, 2) DEFAULT 0.00, -- Tổng đã rút
    
    -- Currency
    currency VARCHAR(3) DEFAULT 'VND',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id)
);

CREATE INDEX idx_wallets_user ON wallets(user_id);

-- ============================================
-- 3. WAREHOUSES TABLE (Kho đàn)
-- ============================================
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Info
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    district VARCHAR(100),
    city VARCHAR(100) NOT NULL,
    
    -- Geolocation (PostGIS)
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    
    -- Contact
    phone VARCHAR(15),
    email VARCHAR(255),
    
    -- Inventory Count (denormalized for performance)
    total_pianos INTEGER DEFAULT 0,
    available_pianos INTEGER DEFAULT 0,
    rented_pianos INTEGER DEFAULT 0,
    
    -- Operating Hours
    opening_time TIME DEFAULT '08:00',
    closing_time TIME DEFAULT '21:00',
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Rating
    avg_rating DECIMAL(2, 1) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Spatial index cho tìm kho gần nhất
CREATE INDEX idx_warehouses_location ON warehouses USING GIST(location);
CREATE INDEX idx_warehouses_partner ON warehouses(partner_id);
CREATE INDEX idx_warehouses_city ON warehouses(city);

-- ============================================
-- 4. PIANOS TABLE (Đàn piano)
-- ============================================
CREATE TABLE pianos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
    
    -- Piano Info
    brand VARCHAR(100) NOT NULL, -- Yamaha, Casio, Roland
    model VARCHAR(100) NOT NULL, -- P-45, CDP-S110, FP-10
    serial_number VARCHAR(100) UNIQUE,
    
    -- Specs
    keys_count INTEGER DEFAULT 88, -- 61, 76, 88
    has_midi BOOLEAN DEFAULT true,
    has_bluetooth BOOLEAN DEFAULT false,
    weight_kg DECIMAL(5, 2),
    
    -- Pricing
    daily_rate DECIMAL(10, 2) NOT NULL,
    weekly_rate DECIMAL(10, 2),
    monthly_rate DECIMAL(10, 2),
    deposit_amount DECIMAL(10, 2) DEFAULT 0,
    
    -- Status: available, rented, maintenance, retired
    status VARCHAR(20) NOT NULL DEFAULT 'available'
        CHECK (status IN ('available', 'rented', 'maintenance', 'retired')),
    
    -- Current rental (if rented)
    current_order_id UUID, -- Will be FK after orders table
    
    -- Media
    images JSONB DEFAULT '[]', -- Array of image URLs
    
    -- Condition
    condition VARCHAR(20) DEFAULT 'good'
        CHECK (condition IN ('new', 'excellent', 'good', 'fair', 'poor')),
    
    -- Rating
    avg_rating DECIMAL(2, 1) DEFAULT 0.0,
    total_rentals INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_pianos_warehouse ON pianos(warehouse_id);
CREATE INDEX idx_pianos_status ON pianos(status);
CREATE INDEX idx_pianos_brand ON pianos(brand);

-- ============================================
-- 5. ORDERS TABLE (Đơn thuê đàn)
-- ============================================
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(20) UNIQUE NOT NULL, -- XP-20260205-001
    
    -- Parties
    student_id UUID NOT NULL REFERENCES users(id),
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    piano_id UUID NOT NULL REFERENCES pianos(id),
    
    -- Rental Period
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    actual_return_date DATE,
    
    -- Delivery Address
    delivery_address TEXT NOT NULL,
    delivery_lat DECIMAL(10, 8),
    delivery_lng DECIMAL(11, 8),
    delivery_distance_km DECIMAL(6, 2),
    
    -- Pricing
    rental_days INTEGER NOT NULL,
    daily_rate DECIMAL(10, 2) NOT NULL,
    rental_amount DECIMAL(12, 2) NOT NULL,
    insurance_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_amount DECIMAL(10, 2) DEFAULT 0,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(12, 2) NOT NULL,
    deposit_amount DECIMAL(10, 2) DEFAULT 0,
    
    -- Payment
    payment_status VARCHAR(20) DEFAULT 'pending'
        CHECK (payment_status IN ('pending', 'paid', 'refunded', 'failed')),
    payment_method VARCHAR(20), -- vnpay, momo, bank_transfer
    payment_transaction_id VARCHAR(100),
    paid_at TIMESTAMP WITH TIME ZONE,
    
    -- Order Status
    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (status IN (
            'pending',      -- Chờ thanh toán
            'paid',         -- Đã thanh toán
            'confirmed',    -- Partner xác nhận
            'preparing',    -- Đang chuẩn bị
            'shipping',     -- Đang giao
            'delivered',    -- Đã giao
            'active',       -- Đang sử dụng
            'returning',    -- Đang trả
            'returned',     -- Đã trả
            'completed',    -- Hoàn thành
            'cancelled'     -- Đã hủy
        )),
    
    -- Shipping
    shipper_name VARCHAR(100),
    shipper_phone VARCHAR(15),
    tracking_code VARCHAR(50),
    estimated_delivery TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    
    -- Affiliate tracking
    referrer_id UUID REFERENCES users(id), -- Người giới thiệu student
    commission_processed BOOLEAN DEFAULT FALSE,
    
    -- Notes
    customer_note TEXT,
    partner_note TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_orders_student ON orders(student_id);
CREATE INDEX idx_orders_warehouse ON orders(warehouse_id);
CREATE INDEX idx_orders_piano ON orders(piano_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_referrer ON orders(referrer_id);
CREATE INDEX idx_orders_created ON orders(created_at DESC);

-- Add FK from pianos.current_order_id
ALTER TABLE pianos 
ADD CONSTRAINT fk_pianos_current_order 
FOREIGN KEY (current_order_id) REFERENCES orders(id) ON DELETE SET NULL;

-- ============================================
-- 6. COMMISSIONS TABLE (Hoa hồng Affiliate)
-- ============================================
CREATE TABLE commissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Related entities
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    affiliate_id UUID NOT NULL REFERENCES users(id), -- Người nhận hoa hồng
    source_user_id UUID NOT NULL REFERENCES users(id), -- Người tạo giao dịch
    
    -- Commission Details
    tier INTEGER NOT NULL CHECK (tier IN (1, 2)), -- Tầng 1 hoặc 2
    
    -- Amounts
    order_amount DECIMAL(12, 2) NOT NULL, -- Giá trị đơn hàng gốc
    commission_rate DECIMAL(5, 2) NOT NULL, -- Tỷ lệ % (5.00, 10.00, 12.00)
    commission_amount DECIMAL(12, 2) NOT NULL, -- Số tiền hoa hồng
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending'
        CHECK (status IN ('pending', 'approved', 'paid', 'cancelled')),
    
    -- Wallet transaction
    wallet_transaction_id UUID,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    approved_at TIMESTAMP WITH TIME ZONE,
    paid_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_commissions_order ON commissions(order_id);
CREATE INDEX idx_commissions_affiliate ON commissions(affiliate_id);
CREATE INDEX idx_commissions_source_user ON commissions(source_user_id);
CREATE INDEX idx_commissions_tier ON commissions(tier);
CREATE INDEX idx_commissions_status ON commissions(status);

-- ============================================
-- 7. WALLET_TRANSACTIONS TABLE (Lịch sử ví)
-- ============================================
CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    
    -- Transaction Type
    type VARCHAR(20) NOT NULL
        CHECK (type IN ('commission', 'withdrawal', 'refund', 'bonus', 'adjustment')),
    
    -- Direction
    direction VARCHAR(10) NOT NULL CHECK (direction IN ('credit', 'debit')),
    
    -- Amount
    amount DECIMAL(12, 2) NOT NULL,
    balance_before DECIMAL(15, 2) NOT NULL,
    balance_after DECIMAL(15, 2) NOT NULL,
    
    -- Reference
    reference_type VARCHAR(50), -- 'commission', 'order', 'withdrawal'
    reference_id UUID, -- commission_id, order_id, etc.
    
    -- Description
    description TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'completed'
        CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_wallet_transactions_wallet ON wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_type ON wallet_transactions(type);
CREATE INDEX idx_wallet_transactions_created ON wallet_transactions(created_at DESC);

-- ============================================
-- 8. CLASS_SESSIONS TABLE (Buổi học online)
-- ============================================
CREATE TABLE class_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Parties
    student_id UUID NOT NULL REFERENCES users(id),
    teacher_id UUID NOT NULL REFERENCES users(id),
    
    -- Scheduling
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    actual_start_at TIMESTAMP WITH TIME ZONE,
    actual_end_at TIMESTAMP WITH TIME ZONE,
    
    -- Session Info
    session_type VARCHAR(20) DEFAULT 'one_on_one'
        CHECK (session_type IN ('one_on_one', 'group', 'trial')),
    
    -- Pricing
    price DECIMAL(10, 2) NOT NULL,
    platform_fee DECIMAL(10, 2) DEFAULT 0,
    teacher_earning DECIMAL(10, 2) NOT NULL,
    
    -- Payment
    payment_status VARCHAR(20) DEFAULT 'pending'
        CHECK (payment_status IN ('pending', 'paid', 'refunded')),
    
    -- Status
    status VARCHAR(20) DEFAULT 'scheduled'
        CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'no_show')),
    
    -- Recording
    recording_url VARCHAR(500),
    midi_log_url VARCHAR(500),
    
    -- Room
    room_id VARCHAR(100),
    
    -- Affiliate tracking
    referrer_id UUID REFERENCES users(id),
    commission_processed BOOLEAN DEFAULT FALSE,
    
    -- Notes
    teacher_notes TEXT,
    student_feedback TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_class_sessions_student ON class_sessions(student_id);
CREATE INDEX idx_class_sessions_teacher ON class_sessions(teacher_id);
CREATE INDEX idx_class_sessions_scheduled ON class_sessions(scheduled_at);
CREATE INDEX idx_class_sessions_status ON class_sessions(status);

-- ============================================
-- 9. TEACHER_PROFILES TABLE (Hồ sơ giáo viên)
-- ============================================
CREATE TABLE teacher_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Bio
    bio TEXT,
    video_intro_url VARCHAR(500),
    
    -- Expertise
    specialties JSONB DEFAULT '[]', -- ["classical", "pop", "jazz"]
    experience_years INTEGER DEFAULT 0,
    education TEXT,
    certificates JSONB DEFAULT '[]',
    
    -- Pricing
    hourly_rate DECIMAL(10, 2) NOT NULL,
    trial_rate DECIMAL(10, 2), -- Giá buổi thử
    
    -- Availability
    available_slots JSONB DEFAULT '[]', -- Weekly schedule
    
    -- Teaching style
    teaching_style VARCHAR(50) -- "patient", "strict", "fun"
        CHECK (teaching_style IN ('patient', 'strict', 'fun', 'encouraging')),
    
    -- Stats (denormalized)
    avg_rating DECIMAL(2, 1) DEFAULT 0.0,
    total_students INTEGER DEFAULT 0,
    total_sessions INTEGER DEFAULT 0,
    total_hours INTEGER DEFAULT 0,
    
    -- Status
    is_verified BOOLEAN DEFAULT FALSE,
    is_accepting_students BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id)
);

CREATE INDEX idx_teacher_profiles_user ON teacher_profiles(user_id);
CREATE INDEX idx_teacher_profiles_rating ON teacher_profiles(avg_rating DESC);

-- ============================================
-- 10. FUNCTIONS & TRIGGERS
-- ============================================

-- Function: Generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number := 'XP-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
                        LPAD(NEXTVAL('order_number_seq')::TEXT, 3, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE IF NOT EXISTS order_number_seq START 1;

CREATE TRIGGER trg_orders_generate_number
    BEFORE INSERT ON orders
    FOR EACH ROW
    WHEN (NEW.order_number IS NULL)
    EXECUTE FUNCTION generate_order_number();

-- Function: Update timestamps
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER trg_users_updated BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_wallets_updated BEFORE UPDATE ON wallets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_warehouses_updated BEFORE UPDATE ON warehouses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_pianos_updated BEFORE UPDATE ON pianos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_orders_updated BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_class_sessions_updated BEFORE UPDATE ON class_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Function: Create wallet on user creation
CREATE OR REPLACE FUNCTION create_wallet_for_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO wallets (user_id) VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_create_wallet
    AFTER INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION create_wallet_for_user();

-- Function: Update warehouse inventory counts
CREATE OR REPLACE FUNCTION update_warehouse_inventory()
RETURNS TRIGGER AS $$
BEGIN
    -- Update counts after piano status change
    UPDATE warehouses
    SET 
        total_pianos = (SELECT COUNT(*) FROM pianos WHERE warehouse_id = COALESCE(NEW.warehouse_id, OLD.warehouse_id) AND status != 'retired'),
        available_pianos = (SELECT COUNT(*) FROM pianos WHERE warehouse_id = COALESCE(NEW.warehouse_id, OLD.warehouse_id) AND status = 'available'),
        rented_pianos = (SELECT COUNT(*) FROM pianos WHERE warehouse_id = COALESCE(NEW.warehouse_id, OLD.warehouse_id) AND status = 'rented'),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.warehouse_id, OLD.warehouse_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pianos_inventory
    AFTER INSERT OR UPDATE OR DELETE ON pianos
    FOR EACH ROW
    EXECUTE FUNCTION update_warehouse_inventory();

-- Function: Generate referral code
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.referral_code IS NULL THEN
        NEW.referral_code := LOWER(SUBSTRING(MD5(NEW.id::TEXT || NOW()::TEXT), 1, 8));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_referral_code
    BEFORE INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION generate_referral_code();

-- ============================================
-- 11. VIEWS FOR ANALYTICS
-- ============================================

-- View: Affiliate network with earnings
CREATE OR REPLACE VIEW v_affiliate_network AS
SELECT 
    u.id,
    u.full_name,
    u.referral_code,
    u.referrer_id,
    r.full_name as referrer_name,
    (SELECT COUNT(*) FROM users WHERE referrer_id = u.id) as f1_count,
    (SELECT COUNT(*) FROM users u2 WHERE u2.referrer_id IN (SELECT id FROM users WHERE referrer_id = u.id)) as f2_count,
    w.balance,
    w.total_earned
FROM users u
LEFT JOIN users r ON u.referrer_id = r.id
LEFT JOIN wallets w ON u.id = w.user_id;

-- View: Warehouse performance
CREATE OR REPLACE VIEW v_warehouse_performance AS
SELECT 
    w.id,
    w.name,
    w.city,
    w.total_pianos,
    w.available_pianos,
    w.rented_pianos,
    CASE WHEN w.total_pianos > 0 
         THEN ROUND((w.rented_pianos::DECIMAL / w.total_pianos) * 100, 2) 
         ELSE 0 END as utilization_rate,
    w.avg_rating,
    (SELECT COUNT(*) FROM orders WHERE warehouse_id = w.id AND status = 'completed') as total_orders,
    (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE warehouse_id = w.id AND payment_status = 'paid') as total_revenue
FROM warehouses w
WHERE w.is_active = true;

-- ============================================
-- 12. SAMPLE DATA FOR TESTING
-- ============================================

-- Insert sample admin
INSERT INTO users (phone, email, full_name, role, referral_code)
VALUES ('0901234567', 'admin@xpiano.vn', 'Admin Xpiano', 'admin', 'xpiadmin');

-- Insert sample partner
INSERT INTO users (phone, email, full_name, role, referral_code)
VALUES ('0901234568', 'partner1@xpiano.vn', 'Piano Store HN', 'partner', 'pianoHN');

-- Insert sample teacher
INSERT INTO users (phone, email, full_name, role, referral_code)
VALUES ('0901234569', 'teacher1@xpiano.vn', 'Cô Hương', 'teacher', 'cohuong');

-- Insert sample students (with referral hierarchy)
INSERT INTO users (phone, email, full_name, role, referral_code, referrer_id)
VALUES 
    ('0901234570', 'student1@gmail.com', 'Minh Anh', 'student', 'minhanh', 
     (SELECT id FROM users WHERE phone = '0901234569')), -- Referred by co Huong
    ('0901234571', 'student2@gmail.com', 'Tuấn Kiệt', 'student', 'tuankiet',
     (SELECT id FROM users WHERE phone = '0901234570')); -- Referred by Minh Anh (F2)

-- Insert sample warehouse
INSERT INTO warehouses (partner_id, name, address, city, location, phone)
VALUES (
    (SELECT id FROM users WHERE phone = '0901234568'),
    'Piano Store Hà Nội',
    '123 Xuân Thủy, Cầu Giấy',
    'Hà Nội',
    ST_SetSRID(ST_MakePoint(105.7827, 21.0356), 4326)::geography,
    '0241234567'
);

-- Insert sample pianos
INSERT INTO pianos (warehouse_id, brand, model, serial_number, daily_rate, monthly_rate, status)
SELECT 
    w.id,
    brand,
    model,
    'SN-' || brand || '-' || generate_series(1, 3)::text,
    daily_rate,
    monthly_rate,
    status
FROM warehouses w, 
(VALUES 
    ('Yamaha', 'P-45', 20000, 500000, 'available'),
    ('Casio', 'CDP-S110', 18000, 450000, 'available'),
    ('Roland', 'FP-10', 25000, 650000, 'rented')
) AS t(brand, model, daily_rate, monthly_rate, status)
LIMIT 3;

COMMIT;

-- ============================================
-- SCHEMA COMPLETE! ✅
-- ============================================
