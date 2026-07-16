// Storage Service — satu-satunya akses ke Hive

import 'package:hive_flutter/hive_flutter.dart';
import '../models/lecturer.dart';
import '../models/room.dart';
import '../models/schedule.dart';
import '../models/history.dart';

/// Layer persistensi. UI dan Provider tidak boleh akses Hive langsung.
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  // Nama box Hive
  static const String _lecturersBox = 'lecturers';
  static const String _roomsBox = 'rooms';
  static const String _schedulesBox = 'schedules';
  static const String _historiesBox = 'histories';

  Box<Lecturer> get lecturers => Hive.box<Lecturer>(_lecturersBox);
  Box<Room> get rooms => Hive.box<Room>(_roomsBox);
  Box<Schedule> get schedules => Hive.box<Schedule>(_schedulesBox);
  Box<History> get histories => Hive.box<History>(_historiesBox);

  // ─── Load ────────────────────────────────────────────────────────────────────

  List<Lecturer> loadLecturers() => lecturers.values.toList();
  List<Room> loadRooms() => rooms.values.toList();
  List<Schedule> loadSchedules() => schedules.values.toList();

  List<History> loadHistories() {
    final list = histories.values.toList();
    list.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return list;
  }

  // Alias untuk kompatibilitas
  List<Lecturer> getAllLecturers() => loadLecturers();
  List<Room> getAllRooms() => loadRooms();
  List<Schedule> getAllSchedules() => loadSchedules();
  List<History> getAllHistories() => loadHistories();

  // ─── Dosen ───────────────────────────────────────────────────────────────────

  Future<void> saveLecturer(Lecturer lecturer) async =>
      lecturers.put(lecturer.id, lecturer);

  Future<void> saveLecturers(List<Lecturer> list) async =>
      lecturers.putAll({for (final l in list) l.id: l});

  Future<void> deleteLecturer(String id) async => lecturers.delete(id);

  Lecturer? getLecturer(String id) => lecturers.get(id);

  // ─── Ruangan ─────────────────────────────────────────────────────────────────

  Future<void> saveRoom(Room room) async => rooms.put(room.id, room);

  Future<void> saveRooms(List<Room> list) async =>
      rooms.putAll({for (final r in list) r.id: r});

  Future<void> deleteRoom(String id) async => rooms.delete(id);

  Room? getRoom(String id) => rooms.get(id);

  // ─── Jadwal ──────────────────────────────────────────────────────────────────

  Future<void> saveSchedules(List<Schedule> list) async {
    await schedules.clear();
    await schedules.putAll({for (final s in list) s.id: s});
  }

  Future<void> saveAllSchedules(List<Schedule> list) async =>
      saveSchedules(list);

  Future<void> clearSchedules() async => schedules.clear();

  // ─── Riwayat ─────────────────────────────────────────────────────────────────

  Future<void> saveHistory(History history) async =>
      histories.put(history.id, history);

  Future<void> saveHistories(List<History> list) async =>
      histories.putAll({for (final h in list) h.id: h});

  Future<void> deleteHistory(String id) async => histories.delete(id);

  History? getHistory(String id) => histories.get(id);

  // ─── Clear All ───────────────────────────────────────────────────────────────

  /// Hapus semua data dari seluruh box Hive
  Future<void> clearAll() async {
    await Future.wait([
      lecturers.clear(),
      rooms.clear(),
      schedules.clear(),
      histories.clear(),
    ]);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  int get lecturerCount => lecturers.length;
  int get roomCount => rooms.length;
  int get scheduleCount => schedules.length;

  int get courseCount =>
      getAllLecturers().fold(0, (sum, l) => sum + l.courses.length);

  /// Cek apakah ada data sesi sebelumnya
  bool hasExistingData() =>
      lecturers.isNotEmpty ||
      rooms.isNotEmpty ||
      schedules.isNotEmpty ||
      histories.isNotEmpty;

  bool isCourseCodeExists(String code, {String? excludeLecturerId}) {
    for (final lecturer in getAllLecturers()) {
      if (excludeLecturerId != null && lecturer.id == excludeLecturerId) continue;
      for (final course in lecturer.courses) {
        if (course.courseCode.toLowerCase() == code.toLowerCase()) return true;
      }
    }
    return false;
  }

  bool isRoomNameExists(String name, {String? excludeId}) {
    for (final room in getAllRooms()) {
      if (excludeId != null && room.id == excludeId) continue;
      if (room.roomName.toLowerCase() == name.toLowerCase()) return true;
    }
    return false;
  }
}
