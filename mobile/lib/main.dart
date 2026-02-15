import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'models/feed_item.dart';
import 'screens/create_video_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/piano_rental_screen.dart';
import 'screens/piano_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/teacher_public_profile_screen.dart';
import 'features/comments/comment_sheet.dart';
import 'features/comments/comments_repository.dart';
import 'features/comments/supabase_comments_repository.dart';
import 'widgets/feed_media_item.dart';
import 'widgets/login_bottom_sheet.dart'; // Import Login Sheet

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://pjgjusdmzxrhgiptfvbg.supabase.co',
    anonKey: 'sb_publishable_GMnCRFvRGqElGLerTiE-3g_YpGm-KoW',
  );

  // Make the status bar transparent for full-screen immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Enable edge-to-edge mode
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  runApp(const PianoSocialFeedApp());
}

class PianoSocialFeedApp extends StatelessWidget {
  const PianoSocialFeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xpiano',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD4AF37),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      // Use SplashScreen to check session on app start
      home: const SplashScreen(),
    );
  }
}

enum FeedScope {
  forYou,
  following,
}

class PianoFeedScreen extends StatefulWidget {
  const PianoFeedScreen({super.key});

  @override
  State<PianoFeedScreen> createState() => _PianoFeedScreenState();
}

class _PianoFeedScreenState extends State<PianoFeedScreen>
    with WidgetsBindingObserver {
  // Color Palette
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFFFFFFFF);

  final SupabaseService _supabaseService = SupabaseService();
  final CommentsRepository _commentRepository = SupabaseCommentsRepository();
  final PageController _pageController = PageController(keepPage: true);
  final List<FeedItem> _feedItems = [];
  FeedCursor? _nextCursor;
  int _currentFeedIndex = 0;
  bool _isInitialFeedLoading = true;
  bool _isLoadingMoreFeed = false;
  bool _hasMoreFeed = true;
  String? _feedError;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  bool _isHoldingToPause = false;
  int? _manuallyPausedItemId;
  int? _heartAnimatingItemId;
  IconData? _playbackFeedbackIcon;
  int? _playbackFeedbackItemId;
  final Set<int> _likedFeedIds = {};
  final Set<String> _savedFeedIds = {};
  final Set<int> _saveAnimatingFeedIds = {};
  final Set<int> _likeRequestsInFlight = {};
  final Set<String> _saveRequestsInFlight = {};
  final Set<int> _shareRequestsInFlight = {};
  final Map<int, int> _likeCountOverrides = {};
  final Map<int, int> _commentCountOverrides = {};
  final Map<int, int> _shareCountOverrides = {};
  Timer? _playbackFeedbackTimer;
  Timer? _pendingViewTimer;
  String? _pendingViewFeedId;
  final Set<String> _viewRequestsInFlight = {};
  final Set<String> _viewRecordedInSession = {};
  late final String _viewSessionId = _generateSessionId();

  DateTime? _lastTapDownAt;
  Offset? _lastTapDownPosition;
  int? _lastTapDownItemId;
  int? _pendingTapToggleItemId;
  bool _pendingTapToggleWasPaused = false;
  DateTime? _pendingTapToggleAt;

  static const int _feedPageSize = 12;
  int _selectedIndex = 0;
  FeedScope _feedScope = FeedScope.forYou;

  // Guest Mode State
  bool _isGuest = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthState();
    _loadInitialFeed();
  }

  void _checkAuthState() {
    final session = Supabase.instance.client.auth.currentSession;
    final isGuest = session == null;
    setState(() {
      _isGuest = isGuest;
      if (isGuest) {
        _savedFeedIds.clear();
      }
    });
    if (!isGuest) {
      unawaited(_loadSavedPosts());
      unawaited(_syncShareCountsFromDb());
    }
    if (_feedScope == FeedScope.following) {
      unawaited(_loadInitialFeed());
    }
  }

  Future<void> _loadInitialFeed() async {
    setState(() {
      _isInitialFeedLoading = true;
      _isLoadingMoreFeed = false;
      _hasMoreFeed = true;
      _feedError = null;
      _currentFeedIndex = 0;
      _resetPlaybackState();
      _nextCursor = null;
      _feedItems.clear();
      _shareCountOverrides.clear();
    });

    try {
      final FeedPageResult page;
      if (_feedScope == FeedScope.following) {
        if (_isGuest) {
          if (!mounted) return;
          setState(() {
            _isInitialFeedLoading = false;
            _hasMoreFeed = false;
            _feedItems.clear();
          });
          return;
        }
        page =
            await _supabaseService.getFollowingFeedPage(limit: _feedPageSize);
      } else {
        page = await _supabaseService.getSocialFeedPage(limit: _feedPageSize);
      }
      if (!mounted) return;

      setState(() {
        _feedItems.addAll(page.items);
        _nextCursor = page.nextCursor;
        _hasMoreFeed = page.hasMore;
        _isInitialFeedLoading = false;
      });
      _scheduleViewTrackingForActiveItem();
      unawaited(_syncShareCountsFromDb(items: page.items));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitialFeedLoading = false;
        _feedError = e.toString();
      });
    }
  }

  Future<void> _loadMoreFeedIfNeeded(int currentIndex) async {
    final remaining = _feedItems.length - 1 - currentIndex;
    if (remaining > 3 || !_hasMoreFeed || _isLoadingMoreFeed) {
      return;
    }

    setState(() {
      _isLoadingMoreFeed = true;
    });

    try {
      final FeedPageResult page;
      if (_feedScope == FeedScope.following) {
        page = await _supabaseService.getFollowingFeedPage(
          limit: _feedPageSize,
          cursor: _nextCursor,
        );
      } else {
        page = await _supabaseService.getSocialFeedPage(
          limit: _feedPageSize,
          cursor: _nextCursor,
        );
      }
      if (!mounted) return;

      final existingIds = _feedItems.map((item) => item.id).toSet();
      final newItems =
          page.items.where((item) => !existingIds.contains(item.id)).toList();

      setState(() {
        _feedItems.addAll(newItems);
        _nextCursor = page.nextCursor;
        _hasMoreFeed = page.hasMore && newItems.isNotEmpty;
        _isLoadingMoreFeed = false;
      });
      unawaited(_syncShareCountsFromDb(items: newItems));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMoreFeed = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playbackFeedbackTimer?.cancel();
    _cancelPendingViewTracking();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    setState(() {
      _appLifecycleState = state;
      if (state != AppLifecycleState.resumed) {
        _resetPlaybackState();
      }
    });
    _scheduleViewTrackingForActiveItem();
  }

  bool get _isFeedTabVisible => _selectedIndex == 0;

  bool get _isFeedPlaybackActive =>
      _isFeedTabVisible && _appLifecycleState == AppLifecycleState.resumed;

  int _effectiveLikesCount(FeedItem item) {
    return _likeCountOverrides[item.id] ?? item.likesCount;
  }

  int _effectiveCommentsCount(FeedItem item) {
    return _commentCountOverrides[item.id] ?? item.commentsCount;
  }

  int _effectiveSharesCount(FeedItem item) {
    return _shareCountOverrides[item.id] ?? item.sharesCount;
  }

  bool _isItemLiked(FeedItem item) {
    return _likedFeedIds.contains(item.id);
  }

  bool _isItemSaved(FeedItem item) {
    return _savedFeedIds.contains(item.dbId);
  }

  Future<void> _loadSavedPosts() async {
    try {
      final savedIds = await _supabaseService.getSavedPostIds();
      if (!mounted) return;
      setState(() {
        _savedFeedIds
          ..clear()
          ..addAll(savedIds);
      });
    } catch (_) {
      // Keep local empty state on failure.
    }
  }

  Future<void> _syncShareCountsFromDb({List<FeedItem>? items}) async {
    if (_isGuest) return;
    final targetItems = items ?? _feedItems;
    if (targetItems.isEmpty) return;

    try {
      final counts = await _supabaseService.getShareEventCountsByFeedIds(
        targetItems.map((item) => item.dbId),
      );
      if (!mounted) return;
      setState(() {
        for (final item in targetItems) {
          final dbCount = counts[item.dbId] ?? 0;
          _shareCountOverrides[item.id] =
              dbCount > item.sharesCount ? dbCount : item.sharesCount;
        }
      });
    } catch (_) {
      // Keep current local share counts if sync fails.
    }
  }

  void _resetPlaybackState() {
    _playbackFeedbackTimer?.cancel();
    _cancelPendingViewTracking();
    _isHoldingToPause = false;
    _manuallyPausedItemId = null;
    _playbackFeedbackIcon = null;
    _playbackFeedbackItemId = null;
    _lastTapDownAt = null;
    _lastTapDownPosition = null;
    _lastTapDownItemId = null;
    _clearPendingTapToggle();
  }

  void _clearPendingTapToggle() {
    _pendingTapToggleItemId = null;
    _pendingTapToggleWasPaused = false;
    _pendingTapToggleAt = null;
  }

  bool _isDoubleTapCandidate(int itemId, Offset position, DateTime now) {
    final lastAt = _lastTapDownAt;
    final lastPos = _lastTapDownPosition;
    final lastItemId = _lastTapDownItemId;
    if (lastAt == null || lastPos == null || lastItemId == null) return false;
    if (lastItemId != itemId) return false;

    final withinTime =
        now.difference(lastAt) <= const Duration(milliseconds: 260);
    final withinDistance = (position - lastPos).distance <= 52;
    return withinTime && withinDistance;
  }

  void _rememberTapDown(int itemId, Offset position, DateTime now) {
    _lastTapDownAt = now;
    _lastTapDownPosition = position;
    _lastTapDownItemId = itemId;
  }

  void _clearTapDownHistory() {
    _lastTapDownAt = null;
    _lastTapDownPosition = null;
    _lastTapDownItemId = null;
  }

  void _showPlaybackFeedback({
    required int feedId,
    required bool paused,
  }) {
    _playbackFeedbackTimer?.cancel();
    setState(() {
      _playbackFeedbackItemId = feedId;
      _playbackFeedbackIcon = paused ? Icons.pause : Icons.play_arrow;
    });

    _playbackFeedbackTimer = Timer(const Duration(milliseconds: 240), () {
      if (!mounted || _playbackFeedbackItemId != feedId) return;
      setState(() {
        _playbackFeedbackItemId = null;
        _playbackFeedbackIcon = null;
      });
    });
  }

  bool _shouldPlayItemVideo(FeedItem item, int index) {
    if (!item.isVideo) return false;
    if (index != _currentFeedIndex) return false;
    if (!_isFeedPlaybackActive) return false;
    if (_isHoldingToPause) return false;
    return _manuallyPausedItemId != item.id;
  }

  bool _shouldPreloadItemVideo(FeedItem item, int index) {
    if (!item.isVideo) return false;

    final isCurrent = index == _currentFeedIndex;
    final isNext = index == _currentFeedIndex + 1;

    final keepCurrentWarm = !_isFeedPlaybackActive && isCurrent;
    final preloadNext = _isFeedTabVisible && isNext;
    return keepCurrentWarm || preloadNext;
  }

  void _onFeedTapDown(
    FeedItem item,
    int index,
    TapDownDetails details,
  ) {
    if (index != _currentFeedIndex) return;

    final now = DateTime.now();
    if (_pendingTapToggleAt != null &&
        now.difference(_pendingTapToggleAt!) >
            const Duration(milliseconds: 420)) {
      _clearPendingTapToggle();
    }
    final isDoubleTap =
        _isDoubleTapCandidate(item.id, details.localPosition, now);

    if (isDoubleTap) {
      _clearTapDownHistory();
      _handleDoubleTapLike(item, index);
      return;
    }

    _rememberTapDown(item.id, details.localPosition, now);

    if (!_isFeedPlaybackActive || !item.isVideo) return;

    final wasPaused = _manuallyPausedItemId == item.id;
    setState(() {
      _isHoldingToPause = false;
      _manuallyPausedItemId = wasPaused ? null : item.id;
      _pendingTapToggleItemId = item.id;
      _pendingTapToggleWasPaused = wasPaused;
      _pendingTapToggleAt = now;
    });

    _showPlaybackFeedback(
      feedId: item.id,
      paused: !wasPaused,
    );
    _scheduleViewTrackingForActiveItem();
  }

  void _onFeedLongPressStart(
    FeedItem item,
    int index,
    LongPressStartDetails details,
  ) {
    if (!_isFeedPlaybackActive || !item.isVideo || index != _currentFeedIndex) {
      return;
    }
    setState(() {
      if (_pendingTapToggleItemId == item.id) {
        _manuallyPausedItemId = _pendingTapToggleWasPaused ? item.id : null;
        _clearPendingTapToggle();
      }
      _isHoldingToPause = true;
      _playbackFeedbackItemId = null;
      _playbackFeedbackIcon = null;
    });
    _scheduleViewTrackingForActiveItem();
  }

  void _onFeedLongPressEnd(
    FeedItem item,
    int index,
    LongPressEndDetails details,
  ) {
    if (!item.isVideo || index != _currentFeedIndex || !_isHoldingToPause) {
      return;
    }
    setState(() {
      _isHoldingToPause = false;
    });
    _scheduleViewTrackingForActiveItem();
  }

  void _handleDoubleTapLike(FeedItem item, int index) {
    if (index != _currentFeedIndex) return;

    // If first tap was already applied as pause/play, restore original playback
    // so double-tap like doesn't feel like a delayed/toggling tap action.
    final pendingAt = _pendingTapToggleAt;
    final shouldRestore = _pendingTapToggleItemId == item.id &&
        pendingAt != null &&
        DateTime.now().difference(pendingAt) <=
            const Duration(milliseconds: 420);

    if (shouldRestore) {
      setState(() {
        _manuallyPausedItemId = _pendingTapToggleWasPaused ? item.id : null;
        _clearPendingTapToggle();
      });
    }
    _clearPendingTapToggle();

    _showHeartAnimation(item.id);
    _checkLogin(() {
      _submitLikeOptimistic(item);
    });
  }

  Future<void> _submitLikeOptimistic(FeedItem item) async {
    if (_likedFeedIds.contains(item.id) ||
        _likeRequestsInFlight.contains(item.id)) {
      return;
    }

    final previousCount = _effectiveLikesCount(item);
    setState(() {
      _likedFeedIds.add(item.id);
      _likeRequestsInFlight.add(item.id);
      _likeCountOverrides[item.id] = previousCount + 1;
    });

    try {
      await _supabaseService.incrementLikesAtomic(item.id);
    } catch (_) {
      if (mounted) {
        setState(() {
          _likedFeedIds.remove(item.id);
          _likeCountOverrides[item.id] = previousCount;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _likeRequestsInFlight.remove(item.id);
        });
      }
    }
  }

  void _showHeartAnimation(int feedId) {
    setState(() {
      _heartAnimatingItemId = feedId;
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted || _heartAnimatingItemId != feedId) return;
      setState(() {
        _heartAnimatingItemId = null;
      });
    });
  }

  void _openTeacherPublicProfile(FeedItem item) {
    _checkLogin(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherPublicProfileScreen(
            teacherName: item.authorName,
            teacherAvatar:
                item.authorAvatar.isNotEmpty ? item.authorAvatar : null,
            teacherUserId: item.authorId,
          ),
        ),
      );
    });
  }

  Future<void> _openCommentSheet(FeedItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => CommentSheet(
        feedItemId: item.dbId,
        initialCount: _effectiveCommentsCount(item),
        repository: _commentRepository,
        onCountChanged: (count) {
          if (!mounted) return;
          setState(() {
            _commentCountOverrides[item.id] = count;
          });
        },
      ),
    );
  }

  Future<void> _toggleSave(FeedItem item) async {
    final dbId = item.dbId;
    if (_saveRequestsInFlight.contains(dbId)) return;

    final wasSaved = _savedFeedIds.contains(dbId);
    setState(() {
      if (wasSaved) {
        _savedFeedIds.remove(dbId);
      } else {
        _savedFeedIds.add(dbId);
      }
      _saveAnimatingFeedIds.add(item.id);
      _saveRequestsInFlight.add(dbId);
    });

    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() {
        _saveAnimatingFeedIds.remove(item.id);
      });
    });

    try {
      if (wasSaved) {
        await _supabaseService.unsavePost(dbId);
      } else {
        await _supabaseService.savePost(dbId);
      }
      unawaited(_loadSavedPosts());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (wasSaved) {
          _savedFeedIds.add(dbId);
        } else {
          _savedFeedIds.remove(dbId);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasSaved ? 'Unsave failed. Try again.' : 'Save failed. Try again.',
            style: GoogleFonts.inter(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saveRequestsInFlight.remove(dbId);
        });
      }
    }
  }

  Future<void> _sharePost(FeedItem item) async {
    if (_shareRequestsInFlight.contains(item.id)) return;

    final targetUrl = item.videoUrl ?? item.mediaUrl;
    final shareText = '${item.caption}\n$targetUrl';
    final previousCount = _effectiveSharesCount(item);

    setState(() {
      _shareRequestsInFlight.add(item.id);
      _shareCountOverrides[item.id] = previousCount + 1;
    });

    try {
      await Share.share(shareText);
      await _supabaseService.logShareEvent(item.dbId);
      unawaited(_syncShareCountsFromDb(items: [item]));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _shareCountOverrides[item.id] = previousCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share failed. Try again.', style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _shareRequestsInFlight.remove(item.id);
        });
      }
    }
  }

  Widget _buildHeartOverlay(FeedItem item) {
    final visible = _heartAnimatingItemId == item.id;
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: AnimatedScale(
              scale: visible ? 1 : 0.78,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: Icon(
                Icons.favorite,
                size: 104,
                color: Colors.white.withOpacity(0.92),
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.32),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPauseOverlay(FeedItem item, int index) {
    final visible = _manuallyPausedItemId == item.id &&
        index == _currentFeedIndex &&
        _isFeedPlaybackActive;

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 140),
            child: AnimatedScale(
              scale: visible ? 1 : 0.9,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.55),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.pause,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackFeedbackOverlay(FeedItem item, int index) {
    final visible = _playbackFeedbackItemId == item.id &&
        index == _currentFeedIndex &&
        _isFeedPlaybackActive &&
        _playbackFeedbackIcon != null;

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 90),
            child: AnimatedScale(
              scale: visible ? 1 : 0.86,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.1,
                  ),
                ),
                child: Icon(
                  _playbackFeedbackIcon,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper to check login before action
  void _checkLogin(VoidCallback action) {
    if (_isGuest) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const LoginBottomSheet(),
      ).then((result) {
        // Re-check auth status after sheet closes
        _checkAuthState();

        // If login was successful, execute the action
        if (result == true) {
          action();
        }
      });
    } else {
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              // 0: Feed
              _buildFeedTab(),

              // 1: Search - Piano Rental
              const PianoRentalScreen(),

              // 2: Add - Create Video
              CreateVideoScreen(
                onVideoPosted: _handleVideoPostedFromCreateTab,
              ),

              // 3: Message
              const MessagesScreen(),

              // 4: Profile
              const ProfileScreen(),
            ],
          ),

          // Bottom Navigation
          _buildBottomNavigation(context),
        ],
      ),
    );
  }

  Widget _buildFeedTab() {
    if (_feedScope == FeedScope.following && _isGuest) {
      return _buildFollowingLoginGate();
    }

    Widget content;
    if (_isInitialFeedLoading) {
      content = const Center(
        child: CircularProgressIndicator(color: primaryGold),
      );
    } else if (_feedError != null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Loi tai feed',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadInitialFeed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.black,
              ),
              child: const Text('Thu lai'),
            ),
          ],
        ),
      );
    } else if (_feedItems.isEmpty) {
      content = Center(
        child: Text(
          _feedScope == FeedScope.following
              ? 'Chua co video tu creators ban dang follow'
              : 'Chua co bai viet nao',
          style: GoogleFonts.inter(color: Colors.white),
        ),
      );
    } else {
      content = _buildFeedView();
    }

    return Stack(
      children: [
        Positioned.fill(child: content),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 0,
          right: 0,
          child: _buildFeedScopeTabs(),
        ),
      ],
    );
  }

  Widget _buildFollowingLoginGate() {
    return Container(
      color: backgroundDark,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, color: primaryGold, size: 52),
                  const SizedBox(height: 16),
                  Text(
                    'Dang nhap de xem Following feed',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => _checkLogin(() {}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Dang nhap',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: _buildFeedScopeTabs(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedView() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) {
        if (index < _feedItems.length) {
          setState(() {
            _currentFeedIndex = index;
            _resetPlaybackState();
          });
          _scheduleViewTrackingForActiveItem();
          _loadMoreFeedIfNeeded(index);
        } else if (_hasMoreFeed) {
          _cancelPendingViewTracking();
          _loadMoreFeedIfNeeded(_feedItems.length - 1);
        }
      },
      itemCount: _feedItems.length + 1,
      pageSnapping: true,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == _feedItems.length) {
          return _hasMoreFeed || _isLoadingMoreFeed
              ? _buildFeedLoadingTailPage()
              : _buildEndOfFeedPage();
        }
        final item = _feedItems[index];
        return _buildFeedPage(
          item,
          index: index,
          key: ValueKey('feed_${item.id}'),
        );
      },
    );
  }

  Widget _buildFeedLoadingTailPage() {
    return Container(
      color: backgroundDark,
      child: const Center(
        child: CircularProgressIndicator(color: primaryGold),
      ),
    );
  }

  // End of Feed Page
  Widget _buildEndOfFeedPage() {
    return Container(
      color: backgroundLight,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: primaryGold,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'Bạn đã xem hết!',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Đã xem tất cả bài viết mới',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                // Refresh button
                ElevatedButton.icon(
                  onPressed: () {
                    _loadInitialFeed();
                    if (_pageController.hasClients) {
                      _pageController.jumpToPage(0);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'Làm mới',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedPage(FeedItem item, {required int index, required Key key}) {
    final shouldPlay = _shouldPlayItemVideo(item, index);
    final shouldPreload = _shouldPreloadItemVideo(item, index);

    return Container(
      key: key,
      child: Stack(
        children: [
          FeedMediaItem(
            key: ValueKey('media_${item.id}'),
            item: item,
            isActive: index == _currentFeedIndex && _isFeedTabVisible,
            shouldPreload: shouldPreload,
            shouldPlay: shouldPlay,
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _onFeedTapDown(item, index, details),
              onLongPressStart: (details) =>
                  _onFeedLongPressStart(item, index, details),
              onLongPressEnd: (details) =>
                  _onFeedLongPressEnd(item, index, details),
            ),
          ),
          _buildPlaybackFeedbackOverlay(item, index),
          _buildPauseOverlay(item, index),
          _buildHeartOverlay(item),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 400,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top Verified Badge (if user is verified)
          if (item.isVerified) IgnorePointer(child: _buildTopUserBadge(item)),

          // Right Sidebar
          _buildRightSidebar(
            item,
            likeCount: _effectiveLikesCount(item),
            isLiked: _isItemLiked(item),
          ),

          // Bottom Content Area
          _buildBottomContent(item),
        ],
      ),
    );
  }

  Widget _buildFeedScopeTabs() {
    return IgnorePointer(
      ignoring: !_isFeedTabVisible,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFeedScopeButton(
                label: 'For You',
                scope: FeedScope.forYou,
              ),
              const SizedBox(width: 4),
              _buildFeedScopeButton(
                label: 'Following',
                scope: FeedScope.following,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedScopeButton({
    required String label,
    required FeedScope scope,
  }) {
    final active = _feedScope == scope;
    return GestureDetector(
      onTap: () => _onFeedScopeChanged(scope),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Top User Badge (Verified Badge)
  Widget _buildTopUserBadge(FeedItem item) {
    return Positioned(
      top: 56,
      left: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verified Badge
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified,
                      color: Color(0xFFFFD700),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.authorName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Right Sidebar with Actions
  Widget _buildRightSidebar(
    FeedItem item, {
    required int likeCount,
    required bool isLiked,
  }) {
    return Positioned(
      right: 12,
      bottom: 144,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Creator Avatar with Add Button
                GestureDetector(
                  onTap: () => _openTeacherPublicProfile(item),
                  child: SizedBox(
                    width: 40,
                    height: 48,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              item.authorAvatar.isNotEmpty
                                  ? item.authorAvatar
                                  : 'https://via.placeholder.com/150',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey,
                                  child: const Icon(Icons.person,
                                      color: Colors.white),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 10,
                          child: GestureDetector(
                            onTap: () => _openTeacherPublicProfile(item),
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Like Button
                GestureDetector(
                  onTap: () => _checkLogin(() {
                    _submitLikeOptimistic(item);
                  }),
                  child: _buildSidebarAction(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    iconColor: isLiked ? Colors.redAccent : Colors.white,
                    label: item.formatCount(likeCount),
                  ),
                ),
                const SizedBox(height: 24),
                // Comment Button
                GestureDetector(
                  onTap: () => _openCommentSheet(item),
                  child: _buildSidebarAction(
                    icon: Icons.chat_bubble_outline,
                    label: item.formatCount(_effectiveCommentsCount(item)),
                  ),
                ),
                const SizedBox(height: 24),
                // Bookmark Button
                GestureDetector(
                  onTap: () => _checkLogin(() {
                    _toggleSave(item);
                  }),
                  child: _buildSidebarAction(
                    icon: _isItemSaved(item)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    iconColor: _isItemSaved(item) ? primaryGold : Colors.white,
                    label: '',
                    iconScale:
                        _saveAnimatingFeedIds.contains(item.id) ? 1.18 : 1.0,
                    iconOpacity:
                        _saveAnimatingFeedIds.contains(item.id) ? 0.88 : 1.0,
                  ),
                ),
                const SizedBox(height: 24),
                // Share Button
                GestureDetector(
                  onTap: () => _checkLogin(() {
                    _sharePost(item);
                  }),
                  child: _buildSidebarAction(
                    icon: Icons.reply,
                    label: item.formatCount(_effectiveSharesCount(item)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarAction({
    required IconData icon,
    required String label,
    Color iconColor = Colors.white,
    double iconScale = 1.0,
    double iconOpacity = 1.0,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: iconScale,
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: iconOpacity,
            duration: const Duration(milliseconds: 170),
            child: Icon(
              icon,
              color: iconColor,
              size: 30,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Bottom Content Area
  Widget _buildBottomContent(FeedItem item) {
    return Positioned(
      bottom: 96,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Description Text
            Padding(
              padding: const EdgeInsets.only(right: 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.caption,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.hashtags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.hashtags.map((tag) => '#$tag').join(' '),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.9),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Location Badge
            if (item.location != null && item.location!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: primaryGold,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.location!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (item.location != null && item.location!.isNotEmpty)
              const SizedBox(height: 8),
            // Music Info
            if (item.musicCredit != null && item.musicCredit!.isNotEmpty)
              Builder(
                builder: (context) => SizedBox(
                  width: MediaQuery.of(context).size.width * 0.66,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.musicCredit!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.only(right: 64),
              child: Row(
                children: [
                  // Borrow Piano Button - Only show if video has pianoId
                  if (item.pianoId != null && item.pianoId!.isNotEmpty)
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFE5E5E5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => _checkLogin(() {
                              // If video has piano_id, navigate to that specific piano
                              if (item.pianoId != null &&
                                  item.pianoId!.isNotEmpty) {
                                // Mock piano data for the specific piano
                                final pianoData = {
                                  'id': item.pianoId,
                                  'name': 'Yamaha C3X Grand Piano',
                                  'category': 'Grand Piano',
                                  'price': '500,000đ/giờ',
                                  'location': item.location ?? 'TP.HCM',
                                  'rating': 4.9,
                                  'reviews': 128,
                                  'image': item.thumbUrl ?? item.mediaUrl,
                                  'available': true,
                                  'features': [
                                    'Âm thanh đỉnh cao',
                                    'Phòng cách âm',
                                    'Điều hòa'
                                  ],
                                };

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PianoDetailScreen(
                                      pianoId: item.pianoId!,
                                      pianoData: pianoData,
                                    ),
                                  ),
                                );
                              } else {
                                // If no piano_id, open piano rental list.
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PianoRentalScreen()),
                                );
                              }
                            }),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.piano,
                                  color: Color(0xFF333333),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Mượn Đàn',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Add spacing only if piano button is shown
                  if (item.pianoId != null && item.pianoId!.isNotEmpty)
                    const SizedBox(width: 12),

                  // Learn Now Button
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE6C86E),
                            Color(0xFFBF953F),
                            Color(0xFFE6C86E),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: primaryGold.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => _checkLogin(() {}),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school,
                                color: Colors.black.withOpacity(0.8),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Học Ngay',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabChanged(int nextIndex) {
    if (_selectedIndex == nextIndex) return;
    setState(() {
      if (_selectedIndex == 0 && nextIndex != 0) {
        _resetPlaybackState();
      }
      _selectedIndex = nextIndex;
    });
    _scheduleViewTrackingForActiveItem();
  }

  void _onFeedScopeChanged(FeedScope nextScope) {
    if (_feedScope == nextScope) return;
    setState(() {
      _feedScope = nextScope;
      _currentFeedIndex = 0;
      _resetPlaybackState();
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    _loadInitialFeed();
  }

  void _handleVideoPostedFromCreateTab() {
    if (!mounted) return;
    setState(() {
      _selectedIndex = 0;
      _feedScope = FeedScope.forYou;
      _currentFeedIndex = 0;
      _resetPlaybackState();
    });
    _loadInitialFeed();
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  FeedItem? _activeFeedItem() {
    if (_currentFeedIndex < 0 || _currentFeedIndex >= _feedItems.length) {
      return null;
    }
    return _feedItems[_currentFeedIndex];
  }

  void _cancelPendingViewTracking() {
    _pendingViewTimer?.cancel();
    _pendingViewTimer = null;
    _pendingViewFeedId = null;
  }

  void _scheduleViewTrackingForActiveItem() {
    _cancelPendingViewTracking();
    if (!_isFeedPlaybackActive) return;

    final activeItem = _activeFeedItem();
    if (activeItem == null || !activeItem.isVideo) return;
    if (!_shouldPlayItemVideo(activeItem, _currentFeedIndex)) return;

    final feedId = activeItem.dbId.trim();
    if (feedId.isEmpty) return;
    if (_viewRecordedInSession.contains(feedId) ||
        _viewRequestsInFlight.contains(feedId)) {
      return;
    }

    _pendingViewFeedId = feedId;
    final trackedIndex = _currentFeedIndex;
    _pendingViewTimer = Timer(const Duration(seconds: 2), () async {
      if (!mounted || !_isFeedPlaybackActive) return;
      if (_currentFeedIndex != trackedIndex) return;

      final currentItem = _activeFeedItem();
      if (currentItem == null || currentItem.dbId.trim() != feedId) return;
      if (!_shouldPlayItemVideo(currentItem, _currentFeedIndex)) return;
      if (_pendingViewFeedId != feedId) return;

      await _recordViewForActiveItem(feedId);
    });
  }

  Future<void> _recordViewForActiveItem(String feedId) async {
    if (_viewRecordedInSession.contains(feedId) ||
        _viewRequestsInFlight.contains(feedId)) {
      return;
    }

    _viewRequestsInFlight.add(feedId);
    try {
      await _supabaseService.recordView(
        feedId: feedId,
        sessionId: _viewSessionId,
      );
      _viewRecordedInSession.add(feedId);
    } catch (_) {
      // keep best-effort, no UI error for view tracking
    } finally {
      _viewRequestsInFlight.remove(feedId);
      _pendingViewFeedId = null;
    }
  }

  String _generateSessionId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // RFC 4122 v4
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }

  // Custom Bottom Navigation
  Widget _buildBottomNavigation(BuildContext context) {
    // Dark footer only on Home tab
    final isDark = _selectedIndex == 0;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? backgroundDark : backgroundLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            10,
            10,
            10,
            bottomInset > 0 ? bottomInset + 2 : 14,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                isActive: _selectedIndex == 0,
                isDark: isDark,
                onTap: () => _onTabChanged(0),
              ),
              _buildNavItem(
                icon: Icons.explore,
                label: 'Khám phá',
                isActive: _selectedIndex == 1,
                isDark: isDark,
                onTap: () => _onTabChanged(1),
              ),
              Transform.translate(
                offset: const Offset(0, -6),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE6C86E),
                        Color(0xFFBF953F),
                        Color(0xFFE6C86E),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGold.withOpacity(0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _onTabChanged(2),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildNavItem(
                icon: Icons.message_outlined,
                label: 'Hộp thư',
                isActive: _selectedIndex == 3,
                isDark: isDark,
                onTap: () => _onTabChanged(3),
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Hồ sơ',
                isActive: _selectedIndex == 4,
                isDark: isDark,
                onTap: () => _onTabChanged(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final color = isActive
        ? primaryGold
        : (isDark
            ? const Color(0xFFB0B0B0)
            : const Color(0xFF9E9E9E)); // Inactive

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 23,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
