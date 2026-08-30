import 'dart:io';

/// Internet aloqasi bor-yo'qligini tekshiradi.
///
/// Qo'shimcha paketsiz ishlaydi — DNS so'rovi orqali tekshiradi.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Duration timeout;

  const NetworkInfoImpl({this.timeout = const Duration(seconds: 3)});

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup(
        'one.one.one.one',
      ).timeout(timeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
