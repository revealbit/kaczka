import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';
part 'session.g.dart';

enum ActivityType { cycling, running }

@freezed
abstract class Session with _$Session {
  const factory Session({
    required String id,
    required String userId,
    required ActivityType activityType,
    required DateTime startedAt,
    DateTime? endedAt,
    @Default(0.0) double distanceKm,
    @Default(0) int pointsEarned,
    @Default(false) bool isValidated,
    @Default(0) int cheatFlagsCount,
    @Default(false) bool isCheatPaused,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
}
