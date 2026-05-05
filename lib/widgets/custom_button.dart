import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ButtonVariant { primary, outline, ghost }

class CustomButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final ButtonVariant variant;
  final bool loading;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.variant = ButtonVariant.primary,
    this.loading = false,
    this.width,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = widget.onTap != null && !widget.loading;
    final isPrimary = widget.variant == ButtonVariant.primary;
    final isOutline = widget.variant == ButtonVariant.outline;

    final bg = isPrimary ? cs.primary : Colors.transparent;
    final fg = isPrimary ? cs.onPrimary : cs.primary;
    final border = isOutline ? Border.all(color: cs.primary, width: 2) : null;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: enabled ? 1 : 0.55,
          child: Container(
            width: widget.width,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: border,
              boxShadow: isPrimary && !_pressed
                  ? [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: .35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: widget.loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: fg,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: fg, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
