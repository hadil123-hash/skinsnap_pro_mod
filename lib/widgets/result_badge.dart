import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ResultBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData? icon;

  const ResultBadge({
    super.key,
    required this.text,
    this.color,
    this.icon,
  });

  factory ResultBadge.success(String text) => ResultBadge(
      text: text, color: AppColors.success, icon: Icons.check_circle_outline);

  factory ResultBadge.warning(String text) => ResultBadge(
      text: text, color: AppColors.warning, icon: Icons.warning_amber_outlined);

  factory ResultBadge.info(String text) =>
      ResultBadge(text: text, color: AppColors.info, icon: Icons.info_outline);

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: badgeColor),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
