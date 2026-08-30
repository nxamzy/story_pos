import 'dart:convert';
import 'dart:io';

import 'package:ocam_pos/core/network/exceptions.dart';

/// Kelajakda ulanadigan REST backend uchun tayyor HTTP klient.
///
/// Hozir Firestore ishlatilyapti, lekin datasource'lar interfeys ortida
/// bo'lgani uchun backend tayyor bo'lganda faqat `*_remote_datasource_impl`
/// fayllari shu klientga o'tkaziladi — BLoC va UI umuman o'zgarmaydi.
abstract class ApiClient {
  Future<dynamic> get(String path, {Map<String, dynamic>? query});
  Future<dynamic> post(String path, {Object? body});
  Future<dynamic> put(String path, {Object? body});
  Future<dynamic> delete(String path);
}

class HttpApiClient implements ApiClient {
  final String baseUrl;
  final Duration timeout;

  /// Token kerak bo'lganda shu callback orqali beriladi
  /// (Firebase ID token yoki backend JWT).
  final Future<String?> Function()? tokenProvider;

  HttpApiClient({
    required this.baseUrl,
    this.tokenProvider,
    this.timeout = const Duration(seconds: 20),
  });

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send('GET', path, query: query);

  @override
  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  @override
  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  @override
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final uri = Uri.parse(
        '$baseUrl$path',
      ).replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));

      final request = await client.openUrl(method, uri).timeout(timeout);
      request.headers.contentType = ContentType.json;

      final token = await tokenProvider?.call();
      if (token != null) {
        request.headers.add(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      if (body != null) request.write(jsonEncode(body));

      final response = await request.close().timeout(timeout);
      final raw = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return raw.isEmpty ? null : jsonDecode(raw);
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw AuthException(
          "Sessiya tugagan, qaytadan kiring",
          code: '${response.statusCode}',
        );
      }
      if (response.statusCode == 404) throw const NotFoundException();

      throw ServerException(
        "Server xatosi (${response.statusCode})",
        code: '${response.statusCode}',
      );
    } on SocketException {
      throw const NetworkException();
    } on HttpException catch (e) {
      throw ServerException(e.message);
    } finally {
      client.close();
    }
  }
}
