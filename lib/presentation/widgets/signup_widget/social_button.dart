import 'package:flutter/material.dart';

class AuthSocialButton extends StatelessWidget {
  final String type;
  const AuthSocialButton({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Center(
        child: type == "fb"
            ? const Icon(Icons.facebook, color: Colors.blue, size: 30)
            : const Icon(Icons.g_mobiledata, color: Colors.red, size: 40),
      ),
    );
  }
}
