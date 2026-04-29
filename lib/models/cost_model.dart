import 'package:hive/hive.dart';

class Cost {
  final String id;
  final String fieldId;
  final String category;
  final double amount;
  final DateTime date;
  final String description;

  Cost({
    required this.id,
    required this.fieldId,
    required this.category,
    required this.amount,
    required this.date,
    this.description = '',
  });

  static const List<String> categories = [
    'Tohum',
    'Gübre',
    'İlaç',
    'İşçilik',
    'Ekipman',
    'Diğer',
  ];
}

class CostAdapter extends TypeAdapter<Cost> {
  @override
  final int typeId = 1;

  @override
  Cost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Cost(
      id: fields[0] as String,
      fieldId: fields[1] as String? ?? '',
      category: fields[2] as String,
      amount: (fields[3] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
      description: fields[5] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Cost obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fieldId)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(5)
      ..write(obj.description);
  }
}
