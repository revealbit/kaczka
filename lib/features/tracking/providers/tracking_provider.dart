import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/local/database.dart';
import '../../../domain/models/gps_point.dart';
import '../../../domain/models/session.dart';
import '../services/anti_cheat_service.dart';
import '../services/gps_service.dart';

part 'tracking_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class TrackingState {
  const TrackingState({
    this.session,
    this.points = const [],
    this.distanceKm = 0.0,
    this.pointsEarned = 0,
    this.isCheatPaused = false,
    this.isTracking = false,
  });

  final Session? session;
  final List<GpsPoint> points;
  final double distanceKm;
  final int pointsEarned;
  final bool isCheatPaused;
  final bool isTracking;

  TrackingState copyWith({
    Session? session,
    List<GpsPoint>? points,
    double? distanceKm,
    int? pointsEarned,
    bool? isCheatPaused,
    bool? isTracking,
  }) {
    return TrackingState(
      session: session ?? this.session,
      points: points ?? this.points,
      distanceKm: distanceKm ?? this.distanceKm,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      isCheatPaused: isCheatPaused ?? this.isCheatPaused,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}

// ---------------------------------------------------------------------------
// Database provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

// ---------------------------------------------------------------------------
// Tracking notifier
// ---------------------------------------------------------------------------

@riverpod
class TrackingNotifier extends _$TrackingNotifier {
  final _gpsService = GpsService();
  final _antiCheat = AntiCheatService();
  final _uuid = const Uuid();

  StreamSubscription<GpsPoint>? _gpsSub;
  GpsPoint? _lastPoint;
  Timer? _syncTimer;

  @override
  TrackingState build() => const TrackingState();

  Future<void> startSession(ActivityType activityType, String userId) async {
    if (state.isTracking) return;

    final sessionId = _uuid.v4();
    final session = Session(
      id: sessionId,
      userId: userId,
      activityType: activityType,
      startedAt: DateTime.now(),
    );

    // Persist locally
    final db = ref.read(appDatabaseProvider);
    await db.sessionsDao.insertSession(
      SessionsTableCompanion(
        id: Value(session.id),
        userId: Value(session.userId),
        activityType: Value(activityType.name),
        startedAt: Value(session.startedAt),
      ),
    );

    _antiCheat.reset();
    _lastPoint = null;

    await _gpsService.start(sessionId);

    _gpsSub = _gpsService.pointStream?.listen((point) => _onGpsPoint(point, db));

    // Periodic sync every 60 s (F-GPS-03)
    _syncTimer = Timer.periodic(
      Duration(seconds: AppConstants.gpsSyncIntervalSeconds),
      (_) => _syncToBackend(db, sessionId),
    );

    state = state.copyWith(session: session, isTracking: true, points: []);
  }

  void _onGpsPoint(GpsPoint point, AppDatabase db) async {
    final isPaused = _antiCheat.process(point);

    // Persist locally regardless of pause (for backend re-validation)
    await db.gpsDao.insertPoint(
      GpsPointsTableCompanion(
        id: Value(point.id),
        sessionId: Value(point.sessionId),
        lat: Value(point.lat),
        lng: Value(point.lng),
        timestamp: Value(point.timestamp),
        accuracyMeters: Value(point.accuracyMeters),
        speedMps: Value(point.speedMps),
      ),
    );

    double addedDistance = 0.0;
    int addedPoints = 0;

    if (!isPaused && _lastPoint != null) {
      addedDistance = GpsService.haversineKm(
        _lastPoint!.lat,
        _lastPoint!.lng,
        point.lat,
        point.lng,
      );

      // Points: 1 per 100 m
      final prevMeters = (state.distanceKm * 1000).floor();
      final newMeters = ((state.distanceKm + addedDistance) * 1000).floor();
      addedPoints =
          ((newMeters ~/ AppConstants.metersPerPoint) - (prevMeters ~/ AppConstants.metersPerPoint))
              .clamp(0, 9999);
    }

    _lastPoint = point;

    state = state.copyWith(
      points: [...state.points, point],
      distanceKm: state.distanceKm + addedDistance,
      pointsEarned: state.pointsEarned + addedPoints,
      isCheatPaused: isPaused,
    );
  }

  Future<void> _syncToBackend(AppDatabase db, String sessionId) async {
    // TODO: call ApiClient POST /sessions/sync with unsynced points
    // Marked as stub — wired up in backend integration phase
    final unsynced = await db.gpsDao.getUnsyncedPoints(sessionId);
    if (unsynced.isEmpty) return;
    // await apiClient.post(ApiConstants.sessionsSync, data: { ... });
    // await db.gpsDao.markSynced(unsynced.map((p) => p.id).toList());
  }

  Future<Session?> stopSession() async {
    if (!state.isTracking || state.session == null) return null;

    _syncTimer?.cancel();
    _syncTimer = null;
    await _gpsSub?.cancel();
    _gpsSub = null;
    await _gpsService.stop();

    final db = ref.read(appDatabaseProvider);
    final endedAt = DateTime.now();

    await db.sessionsDao.updateSession(
      SessionsTableCompanion(
        id: Value(state.session!.id),
        endedAt: Value(endedAt),
        distanceKm: Value(state.distanceKm),
        pointsEarned: Value(state.pointsEarned),
      ),
    );

    final finishedSession = state.session!.copyWith(
      endedAt: endedAt,
      distanceKm: state.distanceKm,
      pointsEarned: state.pointsEarned,
    );

    state = const TrackingState(); // reset
    return finishedSession;
  }
}
