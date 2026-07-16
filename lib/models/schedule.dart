import 'package:hive/hive.dart';
import 'course.dart';
import 'lecturer.dart';
import 'room.dart';

part 'schedule.g.dart';

/// Model satu entri jadwal kuliah hasil generate
@HiveType(typeId: 3)
class Schedule extends HiveObject {
  @HiveField(0)
  late String id;

  /// Hari: 'Senin' | 'Selasa' | dst.
  @HiveField(1)
  late String day;

  /// Jam mulai: format 'HH:mm'
  @HiveField(2)
  late String startTime;

  /// Jam selesai: format 'HH:mm'
  @HiveField(3)
  late String endTime;

  @HiveField(4)
  late Course course;

  @HiveField(5)
  late Lecturer lecturer;

  @HiveField(6)
  late Room room;

  /// Indeks warna (0–6) untuk tampilan berwarna
  @HiveField(7)
  late int colorIndex;

  Schedule({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.course,
    required this.lecturer,
    required this.room,
    required this.colorIndex,
  });

  Schedule copyWith({
    String? id,
    String? day,
    String? startTime,
    String? endTime,
    Course? course,
    Lecturer? lecturer,
    Room? room,
    int? colorIndex,
  }) {
    return Schedule(
      id: id ?? this.id,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      course: course ?? this.course,
      lecturer: lecturer ?? this.lecturer,
      room: room ?? this.room,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  @override
  String toString() =>
      'Schedule(day: $day, $startTime-$endTime, '
      'course: ${course.courseCode}, lecturer: ${lecturer.name}, '
      'room: ${room.roomName})';
}
