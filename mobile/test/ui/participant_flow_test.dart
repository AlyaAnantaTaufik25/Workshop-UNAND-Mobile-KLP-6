import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_peserta/core/data/participant_store.dart';
import 'package:workshop_peserta/core/network/network_providers.dart';
import 'package:workshop_peserta/modules/attendance/providers/screenshot_provider.dart';
import 'package:workshop_peserta/routing/app_router.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('login menolak akun non-peserta, sandi salah, lalu berhasil',
      (tester) async {
    final app = await startApp(tester, size: const Size(320, 740));
    expect(find.text('Selamat Datang'), findsOneWidget);
    await press(tester, 'Masuk');
    expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
    expect(find.text('Bagian ini wajib diisi.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'humas@unand.ac.id');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byTooltip('Tampilkan kata sandi'));
    await tester.pump();
    expect(find.byTooltip('Sembunyikan kata sandi'), findsOneWidget);
    await press(tester, 'Masuk');
    expect(find.text('Akun ini bukan akun peserta. Silakan gunakan aplikasi web.'),
        findsOneWidget);
    expect(signedIn.value, isFalse);
    expect(app.state.profile, isNull);

    await tester.enterText(
        find.byType(TextFormField).at(0), 'peserta@unand.ac.id');
    await tester.enterText(find.byType(TextFormField).at(1), 'salah-sandi');
    await press(tester, 'Masuk');
    expect(find.text('Email atau kata sandi salah'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await press(tester, 'Masuk');
    expect(find.text('Halo, Aulia'), findsOneWidget);
    expect(app.backend.requests, contains('GET /workshops'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('registrasi peserta umum membuat akun dan langsung masuk',
      (tester) async {
    final app = await startApp(tester);
    await press(tester, 'Daftar sekarang');
    await press(tester, 'Peserta Umum');
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Dinda Maharani');
    await tester.enterText(fields.at(1), 'dinda@example.com');
    await tester.enterText(fields.at(2), '0813 7788 9900');
    await tester.enterText(fields.at(3), 'rahasia123');
    await tester.enterText(fields.at(4), 'rahasia123');
    await press(tester, 'Daftar Akun');
    expect(find.text('Registrasi Berhasil!'), findsOneWidget);
    expect(app.state.profile!.email, 'dinda@example.com');
    expect(app.state.profile!.type, 'Peserta Umum');
    await press(tester, 'Mulai Jelajahi Kegiatan');
    expect(find.text('Halo, Dinda'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('katalog dari server: filter, cari, lalu daftar kegiatan',
      (tester) async {
    final app = await startApp(tester, signIn: true);
    final chip = find.widgetWithText(ChoiceChip, 'Seminar');
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(find.text('1 kegiatan'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'tidak ada kegiatan ini');
    await tester.pumpAndSettle();
    expect(find.text('Kegiatan tidak ditemukan'), findsOneWidget);
    await press(tester, 'Atur Ulang Filter');
    await press(tester, 'Lihat Detail');
    expect(find.text('Detail Kegiatan'), findsOneWidget);
    expect(find.text('Workshop Data Science dan Artificial Intelligence'),
        findsOneWidget);
    await press(tester, 'Daftar Kegiatan');
    await press(tester, 'Batal');
    expect(app.state.registrationFor('data-science'), isNull);
    await press(tester, 'Daftar Kegiatan');
    await press(tester, 'Ya, Daftar');
    expect(find.text('Pendaftaran Berhasil'), findsOneWidget);
    expect(app.backend.registrations['data-science']?['status'], 'registered');
    expect(app.state.registrationFor('data-science'), isNotNull);
    await press(tester, 'Lihat Kegiatan Saya');
    expect(find.text('Workshop Data Science dan Artificial Intelligence'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pendaftaran dapat dibatalkan dari Kegiatan Saya', (tester) async {
    final app = await startApp(tester, signIn: true);
    await tester.runAsync(() => app.store.registerWorkshop('data-science'));
    await tester.pumpAndSettle();
    appRouter.go('/registrations');
    await tester.pumpAndSettle();
    await press(tester, 'Batalkan Pendaftaran');
    await press(tester, 'Ya, Batalkan');
    expect(app.backend.registrations['data-science']?['status'], 'cancelled');
    expect(app.state.registrationFor('data-science'), isNull);
    expect(find.text('Pendaftaran dibatalkan.'), findsOneWidget);
  });

  testWidgets('presensi offline memakai kode panitia dan menolak kode salah',
      (tester) async {
    final app = await startApp(tester, signIn: true);
    appRouter.push('/attendance?workshop=kuliah-umum-ai');
    await tester.pumpAndSettle();
    expect(find.text('Presensi aktif'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'ZZZZZZ');
    await press(tester, 'Kirim Presensi');
    expect(find.text('Kode presensi tidak valid'), findsOneWidget);
    expect(app.state.registrationFor('kuliah-umum-ai')!.attendance,
        AttendanceStatus.pending);
    await press(tester, 'Coba Lagi');
    await tester.enterText(find.byType(TextField).first, 'abc123');
    await press(tester, 'Kirim Presensi');
    expect(find.text('Presensi berhasil'), findsOneWidget);
    expect(app.state.registrationFor('kuliah-umum-ai')!.attendance,
        AttendanceStatus.present);
    expect(tester.takeException(), isNull);
  });

  testWidgets('presensi online per hari mengunggah screenshot ke server',
      (tester) async {
    final bytes = File('assets/images/unand-logo.png').readAsBytesSync();
    var picks = 0;
    final app = await startApp(tester, signIn: true, picker: () async {
      picks++;
      if (picks == 1) return null;
      if (picks == 2) {
        throw const FormatException('Pilih screenshot berformat PNG atau JPG.');
      }
      return ScreenshotEvidence(name: 'pertemuan.png', bytes: bytes);
    });
    appRouter.go('/attendance?workshop=bootcamp-digital');
    await tester.pumpAndSettle();
    expect(find.text('Presensi Harian'), findsOneWidget);
    expect(find.text('Pindai QR'), findsNothing);
    // Hanya hari sesi aktif (2026-06-18) yang dapat diisi
    await tester.scrollUntilVisible(find.text('Unggah Screenshot'), 200,
        scrollable: find.byType(Scrollable).last);
    expect(find.text('Unggah Screenshot'), findsOneWidget);

    appRouter.go('/attendance?workshop=bootcamp-digital&day=2026-06-18');
    await tester.pumpAndSettle();
    expect(find.text('Presensi Online'), findsOneWidget);
    final submit = find.widgetWithText(FilledButton, 'Kirim Presensi');
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    await press(tester, 'Pilih Screenshot');
    expect(find.text('Belum ada screenshot'), findsOneWidget);
    await press(tester, 'Pilih Screenshot');
    expect(find.text('Pilih screenshot berformat PNG atau JPG.'), findsOneWidget);
    await press(tester, 'Pilih Screenshot');
    expect(find.text('pertemuan.png'), findsOneWidget);
    await press(tester, 'Kirim Presensi');
    expect(find.textContaining('Menunggu verifikasi panitia.'), findsOneWidget);
    final registration = app.state.registrationFor('bootcamp-digital')!;
    expect(registration.dailyAttendance['2026-06-18']!.status,
        AttendanceStatus.submitted);
    expect(registration.dailyAttendance['2026-06-17'], isNull);
    expect(find.text('Kirim Presensi'), findsNothing);

    appRouter.go('/attendance?workshop=bootcamp-digital&day=2026-06-19');
    await tester.pumpAndSettle();
    expect(find.text('Presensi hari ini belum dibuka oleh panitia.'),
        findsOneWidget);
    expect(find.text('Pilih Screenshot'), findsNothing);
    appRouter.go('/attendance?workshop=bootcamp-digital&day=1999-01-01');
    await tester.pumpAndSettle();
    expect(find.text('Jadwal tidak ditemukan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sertifikat: unduh PDF resmi dan ajukan perbaikan',
      (tester) async {
    final app = await startApp(tester, signIn: true);
    appRouter.go('/certificates');
    await tester.pumpAndSettle();
    expect(find.text('Workshop Penulisan Karya Ilmiah'), findsOneWidget);
    appRouter.go('/certificates/karya-ilmiah');
    await tester.pumpAndSettle();
    expect(find.text('No. UNAND/SERT/1004/2026'), findsOneWidget);
    await press(tester, 'Unduh Sertifikat PDF');
    expect(app.savedFiles.keys, contains('Sertifikat-UNAND-SERT-1004-2026.pdf'));
    expect(find.text('Sertifikat berhasil diunduh.'), findsOneWidget);

    await press(tester, 'Ajukan Perbaikan Sertifikat');
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Aulia Rahman Putra');
    await tester.enterText(fields.at(2), 'Nama belakang belum tercantum.');
    await press(tester, 'Kirim Pengajuan');
    expect(find.text('Setujui pernyataan kebenaran data sebelum mengirim.'),
        findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await press(tester, 'Kirim Pengajuan');
    expect(app.backend.corrections, hasLength(1));
    expect(app.backend.corrections.first['changes'], [
      {'field': 'recipient', 'newValue': 'Aulia Rahman Putra'}
    ]);
    expect(find.text('Perbaikan Sedang Diperiksa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('verifikasi sertifikat publik', (tester) async {
    await startApp(tester, signIn: true);
    appRouter.go('/certificates/verify');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'SALAH/0000');
    await press(tester, 'Verifikasi');
    expect(find.text('Nomor sertifikat tidak terdaftar'), findsOneWidget);
    await tester.enterText(
        find.byType(TextFormField).first, 'UNAND/SERT/1004/2026');
    await press(tester, 'Verifikasi');
    expect(find.text('Sertifikat Sah'), findsOneWidget);
    expect(find.text('Aulia Rahman'), findsOneWidget);
  });

  testWidgets('notifikasi, edit profil, dan logout tersimpan di server',
      (tester) async {
    final app = await startApp(tester, signIn: true);
    expect(app.state.unread, 1);
    await tester.tap(find.byTooltip('Buka notifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Kursi Anda sudah tercatat.'), findsOneWidget);
    await press(tester, 'Tandai semua dibaca');
    expect(app.state.unread, 0);
    expect(app.backend.notifications.every((n) => n['belumDibaca'] == false),
        isTrue);

    appRouter.go('/profile');
    await tester.pumpAndSettle();
    expect(find.text('2211521007'), findsOneWidget);
    await press(tester, 'Edit Profil');
    await tester.enterText(find.byType(TextFormField).at(0), 'Aulia Putri');
    await press(tester, 'Simpan Perubahan');
    expect(app.backend.user['nama'], 'Aulia Putri');
    expect(app.state.profile!.name, 'Aulia Putri');

    await press(tester, 'Keluar');
    await press(tester, 'Ya, Keluar');
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(app.state.profile, isNull);
    expect(app.backend.requests, contains('POST /auth/logout'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('token ditolak server (401) mengembalikan peserta ke login',
      (tester) async {
    final app = await startApp(tester, signIn: true);
    app.backend.tokenExpired = true;
    await tester.runAsync(app.store.refresh);
    await tester.pumpAndSettle();
    expect(signedIn.value, isFalse);
    expect(app.state.profile, isNull);
    expect(find.text('Selamat Datang'), findsOneWidget);
  });

  testWidgets('rute terlindungi diarahkan ke login saat belum masuk',
      (tester) async {
    await startApp(tester);
    appRouter.go('/registrations');
    await tester.pumpAndSettle();
    expect(find.text('Selamat Datang'), findsOneWidget);
  });

  testWidgets('layar utama muat di perangkat kecil dan teks diperbesar',
      (tester) async {
    await startApp(tester, size: const Size(320, 740), signIn: true);
    for (final route in [
      '/workshops',
      '/registrations',
      '/certificates',
      '/profile',
      '/notifications',
      '/workshops/public-speaking',
      '/workshops/missing',
      '/attendance/status/bootcamp-digital',
    ]) {
      appRouter.go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
    }
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    appRouter.go('/workshops');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('validasi screenshot menolak ukuran, tipe, dan data rusak',
      (tester) async {
    // PNG 1x1 yang valid (aset logo melebihi batas 2 MB, jadi tidak dipakai di sini)
    final imageBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
    await tester.runAsync(() async {
      expect(
          (await readScreenshot(XFile.fromData(imageBytes, path: 'screen.PNG')))
              .bytes,
          orderedEquals(imageBytes));
      await expectLater(
          readScreenshot(XFile.fromData(imageBytes, path: 'document.pdf')),
          throwsFormatException);
      await expectLater(
          readScreenshot(XFile.fromData(Uint8List(maxScreenshotBytes + 1),
              path: 'large.png')),
          throwsFormatException);
      await expectLater(
          readScreenshot(XFile.fromData(Uint8List(0), path: 'empty.jpg')),
          throwsFormatException);
      await expectLater(
          readScreenshot(
              XFile.fromData(Uint8List.fromList([1, 2, 3]), path: 'fake.png')),
          throwsFormatException);
    });
  });
}
