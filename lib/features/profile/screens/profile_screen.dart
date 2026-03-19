import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).value;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + info
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.cardDark,
                  child: Text('🦆', style: TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.username ?? 'Username',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              _StatCard(
                label: 'Level',
                value: '${user?.level ?? 1}',
                icon: Icons.emoji_events,
              ),
              _StatCard(
                label: 'Streak',
                value: '${user?.streakDays ?? 0}d 🔥',
                icon: Icons.local_fire_department,
              ),
              _StatCard(
                label: 'Points',
                value: '${user?.totalPoints ?? 0}',
                icon: Icons.star,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Settings list
          Card(
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.history,
                  label: 'Session history',
                  onTap: () => context.push('/profile/history'),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.download,
                  label: 'Export my data',
                  onTap: () => _exportData(context, ref),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.delete_forever,
                  label: 'Delete account',
                  color: AppTheme.error,
                  onTap: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider).value;
    final user = authState is AuthAuthenticated ? authState.user : null;

    final exportJson = '''
{
  "id": "${user?.id ?? ''}",
  "username": "${user?.username ?? ''}",
  "email": "${user?.email ?? ''}",
  "total_points": ${user?.totalPoints ?? 0},
  "level": ${user?.level ?? 1},
  "streak_days": ${user?.streakDays ?? 0},
  "exported_at": "${DateTime.now().toIso8601String()}"
}''';

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Your data (GDPR export)'),
        content: SingleChildScrollView(
          child: SelectableText(
            exportJson,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'All your data will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(dialogCtx);
              // TODO: call GDPR delete endpoint, then sign out
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryYellow, size: 22),
              const SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label, style: TextStyle(color: c)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
