import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WorkshopPhase { upcoming, ongoing, finished }

enum WorkshopStatus { open, full, closed }

enum AttendanceStatus { pending, present, absent }

enum WorkshopDelivery {
  online('Online'),
  offline('Offline');

  const WorkshopDelivery(this.label);
  final String label;
}

class Workshop {
  const Workshop(
      {required this.id,
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
      this.attendanceOpen = false});
  final String id,
      kind,
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
  final bool attendanceOpen;
}

const previewWorkshops = [
  Workshop(
      id: 'data-science',
      kind: 'Workshop',
      delivery: WorkshopDelivery.offline,
      title: 'Workshop Data Science dan Artificial Intelligence',
      theme: 'Membangun Solusi Berbasis Data untuk Masa Depan',
      description:
          'Pelatihan intensif untuk mengenal alur kerja data science, pemanfaatan kecerdasan artifisial, dan penerapannya dalam berbagai bidang.',
      speaker: 'Dr. Rina Kurniawati, M.Kom.',
      organizer: 'UPT Teknologi Informasi UNAND',
      date: 'Sabtu, 28 Juni 2025',
      shortDate: '28 Jun 2025',
      time: '08.30–15.30 WIB',
      location: 'Gedung Convention Hall',
      room: 'Ruang Seminar Lantai 2',
      target: 'Mahasiswa UNAND dan peserta umum',
      benefits: [
        'Sertifikat elektronik',
        'Praktik langsung',
        'Jejaring profesional'
      ],
      registrationPeriod: '10–25 Juni 2025',
      capacity: 120,
      remaining: 34,
      image: 'assets/images/data-science.jpg'),
  Workshop(
      id: 'seminar-ti',
      kind: 'Seminar',
      delivery: WorkshopDelivery.online,
      title: 'Seminar Nasional Teknologi Informasi 2025',
      theme: 'Transformasi Digital yang Inklusif dan Berkelanjutan',
      description:
          'Seminar nasional yang mempertemukan akademisi dan praktisi untuk membahas perkembangan transformasi digital di Indonesia.',
      speaker: 'Prof. Dr. Budi Rahman dan panel praktisi',
      organizer: 'Fakultas Teknologi Informasi UNAND',
      date: 'Kamis, 3 Juli 2025',
      shortDate: '3 Jul 2025',
      time: '09.00–12.30 WIB',
      location: 'Zoom Meeting',
      room: 'Ruang seminar virtual',
      target: 'Mahasiswa, dosen, dan peserta umum',
      benefits: ['Sertifikat elektronik', 'Sesi diskusi', 'Wawasan industri'],
      registrationPeriod: '12 Juni–1 Juli 2025',
      image: 'assets/images/seminar.jpg'),
  Workshop(
      id: 'kuliah-ai',
      kind: 'Kuliah Umum',
      delivery: WorkshopDelivery.offline,
      title: 'Kuliah Umum Artificial Intelligence untuk Masa Depan',
      theme: 'AI yang Bertanggung Jawab untuk Indonesia',
      description:
          'Kuliah umum tentang peluang, tantangan, dan prinsip etis penggunaan artificial intelligence bagi generasi muda.',
      speaker: 'Dr. Andi Pratama, Head of AI Research',
      organizer: 'Universitas Andalas',
      date: 'Hari ini, 18 Juni 2025',
      shortDate: '18 Jun 2025',
      time: '10.00–12.00 WIB',
      location: 'Gedung Convention Hall',
      room: 'Auditorium Utama',
      target: 'Seluruh mahasiswa UNAND',
      benefits: ['Sertifikat elektronik', 'Sesi tanya jawab'],
      registrationPeriod: '1–17 Juni 2025',
      capacity: 500,
      remaining: 112,
      phase: WorkshopPhase.ongoing,
      attendanceOpen: true,
      image: 'assets/images/kuliah-ai.jpg'),
  Workshop(
      id: 'karya-ilmiah',
      kind: 'Workshop',
      delivery: WorkshopDelivery.offline,
      title: 'Workshop Penulisan Karya Ilmiah',
      theme: 'Menulis Ilmiah dengan Jelas dan Berintegritas',
      description:
          'Workshop praktis untuk meningkatkan kemampuan menyusun karya ilmiah, mengelola referensi, dan menghindari plagiarisme.',
      speaker: 'Prof. Dr. Yuliana, M.Sc.',
      organizer: 'LPPM Universitas Andalas',
      date: 'Senin, 12 Mei 2025',
      shortDate: '12 Mei 2025',
      time: '08.00–14.00 WIB',
      location: 'Gedung Pascasarjana',
      room: 'Ruang 3.1',
      target: 'Mahasiswa tingkat akhir',
      benefits: ['Sertifikat elektronik', 'Modul latihan'],
      registrationPeriod: '20 April–8 Mei 2025',
      capacity: 80,
      remaining: 0,
      status: WorkshopStatus.closed,
      phase: WorkshopPhase.finished,
      image: 'assets/images/karya-ilmiah.jpg'),
  Workshop(
      id: 'kewirausahaan',
      kind: 'Seminar',
      delivery: WorkshopDelivery.online,
      title: 'Seminar Kewirausahaan Mahasiswa',
      theme: 'Dari Ide Menjadi Usaha Berdampak',
      description:
          'Seminar inspiratif bersama wirausahawan muda Sumatera Barat untuk membahas validasi ide dan pertumbuhan usaha.',
      speaker: 'Nadia Putri, Founder Ranah Kreatif',
      organizer: 'Direktorat Kemahasiswaan UNAND',
      date: 'Jumat, 25 April 2025',
      shortDate: '25 Apr 2025',
      time: '13.30–16.00 WIB',
      location: 'Zoom Meeting',
      room: 'Ruang seminar virtual',
      target: 'Mahasiswa UNAND',
      benefits: ['Sertifikat elektronik', 'Jejaring wirausaha'],
      registrationPeriod: '10–22 April 2025',
      capacity: 200,
      remaining: 0,
      status: WorkshopStatus.closed,
      phase: WorkshopPhase.finished,
      image: 'assets/images/seminar.jpg'),
  Workshop(
      id: 'public-speaking',
      kind: 'Workshop',
      delivery: WorkshopDelivery.offline,
      title: 'Workshop Public Speaking Profesional',
      theme: 'Berbicara Meyakinkan di Depan Publik',
      description: 'Latihan komunikasi publik bersama fasilitator profesional.',
      speaker: 'Fikri Maulana, M.I.Kom.',
      organizer: 'Humas Universitas Andalas',
      date: 'Sabtu, 5 Juli 2025',
      shortDate: '5 Jul 2025',
      time: '09.00–15.00 WIB',
      location: 'Gedung Rektorat',
      room: 'Ruang Sidang Senat',
      target: 'Mahasiswa UNAND',
      benefits: ['Sertifikat elektronik', 'Simulasi presentasi'],
      registrationPeriod: '10–30 Juni 2025',
      capacity: 60,
      remaining: 0,
      status: WorkshopStatus.full,
      image: 'assets/images/kuliah-ai.jpg'),
];

Workshop? findWorkshop(String id) {
  for (final workshop in previewWorkshops) {
    if (workshop.id == id) return workshop;
  }
  return null;
}

class ParticipantProfile {
  const ParticipantProfile(
      {required this.name,
      required this.email,
      required this.phone,
      required this.type,
      this.nim});
  final String name, email, phone, type;
  final String? nim;
  static const student = ParticipantProfile(
      name: 'Aulia Rahman',
      email: 'aulia.rahman@student.unand.ac.id',
      phone: '0812 3456 7890',
      type: 'Mahasiswa UNAND',
      nim: '2211521007');
}

class PreviewRegistration {
  const PreviewRegistration(this.workshopId,
      {this.attendance = AttendanceStatus.pending});
  final String workshopId;
  final AttendanceStatus attendance;
  String get attendanceLabel => switch (attendance) {
        AttendanceStatus.pending => 'Belum Presensi',
        AttendanceStatus.present => 'Hadir',
        AttendanceStatus.absent => 'Tidak Hadir'
      };
}

class PreviewNotification {
  const PreviewNotification(
      {required this.id,
      required this.title,
      required this.message,
      required this.time,
      required this.workshopId,
      this.read = false,
      this.certificate = false});
  final String id, title, message, time, workshopId;
  final bool read, certificate;
  PreviewNotification markRead() => PreviewNotification(
      id: id,
      title: title,
      message: message,
      time: time,
      workshopId: workshopId,
      read: true,
      certificate: certificate);
}

class PreviewState {
  const PreviewState(
      {this.profile,
      this.registrations = const [
        PreviewRegistration('kuliah-ai'),
        PreviewRegistration('karya-ilmiah',
            attendance: AttendanceStatus.present),
        PreviewRegistration('kewirausahaan',
            attendance: AttendanceStatus.absent)
      ],
      this.notifications = const [
        PreviewNotification(
            id: 'new',
            title: 'Kegiatan Baru Tersedia!',
            message:
                '“Workshop Data Science dan Artificial Intelligence” baru saja dipublikasikan. Yuk, lihat informasi kegiatannya!',
            time: '10 menit lalu',
            workshopId: 'data-science'),
        PreviewNotification(
            id: 'reminder',
            title: 'Kegiatan Segera Dimulai',
            message:
                '“Kuliah Umum Artificial Intelligence untuk Masa Depan” akan segera berlangsung. Jangan lupa hadir sesuai jadwal!',
            time: '1 jam lalu',
            workshopId: 'kuliah-ai'),
        PreviewNotification(
            id: 'certificate',
            title: 'Sertifikat Sudah Tersedia!',
            message:
                'Sertifikat “Workshop Penulisan Karya Ilmiah” sudah bisa diunduh.',
            time: '2 hari lalu',
            workshopId: 'karya-ilmiah',
            read: true,
            certificate: true),
      ],
      this.corrections = const {}});
  final ParticipantProfile? profile;
  final List<PreviewRegistration> registrations;
  final List<PreviewNotification> notifications;
  final Set<String> corrections;
  int get unread => notifications.where((n) => !n.read).length;
  PreviewRegistration? registrationFor(String id) {
    for (final registration in registrations) {
      if (registration.workshopId == id) return registration;
    }
    return null;
  }

  PreviewState copyWith(
          {ParticipantProfile? profile,
          List<PreviewRegistration>? registrations,
          List<PreviewNotification>? notifications,
          Set<String>? corrections}) =>
      PreviewState(
          profile: profile ?? this.profile,
          registrations: registrations ?? this.registrations,
          notifications: notifications ?? this.notifications,
          corrections: corrections ?? this.corrections);
}

/// Local interaction state for the Figma preview. It does not create API sessions.
class PreviewNotifier extends StateNotifier<PreviewState> {
  PreviewNotifier() : super(const PreviewState());
  void signIn(ParticipantProfile profile) =>
      state = PreviewState(profile: profile);
  void signOut() => state = const PreviewState();
  void updateProfile(ParticipantProfile profile) =>
      state = state.copyWith(profile: profile);
  void register(String id) {
    final workshop = findWorkshop(id);
    if (workshop == null ||
        workshop.status != WorkshopStatus.open ||
        state.registrationFor(id) != null) {
      return;
    }
    state = state.copyWith(
        registrations: [...state.registrations, PreviewRegistration(id)]);
  }

  bool checkIn(String id) {
    if (findWorkshop(id)?.attendanceOpen != true ||
        state.registrationFor(id) == null) {
      return false;
    }
    state = state.copyWith(
        registrations: state.registrations
            .map((r) => r.workshopId == id
                ? PreviewRegistration(id, attendance: AttendanceStatus.present)
                : r)
            .toList());
    return true;
  }

  void markRead(String? id) => state = state.copyWith(
      notifications: state.notifications
          .map((n) => id == null || n.id == id ? n.markRead() : n)
          .toList());
  void requestCorrection(String id) =>
      state = state.copyWith(corrections: {...state.corrections, id});
}

final previewProvider = StateNotifierProvider<PreviewNotifier, PreviewState>(
    (ref) => PreviewNotifier());
