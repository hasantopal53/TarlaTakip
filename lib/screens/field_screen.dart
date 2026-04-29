import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../providers/field_provider.dart';
import '../providers/cost_provider.dart';
import '../models/field_model.dart';

class FieldScreen extends StatelessWidget {
  const FieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Tarla & Ürün Yönetimi'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
            actions: [
          Consumer<FieldProvider>(
            builder: (_, p, __) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${p.fields.length} tarla',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<FieldProvider>(
        builder: (context, provider, _) {
          if (provider.fields.isEmpty) {
            return _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.fields.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final field = provider.fields[index];
              return _FieldCard(
                field: field,
                onDelete: () => _confirmDelete(context, provider, field),
                onEdit: () => _showEditSheet(context, field),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'field_fab',
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tarla Ekle',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, FieldProvider provider, Field field) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tarla Sil'),
        content: Text('"${field.name}" tarlasını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteField(field.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FieldFormSheet(),
    );
  }

  void _showEditSheet(BuildContext context, Field field) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FieldFormSheet(existingField: field),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final Field field;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _FieldCard(
      {required this.field,
      required this.onDelete,
      required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final daysToHarvest =
        field.harvestDate.difference(DateTime.now()).inDays;
    final progress = _calculateProgress();

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.grass,
                        color: Color(0xFF2E7D32), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          field.product,
                          style: const TextStyle(
                              color: Color(0xFF4CAF50), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'edit', child: Text('Düzenle')),
                      const PopupMenuItem(
                          value: 'delete',
                          child:
                              Text('Sil', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                      icon: Icons.calendar_today,
                      text: DateFormat('d MMM', 'tr').format(field.sowingDate)),
                  const SizedBox(width: 8),
                  _InfoChip(
                      icon: Icons.agriculture,
                      text: DateFormat('d MMM', 'tr').format(field.harvestDate)),
                  const SizedBox(width: 8),
                  _InfoChip(
                      icon: Icons.straighten,
                      text: '${field.area} dönüm'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    daysToHarvest > 0
                        ? 'Hasada $daysToHarvest gün kaldı'
                        : 'Hasat zamanı!',
                    style: TextStyle(
                      fontSize: 12,
                      color: daysToHarvest <= 7
                          ? Colors.orange
                          : Colors.grey,
                      fontWeight: daysToHarvest <= 7
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    '%${(progress * 100).toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CAF50)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateProgress() {
    final total =
        field.harvestDate.difference(field.sowingDate).inDays;
    if (total <= 0) return 1.0;
    final elapsed =
        DateTime.now().difference(field.sowingDate).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  void _showDetails(BuildContext context) {
    final costs = context.read<CostProvider>().getCostsForField(field.id);
    final totalCost = costs.fold(0.0, (sum, c) => sum + c.amount);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Text(field.name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _DetailRow(label: 'Ürün', value: field.product),
            _DetailRow(
                label: 'Alan', value: '${field.area} dönüm'),
            _DetailRow(
                label: 'Ekim Tarihi',
                value: DateFormat('d MMMM yyyy', 'tr')
                    .format(field.sowingDate)),
            _DetailRow(
                label: 'Tahmini Hasat',
                value: DateFormat('d MMMM yyyy', 'tr')
                    .format(field.harvestDate)),
            if (field.latitude != 0)
              _DetailRow(
                  label: 'Konum',
                  value:
                      '${field.latitude.toStringAsFixed(4)}, ${field.longitude.toStringAsFixed(4)}'),
            _DetailRow(
                label: 'Toplam Maliyet',
                value: '${totalCost.toStringAsFixed(2)} ₺'),
            if (field.notes.isNotEmpty)
              _DetailRow(label: 'Notlar', value: field.notes),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:',
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.grass,
                size: 50, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Henüz tarla eklenmedi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aşağıdaki butona tıklayarak\nilk tarlanızı ekleyin',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FieldFormSheet extends StatefulWidget {
  final Field? existingField;

  const _FieldFormSheet({this.existingField});

  @override
  State<_FieldFormSheet> createState() => _FieldFormSheetState();
}

class _FieldFormSheetState extends State<_FieldFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _productController;
  late TextEditingController _areaController;
  late TextEditingController _notesController;
  late DateTime _sowingDate;
  late DateTime _harvestDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final field = widget.existingField;
    _nameController = TextEditingController(text: field?.name ?? '');
    _productController =
        TextEditingController(text: field?.product ?? '');
    _areaController = TextEditingController(
        text: field?.area != null ? field!.area.toString() : '');
    _notesController = TextEditingController(text: field?.notes ?? '');
    _sowingDate = field?.sowingDate ?? DateTime.now();
    _harvestDate = field?.harvestDate ??
        DateTime.now().add(const Duration(days: 120));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _productController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isSowing) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isSowing ? _sowingDate : _harvestDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2E7D32),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isSowing) {
          _sowingDate = picked;
        } else {
          _harvestDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<FieldProvider>();
    final isEdit = widget.existingField != null;

    final field = Field(
      id: isEdit ? widget.existingField!.id : const Uuid().v4(),
      name: _nameController.text.trim(),
      product: _productController.text.trim(),
      sowingDate: _sowingDate,
      harvestDate: _harvestDate,
      latitude: widget.existingField?.latitude ?? 0,
      longitude: widget.existingField?.longitude ?? 0,
      area: double.tryParse(_areaController.text) ?? 0,
      notes: _notesController.text.trim(),
    );

    if (isEdit) {
      await provider.updateField(field);
    } else {
      await provider.addField(field);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingField != null;

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
              Text(
                isEdit ? 'Tarla Düzenle' : 'Yeni Tarla Ekle',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _inputDeco('Tarla Adı *', Icons.grass),
                validator: (v) =>
                    v!.isEmpty ? 'Tarla adı gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productController,
                decoration: _inputDeco('Ürün Adı *', Icons.eco),
                validator: (v) =>
                    v!.isEmpty ? 'Ürün adı gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _areaController,
                decoration: _inputDeco('Alan (dönüm)', Icons.straighten),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateButton(
                      label: 'Ekim Tarihi',
                      date: _sowingDate,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateButton(
                      label: 'Hasat Tarihi',
                      date: _harvestDate,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration:
                    _inputDeco('Notlar (isteğe bağlı)', Icons.note),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                      : Text(isEdit ? 'Güncelle' : 'Tarla Ekle',
                          style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              DateFormat('d MMM yyyy', 'tr').format(date),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
