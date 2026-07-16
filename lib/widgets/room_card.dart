import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../models/room.dart';

/// Card ruangan untuk RoomScreen
class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key,
    required this.room,
    required this.onEdit,
    required this.onDelete,
  });

  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const Map<String, Color> _categoryColors = {
    'Kelas': AppColors.neonLime,
    'Lab': AppColors.electricBlue,
    'Auditorium': AppColors.purple,
  };

  static const Map<String, IconData> _categoryIcons = {
    'Kelas': Icons.class_outlined,
    'Lab': Icons.science_outlined,
    'Auditorium': Icons.theater_comedy_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[room.category] ?? AppColors.white;
    final icon = _categoryIcons[room.category] ?? Icons.room_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.neoBrutalCard(
        borderColor: AppColors.border,
        shadowOffset: 3,
      ),
      child: Row(
        children: [
          // Icon kategori
          Container(
            width: 56,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: color, size: 24),
          ),

          // Info ruangan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.roomName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    room.category,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Aksi
          Row(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.electricBlue, size: 20),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
                tooltip: 'Hapus',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
