import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/lecturer.dart';
import '../models/course.dart';
import '../services/storage_service.dart';

/// State notifier untuk manajemen data Dosen
class LecturerNotifier extends StateNotifier<List<Lecturer>> {
  LecturerNotifier() : super([]) {
    reload();
  }

  final _storage = StorageService.instance;
  final _uuid = const Uuid();

  /// Muat ulang data dosen dari Hive ke state Riverpod.
  /// Dipanggil oleh SessionManager saat restore atau clear session.
  void reload() {
    state = _storage.getAllLecturers();
  }

  /// Tambah dosen baru
  Future<void> addLecturer({
    required String name,
    required String phone,
    required String email,
    required String preference,
    required List<Course> courses,
  }) async {
    final lecturer = Lecturer(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      email: email,
      preference: preference,
      courses: courses,
    );
    await _storage.saveLecturer(lecturer);
    reload();
  }

  /// Update data dosen
  /// Update data dosen
  Future<void> updateLecturer(Lecturer lecturer) async {
    await _storage.saveLecturer(lecturer);
    reload();
  }

  /// Hapus dosen
  Future<void> deleteLecturer(String id) async {
    await _storage.deleteLecturer(id);
    reload();
  }

  /// Total mata kuliah dari semua dosen
  int get totalCourses =>
      state.fold(0, (sum, l) => sum + l.courses.length);
}

/// Provider global untuk daftar dosen
final lecturerProvider =
    StateNotifierProvider<LecturerNotifier, List<Lecturer>>(
  (ref) => LecturerNotifier(),
);

/// Provider untuk total mata kuliah
final totalCoursesProvider = Provider<int>((ref) {
  final lecturers = ref.watch(lecturerProvider);
  return lecturers.fold(0, (sum, l) => sum + l.courses.length);
});
