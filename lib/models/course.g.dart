// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseAdapter extends TypeAdapter<Course> {
  @override
  final int typeId = 0;

  @override
  Course read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Course(
      id: fields[0] as String,
      courseName: fields[1] as String,
      courseCode: fields[2] as String,
      credits: fields[3] as int,
      semester: fields[4] as int,
      // Field 5: roomCategory (tetap di 5 setelah className dihapus)
      roomCategory: (fields[5] ?? 'Kelas') as String,
      // Field 6: programStudi (baru) — default 'Teknik Informatika' untuk data lama
      programStudi: (fields[6] ?? 'Teknik Informatika') as String,
    );
  }

  @override
  void write(BinaryWriter writer, Course obj) {
    writer
      ..writeByte(7) // 7 fields: 0-6
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.courseCode)
      ..writeByte(3)
      ..write(obj.credits)
      ..writeByte(4)
      ..write(obj.semester)
      ..writeByte(5)
      ..write(obj.roomCategory)
      ..writeByte(6)
      ..write(obj.programStudi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
