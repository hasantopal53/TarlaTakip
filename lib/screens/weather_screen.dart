import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/weather_provider.dart';
import '../providers/field_provider.dart';
import '../services/weather_service.dart';
import '../models/field_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = context.read<WeatherProvider>();
      final fieldProvider = context.read<FieldProvider>();
      
      if (weatherProvider.status == WeatherStatus.initial) {
        weatherProvider.loadWeatherForHome(fieldProvider.fields);
      }
      
      // Tarlalar için hava durumunu arka planda yükle
      if (fieldProvider.fields.isNotEmpty) {
        weatherProvider.loadWeatherForFields(fieldProvider.fields);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    if (_searchController.text.trim().isNotEmpty) {
      context
          .read<WeatherProvider>()
          .loadWeatherByCity(_searchController.text.trim());
      setState(() => _isSearching = false);
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Şehir ara (Örn: Konya)',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSearch(),
                autofocus: true,
              )
            : const Text('Hava Durumu'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) _searchController.clear();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final fields = context.read<FieldProvider>().fields;
              context.read<WeatherProvider>().loadWeatherForHome(fields);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Güncel', icon: Icon(Icons.wb_sunny, size: 18)),
            Tab(text: '5 Günlük', icon: Icon(Icons.date_range, size: 18)),
          ],
        ),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          if (provider.status == WeatherStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1565C0)),
            );
          }
          if (provider.status == WeatherStatus.error) {
            return _ErrorView(
              message: provider.errorMessage,
              onRetry: () {
                final fields = context.read<FieldProvider>().fields;
                provider.loadWeatherForHome(fields);
              },
            );
          }
          if (provider.currentWeather == null) {
            return const Center(child: Text('Veri bulunamadı'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _CurrentWeatherTab(weather: provider.currentWeather!),
              _ForecastTab(forecast: provider.forecast),
            ],
          );
        },
      ),
    );
  }
}

String _weatherTitle(List<Field> fields, String? selectedId, String cityName) {
  if (selectedId == null) return cityName;
  for (final f in fields) {
    if (f.id == selectedId) return '${f.name} - $cityName';
  }
  return cityName;
}

class _CurrentWeatherTab extends StatelessWidget {
  final CurrentWeather weather;

  const _CurrentWeatherTab({required this.weather});

  @override
  Widget build(BuildContext context) {
    final fields = context.watch<FieldProvider>().fields;
    final weatherProvider = context.watch<WeatherProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fields.isNotEmpty) ...[
            const Text(
              'Tarlalarınızın Hava Durumu',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fields.length,
                itemBuilder: (context, index) {
                  final field = fields[index];
                  final isSelected = weatherProvider.selectedFieldId == field.id;
                  final fieldWeather = weatherProvider.fieldWeather[field.id];

                  return GestureDetector(
                    onTap: () => context.read<WeatherProvider>().selectFieldWeather(field),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1565C0) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            field.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (fieldWeather != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: fieldWeather.iconUrl,
                                  width: 30,
                                  height: 30,
                                  placeholder: (context, url) => const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 1)),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.wb_cloudy,
                                          size: 20, color: Colors.blueGrey),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${fieldWeather.temperature.toStringAsFixed(0)}°C',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF1565C0),
                                  ),
                                ),
                              ],
                            ),
                          ] else
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Ana hava kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ),
            ),
            child: Column(
              children: [
                Text(
                  _weatherTitle(
                      fields, weatherProvider.selectedFieldId, weather.cityName),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: weather.iconUrl,
                      width: 100,
                      height: 100,
                      placeholder: (context, url) => const SizedBox(
                        width: 100,
                        height: 100,
                        child: Center(
                            child: CircularProgressIndicator(color: Colors.white)),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                          Icons.wb_cloudy,
                          size: 80,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  weather.description.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'En düşük ${weather.tempMin.toStringAsFixed(0)}° / En yüksek ${weather.tempMax.toStringAsFixed(0)}°',
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBox(
                        icon: Icons.thermostat,
                        label: 'Hissedilen',
                        value: '${weather.feelsLike.toStringAsFixed(0)}°C'),
                    _StatBox(
                        icon: Icons.water_drop,
                        label: 'Nem',
                        value: '%${weather.humidity.toStringAsFixed(0)}'),
                    _StatBox(
                        icon: Icons.air,
                        label: 'Rüzgar',
                        value: '${weather.windSpeed.toStringAsFixed(1)} m/s'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Sulama tavsiyesi
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFFE8F5E9),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.water_drop,
                          color: Color(0xFF2E7D32), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Bu Hafta Sulama Tavsiyesi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    weather.irrigationSuggestion,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _IrrigationTip(
                      icon: '🌡️',
                      tip: 'Sıcaklık 30°C üzerindeyse günlük sulama yapın'),
                  const SizedBox(height: 6),
                  _IrrigationTip(
                      icon: '💧',
                      tip: 'Sabah erken veya akşamüzeri sulama tercih edin'),
                  const SizedBox(height: 6),
                  _IrrigationTip(
                      icon: '☔',
                      tip: 'Yağmur öncesi sulamayı atlayabilirsiniz'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBox(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}

class _IrrigationTip extends StatelessWidget {
  final String icon;
  final String tip;

  const _IrrigationTip({required this.icon, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(tip, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}

class _ForecastTab extends StatelessWidget {
  final List<WeatherForecast> forecast;

  const _ForecastTab({required this.forecast});

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) {
      return const Center(child: Text('Tahmin verisi yok'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: forecast.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final day = forecast[index];
        final isToday = index == 0;

        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: isToday ? 2 : 0,
          color: isToday ? const Color(0xFF1565C0) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday
                            ? 'Bugün'
                            : DateFormat('EEE', 'tr').format(day.date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        DateFormat('d MMM', 'tr').format(day.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday
                              ? Colors.white70
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                CachedNetworkImage(
                  imageUrl: day.iconUrl,
                  width: 45,
                  height: 45,
                  placeholder: (context, url) => const SizedBox(
                      width: 45,
                      height: 45,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.cloud, size: 36, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    day.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isToday ? Colors.white70 : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_drop,
                            size: 14,
                            color: isToday
                                ? Colors.white70
                                : Colors.blueGrey),
                        const SizedBox(width: 2),
                        Text(
                          '%${(day.pop * 100).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isToday
                                ? Colors.white70
                                : Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.maxTemp.toStringAsFixed(0)}° / ${day.minTemp.toStringAsFixed(0)}°',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.opacity,
                            size: 12,
                            color: isToday
                                ? Colors.white60
                                : Colors.grey),
                        const SizedBox(width: 2),
                        Text(
                          '%${day.humidity.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isToday
                                ? Colors.white60
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Hava Durumu Alınamadı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Konum alınamadı veya şehir bulunamadı. Lütfen arama özelliğini kullanın veya GPS\'inizi kontrol edin.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
