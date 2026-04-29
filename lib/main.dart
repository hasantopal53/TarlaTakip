import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/field_model.dart';
import 'models/cost_model.dart';
import 'models/task_model.dart';
import 'providers/field_provider.dart';
import 'providers/cost_provider.dart';
import 'providers/task_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/navigation_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/field_screen.dart';
import 'screens/cost_screen.dart';
import 'screens/task_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatı
  await initializeDateFormatting('tr', null);

  // Hive başlatma
  await Hive.initFlutter();
  Hive.registerAdapter(FieldAdapter());
  Hive.registerAdapter(CostAdapter());
  Hive.registerAdapter(AppTaskAdapter());
  await Hive.openBox<Field>('fields');
  await Hive.openBox<Cost>('costs');
  await Hive.openBox<AppTask>('tasks');

  // Bildirim servisi başlat
  await NotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FieldProvider()),
        ChangeNotifierProvider(create: (_) => CostProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const TarlaTakipApp(),
    ),
  );
}

class TarlaTakipApp extends StatelessWidget {
  const TarlaTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TarlaTakip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12);
            }
            return const TextStyle(color: Colors.grey, fontSize: 11);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF2E7D32));
            }
            return const IconThemeData(color: Colors.grey);
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
        ),
      ),
      home: const MainScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/weather': (context) => const WeatherScreen(),
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    MapScreen(),
    FieldScreen(),
    CostScreen(),
    TaskScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final currentIndex = navProvider.currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      drawer: _AppDrawer(
        currentIndex: currentIndex,
        onSelect: (index) {
          context.read<NavigationProvider>().setIndex(index);
          Navigator.pop(context);
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) =>
            context.read<NavigationProvider>().setIndex(index),
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Harita',
          ),
          NavigationDestination(
            icon: Icon(Icons.grass_outlined),
            selectedIcon: Icon(Icons.grass),
            label: 'Tarlalar',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Maliyetler',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Görevler',
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _AppDrawer(
      {required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.grass,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                const Text(
                  'TarlaTakip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Akıllı Tarım Asistanı',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                    icon: Icons.dashboard,
                    label: 'Ana Sayfa',
                    index: 0,
                    selected: currentIndex == 0,
                    onTap: onSelect),
                _DrawerItem(
                    icon: Icons.map,
                    label: 'Tarla Haritası',
                    index: 1,
                    selected: currentIndex == 1,
                    onTap: onSelect),
                _DrawerItem(
                    icon: Icons.grass,
                    label: 'Tarla Yönetimi',
                    index: 2,
                    selected: currentIndex == 2,
                    onTap: onSelect),
                _DrawerItem(
                    icon: Icons.account_balance_wallet,
                    label: 'Maliyet Takibi',
                    index: 3,
                    selected: currentIndex == 3,
                    onTap: onSelect),
                _DrawerItem(
                    icon: Icons.task,
                    label: 'Görevler',
                    index: 4,
                    selected: currentIndex == 4,
                    onTap: onSelect),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cloud,
                      color: Color(0xFF1565C0)),
                  title: const Text('Hava Durumu'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/weather');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings,
                      color: Colors.grey),
                  title: const Text('Ayarlar'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final ValueChanged<int> onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? const Color(0xFF2E7D32) : Colors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFF2E7D32) : Colors.black87,
          fontWeight:
              selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: const Color(0xFFE8F5E9),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      onTap: () => onTap(index),
    );
  }
}
