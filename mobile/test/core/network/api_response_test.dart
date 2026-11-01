import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_peserta/core/network/api_response.dart';

void main() {
  group('ApiResponse Serialization Test', () {
    test('berhasil mem-parse response sukses standar backend', () {
      final json = {
        'success': true,
        'message': 'Data berhasil dimuat',
        'data': {'id': '1', 'title': 'Workshop Flutter'},
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (raw) => raw as Map<String, dynamic>,
      );

      expect(response.success, isTrue);
      expect(response.message, equals('Data berhasil dimuat'));
      expect(response.data?['title'], equals('Workshop Flutter'));
      expect(response.errors, isEmpty);
    });

    test('berhasil mem-parse response gagal dengan array errors', () {
      final json = {
        'success': false,
        'message': 'Validasi gagal',
        'errors': [
          'Email tidak valid',
          'Password minimal 8 karakter',
        ],
      };

      final response = ApiResponse<dynamic>.fromJson(json, null);

      expect(response.success, isFalse);
      expect(response.message, equals('Validasi gagal'));
      expect(response.errors.length, equals(2));
      expect(response.errors[0], equals('Email tidak valid'));
      expect(response.errors[1], equals('Password minimal 8 karakter'));
      expect(response.data, isNull);
    });
  });
}

