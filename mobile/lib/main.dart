import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'models/feed_item.dart';
import 'screens/booking_screen.dart';
import 'screens/create_video_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/piano_rental_screen.dart';
import 'screens/piano_detail_screen.dart';
import 'screens/splash_screen.dart';
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
      title: 'Piano Social Feed',
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

class PianoFeedScreen extends StatefulWidget {
  const PianoFeedScreen({super.key});

  @override
  State<PianoFeedScreen> createState() => _PianoFeedScreenState();
}

class _PianoFeedScreenState extends State<PianoFeedScreen> {
  // Color Palette
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFFFFFFFF);

  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<FeedItem>> _feedFuture;
  final PageController _pageController = PageController(keepPage: true);
  int _selectedIndex = 0;
  
  // Guest Mode State
  bool _isGuest = true; 

  @override
  void initState() {
    super.initState();
    _feedFuture = _supabaseService.getSocialFeed();
    // Check actual auth state
    _checkAuthState();
  }
  
  void _checkAuthState() {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _isGuest = session == null;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
              FutureBuilder<List<FeedItem>>(
                future: _feedFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryGold),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}', style: GoogleFonts.inter(color: Colors.white)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Chưa có bài viết nào', style: GoogleFonts.inter(color: Colors.white)));
                  }
                  return _buildFeedView(snapshot.data!);
                },
              ),
              
              // 1: Search - Piano Rental
              const PianoRentalScreen(),
              
              // 2: Add - Create Video
              const CreateVideoScreen(),

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

  Widget _buildFeedView(List<FeedItem> feedItems) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: feedItems.length + 1,
      pageSnapping: true,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == feedItems.length) {
          return _buildEndOfFeedPage();
        }
        final item = feedItems[index];
        return _buildFeedPage(item, key: ValueKey('feed_${item.id}'));
      },
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
                    setState(() {
                      _feedFuture = _supabaseService.getSocialFeed();
                      _pageController.jumpToPage(0);
                    });
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

  Widget _buildFeedPage(FeedItem item, {required Key key}) {
    return Container(
      key: key,
      child: Stack(
        children: [
          // Background Image with Overlay
          _buildBackground(item.mediaUrl, key: ValueKey('bg_${item.id}')),
          
          // Top Verified Badge (if user is verified)
          if (item.isVerified) _buildTopUserBadge(item),
          
          // Right Sidebar
          _buildRightSidebar(item),
          
          // Bottom Content Area
          _buildBottomContent(item),
        ],
      ),
    );
  }

  // Background with Image and Gradient Overlay
  Widget _buildBackground(String mediaUrl, {required Key key}) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Background Image
          Image.network(
            key: key,
            mediaUrl.isNotEmpty ? mediaUrl : 'https://via.placeholder.com/1080x1920/000000/FFFFFF?text=No+Image',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.25), // brightness-75 effect
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.error, color: Colors.white54, size: 60),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(
                    color: primaryGold,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
          // Bottom Gradient Overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 400,
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
        ],
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
  Widget _buildRightSidebar(FeedItem item) {
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
                SizedBox(
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
                            item.authorAvatar.isNotEmpty ? item.authorAvatar : 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey,
                                child: const Icon(Icons.person, color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        child: GestureDetector(
                           onTap: () => _checkLogin(() {}),
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
                const SizedBox(height: 24),
                // Like Button
                GestureDetector(
                  onTap: () => _checkLogin(() {
                    // TODO: Implement Like logic
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Liked!')));
                  }),
                  child: _buildSidebarAction(
                    icon: Icons.favorite_border,
                    label: item.formattedLikes,
                  ),
                ),
                const SizedBox(height: 24),
                // Comment Button
                GestureDetector(
                  onTap: () => _checkLogin(() {}),
                   child: _buildSidebarAction(
                    icon: Icons.chat_bubble_outline,
                    label: item.formattedComments,
                  ),
                ),
                const SizedBox(height: 24),
                // Bookmark Button
                GestureDetector(
                   onTap: () => _checkLogin(() {}),
                   child: _buildSidebarAction(
                    icon: Icons.bookmark_border,
                    label: item.formattedShares,
                  ),
                ),
                const SizedBox(height: 24),
                // Share Button
                GestureDetector(
                   onTap: () => _checkLogin(() {}),
                   child: _buildSidebarAction(
                    icon: Icons.reply,
                    label: '',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarAction({required IconData icon, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 30,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                            if (item.pianoId != null && item.pianoId!.isNotEmpty) {
                              // Mock piano data for the specific piano
                              final pianoData = {
                                'id': item.pianoId,
                                'name': 'Yamaha C3X Grand Piano',
                                'category': 'Grand Piano',
                                'price': '500,000đ/giờ',
                                'location': item.location ?? 'TP.HCM',
                                'rating': 4.9,
                                'reviews': 128,
                                'image': item.mediaUrl,
                                'available': true,
                                'features': ['Âm thanh đỉnh cao', 'Phòng cách âm', 'Điều hòa'],
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
                              // If no piano_id, navigate to general booking screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BookingScreen()),
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

  // Custom Bottom Navigation
  Widget _buildBottomNavigation(BuildContext context) {
    // Always use light mode for internal screens
    const isDark = false;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? backgroundDark : backgroundLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.grey[200]!,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    label: 'Home',
                    isActive: _selectedIndex == 0,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _buildNavItem(
                    icon: Icons.explore,
                    label: 'Khám phá',
                    isActive: _selectedIndex == 1,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  // Center Add Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      width: 48,
                      height: 48,
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
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryGold.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => _selectedIndex = 2),
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
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    label: 'Hồ sơ',
                    isActive: _selectedIndex == 4,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Bottom Indicator
          ],
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
        : const Color(0xFF9E9E9E); // Light gray for inactive
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
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
