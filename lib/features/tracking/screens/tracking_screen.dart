import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/session.dart';
import '../providers/tracking_provider.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final _mapController = MapController();
  LatLng? _lastTrackedPosition;

  @override
  void initState() {
    super.initState();
    _centerOnCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _centerOnCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final target = LatLng(pos.latitude, pos.longitude);
      if (mounted) _mapController.move(target, 16);
    } catch (_) {
      // Permission not granted yet or location unavailable — leave default
    }
  }

  @override
  void didUpdateWidget(TrackingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(trackingProvider);
    final isTracking = tracking.isTracking;
    final isPaused = tracking.isCheatPaused;

    final routePoints = tracking.points
        .map((p) => LatLng(p.lat, p.lng))
        .toList();

    // Follow player while tracking
    if (isTracking && routePoints.isNotEmpty) {
      final latest = routePoints.last;
      if (latest != _lastTrackedPosition) {
        _lastTrackedPosition = latest;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _mapController.move(latest, _mapController.camera.zoom),
        );
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map (F-GPS-05)
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(52.237, 21.017),
              initialZoom: 16,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: dotenv.env['OSM_TILE_URL']!,
                userAgentPackageName: dotenv.env['OSM_USER_AGENT']!,
              ),
              if (routePoints.isNotEmpty) ...[
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4,
                      color: AppTheme.primaryYellow,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: routePoints.last,
                      child: const Icon(
                        Icons.circle,
                        color: AppTheme.primaryYellow,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // Stats overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _StatsCard(
              distanceKm: tracking.distanceKm,
              points: tracking.pointsEarned,
              isPaused: isPaused,
            ),
          ),

          // Center on player button
          Positioned(
            bottom: 140,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'center_map',
              backgroundColor: AppTheme.surfaceDark,
              foregroundColor: AppTheme.textPrimary,
              onPressed: _centerOnCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          // Start/Stop button
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: _TrackingButton(isTracking: isTracking),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.distanceKm,
    required this.points,
    required this.isPaused,
  });

  final double distanceKm;
  final int points;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPaused)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warning, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppTheme.warning, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Too fast — points paused',
                      style: TextStyle(
                        color: AppTheme.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                  label: 'Distance',
                  value: '${distanceKm.toStringAsFixed(2)} km',
                ),
                _Stat(
                  label: 'Points',
                  value: '$points pts',
                  highlight: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: highlight ? AppTheme.primaryYellow : null,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _TrackingButton extends ConsumerWidget {
  const _TrackingButton({required this.isTracking});

  final bool isTracking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _toggle(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isTracking ? AppTheme.error : AppTheme.primaryYellow,
          boxShadow: [
            BoxShadow(
              color: (isTracking ? AppTheme.error : AppTheme.primaryYellow)
                  .withAlpha(100),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(
          isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
          color: isTracking ? Colors.white : Colors.black,
          size: 40,
        ),
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(trackingProvider.notifier);
    if (!isTracking) {
      // TODO: pass real userId from auth provider
      await notifier.startSession(ActivityType.cycling, 'demo_user');
    } else {
      final session = await notifier.stopSession();
      if (session != null && context.mounted) {
        _showSessionSummary(context, session);
      }
    }
  }

  void _showSessionSummary(BuildContext context, dynamic session) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🦆', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Session complete!',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${session.distanceKm.toStringAsFixed(2)} km  •  ${session.pointsEarned} pts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
