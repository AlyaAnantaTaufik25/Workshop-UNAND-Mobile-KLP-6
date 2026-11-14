import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_peserta/core/demo/preview_data.dart';
import 'package:workshop_peserta/main.dart';
import 'package:workshop_peserta/modules/attendance/providers/screenshot_provider.dart';
import 'package:workshop_peserta/routing/app_router.dart';

Future<ProviderContainer> startPreview(WidgetTester tester,
    {Future<ScreenshotEvidence?> Function()? picker}) async {
  tester.view.physicalSize = const Size(320, 740);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(overrides: [
    if (picker != null) screenshotPickerProvider.overrideWithValue(picker),
  ]);
  addTearDown(container.dispose);
  container.read(previewProvider.notifier).signIn(ParticipantProfile.student);
  appRouter.go('/login');
  await tester.pumpWidget(UncontrolledProviderScope(
      container: container, child: const WorkshopPesertaApp()));
  await tester.pumpAndSettle();
  return container;
}

Future<void> tapLabel(WidgetTester tester, String text) async {
  final finder = find.text(text).first;
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  final imageBytes = File('assets/images/unand-logo.png').readAsBytesSync();
  final evidence = ScreenshotEvidence(name: 'pertemuan.png', bytes: imageBytes);

  test('online evidence is independent per day and cannot bypass session rules',
      () {
    final notifier = PreviewNotifier();
    addTearDown(notifier.dispose);
    const id = 'digital-bootcamp';
    expect(notifier.checkIn(id), isFalse);
    expect(notifier.checkIn(id, dayId: 'day-1'), isFalse);
    expect(notifier.checkIn(id, dayId: 'missing', evidence: evidence), isFalse);
    expect(notifier.checkIn(id, dayId: 'day-3', evidence: evidence), isFalse);
    expect(notifier.checkIn('seminar-ti', dayId: 'day-1', evidence: evidence),
        isFalse);
    expect(notifier.checkIn(id, dayId: 'day-1', evidence: evidence), isTrue);
    var registration = notifier.state.registrationFor(id)!;
    expect(registration.dailyAttendance['day-1']!.status,
        AttendanceStatus.submitted);
    expect(registration.dailyAttendance['day-2'], isNull);
    expect(registration.attendance, AttendanceStatus.pending);
    expect(registration.canCheckIn, isTrue);
    expect(notifier.checkIn(id, dayId: 'day-1', evidence: evidence), isFalse);
    expect(notifier.checkIn(id, dayId: 'day-2', evidence: evidence), isTrue);
    registration = notifier.state.registrationFor(id)!;
    expect(registration.recordedDays, 2);
    expect(registration.dailyAttendance['day-1']!.evidence, same(evidence));
    expect(registration.dailyAttendance['day-2']!.status,
        AttendanceStatus.submitted);
    expect(registration.dailyAttendance['day-3'], isNull);
    expect(registration.canCheckIn, isFalse);
  });

  testWidgets('screenshot validation rejects size, type and corrupt image data',
      (tester) async {
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
      await expectLater(
          readScreenshot(XFile.fromData(
              Uint8List.fromList(
                  [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
              path: 'broken.png')),
          throwsFormatException);
    });
  });

  testWidgets('online detail explains H-1 and omits venue, offline keeps venue',
      (tester) async {
    await startPreview(tester);
    appRouter.go('/workshops/seminar-ti');
    await tester.pumpAndSettle();
    expect(find.text(Workshop.onlineLinkNotice), findsOneWidget);
    expect(find.text('Lokasi'), findsNothing);
    expect(find.text('Zoom Meeting'), findsNothing);
    expect(find.text('Ruang seminar virtual'), findsNothing);
    appRouter.go('/workshops/data-science');
    await tester.pumpAndSettle();
    expect(find.text('Gedung Convention Hall'), findsWidgets);
    expect(find.text('Hari ke-1'), findsOneWidget);
    expect(find.text('Hari ke-2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'online form handles cancellation, error and a separate daily submission',
      (tester) async {
    var picks = 0;
    final container = await startPreview(tester, picker: () async {
      picks++;
      if (picks == 1) return null;
      if (picks == 2) {
        throw const FormatException('Pilih screenshot berformat PNG atau JPG.');
      }
      return evidence;
    });
    appRouter.go('/attendance?workshop=digital-bootcamp&day=day-2');
    await tester.pumpAndSettle();
    expect(find.text('Presensi Online'), findsOneWidget);
    expect(find.text('Mulai Pindai'), findsNothing);
    expect(find.text('Lokasi'), findsNothing);
    final submitButton = find.widgetWithText(FilledButton, 'Kirim Presensi');
    expect(tester.widget<FilledButton>(submitButton).onPressed, isNull);
    await tapLabel(tester, 'Pilih Screenshot');
    expect(find.text('Belum ada screenshot'), findsOneWidget);
    await tapLabel(tester, 'Pilih Screenshot');
    expect(
        find.text('Pilih screenshot berformat PNG atau JPG.'), findsOneWidget);
    await tapLabel(tester, 'Pilih Screenshot');
    expect(find.text('pertemuan.png'), findsOneWidget);
    await tapLabel(tester, 'Kirim Presensi');
    final registration =
        container.read(previewProvider).registrationFor('digital-bootcamp')!;
    expect(registration.dailyAttendance['day-2']!.status,
        AttendanceStatus.submitted);
    expect(registration.dailyAttendance['day-1'], isNull);
    expect(registration.dailyAttendance['day-3'], isNull);
    expect(find.textContaining('Menunggu verifikasi panitia.'), findsOneWidget);
    expect(find.text('Kirim Presensi'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'daily list has no online QR and unopened days cannot accept evidence',
      (tester) async {
    await startPreview(tester);
    appRouter.go('/attendance?workshop=digital-bootcamp');
    await tester.pumpAndSettle();
    expect(find.text('Presensi Harian'), findsOneWidget);
    expect(find.text('Pindai QR'), findsNothing);
    expect(find.text('Mulai Pindai'), findsNothing);
    appRouter.go('/attendance?workshop=digital-bootcamp&day=day-3');
    await tester.pumpAndSettle();
    expect(find.text('Presensi hari ini belum dibuka oleh panitia.'),
        findsOneWidget);
    expect(find.text('Pilih Screenshot'), findsNothing);
    appRouter.go('/attendance?workshop=digital-bootcamp&day=missing');
    await tester.pumpAndSettle();
    expect(find.text('Jadwal tidak ditemukan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
