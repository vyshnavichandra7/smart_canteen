import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sample_menu.dart';
import '../models/food_item.dart';
import '../providers/favorites_provider.dart';
import '../providers/order_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_button.dart';
import '../widgets/canteen_logo.dart';
import '../widgets/category_chip.dart';
import '../widgets/food_card.dart';
import '../widgets/food_details_sheet.dart';
import '../widgets/pickup_countdown.dart';
import 'cart_screen.dart';
import 'order_tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _category = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final visible = sampleMenu.where((food) {
      final matchesCategory = _category == 'All' || food.category == _category;
      final matchesSearch = food.name.toLowerCase().contains(
        _query.toLowerCase(),
      );
      return food.isAvailable && matchesCategory && matchesSearch;
    }).toList();
    final popular = visible.where((food) => food.isPopular).toList();
    final quickPicks = visible.where((food) => !food.isPopular).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CanteenLogo(size: 30),
            SizedBox(width: 8),
            Text('MGIT Canteen'),
          ],
        ),
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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Consumer<ProfileProvider>(
                  builder: (context, profile, child) => Text(
                    'Hey, ${profile.displayName} 👋',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'What sounds good for your next break?',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => setState(() => _query = value.trim()),
                  decoration: const InputDecoration(
                    hintText: 'What are you craving today?',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 18),
                _PromoBanner(onTap: () => widget.onNavigate(1)),
                const SizedBox(height: 14),
                const _LatestOrderBanner(),
                const SizedBox(height: 24),
                SizedBox(
                  height: 45,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: foodCategories.map((category) {
                      return CategoryChip(
                        label: category,
                        selected: _category == category,
                        onTap: () => setState(() => _category = category),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 22),
                _SectionHeading(
                  title: _query.isEmpty
                      ? 'Popular on Campus'
                      : 'Search results',
                  action: 'See menu',
                  onAction: () => widget.onNavigate(1),
                ),
                const SizedBox(height: 12),
                if (popular.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'No matching dishes right now. Try another search.',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  )
                else
                  SizedBox(
                    height: 268,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: popular.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          _foodCard(popular[index]),
                    ),
                  ),
                const SizedBox(height: 24),
                _FavoritesSection(onSeeAll: () => widget.onNavigate(1)),
                const SizedBox(height: 24),
                _SectionHeading(
                  title: 'Quick Picks',
                  action: 'View all',
                  onAction: () => widget.onNavigate(1),
                ),
                const SizedBox(height: 12),
                if (quickPicks.isEmpty)
                  const Text(
                    'More good things are on the menu.',
                    style: TextStyle(color: AppTheme.muted),
                  )
                else
                  SizedBox(
                    height: 268,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: quickPicks.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          _foodCard(quickPicks[index]),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _foodCard(FoodItem food) => FoodCard(
    food: food,
    width: 204,
    onAdd: () => addFoodToCart(context, food),
    onTap: () => showFoodDetails(context, food),
  );
}

class _LatestOrderBanner extends StatelessWidget {
  const _LatestOrderBanner();

  @override
  Widget build(BuildContext context) => Consumer<OrderProvider>(
    builder: (context, orders, child) {
      final order = orders.latestOrder;
      if (order == null) return const SizedBox.shrink();
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => OrderTrackingScreen(orderId: order.id),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8EAF0)),
            ),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1E6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppTheme.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your order · ${order.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            order.displayStatus,
                            style: TextStyle(
                              color: order.isCancelled
                                  ? const Color(0xFFB42318)
                                  : AppTheme.navy,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (!order.isCancelled) ...[
                            const SizedBox(width: 10),
                            PickupCountdown(order: order),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _FavoritesSection extends StatelessWidget {
  const _FavoritesSection({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) => Consumer<FavoritesProvider>(
    builder: (context, favorites, child) {
      final favoriteFoods = sampleMenu
          .where((food) => favorites.isFavorite(food.id) && food.isAvailable)
          .toList();
      if (favoriteFoods.isEmpty) return const SizedBox.shrink();
      return Column(
        children: [
          _SectionHeading(
            title: 'Your favorites',
            action: 'See menu',
            onAction: onSeeAll,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 268,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: favoriteFoods.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final food = favoriteFoods[index];
                return FoodCard(
                  food: food,
                  width: 204,
                  onAdd: () => addFoodToCart(context, food),
                  onTap: () => showFoodDetails(context, food),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      TextButton(onPressed: onAction, child: Text(action)),
    ],
  );
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppTheme.navy,
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 154,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFF172554), Color(0xFF253E7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Your break,\nmade better.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    'Order ahead · Pick up when ready',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fastfood_rounded,
                color: AppTheme.orange,
                size: 49,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
