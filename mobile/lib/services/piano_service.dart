import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/piano_model.dart';

class PianoService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<PianoModel>> getPianos() async {
    try {
      final response = await _client.from('pianos').select();
      
      final data = response as List<dynamic>;
      return data.map((json) => PianoModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching pianos: $e');
      return [];
    }
  }
}
