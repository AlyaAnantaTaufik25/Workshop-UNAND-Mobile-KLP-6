import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_peserta/core/data/participant_store.dart';
import 'package:workshop_peserta/core/network/dio_client.dart';
import 'package:workshop_peserta/core/network/network_providers.dart';
import 'package:workshop_peserta/main.dart';
import 'package:workshop_peserta/modules/attendance/providers/attendance_provider.dart';
import 'package:workshop_peserta/modules/attendance/providers/screenshot_provider.dart';
import 'package:workshop_peserta/modules/certificates/providers/certificate_provider.dart';
import 'package:workshop_peserta/routing/app_router.dart';

import 'fake_backend.dart';

/// Aplikasi lengkap yang terhubung ke [FakeBackend] melalui Dio.
class TestApp {
  TestApp(this.container, this.backend, this.savedFiles);
  final ProviderContainer container;
  final FakeBackend backend;
  final Map<String, Uint8List> savedFiles;

  ParticipantState get state => container.read(participantStoreProvider);
  ParticipantStore get store => container.read(participantStoreProvider.notifier);
}

Future<TestApp> startApp(WidgetTester tester,
    {Size size = const Size(430, 932),
    bool signIn = false,
    Future<ScreenshotEvidence?> Function()? picker}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  FlutterSecureStorage.setMockInitialValues({});
  signedIn.value = false;
  final backend = FakeBackend();
  final saved = <String, Uint8List>{};
  final container = ProviderContainer(overrides: [
    dioClientProvider.overrideWith((ref) => DioClient(
          sessionStorage: ref.watch(sessionStorageProvider),
          customDio: Dio()..httpClientAdapter = backend,
          onSessionExpired: () => signedIn.value = false,
        )),
    devicePositionProvider
        .overrideWithValue(() async => const DevicePosition(-0.9145, 100.4602)),
    certificateFileSaverProvider.overrideWithValue((name, bytes) async {
      saved[name] = bytes;
      return '/dokumen/$name';
    }),
    if (picker != null) screenshotPickerProvider.overrideWithValue(picker),
  ]);
  addTearDown(container.dispose);
  appRouter.go('/login');
  await tester.pumpWidget(UncontrolledProviderScope(
      container: container, child: const WorkshopPesertaApp()));
  await tester.pumpAndSettle();
  final app = TestApp(container, backend, saved);
  if (signIn) {
    await tester.enterText(
        find.byType(TextFormField).at(0), 'peserta@unand.ac.id');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await press(tester, 'Masuk');
    expect(app.state.profile, isNotNull, reason: 'login harus berhasil');
  }
  return app;
}

Future<void> press(WidgetTester tester, String label) async {
  final target = find.text(label).first;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}
