import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/data/participant_models.dart';
import '../../../core/network/api_call.dart';
import '../../../core/network/api_exceptions.dart';

/// Service API Sertifikat Peserta
class CertificateApiService {
  final Dio _dio;

  CertificateApiService(this._dio);

  /// GET /certificates/my — sertifikat yang sudah terbit untuk peserta
  Future<List<Certificate>> getMyCertificates() => apiCall(
        () => _dio.get(ApiEndpoints.myCertificates),
        (data) =>
            jsonList(data).map((e) => Certificate.fromJson(jsonMap(e))).toList(),
      );

  /// GET /certificates/verify/:nomor — verifikasi keaslian (publik)
  Future<CertificateVerification> verifyCertificate(String serialNumber) =>
      apiCall(
        () => _dio.get(ApiEndpoints.verifyCertificate(serialNumber.trim())),
        (data) => CertificateVerification.fromJson(jsonMap(data)),
      );

  /// GET /certificates/issued/:code/pdf — berkas PDF resmi (ber-QR verifikasi)
  Future<Uint8List> downloadCertificatePdf(String code) async {
    try {
      final response = await _dio.get<List<int>>(
        ApiEndpoints.downloadCertificate(code),
        options: Options(
            responseType: ResponseType.bytes,
            headers: {'Accept': 'application/pdf'}),
      );
      final bytes = response.data ?? const <int>[];
      if (bytes.length < 4 || String.fromCharCodes(bytes.take(4)) != '%PDF') {
        throw const ApiException(message: 'Berkas sertifikat tidak valid.');
      }
      return Uint8List.fromList(bytes);
    } on DioException catch (e) {
      // Respons galat juga berupa bytes; ubah kembali ke JSON agar pesan
      // server (mis. "Anda tidak berhak mengunduh sertifikat ini") tampil.
      final raw = e.response?.data;
      if (raw is List<int>) {
        try {
          final decoded = jsonDecode(utf8.decode(raw));
          throw toApiException(DioException(
              requestOptions: e.requestOptions,
              response: Response(
                  requestOptions: e.requestOptions,
                  statusCode: e.response?.statusCode,
                  data: decoded),
              type: e.type));
        } on FormatException {
          // bukan JSON — pakai pesan umum di bawah
        }
      }
      throw toApiException(e);
    }
  }

  /// GET /certificates/corrections — riwayat pengajuan perbaikan saya
  Future<List<CertificateCorrection>> getMyCorrections() => apiCall(
        () => _dio.get(ApiEndpoints.certificateCorrections),
        (data) => jsonList(data)
            .map((e) => CertificateCorrection.fromJson(jsonMap(e)))
            .toList(),
      );

  /// POST /certificates/corrections — mengajukan perbaikan data sertifikat.
  /// [changes]: field (`recipient`, `degree`, `activity`, `other`) → nilai baru.
  Future<CertificateCorrection> requestCorrection({
    required String certificateCode,
    required Map<String, String> changes,
    required String reason,
  }) =>
      apiCall(
        () => _dio.post(ApiEndpoints.certificateCorrections, data: {
          'certificateId': certificateCode,
          'changes': [
            for (final entry in changes.entries)
              {'field': entry.key, 'newValue': entry.value}
          ],
          'reason': reason,
          'agreed': true,
        }),
        (data) => CertificateCorrection.fromJson(jsonMap(data)),
      );
}
