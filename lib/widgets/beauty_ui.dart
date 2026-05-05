import 'package:flutter/material.dart';

import '../utils/constants.dart';

class BeautyGradientBackground extends StatelessWidget {
  const BeautyGradientBackground({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? const [Color(0xFF201018), Color(0xFF130D11), Color(0xFF241313)]
              : const [Color(0xFFFFF4F9), Color(0xFFFFF8F1), Color(0xFFFFEEF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class BeautyCard extends StatelessWidget {
  const BeautyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 28,
    this.margin,
    this.color,
    this.border,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Border? border;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: AppColors.hotPink.withValues(alpha: .08)),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? .20 : .06),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: AppColors.hotPink.withValues(alpha: isDark ? .10 : .08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.beautyGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? .55 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.beautyGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.hotPink.withValues(alpha: .30),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 21),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BeautyCircleIcon extends StatelessWidget {
  const BeautyCircleIcon({
    super.key,
    required this.icon,
    this.color = AppColors.hotPink,
    this.size = 48,
    this.background,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final double size;
  final Color? background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * .46),
    );

    if (onTap == null) return child;
    return InkWell(onTap: onTap, customBorder: const CircleBorder(), child: child);
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GradientText(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }
}

class PhoneMockup extends StatelessWidget {
  const PhoneMockup({
    super.key,
    required this.child,
    this.height = 360,
    this.background = const Color(0xFFFFF1F8),
  });

  final Widget child;
  final double height;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 285, minHeight: height),
      padding: const EdgeInsets.fromLTRB(12, 22, 12, 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(42),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(31),
            child: SizedBox(
              height: height - 34,
              width: double.infinity,
              child: ColoredBox(
                color: background,
                child: ClipRect(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: height - 34),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class SafetyDot extends StatelessWidget {
  const SafetyDot({super.key, required this.color, this.size = 16});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
