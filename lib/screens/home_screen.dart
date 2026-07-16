import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/lecturer_provider.dart';
import '../providers/room_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/neo_button.dart';
import '../widgets/stat_card.dart';


/// Halaman utama — menampilkan statistik dan aksi cepat
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final void Function(int index) onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturers = ref.watch(lecturerProvider);
    final rooms = ref.watch(roomProvider);
    final scheduleState = ref.watch(scheduleProvider);
    final totalCourses = ref.watch(totalCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              const SizedBox(height: 12),
              Row(
                children: [
                  // Logo
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.neonLime,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.bgPrimary, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'L',
                        style: TextStyle(
                          color: AppColors.bgPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LECTO',
                        style: TextStyle(
                          color: AppColors.neonLime,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Lecturer Scheduling Automation',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Greeting ──────────────────────────────────────────────
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kelola jadwal kuliah secara otomatis',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // ── Stats Grid ────────────────────────────────────────────
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    label: 'Dosen',
                    value: '${lecturers.length}',
                    icon: Icons.person_outline,
                    accentColor: AppColors.neonLime,
                  ),
                  StatCard(
                    label: 'Mata Kuliah',
                    value: '$totalCourses',
                    icon: Icons.book_outlined,
                    accentColor: AppColors.electricBlue,
                  ),
                  StatCard(
                    label: 'Ruangan',
                    value: '${rooms.length}',
                    icon: Icons.meeting_room_outlined,
                    accentColor: AppColors.purple,
                  ),
                  StatCard(
                    label: 'Jadwal',
                    value: '${scheduleState.schedules.length}',
                    icon: Icons.calendar_today_outlined,
                    accentColor: AppColors.neonOrange,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Quick Actions ─────────────────────────────────────────
              const Text(
                'Aksi Cepat',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: NeoButton(
                  label: 'Tambah Dosen',
                  icon: Icons.person_add_outlined,
                  color: AppColors.neonLime,
                  textColor: AppColors.bgPrimary,
                  height: 56,
                  fontSize: 15,
                  onPressed: () => onNavigate(1),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: NeoButton(
                  label: 'Generate Jadwal',
                  icon: Icons.auto_fix_high_outlined,
                  color: AppColors.electricBlue,
                  textColor: AppColors.bgPrimary,
                  height: 56,
                  fontSize: 15,
                  onPressed: () => onNavigate(3),
                ),
              ),
              const SizedBox(height: 32),

              // ── Status indicator ──────────────────────────────────────
              if (scheduleState.schedules.isNotEmpty) ...[
                _StatusBanner(count: scheduleState.schedules.length),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.success.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count jadwal berhasil digenerate',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
