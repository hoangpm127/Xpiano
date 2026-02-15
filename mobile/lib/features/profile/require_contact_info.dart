import 'package:flutter/material.dart';

import '../../services/supabase_service.dart';
import '../../widgets/contact_info_bottom_sheet.dart';

Future<void> requireContactInfo(
  BuildContext context, {
  required Future<void> Function() onOk,
  SupabaseService? service,
}) async {
  final supabaseService = service ?? SupabaseService();

  if (supabaseService.currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ban can dang nhap de tiep tuc.')),
    );
    return;
  }

  Map<String, dynamic> profile;
  try {
    profile = await supabaseService.getMyProfile();
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Khong the tai profile: $e')),
    );
    return;
  }

  final hasContact = supabaseService.profileHasContactInfo(profile);
  if (hasContact) {
    await onOk();
    return;
  }

  if (!context.mounted) return;

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => ContactInfoBottomSheet(
      initialPhone: profile['phone']?.toString() ?? '',
      initialAddressLine: profile['address_line']?.toString() ?? '',
      initialCity: profile['city']?.toString() ?? '',
      initialDistrict: profile['district']?.toString() ?? '',
      onSubmit: (phone, addressLine, city, district) async {
        await supabaseService.upsertContactInfo(
          phone: phone,
          addressLine: addressLine,
          city: city,
          district: district,
        );
      },
    ),
  );

  if (saved == true && context.mounted) {
    await onOk();
  }
}
