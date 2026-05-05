import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/skin_analysis_result.dart';
import '../utils/constants.dart';

class SkinCard extends StatelessWidget {
  final SkinAnalysisResult result;
  final VoidCallback? onTap;

  const SkinCard({super.key, required this.result, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 38,
                lineWidth: 7,
                percent: result.skinScore / 100,
                center: Text(
                  '${result.skinScore}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _scoreColor(result.skinScore),
                  ),
                ),
                progressColor: _scoreColor(result.skinScore),
                backgroundColor: cs.surfaceContainerHighest,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.scoreLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: result.imageLabels
                          .take(3)
                          .map((l) => _LabelChip(label: l.label))
                          .toList(),
                    ),
                  ],
                ),
              ),

              if (onTap != null)
                Icon(Icons.chevron_right,
                    color: cs.onSurface.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.info;
    return AppColors.error;
  }
}

class _LabelChip extends StatelessWidget {
  final String label;
  const _LabelChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}
