import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Server backend tiruan untuk pengujian.
///
/// Meniru bentuk respons backend asli (WorkshopFTIPPSI/backend):
/// `{ success, message, data }` / `{ success:false, message, errors }`,
/// termasuk `myRegistration.attendanceDays` dan `attendanceDate`.
/// Dipasang sebagai [HttpClientAdapter] Dio sehingga API service, store,
/// dan layar yang diuji adalah kode produksi apa adanya.
class FakeBackend implements HttpClientAdapter {
  FakeBackend() {
    reset();
  }

  static const token = 'token-peserta';
  static const validCode = 'ABC123';

  final requests = <String>[];

  /// Simulasikan token yang sudah tidak berlaku (server membalas 401)
  bool tokenExpired = false;
  late Map<String, dynamic> user;
  late List<Map<String, dynamic>> workshops;
  late Map<String, Map<String, dynamic>> registrations;
  late List<Map<String, dynamic>> notifications;
  late List<Map<String, dynamic>> certificates;
  late List<Map<String, dynamic>> corrections;
  int _nextId = 100;

  void reset() {
    requests.clear();
    user = {
      'id': 7,
      'nama': 'Aulia Rahman',
      'email': 'peserta@unand.ac.id',
      'telepon': '0812 3456 7890',
      'role': 'peserta',
      'jenis': 'Mahasiswa',
      'nim': '2211521007',
    };
    workshops = [
      _workshop(
          slug: 'data-science',
          nama: 'Workshop Data Science dan Artificial Intelligence',
          jenis: 'Workshop',
          mode: 'offline',
          mulai: '2026-06-28',
          selesai: '2026-06-29',
          kuota: 120,
          pendaftar: 86,
          status: 'publik',
          registrationState: 'open',
          attendanceState: 'not-open',
          gedung: 'Gedung Convention Hall',
          ruangan: 'Ruang Seminar Lantai 2'),
      _workshop(
          slug: 'kuliah-umum-ai',
          nama: 'Kuliah Umum Artificial Intelligence',
          jenis: 'Kuliah Umum',
          mode: 'offline',
          mulai: '2026-06-18',
          selesai: '2026-06-18',
          kuota: 500,
          pendaftar: 388,
          status: 'berlangsung',
          registrationState: 'closed',
          attendanceState: 'open',
          gedung: 'Auditorium Utama',
          ruangan: ''),
      _workshop(
          slug: 'bootcamp-digital',
          nama: 'Bootcamp Keterampilan Digital',
          jenis: 'Workshop',
          mode: 'online',
          mulai: '2026-06-17',
          selesai: '2026-06-19',
          attendanceDate: '2026-06-18',
          kuota: null,
          pendaftar: 40,
          status: 'berlangsung',
          registrationState: 'closed',
          attendanceState: 'open'),
      _workshop(
          slug: 'public-speaking',
          nama: 'Workshop Public Speaking Profesional',
          jenis: 'Seminar',
          mode: 'offline',
          mulai: '2026-07-05',
          selesai: '2026-07-05',
          kuota: 60,
          pendaftar: 60,
          status: 'publik',
          registrationState: 'open',
          attendanceState: 'not-open',
          gedung: 'Gedung Rektorat',
          ruangan: 'Ruang Sidang Senat'),
      _workshop(
          slug: 'karya-ilmiah',
          nama: 'Workshop Penulisan Karya Ilmiah',
          jenis: 'Workshop',
          mode: 'offline',
          mulai: '2026-05-12',
          selesai: '2026-05-12',
          kuota: 80,
          pendaftar: 80,
          status: 'selesai',
          registrationState: 'closed',
          attendanceState: 'closed',
          gedung: 'Gedung Pascasarjana',
          ruangan: 'Ruang 3.1'),
    ];
    registrations = {
      'kuliah-umum-ai': _registration(11, 'kuliah-umum-ai'),
      'bootcamp-digital': _registration(12, 'bootcamp-digital'),
      'karya-ilmiah': _registration(13, 'karya-ilmiah', status: 'completed')
        ..['attendanceDays'] = [
          {'id': 1, 'date': '2026-05-12', 'status': 'present', 'method': 'qr-location'}
        ],
    };
    notifications = [
      {
        'id': 1,
        'judul': 'Pendaftaran dikonfirmasi: Kuliah Umum Artificial Intelligence',
        'deskripsi': 'Kursi Anda sudah tercatat.',
        'link': '/peserta/workshop-saya',
        'belumDibaca': true,
        'waktu': '17 Juni 2026, 10.00 · belum dibaca',
      },
      {
        'id': 2,
        'judul': 'Sertifikat Sudah Tersedia',
        'deskripsi': 'Workshop Penulisan Karya Ilmiah',
        'link': '/peserta/sertifikat',
        'belumDibaca': false,
        'waktu': '13 Mei 2026, 09.00',
      },
    ];
    certificates = [
      {
        'id': 'unand-demo-1004',
        'workshopId': 'karya-ilmiah',
        'number': 'UNAND/SERT/1004/2026',
        'issued': '13 Mei 2026',
        'recipient': 'Aulia Rahman',
        'issuer': 'UNAND',
        'kind': 'Workshop',
        'degree': '',
      }
    ];
    corrections = [];
  }

  static Map<String, dynamic> _workshop({
    required String slug,
    required String nama,
    required String jenis,
    required String mode,
    required String mulai,
    required String selesai,
    String? attendanceDate,
    required int? kuota,
    required int pendaftar,
    required String status,
    required String registrationState,
    required String attendanceState,
    String gedung = '',
    String ruangan = '',
  }) =>
      {
        'id': slug.hashCode,
        'slug': slug,
        'nama': nama,
        'title': nama,
        'jenis': jenis,
        'mode': mode,
        'tema': 'Tema $nama',
        'tanggalMulai': mulai,
        'tanggalSelesai': selesai,
        'waktuMulai': '09:00',
        'waktuSelesai': '12:00',
        'periodePendaftaran': '1 Juni 2026 – 25 Juni 2026',
        'penyelenggara': 'Universitas Andalas',
        'gedung': gedung,
        'ruangan': ruangan,
        'place': mode == 'online' ? 'Zoom Meeting' : gedung,
        'latitude': null,
        'longitude': null,
        'meetingUrl': mode == 'online' ? 'https://zoom.us/j/123' : null,
        'kuota': kuota,
        'remaining': kuota == null ? 9999 : (kuota - pendaftar).clamp(0, kuota),
        'waitingListEnabled': false,
        'status': status,
        'registrationState': registrationState,
        'attendanceState': attendanceState,
        'attendanceDate': attendanceDate ?? mulai,
        'deskripsi': 'Deskripsi $nama.',
        'manfaat': 'Sertifikat elektronik\nPraktik langsung',
        'targetPeserta': 'Mahasiswa UNAND dan peserta umum',
        'pemateri': 'Dr. Rina Kurniawati',
        'image': '',
        'completed': status == 'selesai',
        'cancelled': status == 'dibatalkan',
      };

  static Map<String, dynamic> _registration(int id, String slug,
          {String status = 'registered'}) =>
      {
        'registrationId': id,
        'workshopId': slug,
        'status': status,
        'attendanceDays': <Map<String, dynamic>>[],
      };

  Map<String, dynamic> _withRegistration(Map<String, dynamic> w) =>
      {...w, 'myRegistration': registrations[w['slug']]};

  Map<String, dynamic>? _findWorkshop(Object? idOrSlug) {
    for (final w in workshops) {
      if (w['slug'] == idOrSlug || '${w['id']}' == '$idOrSlug') return w;
    }
    return null;
  }

  // ───────────────────────── HTTP ─────────────────────────

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final path = options.uri.path.replaceFirst(RegExp(r'^/api/v1'), '');
    final method = options.method.toUpperCase();
    requests.add('$method $path');
    final body = options.data is Map
        ? Map<String, dynamic>.from(options.data as Map)
        : <String, dynamic>{};
    final authed =
        !tokenExpired && options.headers['Authorization'] == 'Bearer $token';

    ResponseBody ok(Object? data, [int status = 200]) =>
        _json({'success': true, 'message': 'OK', 'data': data}, status);
    ResponseBody fail(int status, String message, [List<Object> errors = const []]) =>
        _json({'success': false, 'message': message, 'errors': errors}, status);

    if (method == 'POST' && path == '/auth/login') {
      if (body['password'] != 'password123') {
        return fail(401, 'Email atau kata sandi salah');
      }
      if (body['email'] == 'humas@unand.ac.id') {
        return ok({
          'token': 'token-humas',
          'user': {'id': 2, 'nama': 'Humas', 'email': 'humas@unand.ac.id', 'role': 'humas'}
        });
      }
      return ok({'token': token, 'user': user});
    }
    if (method == 'POST' && path == '/auth/register') {
      user = {
        'id': 50,
        'nama': body['nama'],
        'email': body['email'],
        'telepon': body['telepon'] ?? '',
        'role': 'peserta',
        'jenis': body['jenis'],
        'nim': body['nim'],
      };
      registrations = {};
      return ok({'token': token, 'user': user}, 201);
    }
    if (method == 'GET' && path.startsWith('/certificates/verify/')) {
      final number = Uri.decodeComponent(path.substring('/certificates/verify/'.length));
      final cert = certificates.where((c) => c['number'] == number);
      if (cert.isEmpty) return fail(404, 'Nomor sertifikat tidak terdaftar');
      return ok({
        'valid': true,
        ...cert.first,
        'namaKegiatan': 'Workshop Penulisan Karya Ilmiah',
        'tanggalKegiatan': '12 Mei 2026',
        'kodeKeaslian': 'A1B2C3',
        'penandatangan': [
          {'peran': 'Rektor Universitas Andalas', 'nama': 'Prof. Rektor'}
        ],
      });
    }
    if (!authed) return fail(401, 'Akses ditolak: Token autentikasi tidak ditemukan');

    switch ((method, path)) {
      case ('GET', '/auth/me'):
        return ok(user);
      case ('PUT', '/auth/me'):
        user = {...user, 'nama': body['nama'], 'telepon': body['telepon']};
        return ok(user);
      case ('POST', '/auth/logout'):
        return ok(null);
      case ('GET', '/workshops'):
        return ok(workshops.map(_withRegistration).toList());
      case ('POST', '/registrations'):
        final w = _findWorkshop(body['workshopId']);
        if (w == null) return fail(404, 'Kegiatan tidak ditemukan');
        if (registrations[w['slug']]?['status'] == 'registered') {
          return fail(409, 'Anda sudah terdaftar pada kegiatan ini');
        }
        if (w['registrationState'] != 'open') {
          return fail(422, 'Pendaftaran sudah ditutup');
        }
        if (w['kuota'] != null && w['remaining'] == 0) {
          return fail(422, 'Kuota penuh dan waiting list tidak tersedia');
        }
        registrations[w['slug'] as String] = _registration(_nextId++, w['slug'] as String);
        return ok(_withRegistration(w), 201);
      case ('GET', '/notifications'):
        return ok(notifications);
      case ('PATCH', '/notifications/read'):
        for (final n in notifications) {
          if (body['id'] == null || n['id'] == body['id']) n['belumDibaca'] = false;
        }
        return ok(null);
      case ('GET', '/certificates/my'):
        return ok(certificates);
      case ('GET', '/certificates/corrections'):
        return ok(corrections);
      case ('POST', '/certificates/corrections'):
        if (body['agreed'] != true) return fail(400, 'Setujui pernyataan kebenaran data sebelum mengirim.');
        if ((body['reason'] as String? ?? '').length < 10) {
          return fail(400, 'Jelaskan alasan perbaikan dalam 10–1.000 karakter.');
        }
        final correction = {
          'id': 'PB-2026-${3000 + corrections.length + 1}',
          'certificateId': body['certificateId'],
          'status': 'menunggu',
          'changes': body['changes'],
        };
        corrections.insert(0, correction);
        return ok(correction, 201);
      case ('POST', '/attendance/check-in'):
        return _submitAttendance(body, upload: false);
      case ('POST', '/attendance/upload'):
        return _submitAttendance(body, upload: true);
    }

    final cancel = RegExp(r'^/registrations/(\d+)/cancel$').firstMatch(path);
    if (method == 'PATCH' && cancel != null) {
      final id = int.parse(cancel.group(1)!);
      for (final entry in registrations.entries) {
        if (entry.value['registrationId'] == id) {
          entry.value['status'] = 'cancelled';
          return ok(_withRegistration(_findWorkshop(entry.key)!));
        }
      }
      return fail(404, 'Pendaftaran tidak ditemukan');
    }
    final pdf = RegExp(r'^/certificates/issued/([^/]+)/pdf$').firstMatch(path);
    if (method == 'GET' && pdf != null) {
      final code = Uri.decodeComponent(pdf.group(1)!);
      if (!certificates.any((c) => c['id'] == code)) {
        return fail(403, 'Anda tidak berhak mengunduh sertifikat ini');
      }
      return ResponseBody.fromBytes(utf8.encode('%PDF-1.4 sertifikat'), 200,
          headers: {
            Headers.contentTypeHeader: ['application/pdf']
          });
    }
    return fail(404, 'Endpoint tidak ditemukan: $method $path');
  }

  ResponseBody _submitAttendance(Map<String, dynamic> body, {required bool upload}) {
    final w = _findWorkshop(body['workshopId']);
    if (w == null) return _json({'success': false, 'message': 'Kegiatan tidak ditemukan'}, 404);
    ResponseBody state(String s, String message) => _json({
          'success': false,
          'message': message,
          'errors': [
            {'state': s}
          ]
        }, 422);
    final reg = registrations[w['slug']];
    if (reg == null || reg['status'] == 'cancelled') {
      return state('not-registered', 'Anda belum terdaftar pada kegiatan ini');
    }
    if (w['attendanceState'] != 'open') {
      return state('not-open', 'Sesi presensi tidak sedang dibuka');
    }
    final date = w['attendanceDate'];
    final days = (reg['attendanceDays'] as List).cast<Map<String, dynamic>>();
    final existing = days.where((d) => d['date'] == date && d['status'] != 'rejected');
    if (existing.isNotEmpty) {
      return state(existing.first['status'] == 'present' ? 'present' : 'pending',
          'Presensi Anda untuk sesi ini sudah tercatat');
    }
    if (!upload && body['code'] != validCode) {
      return state('invalid-code', 'Kode presensi tidak valid atau kedaluwarsa');
    }
    if (upload && !(body['fileData'] as String? ?? '').startsWith('data:image/')) {
      return _json({'success': false, 'message': 'Bukti harus berupa PNG, JPG, atau PDF'}, 400);
    }
    days.removeWhere((d) => d['date'] == date);
    days.add({
      'id': _nextId++,
      'date': date,
      'status': upload ? 'pending' : 'present',
      'method': upload ? 'upload' : 'qr-location',
      if (upload) 'fileName': body['fileName'],
    });
    reg['attendanceDays'] = days;
    return _json({'success': true, 'message': 'OK', 'data': _withRegistration(w)}, 200);
  }

  static ResponseBody _json(Object body, int status) =>
      ResponseBody.fromString(jsonEncode(body), status, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      });

  @override
  void close({bool force = false}) {}
}
