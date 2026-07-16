import 'package:hive/hive.dart';

part 'room.g.dart';

/// Model Ruangan
@HiveType(typeId: 2)
class Room extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String roomName;

  /// Kategori ruangan: 'Kelas' | 'Lab' | 'Auditorium'
  @HiveField(2)
  late String category;

  Room({
    required this.id,
    required this.roomName,
    required this.category,
  });

  Room copyWith({
    String? id,
    String? roomName,
    String? category,
  }) {
    return Room(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      category: category ?? this.category,
    );
  }

  @override
  String toString() => 'Room(id: $id, name: $roomName, category: $category)';
}
