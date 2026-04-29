import 'package:hive/hive.dart';

class AppTask {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String type;
  final String fieldId;

  AppTask({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.type,
    this.fieldId = '',
  });

  AppTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    String? type,
    String? fieldId,
  }) {
    return AppTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
      fieldId: fieldId ?? this.fieldId,
    );
  }

  static const List<String> types = [
    'sulama',
    'ilaçlama',
    'hasat',
    'gübreleme',
    'sürme',
    'diğer',
  ];

  static String typeIcon(String type) {
    switch (type) {
      case 'sulama':
        return '💧';
      case 'ilaçlama':
        return '🧪';
      case 'hasat':
        return '🌾';
      case 'gübreleme':
        return '🌱';
      case 'sürme':
        return '🚜';
      default:
        return '📋';
    }
  }
}

class AppTaskAdapter extends TypeAdapter<AppTask> {
  @override
  final int typeId = 2;

  @override
  AppTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return AppTask(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String? ?? '',
      dueDate: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      isCompleted: fields[4] as bool? ?? false,
      type: fields[5] as String? ?? 'diğer',
      fieldId: fields[6] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, AppTask obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dueDate.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.fieldId);
  }
}
