import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/task.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: wire to tasksProvider when backend is ready
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'Today'),
          _TaskCard(
            type: TaskType.daily,
            distanceKm: 8.0,
            progressKm: 3.4,
            bonusPoints: 80,
            validUntil: DateTime.now().add(const Duration(hours: 14)),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'This week'),
          _TaskCard(
            type: TaskType.weekly,
            distanceKm: 50.0,
            progressKm: 23.1,
            bonusPoints: 500,
            validUntil: DateTime.now().add(const Duration(days: 4)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.type,
    required this.distanceKm,
    required this.progressKm,
    required this.bonusPoints,
    required this.validUntil,
  });

  final TaskType type;
  final double distanceKm;
  final double progressKm;
  final int bonusPoints;
  final DateTime validUntil;

  double get _progress => (progressKm / distanceKm).clamp(0.0, 1.0);
  bool get _completed => progressKm >= distanceKm;

  @override
  Widget build(BuildContext context) {
    final hoursLeft = validUntil.difference(DateTime.now()).inHours;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type == TaskType.daily ? 'Daily Challenge' : 'Weekly Challenge',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_completed)
                  const Icon(Icons.check_circle, color: AppTheme.success)
                else
                  Text(
                    '${hoursLeft}h left',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: hoursLeft < 4 ? AppTheme.warning : null),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Run ${distanceKm.toStringAsFixed(0)} km',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppTheme.cardDark,
              color: _completed ? AppTheme.success : AppTheme.primaryYellow,
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
            const SizedBox(height: 6),
            Text(
              '${progressKm.toStringAsFixed(1)} / ${distanceKm.toStringAsFixed(0)} km',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: AppTheme.primaryYellow, size: 16),
                const SizedBox(width: 4),
                Text(
                  '+$bonusPoints bonus pts',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.primaryYellow,
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
