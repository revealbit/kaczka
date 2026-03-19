import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: wire to socialProvider
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Social'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Leaderboard'),
              Tab(text: 'Friends'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LeaderboardTab(),
            _FriendsTab(),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab();

  @override
  Widget build(BuildContext context) {
    final fakeRanks = [
      ('🥇', 'You', 1240),
      ('🥈', 'Marek', 1100),
      ('🥉', 'Ania', 980),
      ('4', 'Bartek', 730),
      ('5', 'Zosia', 410),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: fakeRanks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final (medal, name, pts) = fakeRanks[i];
        final isMe = i == 0;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: isMe ? AppTheme.primaryYellow : AppTheme.cardDark,
            child: Text(medal, style: const TextStyle(fontSize: 18)),
          ),
          title: Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isMe ? AppTheme.primaryYellow : null,
                ),
          ),
          trailing: Text(
            '$pts pts',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        );
      },
    );
  }
}

class _FriendsTab extends StatelessWidget {
  const _FriendsTab();

  void _showAddFriendDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Add friend'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'e.g. quack_master',
          ),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final username = controller.text.trim();
              Navigator.pop(dialogCtx);
              if (username.isEmpty) return;
              // TODO: call socialProvider.addFriend(username)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Friend request sent to $username!'),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Send request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddFriendDialog(context),
            icon: const Icon(Icons.person_add),
            label: const Text('Add friend'),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text('Add friends to see them here!'),
          ),
        ),
      ],
    );
  }
}
