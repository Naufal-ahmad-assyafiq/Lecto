// Session Manager — alur startup dan restore data

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/history_provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../providers/room_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../services/storage_service.dart';

/// Mengelola restore session saat startup.
class SessionManager {
  SessionManager._();

  static final _storage = StorageService.instance;

  /// Cek data lama dan tampilkan dialog restore jika perlu
  static Future<void> initialize(BuildContext context, WidgetRef ref) async {
    if (_storage.hasExistingData() && context.mounted) {
      await _showRestoreDialog(context, ref);
    }
  }

  static bool hasExistingSession() => _storage.hasExistingData();

  static Future<void> _showRestoreDialog(BuildContext context, WidgetRef ref) async {
    final choice = await showDialog<_SessionChoice>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _RestoreSessionDialog(),
    );

    if (!context.mounted) return;

    if (choice == _SessionChoice.startNew) {
      final confirmed = await _showConfirmClearDialog(context);
      if (confirmed == true && context.mounted) {
        await clearSession(ref);
      }
    }
  }

  static Future<bool?> _showConfirmClearDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.error, width: 2),
        ),
        title: const Text(
          'Hapus Semua Data?',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Seluruh data dosen, ruangan, jadwal, dan riwayat akan dihapus permanen.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Hapus Semua', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  /// Hapus semua data dan reset state Riverpod
  static Future<void> clearSession(WidgetRef ref) async {
    await _storage.clearAll();
    ref.read(lecturerProvider.notifier).reload();
    ref.read(roomProvider.notifier).reload();
    ref.read(scheduleProvider.notifier).reset();
    ref.read(historyProvider.notifier).reload();
  }

  /// Reload semua provider dari Hive
  static void restoreSession(WidgetRef ref) {
    ref.read(lecturerProvider.notifier).reload();
    ref.read(roomProvider.notifier).reload();
    ref.read(historyProvider.notifier).reload();
  }
}

enum _SessionChoice { continuePrevious, startNew }

/// Dialog restore data sesi sebelumnya
class _RestoreSessionDialog extends StatelessWidget {
  const _RestoreSessionDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 2),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.neonLime.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.neonLime.withOpacity(0.4)),
            ),
            child: const Icon(Icons.restore_outlined, color: AppColors.neonLime, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Data Sebelumnya\nDitemukan',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
      content: const Text(
        'Ditemukan data penggunaan sebelumnya.\n\n'
        'Apakah ingin melanjutkan data tersebut atau memulai data baru?',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context, _SessionChoice.startNew),
          icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
          label: const Text('Mulai Baru',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, _SessionChoice.continuePrevious),
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: const Text('Lanjutkan', style: TextStyle(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonLime,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ],
    );
  }
}
