// Schedule Engine — strategi pemilihan hari dan slot

import 'dart:math';

import '../../models/room.dart';
import 'conflict_checker.dart';
import 'knowledge_base.dart';

/// Menentukan hari optimal (Least Loaded Day) dan slot waktu tersedia.
class ScheduleEngine {
  ScheduleEngine(this._random);

  final Random _random;

  /// Kembalikan hari kandidat diurutkan dari paling sedikit MK (acak dalam tier).
  List<String> getCandidateDays(String groupKey, ConflictChecker checker) {
    final candidates = KnowledgeBase.workingDays
        .where((day) =>
            checker.getGroupDailyCount(groupKey, day) <
            KnowledgeBase.maxCoursesPerGroupPerDay)
        .toList();

    if (candidates.isEmpty) return [];

    // Kelompokkan per jumlah MK (tier), lalu kocok tiap tier
    final Map<int, List<String>> tierMap = {};
    for (final day in candidates) {
      final count = checker.getGroupDailyCount(groupKey, day);
      tierMap.putIfAbsent(count, () => []).add(day);
    }

    final sortedTiers = tierMap.keys.toList()..sort();
    final ordered = <String>[];
    for (final tier in sortedTiers) {
      ordered.addAll(tierMap[tier]!..shuffle(_random));
    }

    return ordered;
  }

  /// Cari slot awal yang valid dalam sesi preferensi dosen.
  /// Cek: Rule 5 (dosen), Rule 4 (ruangan), Rule 6 (overlap Prodi+Sem).
  String? findStartSlot({
    required String day,
    required String lecturerId,
    required List<String> preferenceSlots,
    required int slotsNeeded,
    required List<Room> eligibleRooms,
    required String groupKey,
    required ConflictChecker checker,
    required int credits,
  }) {
    final allSlots = KnowledgeBase.allTimeSlots;
    final lastPrefIndex = allSlots.indexOf(preferenceSlots.last);

    for (final startSlot in preferenceSlots) {
      final startIndex = allSlots.indexOf(startSlot);
      if (startIndex == -1) continue;

      final endIndex = startIndex + slotsNeeded;

      // Jangan melampaui batas sesi preferensi
      if (endIndex - 1 > lastPrefIndex) break;
      if (endIndex > allSlots.length) break;

      final occupiedSlots = allSlots.sublist(startIndex, endIndex);

      // Rule 5: dosen bentrok?
      if (checker.isLecturerConflict(lecturerId, day, occupiedSlots)) continue;

      // Pre-cek Rule 4: ada ruangan bebas?
      final hasRoom = eligibleRooms
          .any((r) => !checker.isRoomConflict(r.id, day, occupiedSlots));
      if (!hasRoom) continue;

      // Rule 6: overlap Prodi+Semester?
      final endTime = KnowledgeBase.calculateEndTime(startSlot, credits);
      if (endTime == null) continue;

      if (checker.isProgramSemesterConflict(groupKey, day, startSlot, endTime)) {
        continue;
      }

      return startSlot;
    }

    return null;
  }

  /// Cari ruangan pertama yang bebas di slot yang dibutuhkan (Rule 4).
  Room? findRoom({
    required String day,
    required String startSlot,
    required int slotsNeeded,
    required List<Room> eligibleRooms,
    required ConflictChecker checker,
  }) {
    final allSlots = KnowledgeBase.allTimeSlots;
    final startIndex = allSlots.indexOf(startSlot);
    if (startIndex == -1) return null;

    final occupiedSlots = allSlots.sublist(startIndex, startIndex + slotsNeeded);

    for (final room in eligibleRooms) {
      if (!checker.isRoomConflict(room.id, day, occupiedSlots)) return room;
    }

    return null;
  }
}
