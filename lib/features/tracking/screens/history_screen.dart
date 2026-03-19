import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local/database.dart';
import '../providers/tracking_provider.dart';

final _dateFormat = DateFormat('d MMM yyyy, HH:mm');

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Session history')),
      body: FutureBuilder<List<SessionsTableData>>(
        future: db.sessionsDao.getCompletedSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data ?? [];

          if (sessions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🦆', style: TextStyle(fontSize: 56)),
                  SizedBox(height: 12),
                  Text('No sessions yet — go for a ride!'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _SessionCard(session: sessions[i]),
          );
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final SessionsTableData session;

  Duration get _duration {
    final end = session.endedAt;
    if (end == null) return Duration.zero;
    return end.difference(session.startedAt);
  }

  String get _durationLabel {
    final d = _duration;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  IconData get _activityIcon => switch (session.activityType) {
        'cycling' => Icons.directions_bike,
        'running' => Icons.directions_run,
        _ => Icons.fitness_center,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_activityIcon, color: AppTheme.primaryYellow),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dateFormat.format(session.startedAt.toLocal()),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Chip(
                        icon: Icons.route,
                        label: '${session.distanceKm.toStringAsFixed(2)} km',
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        icon: Icons.timer_outlined,
                        label: _durationLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${session.pointsEarned}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryYellow,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  'pts',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 3),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
