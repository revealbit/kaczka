import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: ${next.error}')),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // Duck hero
              Center(
                child: Column(
                  children: [
                    const Text('🦆', style: TextStyle(fontSize: 96)),
                    const SizedBox(height: 16),
                    Text(
                      'Kaczka',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppTheme.primaryYellow,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Move. Earn. Evolve.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Feature bullets
              ...[
                ('🏃', 'Track runs & rides'),
                ('⭐', 'Earn points per km'),
                ('🎭', 'Dress your duck'),
                ('🏆', 'Compete with friends'),
              ].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Text(item.$1, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(
                        item.$2,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Google Sign-In button
              ElevatedButton.icon(
                onPressed: authAsync.isLoading
                    ? null
                    : () => ref.read(authProvider.notifier).signInWithGoogle(),
                icon: authAsync.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login, size: 20),
                label: Text(
                  authAsync.isLoading ? 'Signing in…' : 'Continue with Google',
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'By continuing you accept our Privacy Policy.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                    ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
