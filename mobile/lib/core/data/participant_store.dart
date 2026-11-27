import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/attendance/data/attendance_api_service.dart';
import '../../modules/attendance/providers/attendance_provider.dart';
import '../../modules/auth/data/auth_repository.dart';
import '../../modules/auth/providers/auth_provider.dart';
import '../../modules/certificates/data/certificate_api_service.dart';
import '../../modules/certificates/providers/certificate_provider.dart';
import '../../modules/notifications/data/notification_api_service.dart';
import '../../modules/notifications/providers/notification_provider.dart';
import '../../modules/registrations/data/registration_api_service.dart';
import '../../modules/registrations/providers/registration_provider.dart';
import '../../modules/workshops/data/workshop_api_service.dart';
import '../../modules/workshops/providers/workshop_provider.dart';
import '../network/api_exceptions.dart';
import '../network/network_providers.dart';
import 'participant_models.dart';

export 'participant_models.dart';

/// Seluruh data peserta yang sedang login, dimuat dari backend.
class ParticipantState {
  const ParticipantState({
    this.profile,
    this.workshops = const [],
    this.registrations = const {},
    this.notifications = const [],
    this.certificates = const [],
    this.corrections = const [],
    this.loading = false,
    this.loaded = false,
    this.error,
  });

  final ParticipantProfile? profile;
  final List<Workshop> workshops;

  /// Pendaftaran aktif (bukan dibatalkan), kunci = slug kegiatan
  final Map<String, Registration> registrations;
  final List<AppNotification> notifications;
  final List<Certificate> certificates;
  final List<CertificateCorrection> corrections;
  final bool loading, loaded;
  final String? error;

  int get unread => notifications.where((n) => !n.read).length;

  Workshop? workshopById(String id) {
    for (final workshop in workshops) {
      if (workshop.id == id) return workshop;
    }
    return null;
  }

  Registration? registrationFor(String id) => registrations[id];

  Certificate? certificateFor(String workshopId) {
    for (final certificate in certificates) {
      if (certificate.workshopId == workshopId) return certificate;
    }
    return null;
  }

  /// Pengajuan perbaikan terbaru untuk satu sertifikat (aktif diutamakan)
  CertificateCorrection? correctionFor(String certificateCode) {
    final mine = corrections.where((c) => c.certificateId == certificateCode);
    for (final correction in mine) {
      if (correction.isActive) return correction;
    }
    return mine.isEmpty ? null : mine.first;
  }

  ParticipantState copyWith({
    ParticipantProfile? profile,
    List<Workshop>? workshops,
    Map<String, Registration>? registrations,
    List<AppNotification>? notifications,
    List<Certificate>? certificates,
    List<CertificateCorrection>? corrections,
    bool? loading,
    bool? loaded,
    String? error,
    bool clearError = false,
  }) =>
      ParticipantState(
        profile: profile ?? this.profile,
        workshops: workshops ?? this.workshops,
        registrations: registrations ?? this.registrations,
        notifications: notifications ?? this.notifications,
        certificates: certificates ?? this.certificates,
        corrections: corrections ?? this.corrections,
        loading: loading ?? this.loading,
        loaded: loaded ?? this.loaded,
        error: clearError ? null : error ?? this.error,
      );
}

/// Pengelola data peserta: autentikasi, katalog, pendaftaran, presensi,
/// sertifikat, dan notifikasi — semuanya melalui backend REST API.
class ParticipantStore extends StateNotifier<ParticipantState> {
  ParticipantStore(this._ref) : super(const ParticipantState()) {
    signedIn.addListener(_onSignedInChanged);
  }

  final Ref _ref;

  AuthRepository get _auth => _ref.read(authRepositoryProvider);
  WorkshopApiService get _workshops => _ref.read(workshopApiServiceProvider);
  RegistrationApiService get _registrations =>
      _ref.read(registrationApiServiceProvider);
  AttendanceApiService get _attendance =>
      _ref.read(attendanceApiServiceProvider);
  CertificateApiService get _certificates =>
      _ref.read(certificateApiServiceProvider);
  NotificationApiService get _notifications =>
      _ref.read(notificationApiServiceProvider);

  @override
  void dispose() {
    signedIn.removeListener(_onSignedInChanged);
    super.dispose();
  }

  /// Token ditolak server (401) → kosongkan data; router kembali ke login.
  void _onSignedInChanged() {
    if (!signedIn.value && mounted && state.profile != null) {
      state = const ParticipantState();
    }
  }

  void _update(ParticipantState next) {
    if (mounted) state = next;
  }

  /// Hanya terapkan perubahan bila store masih hidup (mis. belum logout/dispose)
  void _patch(ParticipantState Function(ParticipantState current) change) {
    if (mounted) state = change(state);
  }

  void _startSession(ParticipantProfile profile) {
    _update(ParticipantState(profile: profile));
    signedIn.value = true;
  }

  // ───────────────────────── Autentikasi ─────────────────────────

  /// Memulihkan sesi tersimpan. `true` bila peserta masih login.
  Future<bool> restoreSession() async {
    final profile = await _auth.restoreSession();
    if (profile == null) return false;
    _startSession(profile);
    await refresh();
    return true;
  }

  Future<void> signIn(String email, String password) async {
    final profile = await _auth.login(email, password);
    _startSession(profile);
    await refresh();
  }

  Future<void> registerAccount({
    required String nama,
    required String email,
    required String password,
    String? telepon,
    bool mahasiswa = false,
    String? nim,
  }) async {
    final profile = await _auth.register(
        nama: nama,
        email: email,
        password: password,
        telepon: telepon,
        mahasiswa: mahasiswa,
        nim: nim);
    _startSession(profile);
    await refresh();
  }

  Future<void> signOut() async {
    await _auth.logout();
    _update(const ParticipantState());
    signedIn.value = false;
  }

  Future<void> updateProfile(
      {required String nama, required String telepon}) async {
    final profile = await _auth.updateProfile(nama: nama, telepon: telepon);
    _patch((s) => s.copyWith(profile: profile));
  }

  // ───────────────────────── Data ─────────────────────────

  /// Memuat ulang seluruh data peserta dari server.
  Future<void> refresh() async {
    if (!mounted || state.profile == null) return;
    _patch((s) => s.copyWith(loading: true, clearError: true));
    try {
      final results = await Future.wait<Object>([
        _workshops.getWorkshops(),
        _notifications.getNotifications(),
        _certificates.getMyCertificates(),
        _certificates.getMyCorrections(),
      ]);
      if (!mounted || state.profile == null) return;
      final items = results[0] as List<WorkshopWithRegistration>;
      _patch((s) => s.copyWith(
        workshops: [for (final item in items) item.workshop],
        registrations: {
          for (final item in items)
            if (item.registration?.isActive ?? false)
              item.workshop.id: item.registration!,
        },
        notifications: results[1] as List<AppNotification>,
        certificates: results[2] as List<Certificate>,
        corrections: results[3] as List<CertificateCorrection>,
        loading: false,
        loaded: true,
      ));
    } on ApiException catch (e) {
      _patch((s) => s.copyWith(loading: false, loaded: true, error: e.message));
    }
  }

  /// Menerapkan detail satu kegiatan terbaru dari respons server.
  void _apply(WorkshopWithRegistration item) {
    if (!mounted) return;
    final workshops = [...state.workshops];
    final index = workshops.indexWhere((w) => w.id == item.workshop.id);
    if (index >= 0) {
      workshops[index] = item.workshop;
    } else {
      workshops.add(item.workshop);
    }
    final registrations = {...state.registrations};
    final registration = item.registration;
    if (registration != null && registration.isActive) {
      registrations[item.workshop.id] = registration;
    } else {
      registrations.remove(item.workshop.id);
    }
    _update(state.copyWith(
        workshops: workshops, registrations: Map.unmodifiable(registrations)));
  }

  Future<void> _reloadNotifications() async {
    try {
      final notifications = await _notifications.getNotifications();
      _patch((s) => s.copyWith(notifications: notifications));
    } on ApiException {
      // notifikasi bersifat pelengkap; abaikan kegagalan sementara
    }
  }

  // ───────────────────────── Pendaftaran ─────────────────────────

  /// Mendaftar kegiatan. Mengembalikan pendaftaran (status terdaftar atau
  /// waiting list sesuai kuota yang dihitung server).
  Future<Registration?> registerWorkshop(String workshopId) async {
    final result = await _registrations.registerToWorkshop(workshopId);
    _apply(result);
    unawaited(_reloadNotifications());
    return result.registration;
  }

  Future<void> cancelRegistration(String workshopId) async {
    final registration = state.registrationFor(workshopId);
    if (registration == null) {
      throw const ApiException(message: 'Pendaftaran tidak ditemukan.');
    }
    _apply(await _registrations.cancelRegistration(registration.id));
  }

  // ───────────────────────── Presensi ─────────────────────────

  /// Presensi offline (kode QR + lokasi). Error membawa `state` dari server.
  Future<void> checkIn(String workshopId,
      {String? code, DevicePosition? position}) async {
    _apply(await _attendance.checkIn(
      workshopId: workshopId,
      code: code,
      latitude: position?.latitude,
      longitude: position?.longitude,
    ));
  }

  /// Presensi online (unggah screenshot).
  Future<void> uploadEvidence(
      String workshopId, ScreenshotEvidence evidence) async {
    _apply(await _attendance.uploadEvidence(
        workshopId: workshopId, evidence: evidence));
  }

  // ───────────────────────── Notifikasi ─────────────────────────

  /// Tandai satu ([id]) atau semua notifikasi dibaca.
  Future<void> markRead(int? id) async {
    final previous = state.notifications;
    _update(state.copyWith(
        notifications: previous
            .map((n) => id == null || n.id == id ? n.markRead() : n)
            .toList()));
    try {
      await _notifications.markRead(id: id);
    } on ApiException {
      _patch((s) => s.copyWith(notifications: previous));
    }
  }

  // ───────────────────────── Sertifikat ─────────────────────────

  /// Mengunduh PDF resmi lalu membukanya. Mengembalikan lokasi berkas.
  Future<String> downloadCertificate(Certificate certificate) async {
    final bytes = await _certificates.downloadCertificatePdf(certificate.code);
    final safe = certificate.number.replaceAll(RegExp(r'[^\w.-]+'), '-');
    return _ref.read(certificateFileSaverProvider)('Sertifikat-$safe.pdf', bytes);
  }

  Future<CertificateCorrection> requestCorrection(
    Certificate certificate, {
    required Map<String, String> changes,
    required String reason,
  }) async {
    final correction = await _certificates.requestCorrection(
        certificateCode: certificate.code, changes: changes, reason: reason);
    _patch((s) => s.copyWith(corrections: [correction, ...s.corrections]));
    return correction;
  }

  Future<CertificateVerification> verifyCertificate(String number) =>
      _certificates.verifyCertificate(number);
}

final participantStoreProvider =
    StateNotifierProvider<ParticipantStore, ParticipantState>(
        (ref) => ParticipantStore(ref));
