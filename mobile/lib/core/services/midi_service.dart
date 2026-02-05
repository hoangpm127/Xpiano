import 'dart:async';
import 'package:flutter/foundation.dart';

/// MIDI Service for handling real-time piano input
/// Target latency: < 10ms
class MidiService with ChangeNotifier {
  StreamController<MidiEvent>? _midiEventController;
  Stream<MidiEvent>? _midiEventStream;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  /// Initialize MIDI service and scan for devices
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _midiEventController = StreamController<MidiEvent>.broadcast();
    _midiEventStream = _midiEventController!.stream;
    
    // TODO: Add flutter_midi_command package
    // await MidiCommand().startScanningForBluetoothDevices();
    
    _isInitialized = true;
    notifyListeners();
    
    debugPrint('🎹 MIDI Service initialized');
  }
  
  /// Listen to MIDI events (notes, velocity, etc.)
  Stream<MidiEvent>? get midiEventStream => _midiEventStream;
  
  /// Send MIDI event (for playback or forwarding to teacher)
  void sendMidiEvent(MidiEvent event) {
    if (!_isInitialized) return;
    _midiEventController?.add(event);
    debugPrint('🎵 MIDI Event: ${event.note} velocity: ${event.velocity}');
  }
  
  /// Dispose service
  @override
  void dispose() {
    _midiEventController?.close();
    _isInitialized = false;
    super.dispose();
  }
}

/// MIDI Event model
class MidiEvent {
  final int note; // 0-127
  final int velocity; // 0-127 (0 = note off)
  final DateTime timestamp;
  
  MidiEvent({
    required this.note,
    required this.velocity,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  bool get isNoteOn => velocity > 0;
  bool get isNoteOff => velocity == 0;
  
  @override
  String toString() => 'Note: $note, Velocity: $velocity';
}
