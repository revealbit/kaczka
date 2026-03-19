import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge.freezed.dart';
part 'challenge.g.dart';

enum ChallengeType { distance }

@freezed
abstract class Challenge with _$Challenge {
  const factory Challenge({
    required String id,
    required String creatorId,
    required ChallengeType type,
    required double targetKm,
    required DateTime startDate,
    required DateTime endDate,
    @Default([]) List<ChallengeParticipant> participants,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);
}

@freezed
abstract class ChallengeParticipant with _$ChallengeParticipant {
  const factory ChallengeParticipant({
    required String userId,
    required String username,
    required double progressKm,
    DateTime? completedAt,
  }) = _ChallengeParticipant;

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChallengeParticipantFromJson(json);
}

@freezed
abstract class FriendRank with _$FriendRank {
  const factory FriendRank({
    required String userId,
    required String username,
    required int weeklyPoints,
    required int rank,
    String? avatarUrl,
  }) = _FriendRank;

  factory FriendRank.fromJson(Map<String, dynamic> json) => _$FriendRankFromJson(json);
}
