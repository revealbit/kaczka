import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/costume.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: wire to shopProvider (daily rotation from backend)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Shop'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.primaryYellow, size: 18),
                const SizedBox(width: 4),
                Text(
                  '1 200 pts',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.primaryYellow,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemCount: _demoItems.length,
        itemBuilder: (context, i) => _ShopItemCard(item: _demoItems[i]),
      ),
    );
  }
}

const _demoItems = [
  (emoji: '🎩', name: 'Top Hat', rarity: CostumeRarity.rare, price: 350),
  (emoji: '🕶️', name: 'Cool Shades', rarity: CostumeRarity.common, price: 150),
  (emoji: '🌊', name: 'Wave BG', rarity: CostumeRarity.epic, price: 800),
  (emoji: '🦺', name: 'Safety Vest', rarity: CostumeRarity.common, price: 120),
];

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({required this.item});

  final ({String emoji, String name, CostumeRarity rarity, int price}) item;

  Color get _rarityColor => switch (item.rarity) {
        CostumeRarity.common => AppTheme.textSecondary,
        CostumeRarity.rare => const Color(0xFF4D9EFF),
        CostumeRarity.epic => const Color(0xFFBD5FFF),
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showBuyDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 56),
                  ),
                ),
              ),
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item.rarity.name.toUpperCase(),
                style: TextStyle(
                  color: _rarityColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _showBuyDialog(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 14),
                    const SizedBox(width: 4),
                    Text('${item.price}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBuyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Buy ${item.name}?'),
        content: Text('Cost: ${item.price} pts\nThis item will be added to your wardrobe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              // TODO: call shopProvider.buy(item.id)
            },
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }
}
