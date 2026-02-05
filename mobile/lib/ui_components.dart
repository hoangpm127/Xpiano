// ============================================
// XPIANO MVP - UI COMPONENT STRUCTURE
// Frontend: Flutter (Mobile App)
// Version: 1.0
// ============================================

// ============================================
// PROJECT STRUCTURE
// ============================================
/*
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   ├── endpoints.dart
│   │   └── interceptors/
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── webrtc_service.dart
│   │   └── midi_service.dart
│   ├── models/
│   │   ├── user.dart
│   │   ├── order.dart
│   │   ├── piano.dart
│   │   └── commission.dart
│   └── providers/
│       ├── auth_provider.dart
│       └── wallet_provider.dart
├── features/
│   ├── rental/
│   │   ├── screens/
│   │   │   ├── rental_map_screen.dart
│   │   │   ├── piano_detail_screen.dart
│   │   │   └── checkout_screen.dart
│   │   ├── widgets/
│   │   │   ├── warehouse_marker.dart
│   │   │   └── piano_card.dart
│   │   └── rental_bloc.dart
│   ├── classroom/
│   │   ├── screens/
│   │   │   ├── classroom_screen.dart
│   │   │   └── pre_class_screen.dart
│   │   ├── widgets/
│   │   │   ├── video_grid.dart
│   │   │   ├── virtual_piano.dart
│   │   │   ├── chat_panel.dart
│   │   │   └── control_bar.dart
│   │   └── classroom_bloc.dart
│   └── affiliate/
│       ├── screens/
│       │   ├── affiliate_dashboard.dart
│       │   └── referral_tree_screen.dart
│       ├── widgets/
│       │   ├── earnings_chart.dart
│       │   ├── commission_card.dart
│       │   └── referral_tree.dart
│       └── affiliate_bloc.dart
└── shared/
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── loading_overlay.dart
    │   └── error_dialog.dart
    └── utils/
        ├── formatters.dart
        └── validators.dart
*/


// ============================================
// 1. RENTAL MAP SCREEN
// ============================================

/// rental_map_screen.dart
/// 
/// PURPOSE: Show user location vs nearest warehouses with available pianos
/// 
/// FEATURES:
/// - Google Maps with user location
/// - Warehouse markers (color-coded by availability)
/// - Bottom sheet with piano list
/// - Filter by piano type (61/88 keys)
/// - Distance & estimated delivery time

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RentalMapScreen extends StatefulWidget {
  @override
  _RentalMapScreenState createState() => _RentalMapScreenState();
}

class _RentalMapScreenState extends State<RentalMapScreen> {
  GoogleMapController? _mapController;
  Position? _userLocation;
  Set<Marker> _markers = {};
  List<NearestWarehouse> _warehouses = [];
  
  // Filters
  String _selectedPianoType = 'any'; // any, 61, 88
  double _radiusKm = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thuê Đàn Gần Bạn'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // === MAP ===
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(21.0285, 105.8542), // Hanoi default
              zoom: 12,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
              _loadNearbyWarehouses();
            },
          ),

          // === BOTTOM SHEET: WAREHOUSE LIST ===
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_warehouses.length} kho đàn gần bạn',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text('Trong bán kính ${_radiusKm.toInt()} km'),
                        ],
                      ),
                    ),
                    
                    // List
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _warehouses.length,
                        itemBuilder: (context, index) {
                          return WarehouseCard(
                            warehouse: _warehouses[index],
                            onTap: () => _showWarehouseDetail(_warehouses[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // === WAREHOUSE CARD WIDGET ===
  Widget WarehouseCard({required NearestWarehouse warehouse, VoidCallback? onTap}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.piano, color: Colors.blue, size: 32),
              ),
              SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warehouse.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${warehouse.distanceKm.toStringAsFixed(1)} km',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.schedule, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '~${warehouse.estimatedDeliveryHours}h giao hàng',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${warehouse.availablePianos.length} đàn có sẵn',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================
// 2. CLASSROOM SCREEN
// ============================================

/// classroom_screen.dart
///
/// PURPOSE: Live video call between teacher and student with MIDI overlay
///
/// LAYOUT:
/// ┌─────────────────────────────────────────┐
/// │  Teacher Video (Large)        │ Chat    │
/// │  ┌─────────────────────┐      │ Panel   │
/// │  │                     │      │         │
/// │  │    👨‍🏫 Teacher       │      │ Messages│
/// │  │                     │      │         │
/// │  └─────────────────────┘      │         │
/// │      ┌────┐ Student (Small)   │         │
/// │      │👩‍🎓│                   │         │
/// │      └────┘                   │         │
/// ├─────────────────────────────────────────┤
/// │  Virtual Piano Keyboard                 │
/// │  ┌─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┐ │
/// │  │ │█│ │█│ │ │█│ │█│ │█│ │ │█│ │█│ │ │ │
/// │  └─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┘ │
/// ├─────────────────────────────────────────┤
/// │  🎤  📹  🖥️  📞           ⏱️ 45:30     │
/// │ Mute Cam Share End                      │
/// └─────────────────────────────────────────┘

class ClassroomScreen extends StatefulWidget {
  final String sessionId;
  
  ClassroomScreen({required this.sessionId});

  @override
  _ClassroomScreenState createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  // WebRTC
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  // Controls
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isRecording = false;
  
  // MIDI
  List<int> _pressedKeys = [];
  
  // Chat
  List<ChatMessage> _messages = [];
  TextEditingController _chatController = TextEditingController();
  
  // Session
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // === TOP BAR ===
            _buildTopBar(),
            
            // === MAIN CONTENT ===
            Expanded(
              child: Row(
                children: [
                  // VIDEO AREA
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        // Teacher Video (Large)
                        Expanded(
                          flex: 3,
                          child: _buildVideoGrid(),
                        ),
                        
                        // Virtual Piano
                        Container(
                          height: 120,
                          child: VirtualPiano(
                            pressedKeys: _pressedKeys,
                            onKeyPressed: _handleKeyPress,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // CHAT PANEL (collapsible on mobile)
                  Container(
                    width: 280,
                    child: ChatPanel(
                      messages: _messages,
                      controller: _chatController,
                      onSend: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
            
            // === CONTROL BAR ===
            _buildControlBar(),
          ],
        ),
      ),
    );
  }

  // === VIDEO GRID ===
  Widget _buildVideoGrid() {
    return Stack(
      children: [
        // Remote video (Teacher) - Full size
        Container(
          width: double.infinity,
          height: double.infinity,
          child: RTCVideoView(
            _remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
        ),
        
        // Local video (Student) - Picture-in-picture
        Positioned(
          right: 16,
          bottom: 16,
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: RTCVideoView(
                _localRenderer,
                mirror: true,
              ),
            ),
          ),
        ),
        
        // Recording indicator
        if (_isRecording)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_manual_record, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text('REC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // === CONTROL BAR ===
  Widget _buildControlBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mute
          _ControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            isActive: _isMuted,
            onTap: () => setState(() => _isMuted = !_isMuted),
          ),
          SizedBox(width: 24),
          
          // Camera
          _ControlButton(
            icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
            label: _isCameraOff ? 'Start Cam' : 'Stop Cam',
            isActive: _isCameraOff,
            onTap: () => setState(() => _isCameraOff = !_isCameraOff),
          ),
          SizedBox(width: 24),
          
          // Screen Share
          _ControlButton(
            icon: Icons.screen_share,
            label: 'Share',
            onTap: _startScreenShare,
          ),
          SizedBox(width: 24),
          
          // End Call
          _ControlButton(
            icon: Icons.call_end,
            label: 'End',
            color: Colors.red,
            onTap: _endSession,
          ),
          
          Spacer(),
          
          // Timer
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatDuration(_elapsed),
              style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

// === VIRTUAL PIANO WIDGET ===
class VirtualPiano extends StatelessWidget {
  final List<int> pressedKeys;
  final Function(int) onKeyPressed;
  
  // Piano range: C3 (48) to C5 (72) = 25 keys
  static const int START_NOTE = 48; // C3
  static const int END_NOTE = 72;   // C5
  
  VirtualPiano({required this.pressedKeys, required this.onKeyPressed});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[850],
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(END_NOTE - START_NOTE + 1, (index) {
          final note = START_NOTE + index;
          final isBlack = _isBlackKey(note);
          final isPressed = pressedKeys.contains(note);
          
          return _PianoKey(
            note: note,
            isBlack: isBlack,
            isPressed: isPressed,
            onPressed: () => onKeyPressed(note),
          );
        }),
      ),
    );
  }
  
  bool _isBlackKey(int note) {
    final n = note % 12;
    return [1, 3, 6, 8, 10].contains(n); // C#, D#, F#, G#, A#
  }
}

class _PianoKey extends StatelessWidget {
  final int note;
  final bool isBlack;
  final bool isPressed;
  final VoidCallback onPressed;
  
  _PianoKey({
    required this.note,
    required this.isBlack,
    required this.isPressed,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    final pressedColor = Colors.blue;
    
    if (isBlack) {
      return Container(
        width: 24,
        height: 60,
        margin: EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: isPressed ? pressedColor : Colors.black,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
          boxShadow: [BoxShadow(blurRadius: 2, color: Colors.black54)],
        ),
      );
    }
    
    return Container(
      width: 36,
      height: 100,
      margin: EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: isPressed ? pressedColor.shade100 : Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
  }
}


// ============================================
// 3. AFFILIATE DASHBOARD
// ============================================

/// affiliate_dashboard.dart
///
/// PURPOSE: Show affiliate earnings, network visualization, leaderboard
///
/// LAYOUT:
/// ┌─────────────────────────────────────────┐
/// │  📊 Thống kê Affiliate                  │
/// ├─────────────────────────────────────────┤
/// │  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
/// │  │ 💰      │  │ 👥      │  │ 📈      │ │
/// │  │ 1.25M   │  │ 46      │  │ +350k   │ │
/// │  │ Số dư   │  │Referrals│  │Tháng này│ │
/// │  └─────────┘  └─────────┘  └─────────┘ │
/// ├─────────────────────────────────────────┤
/// │  📈 Biểu đồ Thu nhập (12 tháng)        │
/// │  ┌─────────────────────────────────┐    │
/// │  │    200k   ╭─╮                   │    │
/// │  │          ╭╯ ╰╮  ╭─╮            │    │
/// │  │    100k ╭╯    ╰──╯ ╰╮          │    │
/// │  │       ╭─╯            ╰──────── │    │
/// │  │    0  J  F  M  A  M  J  ...    │    │
/// │  └─────────────────────────────────┘    │
/// ├─────────────────────────────────────────┤
/// │  🌳 Mạng lưới của bạn                   │
/// │  ┌─────────────────────────────────┐    │
/// │  │  👤 You                         │    │
/// │  │   ├─ 👤 Minh Anh (F1) +50k      │    │
/// │  │   │   ├─ 👤 Tuấn (F2) +25k      │    │
/// │  │   │   └─ 👤 Linh (F2) +15k      │    │
/// │  │   └─ 👤 Hà (F1) +80k            │    │
/// │  │       └─ 👤 Nam (F2) +10k       │    │
/// │  └─────────────────────────────────┘    │
/// ├─────────────────────────────────────────┤
/// │  🏆 Leaderboard                         │
/// │  1. Minh Anh - 2.5M ⭐                  │
/// │  2. Tuấn Kiệt - 1.8M                    │
/// │  3. You - 1.25M 👈                      │
/// └─────────────────────────────────────────┘

class AffiliateDashboardScreen extends StatefulWidget {
  @override
  _AffiliateDashboardScreenState createState() => _AffiliateDashboardScreenState();
}

class _AffiliateDashboardScreenState extends State<AffiliateDashboardScreen> {
  AffiliateDashboard? _data;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Affiliate Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareReferralLink,
          ),
        ],
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === REFERRAL LINK CARD ===
                  _ReferralLinkCard(
                    referralCode: _data!.referralCode,
                    referralLink: _data!.referralLink,
                    onCopy: _copyReferralLink,
                    onShare: _shareReferralLink,
                  ),
                  SizedBox(height: 24),
                  
                  // === STATS CARDS ===
                  Row(
                    children: [
                      Expanded(child: _StatCard(
                        icon: Icons.account_balance_wallet,
                        value: _formatCurrency(_data!.wallet.balance),
                        label: 'Số dư',
                        color: Colors.green,
                      )),
                      SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        icon: Icons.people,
                        value: _data!.totalReferrals.toString(),
                        label: 'Người giới thiệu',
                        color: Colors.blue,
                        subtitle: 'F1: ${_data!.f1Count} / F2: ${_data!.f2Count}',
                      )),
                      SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        icon: Icons.trending_up,
                        value: _formatCurrency(_data!.wallet.totalEarned),
                        label: 'Tổng thu nhập',
                        color: Colors.orange,
                      )),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // === EARNINGS CHART ===
                  Text(
                    'Thu nhập 12 tháng gần nhất',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  EarningsChart(data: _data!.monthlyEarnings),
                  SizedBox(height: 24),
                  
                  // === COMMISSION BREAKDOWN ===
                  _CommissionBreakdown(
                    tier1: _data!.commissionsByTier.tier1,
                    tier2: _data!.commissionsByTier.tier2,
                  ),
                  SizedBox(height: 24),
                  
                  // === REFERRAL TREE ===
                  Text(
                    'Mạng lưới của bạn',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  ReferralTreeWidget(onViewAll: _goToReferralTree),
                  SizedBox(height: 24),
                  
                  // === LEADERBOARD ===
                  Text(
                    'Bảng xếp hạng tháng này',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  LeaderboardWidget(),
                  SizedBox(height: 24),
                  
                  // === WITHDRAW BUTTON ===
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.account_balance),
                      label: Text('Rút tiền về tài khoản'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _showWithdrawDialog,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// === REFERRAL LINK CARD ===
class _ReferralLinkCard extends StatelessWidget {
  final String referralCode;
  final String referralLink;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  
  _ReferralLinkCard({
    required this.referralCode,
    required this.referralLink,
    required this.onCopy,
    required this.onShare,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Link giới thiệu của bạn',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralLink,
                    style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: Colors.white),
                  onPressed: onCopy,
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.share, color: Colors.white),
                  label: Text('Chia sẻ', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white),
                  ),
                  onPressed: onShare,
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Mã: $referralCode',
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// === STAT CARD ===
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? subtitle;
  
  _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.subtitle,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

// === EARNINGS CHART ===
class EarningsChart extends StatelessWidget {
  final List<MonthlyEarning> data;
  
  EarningsChart({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final months = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 
                                  'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
                  return Text(months[value.toInt() % 12], 
                    style: TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) => 
                FlSpot(e.key.toDouble(), e.value.total / 1000)
              ).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === REFERRAL TREE WIDGET ===
class ReferralTreeWidget extends StatelessWidget {
  final VoidCallback onViewAll;
  
  ReferralTreeWidget({required this.onViewAll});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Column(
        children: [
          // Tree visualization (simplified)
          _TreeNode(
            name: 'Bạn',
            isRoot: true,
            tier: 0,
            children: [
              _TreeNode(name: 'Minh Anh', tier: 1, earning: 50000),
              _TreeNode(name: 'Hà Phương', tier: 1, earning: 80000),
            ],
          ),
          SizedBox(height: 12),
          TextButton(
            child: Text('Xem toàn bộ mạng lưới →'),
            onPressed: onViewAll,
          ),
        ],
      ),
    );
  }
}

class _TreeNode extends StatelessWidget {
  final String name;
  final int tier;
  final bool isRoot;
  final double? earning;
  final List<_TreeNode>? children;
  
  _TreeNode({
    required this.name,
    required this.tier,
    this.isRoot = false,
    this.earning,
    this.children,
  });
  
  @override
  Widget build(BuildContext context) {
    final tierColor = tier == 1 ? Colors.blue : Colors.purple;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!isRoot) ...[
              SizedBox(width: tier * 24.0),
              Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
            ],
            CircleAvatar(
              radius: 16,
              backgroundColor: isRoot ? Colors.green : tierColor.withOpacity(0.2),
              child: Icon(Icons.person, size: 18, color: isRoot ? Colors.white : tierColor),
            ),
            SizedBox(width: 8),
            Text(name, style: TextStyle(fontWeight: FontWeight.w500)),
            if (!isRoot) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('F$tier', style: TextStyle(fontSize: 10, color: tierColor)),
              ),
            ],
            if (earning != null) ...[
              Spacer(),
              Text('+${_formatCurrency(earning!)}',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
            ],
          ],
        ),
        if (children != null)
          ...children!.map((child) => Padding(
            padding: EdgeInsets.only(top: 8),
            child: child,
          )),
      ],
    );
  }
}


// ============================================
// HELPER FUNCTIONS & MODELS
// ============================================

String _formatCurrency(double amount) {
  if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(1)}M';
  } else if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(0)}k';
  }
  return amount.toStringAsFixed(0);
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${d.inHours}:$minutes:$seconds';
}

// Models
class NearestWarehouse {
  final String id;
  final String name;
  final double distanceKm;
  final int estimatedDeliveryHours;
  final List<Piano> availablePianos;
  
  NearestWarehouse({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.estimatedDeliveryHours,
    required this.availablePianos,
  });
}

class AffiliateDashboard {
  final String referralCode;
  final String referralLink;
  final int f1Count;
  final int f2Count;
  final int totalReferrals;
  final WalletInfo wallet;
  final CommissionsByTier commissionsByTier;
  final List<MonthlyEarning> monthlyEarnings;
  
  AffiliateDashboard({
    required this.referralCode,
    required this.referralLink, 
    required this.f1Count,
    required this.f2Count,
    required this.totalReferrals,
    required this.wallet,
    required this.commissionsByTier,
    required this.monthlyEarnings,
  });
}
