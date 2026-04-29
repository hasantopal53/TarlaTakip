import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _locationEnabled = false;
  Position? _currentPosition;
  bool _loadingLocation = false;
  LocationPermission _locationPermission = LocationPermission.denied;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final notifEnabled =
        await NotificationService.areNotificationsEnabled();
    final locPermission = await LocationService.getPermissionStatus();
    final locEnabled = await LocationService.isLocationServiceEnabled();

    setState(() {
      _notificationsEnabled = notifEnabled;
      _locationPermission = locPermission;
      _locationEnabled = locEnabled &&
          locPermission != LocationPermission.denied &&
          locPermission != LocationPermission.deniedForever;
    });
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _loadingLocation = true);
    final position = await LocationService.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _loadingLocation = false;
    });
  }

  Future<void> _toggleLocation(bool value) async {
    if (value) {
      final permission = await Geolocator.requestPermission();
      setState(() {
        _locationPermission = permission;
        _locationEnabled = permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever;
      });
      if (_locationEnabled) _loadCurrentLocation();
    } else {
      await LocationService.openSettings();
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final granted = await NotificationService.requestPermission();
      setState(() => _notificationsEnabled = granted);
    } else {
      await Geolocator.openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Konum bölümü
          _SectionHeader(title: 'Konum'),
          _SettingsCard(
            children: [
              SwitchListTile(
                secondary: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on,
                      color: Color(0xFF2E7D32), size: 22),
                ),
                title: const Text('Konum İzni',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(_locationPermissionText()),
                value: _locationEnabled,
                onChanged: _toggleLocation,
                activeThumbColor: const Color(0xFF4CAF50),
              ),
              if (_locationEnabled) ...[
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.gps_fixed,
                        color: Color(0xFF1565C0), size: 22),
                  ),
                  title: const Text('Mevcut Konum',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: _loadingLocation
                      ? const Text('Konum alınıyor...',
                          style: TextStyle(color: Colors.grey))
                      : Text(
                          _currentPosition != null
                              ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}\nLon: ${_currentPosition!.longitude.toStringAsFixed(5)}'
                              : 'Konum alınamadı',
                          style: TextStyle(
                            color: _currentPosition != null
                                ? Colors.black87
                                : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                  trailing: _loadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.refresh,
                              color: Color(0xFF2E7D32)),
                          onPressed: _loadCurrentLocation,
                          tooltip: 'Konumu Yenile',
                        ),
                ),
              ],
            ],
          ),

          // Bildirimler bölümü
          _SectionHeader(title: 'Bildirimler'),
          _SettingsCard(
            children: [
              SwitchListTile(
                secondary: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications,
                      color: Colors.orange, size: 22),
                ),
                title: const Text('Bildirim İzni',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(_notificationsEnabled
                    ? 'Görev hatırlatıcıları aktif'
                    : 'Bildirimler kapalı'),
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeThumbColor: const Color(0xFF4CAF50),
              ),
              const Divider(height: 1, indent: 72),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.schedule,
                      color: Colors.purple, size: 22),
                ),
                title: const Text('Bildirim Zamanı',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('Görev günü sabah 08:00'),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ),
            ],
          ),

          // Uygulama ayarları
          _SectionHeader(title: 'Uygulama'),
          _SettingsCard(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.language,
                      color: Color(0xFF2E7D32), size: 22),
                ),
                title: const Text('Dil',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('Türkçe'),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ),
              const Divider(height: 1, indent: 72),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.cloud_sync,
                      color: Color(0xFF1565C0), size: 22),
                ),
                title: const Text('API Anahtarları',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('WeatherMap & Google Maps'),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
                onTap: () => _showApiInfoDialog(context),
              ),
            ],
          ),

          // Hakkında bölümü
          _SectionHeader(title: 'Hakkında'),
          _SettingsCard(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline,
                      color: Color(0xFF2E7D32), size: 22),
                ),
                title: const Text('TarlaTakip',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('v1.0.0 • Akıllı Tarım Asistanı'),
              ),
              const Divider(height: 1, indent: 72),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.star_outline,
                      color: Colors.orange, size: 22),
                ),
                title: const Text('Uygulamayı Değerlendir',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('Google Play Store'),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ),
              const Divider(height: 1, indent: 72),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bug_report,
                      color: Colors.red, size: 22),
                ),
                title: const Text('Hata Bildir',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('destek@tarlatakip.com'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'TarlaTakip © 2026\nYapılmış 🌱 ile',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _locationPermissionText() {
    switch (_locationPermission) {
      case LocationPermission.always:
        return 'Her zaman aktif';
      case LocationPermission.whileInUse:
        return 'Uygulama açıkken aktif';
      case LocationPermission.denied:
        return 'İzin verilmedi';
      case LocationPermission.deniedForever:
        return 'Kalıcı olarak reddedildi - Ayarlardan açın';
      default:
        return 'Bilinmiyor';
    }
  }

  void _showApiInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('API Anahtarları'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OpenWeatherMap API:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('lib/services/weather_service.dart\ndosyasındaki _apiKey değişkenini güncelleyin',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            SizedBox(height: 12),
            Text('Google Maps API:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                'android/app/src/main/AndroidManifest.xml\ndosyasındaki YOUR_GOOGLE_MAPS_API_KEY değerini güncelleyin',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        child: Column(children: children),
      ),
    );
  }
}
