/**
 * API Client Example cho Website (NextJS/React)
 * Sử dụng Supabase SDK để sync với Mobile App database
 */

import { createClient, SupabaseClient } from '@supabase/supabase-js';
import type {
  TeacherProfile,
  PublicTeacherProfile,
  TeacherSearchFilters,
  AdminDashboardStats,
  ApprovalAction,
  SupabaseUser,
  toPublicProfile,
} from './types';

// ============================================
// SUPABASE CLIENT SETUP
// ============================================

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY; // Server-side only

// Client-side: Sử dụng anon key (có RLS protection)
export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Server-side: Sử dụng service role key (bypass RLS - dùng cho admin)
export const supabaseAdmin = supabaseServiceRoleKey
  ? createClient(supabaseUrl, supabaseServiceRoleKey)
  : null;

// ============================================
// AUTH API
// ============================================

export class AuthAPI {
  /**
   * Đăng nhập bằng email & password
   */
  static async signIn(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    return { user: data.user, session: data.session, error };
  }

  /**
   * Đăng xuất
   */
  static async signOut() {
    const { error } = await supabase.auth.signOut();
    return { error };
  }

  /**
   * Lấy user hiện tại
   */
  static async getCurrentUser(): Promise<SupabaseUser | null> {
    const { data } = await supabase.auth.getUser();
    return data.user as SupabaseUser | null;
  }

  /**
   * Lấy session hiện tại
   */
  static async getSession() {
    const { data } = await supabase.auth.getSession();
    return data.session;
  }

  /**
   * Đổi mật khẩu
   */
  static async updatePassword(newPassword: string) {
    const { data, error } = await supabase.auth.updateUser({
      password: newPassword,
    });
    return { data, error };
  }

  /**
   * Gửi email reset password
   */
  static async resetPassword(email: string) {
    const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    });
    return { data, error };
  }
}

// ============================================
// TEACHER PROFILE API
// ============================================

export class TeacherAPI {
  /**
   * Lấy profile của giáo viên hiện tại (authenticated user)
   */
  static async getMyProfile(): Promise<TeacherProfile | null> {
    const user = await AuthAPI.getCurrentUser();
    if (!user) return null;

    const { data, error } = await supabase
      .from('teacher_profiles')
      .select('*')
      .eq('user_id', user.id)
      .single();

    if (error) {
      console.error('Error fetching teacher profile:', error);
      return null;
    }

    return data as TeacherProfile;
  }

  /**
   * Lấy public profile của 1 giáo viên (by user_id)
   */
  static async getTeacherById(userId: string): Promise<PublicTeacherProfile | null> {
    const { data, error } = await supabase
      .from('teacher_profiles')
      .select(`
        id,
        user_id,
        full_name,
        specializations,
        years_experience,
        bio,
        teach_online,
        teach_offline,
        locations,
        price_online,
        price_offline,
        bundle_8_sessions,
        bundle_8_discount,
        bundle_12_sessions,
        bundle_12_discount,
        allow_trial_lesson,
        avatar_url,
        video_demo_url,
        verification_status,
        approved_at,
        created_at,
        updated_at
      `)
      .eq('user_id', userId)
      .eq('verification_status', 'approved')
      .single();

    if (error) {
      console.error('Error fetching teacher:', error);
      return null;
    }

    return data as PublicTeacherProfile;
  }

  /**
   * Lấy danh sách tất cả giáo viên đã duyệt
   */
  static async getApprovedTeachers(): Promise<PublicTeacherProfile[]> {
    const { data, error } = await supabase
      .from('teacher_profiles')
      .select(`
        id,
        user_id,
        full_name,
        specializations,
        years_experience,
        bio,
        teach_online,
        teach_offline,
        locations,
        price_online,
        price_offline,
        bundle_8_sessions,
        bundle_8_discount,
        bundle_12_sessions,
        bundle_12_discount,
        allow_trial_lesson,
        avatar_url,
        video_demo_url,
        verification_status,
        approved_at,
        created_at,
        updated_at
      `)
      .eq('verification_status', 'approved')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching teachers:', error);
      return [];
    }

    return data as PublicTeacherProfile[];
  }

  /**
   * Tìm kiếm giáo viên với filters
   */
  static async searchTeachers(
    filters: TeacherSearchFilters
  ): Promise<PublicTeacherProfile[]> {
    let query = supabase
      .from('teacher_profiles')
      .select(`
        id,
        user_id,
        full_name,
        specializations,
        years_experience,
        bio,
        teach_online,
        teach_offline,
        locations,
        price_online,
        price_offline,
        bundle_8_sessions,
        bundle_8_discount,
        bundle_12_sessions,
        bundle_12_discount,
        allow_trial_lesson,
        avatar_url,
        video_demo_url,
        verification_status,
        approved_at,
        created_at,
        updated_at
      `)
      .eq('verification_status', 'approved');

    // Apply filters
    if (filters.specializations && filters.specializations.length > 0) {
      query = query.overlaps('specializations', filters.specializations);
    }

    if (filters.minExperience !== undefined) {
      query = query.gte('years_experience', filters.minExperience);
    }

    if (filters.maxExperience !== undefined) {
      query = query.lte('years_experience', filters.maxExperience);
    }

    if (filters.teachOnline !== undefined) {
      query = query.eq('teach_online', filters.teachOnline);
    }

    if (filters.teachOffline !== undefined) {
      query = query.eq('teach_offline', filters.teachOffline);
    }

    if (filters.locations && filters.locations.length > 0) {
      query = query.overlaps('locations', filters.locations);
    }

    if (filters.minPriceOnline !== undefined) {
      query = query.gte('price_online', filters.minPriceOnline);
    }

    if (filters.maxPriceOnline !== undefined) {
      query = query.lte('price_online', filters.maxPriceOnline);
    }

    if (filters.minPriceOffline !== undefined) {
      query = query.gte('price_offline', filters.minPriceOffline);
    }

    if (filters.maxPriceOffline !== undefined) {
      query = query.lte('price_offline', filters.maxPriceOffline);
    }

    if (filters.allowTrialLesson !== undefined) {
      query = query.eq('allow_trial_lesson', filters.allowTrialLesson);
    }

    // Sorting
    const sortBy = filters.sortBy || 'created_at';
    const sortOrder = filters.sortOrder || 'desc';
    query = query.order(sortBy, { ascending: sortOrder === 'asc' });

    const { data, error } = await query;

    if (error) {
      console.error('Error searching teachers:', error);
      return [];
    }

    return data as PublicTeacherProfile[];
  }

  /**
   * Subscribe to real-time changes (teacher profiles)
   */
  static subscribeToTeacherChanges(callback: (payload: any) => void) {
    return supabase
      .channel('teacher_profiles_changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'teacher_profiles',
          filter: 'verification_status=eq.approved',
        },
        callback
      )
      .subscribe();
  }
}

// ============================================
// ADMIN API (Server-side only)
// ============================================

export class AdminAPI {
  /**
   * Lấy thống kê dashboard
   */
  static async getDashboardStats(): Promise<AdminDashboardStats | null> {
    if (!supabaseAdmin) {
      console.error('Admin client not initialized');
      return null;
    }

    try {
      // Count teachers by status
      const { count: totalTeachers } = await supabaseAdmin
        .from('teacher_profiles')
        .select('*', { count: 'exact', head: true });

      const { count: pendingApprovals } = await supabaseAdmin
        .from('teacher_profiles')
        .select('*', { count: 'exact', head: true })
        .eq('verification_status', 'pending');

      const { count: approvedTeachers } = await supabaseAdmin
        .from('teacher_profiles')
        .select('*', { count: 'exact', head: true })
        .eq('verification_status', 'approved');

      const { count: rejectedTeachers } = await supabaseAdmin
        .from('teacher_profiles')
        .select('*', { count: 'exact', head: true })
        .eq('verification_status', 'rejected');

      // Count total users with role=student
      const { data: students } = await supabaseAdmin.auth.admin.listUsers();
      const totalStudents = students?.users.filter(
        (u) => u.user_metadata?.role === 'student'
      ).length || 0;

      // New registrations today
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const { count: newRegistrationsToday } = await supabaseAdmin
        .from('teacher_profiles')
        .select('*', { count: 'exact', head: true })
        .gte('created_at', today.toISOString());

      // New registrations this week
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);
      const { count: newRegistrationsThisWeek } = await supabaseAdmin
        .from('teacher_profiles')
        .select('*', { count: 'exact', head: true })
        .gte('created_at', weekAgo.toISOString());

      return {
        totalTeachers: totalTeachers || 0,
        pendingApprovals: pendingApprovals || 0,
        approvedTeachers: approvedTeachers || 0,
        rejectedTeachers: rejectedTeachers || 0,
        totalStudents,
        newRegistrationsToday: newRegistrationsToday || 0,
        newRegistrationsThisWeek: newRegistrationsThisWeek || 0,
      };
    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
      return null;
    }
  }

  /**
   * Lấy danh sách teacher profiles pending (có full data bao gồm CCCD, bank, etc.)
   */
  static async getPendingProfiles(): Promise<TeacherProfile[]> {
    if (!supabaseAdmin) {
      console.error('Admin client not initialized');
      return [];
    }

    const { data, error } = await supabaseAdmin
      .from('teacher_profiles')
      .select('*')
      .eq('verification_status', 'pending')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching pending profiles:', error);
      return [];
    }

    return data as TeacherProfile[];
  }

  /**
   * Lấy full profile của 1 teacher (bao gồm thông tin nhạy cảm - admin only)
   */
  static async getFullProfile(userId: string): Promise<TeacherProfile | null> {
    if (!supabaseAdmin) {
      console.error('Admin client not initialized');
      return null;
    }

    const { data, error } = await supabaseAdmin
      .from('teacher_profiles')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error) {
      console.error('Error fetching full profile:', error);
      return null;
    }

    return data as TeacherProfile;
  }

  /**
   * Duyệt hoặc từ chối profile
   */
  static async updateProfileStatus(action: ApprovalAction) {
    if (!supabaseAdmin) {
      console.error('Admin client not initialized');
      return { success: false, error: 'Admin client not initialized' };
    }

    const updateData: Partial<TeacherProfile> = {
      verification_status: action.status,
    };

    if (action.status === 'approved') {
      updateData.approved_at = action.approvedAt || new Date().toISOString();
      updateData.rejected_reason = null; // Clear rejection reason if any
    } else if (action.status === 'rejected') {
      updateData.rejected_reason = action.rejectedReason || 'No reason provided';
      updateData.approved_at = null;
    }

    const { data, error } = await supabaseAdmin
      .from('teacher_profiles')
      .update(updateData)
      .eq('user_id', action.userId)
      .select()
      .single();

    if (error) {
      console.error('Error updating profile status:', error);
      return { success: false, error: error.message };
    }

    return { success: true, data };
  }

  /**
   * Xóa teacher profile (hard delete)
   */
  static async deleteProfile(userId: string) {
    if (!supabaseAdmin) {
      console.error('Admin client not initialized');
      return { success: false, error: 'Admin client not initialized' };
    }

    const { error } = await supabaseAdmin
      .from('teacher_profiles')
      .delete()
      .eq('user_id', userId);

    if (error) {
      console.error('Error deleting profile:', error);
      return { success: false, error: error.message };
    }

    return { success: true };
  }

  /**
   * Lấy danh sách tất cả users (with pagination)
   */
  static async getAllUsers(page: number = 1, perPage: number = 50) {
    if (!supabaseAdmin) {
      console.error('Admin client not initialized');
      return { users: [], nextPage: null };
    }

    try {
      const { data, error } = await supabaseAdmin.auth.admin.listUsers({
        page,
        perPage,
      });

      if (error) throw error;

      return {
        users: data.users as SupabaseUser[],
        nextPage: data.users.length === perPage ? page + 1 : null,
      };
    } catch (error) {
      console.error('Error fetching users:', error);
      return { users: [], nextPage: null };
    }
  }
}

// ============================================
// STORAGE API
// ============================================

export class StorageAPI {
  /**
   * Lấy public URL của file trong storage
   */
  static getPublicUrl(bucket: string, filePath: string): string {
    const { data } = supabase.storage.from(bucket).getPublicUrl(filePath);
    return data.publicUrl;
  }

  /**
   * Upload file (authenticated users only)
   */
  static async uploadFile(
    bucket: string,
    filePath: string,
    file: File
  ): Promise<string | null> {
    const { data, error } = await supabase.storage
      .from(bucket)
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: false,
      });

    if (error) {
      console.error('Error uploading file:', error);
      return null;
    }

    return StorageAPI.getPublicUrl(bucket, data.path);
  }

  /**
   * Xóa file
   */
  static async deleteFile(bucket: string, filePath: string) {
    const { error } = await supabase.storage.from(bucket).remove([filePath]);

    if (error) {
      console.error('Error deleting file:', error);
      return { success: false, error: error.message };
    }

    return { success: true };
  }

  /**
   * List files in a folder
   */
  static async listFiles(bucket: string, folderPath: string) {
    const { data, error } = await supabase.storage.from(bucket).list(folderPath);

    if (error) {
      console.error('Error listing files:', error);
      return [];
    }

    return data;
  }
}

// ============================================
// USAGE EXAMPLES
// ============================================

/*
// 1. Login
const { user, error } = await AuthAPI.signIn('teacher@example.com', 'password123');

// 2. Get current user's teacher profile
const myProfile = await TeacherAPI.getMyProfile();

// 3. Search teachers
const teachers = await TeacherAPI.searchTeachers({
  specializations: ['Classical Piano', 'Jazz'],
  minExperience: 3,
  teachOnline: true,
  sortBy: 'years_experience',
  sortOrder: 'desc',
});

// 4. Get public teacher profile
const teacher = await TeacherAPI.getTeacherById('user-uuid-here');

// 5. Admin: Get dashboard stats (server-side only)
const stats = await AdminAPI.getDashboardStats();

// 6. Admin: Get pending profiles
const pendingProfiles = await AdminAPI.getPendingProfiles();

// 7. Admin: Approve a profile
await AdminAPI.updateProfileStatus({
  userId: 'user-uuid',
  status: 'approved',
  approvedAt: new Date().toISOString(),
});

// 8. Admin: Reject a profile
await AdminAPI.updateProfileStatus({
  userId: 'user-uuid',
  status: 'rejected',
  rejectedReason: 'CCCD không rõ ràng',
});

// 9. Real-time subscription
const subscription = TeacherAPI.subscribeToTeacherChanges((payload) => {
  console.log('Teacher profile updated:', payload);
  // Refresh UI here
});

// Clean up subscription
subscription.unsubscribe();

// 10. Upload avatar
const avatarUrl = await StorageAPI.uploadFile(
  'teacher-profiles',
  `${userId}/avatars/avatar.jpg`,
  avatarFile
);
*/
