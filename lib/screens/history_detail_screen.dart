import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/time_slots.dart';
import '../models/history.dart';
import '../models/schedule.dart';
import '../services/pdf_service.dart';
import '../widgets/neo_button.dart';
import '../widgets/schedule_card.dart';

/// Halaman detail satu riwayat generate
class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.history});

  final History history;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
        .format(history.generatedAt);

    // Group schedules by day
    final grouped = <String, List<Schedule>>{};
    for (final day in TimeSlots.activeDays) {
      final daySchedules = history.schedules
          .where((s) => s.day == day)
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      if (daySchedules.isNotEmpty) {
        grouped[day] = daySchedules;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Detail Riwayat'),
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // ── Metadata ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined,
                        color: AppColors.textMuted, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Stats
                Row(
                  children: [
                    _statChip('${history.lecturerCount}', 'Dosen',
                        AppColors.neonLime),
                    const SizedBox(width: 8),
                    _statChip('${history.courseCount}', 'Mata Kuliah',
                        AppColors.electricBlue),
                    const SizedBox(width: 8),
                    _statChip('${history.scheduleCount}', 'Jadwal',
                        AppColors.purple),
                  ],
                ),
                const SizedBox(height: 16),

                // Export button
                NeoButton(
                  label: 'Export PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  color: AppColors.neonOrange,
                  textColor: AppColors.white,
                  width: double.infinity,
                  height: 48,
                  onPressed: () => _exportPdf(context),
                ),
              ],
            ),
          ),

          // ── Schedule List ─────────────────────────────────────────────
          Expanded(
            child: grouped.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada jadwal',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
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
                                        color: AppColors.neonLime
                                            .withOpacity(0.4),
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

                          ...daySchedules
                              .map((s) => ScheduleCard(schedule: s)),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25), width: 1),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                )),
            Text(label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    try {
      await PdfService.instance.exportHistory(history);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export gagal: $e')),
        );
      }
    }
  }
}
