import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/beauty_plan.dart';
import '../models/firestore_content.dart';
import '../providers/app_provider.dart';
import '../providers/beauty_plan_provider.dart';
import '../services/product_service.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import '../widgets/product_card.dart';
import 'product_match_screen.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final ProductService _service = ProductService();
  DateTime _selectedDay = DateTime.now();
  RoutineMoment _moment = RoutineMoment.morning;
  final Set<String> _done = <String>{};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadDone();
  }

  String get _dayKey => '${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}-${_moment.name}';
  String _itemKey(String id) => 'routine_done_${_dayKey}_$id';

  Future<void> _loadDone() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('routine_done_${_dayKey}_'));
    if (!mounted) return;
    setState(() {
      _done
        ..clear()
        ..addAll(keys.map((key) => key.replaceFirst('routine_done_${_dayKey}_', '')));
      _loaded = true;
    });
  }

  Future<void> _selectDay(DateTime day) async {
    setState(() {
      _selectedDay = day;
      _loaded = false;
      _done.clear();
    });
    await _loadDone();
  }

  Future<void> _setMoment(RoutineMoment moment) async {
    setState(() {
      _moment = moment;
      _loaded = false;
      _done.clear();
    });
    await _loadDone();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) await _selectDay(picked);
  }

  Future<void> _toggle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _itemKey(id);
    final next = !_done.contains(id);
    if (next) {
      await prefs.setBool(key, true);
    } else {
      await prefs.remove(key);
    }
    await SoundService().feedbackSave();
    if (!mounted) return;
    setState(() {
      if (next) {
        _done.add(id);
      } else {
        _done.remove(id);
      }
    });

    final app = context.read<AppProvider>();
    final service = NotificationService();
    final routineStream = _service.userRoutineProducts();
    final products = await routineStream.first;
    final planItems = _fromPlan(context.read<BeautyPlanProvider>().currentPlan);
    final currentItems = products.isNotEmpty ? _fromProducts(products) : planItems;
    final isComplete = currentItems.isNotEmpty && currentItems.every((item) => _done.contains(item.id));
    if (app.notificationsOn && isComplete) {
      await service.onRoutineCompleted(
        morning: _moment == RoutineMoment.morning,
        title: _moment == RoutineMoment.morning ? 'Routine du matin terminée ✅' : 'Routine du soir terminée ✅',
        body: 'Bravo, ta routine a bien été enregistrée dans SkinSnap.',
        nextTitle: 'On continue demain ✨',
        nextBody: 'Reviens sur SkinSnap pour suivre ta prochaine routine personnalisée.',
      );
    }
  }

  Future<void> _markAll(List<_RoutineDisplayItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final complete = items.isNotEmpty && items.every((item) => _done.contains(item.id));
    for (final item in items) {
      if (complete) {
        await prefs.remove(_itemKey(item.id));
      } else {
        await prefs.setBool(_itemKey(item.id), true);
      }
    }
    await SoundService().feedbackSave();
    if (!mounted) return;
    setState(() {
      if (complete) {
        _done.clear();
      } else {
        _done
          ..clear()
          ..addAll(items.map((item) => item.id));
      }
    });

    final app = context.read<AppProvider>();
    if (app.notificationsOn && !complete && items.isNotEmpty) {
      await NotificationService().onRoutineCompleted(
        morning: _moment == RoutineMoment.morning,
        title: _moment == RoutineMoment.morning ? 'Routine du matin terminée ✅' : 'Routine du soir terminée ✅',
        body: 'Bravo, toute la routine a été cochée avec succès.',
        nextTitle: 'À bientôt sur SkinSnap ✨',
        nextBody: 'Reviens demain pour garder un bon rythme dans ta routine.',
      );
    }
  }

  List<_RoutineDisplayItem> _fromPlan(BeautyPlan? plan) {
    if (plan == null) return const <_RoutineDisplayItem>[];
    final steps = _moment == RoutineMoment.morning ? plan.morningSteps : plan.eveningSteps;
    return steps
        .map(
          (step) => _RoutineDisplayItem(
            id: step.id,
            title: step.title,
            subtitle: step.productName,
            description: step.description,
            icon: Icons.spa_rounded,
            color: AppColors.hotPink,
          ),
        )
        .toList();
  }

  List<_RoutineDisplayItem> _fromProducts(List<ProductItem> products) {
    return products.where((product) {
      final usage = product.usage.toLowerCase();
      if (usage.contains('matin_soir') || usage.contains('daily') || usage.contains('makeup')) return true;
      if (_moment == RoutineMoment.morning) return usage.contains('matin') || usage.contains('morning');
      return usage.contains('soir') || usage.contains('night') || usage.contains('evening');
    }).map((product) {
      return _RoutineDisplayItem(
        id: product.id,
        title: product.routineStep.isEmpty ? product.category : product.routineStep,
        subtitle: product.name,
        description: product.description,
        product: product,
        icon: product.icon,
        color: product.color,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final plan = context.watch<BeautyPlanProvider>().currentPlan;

    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: StreamBuilder<List<ProductItem>>(
            stream: _service.userRoutineProducts(),
            builder: (context, snapshot) {
              final products = snapshot.data ?? const <ProductItem>[];
              final planItems = _fromPlan(plan);
              final routineItems = products.isNotEmpty ? _fromProducts(products) : planItems;
              final doneCount = routineItems.where((item) => _done.contains(item.id)).length;
              final progress = routineItems.isEmpty ? 0.0 : doneCount / routineItems.length;
              final complete = routineItems.isNotEmpty && doneCount == routineItems.length;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            app.tr('my_routine'),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.hotPink),
                          ),
                        ),
                        BeautyCircleIcon(icon: Icons.calendar_month_rounded, size: 44, onTap: _selectDate),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan == null ? app.tr('my_routine_sub') : '${plan.skinType} • ${plan.summary}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .65), fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 18),
                    _DaysRow(selected: _selectedDay, onSelect: _selectDay),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MomentTab(
                            label: app.tr('morning'),
                            active: _moment == RoutineMoment.morning,
                            onTap: () => _setMoment(RoutineMoment.morning),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MomentTab(
                            label: app.tr('evening'),
                            active: _moment == RoutineMoment.evening,
                            onTap: () => _setMoment(RoutineMoment.evening),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    BeautyCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${(progress * 100).round()}% complete',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: routineItems.isEmpty ? null : () => _markAll(routineItems),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(gradient: AppColors.beautyGradient, borderRadius: BorderRadius.circular(16)),
                                    child: Text(complete ? app.tr('reset') : app.tr('done'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: AppColors.blush, color: AppColors.hotPink),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: !_loaded || snapshot.connectionState == ConnectionState.waiting
                                ? const Center(child: CircularProgressIndicator(color: AppColors.hotPink))
                                : routineItems.isEmpty
                                    ? _EmptyRoutine(app: app)
                                    : Column(
                                        children: routineItems
                                            .map((item) => _RoutineTile(item: item, done: _done.contains(item.id), onTap: () => _toggle(item.id)))
                                            .toList(),
                                      ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                            child: GradientButton(
                              label: app.tr('add_routine'),
                              icon: Icons.add_circle_outline_rounded,
                              height: 48,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductMatchScreen())),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (products.isNotEmpty) ...[
                      Text(app.tr('compatible_products'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.hotPink)),
                      const SizedBox(height: 12),
                      ...products.map(
                        (product) => ProductCard(
                          product: product,
                          compact: true,
                          showAddButton: false,
                          onRemove: () async {
                            await _service.removeProductFromUserRoutine(product.id);
                            await SoundService().feedbackSave();
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _ProgressWeek(progress: progress),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoutineDisplayItem {
  const _RoutineDisplayItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    this.product,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final ProductItem? product;
}

class _EmptyRoutine extends StatelessWidget {
  const _EmptyRoutine({required this.app});
  final AppProvider app;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.spa_rounded, color: AppColors.hotPink, size: 42),
        const SizedBox(height: 10),
        Text(
          app.tr('empty_routine'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35),
        ),
      ],
    );
  }
}

class _DaysRow extends StatelessWidget {
  const _DaysRow({required this.selected, required this.onSelect});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final start = DateTime.now().subtract(const Duration(days: 2));
    return SizedBox(
      height: 74,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = DateTime(start.year, start.month, start.day + index);
          final active = day.year == selected.year && day.month == selected.month && day.day == selected.day;
          return GestureDetector(
            onTap: () => onSelect(day),
            child: Container(
              width: 64,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: active ? AppColors.hotPink : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'][day.weekday - 1], style: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.w900)),
                  Text('${day.day}', style: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MomentTab extends StatelessWidget {
  const _MomentTab({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(gradient: active ? AppColors.beautyGradient : null, color: active ? null : Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.white : AppColors.hotPink, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({required this.item, required this.done, required this.onTap});
  final _RoutineDisplayItem item;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: done ? AppColors.mint : AppColors.blush.withValues(alpha: .45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: done ? AppColors.success.withValues(alpha: .25) : AppColors.hotPink.withValues(alpha: .12)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: item.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
              child: Icon(item.icon, color: item.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(item.subtitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (item.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700, height: 1.3)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: done ? AppColors.success : AppColors.hotPink),
          ],
        ),
      ),
    );
  }
}

class _ProgressWeek extends StatelessWidget {
  const _ProgressWeek({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return BeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(app.tr('progress_week'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 14),
          Row(
            children: List.generate(7, (i) {
              final value = i < 3 ? 1.0 : (i == 3 ? progress : .2);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Container(
                        height: 82,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(14)),
                        child: FractionallySizedBox(heightFactor: value, child: Container(decoration: BoxDecoration(gradient: AppColors.beautyGradient, borderRadius: BorderRadius.circular(14)))),
                      ),
                      const SizedBox(height: 6),
                      Text(['L', 'M', 'M', 'J', 'V', 'S', 'D'][i], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
