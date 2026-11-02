import 'package:flutter/material.dart';

import '../models/food_item.dart';
import 'favorite_button.dart';
import 'food_image.dart';

String formatPrice(double price) =>
    '₹${price == price.roundToDouble() ? price.toStringAsFixed(0) : price.toStringAsFixed(2)}';

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.food,
    required this.onAdd,
    required this.onTap,
    this.width,
  });

  final FoodItem food;
  final VoidCallback onAdd;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    FoodImage(
                      imageUrl: food.imageUrl,
                      height: 126,
                      width: double.infinity,
                    ),
                    if (!food.isAvailable)
                      Positioned.fill(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.48),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Unavailable',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavoriteButton(foodId: food.id),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  food.category.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  food.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatPrice(food.price),
                        style: const TextStyle(
                          color: Color(0xFF172554),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: food.isAvailable ? onAdd : null,
                      tooltip: food.isAvailable
                          ? 'Add ${food.name}'
                          : 'Unavailable',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
