class FeedItem {
  final int id;
  final String dbId;
  final DateTime createdAt;
  final String authorName;
  final String? authorId;
  final String authorAvatar;
  final String caption;
  final String mediaUrl;
  final String mediaType;
  final String? videoUrl;
  final String? thumbUrl;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<String> hashtags;
  final bool isVerified;
  final String? location;
  final String? musicCredit;
  final String? pianoId; // ID of the piano associated with this video

  FeedItem({
    required this.id,
    required this.dbId,
    required this.createdAt,
    required this.authorName,
    this.authorId,
    required this.authorAvatar,
    required this.caption,
    required this.mediaUrl,
    this.mediaType = 'image',
    this.videoUrl,
    this.thumbUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.hashtags,
    required this.isVerified,
    this.location,
    this.musicCredit,
    this.pianoId,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final rawMediaUrl = (json['media_url'] as String?)?.trim() ?? '';
    final rawVideoUrl = (json['video_url'] as String?)?.trim();
    final rawThumbUrl = (json['thumb_url'] as String?)?.trim();
    final rawMediaType = (json['media_type'] as String?)?.trim().toLowerCase();
    final normalizedMediaType = (rawMediaType == null || rawMediaType.isEmpty)
        ? (_looksLikeVideo(rawMediaUrl) ? 'video' : 'image')
        : rawMediaType;

    final resolvedVideoUrl = (rawVideoUrl != null && rawVideoUrl.isNotEmpty)
        ? rawVideoUrl
        : ((normalizedMediaType == 'video' || _looksLikeVideo(rawMediaUrl))
            ? rawMediaUrl
            : null);

    final resolvedThumbUrl = (rawThumbUrl != null && rawThumbUrl.isNotEmpty)
        ? rawThumbUrl
        : (resolvedVideoUrl == null ? rawMediaUrl : null);

    return FeedItem(
      id: _parseFeedId(json['id']),
      dbId: _parseFeedDbId(json['id']),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      authorName: json['author_name'] as String? ?? 'Unknown',
      authorId: (json['author_id'] as String?)?.trim(),
      authorAvatar: json['author_avatar'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      mediaUrl: rawMediaUrl,
      mediaType: normalizedMediaType,
      videoUrl: resolvedVideoUrl,
      thumbUrl: resolvedThumbUrl,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      hashtags: json['hashtags'] != null
          ? List<String>.from(json['hashtags'] as List)
          : [],
      isVerified: json['is_verified'] as bool? ?? false,
      location: json['location'] as String?,
      musicCredit: json['music_credit'] as String?,
      pianoId: json['piano_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'db_id': dbId,
      'created_at': createdAt.toIso8601String(),
      'author_name': authorName,
      'author_id': authorId,
      'author_avatar': authorAvatar,
      'caption': caption,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'video_url': videoUrl,
      'thumb_url': thumbUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'hashtags': hashtags,
      'is_verified': isVerified,
      'location': location,
      'music_credit': musicCredit,
      'piano_id': pianoId,
    };
  }

  // Helper to format counts (1234 -> "1.2K")
  String formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String get formattedLikes => formatCount(likesCount);
  String get formattedComments => formatCount(commentsCount);
  String get formattedShares => formatCount(sharesCount);

  bool get isVideo => videoUrl != null && videoUrl!.isNotEmpty;

  static int _parseFeedId(dynamic rawId) {
    if (rawId is int) return rawId;
    if (rawId is String) {
      final parsed = int.tryParse(rawId.trim());
      if (parsed != null) return parsed;
      return rawId.hashCode.abs();
    }
    return 0;
  }

  static String _parseFeedDbId(dynamic rawId) {
    final value = rawId?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
    return '0';
  }

  static bool _looksLikeVideo(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.contains('.mp4?') ||
        lowerUrl.contains('/mp4');
  }
}
