// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecturer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LecturerAdapter extends TypeAdapter<Lecturer> {
  @override
  final int typeId = 1;

  @override
  Lecturer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lecturer(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      email: fields[3] as String,
      preference: fields[4] as String,
      courses: (fields[5] as List).cast<Course>(),
    );
  }

  @override
  void write(BinaryWriter writer, Lecturer obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.preference)
      ..writeByte(5)
      ..write(obj.courses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LecturerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
