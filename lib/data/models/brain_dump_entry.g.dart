// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written equivalent of build_runner output for BrainDumpEntry.

part of 'brain_dump_entry.dart';

class BrainDumpEntryAdapter extends TypeAdapter<BrainDumpEntry> {
  @override
  final int typeId = 10;

  @override
  BrainDumpEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BrainDumpEntry(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      rawTranscript: fields[2] as String,
      tasks: (fields[3] as List).cast<String>(),
      ideas: (fields[4] as List).cast<String>(),
      events: (fields[5] as List).cast<String>(),
      worries: (fields[6] as List).cast<String>(),
      summary: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BrainDumpEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.rawTranscript)
      ..writeByte(3)
      ..write(obj.tasks)
      ..writeByte(4)
      ..write(obj.ideas)
      ..writeByte(5)
      ..write(obj.events)
      ..writeByte(6)
      ..write(obj.worries)
      ..writeByte(7)
      ..write(obj.summary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrainDumpEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
