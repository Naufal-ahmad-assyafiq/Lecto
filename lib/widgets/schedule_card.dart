import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/schedule.dart';

/// Card untuk menampilkan satu entri jadwal
class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.schedule,
    this.showDay = false,
  });

  final Schedule schedule;
  final bool showDay;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scheduleColorAt(schedule.colorIndex);
    final bgColor = AppColors.scheduleBgAt(schedule.colorIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ── Accent bar kiri ─────────────────────────────────────────
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Konten ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header baris
                    Row(
                      children: [
                        if (showDay) ...[
                          _badge(schedule.day, color),
                          const SizedBox(width: 6),
                        ],
                        _badge(
                          '${schedule.startTime} – ${schedule.endTime}',
                          color,
                        ),
                        const Spacer(),
                        _badge(
                          '${schedule.course.credits} SKS',
                          AppColors.textMuted,
                          textColor: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Nama & Kode MK
                    Text(
                      schedule.course.courseName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.course.courseCode,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Detail row
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _infoChip(
                          Icons.person_outline,
                          schedule.lecturer.name,
                          AppColors.electricBlue,
                        ),
                        _infoChip(
                          Icons.meeting_room_outlined,
                          schedule.room.roomName,
                          AppColors.purple,
                        ),
                        _infoChip(
                          Icons.school_outlined,
                          'Semester ${schedule.course.semester}',
                          AppColors.neonOrange,
                        ),
                        _infoChip(
                          Icons.account_balance_outlined,
                          schedule.course.programStudi,
                          AppColors.neonLime,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
