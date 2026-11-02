import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.foodId});

  final String foodId;

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favorites, child) {
        final isFavorite = favorites.isFavorite(foodId);
        return Material(
          color: Colors.white.withValues(alpha: 0.94),
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            visualDensity: VisualDensity.compact,
            onPressed: () async {
              try {
                await favorites.toggle(foodId);
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not update favorites: $error')),
                );
              }
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(isFavorite),
                color: isFavorite
                    ? const Color(0xFFE24B5B)
                    : const Color(0xFF344054),
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}
