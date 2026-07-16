// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryAdapter extends TypeAdapter<History> {
  @override
  final int typeId = 4;

  @override
  History read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return History(
      id: fields[0] as String,
      generatedAt: fields[1] as DateTime,
      lecturerCount: fields[2] as int,
      courseCount: fields[3] as int,
      schedules: (fields[4] as List).cast<Schedule>(),
    );
  }

  @override
  void write(BinaryWriter writer, History obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.generatedAt)
      ..writeByte(2)
      ..write(obj.lecturerCount)
      ..writeByte(3)
      ..write(obj.courseCount)
      ..writeByte(4)
      ..write(obj.schedules);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
