# System Design Document (DESIGN.md)
**Proyek:** Aplikasi Manajemen Tugas "MyPlan"

## 1. Arsitektur Sistem & Pemilihan Teknologi (Tech Stack)
Untuk memastikan aplikasi berjalan responsif, mudah dikelola, dan mendukung sinkronisasi secara instan, pengembangan MyPlan akan menggunakan arsitektur *client-server* berikut:

*   **Frontend (Aplikasi Mobile):** Flutter. Dipilih untuk membangun antarmuka yang mulus di Android dan iOS dengan satu basis kode, serta sangat mendukung pembuatan animasi kustom (untuk fitur gamifikasi/tanaman virtual).
*   **Backend (API & Logika Bisnis):** NestJS. Framework Node.js yang modular dan terstruktur, ideal untuk menangani logika kompleks seperti kalkulasi *streak* dan manajemen pengguna.
*   **Basis Data:** PostgreSQL (relasional untuk menyimpan data pengguna, tugas, dan sub-tugas) dikombinasikan dengan Redis (untuk *caching* cepat dan pelacakan sesi *real-time*).
*   **Infrastruktur & CI/CD (Deployment):** Aplikasi akan dikemas menggunakan Docker dan Docker Compose. Alur otomatisasi (CI/CD) akan dikelola oleh GitHub Actions, menyimpan *image* di GitHub Container Registry (GHCR), lalu di-*deploy* secara mulus ke *Virtual Private Server* (VPS) menggunakan Coolify.

## 2. Panduan UI/UX (Design System)
Berdasarkan pendekatan psikologi produktivitas di PRD, desain visual MyPlan akan berfokus pada reduksi beban kognitif dengan palet warna yang menenangkan:

*   **Palet Warna Utama (Primary & Background):** 
    *   **Primary Green:** `#A8D5BA` (Hijau pastel lembut yang melambangkan pertumbuhan organik pada fitur tanaman virtual dan memberikan efek psikologis menenangkan).
    *   **Background White:** `#FAFAFA` (Putih tulang untuk latar belakang utama aplikasi, menciptakan ruang kosong/whitespace yang bersih).
    *   **Surface Gray:** `#F3F4F6` (Abu-abu sangat terang untuk membedakan kartu tugas atau modal *bottom sheet* dari latar belakang tanpa kontras yang mencolok).
*   **Palet Warna Aksen (Task Labels & Interactive Elements):**
    *   **High Focus Accent:** `#4A90E2` (Biru lembut namun tegas, digunakan untuk label tugas "Fokus Tinggi" atau tombol aksi utama).
    *   **Relaxed Accent:** `#F5CA5C` (Kuning pastel hangat, digunakan untuk label tugas "Santai" atau elemen peringatan yang tidak mengintimidasi).
    *   **Text Primary:** `#333333` (Abu-abu gelap pekat, bukan hitam murni, agar teks lebih nyaman dibaca dan tidak membuat mata cepat lelah).
*   **Tipografi:** Sans-serif yang bersih dan modern (seperti Inter atau Roboto) dengan hierarki visual yang jelas.
*   **Elemen Visual:** Sudut membulat (*rounded corners*, radius sekitar `12px` hingga `16px`) pada kartu tugas untuk kesan ramah dan tidak kaku. *Progress bar* akan menggunakan animasi transisi yang halus.

## 3. Skema Basis Data (Entity Relationship Diagram)

Berikut adalah struktur basis data relasional untuk mengelola pengguna, tugas, dan elemen gamifikasi.

```mermaid
erDiagram
    USERS ||--o{ TASKS : creates
    USERS ||--|| GAMIFICATION : has
    TASKS ||--o{ SUBTASKS : contains

    USERS {
        uuid id PK
        string nama
        string email
        string password_hash
        datetime created_at
    }

    TASKS {
        uuid id PK
        uuid user_id FK
        string judul
        string deskripsi
        enum energy_label "Fokus Tinggi, Sedang, Santai"
        date deadline
        boolean is_completed
        datetime created_at
    }

    SUBTASKS {
        uuid id PK
        uuid task_id FK
        string judul
        boolean is_completed
    }

    GAMIFICATION {
        uuid id PK
        uuid user_id FK
        int current_streak
        int highest_streak
        int plant_level
        date last_active_date
    }
