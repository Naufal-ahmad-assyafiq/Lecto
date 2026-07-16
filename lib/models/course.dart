import 'package:hive/hive.dart';

part 'course.g.dart';

/// Model Mata Kuliah
/// - className dihapus (Revisi sebelumnya)
/// - programStudi ditambahkan di HiveField(6)
@HiveType(typeId: 0)
class Course extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String courseName;

  @HiveField(2)
  late String courseCode;

  /// Jumlah SKS (1–6)
  @HiveField(3)
  late int credits;

  /// Semester (1–8)
  @HiveField(4)
  late int semester;

  /// Kategori ruangan yang dibutuhkan: 'Kelas' | 'Lab' | 'Auditorium'
  @HiveField(5)
  late String roomCategory;

  /// Program Studi pemilik mata kuliah
  @HiveField(6)
  late String programStudi;

  Course({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.credits,
    required this.semester,
    required this.roomCategory,
    required this.programStudi,
  });

  Course copyWith({
    String? id,
    String? courseName,
    String? courseCode,
    int? credits,
    int? semester,
    String? roomCategory,
    String? programStudi,
  }) {
    return Course(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
      roomCategory: roomCategory ?? this.roomCategory,
      programStudi: programStudi ?? this.programStudi,
    );
  }

  /// Kunci kelompok akademik untuk Forward Chaining
  /// Format: 'ProgramStudi|Semester'
  String get academicGroupKey => '$programStudi|$semester';

  @override
  String toString() =>
      'Course(code: $courseCode, name: $courseName, credits: $credits, '
      'semester: $semester, prodi: $programStudi, roomCat: $roomCategory)';
}
