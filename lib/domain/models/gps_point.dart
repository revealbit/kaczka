import 'package:freezed_annotation/freezed_annotation.dart';

part 'gps_point.freezed.dart';
part 'gps_point.g.dart';

@freezed
abstract class GpsPoint with _$GpsPoint {
  const factory GpsPoint({
    required String id,
    required String sessionId,
    required double lat,
    required double lng,
    required DateTime timestamp,
    required double accuracyMeters,
    required double speedMps,
    @Default(false) bool synced,
  }) = _GpsPoint;

  factory GpsPoint.fromJson(Map<String, dynamic> json) => _$GpsPointFromJson(json);
}
