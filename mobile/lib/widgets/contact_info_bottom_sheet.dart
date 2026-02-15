import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactInfoBottomSheet extends StatefulWidget {
  const ContactInfoBottomSheet({
    super.key,
    required this.initialPhone,
    required this.initialAddressLine,
    required this.initialCity,
    required this.initialDistrict,
    required this.onSubmit,
  });

  final String initialPhone;
  final String initialAddressLine;
  final String initialCity;
  final String initialDistrict;
  final Future<void> Function(
    String phone,
    String addressLine,
    String? city,
    String? district,
  ) onSubmit;

  @override
  State<ContactInfoBottomSheet> createState() => _ContactInfoBottomSheetState();
}

class _ContactInfoBottomSheetState extends State<ContactInfoBottomSheet> {
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _districtController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
    _addressController = TextEditingController(text: widget.initialAddressLine);
    _cityController = TextEditingController(text: widget.initialCity);
    _districtController = TextEditingController(text: widget.initialDistrict);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final phone = _phoneController.text.trim();
    final addressLine = _addressController.text.trim();
    final city = _cityController.text.trim();
    final district = _districtController.text.trim();

    if (phone.isEmpty || addressLine.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui long nhap so dien thoai va dia chi nhan hang.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(
        phone,
        addressLine,
        city.isEmpty ? null : city,
        district.isEmpty ? null : district,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Luu thong tin that bai: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Bo sung thong tin lien he',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Can thong tin nay de xac nhan coc/thue dan.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _phoneController,
              label: 'So dien thoai',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            _buildField(
              controller: _addressController,
              label: 'Dia chi',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _cityController,
                    label: 'Tinh/Thanh pho',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildField(
                    controller: _districtController,
                    label: 'Quan/Huyen',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        'Luu va tiep tuc',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
