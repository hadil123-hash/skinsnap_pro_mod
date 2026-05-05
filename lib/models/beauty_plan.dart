import 'dart:convert';

enum RoutineMoment { morning, evening }

class ProductSuggestion {
  final String category;
  final String name;
  final String reason;
  final String usage;

  const ProductSuggestion({
    required this.category,
    required this.name,
    required this.reason,
    required this.usage,
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'name': name,
        'reason': reason,
        'usage': usage,
      };

  factory ProductSuggestion.fromJson(Map<String, dynamic> json) =>
      ProductSuggestion(
        category: json['category'] as String,
        name: json['name'] as String,
        reason: json['reason'] as String,
        usage: json['usage'] as String,
      );
}

class RoutineStep {
  final String id;
  final String title;
  final String description;
  final String productName;
  final RoutineMoment moment;

  const RoutineStep({
    required this.id,
    required this.title,
    required this.description,
    required this.productName,
    required this.moment,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'productName': productName,
        'moment': moment.name,
      };

  factory RoutineStep.fromJson(Map<String, dynamic> json) => RoutineStep(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        productName: json['productName'] as String,
        moment: (json['moment'] as String) == RoutineMoment.evening.name
            ? RoutineMoment.evening
            : RoutineMoment.morning,
      );
}

class BeautyPlan {
  final String sourceAnalysisId;
  final DateTime createdAt;
  final String skinType;
  final String summary;
  final String coachMessage;
  final List<String> concerns;
  final List<ProductSuggestion> products;
  final List<RoutineStep> morningSteps;
  final List<RoutineStep> eveningSteps;

  const BeautyPlan({
    required this.sourceAnalysisId,
    required this.createdAt,
    required this.skinType,
    required this.summary,
    required this.coachMessage,
    required this.concerns,
    required this.products,
    required this.morningSteps,
    required this.eveningSteps,
  });

  Map<String, dynamic> toJson() => {
        'sourceAnalysisId': sourceAnalysisId,
        'createdAt': createdAt.toIso8601String(),
        'skinType': skinType,
        'summary': summary,
        'coachMessage': coachMessage,
        'concerns': concerns,
        'products': products.map((item) => item.toJson()).toList(),
        'morningSteps': morningSteps.map((item) => item.toJson()).toList(),
        'eveningSteps': eveningSteps.map((item) => item.toJson()).toList(),
      };

  factory BeautyPlan.fromJson(Map<String, dynamic> json) => BeautyPlan(
        sourceAnalysisId: json['sourceAnalysisId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        skinType: json['skinType'] as String,
        summary: json['summary'] as String,
        coachMessage: json['coachMessage'] as String,
        concerns: List<String>.from(json['concerns'] as List),
        products: (json['products'] as List<dynamic>)
            .map((item) =>
                ProductSuggestion.fromJson(item as Map<String, dynamic>))
            .toList(),
        morningSteps: (json['morningSteps'] as List<dynamic>)
            .map((item) => RoutineStep.fromJson(item as Map<String, dynamic>))
            .toList(),
        eveningSteps: (json['eveningSteps'] as List<dynamic>)
            .map((item) => RoutineStep.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory BeautyPlan.fromJsonString(String value) =>
      BeautyPlan.fromJson(jsonDecode(value) as Map<String, dynamic>);
}

class RoutineProgressDay {
  final String dateKey;
  final List<String> morningCompletedIds;
  final List<String> eveningCompletedIds;

  const RoutineProgressDay({
    required this.dateKey,
    this.morningCompletedIds = const [],
    this.eveningCompletedIds = const [],
  });

  RoutineProgressDay copyWith({
    List<String>? morningCompletedIds,
    List<String>? eveningCompletedIds,
  }) {
    return RoutineProgressDay(
      dateKey: dateKey,
      morningCompletedIds: morningCompletedIds ?? this.morningCompletedIds,
      eveningCompletedIds: eveningCompletedIds ?? this.eveningCompletedIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'morningCompletedIds': morningCompletedIds,
        'eveningCompletedIds': eveningCompletedIds,
      };

  factory RoutineProgressDay.fromJson(Map<String, dynamic> json) =>
      RoutineProgressDay(
        dateKey: json['dateKey'] as String,
        morningCompletedIds:
            List<String>.from(json['morningCompletedIds'] as List? ?? const []),
        eveningCompletedIds:
            List<String>.from(json['eveningCompletedIds'] as List? ?? const []),
      );

  bool isMorningComplete(List<RoutineStep> steps) {
    if (steps.isEmpty) return false;
    return steps.every((step) => morningCompletedIds.contains(step.id));
  }

  bool isEveningComplete(List<RoutineStep> steps) {
    if (steps.isEmpty) return false;
    return steps.every((step) => eveningCompletedIds.contains(step.id));
  }

  bool isFullyComplete(BeautyPlan plan) =>
      isMorningComplete(plan.morningSteps) &&
      isEveningComplete(plan.eveningSteps);

  double morningProgress(List<RoutineStep> steps) {
    if (steps.isEmpty) return 0;
    final completed =
        steps.where((step) => morningCompletedIds.contains(step.id)).length;
    return completed / steps.length;
  }

  double eveningProgress(List<RoutineStep> steps) {
    if (steps.isEmpty) return 0;
    final completed =
        steps.where((step) => eveningCompletedIds.contains(step.id)).length;
    return completed / steps.length;
  }
}
