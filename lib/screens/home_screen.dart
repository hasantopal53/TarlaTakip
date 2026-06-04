import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../providers/field_provider.dart';
import '../providers/task_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/task_model.dart';
import '../models/field_model.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _lastFieldCount = -1;
  FieldProvider? _fieldProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fieldProvider = context.read<FieldProvider>();
      _lastFieldCount = _fieldProvider!.fields.length;
      _fieldProvider!.addListener(_onFieldsChanged);
      _refreshHomeWeather(context);
    });
  }

  @override
  void dispose() {
    _fieldProvider?.removeListener(_onFieldsChanged);
    super.dispose();
  }

  void _onFieldsChanged() {
    if (!mounted || _fieldProvider == null) return;
    final count = _fieldProvider!.fields.length;
    if (count == _lastFieldCount) return;
    _lastFieldCount = count;
    _refreshHomeWeather(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: RefreshIndicator(
        onRefresh: () async => _refreshHomeWeather(context),
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

  void _refreshHomeWeather(BuildContext context) {
    final fields = context.read<FieldProvider>().fields;
    context.read<WeatherProvider>().loadWeatherForHome(fields);
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
    return Consumer2<FieldProvider, WeatherProvider>(
      builder: (context, fieldProvider, weatherProvider, _) {
        final fields = fieldProvider.fields;
        if (weatherProvider.status == WeatherStatus.initial ||
            weatherProvider.status == WeatherStatus.loading) {
          return _buildLoadingCard(fields);
        }
        if (weatherProvider.status == WeatherStatus.error ||
            weatherProvider.currentWeather == null) {
          return _buildErrorCard(context, weatherProvider, fields);
        }
        return _buildWeatherCard(
            context, weatherProvider, fields);
      },
    );
  }

  Widget _buildLoadingCard(List<Field> fields) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fields.isNotEmpty) ...[
            _HomeFieldSelector(
              fields: fields,
              selectedFieldId: null,
              enabled: false,
              onSelect: (_) {},
            ),
            const SizedBox(height: 16),
          ],
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hava durumu yükleniyor...',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(
      BuildContext context, WeatherProvider provider, List<Field> fields) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (fields.isNotEmpty)
              _HomeFieldSelector(
                fields: fields,
                selectedFieldId: provider.selectedFieldId,
                onSelect: (f) => provider.selectHomeField(f),
              ),
            if (fields.isNotEmpty) const SizedBox(height: 12),
            const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage.isNotEmpty
                  ? provider.errorMessage
                  : 'Hava durumu alınamadı',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                final fields = context.read<FieldProvider>().fields;
                provider.loadWeatherForHome(fields);
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(
      BuildContext context, WeatherProvider provider, List<Field> fields) {
    final weather = provider.currentWeather!;
    final locationLabel = provider.homeFieldName != null
        ? '${provider.homeFieldName} · ${weather.cityName}'
        : weather.cityName;
    return Container(
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
          if (fields.isNotEmpty)
            _HomeFieldSelector(
              fields: fields,
              selectedFieldId: provider.selectedFieldId,
              onSelect: (f) => provider.selectHomeField(f),
            ),
          if (fields.isNotEmpty) const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WeatherScreen()),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                provider.homeFieldName != null
                                    ? Icons.grass
                                    : Icons.location_on,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  locationLabel,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                    ),
                    Image.network(
                      weather.iconUrl,
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny,
                          size: 60, color: Colors.white),
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
        ],
      ),
    );
  }
}

/// Ana sayfa hava kartında tarla seçimi (Tarla1, Tarla2, …).
class _HomeFieldSelector extends StatelessWidget {
  final List<Field> fields;
  final String? selectedFieldId;
  final ValueChanged<Field> onSelect;
  final bool enabled;

  const _HomeFieldSelector({
    required this.fields,
    required this.selectedFieldId,
    required this.onSelect,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tarla seçin',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fields.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final field = fields[index];
              final selected = field.id == selectedFieldId;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled ? () => onSelect(field) : null,
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.grass,
                          size: 16,
                          color: selected
                              ? const Color(0xFF1565C0)
                              : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          field.name,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFF1565C0)
                                : Colors.white,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

