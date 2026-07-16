import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history.dart';
import '../models/schedule.dart';
import '../core/forward_chaining/forward_chaining_engine.dart';
import '../services/storage_service.dart';
import 'history_provider.dart';

/// State generate jadwal
enum GenerateStatus { idle, loading, success, error }

class ScheduleState {
  final List<Schedule> schedules;
  final GenerateStatus status;
  final String? errorMessage;

  const ScheduleState({
    this.schedules = const [],
    this.status = GenerateStatus.idle,
    this.errorMessage,
  });

  ScheduleState copyWith({
    List<Schedule>? schedules,
    GenerateStatus? status,
    String? errorMessage,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier untuk generate jadwal menggunakan Forward Chaining Engine
class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier(this._ref) : super(const ScheduleState()) {
    _loadFromStorage();
  }

  final Ref _ref;
  final _storage = StorageService.instance;
  final _engine = ForwardChainingEngine();

  void _loadFromStorage() {
    final schedules = _storage.getAllSchedules();
    if (schedules.isNotEmpty) {
      state = state.copyWith(
        schedules: schedules,
        status: GenerateStatus.success,
      );
    }
  }

  /// Jalankan Forward Chaining Engine dan simpan hasilnya
  Future<History?> generate() async {
    state = state.copyWith(status: GenerateStatus.loading, errorMessage: null);

    try {
      final history = await _engine.generateAndSave();

      state = state.copyWith(
        schedules: history.schedules,
        status: GenerateStatus.success,
      );

      // Refresh history provider
      _ref.read(historyProvider.notifier).reload();

      return history;
    } on SchedulingException catch (e) {
      state = state.copyWith(
        status: GenerateStatus.error,
        errorMessage: e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        status: GenerateStatus.error,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      );
      return null;
    }
  }

  /// Reset ke idle
  void reset() {
    state = const ScheduleState();
  }
}

/// Provider global untuk jadwal
final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>(
  (ref) => ScheduleNotifier(ref),
);
