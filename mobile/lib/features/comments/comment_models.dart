class CommentUI {
  final String id;
  final String userName;
  final String avatarUrl;
  final String text;
  final DateTime createdAt;
  final bool liked;

  const CommentUI({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.text,
    required this.createdAt,
    this.liked = false,
  });

  CommentUI copyWith({
    String? id,
    String? userName,
    String? avatarUrl,
    String? text,
    DateTime? createdAt,
    bool? liked,
  }) {
    return CommentUI(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      liked: liked ?? this.liked,
    );
  }
}
