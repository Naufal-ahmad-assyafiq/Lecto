import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history.dart';
import '../services/storage_service.dart';

/// Notifier untuk manajemen riwayat generate
class HistoryNotifier extends StateNotifier<List<History>> {
  HistoryNotifier() : super([]) {
    reload();
  }

  final _storage = StorageService.instance;

  /// Muat ulang data dari Hive
  void reload() {
    state = _storage.getAllHistories();
  }

  /// Hapus satu riwayat
  Future<void> deleteHistory(String id) async {
    await _storage.deleteHistory(id);
    reload();
  }

  /// Hapus semua riwayat
  Future<void> clearAll() async {
    for (final h in state) {
      await _storage.deleteHistory(h.id);
    }
    reload();
  }
}

/// Provider global untuk riwayat
final historyProvider = StateNotifierProvider<HistoryNotifier, List<History>>(
  (ref) => HistoryNotifier(),
);
