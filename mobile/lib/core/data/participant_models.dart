import 'dart:typed_data';

import '../config/env.dart';
import '../network/api_call.dart';
import '../utils/id_date.dart';

/// Model data peserta yang dipetakan dari respons backend
/// (lihat `workshops.serializer.js`, `auth.service.js`,
/// `certificates.serializer.js` pada backend).

enum WorkshopPhase { upcoming, ongoing, finished }

enum WorkshopStatus { open, waitlist, full, notOpen, closed }

enum AttendanceStatus {
  pending('Belum Presensi'),
  submitted('Menunggu Verifikasi'),
  present('Hadir'),
  rejected('Bukti Ditolak'),
  absent('Tidak Hadir');

  const AttendanceStatus(this.label);
  final String label;

  /// Status presensi dari backend: pending | present | rejected | absent
  static AttendanceStatus fromApi(String? value) => switch (value) {
        'pending' => AttendanceStatus.submitted,
        'present' => AttendanceStatus.present,
        'rejected' => AttendanceStatus.rejected,
        'absent' => AttendanceStatus.absent,
        _ => AttendanceStatus.pending,
      };

  /// Peserta masih boleh mengirim presensi (belum ada / bukti ditolak)
  bool get canSubmit =>
      this == AttendanceStatus.pending || this == AttendanceStatus.rejected;
}

enum AttendanceWindow { notOpen, open, closed }

class WorkshopDay {
  const WorkshopDay(
      {required this.id,
      required this.date,
      required this.time,
      this.window = AttendanceWindow.notOpen});

  /// Tanggal ISO `YYYY-MM-DD` (sama dengan `tanggal` presensi di backend)
  final String id;
  final String date, time;
  final AttendanceWindow window;
}

class ScreenshotEvidence {
  ScreenshotEvidence({required this.name, required Uint8List bytes})
      : bytes = bytes.asUnmodifiableView();
  final String name;
  final Uint8List bytes;

  String get mimeType =>
      name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
}

class DayAttendance {
  const DayAttendance(this.status,
      {this.evidenceName, this.evidenceUrl, this.reason});
  final AttendanceStatus status;
  final String? evidenceName, evidenceUrl, reason;

  factory DayAttendance.fromJson(Map<String, dynamic> json) => DayAttendance(
        AttendanceStatus.fromApi(jsonStringOrNull(json['status'])),
        evidenceName: jsonStringOrNull(json['fileName']),
        evidenceUrl: Env.resolveMediaUrl(jsonStringOrNull(json['fileUrl'])),
        reason: jsonStringOrNull(json['reason']),
      );
}

enum WorkshopDelivery {
  online('Online'),
  offline('Offline');

  const WorkshopDelivery(this.label);
  final String label;
}

class Workshop {
  const Workshop(
      {required this.id,
      this.dbId,
      required this.kind,
      required this.delivery,
      required this.title,
      required this.theme,
      required this.description,
      required this.speaker,
      required this.organizer,
      required this.date,
      required this.shortDate,
      required this.time,
      required this.location,
      required this.room,
      required this.target,
      required this.benefits,
      required this.registrationPeriod,
      required this.image,
      this.capacity,
      this.remaining,
      this.status = WorkshopStatus.open,
      this.phase = WorkshopPhase.upcoming,
      this.cancelled = false,
      this.meetingUrl,
      this.latitude,
      this.longitude,
      required this.days});

  /// Slug kegiatan — dipakai sebagai id di aplikasi dan diterima backend
  /// pada seluruh endpoint (`:id` boleh berupa id angka atau slug).
  final String id;
  final int? dbId;
  final String kind,
      title,
      theme,
      description,
      speaker,
      organizer,
      date,
      shortDate,
      time,
      location,
      room,
      target,
      registrationPeriod,
      image;
  final List<String> benefits;
  final int? capacity, remaining;
  final WorkshopStatus status;
  final WorkshopPhase phase;
  final WorkshopDelivery delivery;
  final bool cancelled;
  final String? meetingUrl;
  final double? latitude, longitude;
  final List<WorkshopDay> days;

  bool get attendanceOpen =>
      days.any((day) => day.window == AttendanceWindow.open);
  bool get canRegister =>
      status == WorkshopStatus.open || status == WorkshopStatus.waitlist;
  bool get hasGeofence => latitude != null && longitude != null;

  String get registrationLabel => switch (status) {
        WorkshopStatus.open => 'Pendaftaran Terbuka',
        WorkshopStatus.waitlist => 'Kuota Penuh · Waiting List',
        WorkshopStatus.full => 'Kuota Penuh',
        WorkshopStatus.notOpen => 'Pendaftaran Belum Dibuka',
        WorkshopStatus.closed =>
          cancelled ? 'Kegiatan Dibatalkan' : 'Pendaftaran Ditutup',
      };

  static const onlineLinkNotice =
      'Tautan kegiatan akan dibagikan H-1 melalui Kegiatan Saya.';

  factory Workshop.fromJson(Map<String, dynamic> json) {
    final start = IdDate.parse(jsonStringOrNull(json['tanggalMulai'])) ??
        DateTime.now();
    var end = IdDate.parse(jsonStringOrNull(json['tanggalSelesai'])) ?? start;
    if (end.isBefore(start)) end = start;

    final apiStatus = jsonString(json['status']);
    final cancelled = apiStatus == 'dibatalkan' || json['cancelled'] == true;
    final completed = apiStatus == 'selesai' || json['completed'] == true;
    final registrationState = jsonString(json['registrationState'], 'open');
    final capacity = jsonInt(json['kuota']);
    final remaining = capacity == null ? null : jsonInt(json['remaining']);

    final WorkshopStatus status;
    if (cancelled || completed || registrationState == 'closed') {
      status = WorkshopStatus.closed;
    } else if (registrationState == 'not-open') {
      status = WorkshopStatus.notOpen;
    } else if (capacity != null && (remaining ?? 0) <= 0) {
      status = json['waitingListEnabled'] == true
          ? WorkshopStatus.waitlist
          : WorkshopStatus.full;
    } else {
      status = WorkshopStatus.open;
    }

    final phase = cancelled || completed
        ? WorkshopPhase.finished
        : apiStatus == 'berlangsung'
            ? WorkshopPhase.ongoing
            : WorkshopPhase.upcoming;

    final startTime = jsonStringOrNull(json['waktuMulai']);
    final endTime = jsonStringOrNull(json['waktuSelesai']);
    final time = startTime != null
        ? '${startTime.replaceAll(':', '.')}–${(endTime ?? '').replaceAll(':', '.')} WIB'
        : jsonString(json['time'], '-');

    // Jendela presensi per hari: backend hanya menerima presensi untuk
    // `attendanceDate` (hari ini bila dalam rentang kegiatan) saat sesi dibuka.
    final attendanceState = jsonString(json['attendanceState'], 'not-open');
    final attendanceDate =
        jsonStringOrNull(json['attendanceDate']) ?? IdDate.iso(start);
    AttendanceWindow windowFor(String iso) {
      if (cancelled) return AttendanceWindow.closed;
      if (attendanceState == 'closed') return AttendanceWindow.closed;
      if (attendanceState != 'open') return AttendanceWindow.notOpen;
      final compare = iso.compareTo(attendanceDate);
      if (compare == 0) return AttendanceWindow.open;
      return compare < 0 ? AttendanceWindow.closed : AttendanceWindow.notOpen;
    }

    final days = IdDate.daysBetween(start, end).map((d) {
      final iso = IdDate.iso(d);
      return WorkshopDay(
          id: iso, date: IdDate.long(d), time: time, window: windowFor(iso));
    }).toList();

    final online = jsonString(json['mode']) == 'online';
    final building = jsonString(json['gedung']);
    final description = jsonString(json['deskripsi']).isNotEmpty
        ? jsonString(json['deskripsi'])
        : jsonString(json['description']);

    return Workshop(
      id: jsonString(json['slug']).isNotEmpty
          ? jsonString(json['slug'])
          : jsonString(json['id']),
      dbId: jsonInt(json['id']),
      kind: jsonString(json['jenis'], 'Kegiatan'),
      delivery: online ? WorkshopDelivery.online : WorkshopDelivery.offline,
      title: jsonString(json['nama'], jsonString(json['title'])),
      theme: jsonString(json['tema']),
      description: description,
      speaker: jsonString(json['pemateri']).isNotEmpty
          ? jsonString(json['pemateri'])
          : '-',
      organizer: jsonString(json['penyelenggara'], 'Universitas Andalas'),
      date: days.length > 1
          ? '${IdDate.long(start)} – ${IdDate.long(end)}'
          : IdDate.long(start),
      shortDate: IdDate.shortRange(start, end),
      time: time,
      location: online
          ? 'Online'
          : building.isNotEmpty
              ? building
              : jsonString(json['place'], '-'),
      room: online ? '' : jsonString(json['ruangan']),
      target: jsonString(json['targetPeserta']).isNotEmpty
          ? jsonString(json['targetPeserta'])
          : 'Umum',
      benefits: jsonString(json['manfaat'])
          .split(RegExp(r'[\n;]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      registrationPeriod: jsonString(json['periodePendaftaran'], '-'),
      image: Env.resolveMediaUrl(jsonStringOrNull(json['image'])) ?? '',
      capacity: capacity,
      remaining: remaining,
      status: status,
      phase: phase,
      cancelled: cancelled,
      meetingUrl: jsonStringOrNull(json['meetingUrl']),
      latitude: jsonDouble(json['latitude']),
      longitude: jsonDouble(json['longitude']),
      days: days,
    );
  }
}

enum RegistrationStatus { registered, waiting, cancelled, completed }

/// Pendaftaran peserta pada satu kegiatan (`myRegistration` dari backend)
class Registration {
  const Registration(
      {required this.workshop,
      required this.id,
      this.status = RegistrationStatus.registered,
      this.queue,
      this.dailyAttendance = const {}});

  final Workshop workshop;
  final int id;
  final RegistrationStatus status;
  final int? queue;

  /// Presensi per hari, kunci = tanggal ISO (= [WorkshopDay.id])
  final Map<String, DayAttendance> dailyAttendance;

  String get workshopId => workshop.id;
  bool get isActive => status != RegistrationStatus.cancelled;
  bool get isWaiting => status == RegistrationStatus.waiting;

  factory Registration.fromJson(Map<String, dynamic> json, Workshop workshop) {
    final daily = <String, DayAttendance>{};
    for (final item in jsonList(json['attendanceDays'])) {
      final map = jsonMap(item);
      final date = jsonStringOrNull(map['date']);
      if (date != null) daily[date] = DayAttendance.fromJson(map);
    }
    return Registration(
      workshop: workshop,
      id: jsonInt(json['registrationId']) ?? 0,
      status: switch (jsonString(json['status'])) {
        'waiting' => RegistrationStatus.waiting,
        'cancelled' => RegistrationStatus.cancelled,
        'completed' => RegistrationStatus.completed,
        _ => RegistrationStatus.registered,
      },
      queue: jsonInt(json['queue']),
      dailyAttendance: Map.unmodifiable(daily),
    );
  }

  String get statusLabel => switch (status) {
        RegistrationStatus.registered ||
        RegistrationStatus.completed =>
          'Terdaftar',
        RegistrationStatus.waiting =>
          queue != null ? 'Waiting List #$queue' : 'Waiting List',
        RegistrationStatus.cancelled => 'Dibatalkan',
      };

  DayAttendance attendanceFor(WorkshopDay day) =>
      dailyAttendance[day.id] ??
      DayAttendance(day.window == AttendanceWindow.closed
          ? AttendanceStatus.absent
          : AttendanceStatus.pending);

  AttendanceStatus get attendance {
    final statuses =
        workshop.days.map((day) => attendanceFor(day).status).toList();
    if (statuses.every((s) => s == AttendanceStatus.present)) {
      return AttendanceStatus.present;
    }
    if (statuses.contains(AttendanceStatus.rejected)) {
      return AttendanceStatus.rejected;
    }
    if (statuses.contains(AttendanceStatus.pending)) {
      return AttendanceStatus.pending;
    }
    if (statuses.contains(AttendanceStatus.submitted)) {
      return AttendanceStatus.submitted;
    }
    if (statuses.contains(AttendanceStatus.present)) {
      return AttendanceStatus.present;
    }
    return AttendanceStatus.absent;
  }

  int get recordedDays => dailyAttendance.values
      .where((a) =>
          a.status == AttendanceStatus.present ||
          a.status == AttendanceStatus.submitted)
      .length;

  String get attendanceLabel {
    if (isWaiting) return 'Menunggu Kursi';
    final days = workshop.days;
    return days.length > 1
        ? '$recordedDays/${days.length} hari tercatat'
        : attendance.label;
  }

  /// Peserta terdaftar (bukan waiting list) dan ada hari yang sedang dibuka
  /// yang belum memiliki presensi sah/menunggu.
  bool get canCheckIn =>
      status == RegistrationStatus.registered &&
      workshop.days.any((day) =>
          day.window == AttendanceWindow.open &&
          attendanceFor(day).status.canSubmit);

  bool get canCancel =>
      (status == RegistrationStatus.registered ||
          status == RegistrationStatus.waiting) &&
      workshop.phase == WorkshopPhase.upcoming;
}

class ParticipantProfile {
  const ParticipantProfile(
      {this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.type,
      this.role = 'peserta',
      this.nim});
  final int? id;
  final String name, email, phone, type, role;
  final String? nim;

  bool get isStudent => type == 'Mahasiswa UNAND';

  factory ParticipantProfile.fromJson(Map<String, dynamic> json) {
    final jenis = jsonString(json['jenis']);
    return ParticipantProfile(
      id: jsonInt(json['id']),
      name: jsonString(json['nama'], 'Peserta'),
      email: jsonString(json['email']),
      phone: jsonString(json['telepon']).isNotEmpty
          ? jsonString(json['telepon'])
          : '-',
      type: switch (jenis) {
        'Mahasiswa' || 'Mahasiswa UNAND' => 'Mahasiswa UNAND',
        '' || 'Umum' => 'Peserta Umum',
        _ => jenis,
      },
      role: jsonString(json['role'], 'peserta'),
      nim: jsonStringOrNull(json['nim']),
    );
  }
}

class AppNotification {
  const AppNotification(
      {required this.id,
      required this.title,
      required this.message,
      required this.time,
      this.link,
      this.read = false});
  final int id;
  final String title, message, time;
  final String? link;
  final bool read;

  bool get certificate =>
      (link ?? '').contains('sertifikat') ||
      title.toLowerCase().contains('sertifikat');

  /// Rute aplikasi mobile untuk tautan notifikasi (tautan backend berbentuk
  /// rute portal web, mis. `/peserta/workshop-saya`).
  String get route {
    final value = link ?? '';
    if (value.contains('sertifikat')) return '/certificates';
    if (value.contains('workshop-saya')) return '/registrations';
    return '/workshops';
  }

  AppNotification markRead() => AppNotification(
      id: id, title: title, message: message, time: time, link: link, read: true);

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['judul']),
        message: jsonString(json['deskripsi']),
        time: jsonString(json['waktu']).replaceAll(' · belum dibaca', ''),
        link: jsonStringOrNull(json['link']),
        read: json['belumDibaca'] != true,
      );
}

class Certificate {
  const Certificate(
      {required this.code,
      required this.workshopId,
      required this.number,
      required this.issued,
      required this.recipient,
      required this.issuer,
      required this.kind,
      this.degree = ''});

  /// Kode sertifikat (dipakai untuk unduh PDF & pengajuan perbaikan)
  final String code;
  final String workshopId, number, issued, recipient, issuer, kind, degree;

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
        code: jsonString(json['id']),
        workshopId: jsonString(json['workshopId']),
        number: jsonString(json['number']),
        issued: jsonString(json['issued']),
        recipient: jsonString(json['recipient']),
        issuer: jsonString(json['issuer']),
        kind: jsonString(json['kind']),
        degree: jsonString(json['degree']),
      );
}

class CertificateCorrection {
  const CertificateCorrection(
      {required this.id,
      required this.certificateId,
      required this.status,
      this.issuerNote,
      this.replacementNumber});
  final String id, certificateId, status;
  final String? issuerNote, replacementNumber;

  bool get isActive => status == 'menunggu' || status == 'diproses';

  String get statusLabel => switch (status) {
        'menunggu' => 'Menunggu Pemeriksaan',
        'diproses' => 'Sedang Diproses',
        'selesai' => 'Perbaikan Selesai',
        'ditolak' => 'Perbaikan Ditolak',
        'dibatalkan' => 'Dibatalkan',
        _ => status,
      };

  factory CertificateCorrection.fromJson(Map<String, dynamic> json) =>
      CertificateCorrection(
        id: jsonString(json['id']),
        certificateId: jsonString(json['certificateId']),
        status: jsonString(json['status']),
        issuerNote: jsonStringOrNull(json['issuerNote']),
        replacementNumber: jsonStringOrNull(json['replacementNumber']),
      );
}

class CertificateVerification {
  const CertificateVerification(
      {required this.number,
      required this.recipient,
      required this.activity,
      required this.activityDate,
      required this.issuer,
      required this.authenticityCode,
      this.signers = const []});
  final String number, recipient, activity, activityDate, issuer;
  final String authenticityCode;
  final List<String> signers;

  factory CertificateVerification.fromJson(Map<String, dynamic> json) =>
      CertificateVerification(
        number: jsonString(json['number']),
        recipient: jsonString(json['recipient']),
        activity: jsonString(json['namaKegiatan']),
        activityDate: jsonString(json['tanggalKegiatan']),
        issuer: jsonString(json['issuer']),
        authenticityCode: jsonString(json['kodeKeaslian']),
        signers: jsonList(json['penandatangan'])
            .map(jsonMap)
            .map((s) => '${jsonString(s['nama'])} — ${jsonString(s['peran'])}')
            .toList(),
      );
}
