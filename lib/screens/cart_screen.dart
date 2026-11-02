import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/food_card.dart';
import '../widgets/food_image.dart';
import 'order_confirmation_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _placingOrder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is waiting',
              message: 'Add something tasty from the menu to get started.',
              actionLabel: 'Continue shopping',
              onAction: () => Navigator.pop(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: cart.items.length + 2,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == cart.items.length) {
                return _PriceSummary(subtotal: cart.subtotal);
              }
              if (index == cart.items.length + 1) {
                return const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'No extra service or delivery charges.',
                    style: TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                );
              }
              return _CartItemTile(item: cart.items[index]);
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) => SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatPrice(cart.total),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: cart.isEmpty || _placingOrder
                      ? null
                      : () => _placeOrder(cart),
                  child: _placingOrder
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Place order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder(CartProvider cart) async {
    setState(() => _placingOrder = true);
    try {
      final order = await context.read<OrderProvider>().placeOrder(cart);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => OrderConfirmationScreen(orderId: order.id),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not place order: $error')));
    } finally {
      if (mounted) setState(() => _placingOrder = false);
    }
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            FoodImage(
              imageUrl: item.food.imageUrl,
              height: 76,
              width: 76,
              borderRadius: 14,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.food.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatPrice(item.food.price),
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove_rounded,
                        label: 'Decrease ${item.food.name}',
                        onTap: () => _update(
                          context,
                          () => cart.decrement(item.food.id),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add_rounded,
                        label: 'Increase ${item.food.name}',
                        onTap: () => _update(
                          context,
                          () => cart.increment(item.food.id),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatPrice(item.total),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove ${item.food.name}',
              onPressed: () =>
                  _update(context, () => cart.remove(item.food.id)),
              icon: const Icon(Icons.close_rounded, color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update cart: $error')));
    }
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 30,
    width: 30,
    child: IconButton.filledTonal(
      onPressed: onTap,
      tooltip: label,
      padding: EdgeInsets.zero,
      iconSize: 17,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon),
    ),
  );
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.subtotal});

  final double subtotal;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _PriceRow(label: 'Subtotal', amount: subtotal),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _PriceRow(label: 'Total', amount: subtotal, bold: true),
        ],
      ),
    ),
  );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    this.bold = false,
  });

  final String label;
  final double amount;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: bold ? AppTheme.ink : AppTheme.muted,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
      Text(
        formatPrice(amount),
        style: TextStyle(
          color: AppTheme.ink,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    ],
  );
}
