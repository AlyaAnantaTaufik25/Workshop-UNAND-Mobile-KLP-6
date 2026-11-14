# Pratinjau UI Workshop UNAND

Implementasi Flutter mengikuti [referensi Figma](https://score-plant-12480283.figma.site/): font Inter, hijau `#14532D`, kartu kegiatan, gambar kampus, latar `#F7F8FA`, dan navigasi empat menu. Pada layar besar, antarmuka dibatasi hingga 430 px seperti referensi. Gambar dan font dibundel sehingga tidak memerlukan jaringan saat ditampilkan.

## Menjalankan

Dari folder `mobile`:

```powershell
flutter pub get
flutter run
```

Untuk menjalankan tampilan di browser Chrome:

```powershell
flutter run -d chrome
```

Dukungan web sudah disiapkan di folder `web`; tidak perlu `npm install` atau server backend untuk menjelajahi data contoh.

Pilih **Masuk sebagai Mahasiswa** untuk menjelajahi data contoh. Form peserta umum memvalidasi email dan kata sandi minimal enam karakter. Jangan gunakan kata sandi asli untuk pratinjau.

## Halaman dan interaksi

- Login mahasiswa/peserta umum dan formulir pendaftaran akun.
- Beranda dengan pencarian, filter jenis kegiatan, kartu unggulan, dan daftar kegiatan. Setiap kartu menampilkan label Online (ikon video) untuk kegiatan daring atau nama tempat (ikon lokasi) untuk kegiatan luring sebelum detail dibuka; label juga muncul di Kegiatan Saya dan detail kegiatan. Nama tempat yang panjang dapat membungkus ke baris berikutnya agar tetap terbaca.
- Kegiatan online menampilkan keterangan tautan dibagikan H-1 melalui Kegiatan Saya, tanpa tempat atau ruangan. Kegiatan offline tetap menampilkan lokasi fisik.
- Detail kegiatan dengan informasi pelaksanaan, jadwal per hari, narasumber, manfaat, kuota, serta dialog konfirmasi dan hasil pendaftaran. Kegiatan dapat berlangsung beberapa hari.
- Kegiatan Saya dengan tab Akan Datang, Berlangsung, dan Selesai.
- Presensi dicatat terpisah untuk setiap hari kegiatan. Kegiatan offline memakai simulasi QR; kegiatan online memakai pemilih file screenshot PNG/JPG maksimal 5 MB, pratinjau gambar, dan status Menunggu Verifikasi. Pengiriman satu hari tidak mengubah hari lain dan tidak dapat dikirim ulang.
- Coba **Bootcamp Keterampilan Digital** pada Kegiatan Saya → Berlangsung untuk alur online tiga hari. Hari pertama dan kedua masih dibuka panitia; hari ketiga belum dibuka. Workshop Data Science mencontohkan kegiatan offline dua hari.
- Daftar, pratinjau, dan formulir perbaikan sertifikat.
- Notifikasi dengan penanda belum dibaca dan aksi tandai semua dibaca.
- Profil, edit data, konfirmasi keluar, dan akses diagnostik server.

## Data contoh dan integrasi

Tanggal, isi kegiatan, identitas peserta contoh, dan gambar mengikuti Figma. Tahun 2025 dipertahankan sebagai isi prototipe, bukan jadwal kegiatan aktual.

State pratinjau dikelola oleh `lib/core/demo/preview_data.dart` menggunakan Riverpod. Login tidak melakukan autentikasi server atau membuat token. Pendaftaran akun/kegiatan, perubahan profil, presensi, dan pengajuan perbaikan hanya mendemonstrasikan alur UI. State kembali ke data awal saat keluar atau aplikasi dimulai ulang.

Pemindaian offline tidak mengakses kamera/GPS. Pemilih screenshot online membuka file yang dipilih pengguna, memvalidasi tipe/ukuran serta keterbacaan gambar, dan menyimpan bukti hanya di memori pratinjau; file belum diunggah ke server atau diperiksa panitia. Tautan pertemuan belum disediakan dalam data contoh; keterangan H-1 menjelaskan waktu pembagiannya. Jadwal memakai status sesi contoh (dibuka/belum dibuka/ditutup), bukan tanggal perangkat. Sertifikat diberi penanda pratinjau; tombol unduh menjelaskan bahwa dokumen resmi belum tersedia. Tidak ada PDF resmi atau tanda tangan elektronik yang dibuat. Integrasi API, SSO UNAND, kamera/GPS, penyimpanan bukti dan verifikasi panitia, unduhan resmi, dan penyimpanan permanen tetap memerlukan implementasi backend terkait. Diagnostik `/health` tetap memakai layanan API yang sudah ada.

Inter dimuat dari aset lokal dengan lisensi OFL di `assets/fonts/OFL.txt`; foto memakai aset Unsplash yang sama dengan referensi. Logo UNAND memakai gambar yang diberikan pengguna di `assets/images/unand-logo.png`, termasuk logo header, pratinjau sertifikat, dan ikon browser.

## Pemeriksaan

```powershell
flutter test
```

Pengujian mencakup validasi formulir, pencarian/filter, pembatalan dan konfirmasi pendaftaran, larangan duplikasi/kuota penuh, navigasi, perubahan profil, notifikasi, presensi, pengajuan koreksi, logout, serta tata letak 320 px dan pembesaran teks.
