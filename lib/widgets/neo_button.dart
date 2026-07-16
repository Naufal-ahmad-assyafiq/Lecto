import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Tombol Neo-Brutalism dengan shadow tebal dan border hitam
class NeoButton extends StatefulWidget {
  const NeoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.neonLime,
    this.textColor = AppColors.bgPrimary,
    this.width,
    this.height = 52,
    this.fontSize = 15,
    this.isLoading = false,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final double? width;
  final double height;
  final double fontSize;
  final bool isLoading;
  final Color? borderColor;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _offset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.03, 0.06),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final effectiveColor =
        isDisabled ? AppColors.textMuted : widget.color;
    final effectiveBorderColor = widget.borderColor ?? AppColors.bgPrimary;

    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTapCancel: isDisabled ? null : _onTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _offset.value.dx * 4,
              _offset.value.dy * 4,
            ),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDisabled
                      ? AppColors.border
                      : effectiveBorderColor,
                  width: 2,
                ),
                boxShadow: isDisabled
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          offset: Offset(
                            4 - _offset.value.dx * 4,
                            4 - _offset.value.dy * 4,
                          ),
                          blurRadius: 0,
                        ),
                      ],
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: widget.textColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: isDisabled
                                ? AppColors.textMuted
                                : widget.textColor,
                            size: widget.fontSize + 2,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: isDisabled
                                ? AppColors.textMuted
                                : widget.textColor,
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
