import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WeatherProvider>();
      if (provider.status == WeatherStatus.initial) {
        provider.loadWeather();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Hava Durumu'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WeatherProvider>().loadWeather(),
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
              onRetry: provider.loadWeather,
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

class _CurrentWeatherTab extends StatelessWidget {
  final CurrentWeather weather;

  const _CurrentWeatherTab({required this.weather});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
                  weather.cityName,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      weather.iconUrl,
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.wb_cloudy,
                          size: 60,
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
                Image.network(
                  day.iconUrl,
                  width: 40,
                  height: 40,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.cloud, size: 36),
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
              'API anahtarınızın doğru olduğundan emin olun.',
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
