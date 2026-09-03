import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension AppNavigation on BuildContext {
  /// Orqaga qaytaradi; qaytadigan sahifa bo'lmasa [fallback] ga o'tadi.
  ///
  /// Kerak bo'lish sababi: tizimdan chiqilganda GoRouter'ning `redirect`i
  /// login sahifasini stack ildiziga qo'yadi. Bunday holatda oddiy
  /// `context.pop()` "nothing to pop" xatosini beradi — orqaga tugmasi
  /// ilovani yiqitardi.
  void popOrGo(String fallback) => canPop() ? pop() : go(fallback);
}
