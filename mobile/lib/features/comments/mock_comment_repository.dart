import 'dart:math';

import 'comment_models.dart';
import 'comments_repository.dart';

class MockCommentRepository implements CommentsRepository {
  @override
  Future<List<CommentUI>> fetchComments(String feedId) async {
    await Future.delayed(const Duration(milliseconds: 140));

    final random = Random(feedId.hashCode);
    final count = 6 + random.nextInt(5);
    final now = DateTime.now();

    return List.generate(count, (index) {
      final seed = random.nextInt(9999);
      final minuteOffset = 3 + (index * 7) + random.nextInt(15);

      return CommentUI(
        id: 'mock-$feedId-$seed-$index',
        userName: _mockNames[seed % _mockNames.length],
        avatarUrl: _mockAvatars[seed % _mockAvatars.length],
        text: _mockTexts[seed % _mockTexts.length],
        createdAt: now.subtract(Duration(minutes: minuteOffset)),
        liked: random.nextBool() && index % 3 == 0,
      );
    });
  }

  @override
  Future<CommentUI> postComment(String feedId, String text) async {
    await Future.delayed(const Duration(milliseconds: 120));

    return CommentUI(
      id: 'local-$feedId-${DateTime.now().microsecondsSinceEpoch}',
      userName: 'Bạn',
      avatarUrl: _currentUserAvatar,
      text: text,
      createdAt: DateTime.now(),
      liked: false,
    );
  }

  static const String _currentUserAvatar = 'https://i.pravatar.cc/80?img=3';

  static const List<String> _mockNames = [
    'Linh Piano',
    'Minh Anh',
    'Thảo My',
    'Quốc Bảo',
    'Hà Trâm',
    'An Nhiên',
    'Khánh Vy',
    'Hoàng Long',
    'Ngọc Châu',
    'Vũ Nam',
  ];

  static const List<String> _mockTexts = [
    'Bài này nghe cuốn quá ạ!',
    'Mình tập theo 3 ngày thấy tay mềm hơn thật.',
    'Có sheet nhạc đoạn này không bạn?',
    'Nhịp đoạn điệp khúc nên đếm thế nào ạ?',
    'Video rất dễ hiểu, cảm ơn thầy/cô!',
    'Mong có thêm series cho beginner.',
    'Âm thanh piano sạch và ấm quá.',
    'Bấm pedal ở phút nào là hợp lý nhất?',
    'Mình sẽ thử bài này tối nay.',
    'Tips quá hữu ích luôn!',
  ];

  static const List<String> _mockAvatars = [
    'https://i.pravatar.cc/80?img=11',
    'https://i.pravatar.cc/80?img=12',
    'https://i.pravatar.cc/80?img=13',
    'https://i.pravatar.cc/80?img=14',
    'https://i.pravatar.cc/80?img=15',
    'https://i.pravatar.cc/80?img=16',
    'https://i.pravatar.cc/80?img=17',
    'https://i.pravatar.cc/80?img=18',
    'https://i.pravatar.cc/80?img=19',
    'https://i.pravatar.cc/80?img=20',
  ];
}
