import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'features/balance/balance_screen.dart';
import 'features/stock/stock_screen.dart';
import 'features/sales/sales_screen.dart';
import 'features/settings/settings_screen.dart';
import 'models/product.dart';
import 'models/sale.dart';
import 'models/settings.dart';
import 'data/repositories/settings_repository.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  await _registerHiveAdapters();
  
  runApp(
    const ProviderScope(
      child: TODAChicApp(),
    ),
  );
}

Future<void> _registerHiveAdapters() async {
  // Register Product adapter (typeId: 0)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ProductAdapter());
  }
  
  // Register Sale adapter (typeId: 1)
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(SaleAdapter());
  }
  
  // Register StockLevel enum adapter (typeId: 2)
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(StockLevelAdapter());
  }
  
  // Register Size enum adapter (typeId: 3)  
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(SizeAdapter());
  }
  
  // Register PriceMode enum adapter (typeId: 4)
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(PriceModeAdapter());
  }
  
  // Register Settings adapter (typeId: 5)
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(SettingsAdapter());
  }
}

class TODAChicApp extends ConsumerWidget {
  const TODAChicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsRepositoryProvider);
    
    return MaterialApp.router(
      title: 'TODAChic Clean',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), // Spanish
        Locale('en'), // English
      ],
      locale: const Locale('es'),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AppShell(),
    ),
    GoRoute(
      path: '/stock',
      builder: (context, state) => const StockScreen(),
    ),
    GoRoute(
      path: '/sales',
      builder: (context, state) => const SalesScreen(),
    ),
    GoRoute(
      path: '/balance',
      builder: (context, state) => const BalanceScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _showSplash = true;
  int _currentIndex = 0;

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.inventory_2),
      selectedIcon: Icon(Icons.inventory_2),
      label: 'Stock',
    ),
    NavigationDestination(
      icon: Icon(Icons.point_of_sale),
      selectedIcon: Icon(Icons.point_of_sale),
      label: 'Ventas',
    ),
    NavigationDestination(
      icon: Icon(Icons.analytics),
      selectedIcon: Icon(Icons.analytics),
      label: 'Balance',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings),
      selectedIcon: Icon(Icons.settings),
      label: 'Configuración',
    ),
  ];

  final List<Widget> _screens = const [
    StockScreen(),
    SalesScreen(),
    BalanceScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onComplete: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const TODAChicLogo(
          fontSize: 24,
          showButterflies: false,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _destinations,
        elevation: 8,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const TODAChicLogo(
          fontSize: 24,
          showButterflies: false,
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Bienvenido a TODAChic',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sistema de gestión de tienda',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TODAChicLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final bool showButterflies;
  final bool isLight;

  const TODAChicLogo({
    super.key,
    required this.fontSize,
    this.color,
    this.showButterflies = false,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showButterflies) ...[
          Icon(
            Icons.flutter_dash,
            size: fontSize * 0.8,
            color: textColor.withOpacity(0.7),
          ),
          SizedBox(width: fontSize * 0.2),
        ],
        Text(
          'TODA',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          'Chic',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
            color: textColor.withOpacity(0.8),
            fontStyle: FontStyle.italic,
          ),
        ),
        if (showButterflies) ...[
          SizedBox(width: fontSize * 0.2),
          Icon(
            Icons.flutter_dash,
            size: fontSize * 0.8,
            color: textColor.withOpacity(0.7),
          ),
        ],
      ],
    );
  }
}