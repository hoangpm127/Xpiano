import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

// IMPORTANT: Replace with your actual App ID
const String _kAppId = "YOUR_AGORA_APP_ID"; 
const String _kChannelName = "demo_class";

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key});

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  late RtcEngine _engine;
  bool _isInit = false;
  bool _isMicOn = true;
  bool _isHandRaised = false;
  
  // Agora State
  int? _remoteUid; // ID của giáo viên (người khác tham gia)
  bool _localUserJoined = false;

  @override
  void initState() {
    super.initState();
    // Force landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _initAgora();
  }

  Future<void> _initAgora() async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create Agora Engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: _kAppId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    // Event Handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    // Join Channel
    await _engine.joinChannel(
      token: "", // Use temp token if needed, empty for now (testing mode)
      channelId: _kChannelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    
    setState(() {
      _isInit = true;
    });
  }

  Future<void> _disposeAgora() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  void dispose() {
    // Restore portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _disposeAgora();
    super.dispose();
  }

  void _onToggleMic() {
    setState(() {
      _isMicOn = !_isMicOn;
    });
    _engine.muteLocalAudioStream(!_isMicOn);
  }

  void _onLeaveChannel() {
    // Navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Layer 1: Remote Video (Teacher) or Placeholder
          Positioned.fill(
            child: _buildRemoteVideo(),
          ),

          // Layer 2: Local Video (Student - Small floating)
          Positioned(
            top: 16,
            left: 16,
            width: 120,
            height: 90,
            child: _buildLocalVideo(),
          ),

          // Layer 3: Piano Visualizer (Bottom Overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildPianoVisualizer(),
          ),

          // Layer 4: Controls
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildRemoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: _kChannelName),
        ),
      );
    } else {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Đang chờ giáo viên...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLocalVideo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _localUserJoined
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }

  Widget _buildPianoVisualizer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Basic Key Visualization
          SizedBox(
            height: 40,
            child: Row(
              children: List.generate(20, (index) {
                 // Simple visualization pattern
                 final isBlack = [1, 3, 6, 8, 10].contains(index % 12);
                 return Expanded(
                   child: Container(
                     margin: const EdgeInsets.symmetric(horizontal: 1),
                     color: isBlack ? Colors.black : Colors.white.withOpacity(0.8),
                   ),
                 );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildControls() {
    return SafeArea(
      child: Stack(
        children: [
          // Exit button (Top right)
          Positioned(
            top: 16,
            right: 16,
            child: _buildControlButton(
              icon: Icons.close,
              color: Colors.red,
              onTap: _onLeaveChannel,
            ),
          ),

          // Raise hand button (Bottom right, above piano)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15 + 16,
            right: 16,
            child: _buildControlButton(
              icon: _isHandRaised ? Icons.back_hand : Icons.back_hand_outlined,
              color: _isHandRaised ? Colors.amber : Colors.white,
              onTap: () {
                setState(() {
                  _isHandRaised = !_isHandRaised;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isHandRaised ? 'Đã giơ tay ✋' : 'Đã hạ tay'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),

          // Mic button (Bottom left)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15 + 16,
            left: 16,
            child: _buildControlButton(
              icon: _isMicOn ? Icons.mic : Icons.mic_off,
              color: _isMicOn ? Colors.white : Colors.red,
              onTap: _onToggleMic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color == Colors.white ? Colors.black : Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
