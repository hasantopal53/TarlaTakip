import 'package:hive/hive.dart';

class Field {
  final String id;
  final String name;
  final String product;
  final DateTime sowingDate;
  final DateTime harvestDate;
  final double latitude;
  final double longitude;
  final double area;
  final String notes;

  Field({
    required this.id,
    required this.name,
    required this.product,
    required this.sowingDate,
    required this.harvestDate,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.area = 0.0,
    this.notes = '',
  });

  Field copyWith({
    String? id,
    String? name,
    String? product,
    DateTime? sowingDate,
    DateTime? harvestDate,
    double? latitude,
    double? longitude,
    double? area,
    String? notes,
  }) {
    return Field(
      id: id ?? this.id,
      name: name ?? this.name,
      product: product ?? this.product,
      sowingDate: sowingDate ?? this.sowingDate,
      harvestDate: harvestDate ?? this.harvestDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      area: area ?? this.area,
      notes: notes ?? this.notes,
    );
  }
}

class FieldAdapter extends TypeAdapter<Field> {
  @override
  final int typeId = 0;

  @override
  Field read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Field(
      id: fields[0] as String,
      name: fields[1] as String,
      product: fields[2] as String,
      sowingDate: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      harvestDate: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
      latitude: (fields[5] as num).toDouble(),
      longitude: (fields[6] as num).toDouble(),
      area: (fields[7] as num).toDouble(),
      notes: fields[8] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Field obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.product)
      ..writeByte(3)
      ..write(obj.sowingDate.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.harvestDate.millisecondsSinceEpoch)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.area)
      ..writeByte(8)
      ..write(obj.notes);
  }
}
