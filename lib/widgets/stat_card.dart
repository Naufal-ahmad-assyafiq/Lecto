import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';

/// Card statistik untuk Home Screen
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor = AppColors.neonLime,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.neoBrutalCard(
        color: AppColors.bgCard,
        borderColor: accentColor.withOpacity(0.5),
        borderWidth: 2,
        shadowOffset: 3,
        shadowColor: Colors.black,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: accentColor.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
