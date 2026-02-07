class FeedItem {
  final int id;
  final String authorName;
  final String authorAvatar;
  final String caption;
  final String mediaUrl;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<String> hashtags;
  final bool isVerified;
  final String? location;
  final String? musicCredit;

  FeedItem({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.caption,
    required this.mediaUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.hashtags,
    required this.isVerified,
    this.location,
    this.musicCredit,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] as int,
      authorName: json['author_name'] as String? ?? 'Unknown',
      authorAvatar: json['author_avatar'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      mediaUrl: json['media_url'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      hashtags: json['hashtags'] != null
          ? List<String>.from(json['hashtags'] as List)
          : [],
      isVerified: json['is_verified'] as bool? ?? false,
      location: json['location'] as String?,
      musicCredit: json['music_credit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'caption': caption,
      'media_url': mediaUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'hashtags': hashtags,
      'is_verified': isVerified,
      'location': location,
      'music_credit': musicCredit,
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
}
