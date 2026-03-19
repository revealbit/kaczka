import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String username,
    required String email,
    required int totalPoints,
    required int currentPoints,
    required int level,
    required int streakDays,
    String? avatarUrl,
    String? avatarDuckBase,
    DateTime? lastActiveDate,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
