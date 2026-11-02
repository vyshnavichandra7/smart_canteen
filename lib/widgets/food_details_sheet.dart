import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import 'food_card.dart';
import 'food_image.dart';

Future<void> addFoodToCart(BuildContext context, FoodItem food) async {
  try {
    await context.read<CartProvider>().add(food);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${food.name} added to your cart')),
      );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Could not add item: $error')));
  }
}

void showFoodDetails(BuildContext context, FoodItem food) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FoodImage(
              imageUrl: food.imageUrl,
              height: 210,
              width: double.infinity,
            ),
            const SizedBox(height: 18),
            Text(
              food.category.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Text(food.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              food.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatPrice(food.price),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: food.isAvailable
                      ? () async {
                          await addFoodToCart(context, food);
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: Text(food.isAvailable ? 'Add to cart' : 'Unavailable'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
