import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../models/lecturer.dart';

/// Card dosen untuk ditampilkan di LecturerScreen
class LecturerCard extends StatelessWidget {
  const LecturerCard({
    super.key,
    required this.lecturer,
    required this.onEdit,
    required this.onDelete,
  });

  final Lecturer lecturer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isPagi = lecturer.preference == 'Pagi';
    final prefColor = isPagi ? AppColors.neonLime : AppColors.electricBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.neoBrutalCard(
        borderColor: AppColors.border,
        shadowOffset: 3,
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: prefColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: prefColor.withOpacity(0.4), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      lecturer.name.isNotEmpty
                          ? lecturer.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: prefColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info dosen
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lecturer.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lecturer.email,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Preferensi badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: prefColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: prefColor.withOpacity(0.4), width: 1.5),
                  ),
                  child: Text(
                    lecturer.preference,
                    style: TextStyle(
                      color: prefColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Daftar MK ─────────────────────────────────────────────────
          if (lecturer.courses.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${lecturer.courses.length} Mata Kuliah',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: lecturer.courses.map((c) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bgCardAlt,
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Text(
                          '${c.courseCode} · ${c.credits} SKS',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

          // ── Aksi ──────────────────────────────────────────────────────
          const Divider(height: 1, color: AppColors.border),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.electricBlue),
                  label: const Text('Edit',
                      style: TextStyle(
                          color: AppColors.electricBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.border),
              Expanded(
                child: TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: AppColors.error),
                  label: const Text('Hapus',
                      style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
