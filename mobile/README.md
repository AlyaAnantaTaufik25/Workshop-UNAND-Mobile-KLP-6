# SIM Workshop UNAND - Aplikasi Mobile (Peserta)

Aplikasi mobile berbasis **Flutter** untuk **Sistem Informasi Manajemen Workshop Universitas Andalas (UNAND)**.

Repositori ini berada di dalam monorepo pada direktori `mobile/` dan dikhususkan untuk **Aktor Peserta**.

---

## 👥 Batasan Aktor (PENTING)

Aplikasi mobile ini **KHUSUS untuk aktor PESERTA** (mahasiswa UNAND dan peserta umum).
- Aktor **Humas**, **Sekretariat Rektor**, **Mitra**, dan **Rektor** beroperasi melalui **aplikasi web** (`frontend/`).
- Tidak ada menu, navigasi, maupun modul administrasi/verifikasi untuk keempat aktor tersebut di aplikasi ini.
- Role yang diizinkan hanya: `AppRoles.peserta = 'peserta'`.
- Saat login, jika akun yang masuk bukan role `peserta`, sistem menolak penyimpanan sesi dan menampilkan pesan:
  > *"Akun ini bukan akun peserta. Silakan gunakan aplikasi web."*

---

## 🛠️ Tech Stack & Arsitektur

- **Framework**: Flutter (Dart 3, null safety, Material 3)
- **State Management**: `flutter_riverpod` (Provider & StateNotifier, clean & scalable tanpa code generation awal)
- **Routing**: `go_router` (StatefulShellRoute untuk bottom navigation 5 tab)
- **HTTP Client**: `dio` (AuthInterceptor untuk Bearer Token + LogInterceptor pada mode debug)
- **Model JSON**: `json_annotation` + `json_serializable` (dev) + `build_runner` (dev)
- **Penyimpanan Sesi**: `flutter_secure_storage` (token, user ID, role)
- **Code Quality**: `flutter_lints` (`analysis_options.yaml`)

> **Rencana Package Masa Depan (Belum Dipasang di Tahap Inisiasi):**
> - **Presensi**: `mobile_scanner`, `geolocator`, `permission_handler`
> - **Sertifikat PDF**: `path_provider`, `open_filex`

---

## 📁 Struktur Direktori `mobile/`

```text
mobile/
├── android/                   # Konfigurasi platform Android (cleartext debug & INTERNET)
├── ios/                       # Konfigurasi platform iOS (NSAllowsLocalNetworking)
├── env/
│   ├── dev.json.example       # Template konfigurasi environment lokal
│   └── dev.json               # Konfigurasi asli (di-.gitignore)
├── .vscode/
│   └── launch.json            # Konfigurasi Run & Debug dengan --dart-define-from-file
├── lib/
│   ├── main.dart              # Entrypoint aplikasi + ProviderScope + MaterialApp.router
│   ├── core/
│   │   ├── config/            # Env.dart (pembacaan API_BASE_URL)
│   │   ├── constants/         # AppRoles, ApiEndpoints
│   │   ├── network/           # ApiResponse, DioClient, AuthInterceptor, ApiExceptions
│   │   ├── storage/           # SessionStorage (FlutterSecureStorage + isPeserta())
│   │   ├── theme/             # AppTheme (Material 3 tema hijau/emas UNAND)
│   │   └── widgets/           # LoadingView, ErrorView
│   ├── routing/
│   │   ├── app_router.dart    # GoRouter + ShellRoute bottom nav
│   │   └── scaffold_with_nav_bar.dart
│   └── modules/               # Arsitektur modular per fitur Peserta
│       ├── health/            # [AKTIF E2E] Cek koneksi server GET /api/v1/health
│       ├── auth/              # [PLANNED] Login & Register peserta
│       ├── workshops/         # [PLANNED] Katalog & detail workshop
│       ├── registrations/     # [PLANNED] Kegiatan saya & pembatalan
│       ├── attendance/        # [PLANNED] Presensi QR dinamis & geofencing
│       ├── certificates/      # [PLANNED] Sertifikat saya, unduh PDF, verifikasi publik
│       └── profile/           # [PLANNED] Profil akun peserta & tombol logout
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

---

## 🚀 Panduan Menjalankan Aplikasi

### 1. Jalankan Backend Terlebih Dahulu
Masuk ke direktori `backend/` pada root repositori:
```bash
cd backend
npm install
npm run dev
```
Backend berjalan di: `http://localhost:5000/api/v1`

### 2. Konfigurasi Environment File
Salin file template environment di direktori `mobile/`:
```bash
cd mobile
cp env/dev.json.example env/dev.json
```
Sesuaikan isi `env/dev.json` dengan target perangkat:

| Target Perangkat | Nilai `API_BASE_URL` | Catatan |
|---|---|---|
| **Emulator Android** | `http://10.0.2.2:5000/api/v1` | Alamat alias Android Studio ke localhost laptop |
| **iOS Simulator** | `http://localhost:5000/api/v1` | Menghubungi langsung ke localhost Mac |
| **HP Fisik (Android/iOS)**| `http://<IP-LAN-LAPTOP>:5000/api/v1` | Contoh: `http://192.168.1.10:5000/api/v1` (harus 1 Wi-Fi) |

### 3. Menjalankan Aplikasi

#### Menggunakan Terminal / CLI:
```bash
cd mobile
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```

#### Menggunakan VS Code:
1. Buka folder repositori di VS Code.
2. Buka menu **Run & Debug** (`Ctrl+Shift+D` atau `Cmd+Shift+D`).
3. Pilih profil: **`workshop_peserta (Dev - Emulator)`**.
4. Tekan tombol `F5`.

#### Menggunakan Android Studio:
1. Masuk ke **Run** > **Edit Configurations...**
2. Pada konfigurasi Flutter app, tambahkan pada kolom **Additional run args**:
   ```text
   --dart-define-from-file=env/dev.json
   ```
3. Klik **Apply** dan jalankan aplikasi.

---

## 🔍 Fitur yang Sudah Aktif: Cek Koneksi Server
Pada tahap inisiasi awal ini, seluruh modul telah memiliki kerangka placeholder (API service dengan TODO, repository, provider, dan view). 

Satu-satunya fitur yang **aktif secara penuh end-to-end** adalah:
- **Layar Cek Koneksi Server** (`/health`): Memanggil endpoint `GET /api/v1/health` untuk memastikan aplikasi di emulator/HP dapat menjangkau server backend dan database MySQL lokal.
- Dapat diakses dari:
  1. Tombol pada halaman login ("Cek Koneksi ke Server Backend").
  2. Tombol di AppBar katalog workshop.
  3. Tombol pada halaman profil peserta.

---

## 📋 Daftar Endpoint yang Dibutuhkan Mobile (PROPOSED)

Daftar endpoint berikut diperlukan untuk alur peserta di aplikasi mobile tetapi belum tercantum pada `docs/api-contract.md`:
1. `GET /api/v1/attendance/my/:workshopId` : Mengetahui status kehadiran peserta pada satu workshop tertentu.
2. `GET /api/v1/certificates/:id/download` : Mengunduh berkas fisik sertifikat berformat PDF.
3. `POST /api/v1/certificates/:id/correction-requests` : Peserta mengajukan koreksi nama/data pada sertifikat ke panitia.

