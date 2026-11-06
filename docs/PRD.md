# Product Requirements Document (PRD)
**Judul Proyek:** Perancangan Aplikasi Manajemen Tugas "MyPlan" Berbasis Mobile dengan Pendekatan Psikologi Produktivitas

## 1. Latar Belakang
Manajemen waktu dan tugas sering kali menjadi tantangan utama bagi mahasiswa maupun profesional. Banyak aplikasi *to-do list* yang tersedia saat ini hanya berfokus pada pencatatan tugas, yang sering kali justru memicu beban kognitif (rasa kewalahan) ketika pengguna melihat daftar pekerjaan yang panjang. Oleh karena itu, diperlukan sebuah aplikasi yang tidak hanya mencatat jadwal, tetapi juga membantu pengguna mengelola energi mental mereka melalui antarmuka yang minimalis dan fitur yang memotivasi. "MyPlan" hadir sebagai solusi manajemen tugas harian yang lebih cerdas dan ramah psikologis.

## 2. Tujuan Proyek
* Membangun aplikasi manajemen tugas "MyPlan" yang mengoptimalkan produktivitas harian pengguna.
* Mengurangi beban kognitif pengguna melalui desain antarmuka (User Interface) yang bersih dan minimalis.
* Membantu pengguna mempertahankan konsistensi dan fokus melalui sistem gamifikasi.

## 3. Target Pengguna
Mahasiswa, pekerja lepas (*freelancer*), dan profesional muda yang membutuhkan alat bantu perencanaan harian yang praktis, cepat, dan tidak mengintimidasi.

## 4. Fitur Unggulan (Core Features)
Aplikasi MyPlan memiliki keunggulan dibandingkan aplikasi serupa di pasaran melalui fitur-fitur berikut:
* **Kategorisasi Berbasis Energi:** Fitur pelabelan tugas berdasarkan tingkat konsentrasi yang dibutuhkan (misalnya: Fokus Tinggi, atau Santai), sehingga pengguna dapat menyesuaikan pekerjaan dengan kondisi fisik dan mental mereka.
* **Visualisasi Progres (Sub-tugas):** Fitur pemecahan tugas kompleks menjadi langkah-langkah kecil yang dilengkapi dengan indikator persentase (*progress bar*).
* **Sistem Gamifikasi:** Implementasi elemen visual seperti "Streak Harian" (runtutan hari produktif) atau "Tanaman Virtual" yang tumbuh setiap kali target harian tercapai untuk menjaga motivasi.
* **Ruang Kosong Bebas Distraksi:** Optimalisasi *whitespace* pada desain UI untuk memusatkan fokus pengguna pada tugas hari ini (My Day).

## 5. Struktur Antarmuka (User Interface)
Aplikasi MyPlan dirancang dengan 5 layar utama yang saling berkesinambungan:
1. **Beranda (My Day):** Menampilkan sapaan personal, widget gamifikasi, dan daftar tugas hari ini dengan kartu tugas yang interaktif.
2. **Halaman Tambah Tugas (Modal/Bottom Sheet):** Formulir cepat untuk memasukkan nama tugas, memilih label energi, dan menetapkan tanggal.
3. **Halaman Detail Tugas:** Menampilkan rincian tugas utama, daftar sub-tugas yang bisa dicentang, dan catatan tambahan.
4. **Halaman Kalender:** Menampilkan tinjauan jadwal mingguan atau bulanan dengan blok waktu (*timeline*).
5. **Halaman Profil & Statistik:** Menampilkan pencapaian pengguna, grafik produktivitas mingguan, dan jam fokus.

## 6. Alur Penggunaan Aplikasi (User Flow)

Berikut adalah diagram visual yang menggambarkan interaksi utama pengguna dari awal membuka aplikasi hingga menyelesaikan tugas dan melihat statistik.

```mermaid
graph TD
    A([Buka Aplikasi]) --> B{Pengguna Baru?}
    
    B -- Ya --> C[Onboarding & Registrasi]
    B -- Tidak --> D[Masuk / Login]
    
    C --> E[Beranda / My Day]
    D --> E
    
    E --> F[Lihat Sapaan & Widget Gamifikasi]
    E --> G[Lihat Daftar Tugas Hari Ini]
    
    %% Alur Tambah Tugas
    G --> H((Aksi: Tambah Tugas))
    H --> I[Buka Bottom Sheet Formulir]
    I --> J[Input Nama, Label Energi, Deadline]
    J --> |Simpan| E
    
    %% Alur Pengerjaan Tugas
    G --> K((Aksi: Kerjakan Tugas))
    K --> L[Buka Detail Tugas Utama]
    L --> M[Pecah & Centang Sub-tugas]
    
    M --> N{Semua Sub-tugas Selesai?}
    N -- Belum --> M
    N -- Ya --> O[Tugas Selesai]
    
    O --> P[Tampilkan Animasi Apresiasi]
    P --> Q[Update Gamifikasi: Tanaman Tumbuh & Streak Bertambah]
    Q --> E
    
    %% Navigasi Lain
    E --> R((Navigasi Menu Lain))
    R --> S[Buka Halaman Kalender]
    S --> |Tinjau/Ubah Jadwal| E
    
    R --> T[Buka Halaman Profil]
    T --> |Evaluasi Statistik Mingguan| E
