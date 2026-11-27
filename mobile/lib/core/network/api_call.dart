import 'package:dio/dio.dart';
import 'api_exceptions.dart';

/// Menjalankan permintaan HTTP ke backend dan mengembalikan field `data`
/// dari respons standar `{ success, message, data }`.
///
/// Seluruh kegagalan diubah menjadi [ApiException] dengan pesan dari server
/// (berbahasa Indonesia), sehingga layar cukup menampilkan `error.message`.
Future<T> apiCall<T>(
  Future<Response<dynamic>> Function() request,
  T Function(dynamic data) parse,
) async {
  try {
    final response = await request();
    final body = response.data;
    if (body is Map && body['success'] == false) {
      throw _fromBody(body, response.statusCode);
    }
    return parse(body is Map ? body['data'] : body);
  } on DioException catch (e) {
    throw toApiException(e);
  } on ApiException {
    rethrow;
  } on FormatException catch (e) {
    throw ApiException(message: 'Format data dari server tidak sesuai: ${e.message}');
  } on TypeError catch (e) {
    throw ApiException(message: 'Format data dari server tidak sesuai: $e');
  }
}

/// Mengubah [DioException] menjadi [ApiException] yang ramah pengguna.
ApiException toApiException(DioException e) {
  final body = e.response?.data;
  final status = e.response?.statusCode;
  if (body is Map) {
    final error = _fromBody(body, status);
    if (status == 401) {
      return UnauthorizedException(message: error.message, errors: error.errors);
    }
    return error;
  }
  if (status != null) {
    return ApiException(
        message: 'Server mengembalikan kesalahan ($status).', statusCode: status);
  }
  final base = e.requestOptions.baseUrl;
  return NetworkException(
    message: switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'Server terlalu lama merespons. Periksa koneksi lalu coba lagi.',
      _ => 'Tidak dapat terhubung ke server ($base). '
          'Pastikan backend berjalan dan perangkat terhubung ke jaringan yang sama.',
    },
  );
}

ApiException _fromBody(Map<dynamic, dynamic> body, int? status) {
  final rawErrors = body['errors'];
  final errors = <String>[];
  String? state;
  if (rawErrors is List) {
    for (final item in rawErrors) {
      if (item is Map && item['state'] is String) {
        state ??= item['state'] as String;
      } else if (item != null) {
        errors.add(item.toString());
      }
    }
  }
  final message = body['message'];
  return ApiException(
    message: message is String && message.isNotEmpty
        ? message
        : 'Terjadi kesalahan pada server',
    statusCode: status,
    errors: errors,
    state: state,
  );
}

/// Helper konversi JSON yang toleran terhadap tipe angka/teks dari server.
String jsonString(dynamic value, [String fallback = '']) =>
    value == null ? fallback : value.toString();

String? jsonStringOrNull(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int? jsonInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? jsonDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

Map<String, dynamic> jsonMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<dynamic> jsonList(dynamic value) => value is List ? value : const [];
