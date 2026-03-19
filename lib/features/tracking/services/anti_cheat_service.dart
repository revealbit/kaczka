import '../../../core/constants/app_constants.dart';
import '../../../domain/models/gps_point.dart';

/// Detects cheating based on consecutive high-speed GPS readings.
///
/// Rule (F-AC-01): if speed > 40 km/h for ≥3 consecutive points → pause scoring.
class AntiCheatService {
  int _consecutiveFastPoints = 0;
  bool _isPaused = false;

  bool get isPaused => _isPaused;

  /// Feed one GPS point. Returns whether scoring should be paused.
  bool process(GpsPoint point) {
    if (point.speedMps > AppConstants.maxSpeedMps) {
      _consecutiveFastPoints++;
      if (_consecutiveFastPoints >= AppConstants.cheatingConsecutivePoints) {
        _isPaused = true;
      }
    } else {
      _consecutiveFastPoints = 0;
      _isPaused = false; // auto-resume when speed drops (F-AC-03)
    }
    return _isPaused;
  }

  void reset() {
    _consecutiveFastPoints = 0;
    _isPaused = false;
  }
}
