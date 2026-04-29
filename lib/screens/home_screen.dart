import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../providers/task_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/task_model.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: RefreshIndicator(
        onRefresh: () => context.read<WeatherProvider>().loadWeather(),
        color: const Color(0xFF2E7D32),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WeatherCard(),
                    const SizedBox(height: 16),
                    _IrrigationCard(),
                    const SizedBox(height: 20),
                    _SectionHeader(
                      title: 'Yaklaşan Görevler',
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 8),
                    _UpcomingTasksList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF2E7D32),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Merhaba, Çiftçi 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    DateFormat('d MMMM yyyy, EEEE', 'tr').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }
}

class _WeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        if (provider.status == WeatherStatus.loading) {
          return _buildLoadingCard();
        }
        if (provider.status == WeatherStatus.error ||
            provider.currentWeather == null) {
          return _buildErrorCard(context, provider);
        }
        return _buildWeatherCard(context, provider);
      },
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, WeatherProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            const Text('Hava durumu alınamadı',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => provider.loadWeather(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, WeatherProvider provider) {
    final weather = provider.currentWeather!;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WeatherScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          weather.cityName,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      '${weather.temperature.toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weather.description.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                Image.network(
                  weather.iconUrl,
                  width: 80,
                  height: 80,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.wb_sunny, size: 60, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WeatherStat(
                    icon: Icons.thermostat,
                    label: 'Hissedilen',
                    value: '${weather.feelsLike.toStringAsFixed(0)}°C'),
                _WeatherStat(
                    icon: Icons.water_drop,
                    label: 'Nem',
                    value: '%${weather.humidity.toStringAsFixed(0)}'),
                _WeatherStat(
                    icon: Icons.air,
                    label: 'Rüzgar',
                    value: '${weather.windSpeed.toStringAsFixed(1)} m/s'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherStat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

class _IrrigationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final suggestion = provider.currentWeather?.irrigationSuggestion ??
            '📡 Hava verisi yükleniyor...';

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFFE8F5E9),
          elevation: 0,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.water_drop,
                      color: Color(0xFF2E7D32), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sulama Önerisi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        suggestion,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }
}

class _UpcomingTasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final tasks = provider.upcomingTasks.take(3).toList();
        if (tasks.isEmpty) {
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            color: Colors.white,
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.task_alt, size: 36, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Bu hafta görev yok',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          );
        }
        return Column(
          children: tasks
              .map((task) => _TaskItem(task: task))
              .toList(),
        );
      },
    );
  }
}

class _TaskItem extends StatelessWidget {
  final AppTask task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final daysLeft = task.dueDate.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 1;

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isUrgent
                ? Colors.red.shade50
                : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              AppTask.typeIcon(task.type),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(task.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          DateFormat('d MMM', 'tr').format(task.dueDate),
          style: TextStyle(
              color: isUrgent ? Colors.red : Colors.grey,
              fontSize: 12),
        ),
        trailing: isUrgent
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Acil',
                    style: TextStyle(color: Colors.red, fontSize: 11)),
              )
            : Text(
                '$daysLeft gün',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(icon: Icons.grass, label: 'Tarlalarım', color: const Color(0xFF2E7D32), index: 2),
      _Action(icon: Icons.attach_money, label: 'Maliyetler', color: Colors.orange, index: 3),
      _Action(icon: Icons.task_alt, label: 'Görevler', color: Colors.blue, index: 4),
      _Action(icon: Icons.cloud, label: 'Hava', color: const Color(0xFF1565C0), index: -1),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: actions.map((a) {
        return GestureDetector(
          onTap: () {
            if (a.index == -1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeatherScreen()),
              );
            } else {
              context.read<NavigationProvider>().setIndex(a.index);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: a.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: a.color.withValues(alpha: 0.3), width: 1),
                ),
                child: Icon(a.icon, color: a.color, size: 26),
              ),
              const SizedBox(height: 4),
              Text(
                a.label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.black87),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final int index;
  const _Action(
      {required this.icon,
      required this.label,
      required this.color,
      required this.index});
}

