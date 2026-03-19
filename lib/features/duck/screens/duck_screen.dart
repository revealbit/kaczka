import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/costume.dart';

class DuckScreen extends ConsumerWidget {
  const DuckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: wire to duckProvider with real equipped costumes
    return Scaffold(
      appBar: AppBar(title: const Text('My Duck')),
      body: Column(
        children: [
          // Duck preview
          Expanded(
            flex: 3,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cardDark,
                      border: Border.all(
                        color: AppTheme.primaryYellow.withAlpha(60),
                        width: 2,
                      ),
                    ),
                  ),
                  const Text('🦆', style: TextStyle(fontSize: 100)),
                ],
              ),
            ),
          ),

          // Costume slots
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: CostumeType.values.map((type) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _SlotButton(type: type),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Equipped list
          Expanded(
            flex: 2,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Text(
                  'My costumes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Visit the shop to get costumes!'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Demo costumes per slot type
const _demoCostumes = {
  CostumeType.hat: [
    (emoji: '🎩', name: 'Top Hat'),
    (emoji: '🧢', name: 'Cap'),
    (emoji: '👑', name: 'Crown'),
  ],
  CostumeType.body: [
    (emoji: '🦺', name: 'Safety Vest'),
    (emoji: '👔', name: 'Shirt'),
    (emoji: '🥋', name: 'Gi'),
  ],
  CostumeType.accessory: [
    (emoji: '🕶️', name: 'Cool Shades'),
    (emoji: '📿', name: 'Necklace'),
    (emoji: '🎀', name: 'Bow'),
  ],
  CostumeType.background: [
    (emoji: '🌊', name: 'Wave BG'),
    (emoji: '🌅', name: 'Sunset BG'),
    (emoji: '🌲', name: 'Forest BG'),
  ],
};

class _SlotButton extends StatelessWidget {
  const _SlotButton({required this.type});
  final CostumeType type;

  static const _labels = {
    CostumeType.hat: ('🎩', 'Hat'),
    CostumeType.body: ('👕', 'Body'),
    CostumeType.accessory: ('💎', 'Acc'),
    CostumeType.background: ('🌄', 'BG'),
  };

  void _showSlotSheet(BuildContext context) {
    final (_, label) = _labels[type]!;
    final items = _demoCostumes[type] ?? [];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose $label',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => ListTile(
                leading: Text(item.emoji, style: const TextStyle(fontSize: 28)),
                title: Text(item.name),
                trailing: const Icon(Icons.check_circle_outline,
                    color: AppTheme.primaryYellow),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  // TODO: wire to duckProvider.equip(type, item)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} equipped!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: AppTheme.textSecondary),
              title: const Text('None (remove)'),
              onTap: () {
                Navigator.pop(sheetCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label slot cleared.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (emoji, label) = _labels[type]!;
    return GestureDetector(
      onTap: () => _showSlotSheet(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryYellow.withAlpha(80),
              ),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
