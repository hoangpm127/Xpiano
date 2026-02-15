/**
 * TypeScript Types cho Website Integration
 * Sync với Supabase Database từ Mobile App
 */

// ============================================
// AUTH TYPES (từ auth.users)
// ============================================

export interface UserMetadata {
  full_name: string;
  role: 'student' | 'teacher';
}

export interface SupabaseUser {
  id: string; // UUID
  email: string;
  email_confirmed_at?: string | null;
  user_metadata: UserMetadata;
  created_at: string;
  updated_at: string;
  last_sign_in_at?: string | null;
}

// ============================================
// TEACHER PROFILE TYPES (từ teacher_profiles)
// ============================================

export type VerificationStatus = 'pending' | 'approved' | 'rejected';

export type Specialization = 
  | 'Classical Piano'
  | 'Jazz'
  | 'Pop'
  | 'Blues'
  | 'Rock'
  | 'Children Education'
  | 'Music Theory'
  | 'Other';

export interface TeacherProfile {
  // Định danh
  id: string; // UUID
  user_id: string; // UUID - Link to auth.users
  
  // Step 1: Thông tin cơ bản
  full_name: string;
  specializations: Specialization[];
  years_experience: number;
  bio: string | null;
  teach_online: boolean;
  teach_offline: boolean;
  locations: string[]; // VD: ["Quận 1, TP.HCM", "Quận 3, TP.HCM"]
  
  // Step 2: Giá và gói
  price_online: number | null; // VNĐ (VD: 250000)
  price_offline: number | null; // VNĐ (VD: 350000)
  bundle_8_sessions: number; // Default: 8
  bundle_8_discount: number; // % (VD: 10)
  bundle_12_sessions: number; // Default: 12
  bundle_12_discount: number; // % (VD: 15)
  allow_trial_lesson: boolean;
  
  // Step 3: Xác minh & Ngân hàng (PRIVATE - Admin only)
  id_number: string | null; // Số CCCD/CMND
  id_front_url: string | null; // URL ảnh mặt trước
  id_back_url: string | null; // URL ảnh mặt sau
  bank_name: string | null;
  bank_account: string | null;
  account_holder: string | null;
  certificates_description: string | null;
  certificate_urls: string[]; // Array URLs ảnh chứng chỉ
  
  // Media
  avatar_url: string | null;
  video_demo_url: string | null;
  
  // Trạng thái duyệt
  verification_status: VerificationStatus;
  rejected_reason: string | null;
  approved_at: string | null; // ISO timestamp
  
  // Metadata
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
}

// ============================================
// PUBLIC TEACHER PROFILE (Safe to expose)
// ============================================

export interface PublicTeacherProfile {
  // Định danh
  id: string;
  user_id: string;
  
  // Thông tin cơ bản
  full_name: string;
  specializations: Specialization[];
  years_experience: number;
  bio: string | null;
  teach_online: boolean;
  teach_offline: boolean;
  locations: string[];
  
  // Giá (hiển thị cho học viên)
  price_online: number | null;
  price_offline: number | null;
  bundle_8_sessions: number;
  bundle_8_discount: number;
  bundle_12_sessions: number;
  bundle_12_discount: number;
  allow_trial_lesson: boolean;
  
  // Media công khai
  avatar_url: string | null;
  video_demo_url: string | null;
  
  // Status
  verification_status: VerificationStatus; // Always 'approved' for public
  approved_at: string | null;
  
  // Metadata
  created_at: string;
  updated_at: string;
}

// ============================================
// API RESPONSE TYPES
// ============================================

export interface ApiResponse<T> {
  data: T | null;
  error: ApiError | null;
}

export interface ApiError {
  message: string;
  code?: string;
  details?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  count: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

// ============================================
// FILTER & SEARCH TYPES
// ============================================

export interface TeacherSearchFilters {
  specializations?: Specialization[];
  minExperience?: number;
  maxExperience?: number;
  teachOnline?: boolean;
  teachOffline?: boolean;
  locations?: string[];
  minPriceOnline?: number;
  maxPriceOnline?: number;
  minPriceOffline?: number;
  maxPriceOffline?: number;
  allowTrialLesson?: boolean;
  sortBy?: 'created_at' | 'years_experience' | 'price_online' | 'price_offline';
  sortOrder?: 'asc' | 'desc';
}

// ============================================
// ADMIN TYPES
// ============================================

export interface AdminDashboardStats {
  totalTeachers: number;
  pendingApprovals: number;
  approvedTeachers: number;
  rejectedTeachers: number;
  totalStudents: number;
  newRegistrationsToday: number;
  newRegistrationsThisWeek: number;
}

export interface ApprovalAction {
  userId: string;
  status: 'approved' | 'rejected';
  rejectedReason?: string;
  approvedAt?: string;
}

// ============================================
// BOOKING TYPES (Future feature)
// ============================================

export interface BookingRequest {
  teacher_id: string;
  student_id: string;
  session_type: 'online' | 'offline';
  package_type: 'single' | 'bundle_8' | 'bundle_12' | 'trial';
  preferred_date: string; // ISO date
  preferred_time: string; // HH:mm
  message?: string;
}

export interface Booking {
  id: string;
  teacher_id: string;
  student_id: string;
  session_type: 'online' | 'offline';
  package_type: 'single' | 'bundle_8' | 'bundle_12' | 'trial';
  scheduled_at: string;
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed';
  price: number;
  notes?: string;
  created_at: string;
  updated_at: string;
}

// ============================================
// UTILITY TYPES
// ============================================

export type DatabaseTables = {
  teacher_profiles: TeacherProfile;
  // Thêm các tables khác khi cần
};

export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

// ============================================
// CONSTANTS
// ============================================

export const SPECIALIZATIONS: Specialization[] = [
  'Classical Piano',
  'Jazz',
  'Pop',
  'Blues',
  'Rock',
  'Children Education',
  'Music Theory',
  'Other',
];

export const VIETNAMESE_BANKS = [
  'Vietcombank',
  'VietinBank',
  'BIDV',
  'Agribank',
  'Techcombank',
  'MBBank',
  'ACB',
  'VPBank',
  'TPBank',
  'Sacombank',
  'HDBank',
  'VIB',
  'SHB',
  'SeABank',
  'MSB',
  'OCB',
  'VietCapital Bank',
  'BacABank',
  'Kienlongbank',
  'PGBank',
] as const;

export type VietnameseBank = typeof VIETNAMESE_BANKS[number];

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Tính giá sau giảm cho bundle
 */
export function calculateBundlePrice(
  singlePrice: number,
  sessions: number,
  discountPercent: number
): number {
  const totalPrice = singlePrice * sessions;
  const discount = (totalPrice * discountPercent) / 100;
  return Math.round(totalPrice - discount);
}

/**
 * Format giá VNĐ
 */
export function formatVND(amount: number): string {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(amount);
}

/**
 * Convert teacher profile to public profile (loại bỏ thông tin nhạy cảm)
 */
export function toPublicProfile(profile: TeacherProfile): PublicTeacherProfile {
  const {
    id_number,
    id_front_url,
    id_back_url,
    bank_name,
    bank_account,
    account_holder,
    certificates_description,
    certificate_urls,
    rejected_reason,
    ...publicData
  } = profile;
  
  return publicData as PublicTeacherProfile;
}

/**
 * Check if user is teacher
 */
export function isTeacher(user: SupabaseUser): boolean {
  return user.user_metadata.role === 'teacher';
}

/**
 * Check if user is student
 */
export function isStudent(user: SupabaseUser): boolean {
  return user.user_metadata.role === 'student';
}

/**
 * Validate email format
 */
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Get avatar fallback URL (first letter of name)
 */
export function getAvatarFallback(fullName: string): string {
  const initial = fullName.charAt(0).toUpperCase();
  return `https://ui-avatars.com/api/?name=${initial}&background=random&size=200`;
}

/**
 * Parse storage URL to get file path
 */
export function parseStorageUrl(url: string): { 
  bucket: string; 
  path: string; 
} | null {
  try {
    const urlObj = new URL(url);
    const pathParts = urlObj.pathname.split('/');
    const bucketIndex = pathParts.indexOf('public');
    
    if (bucketIndex === -1) return null;
    
    const bucket = pathParts[bucketIndex + 1];
    const path = pathParts.slice(bucketIndex + 2).join('/');
    
    return { bucket, path };
  } catch {
    return null;
  }
}
