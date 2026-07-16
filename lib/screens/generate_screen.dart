import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/time_slots.dart';
import '../models/schedule.dart';
import '../providers/lecturer_provider.dart';
import '../providers/room_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/history_provider.dart';
import '../services/pdf_service.dart';
import '../widgets/neo_button.dart';
import '../widgets/schedule_card.dart';

/// Halaman Generate Jadwal menggunakan Forward Chaining Engine
class GenerateScreen extends ConsumerStatefulWidget {
  const GenerateScreen({super.key});

  @override
  ConsumerState<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends ConsumerState<GenerateScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleProvider);
    final lecturers = ref.watch(lecturerProvider);
    final rooms = ref.watch(roomProvider);

    final canGenerate = lecturers.isNotEmpty &&
        lecturers.any((l) => l.courses.isNotEmpty) &&
        rooms.isNotEmpty;

    final isLoading = scheduleState.status == GenerateStatus.loading;
    final hasResult = scheduleState.schedules.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Generate Jadwal'),
        actions: [
          if (hasResult)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => _exportPDF(context),
                icon: const Icon(Icons.picture_as_pdf_outlined,
                    color: AppColors.neonLime, size: 20),
                label: const Text('Export PDF',
                    style: TextStyle(
                        color: AppColors.neonLime,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Generate Button Area ─────────────────────────────────────
          _buildGenerateArea(canGenerate, isLoading, hasResult),

          // ── Results ─────────────────────────────────────────────────
          if (hasResult)
            Expanded(
              child: _buildResults(scheduleState.schedules),
            ),

          // ── Error ───────────────────────────────────────────────────
          if (scheduleState.status == GenerateStatus.error &&
              scheduleState.errorMessage != null)
            _buildError(scheduleState.errorMessage!),

          // ── Empty state ─────────────────────────────────────────────
          if (!hasResult &&
              scheduleState.status != GenerateStatus.loading &&
              scheduleState.status != GenerateStatus.error)
            Expanded(child: _buildEmpty(canGenerate)),
        ],
      ),
    );
  }

  // ── Build Generate Area ──────────────────────────────────────────────────

  Widget _buildGenerateArea(
      bool canGenerate, bool isLoading, bool hasResult) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Validasi bar
          _buildValidationIndicators(),
          const SizedBox(height: 16),

          // Generate button
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) {
              return Transform.scale(
                scale: isLoading ? _pulse.value : 1.0,
                child: child,
              );
            },
            child: SizedBox(
              width: double.infinity,
              child: NeoButton(
                label: isLoading
                    ? 'Sedang Memproses...'
                    : hasResult
                        ? 'Generate Ulang'
                        : 'Generate Jadwal',
                icon: isLoading
                    ? Icons.hourglass_empty
                    : Icons.auto_fix_high_outlined,
                color: canGenerate
                    ? AppColors.neonLime
                    : AppColors.textMuted,
                textColor: AppColors.bgPrimary,
                height: 60,
                fontSize: 17,
                isLoading: isLoading,
                onPressed: canGenerate && !isLoading ? _generate : null,
              ),
            ),
          ),

          if (hasResult && !isLoading) ...[
            const SizedBox(height: 10),
            Text(
              '${ref.read(scheduleProvider).schedules.length} jadwal berhasil dibuat',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Validation Indicators ───────────────────────────────────────────────

  Widget _buildValidationIndicators() {
    final lecturers = ref.watch(lecturerProvider);
    final rooms = ref.watch(roomProvider);
    final hasCourses = lecturers.any((l) => l.courses.isNotEmpty);

    return Row(
      children: [
        _validChip('Dosen', lecturers.isNotEmpty, Icons.person_outline),
        const SizedBox(width: 8),
        _validChip('Mata Kuliah', hasCourses, Icons.book_outlined),
        const SizedBox(width: 8),
        _validChip('Ruangan', rooms.isNotEmpty, Icons.meeting_room_outlined),
      ],
    );
  }

  Widget _validChip(String label, bool valid, IconData icon) {
    final color = valid ? AppColors.success : AppColors.error;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              valid ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Results ─────────────────────────────────────────────────────────────

  Widget _buildResults(List<Schedule> schedules) {
    // Group by day
    final grouped = <String, List<Schedule>>{};
    for (final day in TimeSlots.activeDays) {
      final daySchedules = schedules.where((s) => s.day == day).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      if (daySchedules.isNotEmpty) {
        grouped[day] = daySchedules;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final day = grouped.keys.elementAt(i);
        final daySchedules = grouped[day]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neonLime.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.neonLime.withOpacity(0.4),
                          width: 1.5),
                    ),
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: AppColors.neonLime,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${daySchedules.length} jadwal',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            ...daySchedules.map((s) => ScheduleCard(schedule: s)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty(bool canGenerate) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: AppColors.textMuted.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            canGenerate
                ? 'Tekan Generate untuk membuat jadwal'
                : 'Lengkapi data terlebih dahulu',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            canGenerate
                ? 'Sistem akan menjadwalkan secara otomatis\nmenggunakan Forward Chaining'
                : 'Tambah dosen, mata kuliah, dan ruangan',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.error.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _generate() async {
    await ref.read(scheduleProvider.notifier).generate();
  }

  Future<void> _exportPDF(BuildContext context) async {
    final histories = ref.read(historyProvider);
    if (histories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada riwayat untuk diekspor'),
        ),
      );
      return;
    }
    try {
      await PdfService.instance.exportHistory(histories.first);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export gagal: $e')),
        );
      }
    }
  }
}
