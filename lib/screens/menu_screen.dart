import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sample_menu.dart';
import '../models/food_item.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_button.dart';
import '../widgets/category_chip.dart';
import '../widgets/empty_state.dart';
import '../widgets/food_card.dart';
import '../widgets/food_details_sheet.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _category = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final favoriteIds = context.watch<FavoritesProvider>().favoriteIds;
    final categories = ['All', ...foodCategories.skip(1), 'Favorites'];
    final foods = sampleMenu.where((food) {
      final categoryMatches = _category == 'Favorites'
          ? favoriteIds.contains(food.id)
          : _category == 'All' || food.category == _category;
      return categoryMatches &&
          food.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore the menu'),
        actions: [
          CartButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const CartScreen()),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: const InputDecoration(
                hintText: 'Search dishes',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: categories.map((category) {
                return CategoryChip(
                  label: category,
                  selected: _category == category,
                  onTap: () => setState(() => _category = category),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: foods.isEmpty
                ? EmptyState(
                    icon: _category == 'Favorites'
                        ? Icons.favorite_border_rounded
                        : Icons.search_off_rounded,
                    title: _category == 'Favorites'
                        ? 'No favorites yet'
                        : 'No dishes found',
                    message: _category == 'Favorites'
                        ? 'Tap the heart on a dish to save it here.'
                        : 'Try a different search or category.',
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth > 700 ? 3 : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        itemCount: foods.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: columns == 2 ? 0.73 : 0.82,
                        ),
                        itemBuilder: (context, index) =>
                            _buildFoodCard(foods[index]),
                      );
                    },
                  ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Menu and availability',
              style: TextStyle(color: AppTheme.muted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(FoodItem food) => FoodCard(
    food: food,
    onAdd: () => addFoodToCart(context, food),
    onTap: () => showFoodDetails(context, food),
  );
}
