import 'package:flutter/material.dart';
import '../../screens/stub_screen.dart';

enum StubPresentation {
  screen,
  bottomSheet,
}

Future<void> openStub(
  BuildContext context,
  String title,
  String description, {
  IconData icon = Icons.construction_rounded,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => StubScreen(
        title: title,
        description: description,
        icon: icon,
      ),
    ),
  );
}

Future<void> showComingSoonSheet(
  BuildContext context,
  String title,
  String description, {
  IconData icon = Icons.schedule_rounded,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E6E6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B6B6B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Da hieu',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
