import 'package:flutter/material.dart';

class AppLogoBadge extends StatelessWidget {
  final double size;

  const AppLogoBadge({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/app/app_icon.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
