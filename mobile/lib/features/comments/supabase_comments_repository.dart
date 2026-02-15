import 'package:supabase_flutter/supabase_flutter.dart';

import 'comment_models.dart';
import 'comments_repository.dart';

class SupabaseCommentsRepository implements CommentsRepository {
  SupabaseCommentsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<CommentUI>> fetchComments(String feedId) async {
    final normalizedFeedId = _normalizeFeedId(feedId);
    final response = await _client
        .from('comments')
        .select('id, feed_id, user_id, content, created_at')
        .eq('feed_id', normalizedFeedId)
        .order('created_at', ascending: false);

    final rows = List<Map<String, dynamic>>.from(response as List);
    final userIds = rows
        .map((row) => row['user_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    final profileMap = await _fetchTeacherProfiles(userIds);

    return rows
        .map((row) => _mapRowToComment(
              row,
              profile: profileMap[row['user_id']?.toString()],
            ))
        .toList();
  }

  @override
  Future<CommentUI> postComment(String feedId, String text) async {
    final normalizedFeedId = _normalizeFeedId(feedId);
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Ban can dang nhap de binh luan.');
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw Exception('Noi dung binh luan khong duoc de trong.');
    }

    try {
      final inserted = await _client
          .from('comments')
          .insert({
            'feed_id': normalizedFeedId,
            'user_id': user.id,
            'content': trimmed,
          })
          .select('id, feed_id, user_id, content, created_at')
          .single();

      final profile = await _fetchTeacherProfile(user.id);
      return _mapRowToComment(
        Map<String, dynamic>.from(inserted),
        profile: profile ??
            _UserProfileSummary(
              name: _resolveUserNameFromAuth(user),
              avatarUrl: _resolveAvatarFromAuth(user),
            ),
      );
    } on PostgrestException catch (e) {
      throw Exception('Khong the gui binh luan: ${e.message}');
    }
  }

  Future<Map<String, _UserProfileSummary>> _fetchTeacherProfiles(
    Set<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};
    try {
      final response = await _client
          .from('teacher_profiles')
          .select('user_id, full_name, avatar_url')
          .inFilter('user_id', userIds.toList());

      final rows = List<Map<String, dynamic>>.from(response as List);
      final map = <String, _UserProfileSummary>{};
      for (final row in rows) {
        final userId = row['user_id']?.toString();
        if (userId == null || userId.isEmpty) continue;
        map[userId] = _UserProfileSummary(
          name: (row['full_name']?.toString().trim().isNotEmpty ?? false)
              ? row['full_name'].toString().trim()
              : _fallbackUserName(userId),
          avatarUrl: row['avatar_url']?.toString().trim(),
        );
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  Future<_UserProfileSummary?> _fetchTeacherProfile(String userId) async {
    try {
      final profile = await _client
          .from('teacher_profiles')
          .select('full_name, avatar_url')
          .eq('user_id', userId)
          .maybeSingle();
      if (profile == null) return null;
      return _UserProfileSummary(
        name: (profile['full_name']?.toString().trim().isNotEmpty ?? false)
            ? profile['full_name'].toString().trim()
            : _fallbackUserName(userId),
        avatarUrl: profile['avatar_url']?.toString().trim(),
      );
    } catch (_) {
      return null;
    }
  }

  CommentUI _mapRowToComment(
    Map<String, dynamic> row, {
    _UserProfileSummary? profile,
  }) {
    final userId = row['user_id']?.toString() ?? '';
    final userName = profile?.name ?? _fallbackUserName(userId);
    final avatarUrl = (profile?.avatarUrl?.isNotEmpty ?? false)
        ? profile!.avatarUrl!
        : _fallbackAvatar(userName);

    return CommentUI(
      id: row['id']?.toString() ?? '0',
      userName: userName,
      avatarUrl: avatarUrl,
      text: row['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.now(),
      liked: false,
    );
  }

  String _resolveUserNameFromAuth(User user) {
    final metadataName = user.userMetadata?['full_name']?.toString().trim();
    if (metadataName != null && metadataName.isNotEmpty) {
      return metadataName;
    }
    final email = user.email?.trim() ?? '';
    if (email.contains('@')) {
      final value = email.split('@').first.trim();
      if (value.isNotEmpty) return value;
    }
    return _fallbackUserName(user.id);
  }

  String _resolveAvatarFromAuth(User user) {
    final metadataAvatar = user.userMetadata?['avatar_url']?.toString().trim();
    if (metadataAvatar != null && metadataAvatar.isNotEmpty) {
      return metadataAvatar;
    }
    return _fallbackAvatar(_resolveUserNameFromAuth(user));
  }

  String _fallbackUserName(String userId) {
    if (userId.isEmpty) return 'Nguoi dung';
    final short = userId.length <= 6 ? userId : userId.substring(0, 6);
    return 'User $short';
  }

  String _fallbackAvatar(String seed) {
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(seed)}'
        '&background=E5E7EB&color=374151';
  }

  int _normalizeFeedId(String feedId) {
    final value = int.tryParse(feedId.trim());
    if (value == null) {
      throw Exception('Feed ID khong hop le: $feedId');
    }
    return value;
  }
}

class _UserProfileSummary {
  const _UserProfileSummary({
    required this.name,
    this.avatarUrl,
  });

  final String name;
  final String? avatarUrl;
}
