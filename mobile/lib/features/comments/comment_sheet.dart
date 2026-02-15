import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'comment_models.dart';
import 'comments_repository.dart';

class CommentSheet extends StatefulWidget {
  final String feedItemId;
  final int initialCount;
  final CommentsRepository repository;
  final ValueChanged<int>? onCountChanged;

  const CommentSheet({
    super.key,
    required this.feedItemId,
    required this.initialCount,
    required this.repository,
    this.onCountChanged,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<CommentUI> _comments = [];

  bool _isLoading = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await widget.repository.fetchComments(widget.feedItemId);
      if (!mounted) return;

      setState(() {
        _comments
          ..clear()
          ..addAll(result);
        _isLoading = false;
      });
      _emitCount();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Khong the tai binh luan', style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _postComment() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isPosting) return;

    final optimistic = CommentUI(
      id: 'optimistic-${DateTime.now().microsecondsSinceEpoch}',
      userName: 'Ban',
      avatarUrl: 'https://i.pravatar.cc/80?img=3',
      text: text,
      createdAt: DateTime.now(),
      liked: false,
    );

    setState(() {
      _isPosting = true;
      _comments.insert(0, optimistic);
      _inputController.clear();
    });
    _emitCount();

    try {
      final persisted =
          await widget.repository.postComment(widget.feedItemId, text);
      if (!mounted) return;

      final optimisticIndex = _comments.indexWhere((c) => c.id == optimistic.id);
      if (optimisticIndex != -1) {
        setState(() {
          _comments[optimisticIndex] = persisted;
        });
      }

      await _loadComments(showLoading: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _comments.removeWhere((c) => c.id == optimistic.id);
        _inputController.text = text;
      });
      _emitCount();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Gui binh luan that bai: $e', style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  void _toggleCommentLike(String commentId) {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;

    setState(() {
      final current = _comments[index];
      _comments[index] = current.copyWith(liked: !current.liked);
    });
  }

  void _emitCount() {
    widget.onCountChanged?.call(_comments.length);
  }

  String _formatTime(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'vua xong';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final displayCount =
        (_comments.isEmpty && _isLoading) ? widget.initialCount : _comments.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.45,
      maxChildSize: 0.90,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Binh luan ($displayCount)',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? Center(
                            child: Text(
                              'Chua co binh luan nao',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF6B7280),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage:
                                        NetworkImage(comment.avatarUrl),
                                    backgroundColor: const Color(0xFFE5E7EB),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          comment.text,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            height: 1.35,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatTime(comment.createdAt),
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _toggleCommentLike(comment.id),
                                    child: Icon(
                                      comment.liked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 18,
                                      color: comment.liked
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemCount: _comments.length,
                          ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: TextField(
                            controller: _inputController,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _postComment(),
                            decoration: InputDecoration(
                              hintText: 'Them binh luan...',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isPosting ? null : _postComment,
                        icon: _isPosting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Color(0xFF111827),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
