// Conflict Checker — validasi bentrok jadwal

import '../../models/room.dart';
import 'knowledge_base.dart';

/// Interval waktu dalam menit (untuk cek overlap Rule 6)
class _TimeInterval {
  final int startMinutes;
  final int endMinutes;
  const _TimeInterval(this.startMinutes, this.endMinutes);
}

/// Menyimpan dan memvalidasi semua bentrok jadwal (Working Memory).
class ConflictChecker {
  // Rule 5 — slot terpakai per dosen
  final Map<String, bool> _lecturerOccupied = {};

  // Rule 4 — slot terpakai per ruangan
  final Map<String, Set<String>> _roomOccupied = {};

  // Rule 6 — interval waktu per kelompok (Prodi+Sem) per hari
  final Map<String, List<_TimeInterval>> _prodiSemIntervals = {};

  // Rule 7 — jumlah MK per kelompok per hari
  final Map<String, int> _groupDailyCount = {};

  /// Reset Working Memory untuk sesi generate baru
  void reset() {
    _lecturerOccupied.clear();
    _roomOccupied.clear();
    _prodiSemIntervals.clear();
    _groupDailyCount.clear();
  }

  /// Jumlah MK kelompok pada hari tertentu
  int getGroupDailyCount(String groupKey, String day) =>
      _groupDailyCount['$groupKey|$day'] ?? 0;

  /// Rule 5: cek bentrok dosen di slot-slot yang dibutuhkan
  bool isLecturerConflict(String lecturerId, String day, List<String> slots) {
    return slots.any((s) => _lecturerOccupied['$lecturerId|$day|$s'] == true);
  }

  /// Rule 4: cek bentrok ruangan di slot-slot yang dibutuhkan
  bool isRoomConflict(String roomId, String day, List<String> slots) {
    return slots.any((s) => (_roomOccupied['$day|$s'] ?? {}).contains(roomId));
  }

  /// Rule 3: cek kesesuaian kategori ruangan
  bool isRoomCategoryValid(Room room, String requiredCategory) =>
      room.category == requiredCategory;

  /// Rule 6: cek overlap interval Prodi+Semester.
  /// Formula: newStart < existingEnd AND newEnd > existingStart
  bool isProgramSemesterConflict(
    String groupKey,
    String day,
    String newStartTime,
    String newEndTime,
  ) {
    final existing = _prodiSemIntervals['$groupKey|$day'];
    if (existing == null || existing.isEmpty) return false;

    final newStart = KnowledgeBase.timeToMinutes(newStartTime);
    final newEnd = KnowledgeBase.timeToMinutes(newEndTime);

    return existing.any((iv) => newStart < iv.endMinutes && newEnd > iv.startMinutes);
  }

  /// Tandai slot sebagai terpakai setelah jadwal valid (Rule 8)
  void markOccupied({
    required String day,
    required List<String> slots,
    required String lecturerId,
    required String roomId,
    required String groupKey,
    required String startTime,
    required String endTime,
  }) {
    for (final slot in slots) {
      _lecturerOccupied['$lecturerId|$day|$slot'] = true;
      _roomOccupied.putIfAbsent('$day|$slot', () => {}).add(roomId);
    }

    final key = '$groupKey|$day';
    _prodiSemIntervals.putIfAbsent(key, () => []).add(_TimeInterval(
      KnowledgeBase.timeToMinutes(startTime),
      KnowledgeBase.timeToMinutes(endTime),
    ));

    _groupDailyCount[key] = (_groupDailyCount[key] ?? 0) + 1;
  }
}
