import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_peserta/core/demo/preview_data.dart';
import 'package:workshop_peserta/main.dart';
import 'package:workshop_peserta/routing/app_router.dart';

Future<ProviderContainer> startApp(WidgetTester tester,
    {Size size = const Size(430, 932)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  appRouter.go('/login');
  await tester.pumpWidget(UncontrolledProviderScope(
      container: container, child: const WorkshopPesertaApp()));
  await tester.pumpAndSettle();
  return container;
}

Future<void> press(WidgetTester tester, String label) async {
  final target = find.text(label).first;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  test(
      'preview registration enforces eligibility and does not duplicate tickets',
      () {
    final notifier = PreviewNotifier();
    notifier.signIn(ParticipantProfile.student);
    notifier.register('data-science');
    notifier.register('data-science');
    notifier.register('public-speaking');
    notifier.register('karya-ilmiah');
    expect(
        notifier.state.registrations
            .where((r) => r.workshopId == 'data-science'),
        hasLength(1));
    expect(notifier.state.registrationFor('public-speaking'), isNull);
    expect(notifier.checkIn('data-science'), isFalse);
    expect(notifier.checkIn('kuliah-ai'), isTrue);
    expect(notifier.state.registrationFor('kuliah-ai')!.attendance,
        AttendanceStatus.present);
    notifier.signOut();
    expect(notifier.state.profile, isNull);
    expect(notifier.state.registrationFor('data-science'), isNull);
    notifier.dispose();
  });

  testWidgets('student can browse, filter, search and register from detail',
      (tester) async {
    final container = await startApp(tester);
    await press(tester, 'Masuk sebagai Mahasiswa');
    expect(find.text('Halo, Aulia'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Seminar'));
    await tester.pumpAndSettle();
    expect(find.text('2 kegiatan'), findsOneWidget);
    await tester.enterText(
        find.byType(TextField).first, 'tidak ada kegiatan ini');
    await tester.pumpAndSettle();
    expect(find.text('Kegiatan tidak ditemukan'), findsOneWidget);
    await press(tester, 'Atur Ulang Filter');
    await press(tester, 'Lihat Detail');
    expect(find.text('Detail Kegiatan'), findsOneWidget);
    expect(find.text('Beranda'), findsNothing);
    await press(tester, 'Daftar Kegiatan');
    await press(tester, 'Batal');
    expect(container.read(previewProvider).registrationFor('data-science'),
        isNull);
    await press(tester, 'Daftar Kegiatan');
    await press(tester, 'Ya, Daftar');
    expect(find.text('Pendaftaran Berhasil'), findsOneWidget);
    await press(tester, 'Lihat Kegiatan Saya');
    expect(find.text('Workshop Data Science dan Artificial Intelligence'),
        findsOneWidget);
    expect(container.read(previewProvider).registrationFor('data-science'),
        isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('public login validates input and allows revealing password',
      (tester) async {
    await startApp(tester, size: const Size(320, 740));
    await press(tester, 'Masuk');
    expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
    expect(find.text('Kata sandi minimal 6 karakter.'), findsOneWidget);
    await tester.enterText(
        find.byType(TextFormField).at(0), 'peserta@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'contoh123');
    await tester.tap(find.byTooltip('Tampilkan kata sandi'));
    await tester.pump();
    expect(find.byTooltip('Sembunyikan kata sandi'), findsOneWidget);
    await press(tester, 'Masuk');
    expect(find.text('Halo, Dinda'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile edits and notifications update shared preview state',
      (tester) async {
    final container = await startApp(tester);
    await press(tester, 'Masuk sebagai Mahasiswa');
    await tester.tap(find.byTooltip('Buka notifikasi'));
    await tester.pumpAndSettle();
    await press(tester, 'Tandai semua dibaca');
    expect(container.read(previewProvider).unread, 0);
    appRouter.go('/profile');
    await tester.pumpAndSettle();
    await press(tester, 'Edit Profil');
    await tester.enterText(find.byType(TextFormField).at(0), 'Aulia Putri');
    await press(tester, 'Simpan Perubahan');
    expect(container.read(previewProvider).profile!.name, 'Aulia Putri');
    await press(tester, 'Keluar');
    await press(tester, 'Ya, Keluar');
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(container.read(previewProvider).profile, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'presensi simulation checks in and correction form records request',
      (tester) async {
    final container = await startApp(tester);
    await press(tester, 'Masuk sebagai Mahasiswa');
    appRouter.push('/attendance?workshop=kuliah-ai');
    await tester.pumpAndSettle();
    await press(tester, 'Mulai Pindai');
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.text('Presensi berhasil'), findsOneWidget);
    expect(
        container
            .read(previewProvider)
            .registrationFor('kuliah-ai')!
            .attendance,
        AttendanceStatus.present);
    appRouter.go('/certificates/karya-ilmiah');
    await tester.pumpAndSettle();
    await press(tester, 'Ajukan Perbaikan Sertifikat');
    await tester.enterText(find.byType(TextFormField).at(1),
        'Perbaikan ejaan nama pada sertifikat.');
    await press(tester, 'Kirim Pengajuan');
    expect(
        container.read(previewProvider).corrections, contains('karya-ilmiah'));
    expect(find.text('Perbaikan Sedang Diperiksa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('main screens fit small devices and enlarged text',
      (tester) async {
    await startApp(tester, size: const Size(320, 740));
    for (final route in [
      '/workshops',
      '/registrations',
      '/certificates',
      '/profile',
      '/workshops/public-speaking',
      '/workshops/missing'
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
}
