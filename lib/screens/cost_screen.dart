import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../providers/cost_provider.dart';
import '../providers/field_provider.dart';
import '../models/cost_model.dart';

class CostScreen extends StatelessWidget {
  const CostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Maliyet Takibi'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<CostProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _SummaryCard(provider: provider),
                      const SizedBox(height: 16),
                      _CategoryBreakdown(provider: provider),
                      const SizedBox(height: 16),
                      if (provider.costs.isNotEmpty)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Gider Geçmişi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ),
                      if (provider.costs.isNotEmpty)
                        const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (provider.costs.isEmpty)
                const SliverFillRemaining(
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cost = provider.costs[index];
                        return _CostItem(
                          cost: cost,
                          onDelete: () => provider.deleteCost(cost.id),
                        );
                      },
                      childCount: provider.costs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'cost_fab',
        onPressed: () => _showAddCostSheet(context),
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Gider Ekle',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddCostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddCostSheet(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final CostProvider provider;

  const _SummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Toplam Gider',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            '${NumberFormat('#,##0.00', 'tr').format(provider.totalCost)} ₺',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${provider.costs.length} adet gider kaydı',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final CostProvider provider;

  const _CategoryBreakdown({required this.provider});

  static const Map<String, Color> _categoryColors = {
    'Tohum': Color(0xFF4CAF50),
    'Gübre': Color(0xFF8BC34A),
    'İlaç': Color(0xFFFF9800),
    'İşçilik': Color(0xFF2196F3),
    'Ekipman': Color(0xFF9C27B0),
    'Diğer': Color(0xFF607D8B),
  };

  static const Map<String, IconData> _categoryIcons = {
    'Tohum': Icons.grass,
    'Gübre': Icons.science,
    'İlaç': Icons.local_pharmacy,
    'İşçilik': Icons.people,
    'Ekipman': Icons.agriculture,
    'Diğer': Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context) {
    final byCategory = provider.costsByCategory;
    if (byCategory.isEmpty) return const SizedBox.shrink();

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategorilere Göre',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            ...byCategory.entries.map((entry) {
              final percent = provider.totalCost > 0
                  ? entry.value / provider.totalCost
                  : 0.0;
              final color =
                  _categoryColors[entry.key] ?? Colors.grey;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _categoryIcons[entry.key] ??
                              Icons.more_horiz,
                          color: color,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(entry.key,
                            style: const TextStyle(fontSize: 13)),
                        const Spacer(),
                        Text(
                          '${NumberFormat('#,##0.00', 'tr').format(entry.value)} ₺',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '%${(percent * 100).toStringAsFixed(0)}',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(color),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CostItem extends StatelessWidget {
  final Cost cost;
  final VoidCallback onDelete;

  const _CostItem({required this.cost, required this.onDelete});

  static const Map<String, Color> _categoryColors = {
    'Tohum': Color(0xFF4CAF50),
    'Gübre': Color(0xFF8BC34A),
    'İlaç': Color(0xFFFF9800),
    'İşçilik': Color(0xFF2196F3),
    'Ekipman': Color(0xFF9C27B0),
    'Diğer': Color(0xFF607D8B),
  };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[cost.category] ?? Colors.grey;

    return Dismissible(
      key: Key(cost.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_long, color: color, size: 22),
          ),
          title: Text(
            cost.category,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            cost.description.isNotEmpty
                ? cost.description
                : DateFormat('d MMMM yyyy', 'tr').format(cost.date),
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${NumberFormat('#,##0.00', 'tr').format(cost.amount)} ₺',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF2E7D32),
                ),
              ),
              Text(
                DateFormat('d MMM', 'tr').format(cost.date),
                style: const TextStyle(
                    color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Henüz gider kaydı yok',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Gider eklemek için aşağıdaki butona tıklayın',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _AddCostSheet extends StatefulWidget {
  const _AddCostSheet();

  @override
  State<_AddCostSheet> createState() => _AddCostSheetState();
}

class _AddCostSheetState extends State<_AddCostSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = Cost.categories.first;
  String? _selectedFieldId;
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final cost = Cost(
      id: const Uuid().v4(),
      fieldId: _selectedFieldId ?? '',
      category: _selectedCategory,
      amount: double.parse(_amountController.text.replaceAll(',', '.')),
      date: _selectedDate,
      description: _descriptionController.text.trim(),
    );

    await context.read<CostProvider>().addCost(cost);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fields = context.read<FieldProvider>().fields;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gider Ekle',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Kategori seçimi
              const Text('Kategori',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Cost.categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    selectedColor: const Color(0xFF4CAF50),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Tutar (₺) *',
                  prefixIcon: const Icon(Icons.attach_money,
                      color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Tutar gerekli';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) {
                    return 'Geçersiz tutar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama (isteğe bağlı)',
                  prefixIcon: const Icon(Icons.note,
                      color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (fields.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: _selectedFieldId,
                  decoration: InputDecoration(
                    labelText: 'Tarla (isteğe bağlı)',
                    prefixIcon: const Icon(Icons.grass,
                        color: Color(0xFF2E7D32)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Tüm tarlalar')),
                    ...fields.map((f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(f.name),
                        )),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedFieldId = v),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Gider Ekle',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
