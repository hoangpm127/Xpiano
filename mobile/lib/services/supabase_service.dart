import 'dart:typed_data';
import 'dart:io';
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
  bool? _socialFeedHasMediaTypeCache;
  bool? _socialFeedHasAuthorIdCache;

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

  Future<Map<String, dynamic>?> getTeacherProfileByUserId(String userId) async {
    try {
      final response = await _client
          .from('teacher_profiles')
          .select('user_id, full_name, avatar_url, bio')
          .eq('user_id', userId)
          .maybeSingle();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching teacher profile by user id: $e');
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

  Future<String> uploadVideoToStorage({
    required String filePath,
    required String destPath,
    int maxRetries = 2,
    Duration timeout = const Duration(seconds: 120),
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Video file not found at path: $filePath');
    }

    if (destPath.trim().isEmpty) {
      throw Exception('Destination path is required');
    }

    int attempt = 0;
    Object? lastError;
    final storage = _client.storage.from('videos-feed');

    while (attempt <= maxRetries) {
      try {
        await storage
            .upload(
              destPath,
              file,
              fileOptions: const FileOptions(
                contentType: 'video/mp4',
                upsert: false,
              ),
            )
            .timeout(timeout);
        return storage.getPublicUrl(destPath);
      } catch (e) {
        lastError = e;
        attempt++;
        if (attempt > maxRetries) break;
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw Exception('Upload video failed: $lastError');
  }

  Future<Map<String, dynamic>> createSocialFeedPost({
    required String caption,
    required String mediaUrl,
    String mediaType = 'video',
    List<String> hashtags = const [],
  }) async {
    if (mediaUrl.trim().isEmpty) {
      throw Exception('mediaUrl is required');
    }

    final author = await _resolveCurrentAuthor();
    final payload = <String, dynamic>{
      'author_name': author.name,
      'author_avatar': author.avatarUrl ?? '',
      'caption': caption.trim(),
      'media_url': mediaUrl.trim(),
      'likes_count': 0,
      'comments_count': 0,
      'shares_count': 0,
      'hashtags': hashtags,
      'is_verified': false,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (await _socialFeedHasMediaTypeColumn()) {
      payload['media_type'] = mediaType;
    }
    if (await _socialFeedHasAuthorIdColumn()) {
      payload['author_id'] = currentUser?.id;
    }

    try {
      final inserted =
          await _client.from('social_feed').insert(payload).select().single();
      return Map<String, dynamic>.from(inserted);
    } on PostgrestException catch (e) {
      final needsTextId = (e.message).toLowerCase().contains('column "id"') &&
          (e.message.toLowerCase().contains('null') ||
              e.code == '23502' ||
              e.code == 'PGRST204');
      if (!needsTextId) rethrow;

      final fallbackPayload = Map<String, dynamic>.from(payload)
        ..['id'] = await _nextTextSocialFeedId();
      final inserted = await _client
          .from('social_feed')
          .insert(fallbackPayload)
          .select()
          .single();
      return Map<String, dynamic>.from(inserted);
    }
  }

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

  Future<FeedPageResult> getFollowingFeedPage({
    int limit = 12,
    FeedCursor? cursor,
  }) async {
    final user = currentUser;
    if (user == null) {
      return const FeedPageResult(
        items: [],
        nextCursor: null,
        hasMore: false,
      );
    }

    if (!await _socialFeedHasAuthorIdColumn()) {
      return const FeedPageResult(
        items: [],
        nextCursor: null,
        hasMore: false,
      );
    }

    try {
      final followRows = await _client
          .from('follows')
          .select('followee_id')
          .eq('follower_id', user.id);

      final followeeIds = (followRows as List)
          .map((row) =>
              row is Map<String, dynamic> ? row['followee_id']?.toString() : '')
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();

      if (followeeIds.isEmpty) {
        return const FeedPageResult(
          items: [],
          nextCursor: null,
          hasMore: false,
        );
      }

      dynamic query = _client
          .from('social_feed')
          .select()
          .inFilter('author_id', followeeIds)
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
      print('Error fetching following feed page: $e');
      return const FeedPageResult(
        items: [],
        nextCursor: null,
        hasMore: false,
      );
    }
  }

  Future<List<FeedItem>> getCreatorFeedItems({
    required String authorId,
    int limit = 30,
  }) async {
    if (!await _socialFeedHasAuthorIdColumn()) {
      return [];
    }

    try {
      final response = await _client
          .from('social_feed')
          .select()
          .eq('author_id', authorId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching creator feed items: $e');
      return [];
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

  Future<int> createBookingAtomic({
    required int pianoId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
    String status = 'confirmed',
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final result = await _client.rpc(
        'create_booking_atomic',
        params: {
          'p_piano_id': pianoId,
          'p_start': startTime.toUtc().toIso8601String(),
          'p_end': endTime.toUtc().toIso8601String(),
          'p_total_price': totalPrice,
          'p_status': status,
        },
      );

      if (result is int) return result;
      if (result is num) return result.toInt();
      if (result is String) {
        final parsed = int.tryParse(result.trim());
        if (parsed != null) return parsed;
      }
      throw Exception('Invalid booking response: $result');
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  // Backward-compatible wrapper
  Future<void> createBooking({
    required int pianoId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
  }) async {
    await createBookingAtomic(
      pianoId: pianoId,
      startTime: startTime,
      endTime: endTime,
      totalPrice: totalPrice,
    );
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
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      print('Error cancelling booking: $e');
      rethrow;
    }
  }

  // --- RENTAL METHODS ---

  Future<String> createRentalAtomic({
    required int pianoId,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
    required double depositAmount,
    String status = 'pending',
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final result = await _client.rpc(
        'create_rental_atomic',
        params: {
          'p_piano_id': pianoId,
          'p_start_date': _toDateOnly(startDate),
          'p_end_date': _toDateOnly(endDate),
          'p_total_price': totalPrice,
          'p_deposit_amount': depositAmount,
          'p_status': status,
        },
      );

      if (result is String && result.trim().isNotEmpty) {
        return result.trim();
      }
      if (result is Map && result['id'] != null) {
        return result['id'].toString();
      }
      throw Exception('Invalid rental response: $result');
    } catch (e) {
      print('Error creating rental: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMyRentals({int limit = 50}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('rentals')
          .select('*, pianos(id, name, image_url, daily_price, deposit_amount)')
          .eq('renter_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();
    } catch (e) {
      print('Error fetching rentals: $e');
      return [];
    }
  }

  Future<void> cancelRental(String rentalId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('rentals')
          .update({'status': 'cancelled'})
          .eq('id', rentalId)
          .eq('renter_id', user.id);
    } catch (e) {
      print('Error cancelling rental: $e');
      rethrow;
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

  Future<bool> isFollowing(String followeeId) async {
    final user = currentUser;
    if (user == null || followeeId.trim().isEmpty) return false;
    try {
      final row = await _client
          .from('follows')
          .select('follower_id')
          .eq('follower_id', user.id)
          .eq('followee_id', followeeId.trim())
          .maybeSingle();
      return row != null;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  Future<bool> toggleFollow(String followeeId) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    if (followeeId.trim().isEmpty) {
      throw Exception('followee_id is required');
    }

    try {
      final result = await _client.rpc(
        'toggle_follow',
        params: {'p_followee_id': followeeId.trim()},
      );

      if (result is bool) return result;
      if (result is num) return result > 0;
      if (result is String) {
        final normalized = result.trim().toLowerCase();
        return normalized == 'true' || normalized == '1';
      }
      return false;
    } catch (e) {
      print('Error toggling follow: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getProfileStats(String userId) async {
    if (userId.trim().isEmpty) {
      return const {
        'followers_count': 0,
        'following_count': 0,
        'posts_count': 0,
      };
    }
    try {
      final result = await _client
          .rpc('get_profile_stats', params: {'p_user_id': userId.trim()});

      if (result is Map<String, dynamic>) {
        return {
          'followers_count':
              int.tryParse(result['followers_count']?.toString() ?? '0') ?? 0,
          'following_count':
              int.tryParse(result['following_count']?.toString() ?? '0') ?? 0,
          'posts_count':
              int.tryParse(result['posts_count']?.toString() ?? '0') ?? 0,
        };
      }

      if (result is Map) {
        return {
          'followers_count':
              int.tryParse(result['followers_count']?.toString() ?? '0') ?? 0,
          'following_count':
              int.tryParse(result['following_count']?.toString() ?? '0') ?? 0,
          'posts_count':
              int.tryParse(result['posts_count']?.toString() ?? '0') ?? 0,
        };
      }
    } catch (e) {
      print('Error fetching profile stats: $e');
    }

    return const {
      'followers_count': 0,
      'following_count': 0,
      'posts_count': 0,
    };
  }

  Future<Set<String>> getSavedPostIds() async {
    final user = currentUser;
    if (user == null) return <String>{};

    try {
      final response = await _client
          .from('saved_posts')
          .select('feed_id')
          .eq('user_id', user.id);
      return (response as List)
          .map((row) =>
              row is Map<String, dynamic> ? row['feed_id']?.toString() : null)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (e) {
      print('Error fetching saved posts: $e');
      return <String>{};
    }
  }

  Future<void> savePost(String feedId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final normalizedFeedId = _normalizeFeedDbId(feedId);
    await _client.from('saved_posts').upsert(
      {
        'user_id': user.id,
        'feed_id': normalizedFeedId,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,feed_id',
    );
  }

  Future<void> unsavePost(String feedId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final normalizedFeedId = _normalizeFeedDbId(feedId);
    await _client
        .from('saved_posts')
        .delete()
        .eq('user_id', user.id)
        .eq('feed_id', normalizedFeedId);
  }

  Future<void> logShareEvent(String feedId) async {
    final user = currentUser;
    if (user == null) return;

    final normalizedFeedId = _normalizeFeedDbId(feedId);
    try {
      await _client.from('share_events').insert({
        'feed_id': normalizedFeedId,
        'user_id': user.id,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      print('Error logging share event: $e');
    }
  }

  Future<bool> recordView({
    required String feedId,
    required String sessionId,
  }) async {
    final normalizedFeedId = feedId.trim();
    if (normalizedFeedId.isEmpty) {
      throw Exception('feed_id is required');
    }

    try {
      final result = await _client.rpc(
        'record_view',
        params: {
          'p_feed_id': normalizedFeedId,
          'p_session_id': sessionId,
        },
      );

      if (result is bool) return result;
      if (result is num) return result > 0;
      if (result is String) {
        final normalized = result.trim().toLowerCase();
        return normalized == 'true' || normalized == '1';
      }
      return false;
    } catch (e) {
      print('Error recording view: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getShareEventCountsByFeedIds(
    Iterable<String> feedIds,
  ) async {
    final normalizedIds = <int>[];
    for (final raw in feedIds) {
      final parsed = int.tryParse(raw.trim());
      if (parsed != null) {
        normalizedIds.add(parsed);
      }
    }

    if (normalizedIds.isEmpty) {
      return <String, int>{};
    }

    try {
      final response = await _client
          .from('share_events')
          .select('feed_id')
          .inFilter('feed_id', normalizedIds);

      final counts = <String, int>{};
      for (final row in response as List) {
        if (row is! Map<String, dynamic>) continue;
        final feedId = row['feed_id']?.toString();
        if (feedId == null || feedId.isEmpty) continue;
        counts[feedId] = (counts[feedId] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      print('Error fetching share event counts: $e');
      return <String, int>{};
    }
  }

  Future<bool> _socialFeedHasMediaTypeColumn() async {
    if (_socialFeedHasMediaTypeCache != null) {
      return _socialFeedHasMediaTypeCache!;
    }
    try {
      await _client.from('social_feed').select('media_type').limit(1);
      _socialFeedHasMediaTypeCache = true;
    } catch (_) {
      _socialFeedHasMediaTypeCache = false;
    }
    return _socialFeedHasMediaTypeCache!;
  }

  Future<bool> _socialFeedHasAuthorIdColumn() async {
    if (_socialFeedHasAuthorIdCache != null) {
      return _socialFeedHasAuthorIdCache!;
    }
    try {
      await _client.from('social_feed').select('author_id').limit(1);
      _socialFeedHasAuthorIdCache = true;
    } catch (_) {
      _socialFeedHasAuthorIdCache = false;
    }
    return _socialFeedHasAuthorIdCache!;
  }

  int _normalizeFeedDbId(String feedId) {
    final parsed = int.tryParse(feedId.trim());
    if (parsed == null) {
      throw Exception('Invalid feed_id: $feedId');
    }
    return parsed;
  }

  Future<String> _nextTextSocialFeedId() async {
    final rows = await _client.from('social_feed').select('id');
    var maxId = 0;
    for (final row in rows as List) {
      final rawId = row is Map<String, dynamic> ? row['id'] : null;
      final parsed = int.tryParse(rawId?.toString() ?? '');
      if (parsed != null && parsed > maxId) {
        maxId = parsed;
      }
    }
    return (maxId + 1).toString();
  }

  String _toDateOnly(DateTime value) {
    final utc = DateTime.utc(value.year, value.month, value.day);
    return utc.toIso8601String().split('T').first;
  }

  Future<_AuthorData> _resolveCurrentAuthor() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    String? displayName = user.userMetadata?['full_name'] as String?;
    String? avatarUrl = user.userMetadata?['avatar_url'] as String?;

    try {
      final profile = await _client
          .from('teacher_profiles')
          .select('full_name, avatar_url')
          .eq('user_id', user.id)
          .maybeSingle();
      if (profile != null) {
        displayName = (profile['full_name'] as String?) ?? displayName;
        avatarUrl = (profile['avatar_url'] as String?) ?? avatarUrl;
      }
    } catch (_) {
      // Keep auth metadata fallback.
    }

    final fallbackName = user.email?.split('@').first ?? 'Teacher';
    return _AuthorData(
      name: (displayName?.trim().isNotEmpty ?? false)
          ? displayName!.trim()
          : fallbackName,
      avatarUrl: avatarUrl?.trim(),
    );
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

class _AuthorData {
  final String name;
  final String? avatarUrl;

  const _AuthorData({
    required this.name,
    required this.avatarUrl,
  });
}
