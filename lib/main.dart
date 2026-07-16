import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';
import 'core/storage/session_manager.dart';
import 'models/course.dart';
import 'models/history.dart';
import 'models/lecturer.dart';
import 'models/room.dart';
import 'models/schedule.dart';
import 'screens/generate_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lecturer_screen.dart';
import 'screens/room_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale Indonesia
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Hive (IndexedDB di Web)
  await Hive.initFlutter();

  // Daftarkan TypeAdapter
  Hive.registerAdapter(CourseAdapter());
  Hive.registerAdapter(LecturerAdapter());
  Hive.registerAdapter(RoomAdapter());
  Hive.registerAdapter(ScheduleAdapter());
  Hive.registerAdapter(HistoryAdapter());

  // Buka semua box
  await Future.wait([
    Hive.openBox<Lecturer>('lecturers'),
    Hive.openBox<Room>('rooms'),
    Hive.openBox<Schedule>('schedules'),
    Hive.openBox<History>('histories'),
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgSecondary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: LectoApp()));
}

/// Root widget aplikasi
class LectoApp extends StatelessWidget {
  const LectoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lecto — Lecturer Scheduling',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

// ─── Splash Screen ───────────────────────────────────────────────────────────

/// Halaman awal — loading data & restore session
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  String _loadingStatus = 'Memulai aplikasi...';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runBootstrap());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _runBootstrap() async {
    await Future.delayed(const Duration(milliseconds: 400));

    _setStatus('Loading Local Storage...');
    await Future.delayed(const Duration(milliseconds: 300));

    _setStatus('Loading Lecturers...');
    await Future.delayed(const Duration(milliseconds: 250));

    _setStatus('Loading Rooms...');
    await Future.delayed(const Duration(milliseconds: 250));

    _setStatus('Loading Schedule...');
    await Future.delayed(const Duration(milliseconds: 250));

    _setStatus('Loading Completed ✓');
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    // Cek dan tampilkan dialog restore session
    await SessionManager.initialize(context, ref);

    if (!mounted) return;

    // Navigasi ke dashboard
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LectoShell(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _setStatus(String status) {
    if (mounted) setState(() => _loadingStatus = status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 16),
                const Text(
                  'Automatic Lecturer Scheduling',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 72),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.neonLime.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _loadingStatus,
                    key: ValueKey(_loadingStatus),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.neonLime,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
        ],
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: const Text(
        'LECTO',
        style: TextStyle(
          color: Colors.black,
          fontSize: 42,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
          height: 1,
        ),
      ),
    );
  }
}

// ─── Lecto Shell ─────────────────────────────────────────────────────────────

/// Shell utama dengan Bottom Navigation
class LectoShell extends ConsumerStatefulWidget {
  const LectoShell({super.key});

  @override
  ConsumerState<LectoShell> createState() => _LectoShellState();
}

class _LectoShellState extends ConsumerState<LectoShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(onNavigate: _onNavTap),
      const LecturerScreen(),
      const RoomScreen(),
      const GenerateScreen(),
      const HistoryScreen(),
    ];
  }

  void _onNavTap(int index) => setState(() => _currentIndex = index);

  static const _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Dosen',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.meeting_room_outlined),
      activeIcon: Icon(Icons.meeting_room),
      label: 'Ruangan',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.auto_fix_high_outlined),
      activeIcon: Icon(Icons.auto_fix_high),
      label: 'Generate',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.history_outlined),
      activeIcon: Icon(Icons.history),
      label: 'Riwayat',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
          items: _navItems,
        ),
      ),
    );
  }
}
