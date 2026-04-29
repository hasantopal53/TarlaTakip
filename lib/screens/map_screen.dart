import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../providers/field_provider.dart';
import '../models/field_model.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  static const LatLng _defaultLocation = LatLng(39.9208, 32.8541); // Ankara
  LatLng _currentPosition = _defaultLocation;
  bool _locationLoaded = false;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkers();
    });
  }

  Future<void> _loadLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _locationLoaded = true;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 14),
      );
    }
  }

  void _updateMarkers() {
    final fields = context.read<FieldProvider>().fields;
    final newMarkers = <Marker>{};

    for (final field in fields) {
      if (field.latitude != 0 || field.longitude != 0) {
        newMarkers.add(
          Marker(
            markerId: MarkerId(field.id),
            position: LatLng(field.latitude, field.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: field.name,
              snippet: '${field.product} • ${field.area} dönüm',
            ),
            onTap: () => _showFieldBottomSheet(field),
          ),
        );
      }
    }

    setState(() => _markers
      ..clear()
      ..addAll(newMarkers));
  }

  void _showFieldBottomSheet(Field field) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FieldInfoSheet(field: field),
    );
  }

  void _showAddFieldDialog(LatLng position) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddFieldSheet(
        position: position,
        onSaved: () => _updateMarkers(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarla Haritası'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _loadLocation,
            tooltip: 'Konumuma Git',
          ),
        ],
      ),
      body: Consumer<FieldProvider>(
        builder: (context, fieldProvider, _) {
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_locationLoaded) {
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(_currentPosition, 14),
                    );
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 12,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.hybrid,
                onLongPress: _showAddFieldDialog,
              ),
              // Bilgi banner
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xFF2E7D32), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${fieldProvider.fields.length} tarla • Uzun basarak tarla ekleyin',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'map_fab',
        onPressed: _loadLocation,
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.gps_fixed, color: Colors.white),
        label: const Text('Konumum',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _FieldInfoSheet extends StatelessWidget {
  final Field field;

  const _FieldInfoSheet({required this.field});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grass, color: Color(0xFF2E7D32), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  field.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.eco, label: 'Ürün', value: field.product),
          _InfoRow(
              icon: Icons.calendar_today,
              label: 'Ekim Tarihi',
              value: DateFormat('d MMM yyyy', 'tr').format(field.sowingDate)),
          _InfoRow(
              icon: Icons.agriculture,
              label: 'Tahmini Hasat',
              value:
                  DateFormat('d MMM yyyy', 'tr').format(field.harvestDate)),
          _InfoRow(
              icon: Icons.straighten,
              label: 'Alan',
              value: '${field.area} dönüm'),
          if (field.notes.isNotEmpty)
            _InfoRow(
                icon: Icons.note, label: 'Not', value: field.notes),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

class _AddFieldSheet extends StatefulWidget {
  final LatLng position;
  final VoidCallback onSaved;

  const _AddFieldSheet(
      {required this.position, required this.onSaved});

  @override
  State<_AddFieldSheet> createState() => _AddFieldSheetState();
}

class _AddFieldSheetState extends State<_AddFieldSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _productController = TextEditingController();
  final _areaController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _sowingDate = DateTime.now();
  DateTime _harvestDate = DateTime.now().add(const Duration(days: 120));
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _productController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final field = Field(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      product: _productController.text.trim(),
      sowingDate: _sowingDate,
      harvestDate: _harvestDate,
      latitude: widget.position.latitude,
      longitude: widget.position.longitude,
      area: double.tryParse(_areaController.text) ?? 0,
      notes: _notesController.text.trim(),
    );

    await context.read<FieldProvider>().addField(field);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
              const Text('Yeni Tarla Ekle',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Konum: ${widget.position.latitude.toStringAsFixed(4)}, ${widget.position.longitude.toStringAsFixed(4)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Tarla Adı', Icons.grass),
                validator: (v) =>
                    v!.isEmpty ? 'Tarla adı gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productController,
                decoration: _inputDecoration('Ürün Adı', Icons.eco),
                validator: (v) => v!.isEmpty ? 'Ürün adı gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _areaController,
                decoration: _inputDecoration('Alan (dönüm)', Icons.straighten),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: _inputDecoration('Notlar (isteğe bağlı)', Icons.note),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
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
                      : const Text('Tarla Ekle',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
    );
  }
}
