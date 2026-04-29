import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/field_model.dart';

class FieldProvider extends ChangeNotifier {
  late Box<Field> _box;
  List<Field> _fields = [];

  List<Field> get fields => List.unmodifiable(_fields);

  FieldProvider() {
    _init();
  }

  void _init() {
    _box = Hive.box<Field>('fields');
    _fields = _box.values.toList();
  }

  Future<void> addField(Field field) async {
    await _box.put(field.id, field);
    _fields = _box.values.toList();
    notifyListeners();
  }

  Future<void> updateField(Field field) async {
    await _box.put(field.id, field);
    _fields = _box.values.toList();
    notifyListeners();
  }

  Future<void> deleteField(String id) async {
    await _box.delete(id);
    _fields = _box.values.toList();
    notifyListeners();
  }

  Field? getFieldById(String id) {
    try {
      return _fields.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}
