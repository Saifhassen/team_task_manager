// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      title: fields[0] as String,
      notes: fields[1] as String,
      type: fields[2] as String,
      description: fields[3] as String,
      startDate: fields[4] as DateTime,
      unitType: fields[5] as String,
      assignedPeople: (fields[6] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      colorValue: fields[7] as int,
      editorName: fields[9] as String,
      endDate: fields[8] as DateTime?,
      inquiryResponded: fields[10] as bool,
      inquirySentToAdmin: fields[11] as bool,
      inquiryReply: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.notes)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.unitType)
      ..writeByte(6)
      ..write(obj.assignedPeople)
      ..writeByte(7)
      ..write(obj.colorValue)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.editorName)
      ..writeByte(10)
      ..write(obj.inquiryResponded)
      ..writeByte(11)
      ..write(obj.inquirySentToAdmin)
      ..writeByte(12)
      ..write(obj.inquiryReply);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
