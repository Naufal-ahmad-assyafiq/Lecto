// Inference Engine — inti Forward Chaining

import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../models/course.dart';
import '../../models/lecturer.dart';
import '../../models/room.dart';
import '../../models/schedule.dart';
import 'conflict_checker.dart';
import 'knowledge_base.dart';
import 'rules.dart';
import 'schedule_engine.dart';

/// Mengevaluasi semua rule dan membangun Working Memory (jadwal).
class InferenceEngine {
  InferenceEngine() {
    _random = Random();
    _scheduleEngine = ScheduleEngine(_random);
    _conflictChecker = ConflictChecker();
  }

  late final Random _random;
  late final ScheduleEngine _scheduleEngine;
  late final ConflictChecker _conflictChecker;

  final List<Schedule> _workingMemory = [];
  final Map<String, int> _courseColorMap = {};
  int _colorCounter = 0;

  /// Jalankan Forward Chaining, kembalikan jadwal tervalidasi.
  List<Schedule> run(List<Lecturer> lecturers, List<Room> rooms) {
    _workingMemory.clear();
    _courseColorMap.clear();
    _colorCounter = 0;
    _conflictChecker.reset();

    for (final lecturer in lecturers) {
      _processLecturer(lecturer, rooms);
    }

    return List.unmodifiable(_workingMemory);
  }

  void _processLecturer(Lecturer lecturer, List<Room> rooms) {
    // Rule 1/2: tentukan pool slot sesuai preferensi
    final preferenceSlots = KnowledgeBase.slotsForPreference(lecturer.preference);

    assert(
      Rules.rulePreferensiPagi(lecturer.preference) ||
          Rules.rulePreferensiSiang(lecturer.preference),
    );

    for (final course in lecturer.courses) {
      _inferCourse(
        lecturer: lecturer,
        course: course,
        rooms: rooms,
        preferenceSlots: preferenceSlots,
      );
    }
  }

  void _inferCourse({
    required Lecturer lecturer,
    required Course course,
    required List<Room> rooms,
    required List<String> preferenceSlots,
  }) {
    // Business Rule Durasi: 1 SKS=45mnt, 2 SKS=90mnt, 3 SKS=120mnt
    final slotsNeeded = Rules.ruleSlotGrid(course.credits);
    final groupKey = course.academicGroupKey;

    // Rule 3: filter ruangan sesuai kategori
    final eligibleRooms = rooms
        .where((r) => Rules.ruleKategoriRuanganValid(r.category, course.roomCategory))
        .toList();

    if (eligibleRooms.isEmpty) return;

    // Rule 7: kandidat hari (Least Loaded Day)
    final candidateDays = _scheduleEngine.getCandidateDays(groupKey, _conflictChecker);
    if (candidateDays.isEmpty) return;

    for (final day in candidateDays) {
      // Rule 5, 4, 6: cari slot valid
      final startSlot = _scheduleEngine.findStartSlot(
        day: day,
        lecturerId: lecturer.id,
        preferenceSlots: preferenceSlots,
        slotsNeeded: slotsNeeded,
        eligibleRooms: eligibleRooms,
        groupKey: groupKey,
        checker: _conflictChecker,
        credits: course.credits,
      );
      if (startSlot == null) continue;

      // Rule 4: cari ruangan bebas
      final room = _scheduleEngine.findRoom(
        day: day,
        startSlot: startSlot,
        slotsNeeded: slotsNeeded,
        eligibleRooms: eligibleRooms,
        checker: _conflictChecker,
      );
      if (room == null) continue;

      // Rule 8: validasi final
      final endTime = KnowledgeBase.calculateEndTime(startSlot, course.credits)!;
      final allSlots = KnowledgeBase.allTimeSlots;
      final startIndex = allSlots.indexOf(startSlot);
      final occupiedSlots = allSlots.sublist(startIndex, startIndex + slotsNeeded);

      final isValid = Rules.ruleJadwalValid(
        slotDalamPreferensi: true,
        ruanganSesuaiKategori: true,
        ruanganTersedia: Rules.ruleRuanganTersedia(
          !_conflictChecker.isRoomConflict(room.id, day, occupiedSlots),
        ),
        dosenTersedia: Rules.ruleDosenTersedia(
          !_conflictChecker.isLecturerConflict(lecturer.id, day, occupiedSlots),
        ),
        tidakAdaOverlapProdiSem: Rules.ruleSlotProdiSemesterValid(
          !_conflictChecker.isProgramSemesterConflict(groupKey, day, startSlot, endTime),
        ),
        hariBelumPenuh: Rules.ruleHariTersedia(
          _conflictChecker.getGroupDailyCount(groupKey, day),
        ),
      );
      if (!isValid) continue;

      final schedule = Schedule(
        id: const Uuid().v4(),
        day: day,
        startTime: startSlot,
        endTime: endTime,
        course: course,
        lecturer: lecturer,
        room: room,
        colorIndex: _assignColor(course.courseCode),
      );

      _conflictChecker.markOccupied(
        day: day,
        slots: occupiedSlots,
        lecturerId: lecturer.id,
        roomId: room.id,
        groupKey: groupKey,
        startTime: startSlot,
        endTime: endTime,
      );

      _workingMemory.add(schedule);
      return;
    }
  }

  /// Tetapkan warna cycling per kode MK
  int _assignColor(String courseCode) {
    if (!_courseColorMap.containsKey(courseCode)) {
      _courseColorMap[courseCode] = _colorCounter % 7;
      _colorCounter++;
    }
    return _courseColorMap[courseCode]!;
  }
}
