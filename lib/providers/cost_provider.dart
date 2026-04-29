import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/cost_model.dart';

class CostProvider extends ChangeNotifier {
  late Box<Cost> _box;
  List<Cost> _costs = [];

  List<Cost> get costs => List.unmodifiable(_costs);

  double get totalCost =>
      _costs.fold(0.0, (sum, c) => sum + c.amount);

  Map<String, double> get costsByCategory {
    final map = <String, double>{};
    for (final cost in _costs) {
      map[cost.category] = (map[cost.category] ?? 0) + cost.amount;
    }
    return map;
  }

  CostProvider() {
    _init();
  }

  void _init() {
    _box = Hive.box<Cost>('costs');
    _costs = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addCost(Cost cost) async {
    await _box.put(cost.id, cost);
    _costs = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> deleteCost(String id) async {
    await _box.delete(id);
    _costs = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  List<Cost> getCostsForField(String fieldId) {
    return _costs.where((c) => c.fieldId == fieldId).toList();
  }
}
