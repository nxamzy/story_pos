import 'package:flutter/material.dart';

class AuthBackButton extends StatelessWidget {
  final Color bg;
  final Color iconColor;
  final VoidCallback onTap;

  const AuthBackButton({
    super.key,
    required this.bg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.chevron_left, color: iconColor, size: 24),
      ),
    );
  }
}
