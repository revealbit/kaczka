import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/models/gps_point.dart';

/// Manages background GPS location stream with accuracy filtering.
class GpsService {
  GpsService();

  final _uuid = const Uuid();
  StreamController<GpsPoint>? _controller;
  StreamSubscription<Position>? _positionSub;

  Stream<GpsPoint>? get pointStream => _controller?.stream;

  /// Start streaming GPS points. Call once per session.
  Future<void> start(String sessionId) async {
    _controller = StreamController<GpsPoint>.broadcast();

    await _requestPermissions();
    _initForegroundTask();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // metres — reduces noise
      timeLimit: null,
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) => _handlePosition(sessionId, pos),
    );
  }

  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
    await _controller?.close();
    _controller = null;
    FlutterForegroundTask.stopService();
  }

  void _handlePosition(String sessionId, Position pos) {
    // F-GPS-04: discard points with accuracy > 50 m
    if (pos.accuracy > AppConstants.gpsMaxAccuracyMeters) return;

    final point = GpsPoint(
      id: _uuid.v4(),
      sessionId: sessionId,
      lat: pos.latitude,
      lng: pos.longitude,
      timestamp: pos.timestamp,
      accuracyMeters: pos.accuracy,
      speedMps: pos.speed < 0 ? 0.0 : pos.speed,
    );

    _controller?.add(point);
  }

  /// Haversine distance in kilometres between two lat/lng pairs.
  static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _rad(double deg) => deg * math.pi / 180;

  Future<void> _requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    // Background permission is requested separately by Android system dialog
    // when the foreground service is started.
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'kaczka_gps_channel',
        channelName: 'GPS Tracking',
        channelDescription: 'Kaczka is tracking your activity in the background.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          AppConstants.gpsIntervalSeconds * 1000,
        ),
        autoRunOnBoot: false,
        allowWakeLock: true,
      ),
    );

    FlutterForegroundTask.startService(
      serviceId: 1001,
      notificationTitle: 'Kaczka — tracking',
      notificationText: 'Activity tracking is active',
    );
  }
}
