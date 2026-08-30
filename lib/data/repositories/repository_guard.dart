import 'package:ocam_pos/core/network/failure.dart';

/// Repository'lar uchun umumiy xato "qalqoni".
///
/// Data qatlamidagi har qanday xato (Firebase, tarmoq, validatsiya) shu yerda
/// [Failure] ga aylanadi. Shu sababli BLoC'lar Firebase haqida hech narsa
/// bilmaydi — backend almashsa ular o'zgarmaydi.
mixin RepositoryGuard {
  Future<T> guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw Failure.from(error);
    }
  }

  Stream<T> guardStream<T>(Stream<T> Function() source) {
    try {
      return source().handleError((Object error) {
        throw Failure.from(error);
      });
    } catch (error) {
      return Stream<T>.error(Failure.from(error));
    }
  }
}
