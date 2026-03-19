import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

enum TaskType { daily, weekly }

@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required String userId,
    required TaskType type,
    required double distanceKm,
    required int bonusPoints,
    required DateTime validFrom,
    required DateTime validUntil,
    @Default(0.0) double progressKm,
    DateTime? completedAt,
  }) = _Task;

  const Task._();

  double get progressPercent =>
      (progressKm / distanceKm).clamp(0.0, 1.0);

  bool get isCompleted => completedAt != null;

  bool get isExpired => DateTime.now().isAfter(validUntil);

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
