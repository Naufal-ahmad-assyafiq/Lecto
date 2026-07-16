import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../models/history.dart';
import '../providers/history_provider.dart';
import 'history_detail_screen.dart';

/// Halaman Riwayat Generate Jadwal
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          if (histories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => _confirmClearAll(context, ref),
                icon: const Icon(Icons.delete_sweep_outlined,
                    color: AppColors.error, size: 20),
                label: const Text('Hapus Semua',
                    style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ),
        ],
      ),
      body: histories.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: histories.length,
              itemBuilder: (_, i) {
                return _HistoryCard(
                  history: histories[i],
                  index: i,
                  onDelete: () => _confirmDelete(context, ref, histories[i]),
                  onView: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HistoryDetailScreen(history: histories[i]),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history,
              size: 64, color: AppColors.textMuted.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada riwayat',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate jadwal untuk melihat riwayat di sini',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, History h) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 2),
        ),
        title: const Text('Hapus Riwayat?',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text('Riwayat generate ini akan dihapus.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(historyProvider.notifier).deleteHistory(h.id);
    }
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 2),
        ),
        title: const Text('Hapus Semua Riwayat?',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text('Semua riwayat generate akan dihapus permanen.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus Semua',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(historyProvider.notifier).clearAll();
    }
  }
}

// ─── History Card ─────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.history,
    required this.index,
    required this.onDelete,
    required this.onView,
  });

  final History history;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy', 'id_ID').format(history.generatedAt);
    final timeStr = DateFormat('HH:mm').format(history.generatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.neoBrutalCard(
        borderColor: AppColors.border,
        shadowOffset: 3,
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon riwayat
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.electricBlue.withOpacity(0.3),
                        width: 1.5),
                  ),
                  child: const Icon(Icons.history,
                      color: AppColors.electricBlue, size: 22),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate #${index + 1}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '$dateStr · $timeStr',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats row
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('${history.lecturerCount}', 'Dosen',
                    AppColors.neonLime),
                _divider(),
                _statItem('${history.courseCount}', 'Mata Kuliah',
                    AppColors.electricBlue),
                _divider(),
                _statItem('${history.scheduleCount}', 'Jadwal',
                    AppColors.purple),
              ],
            ),
          ),

          // Actions
          const Divider(height: 1, color: AppColors.border),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined,
                      size: 16, color: AppColors.electricBlue),
                  label: const Text('Lihat Detail',
                      style: TextStyle(
                          color: AppColors.electricBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ),
              Container(
                  width: 1, height: 36, color: AppColors.border),
              Expanded(
                child: TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: AppColors.error),
                  label: const Text('Hapus',
                      style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
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
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.border,
    );
  }
}
