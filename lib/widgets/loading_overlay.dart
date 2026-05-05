import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;
  const LoadingOverlay({super.key, this.message = 'Analyse en cours…'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1200.ms, color: AppColors.accent),

              const SizedBox(height: AppSpacing.md),

              Text(
                message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 800.ms)
                  .then()
                  .fadeOut(duration: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
