// ============================================================
// FORWARD CHAINING ENGINE — Façade (Entry Point)
// ============================================================
//
// File ini adalah PINTU MASUK (façade) dari seluruh sistem
// penjadwalan Forward Chaining Lecto.
//
// UI dan Provider hanya perlu memanggil:
//   ForwardChainingEngine().generate()
//   ForwardChainingEngine().generateAndSave()
//
// Seluruh proses inferensi terjadi di dalam komponen-komponen
// yang diorkestrasi oleh façade ini:
//
//   ┌─────────────────────────────────────────┐
//   │         ForwardChainingEngine           │ ← Façade (file ini)
//   │                                         │
//   │  ┌──────────────┐                       │
//   │  │  FactManager │ ← Ambil fakta dari Hive│
//   │  └──────┬───────┘                       │
//   │         │                               │
//   │  ┌──────▼───────────────────────────┐   │
//   │  │       InferenceEngine            │   │
//   │  │  (Forward Chaining core)         │   │
//   │  │                                  │   │
//   │  │  ┌─────────────┐                 │   │
//   │  │  │ConflictChecker│ ← Working Mem │   │
//   │  │  └─────────────┘                 │   │
//   │  │  ┌─────────────┐                 │   │
//   │  │  │ScheduleEngine│ ← Least Loaded │   │
//   │  │  └─────────────┘                 │   │
//   │  └──────────────────────────────────┘   │
//   │         │                               │
//   │  Output: List<Schedule>                 │
//   └─────────────────────────────────────────┘
//
// ============================================================

import 'package:uuid/uuid.dart';

import '../../models/history.dart';
import '../../models/schedule.dart';
import '../../services/storage_service.dart';
import 'fact_manager.dart';
import 'inference_engine.dart';
// Re-export SchedulingException agar provider tidak perlu
// mengubah import (cukup import file ini)
export 'knowledge_base.dart' show SchedulingException;

/// Façade sistem pakar penjadwalan Forward Chaining Lecto.
///
/// Cara penggunaan dari luar (Provider / UI):
/// ```dart
/// final engine = ForwardChainingEngine();
/// final schedules = await engine.generate();
/// // atau
/// final history = await engine.generateAndSave();
/// ```
class ForwardChainingEngine {
  final _uuid = const Uuid();
  final _storage = StorageService.instance;
  final _factManager = FactManager();
  final _inferenceEngine = InferenceEngine();

  // ─── Public API ───────────────────────────────────────────

  /// Jalankan Forward Chaining dan kembalikan daftar jadwal hasil inferensi.
  ///
  /// Alur:
  ///   1. FactManager.validate() → pastikan data lengkap
  ///   2. FactManager.getLecturers() + getRooms() → ambil fakta
  ///   3. InferenceEngine.run() → evaluasi semua rule → Working Memory
  ///
  /// Melempar [SchedulingException] jika data tidak mencukupi.
  Future<List<Schedule>> generate() async {
    // STEP 1: Validasi fakta — lempar SchedulingException jika kurang
    _factManager.validate();

    // STEP 2: Ambil seluruh fakta dari Hive
    final lecturers = _factManager.getLecturers();
    final rooms = _factManager.getRooms();

    // STEP 3: Jalankan Inference Engine
    // Engine akan mengevaluasi semua rule dan mengembalikan
    // Working Memory berupa daftar jadwal tervalidasi.
    final schedules = _inferenceEngine.run(lecturers, rooms);

    return schedules;
  }

  /// Generate jadwal dan simpan ke Hive (jadwal aktif + riwayat).
  ///
  /// Alur:
  ///   1. generate() → hasilkan jadwal
  ///   2. Simpan ke Hive (schedules box)
  ///   3. Buat History record dan simpan ke Hive (histories box)
  ///
  /// Mengembalikan [History] yang berisi metadata dan daftar jadwal.
  Future<History> generateAndSave() async {
    // Hasilkan jadwal menggunakan Forward Chaining
    final schedules = await generate();

    // Simpan jadwal aktif ke Hive (menggantikan jadwal sebelumnya)
    await _storage.saveAllSchedules(schedules);

    // Ambil metadata untuk riwayat
    final lecturers = _factManager.getLecturers();
    final totalCourses =
        lecturers.fold<int>(0, (sum, l) => sum + l.courses.length);

    // Buat dan simpan record riwayat ke Hive
    final history = History(
      id: _uuid.v4(),
      generatedAt: DateTime.now(),
      lecturerCount: lecturers.length,
      courseCount: totalCourses,
      schedules: schedules,
    );
    await _storage.saveHistory(history);

    return history;
  }
}
