import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feed_item.dart';
import '../models/piano.dart';

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

  // Fetch Pianos
  Future<List<Piano>> getPianos() async {
    try {
      final response = await _client
          .from('pianos')
          .select()
          .order('rating', ascending: false);

      if (response == null) {
        return [];
      }

      final List<Piano> pianos = (response as List)
          .map((item) => Piano.fromJson(item as Map<String, dynamic>))
          .toList();

      return pianos;
    } catch (e) {
      print('Error fetching pianos: $e');
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
}
