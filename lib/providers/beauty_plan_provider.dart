import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/beauty_plan.dart';
import '../models/makeup_recommendation.dart';
import '../models/skin_analysis_result.dart';
import '../services/beauty_advisor_service.dart';

class BeautyPlanProvider extends ChangeNotifier {
  static const _kCurrentPlan = 'beauty_current_plan';
  static const _kRoutineProgress = 'beauty_routine_progress';

  final BeautyAdvisorService _advisor = BeautyAdvisorService();

  BeautyPlan? _currentPlan;
  Map<String, RoutineProgressDay> _progressByDate = {};

  BeautyPlan? get currentPlan => _currentPlan;
  bool get hasPlan => _currentPlan != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawPlan = prefs.getString(_kCurrentPlan);
    final rawProgress = prefs.getString(_kRoutineProgress);

    if (rawPlan != null && rawPlan.isNotEmpty) {
      _currentPlan = BeautyPlan.fromJsonString(rawPlan);
    }

    if (rawProgress != null && rawProgress.isNotEmpty) {
      final decoded = jsonDecode(rawProgress) as Map<String, dynamic>;
      _progressByDate = decoded.map(
        (key, value) => MapEntry(
          key,
          RoutineProgressDay.fromJson(value as Map<String, dynamic>),
        ),
      );
    }

    notifyListeners();
  }

  BeautyPlan previewPlan({
    required SkinAnalysisResult result,
    required Locale locale,
  }) {
    return _advisor.buildPlan(result: result, locale: locale);
  }

  Future<BeautyPlan> adoptFromResult({
    required SkinAnalysisResult result,
    required Locale locale,
  }) async {
    final plan = _advisor.buildPlan(result: result, locale: locale);
    await applyPlan(plan);
    return plan;
  }

  Future<void> applyPlan(BeautyPlan plan) async {
    _currentPlan = plan;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrentPlan, plan.toJsonString());
  }

  MakeupRecommendation buildMakeupRecommendation({
    required Locale locale,
    required String eventType,
    required String style,
  }) {
    return _advisor.buildMakeupRecommendation(
      locale: locale,
      eventType: eventType,
      style: style,
      plan: _currentPlan,
    );
  }

  String dateKeyFor(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  RoutineProgressDay progressFor(DateTime date) {
    return _progressByDate[dateKeyFor(date)] ??
        RoutineProgressDay(dateKey: dateKeyFor(date));
  }

  double morningProgress(DateTime date) {
    final plan = _currentPlan;
    if (plan == null) return 0;
    return progressFor(date).morningProgress(plan.morningSteps);
  }

  double eveningProgress(DateTime date) {
    final plan = _currentPlan;
    if (plan == null) return 0;
    return progressFor(date).eveningProgress(plan.eveningSteps);
  }

  double totalProgress(DateTime date) {
    return (morningProgress(date) + eveningProgress(date)) / 2;
  }

  Future<void> toggleStep({
    required DateTime date,
    required RoutineMoment moment,
    required String stepId,
  }) async {
    final key = dateKeyFor(date);
    final current = progressFor(date);

    if (moment == RoutineMoment.morning) {
      final ids = [...current.morningCompletedIds];
      if (ids.contains(stepId)) {
        ids.remove(stepId);
      } else {
        ids.add(stepId);
      }
      _progressByDate[key] = current.copyWith(morningCompletedIds: ids);
    } else {
      final ids = [...current.eveningCompletedIds];
      if (ids.contains(stepId)) {
        ids.remove(stepId);
      } else {
        ids.add(stepId);
      }
      _progressByDate[key] = current.copyWith(eveningCompletedIds: ids);
    }

    notifyListeners();
    await _persistProgress();
  }

  Future<void> markMomentComplete({
    required DateTime date,
    required RoutineMoment moment,
    required bool complete,
  }) async {
    final plan = _currentPlan;
    if (plan == null) return;

    final key = dateKeyFor(date);
    final current = progressFor(date);

    if (moment == RoutineMoment.morning) {
      _progressByDate[key] = current.copyWith(
        morningCompletedIds: complete
            ? plan.morningSteps.map((step) => step.id).toList()
            : <String>[],
      );
    } else {
      _progressByDate[key] = current.copyWith(
        eveningCompletedIds: complete
            ? plan.eveningSteps.map((step) => step.id).toList()
            : <String>[],
      );
    }

    notifyListeners();
    await _persistProgress();
  }

  Future<void> resetDay(DateTime date) async {
    _progressByDate.remove(dateKeyFor(date));
    notifyListeners();
    await _persistProgress();
  }

  int currentStreak() {
    final plan = _currentPlan;
    if (plan == null) return 0;

    var streak = 0;
    var day = DateTime.now();

    while (true) {
      final progress = _progressByDate[dateKeyFor(day)];
      if (progress == null || !progress.isFullyComplete(plan)) {
        break;
      }
      streak += 1;
      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<void> _persistProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kRoutineProgress,
      jsonEncode(
        _progressByDate.map((key, value) => MapEntry(key, value.toJson())),
      ),
    );
  }
}
