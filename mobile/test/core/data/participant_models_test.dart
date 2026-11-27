import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_peserta/core/config/env.dart';
import 'package:workshop_peserta/core/data/participant_models.dart';
import 'package:workshop_peserta/core/network/api_exceptions.dart';
import 'package:workshop_peserta/modules/attendance/data/attendance_api_service.dart';
import 'package:workshop_peserta/modules/attendance/data/presensi_qr.dart';
import 'package:workshop_peserta/modules/workshops/data/workshop_api_service.dart';

import '../../support/fake_backend.dart';

/// Contoh respons GET /workshops dari backend asli (dipotong)
const _sample = {
  'id': 19,
  'slug': 'klinik-publikasi-ilmiah',
  'nama': 'Klinik Penulisan Publikasi Ilmiah',
  'jenis': 'Pelatihan',
  'mode': 'online',
  'tema': 'Riset & Inovasi',
  'tanggalMulai': '2026-05-18',
  'tanggalSelesai': '2026-05-18',
  'waktuMulai': '13:00',
  'waktuSelesai': '16:00',
  'periodePendaftaran': '1 Mei 2026 – 16 Mei 2026',
  'penyelenggara': 'Universitas Andalas',
  'gedung': '',
  'ruangan': '',
  'kuota': 60,
  'remaining': 34,
  'waitingListEnabled': true,
  'status': 'berlangsung',
  'registrationState': 'closed',
  'attendanceState': 'open',
  'attendanceDate': '2026-05-18',
  'deskripsi': 'Latihan penulisan dan penyuntingan artikel ilmiah.',
  'manfaat': 'Pendampingan naskah dan sertifikat.',
  'targetPeserta': 'Mahasiswa dan dosen',
  'pemateri': 'Dr. Lestari Handayani',
  'image': 'https://images.unsplash.com/photo.jpg',
  'meetingUrl': 'https://zoom.us/j/5550002222',
  'myRegistration': {
    'registrationId': 930,
    'workshopId': 'klinik-publikasi-ilmiah',
    'status': 'registered',
    'attendanceDays': [
      {
        'id': 834,
        'date': '2026-05-18',
        'status': 'rejected',
        'method': 'upload',
        'fileName': 'bukti-publikasi.png',
        'fileUrl': 'http://localhost:5000/uploads/presensi/bukti.png',
        'reason': 'Nama peserta belum terlihat.'
      }
    ]
  }
};

Map<String, dynamic> _with(Map<String, dynamic> changes) =>
    {..._sample, ...changes};

void main() {
  test('kegiatan & pendaftaran dari JSON backend dipetakan dengan benar', () {
    final item = WorkshopWithRegistration.fromJson(_sample);
    final w = item.workshop;
    expect(w.id, 'klinik-publikasi-ilmiah');
    expect(w.dbId, 19);
    expect(w.kind, 'Pelatihan');
    expect(w.delivery, WorkshopDelivery.online);
    expect(w.phase, WorkshopPhase.ongoing);
    expect(w.status, WorkshopStatus.closed);
    expect(w.time, '13.00–16.00 WIB');
    expect(w.date, 'Senin, 18 Mei 2026');
    expect(w.benefits, ['Pendampingan naskah dan sertifikat.']);
    expect(w.days, hasLength(1));
    expect(w.days.single.window, AttendanceWindow.open);

    final r = item.registration!;
    expect(r.id, 930);
    expect(r.attendance, AttendanceStatus.rejected);
    // Bukti ditolak boleh diunggah ulang
    expect(r.canCheckIn, isTrue);
    final day = r.attendanceFor(w.days.single);
    expect(day.reason, 'Nama peserta belum terlihat.');
    // localhost dari PUBLIC_URL diganti host API agar bisa dibuka dari HP/emulator
    expect(day.evidenceUrl,
        '${Env.apiOrigin}/uploads/presensi/bukti.png');
  });

  test('jendela presensi kegiatan multi-hari mengikuti attendanceDate server',
      () {
    final w = Workshop.fromJson(_with({
      'tanggalMulai': '2026-06-17',
      'tanggalSelesai': '2026-06-19',
      'attendanceDate': '2026-06-18',
    }));
    expect(w.days.map((d) => d.id), ['2026-06-17', '2026-06-18', '2026-06-19']);
    expect(w.days.map((d) => d.window), [
      AttendanceWindow.closed,
      AttendanceWindow.open,
      AttendanceWindow.notOpen,
    ]);
    expect(w.shortDate, '17–19 Jun 2026');

    final closed = Workshop.fromJson(_with({'attendanceState': 'closed'}));
    expect(closed.attendanceOpen, isFalse);
    final notOpen = Workshop.fromJson(_with({'attendanceState': 'not-open'}));
    expect(notOpen.days.single.window, AttendanceWindow.notOpen);
  });

  test('status pendaftaran: buka, waiting list, penuh, belum dibuka, selesai',
      () {
    WorkshopStatus status(Map<String, dynamic> c) =>
        Workshop.fromJson(_with({'status': 'publik', ...c})).status;
    expect(status({'registrationState': 'open'}), WorkshopStatus.open);
    expect(status({'registrationState': 'open', 'remaining': 0}),
        WorkshopStatus.waitlist);
    expect(
        status({
          'registrationState': 'open',
          'remaining': 0,
          'waitingListEnabled': false
        }),
        WorkshopStatus.full);
    expect(status({'registrationState': 'not-open'}), WorkshopStatus.notOpen);
    expect(status({'registrationState': 'open', 'kuota': null}),
        WorkshopStatus.open);
    final done = Workshop.fromJson(_with({'status': 'selesai'}));
    expect(done.status, WorkshopStatus.closed);
    expect(done.phase, WorkshopPhase.finished);
    final cancelled = Workshop.fromJson(_with({'status': 'dibatalkan'}));
    expect(cancelled.registrationLabel, 'Kegiatan Dibatalkan');
    expect(cancelled.attendanceOpen, isFalse);
  });

  test('waiting list tidak boleh presensi dan menampilkan antrean', () {
    final item = WorkshopWithRegistration.fromJson(_with({
      'myRegistration': {
        'registrationId': 5,
        'status': 'waiting',
        'queue': 3,
        'attendanceDays': []
      }
    }));
    final r = item.registration!;
    expect(r.isWaiting, isTrue);
    expect(r.statusLabel, 'Waiting List #3');
    expect(r.canCheckIn, isFalse);
  });

  test('isi QR presensi dari portal web maupun kode manual', () {
    final qr = PresensiQr.parse(
        'http://localhost:5173/peserta/workshop-saya?presensi=data-science&kode=ab12cd');
    expect(qr.code, 'AB12CD');
    expect(qr.workshop, 'data-science');
    final manual = PresensiQr.parse('  x9y8z7 ');
    expect(manual.code, 'X9Y8Z7');
    expect(manual.workshop, isEmpty);
  });

  test('notifikasi dipetakan ke rute aplikasi mobile', () {
    final n = AppNotification.fromJson({
      'id': 3,
      'judul': 'Perbaikan Sertifikat Selesai',
      'deskripsi': 'Workshop',
      'link': '/peserta/sertifikat',
      'belumDibaca': true,
      'waktu': '18 Mei 2026, 10.00 · belum dibaca',
    });
    expect(n.route, '/certificates');
    expect(n.read, isFalse);
    expect(n.time, '18 Mei 2026, 10.00');
    expect(n.certificate, isTrue);
    expect(
        AppNotification.fromJson({'id': 1, 'link': '/peserta/workshop-saya'})
            .route,
        '/registrations');
  });

  test('profil: jenis peserta dari backend', () {
    expect(ParticipantProfile.fromJson({'nama': 'A', 'jenis': 'Mahasiswa'}).type,
        'Mahasiswa UNAND');
    expect(ParticipantProfile.fromJson({'nama': 'B', 'jenis': 'Umum'}).type,
        'Peserta Umum');
  });

  test('galat presensi membawa state dari server', () async {
    final backend = FakeBackend();
    final dio = Dio(BaseOptions(
        baseUrl: 'http://api.test/api/v1',
        headers: {'Authorization': 'Bearer ${FakeBackend.token}'}))
      ..httpClientAdapter = backend;
    final service = AttendanceApiService(dio);
    await expectLater(
        service.checkIn(workshopId: 'kuliah-umum-ai', code: 'SALAH1'),
        throwsA(isA<ApiException>()
            .having((e) => e.state, 'state', 'invalid-code')
            .having((e) => e.statusCode, 'statusCode', 422)
            .having((e) => e.message, 'message', contains('tidak valid'))));
    final ok = await service.checkIn(
        workshopId: 'kuliah-umum-ai', code: FakeBackend.validCode);
    expect(ok.registration!.attendance, AttendanceStatus.present);

    final anonymous = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))
      ..httpClientAdapter = backend;
    await expectLater(
        WorkshopApiService(anonymous).getWorkshops(),
        throwsA(isA<UnauthorizedException>()));
  });

  test('Env.resolveMediaUrl', () {
    expect(Env.resolveMediaUrl(null), isNull);
    expect(Env.resolveMediaUrl('https://cdn.example.com/a.png'),
        'https://cdn.example.com/a.png');
    expect(Env.resolveMediaUrl('/uploads/a.png'), '${Env.apiOrigin}/uploads/a.png');
    expect(Env.resolveMediaUrl('http://127.0.0.1:5000/uploads/a.png'),
        '${Env.apiOrigin}/uploads/a.png');
  });
}
