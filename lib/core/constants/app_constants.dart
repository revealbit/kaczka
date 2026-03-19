class AppConstants {
  AppConstants._();

  // GPS tracking
  static const int gpsIntervalSeconds = 5;
  static const double gpsMaxAccuracyMeters = 50.0;
  static const int gpsSyncIntervalSeconds = 60;

  // Anti-cheat: speed threshold for cheat detection (40 km/h = 11.11 m/s)
  static const double maxSpeedMps = 11.11;
  static const int cheatingConsecutivePoints = 3;

  // Points: 1 point per 100 m
  static const double metersPerPoint = 100.0;

  // Task distance constraints
  static const double dailyTaskMinKm = 4.0;
  static const double dailyTaskMaxKm = 12.0;
  static const double weeklyTaskMinKm = 30.0;
  static const double weeklyTaskMaxKm = 100.0;
  static const double taskBonusPtsPerKm = 10.0;

  // Streak
  static const Duration streakGraceWindow = Duration(hours: 27); // 03:00 reset

  // App
  static const String appName = 'Kaczka';
  static const String duckBaseAsset = 'assets/images/duck_base.png';
}
