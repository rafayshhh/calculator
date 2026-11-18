import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String expression;

  @HiveField(2)
  final String result;

  @HiveField(3)
  final DateTime timestamp;

  HistoryEntry({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  HistoryEntry copyWith({
    String? id,
    String? expression,
    String? result,
    DateTime? timestamp,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class HistoryEntryAdapter extends TypeAdapter<HistoryEntry> {
  @override
  final int typeId = 1;

  @override
  HistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryEntry(
      id: fields[0] as String,
      expression: fields[1] as String,
      result: fields[2] as String,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.expression)
      ..writeByte(2)
      ..write(obj.result)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

@HiveType(typeId: 0)
class HistoryEntryV2 extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String expression;

  @HiveField(2)
  final String result;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? toolRoute;

  @HiveField(5)
  final String? toolStateJson;

  HistoryEntryV2({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
    this.toolRoute,
    this.toolStateJson,
  });

  HistoryEntryV2 copyWith({
    String? id,
    String? expression,
    String? result,
    DateTime? timestamp,
    String? toolRoute,
    String? toolStateJson,
  }) {
    return HistoryEntryV2(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      toolRoute: toolRoute ?? this.toolRoute,
      toolStateJson: toolStateJson ?? this.toolStateJson,
    );
  }
}

class HistoryEntryV2Adapter extends TypeAdapter<HistoryEntryV2> {
  @override
  final int typeId = 0;

  @override
  HistoryEntryV2 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryEntryV2(
      id: fields[0] as String,
      expression: fields[1] as String,
      result: fields[2] as String,
      timestamp: fields[3] as DateTime,
      toolRoute: fields[4] as String?,
      toolStateJson: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryEntryV2 obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.expression)
      ..writeByte(2)
      ..write(obj.result)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.toolRoute)
      ..writeByte(5)
      ..write(obj.toolStateJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntryV2Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
