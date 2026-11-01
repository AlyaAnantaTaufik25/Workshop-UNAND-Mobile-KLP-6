# 📱 Aplikasi Mobile Peserta - SIM Workshop UNAND

Aplikasi mobile berbasis **Flutter** ini dikembangkan untuk peserta workshop di lingkungan Universitas Andalas, baik kalangan mahasiswa UNAND maupun masyarakat umum. Melalui aplikasi ini, peserta dapat menjelajahi katalog kegiatan workshop, mendaftar ke kegiatan yang diinginkan, melakukan presensi berbasis pemindaian QR Code dinamis dan validasi radius lokasi (*geofencing*), memantau riwayat serta status kehadiran, mengunduh sertifikat resmi berformat PDF dengan tanda tangan elektronik, hingga mengajukan permohonan perbaikan data sertifikat secara mandiri. Seluruh pertukaran data terhubung langsung ke backend RESTful API yang sama dengan platform web pengelola.

---

## 🧑‍🎓 Aktor Pengguna

> **⚠️ PENTING: Aplikasi Mobile Ini KHUSUS untuk Aktor PESERTA**
>
> Pengguna yang dilayani adalah **Mahasiswa Universitas Andalas** dan **Peserta Umum**. Aktor **Humas UNAND**, **Sekretariat Rektor**, **Mitra Kerja Sama**, dan **Rektor** mengelola operasional melalui aplikasi web pada folder [`../frontend`](../frontend/README.md). Tidak ada antarmuka, modul, maupun hak akses untuk keempat aktor pengelola tersebut di aplikasi mobile ini.

### Perilaku Pembatasan Akses (Planned Behavior)

Aplikasi menerapkan validasi peran (*role-based access*) saat autentikasi. Apabila akun yang masuk memiliki peran selain `peserta`, sesi login tidak akan disimpan ke penyimpanan lokal dan sistem langsung menampilkan pesan penolakan:

```
"Akun ini bukan akun peserta. Silakan gunakan aplikasi web."
```

### Dasar Keputusan Arsitektur

Pembatasan ini merujuk langsung pada dokumen perancangan sistem Kelompok 6:

1. **Dokumen A3 (Perancangan Sistem - Mobile Design)**: Gambar 3.108 sampai dengan Gambar 3.125 secara khusus hanya mendefinisikan alur layar untuk Peserta.
2. **Dokumen A2 (Spesifikasi Kebutuhan Sistem)**: Kebutuhan fungsional antarmuka mobile berfokus penuh pada aktivitas peserta workshop di lapangan (pendaftaran cepat, pemindaian QR presensi, dan klaim sertifikat).

---

## ✨ Fitur untuk Peserta

Daftar kebutuhan fungsional aktor Peserta yang bersumber dari Dokumen A2 serta status implementasinya saat ini:

| No | Fitur | Keterangan | Status |
|:--:|---|---|:---:|
| 1 | **Cek Koneksi Server (Health Check)** | Memeriksa ketersediaan REST API backend dan database MySQL lokal | **ACTIVE** |
| 2 | **Registrasi Akun** | Pendaftaran akun baru bagi mahasiswa UNAND dan peserta umum | PLANNED |
| 3 | **Login Akun** | Masuk ke sistem dengan email & password untuk memperoleh token JWT | PLANNED |
| 4 | **Logout Sesi** | Keluar dari aplikasi dan menghapus token dari secure storage | PLANNED |
| 5 | **Kelola Profil** | Melihat informasi akun dan memperbarui data diri peserta | PLANNED |
| 6 | **Melihat Daftar & Detail Kegiatan** | Menjelajahi katalog workshop aktif, informasi narasumber, dan jadwal | PLANNED |
| 7 | **Mendaftar Kegiatan** | Mengajukan keikutsertaan workshop (tiket peserta / *waiting list*) | PLANNED |
| 8 | **Melihat Kegiatan yang Diikuti** | Meninjau riwayat workshop yang telah didaftarkan serta pembatalan tiket | PLANNED |
| 9 | **Melakukan Presensi** | Check-in kehadiran via scan QR dinamis panitia dan validasi GPS (*geofencing*) | PLANNED |
| 10 | **Melihat Status Kehadiran** | Memantau rekap status presensi (hadir / tidak hadir) per kegiatan | PLANNED |
| 11 | **Mengunduh Sertifikat** | Mengunduh sertifikat digital ber-TTE resmi yang telah terbit (PDF) | PLANNED |
| 12 | **Mengajukan Perbaikan Sertifikat** | Mengajukan koreksi data (e.g., ejaan nama, gelar) pada draf sertifikat | PLANNED |

*Status **ACTIVE** = fitur sudah dapat diuji end-to-end. Status **PLANNED** = dalam antrean pengerjaan.*

---

## 🛠️ Teknologi yang Digunakan

Aplikasi mobile dibangun menggunakan **Flutter** dengan bahasa pemrograman **Dart 3 (null safety)** dan desain antarmuka **Material 3**. Pemilihan Flutter didasari kebutuhan menghasilkan satu basis kode (*single codebase*) yang dapat berjalan optimal di Android maupun iOS secara konsisten, mengingat peserta workshop menggunakan ragam gawai yang sangat bervariasi.

| Kebutuhan | Package / Pustaka | Fungsi Utama | Status |
|---|---|---|:---:|
| **Framework & UI** | `flutter` + Material 3 | Kerangka kerja lintas platform & komponen UI standar | Terpasang |
| **State Management** | `flutter_riverpod: ^2.5.1` | Manajemen state yang reaktif, aman, dan mudah diuji | Terpasang |
| **Routing & Navigasi** | `go_router: ^14.2.0` | Navigasi deklaratif berbasis URL & `StatefulShellRoute` | Terpasang |
| **HTTP Client** | `dio: ^5.4.3+1` | Pemanggilan REST API, interceptor token JWT & logging debug | Terpasang |
| **Serialisasi JSON** | `json_annotation`, `json_serializable` | Konversi DTO JSON aman tipe data (*type-safe*) | Terpasang |
| **Code Generation** | `build_runner: ^2.4.9` | Generator otomatis file mapper model (`*.g.dart`) | Terpasang |
| **Penyimpanan Kredensial** | `flutter_secure_storage: ^9.2.2` | Penyimpanan token JWT & peran terenkripsi (Keystore/Keychain) | Terpasang |
| **Linter & Code Style** | `flutter_lints: ^4.0.0` | Penegakan aturan penulisan kode baku Flutter | Terpasang |
| **Pemindaian QR** | `mobile_scanner` | Pembacaan QR Code token presensi via kamera perangkat | **Rencana** |
| **Lokasi & Geofencing** | `geolocator`, `permission_handler` | Pengecekan GPS presisi tinggi dan deteksi manipulasi lokasi | **Rencana** |
| **Unduh & Buka PDF** | `path_provider`, `open_filex` | Menyimpan stream file sertifikat dan membuka penampil PDF | **Rencana** |

---

## 📋 Prasyarat

Sebelum menjalankan aplikasi mobile, pastikan komputer pengembangan Anda telah memenuhi seluruh komponen berikut:

1. **Flutter SDK** versi stable terbaru (minimal v3.19.0). Cek dengan:
   ```bash
   flutter --version
   ```
2. **Android Studio** dengan komponen Android SDK Build-Tools, Platform-tools, dan minimal satu Android Virtual Device (AVD) API 26 ke atas.
3. **Perangkat Pengujian**, salah satu dari:
   - Emulator Android Studio, atau
   - Smartphone fisik Android dengan opsi *Developer Options* dan *USB Debugging* aktif.
   - *(Opsional)* Komputer macOS + Xcode untuk pengujian di iOS Simulator.
4. **Backend Server SIM Workshop** sudah dapat dijalankan di laptop. Panduan lengkap tersedia di [`../README.md`](../README.md).
5. **Verifikasi Lingkungan** — Jalankan perintah berikut dan pastikan baris Flutter serta Android toolchain bertanda centang hijau (✓):
   ```bash
   flutter doctor
   ```

---

## 🚀 Cara Menjalankan

Ikuti langkah-langkah terurut berikut untuk memulai aplikasi pada lingkungan lokal:

### Langkah 1 — Jalankan Backend Terlebih Dahulu

Aplikasi mobile membutuhkan backend REST API yang aktif. Dari direktori root repositori:

```bash
cd backend
npm install
npm run dev
```

Pastikan output terminal menampilkan pesan koneksi database, lalu buka peramban laptop dan akses:

```
http://localhost:5000/api/v1/health
```

Jika halaman menampilkan `"status": "healthy"`, backend siap menerima koneksi dari aplikasi mobile.

### Langkah 2 — Masuk ke Folder Mobile

```bash
cd mobile
```

### Langkah 3 — Salin Konfigurasi Environment

Salin template variabel lingkungan menjadi berkas konfigurasi aktif:

- **Windows PowerShell:**
  ```powershell
  Copy-Item env\dev.json.example env\dev.json
  ```
- **Linux / macOS / Git Bash:**
  ```bash
  cp env/dev.json.example env/dev.json
  ```

### Langkah 4 — Sesuaikan Alamat Backend

Buka `env/dev.json` dan sesuaikan nilai `API_BASE_URL` sesuai perangkat pengujian Anda. Lihat panduan lengkap pada [Bagian Konfigurasi Koneksi](#-konfigurasi-koneksi-ke-backend).

### Langkah 5 — Pasang Dependensi Flutter

```bash
flutter pub get
```

### Langkah 6 — Generate Kode Model JSON

```bash
dart run build_runner build --delete-conflicting-outputs
```

> **Catatan**: Perintah ini mengompilasi berkas model data (`@JsonSerializable`) menjadi berkas `*.g.dart` yang dibutuhkan saat runtime. **Wajib dijalankan ulang** setiap kali Anda menambahkan atau memodifikasi atribut pada model data.

### Langkah 7 — Jalankan Aplikasi

```bash
flutter run --dart-define-from-file=env/dev.json
```

### Langkah 8 — Menjalankan Melalui IDE

- **VS Code / Cursor**: Konfigurasi profil run sudah tersedia di [`.vscode/launch.json`](.vscode/launch.json). Buka panel **Run & Debug** (`Ctrl+Shift+D` / `Cmd+Shift+D`), pilih **`workshop_peserta (Dev - Emulator)`**, lalu tekan **F5**.

- **Android Studio**: Buka **Run** › **Edit Configurations...**, pilih konfigurasi Flutter Anda, lalu tambahkan pada kolom **Additional run args**:
  ```
  --dart-define-from-file=env/dev.json
  ```

### Langkah 9 — Hasil yang Diharapkan

Aplikasi terbuka dengan tema hijau Universitas Andalas dan menampilkan halaman awal. Klik tombol **"Cek Koneksi ke Server Backend"** untuk memverifikasi bahwa status server bernilai `healthy` dan status database MySQL bernilai `connected`.

---

## 🔌 Konfigurasi Koneksi ke Backend

Alamat URL backend **tidak pernah ditulis langsung (*hardcoded*)** di dalam kode sumber. Nilai tersebut dibaca saat kompilasi dari berkas `env/dev.json` melalui variabel `Env.apiBaseUrl`. Berkas `env/dev.json` bersifat rahasia lokal dan **tidak ikut di-commit** ke repositori (sudah tercantum di `.gitignore`).

### Tabel Penentuan Alamat API

| Perangkat Pengujian | Nilai `API_BASE_URL` | Keterangan |
|---|---|---|
| **Emulator Android** | `http://10.0.2.2:5000/api/v1` | `10.0.2.2` adalah alias khusus emulator Android menuju `localhost` laptop host |
| **iOS Simulator** | `http://localhost:5000/api/v1` | Simulator iOS berbagi tumpukan jaringan langsung dengan macOS host |
| **Smartphone Fisik** | `http://<IP-LAN-LAPTOP>:5000/api/v1` | Contoh: `http://192.168.1.15:5000/api/v1`. HP dan laptop harus satu Wi-Fi |

### Cara Menemukan IP LAN Laptop

- **Windows PowerShell / CMD:**
  ```powershell
  ipconfig
  ```
  Cari nilai `IPv4 Address` pada adapter **Wi-Fi**.

- **Linux / macOS:**
  ```bash
  ifconfig
  # atau
  ip addr show
  ```
  Cari alamat IP lokal (biasanya berawalan `192.168.x.x` atau `10.x.x.x`).

> **Catatan untuk Smartphone Fisik:**
> - Pastikan server backend mendengarkan koneksi dari luar (`0.0.0.0`), bukan hanya `127.0.0.1`.
> - Izinkan port **5000** pada *Windows Defender Firewall* atau firewall OS laptop Anda.
> - Komunikasi HTTP tanpa HTTPS hanya diizinkan di **mode debug**. Konfigurasi `android:usesCleartextTraffic="true"` dipasang pada berkas debug saja: [`android/app/src/debug/AndroidManifest.xml`](android/app/src/debug/AndroidManifest.xml).

### Format Pertukaran Data REST API

Aplikasi mengadopsi format respon standar backend (lihat [`backend/src/utils/response.util.js`](../backend/src/utils/response.util.js)):

**Respon Berhasil (HTTP 200/201):**
```json
{
  "success": true,
  "message": "Data berhasil dimuat",
  "data": { ... }
}
```

**Respon Gagal (HTTP 4xx/5xx):**
```json
{
  "success": false,
  "message": "Validasi gagal",
  "errors": [
    "Format email tidak valid",
    "Kata sandi minimal 8 karakter"
  ]
}
```

Lapisan jaringan aplikasi secara otomatis memetakan respon sukses ke kelas generik [`ApiResponse<T>`](lib/core/network/api_response.dart) dan membungkus kegagalan ke dalam [`ApiException`](lib/core/network/api_exceptions.dart) agar pesan kesalahan dapat divisualisasikan dengan rapi di antarmuka pengguna. Rincian kontrak API lengkap tersedia di [`../docs/api-contract.md`](../docs/api-contract.md).

---

## 📁 Struktur Folder

Direktori `mobile/` dirancang dengan pendekatan modular berbasis fitur (*feature-first*), di mana setiap modul memiliki pemisahan lapisan yang jelas:

```text
mobile/
├── android/                        # Berkas native Android (izin & konfigurasi debug/release)
│   └── app/src/
│       ├── debug/AndroidManifest.xml   # usesCleartextTraffic=true hanya saat debug
│       └── main/AndroidManifest.xml    # Deklarasi permission INTERNET
├── ios/
│   └── Runner/Info.plist           # NSAllowsLocalNetworking untuk koneksi server lokal (iOS)
├── env/
│   ├── dev.json.example            # Template variabel environment (boleh di-commit)
│   └── dev.json                    # Konfigurasi aktif lokal (diabaikan Git)
├── .vscode/
│   └── launch.json                 # Profil run & debug untuk VS Code dan Cursor
├── lib/
│   ├── main.dart                   # Titik masuk: ProviderScope + MaterialApp.router
│   ├── core/                       # Infrastruktur & utilitas lintas modul
│   │   ├── config/
│   │   │   └── env.dart            # Pembacaan API_BASE_URL dari --dart-define-from-file
│   │   ├── constants/
│   │   │   ├── app_roles.dart      # Konstanta: AppRoles.peserta = 'peserta'
│   │   │   └── api_endpoints.dart  # Seluruh path URL REST API
│   │   ├── network/
│   │   │   ├── dio_client.dart     # Instansi Dio terpusat + interceptor
│   │   │   ├── auth_interceptor.dart # Injeksi Bearer token & penanganan 401
│   │   │   ├── api_response.dart   # Model pembungkus ApiResponse<T>
│   │   │   └── api_exceptions.dart # Hierarki ApiException, NetworkException, dll.
│   │   ├── storage/
│   │   │   └── session_storage.dart # FlutterSecureStorage: token, role, isPeserta()
│   │   ├── theme/
│   │   │   └── app_theme.dart      # Material 3 — palet hijau & emas Universitas Andalas
│   │   └── widgets/
│   │       ├── loading_view.dart   # Indikator loading standar
│   │       └── error_view.dart     # Penampil pesan & daftar errors dari backend
│   ├── routing/
│   │   ├── app_router.dart         # GoRouter terpusat dengan StatefulShellRoute
│   │   └── scaffold_with_nav_bar.dart # Bottom Navigation Bar 4 tab peserta
│   └── modules/                    # Modul fungsional (selaras nama dengan backend/src/modules/)
│       ├── health/                 # [ACTIVE] Cek Koneksi Server — GET /health
│       │   ├── data/               # health_api_service.dart, health_repository.dart
│       │   ├── models/             # health_model.dart
│       │   ├── providers/          # health_provider.dart (StateNotifier)
│       │   └── views/             # health_screen.dart
│       ├── auth/                   # [PLANNED] Login & Registrasi Peserta
│       ├── workshops/              # [PLANNED] Katalog & Detail Kegiatan
│       ├── registrations/          # [PLANNED] Pendaftaran & Kegiatan Saya
│       ├── attendance/             # [PLANNED] Presensi QR & Geofencing
│       ├── certificates/           # [PLANNED] Sertifikat Digital & Verifikasi
│       └── profile/               # [PLANNED] Profil & Pengaturan Akun
├── test/
│   └── core/network/
│       └── api_response_test.dart  # Unit test parsing ApiResponse sukses & gagal
├── analysis_options.yaml           # Aturan analisis statis (flutter_lints)
├── pubspec.yaml                    # Metadata & dependensi proyek
└── README.md                       # Panduan dokumentasi ini
```

### Pola Isi Setiap Folder Modul

Nama modul di bawah `lib/modules/` sengaja diselaraskan dengan modul backend di [`backend/src/modules/`](../backend/src/modules/) agar memudahkan pemetaan antara layar mobile dan endpoint yang dikonsumsi:

```text
modules/<nama_modul>/
├── data/
│   ├── <nama>_api_service.dart   # Pemanggilan HTTP via Dio
│   └── <nama>_repository.dart    # Abstraksi sumber data (koordinator)
├── models/                       # Data Transfer Object (DTO) + entitas domain
├── providers/                    # Riverpod StateNotifier (state & business logic)
└── views/                        # Widget layar (Screen) & komponen UI modul
```

### Diagram Alur Data Aplikasi

```
┌─────────────┐     watch/read      ┌─────────────────────┐
│  View/UI    │ ◄────────────────── │  Riverpod Provider  │
│  (Screen)   │                     │  (StateNotifier)    │
└──────┬──────┘                     └──────────┬──────────┘
       │ trigger event (tap)                   │ call
       └─────────────────────────────────────► │
                                               ▼
                                    ┌──────────────────────┐
                                    │  Repository          │
                                    │  (sumber data tunggal│
                                    │   untuk View)        │
                                    └──────────┬───────────┘
                                               │ call
                                               ▼
                                    ┌──────────────────────┐
                                    │  API Service (Dio)   │
                                    │  AuthInterceptor     │
                                    │  Bearer Token        │
                                    └──────────┬───────────┘
                                               │ HTTP JSON
                                               ▼
                                    ┌──────────────────────┐
                                    │  Backend REST API    │
                                    │  (Node.js + Express) │
                                    └──────────────────────┘
```

| Lapisan | Tanggung Jawab |
|---|---|
| **View** | Merender antarmuka dan mendengarkan perubahan state dari Provider |
| **Provider** | Menampung logika bisnis presentasi dan mengelola state aktif layar |
| **Repository** | Mengkoordinasikan sumber data (jaringan atau cache lokal) |
| **API Service** | Menangani komunikasi HTTP murni, injeksi token, dan parsing respons |

---

## 🗺️ Daftar Halaman & Endpoint

Tabel berikut memetakan rancangan layar pada Dokumen A3 ke modul kode dan endpoint REST API:

| Halaman Aplikasi | Gambar A3 | Modul Kode | Endpoint REST API | Status |
|---|:---:|---|---|:---:|
| Health Check (Diagnostik Server) | — | `health` | `GET /api/v1/health` | **ACTIVE** |
| Login Mahasiswa UNAND | 3.108 | `auth` | `POST /api/v1/auth/login` | PLANNED |
| Login Peserta Umum | 3.109 | `auth` | `POST /api/v1/auth/login` | PLANNED |
| Daftar Akun Mahasiswa | 3.110 | `auth` | `POST /api/v1/auth/register` | PLANNED |
| Daftar Akun Peserta Umum | 3.111 | `auth` | `POST /api/v1/auth/register` | PLANNED |
| Dashboard / Katalog Kegiatan | 3.112 | `workshops` | `GET /api/v1/workshops` | PLANNED |
| Detail Kegiatan Workshop | 3.113 | `workshops` | `GET /api/v1/workshops/{id}` | PLANNED |
| Pop-up Konfirmasi Daftar | 3.114 | `registrations` | `POST /api/v1/registrations` | PLANNED |
| Pop-up Berhasil Daftar | 3.115 | `registrations` | *(Respon UI dari pendaftaran)* | PLANNED |
| Kegiatan Saya | 3.116 | `registrations` | `GET /api/v1/registrations/my` | PLANNED |
| Presensi Kegiatan (QR Scanner) | 3.117 | `attendance` | `POST /api/v1/attendance/check-in` | PLANNED |
| Konfirmasi Presensi Berhasil | 3.118 | `attendance` | *(Respon UI dari check-in)* | PLANNED |
| Status Absensi per Kegiatan | 3.119 | `attendance` | `GET /api/v1/attendance/my/{workshopId}` | **PROPOSED** |
| Daftar Sertifikat Saya | 3.120 | `certificates` | `GET /api/v1/certificates/my` | PLANNED |
| Detail & Unduh Sertifikat PDF | 3.121 | `certificates` | `GET /api/v1/certificates/{id}/download` | **PROPOSED** |
| Ajukan Perbaikan Sertifikat | 3.122 | `certificates` | `POST /api/v1/certificates/{id}/correction-requests` | **PROPOSED** |
| Profil Akun Peserta | 3.123 | `profile` | `GET /api/v1/auth/me` | PLANNED |
| Edit Data Akun | 3.124 | `profile` | `PUT /api/v1/users/{id}` | PLANNED |
| Filter & Pencarian Kegiatan | 3.125 | `workshops` | `GET /api/v1/workshops` | PLANNED |

### Keterangan Status

| Status | Arti |
|:---:|---|
| **ACTIVE** | Sudah diimplementasikan dan dapat diuji saat ini |
| **PLANNED** | Sudah terdaftar di [`../docs/api-contract.md`](../docs/api-contract.md), menunggu giliran pengerjaan |
| **PROPOSED** | Dibutuhkan oleh alur mobile tetapi **belum ada** di dokumen kontrak API — perlu dikoordinasikan lebih lanjut dengan tim backend |

### Struktur Menu Navigasi Bawah

Antarmuka utama peserta menggunakan *bottom navigation bar* dengan 4 menu utama:

| Urutan | Label | Route | Keterangan |
|:---:|---|---|---|
| 1 | **Beranda** | `/workshops` | Katalog & pencarian kegiatan workshop |
| 2 | **Kegiatan Saya** | `/registrations` | Riwayat pendaftaran & pembatalan |
| 3 | **Sertifikat** | `/certificates` | Daftar & unduh sertifikat digital |
| 4 | **Akun** | `/profile` | Profil peserta & pengaturan |

*(Fitur Presensi diakses secara kontekstual melalui tombol aksi cepat dari halaman detail kegiatan atau halaman Kegiatan Saya.)*

---

## 📍 Catatan Fitur Presensi (Rencana Alur)

Fitur presensi merupakan nilai inovasi utama aplikasi mobile SIM Workshop UNAND yang mengombinasikan **QR Code Dinamis** dan **Validasi Radius Geofencing**. Berikut alur yang direncanakan:

1. **Permintaan Izin Terisolasi**: Izin kamera (`CAMERA`) hanya diminta saat peserta menekan tombol buka pemindai. Izin lokasi presisi (`ACCESS_FINE_LOCATION`) hanya diminta ketika pengguna memasuki layar presensi aktif — tidak diminta secara global saat aplikasi pertama kali dibuka.

2. **Mekanisme Check-In di Lapangan**:
   - Kamera memindai token QR yang ditayangkan oleh panitia workshop (QR berganti secara berkala).
   - Package `geolocator` mengambil koordinat lintang dan bujur terkini pengguna dengan akurasi tinggi dalam batas waktu (*timeout*) tertentu.
   - Data `qr_token`, `latitude`, dan `longitude` langsung dikirimkan ke endpoint `POST /api/v1/attendance/check-in`.

3. **Validasi Terpusat di Server**: Server backend memvalidasi masa berlaku token QR, menghitung jarak koordinat GPS peserta terhadap lokasi gedung/ruangan workshop, dan memeriksa status pendaftaran. Aplikasi mobile bertugas menyajikan notifikasi keberhasilan atau pesan alasan penolakan dari server.

4. **Deteksi Manipulasi Lokasi**: Di platform Android, direncanakan memanfaatkan properti `isMocked` dari package `geolocator` untuk mendeteksi penggunaan aplikasi GPS palsu (*fake GPS*) dan mencegah kecurangan titip absen jarak jauh.

---

## 🧪 Pengujian & Pemeriksaan Kode

Jalankan seluruh perintah berikut sebelum mengajukan *Pull Request*:

**1. Analisis Sintaksis & Linter:**
```bash
flutter analyze
```

**2. Pengujian Unit Otomatis:**
```bash
flutter test
```
*Saat ini pengujian unit mencakup verifikasi serialisasi `ApiResponse` untuk skenario respon sukses (parsing `data`) maupun respon gagal (parsing `errors` berupa array string).*

**3. Penyelarasan Format Kode:**
```bash
dart format .
```

---

## 🌿 Aturan Kolaborasi Git untuk Mobile

Mengacu pada panduan kolaborasi Git utama di [`../README.md`](../README.md#-aturan-branch--kolaborasi-git):

### 1. Penamaan Branch

Selalu cabang dari `develop` dengan format khusus mobile:
```text
feature/mb-<nama-fitur>
```
Contoh: `feature/mb-login`, `feature/mb-presensi-qr`, `feature/mb-katalog-workshop`

### 2. Standar Pesan Commit

Gunakan *Conventional Commits* dengan scope `(mobile)`:
```text
feat(mobile): tambah halaman login mahasiswa
fix(mobile): perbaiki parsing array error response
docs(mobile): perbarui panduan konfigurasi IP LAN untuk HP fisik
refactor(mobile): optimasi manajemen state provider kegiatan
```

### 3. Aturan Kebersihan Berkas

- ❌ Jangan commit `env/dev.json` (konfigurasi lokal pribadi).
- ❌ Jangan commit direktori `build/`, `android/.gradle/`, dan `.dart_tool/`.
- ⚠️ Berkas `*.g.dart` (hasil `build_runner`) disarankan **di-generate lokal** oleh masing-masing pengembang. Diskusikan bersama tim apakah perlu di-gitignore atau di-commit.

### 4. Alur Pull Request

1. Push branch ke GitHub dan buat Pull Request menuju `develop`.
2. Minta tinjauan (*code review*) dari minimal satu rekan pengembang sebelum merge.
3. Jika implementasi mobile membutuhkan **endpoint REST baru** yang belum ada, diskusikan terlebih dahulu dengan pengembang backend, lalu catat perubahan di [`../docs/api-contract.md`](../docs/api-contract.md) sebelum mulai mengimplementasi.

---

## ❓ Masalah yang Sering Terjadi (Troubleshooting)

| Masalah | Kemungkinan Penyebab | Solusi |
|---|---|---|
| **"Server tidak dapat dijangkau"** di Emulator | Backend belum berjalan atau `API_BASE_URL` salah | Pastikan `npm run dev` berjalan di terminal backend (port 5000 aktif). Gunakan `http://10.0.2.2:5000/api/v1` khusus untuk emulator Android. |
| **Koneksi gagal di HP Fisik**, lancar di emulator | Masih memakai `10.0.2.2`, HP di jaringan berbeda, atau firewall laptop memblokir | Ganti `API_BASE_URL` ke IP LAN laptop (`ipconfig`). Pastikan satu jaringan Wi-Fi dan buka port 5000 di firewall. |
| **Error: "Cleartext HTTP traffic not permitted"** | Menjalankan mode release dengan URL `http://` | Koneksi HTTP tanpa SSL hanya diizinkan saat debug. Jalankan dengan `flutter run` (debug), bukan `flutter run --release`. |
| **Error: File `*.g.dart` tidak ditemukan** | Build runner belum dieksekusi | Jalankan `dart run build_runner build --delete-conflicting-outputs` dari folder `mobile`. |
| **`API_BASE_URL` kosong atau nilai default** | Lupa menyertakan argumen `--dart-define-from-file` | Selalu sertakan `--dart-define-from-file=env/dev.json` baik saat menjalankan via terminal maupun IDE. |
| **`flutter doctor` menunjukkan Android license belum diterima** | Lisensi Android SDK belum disetujui | Jalankan `flutter doctor --android-licenses` dan ketik `y` untuk setiap persetujuan lisensi. |

---

## 🛣️ Rencana Pengembangan

Daftar tahapan implementasi fitur secara berurutan:

- [x] Inisiasi proyek Flutter, struktur modular, dan integrasi Riverpod + GoRouter
- [x] Konfigurasi koneksi jaringan Dio, interceptor token JWT, dan penanganan error standar
- [x] Fitur aktif diagnostik server: **Cek Kesehatan API** (`GET /api/v1/health`)
- [ ] **Modul Auth**: Layar login & registrasi (mahasiswa dan umum) + validasi role peserta + integrasi token JWT
- [ ] **Modul Workshops**: Tampilan daftar kegiatan, pencarian, filter, dan halaman detail workshop
- [ ] **Modul Registrations**: Alur pendaftaran kegiatan, validasi kuota, *waiting list*, dan pembatalan tiket
- [ ] **Modul Attendance**: Pemasangan `mobile_scanner` + `geolocator`, implementasi alur scan QR + validasi GPS, dan pengujian di HP fisik
- [ ] **Modul Certificates**: Tampilan daftar sertifikat, unduh PDF via `open_filex`, dan formulir pengajuan koreksi
- [ ] **Modul Profile**: Pengelolaan data diri peserta, ubah kata sandi, dan halaman logout
- [ ] Pengujian menyeluruh di perangkat fisik Android dan iOS (opsional)

---

## 🔗 Referensi

- 📄 [Panduan Utama Proyek Monorepo SIM Workshop UNAND](../README.md)
- 📋 [Spesifikasi Kontrak REST API Backend](../docs/api-contract.md)
- Dokumen Perancangan Perangkat Lunak **Kelompok 6 SIM Workshop UNAND**:
  - **Dokumen A1** — Proposal Pengembangan Sistem
  - **Dokumen A2** — Spesifikasi Kebutuhan Sistem *(SRS — Kebutuhan Fungsional Peserta)*
  - **Dokumen A3** — Perancangan Arsitektur & Antarmuka Sistem *(Mobile Design: Gambar 3.108 – 3.125)*
