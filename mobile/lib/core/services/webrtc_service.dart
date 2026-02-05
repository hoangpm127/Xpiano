import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// WebRTC Service for video/audio calls and MIDI data transfer
/// Target audio latency: < 50ms
class WebRTCService with ChangeNotifier {
  RTCPeerConnection? _peerConnection;
  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;
  RTCDataChannel? _midiDataChannel;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  /// Initialize WebRTC
  Future<void> initialize() async {
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    
    await _localRenderer!.initialize();
    await _remoteRenderer!.initialize();
    
    debugPrint('📹 WebRTC Service initialized');
  }
  
  /// Start video call
  Future<void> startCall() async {
    // Get local media stream (camera + microphone)
    final mediaConstraints = {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': false, // Important for music!
      },
      'video': {
        'facingMode': 'user',
        'width': 1280,
        'height': 720,
      }
    };
    
    final localStream = await navigator.mediaDevices.getUserMedia(
      mediaConstraints,
    );
    
    _localRenderer!.srcObject = localStream;
    
    // TODO: Setup peer connection with STUN/TURN servers
    // TODO: Create offer/answer for signaling
    
    _isConnected = true;
    notifyListeners();
    
    debugPrint('🎥 Video call started');
  }
  
  /// Send MIDI data through WebRTC DataChannel
  /// This is faster than WebSocket for real-time data
  void sendMidiData(String midiData) {
    if (_midiDataChannel != null) {
      final message = RTCDataChannelMessage(midiData);
      _midiDataChannel!.send(message);
    }
  }
  
  /// Mute/unmute microphone
  void toggleMic() {
    final tracks = _localRenderer?.srcObject?.getAudioTracks();
    if (tracks != null && tracks.isNotEmpty) {
      final enabled = tracks[0].enabled;
      tracks[0].enabled = !enabled;
      notifyListeners();
    }
  }
  
  /// Turn camera on/off
  void toggleCamera() {
    final tracks = _localRenderer?.srcObject?.getVideoTracks();
    if (tracks != null && tracks.isNotEmpty) {
      final enabled = tracks[0].enabled;
      tracks[0].enabled = !enabled;
      notifyListeners();
    }
  }
  
  /// End call
  Future<void> endCall() async {
    _localRenderer?.srcObject?.getTracks().forEach((track) {
      track.stop();
    });
    
    _peerConnection?.close();
    _peerConnection = null;
    
    _isConnected = false;
    notifyListeners();
    
    debugPrint('📴 Call ended');
  }
  
  RTCVideoRenderer? get localRenderer => _localRenderer;
  RTCVideoRenderer? get remoteRenderer => _remoteRenderer;
  
  @override
  void dispose() {
    endCall();
    _localRenderer?.dispose();
    _remoteRenderer?.dispose();
    super.dispose();
  }
}
