import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../models/skin_analysis_result.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import '../widgets/path_image.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<HistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = StorageService().loadHistory();
  }

  Future<void> _open(HistoryItem item) async {
    final result = await StorageService().loadFullResult(item.id);
    if (!mounted || result == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
    setState(() => _future = StorageService().loadHistory());
  }

  Future<void> _clear() async {
    await StorageService().clearAll();
    if (mounted) setState(() => _future = StorageService().loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: FutureBuilder<List<HistoryItem>>(
            future: _future,
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <HistoryItem>[];
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                children: [
                  Row(
                    children: [
                      BeautyCircleIcon(
                        icon: Icons.arrow_back_ios_new_rounded,
                        size: 44,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: GradientText('Historique',
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                      ),
                      if (items.isNotEmpty)
                        BeautyCircleIcon(
                          icon: Icons.delete_outline_rounded,
                          size: 44,
                          onTap: _clear,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator(color: AppColors.hotPink))
                  else if (items.isEmpty)
                    BeautyCard(
                      child: Column(
                        children: const [
                          Icon(Icons.history_rounded, color: AppColors.hotPink, size: 72),
                          SizedBox(height: 12),
                          Text('Aucune analyse sauvegardée',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          SizedBox(height: 6),
                          Text('Sauvegardez un résultat après un scan visage.'),
                        ],
                      ),
                    )
                  else
                    ...items.map((item) => _HistoryTile(item: item, onTap: () => _open(item))),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item, required this.onTap});
  final HistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: BeautyCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 78,
                  height: 78,
                  child: PathImage(
                    path: item.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.blush,
                      child: const Icon(Icons.face_retouching_natural_rounded, color: AppColors.hotPink),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.skinScore}% • ${item.scoreLabel}',
                        style: const TextStyle(color: AppColors.hotPink, fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(item.formattedDate, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      item.topLabels.isEmpty ? 'ML Kit analysis' : item.topLabels.join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .58)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.hotPink),
            ],
          ),
        ),
      ),
    );
  }
}
