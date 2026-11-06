import 'models/energy_level.dart';
import 'models/gamification_model.dart';
import 'models/subtask_model.dart';
import 'models/task_model.dart';
import 'models/user_model.dart';

class MockData {
  MockData._();

  static UserModel get initialUser => const UserModel(
        id: 'user_amanda_1',
        name: 'Amanda',
        email: 'amanda.mindful@myplan.app',
        title: 'Penanam Sadar (Mindful Planter)',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        focusHoursThisWeek: 18.5,
        enableGentleReminders: true,
        reminderSound: 'Alunan Chime Lembut',
      );

  static GamificationModel get initialGamification {
    final now = DateTime.now();
    return GamificationModel(
      id: 'game_amanda_1',
      userId: 'user_amanda_1',
      currentStreak: 7,
      highestStreak: 14,
      plantLevel: 3,
      plantName: 'Monstera Sejuk',
      currentXp: 120,
      xpNeededForNextLevel: 240,
      lastWateredDate: null,
      lastActiveDate: now,
      completedTasksCount: 8,
    );
  }

  static List<Task> get initialTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    return [
      Task(
        id: 'task_1',
        title: 'Selesaikan Laporan Metodologi Penelitian',
        intention:
            'Menyelesaikan analisis bab metodologi agar siap diajukan ke pembimbing.',
        energyLevel: EnergyLevel.high,
        deadline: today,
        targetTime: '14:00 WIB',
        durationMinutes: 45,
        gentleReminder: true,
        isCompleted: false,
        createdAt: today.subtract(const Duration(hours: 4)),
        subtasks: const [
          Subtask(
            id: 'sub_1_1',
            taskId: 'task_1',
            title: 'Tinjau kembali perumusan hipotesis',
            isCompleted: true,
          ),
          Subtask(
            id: 'sub_1_2',
            taskId: 'task_1',
            title: 'Buat diagram alur pengumpulan data',
            isCompleted: true,
          ),
          Subtask(
            id: 'sub_1_3',
            taskId: 'task_1',
            title: 'Tulis draf simpulan bab metodologi',
            isCompleted: false,
          ),
        ],
      ),
      Task(
        id: 'task_2',
        title: 'Review Desain Mockup User Flow MyPlan',
        intention:
            'Memastikan antarmuka ramah kognitif dan bebas distraksi bagi pengguna.',
        energyLevel: EnergyLevel.high,
        deadline: today,
        targetTime: '16:30 WIB',
        durationMinutes: 30,
        gentleReminder: true,
        isCompleted: false,
        createdAt: today.subtract(const Duration(hours: 3)),
        subtasks: const [
          Subtask(
            id: 'sub_2_1',
            taskId: 'task_2',
            title: 'Periksa kontras warna palet primer sage',
            isCompleted: true,
          ),
          Subtask(
            id: 'sub_2_2',
            taskId: 'task_2',
            title: 'Uji transisi modal bottom sheet',
            isCompleted: false,
          ),
          Subtask(
            id: 'sub_2_3',
            taskId: 'task_2',
            title: 'Cek layout responsive pada layar mobile',
            isCompleted: false,
          ),
          Subtask(
            id: 'sub_2_4',
            taskId: 'task_2',
            title: 'Verifikasi micro-interaction siram tanaman',
            isCompleted: false,
          ),
        ],
      ),
      Task(
        id: 'task_3',
        title: 'Brainstorming Ide Kampanye Media Sosial',
        intention:
            'Menyusun pesan komunikasi psikologi produktivitas yang menyejukkan.',
        energyLevel: EnergyLevel.medium,
        deadline: today,
        targetTime: '19:00 WIB',
        durationMinutes: 40,
        gentleReminder: true,
        isCompleted: false,
        createdAt: today.subtract(const Duration(hours: 2)),
        subtasks: const [
          Subtask(
            id: 'sub_3_1',
            taskId: 'task_3',
            title: 'Riset topik tren mindful living minggu ini',
            isCompleted: false,
          ),
          Subtask(
            id: 'sub_3_2',
            taskId: 'task_3',
            title: 'Buat draf 3 postingan edukasi micro-habits',
            isCompleted: false,
          ),
        ],
      ),
      Task(
        id: 'task_4',
        title: 'Membaca 1 Bab Buku Psikologi Kognitif',
        intention: 'Memperkaya wawasan mengenai pemulihan energi mental.',
        energyLevel: EnergyLevel.relaxed,
        deadline: today,
        targetTime: '21:00 WIB',
        durationMinutes: 25,
        gentleReminder: false,
        isCompleted: true,
        createdAt: today.subtract(const Duration(hours: 1)),
        subtasks: const [
          Subtask(
            id: 'sub_4_1',
            taskId: 'task_4',
            title: 'Meringkas 3 poin penting tentang kelelahan keputusan',
            isCompleted: true,
          ),
        ],
      ),
      // Tomorrow tasks
      Task(
        id: 'task_5',
        title: 'Penyusunan Anggaran & Alokasi Kuartal Baru',
        intention: 'Mengatur alur finansial proyek dengan transparan & tenang.',
        energyLevel: EnergyLevel.high,
        deadline: tomorrow,
        targetTime: '10:00 WIB',
        durationMinutes: 60,
        gentleReminder: true,
        isCompleted: false,
        createdAt: today,
        subtasks: const [
          Subtask(
            id: 'sub_5_1',
            taskId: 'task_5',
            title: 'Hitung pengeluaran operasional bulan lalu',
            isCompleted: false,
          ),
          Subtask(
            id: 'sub_5_2',
            taskId: 'task_5',
            title: 'Proyeksikan kebutuhan lisensi perangkat lunak',
            isCompleted: false,
          ),
        ],
      ),
      Task(
        id: 'task_6',
        title: 'Latihan Meditasi & Pernapasan 15 Menit',
        intention: 'Menjaga ketenangan batin sebelum istirahat malam.',
        energyLevel: EnergyLevel.relaxed,
        deadline: tomorrow,
        targetTime: '20:30 WIB',
        durationMinutes: 15,
        gentleReminder: true,
        isCompleted: false,
        createdAt: today,
        subtasks: const [
          Subtask(
            id: 'sub_6_1',
            taskId: 'task_6',
            title: 'Teknik 4-7-8 deep breathing',
            isCompleted: false,
          ),
        ],
      ),
      // Yesterday completed task
      Task(
        id: 'task_7',
        title: 'Diskusi Sesi Refleksi Mingguan dengan Tim',
        intention: 'Mendengarkan masukan dan menyelaraskan ritme kerja tim.',
        energyLevel: EnergyLevel.medium,
        deadline: yesterday,
        targetTime: '15:00 WIB',
        durationMinutes: 45,
        gentleReminder: false,
        isCompleted: true,
        createdAt: yesterday.subtract(const Duration(hours: 3)),
        subtasks: const [
          Subtask(
            id: 'sub_7_1',
            taskId: 'task_7',
            title: 'Catat poin tantangan utama minggu ini',
            isCompleted: true,
          ),
          Subtask(
            id: 'sub_7_2',
            taskId: 'task_7',
            title: 'Apresiasi pencapaian setiap anggota tim',
            isCompleted: true,
          ),
        ],
      ),
    ];
  }
}
