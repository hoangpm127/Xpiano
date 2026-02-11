import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feed_item.dart';
import '../models/piano.dart';

import '../models/booking.dart';

class FeedCursor {
  final DateTime createdAt;
  final int id;

  const FeedCursor({
    required this.createdAt,
    required this.id,
  });
}

class FeedPageResult {
  final List<FeedItem> items;
  final FeedCursor? nextCursor;
  final bool hasMore;

  const FeedPageResult({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- AUTH METHODS ---

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn(
      {required String email, required String password}) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Check if email already exists using RPC function
  Future<bool> emailExists(String email) async {
    try {
      // Call RPC function on Supabase to check email in auth.users
      final result = await _client
          .rpc('check_email_exists', params: {'email_to_check': email});
      return result == true;
    } catch (e) {
      print('Error checking email: $e');
      // If RPC not found, return false to allow registration attempt
      // Duplicate will be caught during signUp
      return false;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    // Sign up with email auto-confirm disabled (will be handled by OTP)
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role},
      emailRedirectTo: null, // Disable email confirmation link
    );

    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> updateUserMetadata(
      {required String fullName, required String role}) async {
    await _client.auth.updateUser(
      UserAttributes(data: {'full_name': fullName, 'role': role}),
    );
  }

  // --- OTP METHODS ---

  // 1. Send OTP to Email
  Future<void> sendEmailOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true, // Create user if not exists
    );
  }

  // 2. Verify OTP and Login
  Future<AuthResponse> verifyEmailOtp(String email, String token) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email, // or OtpType.magiclink depending on config
    );
  }

  // 3. Finalize Registration (Set Password & Metadata) calling update after verify
  Future<UserResponse> updateRegisterInfo({
    required String password,
    required String fullName,
    required String role,
  }) async {
    return await _client.auth.updateUser(
      UserAttributes(
        password: password,
        data: {'full_name': fullName, 'role': role},
      ),
    );
  }

  // --- STORAGE METHODS ---

  // Upload image to Supabase Storage
  Future<String> uploadImage({
    required Uint8List fileBytes,
    required String fileName,
    required String folder, // e.g., 'avatars', 'id_cards', 'certificates'
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 60), // Default 60s
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final filePath = '$userId/$folder/$fileName';

    // Check file size (max 50MB)
    final fileSizeMB = fileBytes.length / (1024 * 1024);
    if (fileSizeMB > 50) {
      throw Exception(
          'File quá lớn (${fileSizeMB.toStringAsFixed(1)}MB). Tối đa 50MB');
    }

    // Retry logic with exponential backoff
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await _client.storage
            .from('teacher-profiles')
            .uploadBinary(filePath, fileBytes)
            .timeout(timeout);

        return _client.storage.from('teacher-profiles').getPublicUrl(filePath);
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow; // Throw error after max retries
        }
        // Wait before retry (exponential backoff: 2s, 4s, 8s...)
        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }

    throw Exception('Upload failed after $maxRetries attempts');
  }

  // Delete image from Supabase Storage
  Future<void> deleteImage(String url) async {
    try {
      // Extract file path from public URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('teacher-profiles');
      if (bucketIndex != -1 && pathSegments.length > bucketIndex + 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from('teacher-profiles').remove([filePath]);
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // --- TEACHER PROFILE METHODS ---

  // Create teacher profile
  Future<Map<String, dynamic>> createTeacherProfile(
      Map<String, dynamic> profileData) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final data = {
      'user_id': userId,
      ...profileData,
    };

    final response =
        await _client.from('teacher_profiles').insert(data).select().single();

    return response as Map<String, dynamic>;
  }

  // Update teacher profile
  Future<Map<String, dynamic>> updateTeacherProfile(
      Map<String, dynamic> profileData) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('teacher_profiles')
        .update(profileData)
        .eq('user_id', userId)
        .select()
        .single();

    return response as Map<String, dynamic>;
  }

  // Get teacher profile by user ID
  Future<Map<String, dynamic>?> getTeacherProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('teacher_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching teacher profile: $e');
      return null;
    }
  }

  // Get all approved teacher profiles
  Future<List<Map<String, dynamic>>> getApprovedTeachers() async {
    try {
      final response = await _client
          .from('teacher_profiles')
          .select()
          .eq('verification_status', 'approved')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching approved teachers: $e');
      return [];
    }
  }

  // --- FEED METHODS ---

  // Fetch Social Feed
  Future<List<FeedItem>> getSocialFeed() async {
    try {
      final response = await _client
          .from('social_feed')
          .select()
          .order('created_at', ascending: false);

      final List<FeedItem> feeds = (response as List)
          .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
          .toList();

      return feeds;
    } catch (e) {
      print('Error fetching social feed: $e');
      return [];
    }
  }

  Future<FeedPageResult> getSocialFeedPage({
    int limit = 12,
    FeedCursor? cursor,
  }) async {
    try {
      dynamic query = _client
          .from('social_feed')
          .select()
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .limit(limit);

      if (cursor != null) {
        final createdAtIso = cursor.createdAt.toUtc().toIso8601String();
        query = query.or(
          'created_at.lt.$createdAtIso,and(created_at.eq.$createdAtIso,id.lt.${cursor.id})',
        );
      }

      final response = await query;
      final items = (response as List)
          .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
          .toList();

      final hasMore = items.length == limit;
      FeedCursor? nextCursor;

      if (hasMore && items.isNotEmpty) {
        final last = items.last;
        nextCursor = FeedCursor(createdAt: last.createdAt, id: last.id);
      }

      return FeedPageResult(
        items: items,
        nextCursor: nextCursor,
        hasMore: hasMore,
      );
    } catch (e) {
      print('Error fetching social feed page: $e');
      return const FeedPageResult(
        items: [],
        nextCursor: null,
        hasMore: false,
      );
    }
  }

  // Stream Social Feed (real-time updates)
  Stream<List<FeedItem>> watchSocialFeed() {
    return _client
        .from('social_feed')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
            .toList());
  }

  // --- PIANO METHODS ---

  // Fetch Pianos (Optional Category Filter)
  Future<List<Piano>> getPianos({String? category}) async {
    try {
      if (category != null && category != 'All') {
        final response = await _client
            .from('pianos')
            .select()
            .eq('category', category)
            .order('rating', ascending: false);

        return (response as List)
            .map((item) => Piano.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        final response = await _client
            .from('pianos')
            .select()
            .order('rating', ascending: false);

        return (response as List)
            .map((item) => Piano.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error fetching pianos: $e');
      return [];
    }
  }

  // --- BOOKING METHODS ---

  // Create Booking
  Future<void> createBooking({
    required int pianoId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('bookings').insert({
        'user_id': user.id, // Securely use the auth user id
        'piano_id': pianoId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'total_price': totalPrice,
        'status': 'confirmed',
      });
    } catch (e) {
      print('Error creating booking: $e');
      throw e;
    }
  }

  // Get User Bookings
  Future<List<Booking>> getMyBookings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('bookings')
          .select('*, pianos(name, image_url)')
          .eq('user_id', user.id) // Filter by owner
          .order('start_time', ascending: false);

      final List<Booking> bookings = (response as List)
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();

      return bookings;
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  // Cancel Booking
  Future<void> cancelBooking(int id) async {
    try {
      await _client
          .from('bookings')
          .update({'status': 'cancelled'}).eq('id', id);
    } catch (e) {
      print('Error cancelling booking: $e');
      throw e;
    }
  }

  // --- INTERACTION METHODS ---

  Future<void> incrementLikesAtomic(int feedId) async {
    // Server-side atomic increment only. Requires one of these RPCs on DB:
    // - increment_social_feed_likes(p_feed_id integer)
    // - increment_likes(feed_id integer)
    try {
      await _client.rpc(
        'increment_social_feed_likes',
        params: {'p_feed_id': feedId},
      );
      return;
    } catch (_) {
      // Backward-compat fallback RPC name.
    }

    try {
      await _client.rpc(
        'increment_likes',
        params: {'feed_id': feedId},
      );
    } catch (e) {
      print('Error incrementing likes atomically: $e');
      rethrow;
    }
  }

  Future<void> incrementComments(int feedId, int currentCount) async {
    try {
      await _client
          .from('social_feed')
          .update({'comments_count': currentCount + 1}).eq('id', feedId);
    } catch (e) {
      print('Error incrementing comments: $e');
    }
  }

  Future<void> incrementShares(int feedId, int currentCount) async {
    try {
      await _client
          .from('social_feed')
          .update({'shares_count': currentCount + 1}).eq('id', feedId);
    } catch (e) {
      print('Error incrementing shares: $e');
    }
  }

  // --- ADMIN METHODS ---

  /// Approve all pending teacher profiles (for testing/admin purposes)
  Future<Map<String, dynamic>> approveAllPendingTeachers() async {
    try {
      // Get count of pending teachers
      final pendingTeachers = await _client
          .from('teacher_profiles')
          .select()
          .eq('verification_status', 'pending');

      final count = pendingTeachers.length;

      if (count == 0) {
        return {
          'success': true,
          'message': 'Không có giáo viên nào đang chờ duyệt',
          'count': 0,
        };
      }

      // Update all to approved
      await _client.from('teacher_profiles').update({
        'verification_status': 'approved',
        'approved_at': DateTime.now().toIso8601String(),
      }).eq('verification_status', 'pending');

      return {
        'success': true,
        'message': 'Đã duyệt $count giáo viên thành công',
        'count': count,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi: $e',
        'count': 0,
      };
    }
  }

  /// Get all teacher profiles with their verification status (for admin)
  Future<List<Map<String, dynamic>>> getAllTeacherProfiles() async {
    try {
      final response = await _client
          .from('teacher_profiles')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching all teacher profiles: $e');
      return [];
    }
  }
}
