import 'package:flutter/material.dart';
import '../features/common/stub_helper.dart';

class ComingSoonAction extends StatelessWidget {
  const ComingSoonAction({
    super.key,
    required this.icon,
    required this.label,
    required this.title,
    required this.description,
    this.presentation = StubPresentation.screen,
    this.disabled = true,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.borderColor = const Color(0xFFD4AF37),
    this.foregroundColor = const Color(0xFFD4AF37),
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  });

  final IconData icon;
  final String label;
  final String title;
  final String description;
  final StubPresentation presentation;
  final bool disabled;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;

  Future<void> _open(BuildContext context) async {
    if (presentation == StubPresentation.bottomSheet) {
      await showComingSoonSheet(
        context,
        title,
        description,
        icon: icon,
      );
      return;
    }

    await openStub(
      context,
      title,
      description,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.78 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _open(context),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: foregroundColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DisabledAction extends StatelessWidget {
  const DisabledAction({
    super.key,
    required this.icon,
    required this.label,
    required this.title,
    required this.description,
    this.presentation = StubPresentation.screen,
  });

  final IconData icon;
  final String label;
  final String title;
  final String description;
  final StubPresentation presentation;

  @override
  Widget build(BuildContext context) {
    return ComingSoonAction(
      icon: icon,
      label: label,
      title: title,
      description: description,
      presentation: presentation,
      disabled: true,
    );
  }
}
