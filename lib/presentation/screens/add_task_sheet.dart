import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/energy_level.dart';
import '../../data/models/subtask_model.dart';
import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';

class AddTaskSheet extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskSheet({super.key, this.taskToEdit});

  static Future<void> show(BuildContext context, {Task? taskToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskSheet(taskToEdit: taskToEdit),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _uuid = const Uuid();
  late TextEditingController _titleController;
  late TextEditingController _intentionController;
  late TextEditingController _subtaskInputController;

  EnergyLevel _selectedEnergy = EnergyLevel.high;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  int _durationMinutes = 45;
  bool _gentleReminder = true;
  List<Subtask> _subtasks = [];
  bool _isAddingSubtask = false;

  @override
  void initState() {
    super.initState();
    final edit = widget.taskToEdit;
    if (edit != null) {
      _titleController = TextEditingController(text: edit.title);
      _intentionController = TextEditingController(text: edit.intention);
      _selectedEnergy = edit.energyLevel;
      _selectedDate = edit.deadline;
      _durationMinutes = edit.durationMinutes;
      _gentleReminder = edit.gentleReminder;
      _subtasks = List.from(edit.subtasks);
      final parts = edit.targetTime.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 14;
        final m = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        _selectedTime = TimeOfDay(hour: h, minute: m);
      }
    } else {
      _titleController = TextEditingController(
          text: 'Menyusun Pembahasan Bab 2 Kajian Teori');
      _intentionController = TextEditingController();
      _subtasks = [
        Subtask(
          id: _uuid.v4(),
          taskId: 'temp',
          title: 'Cari 3 jurnal referensi pendukung di Google Scholar',
          isCompleted: true,
        ),
        Subtask(
          id: _uuid.v4(),
          taskId: 'temp',
          title: 'Buat kerangka 4 poin pembahasan utama',
          isCompleted: false,
        ),
        Subtask(
          id: _uuid.v4(),
          taskId: 'temp',
          title: 'Tulis draf paragraf pengantar teori (min. 150 kata)',
          isCompleted: false,
        ),
      ];
    }
    _subtaskInputController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _intentionController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  int get _completedSubtasksCount =>
      _subtasks.where((s) => s.isCompleted).length;

  double get _subtaskProgressRatio => _subtasks.isEmpty
      ? 0.0
      : (_completedSubtasksCount / _subtasks.length).clamp(0.0, 1.0);

  String _formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  void _handleAddSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(
          Subtask(
            id: _uuid.v4(),
            taskId: widget.taskToEdit?.id ?? 'temp',
            title: text,
            isCompleted: false,
          ),
        );
        _subtaskInputController.clear();
        _isAddingSubtask = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showDurationPicker() {
    final options = [15, 25, 30, 45, 60, 90, 120];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estimasi Durasi Sesi Fokus',
                  style: AppTypography.headlineSm),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((dur) {
                  final isSel = _durationMinutes == dur;
                  final blocks = (dur / 25).round().clamp(1, 4);
                  return ChoiceChip(
                    label: Text('$dur Menit ($blocks Blok Fokus)'),
                    selected: isSel,
                    selectedColor: AppColors.primaryContainer,
                    onSelected: (val) {
                      setState(() {
                        _durationMinutes = dur;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tugas tidak boleh kosong'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = context.read<TaskProvider>();
    final isEditing = widget.taskToEdit != null;
    final taskId = widget.taskToEdit?.id ?? _uuid.v4();

    // Map subtasks with actual taskId
    final finalSubtasks = _subtasks
        .map((s) => s.copyWith(taskId: taskId))
        .toList();

    final task = Task(
      id: taskId,
      title: title,
      intention: _intentionController.text.trim(),
      energyLevel: _selectedEnergy,
      deadline: _selectedDate,
      targetTime: _formatTimeOfDay(_selectedTime),
      durationMinutes: _durationMinutes,
      gentleReminder: _gentleReminder,
      isCompleted: widget.taskToEdit?.isCompleted ?? false,
      createdAt: widget.taskToEdit?.createdAt ?? DateTime.now(),
      subtasks: finalSubtasks,
    );

    if (isEditing) {
      provider.updateTask(task);
    } else {
      provider.addTask(task);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isEditing
                    ? 'Perubahan tugas berhasil disimpan!'
                    : 'Tugas tersimpan! Kebunmu mendapatkan +25 XP 🌱',
                style: AppTypography.bodyMd.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final isTodaySelected = DateFormatter.isSameDay(_selectedDate, today);
    final isTomorrowSelected = DateFormatter.isSameDay(_selectedDate, tomorrow);

    final blocksCount = (_durationMinutes / 25).round().clamp(1, 5);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab Handle
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header Modal
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_note,
                            size: 20,
                            color: AppColors.onPrimaryFixedVariant,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.taskToEdit != null
                                    ? 'Ubah Tugas'
                                    : 'Tambah Tugas Baru',
                                style: AppTypography.headlineSm.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Rencanakan tugasmu dengan sadar, tenang, dan tanpa terburu-buru.',
                                style: AppTypography.bodySm,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLow,
                      foregroundColor: AppColors.onSurfaceVariant,
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Micro-Mindfulness / Intention Mood Check
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primaryContainer.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.self_improvement,
                        size: 18,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NIAT HARI INI',
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          TextField(
                            controller: _intentionController,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurface,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText:
                                  'Apa tujuan positif dari menyelesaikan tugas ini?',
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Form Section: Task Title
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Text('Nama Tugas', style: AppTypography.labelLg),
                    Text(
                      'Langkah Awal',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                maxLines: 2,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText:
                      'cth: Menyusun Bab 2 Skripsi atau Laporan Keuangan Mingguan...',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Core Psychology Feature: Mental Energy Rating
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  const Text('Tingkat Energi Diperlukan',
                      style: AppTypography.labelLg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.highFocusContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Bio-ritme',
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onHighFocusContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const Text(
                'Sesuaikan tugas dengan kapasitas mental & ritme otakmu saat ini.',
                style: AppTypography.bodySm,
              ),
              const SizedBox(height: 10),

              // 3 Energy Selector Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 360) {
                    return Column(
                      children: [
                        _buildEnergyCard(
                          level: EnergyLevel.high,
                          label: 'Fokus Tinggi',
                          desc: 'Deep Work pekat, butuh konsentrasi pekat & tanpa distraksi.',
                          icon: Icons.bolt,
                          accentColor: AppColors.highFocus,
                          bgActiveColor: AppColors.highFocusContainerLight,
                        ),
                        const SizedBox(height: 8),
                        _buildEnergyCard(
                          level: EnergyLevel.medium,
                          label: 'Sedang',
                          desc: 'Aktivitas teratur dengan ritme kerja santai & dinamis.',
                          icon: Icons.balance,
                          accentColor: AppColors.onSurface,
                          bgActiveColor: AppColors.surfaceContainer,
                        ),
                        const SizedBox(height: 8),
                        _buildEnergyCard(
                          level: EnergyLevel.relaxed,
                          label: 'Santai',
                          desc: 'Tugas ringan, administratif, & minim beban kognitif.',
                          icon: Icons.spa,
                          accentColor: AppColors.relaxed,
                          bgActiveColor: AppColors.relaxedContainerLight,
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: _buildEnergyCard(
                          level: EnergyLevel.high,
                          label: 'Fokus Tinggi',
                          desc: 'Deep Work pekat.',
                          icon: Icons.bolt,
                          accentColor: AppColors.highFocus,
                          bgActiveColor: AppColors.highFocusContainerLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildEnergyCard(
                          level: EnergyLevel.medium,
                          label: 'Sedang',
                          desc: 'Ritme dinamis.',
                          icon: Icons.balance,
                          accentColor: AppColors.onSurface,
                          bgActiveColor: AppColors.surfaceContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildEnergyCard(
                          level: EnergyLevel.relaxed,
                          label: 'Santai',
                          desc: 'Tugas ringan.',
                          icon: Icons.spa,
                          accentColor: AppColors.relaxed,
                          bgActiveColor: AppColors.relaxedContainerLight,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Psychology Breakdown Feature: Micro-steps (Sub-tugas)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            const Text('Pecah Jadi Langkah Mikro',
                                style: AppTypography.labelLg),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.psychology,
                                      size: 13,
                                      color: AppColors.onPrimaryContainer),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Rekomendasi',
                                    style: AppTypography.labelSm.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$_completedSubtasksCount dari ${_subtasks.length} selesai',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tugas rumit terasa jauh lebih bersahabat saat diurai jadi tindakan 5-10 menit.',
                      style: AppTypography.bodySm,
                    ),
                    const SizedBox(height: 8),

                    // Tactile progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 5,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Container(color: AppColors.surfaceContainerHighest),
                            FractionallySizedBox(
                              widthFactor: _subtaskProgressRatio,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtasks checklist items
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subtasks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final sub = _subtasks[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _subtasks[index] = sub.copyWith(
                                      isCompleted: !sub.isCompleted,
                                    );
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: sub.isCompleted
                                        ? AppColors.primary
                                        : AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: sub.isCompleted
                                      ? const Icon(Icons.check,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  sub.title,
                                  style: AppTypography.bodySm.copyWith(
                                    color: sub.isCompleted
                                        ? AppColors.textMuted
                                        : AppColors.onSurface,
                                    decoration: sub.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                color: AppColors.outlineVariant,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    _subtasks.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // Add Subtask button / inline field
                    if (_isAddingSubtask)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subtaskInputController,
                              autofocus: true,
                              style: AppTypography.bodySm,
                              decoration: InputDecoration(
                                hintText: 'Ketik langkah mikro baru...',
                                fillColor: AppColors.surfaceRaised,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (_) => _handleAddSubtask(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check,
                                color: AppColors.primary),
                            onPressed: _handleAddSubtask,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.outline),
                            onPressed: () {
                              setState(() {
                                _isAddingSubtask = false;
                                _subtaskInputController.clear();
                              });
                            },
                          ),
                        ],
                      )
                    else
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isAddingSubtask = true;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_circle,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Tambah langkah mikro berikutnya...',
                                  style: AppTypography.labelMd.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Scheduling & Time Anchoring
              const Text('Jadwal & Waktu Fokus', style: AppTypography.labelLg),
              const SizedBox(height: 10),

              // Date Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildDatePill(
                      label: 'Hari Ini (${DateFormatter.formatRelativeDate(today)})',
                      icon: Icons.today,
                      isSelected: isTodaySelected,
                      onTap: () => setState(() => _selectedDate = today),
                    ),
                    const SizedBox(width: 8),
                    _buildDatePill(
                      label: 'Besok (${DateFormatter.formatRelativeDate(tomorrow)})',
                      isSelected: isTomorrowSelected,
                      onTap: () => setState(() => _selectedDate = tomorrow),
                    ),
                    const SizedBox(width: 8),
                    _buildDatePill(
                      label: !isTodaySelected && !isTomorrowSelected
                          ? DateFormatter.formatMediumDate(_selectedDate)
                          : 'Pilih Tanggal',
                      icon: Icons.event,
                      isSelected: !isTodaySelected && !isTomorrowSelected,
                      onTap: _pickDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Time & Duration Estimator
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 340;
                  final timeTile = InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.schedule,
                                size: 18, color: AppColors.onSurface),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TARGET MULAI',
                                  style: AppTypography.labelSm.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTimeOfDay(_selectedTime),
                                  style: AppTypography.labelLg.copyWith(
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  final durationTile = InkWell(
                    onTap: _showDurationPicker,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.timer,
                                size: 18, color: AppColors.relaxed),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ESTIMASI DURASI',
                                  style: AppTypography.labelSm.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$_durationMinutes Mnt ($blocksCount Blok)',
                                  style: AppTypography.labelLg.copyWith(
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        timeTile,
                        const SizedBox(height: 8),
                        durationTile,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: timeTile),
                      const SizedBox(width: 10),
                      Expanded(child: durationTile),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),

              // Gentle Reminder Toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      size: 20,
                      color: AppColors.highFocus,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pengingat Lembut',
                              style: AppTypography.labelMd),
                          Text(
                            'Notifikasi dengan alunan chime yang menenangkan',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _gentleReminder,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primaryContainer,
                      onChanged: (val) {
                        setState(() {
                          _gentleReminder = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Gamification & Habit Plant Streak Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_florist,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                'Pertumbuhan Kebun Tenang',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onPrimaryFixedVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '+25 XP',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tugas ini akan memberi nutrisi pada daun baru Monstera Sejuk milikmu!',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 11,
                              color: AppColors.onPrimaryFixedVariant
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bottom Action CTAs
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 420;
                  final saveBtn = SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveTask,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: Text(
                        widget.taskToEdit != null
                            ? 'Simpan Perubahan'
                            : 'Simpan Tugas (+25 XP)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  );

                  final cancelBtn = SizedBox(
                    width: isNarrow ? double.infinity : null,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        backgroundColor: AppColors.surfaceContainerLow,
                        foregroundColor: AppColors.onSurfaceVariant,
                      ),
                      child: const Text('Batal'),
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        saveBtn,
                        const SizedBox(height: 8),
                        cancelBtn,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: saveBtn),
                      const SizedBox(width: 10),
                      cancelBtn,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyCard({
    required EnergyLevel level,
    required String label,
    required String desc,
    required IconData icon,
    required Color accentColor,
    required Color bgActiveColor,
  }) {
    final isSelected = _selectedEnergy == level;

    return InkWell(
      onTap: () => setState(() => _selectedEnergy = level),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minHeight: 88),
        decoration: BoxDecoration(
          color: isSelected ? bgActiveColor : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 18, color: accentColor),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : AppColors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 11, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? accentColor : AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: AppTypography.bodySm.copyWith(
                fontSize: 10,
                color: AppColors.textMuted,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePill({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: isSelected
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
