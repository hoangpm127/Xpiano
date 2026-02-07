import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feed_item.dart';
import '../models/piano.dart';

import '../models/booking.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;


  // --- AUTH METHODS ---

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role},
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> updateUserMetadata({required String fullName, required String role}) async {
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
          .update({'status': 'cancelled'})
          .eq('id', id);
    } catch (e) {
      print('Error cancelling booking: $e');
      throw e;
    }
  }

  // --- INTERACTION METHODS ---

  Future<void> incrementLikes(int feedId, int currentCount) async {
    try {
      await _client
          .from('social_feed')
          .update({'likes_count': currentCount + 1})
          .eq('id', feedId);
    } catch (e) {
      print('Error incrementing likes: $e');
    }
  }

  Future<void> incrementComments(int feedId, int currentCount) async {
    try {
      await _client
          .from('social_feed')
          .update({'comments_count': currentCount + 1})
          .eq('id', feedId);
    } catch (e) {
      print('Error incrementing comments: $e');
    }
  }

  Future<void> incrementShares(int feedId, int currentCount) async {
    try {
      await _client
          .from('social_feed')
          .update({'shares_count': currentCount + 1})
          .eq('id', feedId);
    } catch (e) {
      print('Error incrementing shares: $e');
    }
  }
}

