import 'package:hive/hive.dart';
import 'course.dart';

part 'lecturer.g.dart';

/// Model Dosen
@HiveType(typeId: 1)
class Lecturer extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phone;

  @HiveField(3)
  late String email;

  /// Preferensi mengajar: 'Pagi' | 'Siang'
  @HiveField(4)
  late String preference;

  /// Daftar mata kuliah yang diajarkan
  @HiveField(5)
  late List<Course> courses;

  Lecturer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.preference,
    required this.courses,
  });

  Lecturer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? preference,
    List<Course>? courses,
  }) {
    return Lecturer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      preference: preference ?? this.preference,
      courses: courses ?? this.courses,
    );
  }

  @override
  String toString() =>
      'Lecturer(id: $id, name: $name, preference: $preference, '
      'courses: ${courses.length})';
}
