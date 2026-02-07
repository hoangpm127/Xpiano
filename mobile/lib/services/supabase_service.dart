import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feed_item.dart';
import '../models/piano.dart';

import '../models/booking.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch Social Feed
  Future<List<FeedItem>> getSocialFeed() async {
    try {
      final response = await _client
          .from('social_feed')
          .select()
          .order('created_at', ascending: false);

      if (response == null) {
        return [];
      }

      final List<FeedItem> feeds = (response as List)
          .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
          .toList();

      return feeds;
    } catch (e) {
      print('Error fetching social feed: $e');
      return [];
    }
  }

  // Fetch Pianos (Optional Category Filter)
  Future<List<Piano>> getPianos({String? category}) async {
    try {
      var query = _client.from('pianos').select().order('rating', ascending: false);
      
      if (category != null && category != 'All') {
        // Correct way to apply filter on PostgrestFilterBuilder
        // Since we cannot reassign query because types might mismatch if not cast properly
        // Let's chain it differently or use a different approach.
        // PostgrestFilterBuilder <T>
        final response = await _client
            .from('pianos')
            .select()
            .eq('category', category)
            .order('rating', ascending: false);
            
        final List<Piano> pianos = (response as List)
            .map((item) => Piano.fromJson(item as Map<String, dynamic>))
            .toList();
        return pianos;
      } else {
         final response = await _client
            .from('pianos')
            .select()
            .order('rating', ascending: false);
            
        final List<Piano> pianos = (response as List)
            .map((item) => Piano.fromJson(item as Map<String, dynamic>))
            .toList();
        return pianos;
      }
    } catch (e) {
      print('Error fetching pianos: $e');
      return [];
    }
  }

  // Create Booking
  Future<void> createBooking({
    required int pianoId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
  }) async {
    try {
      await _client.from('bookings').insert({
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

  // Increment like count
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

  // Add comment count
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

  // Add share count
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

  // Get User Bookings
  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _client
          .from('bookings')
          .select('*, pianos(name, image_url)')
          .order('start_time', ascending: false);
      
      if (response == null) return [];

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
}
