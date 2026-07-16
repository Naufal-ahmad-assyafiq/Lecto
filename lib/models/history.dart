import 'package:hive/hive.dart';
import 'schedule.dart';

part 'history.g.dart';

/// Model Riwayat Generate Jadwal
@HiveType(typeId: 4)
class History extends HiveObject {
  @HiveField(0)
  late String id;

  /// Waktu generate dilakukan
  @HiveField(1)
  late DateTime generatedAt;

  /// Jumlah dosen yang terlibat
  @HiveField(2)
  late int lecturerCount;

  /// Jumlah mata kuliah yang dijadwalkan
  @HiveField(3)
  late int courseCount;

  /// Daftar jadwal hasil generate
  @HiveField(4)
  late List<Schedule> schedules;

  History({
    required this.id,
    required this.generatedAt,
    required this.lecturerCount,
    required this.courseCount,
    required this.schedules,
  });

  /// Jumlah total slot jadwal
  int get scheduleCount => schedules.length;

  History copyWith({
    String? id,
    DateTime? generatedAt,
    int? lecturerCount,
    int? courseCount,
    List<Schedule>? schedules,
  }) {
    return History(
      id: id ?? this.id,
      generatedAt: generatedAt ?? this.generatedAt,
      lecturerCount: lecturerCount ?? this.lecturerCount,
      courseCount: courseCount ?? this.courseCount,
      schedules: schedules ?? this.schedules,
    );
  }

  @override
  String toString() =>
      'History(id: $id, generatedAt: $generatedAt, '
      'schedules: ${schedules.length})';
}
