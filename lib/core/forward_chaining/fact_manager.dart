// Fact Manager — ambil fakta dari storage untuk inference

import '../../models/lecturer.dart';
import '../../models/room.dart';
import '../../services/storage_service.dart';
import 'knowledge_base.dart';

/// Menyiapkan fakta (dosen, ruangan) untuk Inference Engine.
class FactManager {
  FactManager() : _storage = StorageService.instance;

  final StorageService _storage;

  /// Fakta dosen dari Hive
  List<Lecturer> getLecturers() => _storage.getAllLecturers();

  /// Fakta ruangan dari Hive
  List<Room> getRooms() => _storage.getAllRooms();

  /// Validasi data sebelum generate — lempar [SchedulingException] jika kurang
  void validate() {
    final lecturers = getLecturers();
    if (lecturers.isEmpty) {
      throw const SchedulingException('Belum ada data dosen.');
    }

    final totalMK = lecturers.fold<int>(0, (sum, l) => sum + l.courses.length);
    if (totalMK == 0) {
      throw const SchedulingException('Belum ada mata kuliah.');
    }

    if (getRooms().isEmpty) {
      throw const SchedulingException('Belum ada data ruangan.');
    }
  }
}
