import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocam_pos/core/network/exceptions.dart';

/// BLoC state'lariga tushadigan xato obyekti.
///
/// Foydalanuvchiga ko'rsatish uchun [message] o'zbek tilida tayyor bo'ladi.
class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  /// Har qanday xatoni foydalanuvchi tushunadigan [Failure] ga aylantiradi.
  factory Failure.from(Object error) {
    if (error is Failure) return error;

    if (error is FirebaseAuthException) {
      return Failure(_authMessage(error.code), code: error.code);
    }

    if (error is FirebaseException) {
      return Failure(_firestoreMessage(error.code), code: error.code);
    }

    if (error is AppException) {
      return Failure(error.message, code: error.code);
    }

    return Failure("Kutilmagan xatolik yuz berdi", code: 'unknown');
  }

  static String _authMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "Bu email allaqachon ro'yxatdan o'tgan";
      case 'weak-password':
        return "Parol juda zaif, kamida 6 ta belgi kiriting";
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return "Email yoki parol noto'g'ri";
      case 'invalid-email':
        return "Email formati noto'g'ri";
      case 'user-disabled':
        return "Bu hisob bloklangan";
      case 'too-many-requests':
        return "Juda ko'p urinish. Biroz kutib turing";
      case 'network-request-failed':
        return "Internet aloqasi yo'q";
      case 'requires-recent-login':
        return "Xavfsizlik uchun qaytadan tizimga kiring";
      default:
        return "Kirishda xatolik yuz berdi";
    }
  }

  static String _firestoreMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return "Bu amalga ruxsatingiz yo'q";
      case 'unavailable':
      case 'deadline-exceeded':
        return "Server javob bermayapti. Internetni tekshiring";
      case 'not-found':
        return "Ma'lumot topilmadi";
      case 'already-exists':
        return "Bunday yozuv allaqachon mavjud";
      case 'failed-precondition':
        return "Amalni bajarib bo'lmadi. Ma'lumotlarni tekshiring";
      default:
        return "Ma'lumotlarni yuklashda xatolik";
    }
  }

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => message;
}
