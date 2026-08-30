import 'package:flutter/material.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';

class AuthSocialButton extends StatelessWidget {
  final String type;
  const AuthSocialButton({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      // Ijtimoiy tarmoq orqali kirish hali ulanmagan — backend tayyor
      // bo'lganda shu yerga tegishli oqim qo'shiladi.
      onTap: () => AppSnackBar.info(context, "Tez orada qo'shiladi"),
      child: Container(
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
      ),
    );
  }
}
